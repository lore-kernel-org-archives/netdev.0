From: vidya@cumulusnetworks.com
Subject: [PATCH RFC ethtool]  QSFP Diagnostics Information Support
Date: Fri,  9 Jan 2015 15:41:56 -0800
Message-ID: <1420846916-39510-1-git-send-email-vidya@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, vidya@cumulusnetworks.com,
	roopa@cumulusnetworks.com, bkenward@solarflare.com,
	dave.lee@finisar.com
To: netdev@vger.kernel.org, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:54692 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbbAIXmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 18:42:03 -0500
Received: by mail-yh0-f41.google.com with SMTP id a41so5495854yho.0
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 15:42:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

This patch provides support for diagnostics information
for QSFP Plus modules which based on SFF 8436 specification
This implementation is loosely based on current SFP DOM parser
and SFF-8436 specs (ftp://ftp.seagate.com/pub/sff/SFF-8436.PDF)
by SFF Committee.

Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
---
 Makefile.am    |    2 +-
 ethtool-copy.h |    2 +
 ethtool.c      |    3 +
 internal.h     |    3 +
 qsfp.c         |  827 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 qsfp.h         |  541 ++++++++++++++++++++++++++++++++++++
 6 files changed, 1377 insertions(+), 1 deletion(-)
 create mode 100644 qsfp.c
 create mode 100644 qsfp.h

diff --git a/Makefile.am b/Makefile.am
index 4698d16..b6162db 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -13,7 +13,7 @@ ethtool_SOURCES += \
 		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
 		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
-		  sfpid.c sfpdiag.c ixgbevf.c tse.c
+		  sfpid.c sfpdiag.c ixgbevf.c tse.c qsfp.c
 endif
 
 TESTS = test-cmdline test-features
diff --git a/ethtool-copy.h b/ethtool-copy.h
index 61b78fc..8c4fb8b 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -1314,6 +1314,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETH_MODULE_SFF_8079_LEN		256
 #define ETH_MODULE_SFF_8472		0x2
 #define ETH_MODULE_SFF_8472_LEN		512
+#define ETH_MODULE_SFF_8436     0x3
+#define ETH_MODULE_SFF_8436_LEN     640
 
 /* Reset flags */
 /* The reset() operation must clear the flags for the components which
diff --git a/ethtool.c b/ethtool.c
index bf583f3..8cf1968 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3918,6 +3918,9 @@ static int do_getmodule(struct cmd_context *ctx)
 				sff8079_show_all(eeprom->data);
 				sff8472_show_all(eeprom->data);
 				break;
+			case ETH_MODULE_SFF_8436:
+				sff8436_show_all(eeprom->data);
+				break;
 #endif
 			default:
 				geeprom_dump_hex = 1;
diff --git a/internal.h b/internal.h
index a9dfae0..03543a9 100644
--- a/internal.h
+++ b/internal.h
@@ -262,4 +262,7 @@ void sff8079_show_all(const __u8 *id);
 /* Optics diagnostics */
 void sff8472_show_all(const __u8 *id);
 
+/* QSFP Optics diagnostics */
+void sff8436_show_all(const __u8 *id);
+
 #endif /* ETHTOOL_INTERNAL_H__ */
diff --git a/qsfp.c b/qsfp.c
new file mode 100644
index 0000000..03e80d9
--- /dev/null
+++ b/qsfp.c
@@ -0,0 +1,827 @@
+/*
+ * qsfp.c: Implements SFF-8436 based QSFP+ Diagnostics Memory map.
+ *
+ * Copyright (C) 2014 Cumulus networks Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Freeoftware Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ *  Vidya Ravipati <vidya@cumulusnetworks.com>
+ *   This implementation is loosely based on current SFP parser
+ *   and SFF-8436 specs (ftp://ftp.seagate.com/pub/sff/SFF-8436.PDF)
+ *   by SFF Committee.
+ */
+
+/*
+ *	Description:
+ *	a) The register/memory layout is up to 5 128 byte pages defined by
+ *		a "pages valid" register and switched via a "page select"
+ *		register. Memory of 256 bytes can be memory mapped at a time
+ *		according to SFF 8436.
+ *	b) SFF 8436 based 640 bytes memory layout is presented for parser
+ *
+ *           SFF 8436 based QSFP Memory Map
+ *
+ *           2-Wire Serial Address: 1010000x
+ *
+ *           Lower Page 00h (128 bytes)
+ *           ======================
+ *           |                     |
+ *           |Page Select Byte(127)|
+ *           ======================
+ *                    |
+ *                    V
+ *	     ----------------------------------------
+ *	    |             |            |             |
+ *	    V             V            V             V
+ *	 ----------   ----------   ---------    ------------
+ *	| Upper    | | Upper    | | Upper    | | Upper      |
+ *	| Page 00h | | Page 01h | | Page 02h | | Page 03h   |
+ *	|          | |(Optional)| |(Optional)| | (Optional) |
+ *	|          | |          | |          | |            |
+ *	|          | |          | |          | |            |
+ *	|    ID    | |   AST    | |  User    | |  For       |
+ *	|  Fields  | |  Table   | | EEPROM   | |  Cable     |
+ *	|          | |          | | Data     | | Assemblies |
+ *	|          | |          | |          | |            |
+ *	|          | |          | |          | |            |
+ *	-----------  -----------   ----------  --------------
+ *
+ *
+ **/
+#include <stdio.h>
+#include <math.h>
+#include "internal.h"
+#include "qsfp.h"
+
+#define MAX_DESC_SIZE	42
+
+/* Channel Monitoring Fields */
+struct sff8436_channel_diags {
+
+	__u16 bias_cur;      /* Measured bias current in 2uA units */
+	__u16 rx_power;      /* Measured RX Power */
+
+};
+
+/* Module Monitoring Fields */
+struct sff8436_diags {
+
+#define MAX_CHANNEL_NUM 4
+#define LWARN 0
+#define HWARN 1
+#define LALRM 2
+#define HALRM 3
+
+	__u8 supports_dom;      /* Supports DOM */
+	__u8 supports_alarms;   /* Supports alarm/warning thold */
+	__u8  rx_power_type;    /* 0 = OMA, 1 = Average power */
+	__u16 sfp_voltage;   /* SFP voltage in 0.1mV units */
+	__s16 sfp_temp;      /* SFP Temp in 16-bit signed 1/256 Celcius */
+	/* [4] tables are low/high warn, low/high alarm */
+	/* SFP voltage in 0.1mV units */
+	__u16 thresh_sfp_voltage[4];
+	/* SFP Temp in 16-bit signed 1/256 Celcius */
+	__s16 thresh_sfp_temp[4];
+	/* Measured bias current in 2uA units */
+	__u16 thresh_bias_cur[4];
+	/* Measured RX Power */
+	__u16 thresh_rx_power[4];
+	struct sff8436_channel_diags scd[MAX_CHANNEL_NUM];
+};
+
+static struct sff8436_aw_flags {
+	const char *str;        /* Human-readable string, null at the end */
+	int offset;             /* A2-relative adress offset */
+	__u8 value;             /* Alarm is on if (offset & value) != 0. */
+} sff8436_aw_flags[] = {
+	{ "Laser bias current high alarm   (Chan 1)",
+		SFF8436_TX_BIAS_12_AW_OFFSET, (SFF8436_TX_BIAS_1_HALARM) },
+	{ "Laser bias current low alarm    (Chan 1)",
+		SFF8436_TX_BIAS_12_AW_OFFSET, (SFF8436_TX_BIAS_1_LALARM) },
+	{ "Laser bias current high warning (Chan 1)",
+		SFF8436_TX_BIAS_12_AW_OFFSET, (SFF8436_TX_BIAS_1_HWARN) },
+	{ "Laser bias current low warning  (Chan 1)",
+		SFF8436_TX_BIAS_12_AW_OFFSET, (SFF8436_TX_BIAS_1_LWARN) },
+
+	{ "Laser bias current high alarm   (Chan 2)",
+		SFF8436_TX_BIAS_12_AW_OFFSET, (SFF8436_TX_BIAS_2_HALARM) },
+	{ "Laser bias current low alarm    (Chan 2)",
+		SFF8436_TX_BIAS_12_AW_OFFSET, (SFF8436_TX_BIAS_2_LALARM) },
+	{ "Laser bias current high warning (Chan 2)",
+		SFF8436_TX_BIAS_12_AW_OFFSET, (SFF8436_TX_BIAS_2_HWARN) },
+	{ "Laser bias current low warning  (Chan 2)",
+		SFF8436_TX_BIAS_12_AW_OFFSET, (SFF8436_TX_BIAS_2_LWARN) },
+
+	{ "Laser bias current high alarm   (Chan 3)",
+		SFF8436_TX_BIAS_34_AW_OFFSET, (SFF8436_TX_BIAS_3_HALARM) },
+	{ "Laser bias current low alarm    (Chan 3)",
+		SFF8436_TX_BIAS_34_AW_OFFSET, (SFF8436_TX_BIAS_3_LALARM) },
+	{ "Laser bias current high warning (Chan 3)",
+		SFF8436_TX_BIAS_34_AW_OFFSET, (SFF8436_TX_BIAS_3_HWARN) },
+	{ "Laser bias current low warning  (Chan 3)",
+		SFF8436_TX_BIAS_34_AW_OFFSET, (SFF8436_TX_BIAS_3_LWARN) },
+
+	{ "Laser bias current high alarm   (Chan 4)",
+		SFF8436_TX_BIAS_34_AW_OFFSET, (SFF8436_TX_BIAS_4_HALARM) },
+	{ "Laser bias current low alarm    (Chan 4)",
+		SFF8436_TX_BIAS_34_AW_OFFSET, (SFF8436_TX_BIAS_4_LALARM) },
+	{ "Laser bias current high warning (Chan 4)",
+		SFF8436_TX_BIAS_34_AW_OFFSET, (SFF8436_TX_BIAS_4_HWARN) },
+	{ "Laser bias current low warning  (Chan 4)",
+		SFF8436_TX_BIAS_34_AW_OFFSET, (SFF8436_TX_BIAS_4_LWARN) },
+
+	{ "Module temperature high alarm",
+		SFF8436_TEMP_AW_OFFSET, (SFF8436_TEMP_HALARM_STATUS) },
+	{ "Module temperature low alarm",
+		SFF8436_TEMP_AW_OFFSET, (SFF8436_TEMP_LALARM_STATUS) },
+	{ "Module temperature high warning",
+		SFF8436_TEMP_AW_OFFSET, (SFF8436_TEMP_HWARN_STATUS) },
+	{ "Module temperature low warning",
+		SFF8436_TEMP_AW_OFFSET, (SFF8436_TEMP_LWARN_STATUS) },
+
+	{ "Module voltage high alarm",
+		SFF8436_VCC_AW_OFFSET, (SFF8436_VCC_HALARM_STATUS) },
+	{ "Module voltage low alarm",
+		SFF8436_VCC_AW_OFFSET, (SFF8436_VCC_LALARM_STATUS) },
+	{ "Module voltage high warning",
+		SFF8436_VCC_AW_OFFSET, (SFF8436_VCC_HWARN_STATUS) },
+	{ "Module voltage low warning",
+		SFF8436_VCC_AW_OFFSET, (SFF8436_VCC_LWARN_STATUS) },
+
+	{ "Laser rx power high alarm   (Channel 1)",
+		SFF8436_RX_PWR_12_AW_OFFSET, (SFF8436_RX_PWR_1_HALARM) },
+	{ "Laser rx power low alarm    (Channel 1)",
+		SFF8436_RX_PWR_12_AW_OFFSET, (SFF8436_RX_PWR_1_LALARM) },
+	{ "Laser rx power high warning (Channel 1)",
+		SFF8436_RX_PWR_12_AW_OFFSET, (SFF8436_RX_PWR_1_HWARN) },
+	{ "Laser rx power low warning  (Channel 1)",
+		SFF8436_RX_PWR_12_AW_OFFSET, (SFF8436_RX_PWR_1_LWARN) },
+
+	{ "Laser rx power high alarm   (Channel 2)",
+		SFF8436_RX_PWR_12_AW_OFFSET, (SFF8436_RX_PWR_2_HALARM) },
+	{ "Laser rx power low alarm    (Channel 2)",
+		SFF8436_RX_PWR_12_AW_OFFSET, (SFF8436_RX_PWR_2_LALARM) },
+	{ "Laser rx power high warning (Channel 2)",
+		SFF8436_RX_PWR_12_AW_OFFSET, (SFF8436_RX_PWR_2_HWARN) },
+	{ "Laser rx power low warning  (Channel 2)",
+		SFF8436_RX_PWR_12_AW_OFFSET, (SFF8436_RX_PWR_2_LWARN) },
+
+	{ "Laser rx power high alarm   (Channel 3)",
+		SFF8436_RX_PWR_34_AW_OFFSET, (SFF8436_RX_PWR_3_HALARM) },
+	{ "Laser rx power low alarm    (Channel 3)",
+		SFF8436_RX_PWR_34_AW_OFFSET, (SFF8436_RX_PWR_3_LALARM) },
+	{ "Laser rx power high warning (Channel 3)",
+		SFF8436_RX_PWR_34_AW_OFFSET, (SFF8436_RX_PWR_3_HWARN) },
+	{ "Laser rx power low warning  (Channel 3)",
+		SFF8436_RX_PWR_34_AW_OFFSET, (SFF8436_RX_PWR_3_LWARN) },
+
+	{ "Laser rx power high alarm   (Channel 4)",
+		SFF8436_RX_PWR_34_AW_OFFSET, (SFF8436_RX_PWR_4_HALARM) },
+	{ "Laser rx power low alarm    (Channel 4)",
+		SFF8436_RX_PWR_34_AW_OFFSET, (SFF8436_RX_PWR_4_LALARM) },
+	{ "Laser rx power high warning (Channel 4)",
+		SFF8436_RX_PWR_34_AW_OFFSET, (SFF8436_RX_PWR_4_HWARN) },
+	{ "Laser rx power low warning  (Channel 4)",
+		SFF8436_RX_PWR_34_AW_OFFSET, (SFF8436_RX_PWR_4_LWARN) },
+
+	{ NULL, 0, 0 },
+};
+
+static void sff8436_show_identifier(const __u8 *id)
+{
+	printf("\t%-41s : 0x%02x", "Identifier", id[SFF8436_ID_OFFSET]);
+	switch (id[SFF8436_ID_OFFSET]) {
+	case SFF8436_ID_UNKNOWN:
+		printf(" (no module present, unknown, or unspecified)\n");
+		break;
+	case SFF8436_ID_GBIC:
+		printf(" (GBIC)\n");
+		break;
+	case SFF8436_ID_SOLDERED_MODULE:
+		printf(" (module soldered to motherboard)\n");
+		break;
+	case SFF8436_ID_SFP:
+		printf(" (SFP)\n");
+		break;
+	case SFF8436_ID_300_PIN_XBI:
+		printf(" (300 pin XBI)\n");
+		break;
+	case SFF8436_ID_XENPAK:
+		printf(" (XENPAK)\n");
+		break;
+	case SFF8436_ID_XFP:
+		printf(" (XFP)\n");
+		break;
+	case SFF8436_ID_XFF:
+		printf(" (XFF)\n");
+		break;
+	case SFF8436_ID_XFP_E:
+		printf(" (XFP-E)\n");
+		break;
+	case SFF8436_ID_XPAK:
+		printf(" (XPAK)\n");
+		break;
+	case SFF8436_ID_X2:
+		printf(" (X2)\n");
+		break;
+	case SFF8436_ID_DWDM_SFP:
+		printf(" (DWDM-SFP)\n");
+		break;
+	case SFF8436_ID_DWDM_QSFP:
+		printf(" (QSFP)\n");
+		break;
+	case SFF8436_ID_DWDM_QSFP_PLUS:
+		printf(" (QSFP+)\n");
+		break;
+	default:
+		printf(" (reserved or unknown)\n");
+		break;
+	}
+}
+
+static void sff8436_show_ext_identifier(const __u8 *id)
+{
+	printf("\t%-41s : 0x%02x", "Extended identifier",
+			id[SFF8436_EXT_ID_OFFSET]);
+
+	switch (id[SFF8436_EXT_ID_OFFSET] & SFF8436_EXT_ID_PWR_CLASS_MASK) {
+	case SFF8436_EXT_ID_PWR_CLASS_1:
+		printf(" (1.5W max. Power consumption,");
+		break;
+	case SFF8436_EXT_ID_PWR_CLASS_2:
+		printf(" (2.0W max. Power consumption,");
+		break;
+	case SFF8436_EXT_ID_PWR_CLASS_3:
+		printf(" (2.5W max. Power consumption,");
+		break;
+	case SFF8436_EXT_ID_PWR_CLASS_4:
+		printf(" (3.5W max. Power consumption,");
+		break;
+	}
+	if (id[SFF8436_EXT_ID_OFFSET] & SFF8436_EXT_ID_CDR_TX_MASK)
+		printf(" CDR present in TX,");
+	else
+		printf(" No CDR in TX,");
+
+	if (id[SFF8436_EXT_ID_OFFSET] & SFF8436_EXT_ID_CDR_RX_MASK)
+		printf(" CDR present in RX)\n");
+	else
+		printf(" No CDR in RX)\n");
+}
+
+static void sff8436_show_connector(const __u8 *id)
+{
+	printf("\t%-41s : 0x%02x", "Connector", id[SFF8436_CTOR_OFFSET]);
+	switch (id[SFF8436_CTOR_OFFSET]) {
+	case SFF8436_CTOR_UNKNOWN:
+		printf(" (unknown or unspecified)\n");
+		break;
+	case SFF8436_CTOR_SC:
+		printf(" (SC)\n");
+		break;
+	case SFF8436_CTOR_FC_STYLE_1:
+		printf(" (Fibre Channel Style 1 copper)\n");
+		break;
+	case SFF8436_CTOR_FC_STYLE_2:
+		printf(" (Fibre Channel Style 2 copper)\n");
+		break;
+	case SFF8436_CTOR_BNC_TNC:
+		printf(" (BNC/TNC)\n");
+		break;
+	case SFF8436_CTOR_FC_COAX:
+		printf(" (Fibre Channel coaxial headers)\n");
+		break;
+	case SFF8436_CTOR_FIBER_JACK:
+		printf(" (FibreJack)\n");
+		break;
+	case SFF8436_CTOR_LC:
+		printf(" (LC)\n");
+		break;
+	case SFF8436_CTOR_MT_RJ:
+		printf(" (MT-RJ)\n");
+		break;
+	case SFF8436_CTOR_MU:
+		printf(" (MU)\n");
+		break;
+	case SFF8436_CTOR_SG:
+		printf(" (SG)\n");
+		break;
+	case SFF8436_CTOR_OPT_PT:
+		printf(" (Optical pigtail)\n");
+		break;
+	case SFF8436_CTOR_MPO:
+		printf(" (MPO Parallel Optic)\n");
+		break;
+	case SFF8436_CTOR_HSDC_II:
+		printf(" (HSSDC II)\n");
+		break;
+	case SFF8436_CTOR_COPPER_PT:
+		printf(" (Copper pigtail)\n");
+		break;
+	case SFF8436_CTOR_RJ45:
+		printf(" (RJ45)\n");
+		break;
+	case SFF8436_CTOR_NO_SEPARABLE:
+		printf(" (No separable connector)\n");
+		break;
+	default:
+		printf(" (reserved or unknown)\n");
+		break;
+	}
+}
+
+static void sff8436_show_transceiver(const __u8 *id)
+{
+	static const char *pfx =
+		"\tTransceiver type                          :";
+
+	printf("\t%-41s : 0x%02x 0x%02x 0x%02x " \
+			"0x%02x 0x%02x 0x%02x 0x%02x 0x%02x\n",
+			"Transceiver codes",
+			id[SFF8436_ETHERNET_COMP_OFFSET],
+			id[SFF8436_SONET_COMP_OFFSET],
+			id[SFF8436_SAS_COMP_OFFSET],
+			id[SFF8436_GIGE_COMP_OFFSET],
+			id[SFF8436_FC_LEN_OFFSET],
+			id[SFF8436_FC_TECH_OFFSET],
+			id[SFF8436_FC_TRANS_MEDIA_OFFSET],
+			id[SFF8436_FC_SPEED_OFFSET]);
+
+	/* 10G/40G Ethernet Compliance Codes */
+	if (id[SFF8436_ETHERNET_COMP_OFFSET] & SFF8436_ETHERNET_RSRVD)
+		printf("%s (reserved or unknown)\n", pfx);
+	if (id[SFF8436_ETHERNET_COMP_OFFSET] & SFF8436_ETHERNET_10G_LRM)
+		printf("%s 10G Ethernet: 10G Base-LRM\n", pfx);
+	if (id[SFF8436_ETHERNET_COMP_OFFSET] & SFF8436_ETHERNET_10G_LR)
+		printf("%s 10G Ethernet: 10G Base-LR\n", pfx);
+	if (id[SFF8436_ETHERNET_COMP_OFFSET] & SFF8436_ETHERNET_10G_SR)
+		printf("%s 10G Ethernet: 10G Base-SR\n", pfx);
+	if (id[SFF8436_ETHERNET_COMP_OFFSET] & SFF8436_ETHERNET_40G_CR4)
+		printf("%s 40G Ethernet: 40G Base-CR4\n", pfx);
+	if (id[SFF8436_ETHERNET_COMP_OFFSET] & SFF8436_ETHERNET_40G_SR4)
+		printf("%s 40G Ethernet: 40G Base-SR4\n", pfx);
+	if (id[SFF8436_ETHERNET_COMP_OFFSET] & SFF8436_ETHERNET_40G_LR4)
+		printf("%s 40G Ethernet: 40G Base-LR4\n", pfx);
+	if (id[SFF8436_ETHERNET_COMP_OFFSET] & SFF8436_ETHERNET_40G_ACTIVE)
+		printf("%s 40G Ethernet: 40G Active Cable (XLPPI)\n", pfx);
+
+	/* SONET Compliance Codes */
+	if (id[SFF8436_SONET_COMP_OFFSET] & (SFF8436_SONET_40G_OTN))
+		printf("%s 40G OTN (OTU3B/OTU3C)\n", pfx);
+	if (id[SFF8436_SONET_COMP_OFFSET] & (SFF8436_SONET_OC48_LR))
+		printf("%s SONET: OC-48, long reach\n", pfx);
+	if (id[SFF8436_SONET_COMP_OFFSET] & (SFF8436_SONET_OC48_IR))
+		printf("%s SONET: OC-48, intermediate reach\n", pfx);
+	if (id[SFF8436_SONET_COMP_OFFSET] & (SFF8436_SONET_OC48_SR))
+		printf("%s SONET: OC-48, short reach\n", pfx);
+
+	/* SAS/SATA Compliance Codes */
+	if (id[SFF8436_SAS_COMP_OFFSET] & (SFF8436_SAS_6G))
+		printf("%s SAS 6.0G\n", pfx);
+	if (id[SFF8436_SAS_COMP_OFFSET] & (SFF8436_SAS_3G))
+		printf("%s SAS 3.0G\n", pfx);
+
+	/* Ethernet Compliance Codes */
+	if (id[SFF8436_GIGE_COMP_OFFSET] & SFF8436_GIGE_1000_BASE_T)
+		printf("%s Ethernet: 1000BASE-T\n", pfx);
+	if (id[SFF8436_GIGE_COMP_OFFSET] & SFF8436_GIGE_1000_BASE_CX)
+		printf("%s Ethernet: 1000BASE-CX\n", pfx);
+	if (id[SFF8436_GIGE_COMP_OFFSET] & SFF8436_GIGE_1000_BASE_LX)
+		printf("%s Ethernet: 1000BASE-LX\n", pfx);
+	if (id[SFF8436_GIGE_COMP_OFFSET] & SFF8436_GIGE_1000_BASE_SX)
+		printf("%s Ethernet: 1000BASE-SX\n", pfx);
+
+	/* Fibre Channel link length */
+	if (id[SFF8436_FC_LEN_OFFSET] & SFF8436_FC_LEN_VERY_LONG)
+		printf("%s FC: very long distance (V)\n", pfx);
+	if (id[SFF8436_FC_LEN_OFFSET] & SFF8436_FC_LEN_SHORT)
+		printf("%s FC: short distance (S)\n", pfx);
+	if (id[SFF8436_FC_LEN_OFFSET] & SFF8436_FC_LEN_INT)
+		printf("%s FC: intermediate distance (I)\n", pfx);
+	if (id[SFF8436_FC_LEN_OFFSET] & SFF8436_FC_LEN_LONG)
+		printf("%s FC: long distance (L)\n", pfx);
+	if (id[SFF8436_FC_LEN_OFFSET] & SFF8436_FC_LEN_MED)
+		printf("%s FC: medium distance (M)\n", pfx);
+
+	/* Fibre Channel transmitter technology */
+	if (id[SFF8436_FC_LEN_OFFSET] & SFF8436_FC_TECH_LONG_LC)
+		printf("%s FC: Longwave laser (LC)\n", pfx);
+	if (id[SFF8436_FC_LEN_OFFSET] & SFF8436_FC_TECH_ELEC_INTER)
+		printf("%s FC: Electrical inter-enclosure (EL)\n", pfx);
+	if (id[SFF8436_FC_TECH_OFFSET] & SFF8436_FC_TECH_ELEC_INTRA)
+		printf("%s FC: Electrical intra-enclosure (EL)\n", pfx);
+	if (id[SFF8436_FC_TECH_OFFSET] & SFF8436_FC_TECH_SHORT_WO_OFC)
+		printf("%s FC: Shortwave laser w/o OFC (SN)\n", pfx);
+	if (id[SFF8436_FC_TECH_OFFSET] & SFF8436_FC_TECH_SHORT_W_OFC)
+		printf("%s FC: Shortwave laser with OFC (SL)\n", pfx);
+	if (id[SFF8436_FC_TECH_OFFSET] & SFF8436_FC_TECH_LONG_LL)
+		printf("%s FC: Longwave laser (LL)\n", pfx);
+
+	/* Fibre Channel transmission media */
+	if (id[SFF8436_FC_TRANS_MEDIA_OFFSET] & SFF8436_FC_TRANS_MEDIA_TW)
+		printf("%s FC: Twin Axial Pair (TW)\n", pfx);
+	if (id[SFF8436_FC_TRANS_MEDIA_OFFSET] & SFF8436_FC_TRANS_MEDIA_TP)
+		printf("%s FC: Twisted Pair (TP)\n", pfx);
+	if (id[SFF8436_FC_TRANS_MEDIA_OFFSET] & SFF8436_FC_TRANS_MEDIA_MI)
+		printf("%s FC: Miniature Coax (MI)\n", pfx);
+	if (id[SFF8436_FC_TRANS_MEDIA_OFFSET] & SFF8436_FC_TRANS_MEDIA_TV)
+		printf("%s FC: Video Coax (TV)\n", pfx);
+	if (id[SFF8436_FC_TRANS_MEDIA_OFFSET] & SFF8436_FC_TRANS_MEDIA_M6)
+		printf("%s FC: Multimode, 62.5m (M6)\n", pfx);
+	if (id[SFF8436_FC_TRANS_MEDIA_OFFSET] & SFF8436_FC_TRANS_MEDIA_M5)
+		printf("%s FC: Multimode, 50m (M5)\n", pfx);
+	if (id[SFF8436_FC_TRANS_MEDIA_OFFSET] & SFF8436_FC_TRANS_MEDIA_OM3)
+		printf("%s FC: Multimode, 50um (OM3)\n", pfx);
+	if (id[SFF8436_FC_TRANS_MEDIA_OFFSET] & SFF8436_FC_TRANS_MEDIA_SM)
+		printf("%s FC: Single Mode (SM)\n", pfx);
+
+	/* Fibre Channel speed */
+	if (id[SFF8436_FC_SPEED_OFFSET] & SFF8436_FC_SPEED_1200_MBPS)
+		printf("%s FC: 1200 MBytes/sec\n", pfx);
+	if (id[SFF8436_FC_SPEED_OFFSET] & SFF8436_FC_SPEED_800_MBPS)
+		printf("%s FC: 800 MBytes/sec\n", pfx);
+	if (id[SFF8436_FC_SPEED_OFFSET] & SFF8436_FC_SPEED_1600_MBPS)
+		printf("%s FC: 1600 MBytes/sec\n", pfx);
+	if (id[SFF8436_FC_SPEED_OFFSET] & SFF8436_FC_SPEED_400_MBPS)
+		printf("%s FC: 400 MBytes/sec\n", pfx);
+	if (id[SFF8436_FC_SPEED_OFFSET] & SFF8436_FC_SPEED_200_MBPS)
+		printf("%s FC: 200 MBytes/sec\n", pfx);
+	if (id[SFF8436_FC_SPEED_OFFSET] & SFF8436_FC_SPEED_100_MBPS)
+		printf("%s FC: 100 MBytes/sec\n", pfx);
+}
+
+static void sff8436_show_encoding(const __u8 *id)
+{
+	printf("\t%-41s : 0x%02x", "Encoding", id[SFF8436_ENCODING_OFFSET]);
+	switch (id[SFF8436_ENCODING_OFFSET]) {
+	case SFF8436_ENCODING_UNSPEC:
+		printf(" (unspecified)\n");
+		break;
+	case SFF8436_ENCODING_8B10B:
+		printf(" (8B/10B)\n");
+		break;
+	case SFF8436_ENCODING_4B5B:
+		printf(" (4B/5B)\n");
+		break;
+	case SFF8436_ENCODING_NRZ:
+		printf(" (NRZ)\n");
+		break;
+	case SFF8436_ENCODING_SONET:
+		printf(" (SONET Scrambled)\n");
+		break;
+	case SFF8436_ENCODING_64B66B:
+		printf(" (64B/66B)\n");
+		break;
+	case SFF8436_ENCODING_MANCHESTER:
+		printf(" (Manchester)\n");
+		break;
+	default:
+		printf(" (reserved or unknown)\n");
+		break;
+	}
+}
+
+static void sff8436_show_rate_identifier(const __u8 *id)
+{
+	/* TODO: Need to fix rate select logic */
+	printf("\t%-41s : 0x%02x\n", "Rate identifier",
+			id[SFF8436_EXT_RS_OFFSET]);
+}
+
+static void sff8436_show_oui(const __u8 *id)
+{
+	printf("\t%-41s : %02x:%02x:%02x\n", "Vendor OUI",
+	       id[SFF8436_VENDOR_OUI_OFFSET],
+	       id[SFF8436_VENDOR_OUI_OFFSET + 1],
+	       id[SFF8436_VENDOR_OUI_OFFSET + 2]);
+}
+
+static void sff8436_show_wavelength_or_copper_compliance(const __u8 *id)
+{
+	printf("\t%-41s : 0x%02x", "Transmitter technology",
+		(id[SFF8436_DEVICE_TECH_OFFSET] & SFF8436_TRANS_TECH_MASK));
+
+	switch (id[SFF8436_DEVICE_TECH_OFFSET] & SFF8436_TRANS_TECH_MASK) {
+	case SFF8436_TRANS_850_VCSEL:
+		printf(" (850 nm VCSEL)\n");
+		break;
+	case SFF8436_TRANS_1310_VCSEL:
+		printf(" (1310 nm VCSEL)\n");
+		break;
+	case SFF8436_TRANS_1550_VCSEL:
+		printf(" (1550 nm VCSEL)\n");
+		break;
+	case SFF8436_TRANS_1310_FP:
+		printf(" (1310 nm FP)\n");
+		break;
+	case SFF8436_TRANS_1310_DFB:
+		printf(" (1310 nm DFB)\n");
+		break;
+	case SFF8436_TRANS_1550_DFB:
+		printf(" (1550 nm DFB)\n");
+		break;
+	case SFF8436_TRANS_1310_EML:
+		printf(" (1310 nm EML)\n");
+		break;
+	case SFF8436_TRANS_1550_EML:
+		printf(" (1550 nm EML)\n");
+		break;
+	case SFF8436_TRANS_OTHERS:
+		printf(" (Others)\n");
+		break;
+	case SFF8436_TRANS_1490_DFB:
+		printf(" (1490 nm DFB)\n");
+		break;
+	case SFF8436_TRANS_COPPER_PAS_UNEQUAL:
+		printf(" (Copper cable unequalized)\n");
+		break;
+	case SFF8436_TRANS_COPPER_PAS_EQUAL:
+		printf(" (Copper cable passive equalized)\n");
+		break;
+	case SFF8436_TRANS_COPPER_LNR_FAR_EQUAL:
+		printf(" (Copper cable, near and far end "
+			"limiting active equalizers)\n");
+		break;
+	case SFF8436_TRANS_COPPER_FAR_EQUAL:
+		printf(" (Copper cable, far end limiting "
+			"active equalizers)\n");
+		break;
+	case SFF8436_TRANS_COPPER_NEAR_EQUAL:
+		printf(" (Copper cable, near end limiting "
+			"active equalizers)\n");
+		break;
+	case SFF8436_TRANS_COPPER_LNR_EQUAL:
+		printf(" (Copper cable, linear active equalizers)\n");
+		break;
+	}
+
+	if ((id[SFF8436_DEVICE_TECH_OFFSET] & SFF8436_TRANS_TECH_MASK)
+			>= SFF8436_TRANS_COPPER_PAS_UNEQUAL) {
+		printf("\t%-41s : %udb\n", "Attenuation at 2.5GHz",
+			id[SFF8436_WAVELEN_HIGH_BYTE_OFFSET]);
+		printf("\t%-41s : %udb\n", "Attenuation at 5.0GHz",
+			id[SFF8436_WAVELEN_LOW_BYTE_OFFSET]);
+	} else {
+		printf("\t%-41s : %.3lfnm\n", "Laser wavelength",
+			(((id[SFF8436_WAVELEN_HIGH_BYTE_OFFSET] << 8) |
+				id[SFF8436_WAVELEN_LOW_BYTE_OFFSET])*0.05));
+		printf("\t%-41s : %.3lfnm\n", "Laser wavelength tolerance",
+			(((id[SFF8436_WAVE_TOL_HIGH_BYTE_OFFSET] << 8) |
+			id[SFF8436_WAVE_TOL_LOW_BYTE_OFFSET])*0.005));
+	}
+}
+
+static void sff8436_show_value_with_unit(const __u8 *id, unsigned int reg,
+					 const char *name, unsigned int mult,
+					 const char *unit)
+{
+	unsigned int val = id[reg];
+
+	printf("\t%-41s : %u%s\n", name, val * mult, unit);
+}
+
+static void sff8436_show_ascii(const __u8 *id, unsigned int first_reg,
+			       unsigned int last_reg, const char *name)
+{
+	unsigned int reg, val;
+
+	printf("\t%-41s : ", name);
+	for (reg = first_reg; reg <= last_reg; reg++) {
+		val = id[reg];
+		putchar(((val >= 32) && (val <= 126)) ? val : '_');
+	}
+	printf("\n");
+}
+
+static double convert_mw_to_dbm(double mw)
+{
+	return (10. * log10(mw / 1000.)) + 30.;
+}
+
+/* Most common case: 16-bit unsigned integer in a certain unit */
+#define OFFSET_TO_U16(offset) \
+	(id[offset] << 8 | id[offset + 1])
+
+/*
+ * 2-byte internal temperature conversions:
+ * First byte is a signed 8-bit integer, which is the temp decimal part
+ * Second byte are 1/256th of degree, which are added to the dec part.
+ */
+#define SFF8436_OFFSET_TO_TEMP(offset) ((__s16)OFFSET_TO_U16(offset))
+
+static void sff8436_dom_parse(const __u8 *id, struct sff8436_diags *sd)
+{
+	int i = 0;
+
+	/* Monitoring Thresholds for Alarms and Warnings */
+	sd->thresh_sfp_voltage[HALRM] = OFFSET_TO_U16(SFF8436_VCC_HALRM);
+	sd->thresh_sfp_voltage[LALRM] = OFFSET_TO_U16(SFF8436_VCC_LALRM);
+	sd->thresh_sfp_voltage[HWARN] = OFFSET_TO_U16(SFF8436_VCC_HWARN);
+	sd->thresh_sfp_voltage[LWARN] = OFFSET_TO_U16(SFF8436_VCC_LWARN);
+
+	sd->thresh_sfp_temp[HALRM] = SFF8436_OFFSET_TO_TEMP(SFF8436_TEMP_HALRM);
+	sd->thresh_sfp_temp[LALRM] = SFF8436_OFFSET_TO_TEMP(SFF8436_TEMP_LALRM);
+	sd->thresh_sfp_temp[HWARN] = SFF8436_OFFSET_TO_TEMP(SFF8436_TEMP_HWARN);
+	sd->thresh_sfp_temp[LWARN] = SFF8436_OFFSET_TO_TEMP(SFF8436_TEMP_LWARN);
+
+	sd->thresh_bias_cur[HALRM] = OFFSET_TO_U16(SFF8436_TX_BIAS_HALRM);
+	sd->thresh_bias_cur[LALRM] = OFFSET_TO_U16(SFF8436_TX_BIAS_LALRM);
+	sd->thresh_bias_cur[HWARN] = OFFSET_TO_U16(SFF8436_TX_BIAS_HWARN);
+	sd->thresh_bias_cur[LWARN] = OFFSET_TO_U16(SFF8436_TX_BIAS_LWARN);
+
+	sd->thresh_rx_power[HALRM] = OFFSET_TO_U16(SFF8436_RX_PWR_HALRM);
+	sd->thresh_rx_power[LALRM] = OFFSET_TO_U16(SFF8436_RX_PWR_LALRM);
+	sd->thresh_rx_power[HWARN] = OFFSET_TO_U16(SFF8436_RX_PWR_HWARN);
+	sd->thresh_rx_power[LWARN] = OFFSET_TO_U16(SFF8436_RX_PWR_LWARN);
+
+	/* Current Values for Module */
+	sd->sfp_voltage = OFFSET_TO_U16(SFF8436_VCC_CURR);
+	sd->sfp_temp = SFF8436_OFFSET_TO_TEMP(SFF8436_TEMP_CURR);
+
+	/* Channel Specific Data */
+	for (i = 0; i < MAX_CHANNEL_NUM; i++) {
+		u8 rx_power_offset, tx_bias_offset;
+
+		switch (i) {
+		case 0:
+			rx_power_offset = SFF8436_RX_PWR_1_OFFSET;
+			tx_bias_offset = SFF8436_TX_BIAS_1_OFFSET;
+			break;
+		case 1:
+			rx_power_offset = SFF8436_RX_PWR_2_OFFSET;
+			tx_bias_offset = SFF8436_TX_BIAS_2_OFFSET;
+			break;
+		case 2:
+			rx_power_offset = SFF8436_RX_PWR_3_OFFSET;
+			tx_bias_offset = SFF8436_TX_BIAS_3_OFFSET;
+			break;
+		case 3:
+			rx_power_offset = SFF8436_RX_PWR_4_OFFSET;
+			tx_bias_offset = SFF8436_TX_BIAS_4_OFFSET;
+			break;
+		default:
+			printf(" Invalid channel: %d\n", i);
+			break;
+		}
+		sd->scd[i].bias_cur = OFFSET_TO_U16(tx_bias_offset);
+		sd->scd[i].rx_power = OFFSET_TO_U16(rx_power_offset);
+	}
+
+}
+
+static void sff8436_show_dom(const __u8 *id)
+{
+	struct sff8436_diags sd;
+	char *rx_power_string = NULL;
+	char power_string[MAX_DESC_SIZE];
+	int i;
+
+	/*
+	 * There is no clear identifier to signify the existance of
+	 * optical diagnostics similar to SFF-8472. So checking existance
+	 * of page 3, will provide the gurantee for existance of alarms
+	 * and thresholds
+	 */
+	sd.supports_alarms = id[SFF8436_STATUS_2_OFFSET] &
+						SFF8436_STATUS_PAGE_3_PRESENT;
+	sd.rx_power_type = id[SFF8436_DIAG_TYPE_OFFSET] &
+						SFF8436_RX_PWR_TYPE_MASK;
+
+	sff8436_dom_parse(id, &sd);
+
+# define PRINT_xX_PWR(string, var)                             \
+	printf("\t%-41s : %.4f mW / %.2f dBm\n", (string),           \
+	       (double)((var) / 10000.),                             \
+	       convert_mw_to_dbm((double)((var) / 10000.)))
+
+#define PRINT_BIAS(string, bias_cur)                            \
+	printf("\t%-41s : %.3f mA\n", (string),                       \
+	       (double)(bias_cur / 500.))
+
+#define PRINT_TEMP(string, temp)                                    \
+	printf("\t%-41s : %.2f degrees C / %.2f degrees F\n", (string),   \
+	       (double)(temp / 256.), (double)(temp / 256. * 1.8 + 32.))
+
+
+#define PRINT_VCC(string, sfp_voltage)                               \
+	printf("\t%-41s : %.4f V\n", (string),                             \
+	       (double)(sfp_voltage / 10000.))
+
+#define PRINT_THRESH_BIAS(string, index)                              \
+	PRINT_BIAS(string, sd.thresh_bias_cur[(index)])
+
+# define PRINT_xX_THRESH_PWR(string, var, index)                       \
+	PRINT_xX_PWR(string, (var)[(index)])
+
+#define PRINT_THRESH_TEMP(string, index)                               \
+	PRINT_TEMP(string, sd.thresh_sfp_temp[(index)])
+
+#define PRINT_THRESH_VCC(string, index)                                 \
+	PRINT_VCC(string, sd.thresh_sfp_temp[(index)])
+
+	for (i = 0; i < MAX_CHANNEL_NUM; i++) {
+		snprintf(power_string, MAX_DESC_SIZE, "%s (Channel %d)",
+					"Laser bias current", i+1);
+		PRINT_BIAS(power_string, sd.scd[i].bias_cur);
+	}
+
+	if (!sd.rx_power_type)
+		rx_power_string = "Receiver signal OMA";
+	else
+		rx_power_string = "Rcvr signal avg optical power";
+
+	for (i = 0; i < MAX_CHANNEL_NUM; i++) {
+		snprintf(power_string, MAX_DESC_SIZE, "%s(Channel %d)",
+					rx_power_string, i+1);
+		PRINT_xX_PWR(power_string, sd.scd[i].rx_power);
+	}
+
+	PRINT_TEMP("Module temperature", sd.sfp_temp);
+	PRINT_VCC("Module voltage", sd.sfp_voltage);
+
+	printf("\t%-41s : %s\n", "Alarm/warning flags implemented",
+	       (!sd.supports_alarms ? "Yes" : "No"));
+	if (!sd.supports_alarms) {
+
+		for (i = 0; sff8436_aw_flags[i].str; ++i) {
+			printf("\t%-41s : %s\n", sff8436_aw_flags[i].str,
+			       id[sff8436_aw_flags[i].offset]
+			       & sff8436_aw_flags[i].value ? "On" : "Off");
+		}
+
+		PRINT_THRESH_BIAS("Laser bias current high alarm threshold",
+							HALRM);
+		PRINT_THRESH_BIAS("Laser bias current low alarm threshold",
+							LALRM);
+		PRINT_THRESH_BIAS("Laser bias current high warning threshold",
+							HWARN);
+		PRINT_THRESH_BIAS("Laser bias current low warning threshold",
+							LWARN);
+
+		PRINT_THRESH_TEMP("Module temperature high alarm threshold",
+							HALRM);
+		PRINT_THRESH_TEMP("Module temperature low alarm threshold",
+							LALRM);
+		PRINT_THRESH_TEMP("Module temperature high warning threshold",
+							HWARN);
+		PRINT_THRESH_TEMP("Module temperature low warning threshold",
+							LWARN);
+
+		PRINT_THRESH_VCC("Module voltage high alarm threshold",
+							HALRM);
+		PRINT_THRESH_VCC("Module voltage low alarm threshold",
+							LALRM);
+		PRINT_THRESH_VCC("Module voltage high warning threshold",
+							HWARN);
+		PRINT_THRESH_VCC("Module voltage low warning threshold",
+							LWARN);
+
+		PRINT_xX_THRESH_PWR("Laser rx power high alarm threshold",
+			     sd.thresh_rx_power, HALRM);
+		PRINT_xX_THRESH_PWR("Laser rx power low alarm threshold",
+			     sd.thresh_rx_power, LALRM);
+		PRINT_xX_THRESH_PWR("Laser rx power high warning threshold",
+			     sd.thresh_rx_power, HWARN);
+		PRINT_xX_THRESH_PWR("Laser rx power low warning threshold",
+			     sd.thresh_rx_power, LWARN);
+	}
+
+}
+void sff8436_show_all(const __u8 *id)
+{
+
+	sff8436_show_identifier(id);
+	if (id[SFF8436_ID_OFFSET] == 0x0d) {
+		sff8436_show_ext_identifier(id);
+		sff8436_show_connector(id);
+		sff8436_show_transceiver(id);
+		sff8436_show_encoding(id);
+		sff8436_show_value_with_unit(id, SFF8436_BR_NOMINAL_OFFSET,
+				"BR, Nominal", 100, "Mbps");
+		sff8436_show_rate_identifier(id);
+		sff8436_show_value_with_unit(id, SFF8436_SM_LEN_OFFSET,
+			     "Length (SMF,km)", 1, "km");
+		sff8436_show_value_with_unit(id, SFF8436_OM3_LEN_OFFSET,
+				"Length (OM3 50um)", 2, "m");
+		sff8436_show_value_with_unit(id, SFF8436_OM2_LEN_OFFSET,
+				"Length (OM2 50um)", 1, "m");
+		sff8436_show_value_with_unit(id, SFF8436_OM1_LEN_OFFSET,
+			     "Length (OM1 62.5um)", 1, "m");
+		sff8436_show_value_with_unit(id, SFF8436_CBL_LEN_OFFSET,
+			     "Length (Copper or Active cable)", 1, "m");
+		sff8436_show_wavelength_or_copper_compliance(id);
+		sff8436_show_ascii(id, SFF8436_VENDOR_NAME_START_OFFSET,
+			       SFF8436_VENDOR_NAME_END_OFFSET, "Vendor name");
+		sff8436_show_oui(id);
+		sff8436_show_ascii(id, SFF8436_VENDOR_PN_START_OFFSET,
+			       SFF8436_VENDOR_PN_END_OFFSET, "Vendor PN");
+		sff8436_show_ascii(id, SFF8436_VENDOR_REV_START_OFFSET,
+			       SFF8436_VENDOR_REV_END_OFFSET, "Vendor rev");
+		sff8436_show_ascii(id, SFF8436_VENDOR_SN_START_OFFSET,
+			       SFF8436_VENDOR_SN_END_OFFSET, "Vendor SN");
+		sff8436_show_dom(id);
+	}
+}
diff --git a/qsfp.h b/qsfp.h
new file mode 100644
index 0000000..28107fa
--- /dev/null
+++ b/qsfp.h
@@ -0,0 +1,541 @@
+/*
+ * SFF 8436 standards based QSFP EEPROM Field Definitions
+ *
+ * Vidya Ravipati <vidya@cumulusnetworks.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#ifndef QSFP_H__
+#define QSFP_H__
+
+
+/*------------------------------------------------------------------------------
+ *
+ * QSFP EEPROM data structures
+ *
+ * register info from SFF-8436 Rev 4.8
+ */
+
+/*------------------------------------------------------------------------------
+ *
+ * Lower Memory Page 00h
+ * Measurement, Diagnostic and Control Functions
+ *
+ */
+/* Identifier - 0 */
+#define	SFF8436_ID_OFFSET				0x00
+#define	 SFF8436_ID_UNKNOWN				0x00
+#define	 SFF8436_ID_GBIC				0x01
+#define	 SFF8436_ID_SOLDERED_MODULE		0x02
+#define	 SFF8436_ID_SFP					0x03
+#define	 SFF8436_ID_300_PIN_XBI			0x04
+#define	 SFF8436_ID_XENPAK				0x05
+#define	 SFF8436_ID_XFP					0x06
+#define	 SFF8436_ID_XFF					0x07
+#define	 SFF8436_ID_XFP_E				0x08
+#define	 SFF8436_ID_XPAK				0x09
+#define	 SFF8436_ID_X2					0x0A
+#define	 SFF8436_ID_DWDM_SFP			0x0B
+#define	 SFF8436_ID_DWDM_QSFP			0x0C
+#define	 SFF8436_ID_DWDM_QSFP_PLUS		0x0D
+
+#define	SFF8436_STATUS_1_OFFSET		0x01
+#define	SFF8436_STATUS_2_OFFSET		0x02
+/* Flat Memory:0- Paging, 1- Page 0 only */
+#define	 SFF8436_STATUS_PAGE_3_PRESENT		(1 << 2)
+#define	 SFF8436_STATUS_INTL_OUTPUT			(1 << 1)
+#define	 SFF8436_STATUS_DATA_NOT_READY		(1 << 0)
+
+/* Channel Status Interrupt Flags - 3-5 */
+#define	SFF8436_LOS_AW_OFFSET	0x03
+#define	 SFF8436_TX4_LOS_AW		(1 << 7)
+#define	 SFF8436_TX3_LOS_AW		(1 << 6)
+#define	 SFF8436_TX2_LOS_AW		(1 << 5)
+#define	 SFF8436_TX1_LOS_AW		(1 << 4)
+#define	 SFF8436_RX4_LOS_AW		(1 << 3)
+#define	 SFF8436_RX3_LOS_AW		(1 << 2)
+#define	 SFF8436_RX2_LOS_AW		(1 << 1)
+#define	 SFF8436_RX1_LOS_AW		(1 << 0)
+
+#define	SFF8436_FAULT_AW_OFFSET	0x04
+#define	 SFF8436_TX4_FAULT_AW	(1 << 3)
+#define	 SFF8436_TX3_FAULT_AW	(1 << 2)
+#define	 SFF8436_TX2_FAULT_AW	(1 << 1)
+#define	 SFF8436_TX1_FAULT_AW	(1 << 0)
+
+/* Module Monitor Interrupt Flags - 6-8 */
+#define	SFF8436_TEMP_AW_OFFSET	0x06
+#define	 SFF8436_TEMP_HALARM_STATUS		(1 << 7)
+#define	 SFF8436_TEMP_LALARM_STATUS		(1 << 6)
+#define	 SFF8436_TEMP_HWARN_STATUS		(1 << 5)
+#define	 SFF8436_TEMP_LWARN_STATUS		(1 << 4)
+
+#define	SFF8436_VCC_AW_OFFSET	0x07
+#define	 SFF8436_VCC_HALARM_STATUS		(1 << 7)
+#define	 SFF8436_VCC_LALARM_STATUS		(1 << 6)
+#define	 SFF8436_VCC_HWARN_STATUS		(1 << 5)
+#define	 SFF8436_VCC_LWARN_STATUS		(1 << 4)
+
+/* Channel Monitor Interrupt Flags - 9-21 */
+#define	SFF8436_RX_PWR_12_AW_OFFSET	0x09
+#define	 SFF8436_RX_PWR_1_HALARM		(1 << 7)
+#define	 SFF8436_RX_PWR_1_LALARM		(1 << 6)
+#define	 SFF8436_RX_PWR_1_HWARN			(1 << 5)
+#define	 SFF8436_RX_PWR_1_LWARN			(1 << 4)
+#define	 SFF8436_RX_PWR_2_HALARM		(1 << 3)
+#define	 SFF8436_RX_PWR_2_LALARM		(1 << 2)
+#define	 SFF8436_RX_PWR_2_HWARN			(1 << 1)
+#define	 SFF8436_RX_PWR_2_LWARN			(1 << 0)
+
+#define	SFF8436_RX_PWR_34_AW_OFFSET	0x0A
+#define	 SFF8436_RX_PWR_3_HALARM		(1 << 7)
+#define	 SFF8436_RX_PWR_3_LALARM		(1 << 6)
+#define	 SFF8436_RX_PWR_3_HWARN			(1 << 5)
+#define	 SFF8436_RX_PWR_3_LWARN			(1 << 4)
+#define	 SFF8436_RX_PWR_4_HALARM		(1 << 3)
+#define	 SFF8436_RX_PWR_4_LALARM		(1 << 2)
+#define	 SFF8436_RX_PWR_4_HWARN			(1 << 1)
+#define	 SFF8436_RX_PWR_4_LWARN			(1 << 0)
+
+#define	SFF8436_TX_BIAS_12_AW_OFFSET	0x0B
+#define	 SFF8436_TX_BIAS_1_HALARM		(1 << 7)
+#define	 SFF8436_TX_BIAS_1_LALARM		(1 << 6)
+#define	 SFF8436_TX_BIAS_1_HWARN		(1 << 5)
+#define	 SFF8436_TX_BIAS_1_LWARN		(1 << 4)
+#define	 SFF8436_TX_BIAS_2_HALARM		(1 << 3)
+#define	 SFF8436_TX_BIAS_2_LALARM		(1 << 2)
+#define	 SFF8436_TX_BIAS_2_HWARN		(1 << 1)
+#define	 SFF8436_TX_BIAS_2_LWARN		(1 << 0)
+
+#define	SFF8436_TX_BIAS_34_AW_OFFSET	0xC
+#define	 SFF8436_TX_BIAS_3_HALARM		(1 << 7)
+#define	 SFF8436_TX_BIAS_3_LALARM		(1 << 6)
+#define	 SFF8436_TX_BIAS_3_HWARN		(1 << 5)
+#define	 SFF8436_TX_BIAS_3_LWARN		(1 << 4)
+#define	 SFF8436_TX_BIAS_4_HALARM		(1 << 3)
+#define	 SFF8436_TX_BIAS_4_LALARM		(1 << 2)
+#define	 SFF8436_TX_BIAS_4_HWARN		(1 << 1)
+#define	 SFF8436_TX_BIAS_4_LWARN		(1 << 0)
+
+/* Module Monitoring Values - 22-33 */
+#define	SFF8436_TEMP_CURR			0x16
+#define	SFF8436_TEMP_MSB_OFFSET		0x16
+#define	SFF8436_TEMP_LSB_OFFSET		0x17
+
+#define	SFF8436_VCC_CURR			0x1A
+#define	SFF8436_VCC_MSB_OFFSET		0x1A
+#define	SFF8436_VCC_LSB_OFFSET		0x1B
+
+/* Channel Monitoring Values - 34-81 */
+#define	SFF8436_RX_PWR_1_OFFSET		0x22
+#define	SFF8436_RX_PWR_2_OFFSET		0x24
+#define	SFF8436_RX_PWR_3_OFFSET		0x26
+#define	SFF8436_RX_PWR_4_OFFSET		0x28
+
+#define	SFF8436_TX_BIAS_1_OFFSET	0x2A
+#define	SFF8436_TX_BIAS_2_OFFSET	0x2C
+#define	SFF8436_TX_BIAS_3_OFFSET	0x2E
+#define	SFF8436_TX_BIAS_4_OFFSET	0x30
+
+/* Control Bytes - 86 - 99 */
+#define	SFF8436_TX_DISABLE_OFFSET	0x56
+#define	 SFF8436_TX_DISABLE_4			(1 << 3)
+#define	 SFF8436_TX_DISABLE_3			(1 << 2)
+#define	 SFF8436_TX_DISABLE_2			(1 << 1)
+#define	 SFF8436_TX_DISABLE_1			(1 << 0)
+
+#define	SFF8436_RX_RATE_SELECT_OFFSET	0x57
+#define	 SFF8436_RX_RATE_SELECT_4_MASK		(3 << 6)
+#define	 SFF8436_RX_RATE_SELECT_3_MASK		(3 << 4)
+#define	 SFF8436_RX_RATE_SELECT_2_MASK		(3 << 2)
+#define	 SFF8436_RX_RATE_SELECT_1_MASK		(3 << 0)
+
+#define	SFF8436_TX_RATE_SELECT_OFFSET	0x58
+#define	 SFF8436_TX_RATE_SELECT_4_MASK		(3 << 6)
+#define	 SFF8436_TX_RATE_SELECT_3_MASK		(3 << 4)
+#define	 SFF8436_TX_RATE_SELECT_2_MASK		(3 << 2)
+#define	 SFF8436_TX_RATE_SELECT_1_MASK		(3 << 0)
+
+#define	SFF8436_RX_APP_SELECT_4_OFFSET	0x58
+#define	SFF8436_RX_APP_SELECT_3_OFFSET	0x59
+#define	SFF8436_RX_APP_SELECT_2_OFFSET	0x5A
+#define	SFF8436_RX_APP_SELECT_1_OFFSET	0x5B
+
+#define	SFF8436_PWR_MODE_OFFSET		0x5D
+#define	 SFF8436_LOW_PWR_MODE			(1 << 1)
+#define	 SFF8436_PWR_OVERRIDE			(1 << 0)
+
+#define	SFF8436_TX_APP_SELECT_4_OFFSET	0x5E
+#define	SFF8436_TX_APP_SELECT_3_OFFSET	0x5F
+#define	SFF8436_TX_APP_SELECT_2_OFFSET	0x60
+#define	SFF8436_TX_APP_SELECT_1_OFFSET	0x61
+
+#define	SFF8436_LOS_MASK_OFFSET		0x64
+#define	 SFF8436_TX_LOS_4_MASK			(1 << 7)
+#define	 SFF8436_TX_LOS_3_MASK			(1 << 6)
+#define	 SFF8436_TX_LOS_2_MASK			(1 << 5)
+#define	 SFF8436_TX_LOS_1_MASK			(1 << 4)
+#define	 SFF8436_RX_LOS_4_MASK			(1 << 3)
+#define	 SFF8436_RX_LOS_3_MASK			(1 << 2)
+#define	 SFF8436_RX_LOS_2_MASK			(1 << 1)
+#define	 SFF8436_RX_LOS_1_MASK			(1 << 0)
+
+#define	SFF8436_FAULT_MASK_OFFSET	0x65
+#define	 SFF8436_TX_FAULT_1_MASK		(1 << 3)
+#define	 SFF8436_TX_FAULT_2_MASK		(1 << 2)
+#define	 SFF8436_TX_FAULT_3_MASK		(1 << 1)
+#define	 SFF8436_TX_FAULT_4_MASK		(1 << 0)
+
+#define	SFF8436_TEMP_MASK_OFFSET	0x67
+#define	 SFF8436_TEMP_HALARM_MASK		(1 << 7)
+#define	 SFF8436_TEMP_LALARM_MASK		(1 << 6)
+#define	 SFF8436_TEMP_HWARN_MASK		(1 << 5)
+#define	 SFF8436_TEMP_LWARN_MASK		(1 << 4)
+
+#define	SFF8436_VCC_MASK_OFFSET		0x68
+#define	 SFF8436_VCC_HALARM_MASK		(1 << 7)
+#define	 SFF8436_VCC_LALARM_MASK		(1 << 6)
+#define	 SFF8436_VCC_HWARN_MASK			(1 << 5)
+#define	 SFF8436_VCC_LWARN_MASK			(1 << 4)
+
+/*------------------------------------------------------------------------------
+ *
+ * Upper Memory Page 00h
+ * Serial ID - Base ID, Extended ID and Vendor Specific ID fields
+ *
+ */
+/* Identifier - 128 */
+/* Identifier values same as Lower Memory Page 00h */
+#define	SFF8436_UPPER_PAGE_0_ID_OFFSET		0x80
+
+/* Extended Identifier - 128 */
+#define SFF8436_EXT_ID_OFFSET		0x81
+#define	 SFF8436_EXT_ID_PWR_CLASS_MASK		0xC0
+#define	  SFF8436_EXT_ID_PWR_CLASS_1		(0 << 6)
+#define	  SFF8436_EXT_ID_PWR_CLASS_2		(1 << 6)
+#define	  SFF8436_EXT_ID_PWR_CLASS_3		(2 << 6)
+#define	  SFF8436_EXT_ID_PWR_CLASS_4		(3 << 6)
+#define	 SFF8436_EXT_ID_CLIE_MASK		    0x10
+#define	  SFF8436_EXT_ID_CLIEI_CODE_PRESENT	(1 << 4)
+#define	 SFF8436_EXT_ID_CDR_TX_MASK			0x08
+#define	  SFF8436_EXT_ID_CDR_TX_PRESENT		(1 << 3)
+#define	 SFF8436_EXT_ID_CDR_RX_MASK			0x04
+#define	  SFF8436_EXT_ID_CDR_RX_PRESENT		(1 << 2)
+
+/* Connector Values offset - 130 */
+#define	SFF8436_CTOR_OFFSET		0x82
+#define	 SFF8436_CTOR_UNKNOWN			0x00
+#define	 SFF8436_CTOR_SC				0x01
+#define	 SFF8436_CTOR_FC_STYLE_1		0x02
+#define	 SFF8436_CTOR_FC_STYLE_2		0x03
+#define	 SFF8436_CTOR_BNC_TNC			0x04
+#define	 SFF8436_CTOR_FC_COAX			0x05
+#define	 SFF8436_CTOR_FIBER_JACK		0x06
+#define	 SFF8436_CTOR_LC				0x07
+#define	 SFF8436_CTOR_MT_RJ				0x08
+#define	 SFF8436_CTOR_MU				0x09
+#define	 SFF8436_CTOR_SG				0x0A
+#define	 SFF8436_CTOR_OPT_PT			0x0B
+#define	 SFF8436_CTOR_MPO				0x0C
+/* 0D-1Fh --- Reserved */
+#define	 SFF8436_CTOR_HSDC_II			0x20
+#define	 SFF8436_CTOR_COPPER_PT			0x21
+#define	 SFF8436_CTOR_RJ45				0x22
+#define	 SFF8436_CTOR_NO_SEPARABLE		0x23
+
+/* Specification Compliance - 131-138 */
+/* Ethernet Compliance Codes - 131 */
+#define	SFF8436_ETHERNET_COMP_OFFSET	0x83
+#define	 SFF8436_ETHERNET_RSRVD			(1 << 7)
+#define	 SFF8436_ETHERNET_10G_LRM		(1 << 6)
+#define	 SFF8436_ETHERNET_10G_LR		(1 << 5)
+#define	 SFF8436_ETHERNET_10G_SR		(1 << 4)
+#define	 SFF8436_ETHERNET_40G_CR4		(1 << 3)
+#define	 SFF8436_ETHERNET_40G_SR4		(1 << 2)
+#define	 SFF8436_ETHERNET_40G_LR4		(1 << 1)
+#define	 SFF8436_ETHERNET_40G_ACTIVE	(1 << 0)
+
+/* SONET Compliance Codes - 132 */
+#define	SFF8436_SONET_COMP_OFFSET	0x84
+#define	 SFF8436_SONET_40G_OTN			(1 << 3)
+#define	 SFF8436_SONET_OC48_LR			(1 << 2)
+#define	 SFF8436_SONET_OC48_IR			(1 << 1)
+#define	 SFF8436_SONET_OC48_SR			(1 << 0)
+
+/* SAS/SATA Complaince Codes - 133 */
+#define	SFF8436_SAS_COMP_OFFSET		0x85
+#define	 SFF8436_SAS_6G				    (1 << 5)
+#define	 SFF8436_SAS_3G				    (1 << 4)
+
+/* Gigabit Ethernet Compliance Codes - 134 */
+#define	SFF8436_GIGE_COMP_OFFSET	0x86
+#define	 SFF8436_GIGE_1000_BASE_T		(1 << 3)
+#define	 SFF8436_GIGE_1000_BASE_CX		(1 << 2)
+#define	 SFF8436_GIGE_1000_BASE_LX		(1 << 1)
+#define	 SFF8436_GIGE_1000_BASE_SX		(1 << 0)
+
+
+/* Fibre Channel Link length/Transmitter Tech. - 135,136 */
+#define	SFF8436_FC_LEN_OFFSET		0x87
+#define	 SFF8436_FC_LEN_VERY_LONG		(1 << 7)
+#define	 SFF8436_FC_LEN_SHORT			(1 << 6)
+#define	 SFF8436_FC_LEN_INT				(1 << 5)
+#define	 SFF8436_FC_LEN_LONG			(1 << 4)
+#define	 SFF8436_FC_LEN_MED				(1 << 3)
+#define	 SFF8436_FC_TECH_LONG_LC		(1 << 1)
+#define	 SFF8436_FC_TECH_ELEC_INTER		(1 << 0)
+
+#define	SFF8436_FC_TECH_OFFSET		0x88
+#define	 SFF8436_FC_TECH_ELEC_INTRA			(1 << 7)
+#define	 SFF8436_FC_TECH_SHORT_WO_OFC		(1 << 6)
+#define	 SFF8436_FC_TECH_SHORT_W_OFC		(1 << 5)
+#define	 SFF8436_FC_TECH_LONG_LL			(1 << 4)
+
+
+/* Fibre Channel Transmitter Media - 137 */
+#define	SFF8436_FC_TRANS_MEDIA_OFFSET	0x89
+/* Twin Axial Pair */
+#define	 SFF8436_FC_TRANS_MEDIA_TW		(1 << 7)
+/* Shielded Twisted Pair */
+#define	 SFF8436_FC_TRANS_MEDIA_TP		(1 << 6)
+/* Miniature Coax */
+#define	 SFF8436_FC_TRANS_MEDIA_MI		(1 << 5)
+/* Video Coax */
+#define	 SFF8436_FC_TRANS_MEDIA_TV		(1 << 4)
+/* Multi-mode 62.5m */
+#define	 SFF8436_FC_TRANS_MEDIA_M6		(1 << 3)
+/* Multi-mode 50m */
+#define	 SFF8436_FC_TRANS_MEDIA_M5		(1 << 2)
+/* Multi-mode 50um */
+#define	 SFF8436_FC_TRANS_MEDIA_OM3		(1 << 1)
+/* Single Mode */
+#define	 SFF8436_FC_TRANS_MEDIA_SM		(1 << 0)
+
+/* Fibre Channel Speed - 138 */
+#define	SFF8436_FC_SPEED_OFFSET		0x8A
+#define	 SFF8436_FC_SPEED_1200_MBPS		(1 << 7)
+#define	 SFF8436_FC_SPEED_800_MBPS		(1 << 6)
+#define	 SFF8436_FC_SPEED_1600_MBPS		(1 << 5)
+#define	 SFF8436_FC_SPEED_400_MBPS		(1 << 4)
+#define	 SFF8436_FC_SPEED_200_MBPS		(1 << 2)
+#define	 SFF8436_FC_SPEED_100_MBPS		(1 << 0)
+
+/* Encoding - 139 */
+#define	SFF8436_ENCODING_OFFSET		0x8B
+#define	 SFF8436_ENCODING_MANCHESTER	0x06
+#define	 SFF8436_ENCODING_64B66B		0x05
+#define	 SFF8436_ENCODING_SONET			0x04
+#define	 SFF8436_ENCODING_NRZ			0x03
+#define	 SFF8436_ENCODING_4B5B			0x02
+#define	 SFF8436_ENCODING_8B10B			0x01
+#define	 SFF8436_ENCODING_UNSPEC		0x00
+
+/* BR, Nominal - 140 */
+#define	SFF8436_BR_NOMINAL_OFFSET	0x8C
+
+/* Extended RateSelect - 141 */
+#define	SFF8436_EXT_RS_OFFSET		0x8D
+#define	 SFF8436_EXT_RS_V1			(1 << 0)
+
+/* Length (Standard SM Fiber)-km - 142 */
+#define	SFF8436_SM_LEN_OFFSET		0x8E
+
+/* Length (OM3)-Unit 2m - 143 */
+#define	SFF8436_OM3_LEN_OFFSET		0x8F
+
+/* Length (OM2)-Unit 1m - 144 */
+#define	SFF8436_OM2_LEN_OFFSET		0x90
+
+/* Length (OM1)-Unit 1m - 145 */
+#define	SFF8436_OM1_LEN_OFFSET		0x91
+
+/* Cable Assembly Length -Unit 1m - 146 */
+#define	SFF8436_CBL_LEN_OFFSET		0x92
+
+/* Device Technology - 147 */
+#define	SFF8436_DEVICE_TECH_OFFSET	0x93
+/* Transmitter Technology */
+#define	 SFF8436_TRANS_TECH_MASK			0xF0
+/* Copper cable, linear active equalizers */
+#define	 SFF8436_TRANS_COPPER_LNR_EQUAL		(15 << 4)
+/* Copper cable, near end limiting active equalizers */
+#define	 SFF8436_TRANS_COPPER_NEAR_EQUAL	(14 << 4)
+/* Copper cable, far end limiting active equalizers */
+#define	 SFF8436_TRANS_COPPER_FAR_EQUAL		(13 << 4)
+/* Copper cable, near & far end limiting active equalizers */
+#define	 SFF8436_TRANS_COPPER_LNR_FAR_EQUAL	(12 << 4)
+/* Copper cable, passive equalized */
+#define	 SFF8436_TRANS_COPPER_PAS_EQUAL		(11 << 4)
+/* Copper cable, unequalized */
+#define	 SFF8436_TRANS_COPPER_PAS_UNEQUAL	(10 << 4)
+/* 1490 nm DFB */
+#define	 SFF8436_TRANS_1490_DFB				(9 << 4)
+/* Others */
+#define	 SFF8436_TRANS_OTHERS				(8 << 4)
+/* 1550 nm EML */
+#define	 SFF8436_TRANS_1550_EML				(7 << 4)
+/* 1310 nm EML */
+#define	 SFF8436_TRANS_1310_EML				(6 << 4)
+/* 1550 nm DFB */
+#define	 SFF8436_TRANS_1550_DFB				(5 << 4)
+/* 1310 nm DFB */
+#define	 SFF8436_TRANS_1310_DFB				(4 << 4)
+/* 1310 nm FP */
+#define	 SFF8436_TRANS_1310_FP				(3 << 4)
+/* 1550 nm VCSEL */
+#define	 SFF8436_TRANS_1550_VCSEL			(2 << 4)
+/* 1310 nm VCSEL */
+#define	 SFF8436_TRANS_1310_VCSEL			(1 << 4)
+/* 850 nm VCSEL */
+#define	 SFF8436_TRANS_850_VCSEL			(0 << 4)
+
+ /* Active/No wavelength control */
+#define	 SFF8436_DEV_TECH_ACTIVE_WAVE_LEN	(1 << 3)
+/* Cooled transmitter */
+#define	 SFF8436_DEV_TECH_COOL_TRANS		(1 << 2)
+/* APD/Pin Detector */
+#define	 SFF8436_DEV_TECH_APD_DETECTOR		(1 << 1)
+/* Transmitter tunable */
+#define	 SFF8436_DEV_TECH_TUNABLE			(1 << 0)
+
+/* Vendor Name - 148-163 */
+#define	 SFF8436_VENDOR_NAME_START_OFFSET	0x94
+#define	 SFF8436_VENDOR_NAME_END_OFFSET		0xA3
+
+/* Extended Module Codes - 164 */
+#define	 SFF8436_EXT_MOD_CODE_OFFSET	0xA4
+#define	  SFF8436_EXT_MOD_INFINIBAND_EDR	(1 << 4)
+#define	  SFF8436_EXT_MOD_INFINIBAND_FDR	(1 << 3)
+#define	  SFF8436_EXT_MOD_INFINIBAND_QDR	(1 << 2)
+#define	  SFF8436_EXT_MOD_INFINIBAND_DDR	(1 << 1)
+#define	  SFF8436_EXT_MOD_INFINIBAND_SDR	(1 << 0)
+
+/* Vendor OUI - 165-167 */
+#define	 SFF8436_VENDOR_OUI_OFFSET			0xA5
+#define	  SFF8436_VENDOR_OUI_LEN			3
+
+/* Vendor OUI - 165-167 */
+#define	 SFF8436_VENDOR_PN_START_OFFSET		0xA8
+#define	 SFF8436_VENDOR_PN_END_OFFSET		0xB7
+
+/* Vendor Revision - 184-185 */
+#define	 SFF8436_VENDOR_REV_START_OFFSET	0xB8
+#define	 SFF8436_VENDOR_REV_END_OFFSET	0xB8
+
+/* Wavelength - 186-187 */
+#define	 SFF8436_WAVELEN_HIGH_BYTE_OFFSET	0xBA
+#define	 SFF8436_WAVELEN_LOW_BYTE_OFFSET	0xBB
+
+/* Wavelength  Tolerance- 188-189 */
+#define	 SFF8436_WAVE_TOL_HIGH_BYTE_OFFSET	0xBC
+#define	 SFF8436_WAVE_TOL_LOW_BYTE_OFFSET	0xBD
+
+/* Max case temp - Other than 70 C - 190 */
+#define	 SFF8436_MAXCASE_TEMP_OFFSET	0xBE
+
+/* CC_BASE - 191 */
+#define	 SFF8436_CC_BASE_OFFSET		0xBF
+
+/* Option Values - 192-195 */
+#define	 SFF8436_OPTION_1_OFFSET	0xC0
+#define	 SFF8436_OPTION_2_OFFSET	0xC1
+/* Rx output amplitude */
+#define	  SFF8436_O2_RX_OUTPUT_AMP		(1 << 0)
+#define	 SFF8436_OPTION_3_OFFSET	0xC2
+/* Rx Squelch Disable */
+#define	  SFF8436_O3_RX_SQL_DSBL		(1 << 3)
+/* Rx Output Disable capable */
+#define	  SFF8436_O3_RX_OUTPUT_DSBL		(1 << 2)
+/* Tx Squelch Disable */
+#define	  SFF8436_O3_TX_SQL_DSBL		(1 << 1)
+/* Tx Squelch Impl */
+#define	  SFF8436_O3_TX_SQL_IMPL		(1 << 0)
+#define	 SFF8436_OPTION_4_OFFSET	0xC3
+/* Memory Page 02 present */
+#define	  SFF8436_O4_PAGE_02_PRESENT	(1 << 7)
+/* Memory Page 01 present */
+#define	  SFF8436_O4_PAGE_01_PRESENT	(1 << 6)
+/* Rate Select implemented */
+#define	  SFF8436_O4_RATE_SELECT		(1 << 5)
+/* Tx_DISABLE implemented */
+#define	  SFF8436_O4_TX_DISABLE			(1 << 4)
+/* Tx_FAULT implemented */
+#define	  SFF8436_O4_TX_FAULT			(1 << 3)
+/* Tx Squelch implemented */
+#define	  SFF8436_O4_TX_SQUELCH			(1 << 2)
+/* Tx Loss of Signal */
+#define	  SFF8436_O4_TX_LOS			    (1 << 1)
+
+/* Vendor SN - 196-211 */
+#define	 SFF8436_VENDOR_SN_START_OFFSET	0xC4
+#define	 SFF8436_VENDOR_SN_END_OFFSET	0xD3
+
+/* Vendor Date - 212-219 */
+#define	 SFF8436_DATE_YEAR_OFFSET	0xD4
+#define	  SFF8436_DATE_YEAR_LEN			2
+#define	 SFF8436_DATE_MONTH_OFFSET	0xD6
+#define	  SFF8436_DATE_MONTH_LEN		2
+#define	 SFF8436_DATE_DAY_OFFSET	0xD8
+#define	  SFF8436_DATE_DAY_LEN			2
+
+/* Diagnostic Monitoring Type - 220 */
+#define	 SFF8436_DIAG_TYPE_OFFSET	0xDC
+#define	  SFF8436_RX_PWR_TYPE_MASK		0x8
+#define	   SFF8436_RX_PWR_TYPE_AVG_PWR	(1 << 3)
+#define	   SFF8436_RX_PWR_TYPE_OMA		(0 << 3)
+
+/* Enhanced Options - 221 */
+#define	 SFF8436_ENH_OPTIONS_OFFSET	0xDD
+#define	  SFF8436_RATE_SELECT_EXT_SUPPORT		(1 << 3)
+#define	  SFF8436_RATE_SELECT_APP_TABLE_SUPPORT	(1 << 2)
+
+/* Check code - 223 */
+#define	 SFF8436_CC_EXT_OFFSET		0xDF
+#define	  SFF8436_CC_EXT_LEN			1
+
+
+/*------------------------------------------------------------------------------
+ *
+ * Upper Memory Page 03h
+ * Contains module thresholds, channel thresholds and masks,
+ * and optional channel controls
+ *
+ * Offset - Page Num(3) * PageSize(0x80) + Page offset
+ */
+
+/* Module Thresholds (48 Bytes) 128-175 */
+/* MSB at low address, LSB at high address */
+#define	SFF8436_TEMP_HALRM			0x200
+#define	SFF8436_TEMP_LALRM			0x202
+#define	SFF8436_TEMP_HWARN			0x204
+#define	SFF8436_TEMP_LWARN			0x206
+
+#define	SFF8436_VCC_HALRM			0x210
+#define	SFF8436_VCC_LALRM			0x212
+#define	SFF8436_VCC_HWARN			0x214
+#define	SFF8436_VCC_LWARN			0x216
+
+#define	SFF8436_RX_PWR_HALRM		0x230
+#define	SFF8436_RX_PWR_LALRM		0x232
+#define	SFF8436_RX_PWR_HWARN		0x234
+#define	SFF8436_RX_PWR_LWARN		0x236
+
+#define	SFF8436_TX_BIAS_HALRM		0x238
+#define	SFF8436_TX_BIAS_LALRM		0x23A
+#define	SFF8436_TX_BIAS_HWARN		0x23C
+#define	SFF8436_TX_BIAS_LWARN		0x23E
+
+#endif /* QSFP_H__ */
-- 
1.7.10.4

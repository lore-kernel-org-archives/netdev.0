From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [ethtool PATCH v3 2/4] ethtool:Reorganizing  SFF-8024 fields for SFP/QSFP
Date: Sun, 21 Aug 2016 16:44:02 -0700
Message-ID: <1471823044-5165-3-git-send-email-vidya@cumulusnetworks.com>
Cc: bkenward@solarflare.com, daniel@iogearbox.net, galp@mellanox.com,
        roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
        dustin@cumulusnetworks.com, ben@decadent.org.uk
To: linville@tuxdriver.com, netdev@vger.kernel.org,
        davem@davemloft.net, decot@googlers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33542 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753164AbcHUXoM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2016 19:44:12 -0400
Received: by mail-pa0-f49.google.com with SMTP id ti13so31582036pac.0
        for <netdev@vger.kernel.org>; Sun, 21 Aug 2016 16:44:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

This patch provides following support
a) Reorganized fields based out of SFF-8024 fields i.e. Identifier/
   Encoding/Connector types which are common across SFP/SFP+ (SFF-8472)
   and QSFP+/QSFP28 (SFF-8436/SFF-8636) modules into sff-common files.
b) Moving the common functions for SFP+ and QSFP+ DOM into sff-common
   files

Standards for SFF-8024
a) SFF-8024 Rev 4.0 dated May 31, 2016

Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Acked-by: Bert Kenward <bkenward@solarflare.com>
---
 sff-common.c | 304 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 sff-common.h | 189 +++++++++++++++++++++++++++++++++++++
 sfpdiag.c    | 105 +++------------------
 sfpid.c      | 103 +-------------------
 4 files changed, 509 insertions(+), 192 deletions(-)
 create mode 100644 sff-common.c
 create mode 100644 sff-common.h

diff --git a/sff-common.c b/sff-common.c
new file mode 100644
index 0000000..7700cbe
--- /dev/null
+++ b/sff-common.c
@@ -0,0 +1,304 @@
+/*
+ * sff-common.c: Implements SFF-8024 Rev 4.0 i.e. Specifcation
+ * of pluggable I/O configuration
+ *
+ * Common utilities across SFF-8436/8636 and SFF-8472/8079
+ * are defined in this file
+ *
+ * Copyright 2010 Solarflare Communications Inc.
+ * Aurelien Guillaume <aurelien@iwi.me> (C) 2012
+ * Copyright (C) 2014 Cumulus networks Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Freeoftware Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ *  Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
+ *   This implementation is loosely based on current SFP parser
+ *   and SFF-8024 Rev 4.0 spec (ftp://ftp.seagate.com/pub/sff/SFF-8024.PDF)
+ *   by SFF Committee.
+ */
+
+#include <stdio.h>
+#include <math.h>
+#include "sff-common.h"
+
+double convert_mw_to_dbm(double mw)
+{
+	return (10. * log10(mw / 1000.)) + 30.;
+}
+
+void sff_show_value_with_unit(const __u8 *id, unsigned int reg,
+			      const char *name, unsigned int mult,
+			      const char *unit)
+{
+	unsigned int val = id[reg];
+
+	printf("\t%-41s : %u%s\n", name, val * mult, unit);
+}
+
+void sff_show_ascii(const __u8 *id, unsigned int first_reg,
+		    unsigned int last_reg, const char *name)
+{
+	unsigned int reg, val;
+
+	printf("\t%-41s : ", name);
+	while (first_reg <= last_reg && id[last_reg] == ' ')
+		last_reg--;
+	for (reg = first_reg; reg <= last_reg; reg++) {
+		val = id[reg];
+		putchar(((val >= 32) && (val <= 126)) ? val : '_');
+	}
+	printf("\n");
+}
+
+void sff8024_show_oui(const __u8 *id, int id_offset)
+{
+	printf("\t%-41s : %02x:%02x:%02x\n", "Vendor OUI",
+		      id[id_offset], id[(id_offset) + 1],
+		      id[(id_offset) + 2]);
+}
+
+void sff8024_show_identifier(const __u8 *id, int id_offset)
+{
+	printf("\t%-41s : 0x%02x", "Identifier", id[id_offset]);
+	switch (id[id_offset]) {
+	case SFF8024_ID_UNKNOWN:
+		printf(" (no module present, unknown, or unspecified)\n");
+		break;
+	case SFF8024_ID_GBIC:
+		printf(" (GBIC)\n");
+		break;
+	case SFF8024_ID_SOLDERED_MODULE:
+		printf(" (module soldered to motherboard)\n");
+		break;
+	case SFF8024_ID_SFP:
+		printf(" (SFP)\n");
+		break;
+	case SFF8024_ID_300_PIN_XBI:
+		printf(" (300 pin XBI)\n");
+		break;
+	case SFF8024_ID_XENPAK:
+		printf(" (XENPAK)\n");
+		break;
+	case SFF8024_ID_XFP:
+		printf(" (XFP)\n");
+		break;
+	case SFF8024_ID_XFF:
+		printf(" (XFF)\n");
+		break;
+	case SFF8024_ID_XFP_E:
+		printf(" (XFP-E)\n");
+		break;
+	case SFF8024_ID_XPAK:
+		printf(" (XPAK)\n");
+		break;
+	case SFF8024_ID_X2:
+		printf(" (X2)\n");
+		break;
+	case SFF8024_ID_DWDM_SFP:
+		printf(" (DWDM-SFP)\n");
+		break;
+	case SFF8024_ID_QSFP:
+		printf(" (QSFP)\n");
+		break;
+	case SFF8024_ID_QSFP_PLUS:
+		printf(" (QSFP+)\n");
+		break;
+	case SFF8024_ID_CXP:
+		printf(" (CXP)\n");
+		break;
+	case SFF8024_ID_HD4X:
+		printf(" (Shielded Mini Multilane HD 4X)\n");
+		break;
+	case SFF8024_ID_HD8X:
+		printf(" (Shielded Mini Multilane HD 8X)\n");
+		break;
+	case SFF8024_ID_QSFP28:
+		printf(" (QSFP28)\n");
+		break;
+	case SFF8024_ID_CXP2:
+		printf(" (CXP2/CXP28)\n");
+		break;
+	case SFF8024_ID_CDFP:
+		printf(" (CDFP Style 1/Style 2)\n");
+		break;
+	case SFF8024_ID_HD4X_FANOUT:
+		printf(" (Shielded Mini Multilane HD 4X Fanout Cable)\n");
+		break;
+	case SFF8024_ID_HD8X_FANOUT:
+		printf(" (Shielded Mini Multilane HD 8X Fanout Cable)\n");
+		break;
+	case SFF8024_ID_CDFP_S3:
+		printf(" (CDFP Style 3)\n");
+		break;
+	case SFF8024_ID_MICRO_QSFP:
+		printf(" (microQSFP)\n");
+		break;
+	default:
+		printf(" (reserved or unknown)\n");
+		break;
+	}
+}
+
+void sff8024_show_connector(const __u8 *id, int ctor_offset)
+{
+	printf("\t%-41s : 0x%02x", "Connector", id[ctor_offset]);
+	switch (id[ctor_offset]) {
+	case  SFF8024_CTOR_UNKNOWN:
+		printf(" (unknown or unspecified)\n");
+		break;
+	case SFF8024_CTOR_SC:
+		printf(" (SC)\n");
+		break;
+	case SFF8024_CTOR_FC_STYLE_1:
+		printf(" (Fibre Channel Style 1 copper)\n");
+		break;
+	case SFF8024_CTOR_FC_STYLE_2:
+		printf(" (Fibre Channel Style 2 copper)\n");
+		break;
+	case SFF8024_CTOR_BNC_TNC:
+		printf(" (BNC/TNC)\n");
+		break;
+	case SFF8024_CTOR_FC_COAX:
+		printf(" (Fibre Channel coaxial headers)\n");
+		break;
+	case SFF8024_CTOR_FIBER_JACK:
+		printf(" (FibreJack)\n");
+		break;
+	case SFF8024_CTOR_LC:
+		printf(" (LC)\n");
+		break;
+	case SFF8024_CTOR_MT_RJ:
+		printf(" (MT-RJ)\n");
+		break;
+	case SFF8024_CTOR_MU:
+		printf(" (MU)\n");
+		break;
+	case SFF8024_CTOR_SG:
+		printf(" (SG)\n");
+		break;
+	case SFF8024_CTOR_OPT_PT:
+		printf(" (Optical pigtail)\n");
+		break;
+	case SFF8024_CTOR_MPO:
+		printf(" (MPO Parallel Optic)\n");
+		break;
+	case SFF8024_CTOR_MPO_2:
+		printf(" (MPO Parallel Optic - 2x16)\n");
+		break;
+	case SFF8024_CTOR_HSDC_II:
+		printf(" (HSSDC II)\n");
+		break;
+	case SFF8024_CTOR_COPPER_PT:
+		printf(" (Copper pigtail)\n");
+		break;
+	case SFF8024_CTOR_RJ45:
+		printf(" (RJ45)\n");
+		break;
+	case SFF8024_CTOR_NO_SEPARABLE:
+		printf(" (No separable connector)\n");
+		break;
+	case SFF8024_CTOR_MXC_2x16:
+		printf(" (MXC 2x16)\n");
+		break;
+	default:
+		printf(" (reserved or unknown)\n");
+		break;
+	}
+}
+
+void sff8024_show_encoding(const __u8 *id, int encoding_offset, int sff_type)
+{
+	printf("\t%-41s : 0x%02x", "Encoding", id[encoding_offset]);
+	switch (id[encoding_offset]) {
+	case SFF8024_ENCODING_UNSPEC:
+		printf(" (unspecified)\n");
+		break;
+	case SFF8024_ENCODING_8B10B:
+		printf(" (8B/10B)\n");
+		break;
+	case SFF8024_ENCODING_4B5B:
+		printf(" (4B/5B)\n");
+		break;
+	case SFF8024_ENCODING_NRZ:
+		printf(" (NRZ)\n");
+		break;
+	case SFF8024_ENCODING_4h:
+		if (sff_type == ETH_MODULE_SFF_8472)
+			printf(" (Manchester)\n");
+		else if (sff_type == ETH_MODULE_SFF_8636)
+			printf(" (SONET Scrambled)\n");
+		break;
+	case SFF8024_ENCODING_5h:
+		if (sff_type == ETH_MODULE_SFF_8472)
+			printf(" (SONET Scrambled)\n");
+		else if (sff_type == ETH_MODULE_SFF_8636)
+			printf(" (64B/66B)\n");
+		break;
+	case SFF8024_ENCODING_6h:
+		if (sff_type == ETH_MODULE_SFF_8472)
+			printf(" (64B/66B)\n");
+		else if (sff_type == ETH_MODULE_SFF_8636)
+			printf(" (Manchester)\n");
+		break;
+	case SFF8024_ENCODING_256B:
+		printf(" ((256B/257B (transcoded FEC-enabled data))\n");
+		break;
+	case SFF8024_ENCODING_PAM4:
+		printf(" (PAM4)\n");
+		break;
+	default:
+		printf(" (reserved or unknown)\n");
+		break;
+	}
+}
+
+void sff_show_thresholds(struct sff_diags sd)
+{
+	PRINT_BIAS("Laser bias current high alarm threshold",
+		   sd.bias_cur[HALRM]);
+	PRINT_BIAS("Laser bias current low alarm threshold",
+		   sd.bias_cur[LALRM]);
+	PRINT_BIAS("Laser bias current high warning threshold",
+		   sd.bias_cur[HWARN]);
+	PRINT_BIAS("Laser bias current low warning threshold",
+		   sd.bias_cur[LWARN]);
+
+	PRINT_xX_PWR("Laser output power high alarm threshold",
+		     sd.tx_power[HALRM]);
+	PRINT_xX_PWR("Laser output power low alarm threshold",
+		     sd.tx_power[LALRM]);
+	PRINT_xX_PWR("Laser output power high warning threshold",
+		     sd.tx_power[HWARN]);
+	PRINT_xX_PWR("Laser output power low warning threshold",
+		     sd.tx_power[LWARN]);
+
+	PRINT_TEMP("Module temperature high alarm threshold",
+		   sd.sfp_temp[HALRM]);
+	PRINT_TEMP("Module temperature low alarm threshold",
+		   sd.sfp_temp[LALRM]);
+	PRINT_TEMP("Module temperature high warning threshold",
+		   sd.sfp_temp[HWARN]);
+	PRINT_TEMP("Module temperature low warning threshold",
+		   sd.sfp_temp[LWARN]);
+
+	PRINT_VCC("Module voltage high alarm threshold",
+		  sd.sfp_voltage[HALRM]);
+	PRINT_VCC("Module voltage low alarm threshold",
+		  sd.sfp_voltage[LALRM]);
+	PRINT_VCC("Module voltage high warning threshold",
+		  sd.sfp_voltage[HWARN]);
+	PRINT_VCC("Module voltage low warning threshold",
+		  sd.sfp_voltage[LWARN]);
+
+	PRINT_xX_PWR("Laser rx power high alarm threshold",
+		     sd.rx_power[HALRM]);
+	PRINT_xX_PWR("Laser rx power low alarm threshold",
+		     sd.rx_power[LALRM]);
+	PRINT_xX_PWR("Laser rx power high warning threshold",
+		     sd.rx_power[HWARN]);
+	PRINT_xX_PWR("Laser rx power low warning threshold",
+		     sd.rx_power[LWARN]);
+}
diff --git a/sff-common.h b/sff-common.h
new file mode 100644
index 0000000..5562b4d
--- /dev/null
+++ b/sff-common.h
@@ -0,0 +1,189 @@
+/*
+ * sff-common.h: Implements SFF-8024 Rev 4.0 i.e. Specifcation
+ * of pluggable I/O configuration
+ *
+ * Common utilities across SFF-8436/8636 and SFF-8472/8079
+ * are defined in this file
+ *
+ * Copyright 2010 Solarflare Communications Inc.
+ * Aurelien Guillaume <aurelien@iwi.me> (C) 2012
+ * Copyright (C) 2014 Cumulus networks Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Freeoftware Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ *  Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
+ *   This implementation is loosely based on current SFP parser
+ *   and SFF-8024 specs (ftp://ftp.seagate.com/pub/sff/SFF-8024.PDF)
+ *   by SFF Committee.
+ */
+
+#ifndef SFF_COMMON_H__
+#define SFF_COMMON_H__
+
+#include <stdio.h>
+#include "internal.h"
+
+#define SFF8024_ID_OFFSET				0x00
+#define  SFF8024_ID_UNKNOWN				0x00
+#define  SFF8024_ID_GBIC				0x01
+#define  SFF8024_ID_SOLDERED_MODULE		0x02
+#define  SFF8024_ID_SFP					0x03
+#define  SFF8024_ID_300_PIN_XBI			0x04
+#define  SFF8024_ID_XENPAK				0x05
+#define  SFF8024_ID_XFP					0x06
+#define  SFF8024_ID_XFF					0x07
+#define  SFF8024_ID_XFP_E				0x08
+#define  SFF8024_ID_XPAK				0x09
+#define  SFF8024_ID_X2					0x0A
+#define  SFF8024_ID_DWDM_SFP			0x0B
+#define  SFF8024_ID_QSFP				0x0C
+#define  SFF8024_ID_QSFP_PLUS			0x0D
+#define  SFF8024_ID_CXP					0x0E
+#define  SFF8024_ID_HD4X				0x0F
+#define  SFF8024_ID_HD8X				0x10
+#define  SFF8024_ID_QSFP28				0x11
+#define  SFF8024_ID_CXP2				0x12
+#define  SFF8024_ID_CDFP				0x13
+#define  SFF8024_ID_HD4X_FANOUT			0x14
+#define  SFF8024_ID_HD8X_FANOUT			0x15
+#define  SFF8024_ID_CDFP_S3				0x16
+#define  SFF8024_ID_MICRO_QSFP			0x17
+#define  SFF8024_ID_LAST				SFF8024_ID_MICRO_QSFP
+#define  SFF8024_ID_UNALLOCATED_LAST	0x7F
+#define  SFF8024_ID_VENDOR_START		0x80
+#define  SFF8024_ID_VENDOR_LAST			0xFF
+
+#define  SFF8024_CTOR_UNKNOWN			0x00
+#define  SFF8024_CTOR_SC				0x01
+#define  SFF8024_CTOR_FC_STYLE_1		0x02
+#define  SFF8024_CTOR_FC_STYLE_2		0x03
+#define  SFF8024_CTOR_BNC_TNC			0x04
+#define  SFF8024_CTOR_FC_COAX			0x05
+#define  SFF8024_CTOR_FIBER_JACK		0x06
+#define  SFF8024_CTOR_LC				0x07
+#define  SFF8024_CTOR_MT_RJ				0x08
+#define  SFF8024_CTOR_MU				0x09
+#define  SFF8024_CTOR_SG				0x0A
+#define  SFF8024_CTOR_OPT_PT			0x0B
+#define  SFF8024_CTOR_MPO				0x0C
+#define  SFF8024_CTOR_MPO_2				0x0D
+/* 0E-1Fh --- Reserved */
+#define  SFF8024_CTOR_HSDC_II			0x20
+#define  SFF8024_CTOR_COPPER_PT			0x21
+#define  SFF8024_CTOR_RJ45				0x22
+#define  SFF8024_CTOR_NO_SEPARABLE		0x23
+#define  SFF8024_CTOR_MXC_2x16			0x24
+#define  SFF8024_CTOR_LAST				SFF8024_CTOR_MXC_2x16
+#define  SFF8024_CTOR_UNALLOCATED_LAST	0x7F
+#define  SFF8024_CTOR_VENDOR_START		0x80
+#define  SFF8024_CTOR_VENDOR_LAST		0xFF
+
+/* ENCODING Values */
+#define  SFF8024_ENCODING_UNSPEC		0x00
+#define  SFF8024_ENCODING_8B10B			0x01
+#define  SFF8024_ENCODING_4B5B			0x02
+#define  SFF8024_ENCODING_NRZ			0x03
+/*
+ * Value: 04h
+ * SFF-8472      - Manchester
+ * SFF-8436/8636 - SONET Scrambled
+ */
+#define  SFF8024_ENCODING_4h			0x04
+/*
+ * Value: 05h
+ * SFF-8472      - SONET Scrambled
+ * SFF-8436/8636 - 64B/66B
+ */
+#define  SFF8024_ENCODING_5h			0x05
+/*
+ * Value: 06h
+ * SFF-8472      - 64B/66B
+ * SFF-8436/8636 - Manchester
+ */
+#define  SFF8024_ENCODING_6h			0x06
+#define  SFF8024_ENCODING_256B			0x07
+#define  SFF8024_ENCODING_PAM4			0x08
+
+/* Most common case: 16-bit unsigned integer in a certain unit */
+#define OFFSET_TO_U16(offset) \
+		(id[offset] << 8 | id[(offset) + 1])
+
+# define PRINT_xX_PWR(string, var)                             \
+		printf("\t%-41s : %.4f mW / %.2f dBm\n", (string),         \
+		      (double)((var) / 10000.),                           \
+		       convert_mw_to_dbm((double)((var) / 10000.)))
+
+#define PRINT_BIAS(string, bias_cur)                             \
+		printf("\t%-41s : %.3f mA\n", (string),                       \
+		      (double)(bias_cur / 500.))
+
+#define PRINT_TEMP(string, temp)                                   \
+		printf("\t%-41s : %.2f degrees C / %.2f degrees F\n", \
+		      (string), (double)(temp / 256.),                \
+		      (double)(temp / 256. * 1.8 + 32.))
+
+#define PRINT_VCC(string, sfp_voltage)          \
+		printf("\t%-41s : %.4f V\n", (string),       \
+		      (double)(sfp_voltage / 10000.))
+
+# define PRINT_xX_THRESH_PWR(string, var, index)                       \
+		PRINT_xX_PWR(string, (var)[(index)])
+
+/* Channel Monitoring Fields */
+struct sff_channel_diags {
+	__u16 bias_cur;      /* Measured bias current in 2uA units */
+	__u16 rx_power;      /* Measured RX Power */
+	__u16 tx_power;      /* Measured TX Power */
+};
+
+/* Module Monitoring Fields */
+struct sff_diags {
+
+#define MAX_CHANNEL_NUM 4
+#define LWARN 0
+#define HWARN 1
+#define LALRM 2
+#define HALRM 3
+#define MCURR 4
+
+	/* Supports DOM */
+	__u8 supports_dom;
+	/* Supports alarm/warning thold */
+	__u8 supports_alarms;
+	/* RX Power: 0 = OMA, 1 = Average power */
+	__u8  rx_power_type;
+	/* TX Power: 0 = Not supported, 1 = Average power */
+	__u8  tx_power_type;
+
+	__u8 calibrated_ext;    /* Is externally calibrated */
+	/* [5] tables are low/high warn, low/high alarm, current */
+	/* SFP voltage in 0.1mV units */
+	__u16 sfp_voltage[5];
+	/* SFP Temp in 16-bit signed 1/256 Celcius */
+	__s16 sfp_temp[5];
+	/* Measured bias current in 2uA units */
+	__u16 bias_cur[5];
+	/* Measured TX Power */
+	__u16 tx_power[5];
+	/* Measured RX Power */
+	__u16 rx_power[5];
+	struct sff_channel_diags scd[MAX_CHANNEL_NUM];
+};
+
+double convert_mw_to_dbm(double mw);
+void sff_show_value_with_unit(const __u8 *id, unsigned int reg,
+			      const char *name, unsigned int mult,
+			      const char *unit);
+void sff_show_ascii(const __u8 *id, unsigned int first_reg,
+		    unsigned int last_reg, const char *name);
+void sff_show_thresholds(struct sff_diags sd);
+
+void sff8024_show_oui(const __u8 *id, int id_offset);
+void sff8024_show_identifier(const __u8 *id, int id_offset);
+void sff8024_show_connector(const __u8 *id, int ctor_offset);
+void sff8024_show_encoding(const __u8 *id, int encoding_offset, int sff_type);
+
+#endif /* SFF_COMMON_H__ */
diff --git a/sfpdiag.c b/sfpdiag.c
index a3dbc9b..32e4cd8 100644
--- a/sfpdiag.c
+++ b/sfpdiag.c
@@ -12,6 +12,7 @@
 #include <math.h>
 #include <arpa/inet.h>
 #include "internal.h"
+#include "sff-common.h"
 
 /* Offsets in decimal, for direct comparison with the SFF specs */
 
@@ -86,28 +87,6 @@
 #define SFF_A2_CAL_V_SLP                  88
 #define SFF_A2_CAL_V_OFF                  90
 
-
-struct sff8472_diags {
-
-#define MCURR 0
-#define LWARN 1
-#define HWARN 2
-#define LALRM 3
-#define HALRM 4
-
-	/* [5] tables are current, low/high warn, low/high alarm */
-	__u8 supports_dom;      /* Supports DOM */
-	__u8 supports_alarms;   /* Supports alarm/warning thold */
-	__u8 calibrated_ext;    /* Is externally calibrated */
-	__u16 bias_cur[5];      /* Measured bias current in 2uA units */
-	__u16 tx_power[5];      /* Measured TX Power in 0.1uW units */
-	__u16 rx_power[5];      /* Measured RX Power */
-	__u8  rx_power_type;    /* 0 = OMA, 1 = Average power */
-	__s16 sfp_temp[5];      /* SFP Temp in 16-bit signed 1/256 Celsius */
-	__u16 sfp_voltage[5];   /* SFP voltage in 0.1mV units */
-
-};
-
 static struct sff8472_aw_flags {
 	const char *str;        /* Human-readable string, null at the end */
 	int offset;             /* A2-relative address offset */
@@ -141,12 +120,6 @@ static struct sff8472_aw_flags {
 	{ NULL, 0, 0 },
 };
 
-static double convert_mw_to_dbm(double mw)
-{
-	return (10. * log10(mw / 1000.)) + 30.;
-}
-
-
 /* Most common case: 16-bit unsigned integer in a certain unit */
 #define A2_OFFSET_TO_U16(offset) \
 	(id[SFF_A2_BASE + (offset)] << 8 | id[SFF_A2_BASE + (offset) + 1])
@@ -170,10 +143,8 @@ static double convert_mw_to_dbm(double mw)
  */
 #define A2_OFFSET_TO_TEMP(offset) ((__s16)A2_OFFSET_TO_U16(offset))
 
-
-static void sff8472_dom_parse(const __u8 *id, struct sff8472_diags *sd)
+static void sff8472_dom_parse(const __u8 *id, struct sff_diags *sd)
 {
-
 	sd->bias_cur[MCURR] = A2_OFFSET_TO_U16(SFF_A2_BIAS);
 	sd->bias_cur[HALRM] = A2_OFFSET_TO_U16(SFF_A2_BIAS_HALRM);
 	sd->bias_cur[LALRM] = A2_OFFSET_TO_U16(SFF_A2_BIAS_LALRM);
@@ -203,7 +174,6 @@ static void sff8472_dom_parse(const __u8 *id, struct sff8472_diags *sd)
 	sd->sfp_temp[LALRM] = A2_OFFSET_TO_TEMP(SFF_A2_TEMP_LALRM);
 	sd->sfp_temp[HWARN] = A2_OFFSET_TO_TEMP(SFF_A2_TEMP_HWARN);
 	sd->sfp_temp[LWARN] = A2_OFFSET_TO_TEMP(SFF_A2_TEMP_LWARN);
-
 }
 
 /* Converts to a float from a big-endian 4-byte source buffer. */
@@ -218,7 +188,7 @@ static float befloattoh(const __u32 *source)
 	return converter.dst;
 }
 
-static void sff8472_calibration(const __u8 *id, struct sff8472_diags *sd)
+static void sff8472_calibration(const __u8 *id, struct sff_diags *sd)
 {
 	int i;
 	__u16 rx_reading;
@@ -252,7 +222,7 @@ static void sff8472_calibration(const __u8 *id, struct sff8472_diags *sd)
 	}
 }
 
-static void sff8472_parse_eeprom(const __u8 *id, struct sff8472_diags *sd)
+static void sff8472_parse_eeprom(const __u8 *id, struct sff_diags *sd)
 {
 	sd->supports_dom = id[SFF_A0_DOM] & SFF_A0_DOM_IMPL;
 	sd->supports_alarms = id[SFF_A0_OPTIONS] & SFF_A0_OPTIONS_AW;
@@ -271,7 +241,7 @@ static void sff8472_parse_eeprom(const __u8 *id, struct sff8472_diags *sd)
 
 void sff8472_show_all(const __u8 *id)
 {
-	struct sff8472_diags sd;
+	struct sff_diags sd;
 	char *rx_power_string = NULL;
 	int i;
 
@@ -279,40 +249,22 @@ void sff8472_show_all(const __u8 *id)
 
 	if (!sd.supports_dom) {
 		printf("\t%-41s : No\n", "Optical diagnostics support");
-		return ;
+		return;
 	}
 	printf("\t%-41s : Yes\n", "Optical diagnostics support");
 
-#define PRINT_BIAS(string, index)                                        \
-	printf("\t%-41s : %.3f mA\n", (string),                          \
-	       (double)(sd.bias_cur[(index)] / 500.))
-
-# define PRINT_xX_PWR(string, var, index)                                \
-	printf("\t%-41s : %.4f mW / %.2f dBm\n", (string),               \
-	       (double)((var)[(index)] / 10000.),                        \
-	       convert_mw_to_dbm((double)((var)[(index)] / 10000.)))
-
-#define PRINT_TEMP(string, index)                                        \
-	printf("\t%-41s : %.2f degrees C / %.2f degrees F\n", (string),  \
-	       (double)(sd.sfp_temp[(index)] / 256.),                    \
-	       (double)(sd.sfp_temp[(index)] / 256. * 1.8 + 32.))
-
-#define PRINT_VCC(string, index)                                         \
-	printf("\t%-41s : %.4f V\n", (string),                           \
-	       (double)(sd.sfp_voltage[(index)] / 10000.))
-
-	PRINT_BIAS("Laser bias current", MCURR);
-	PRINT_xX_PWR("Laser output power", sd.tx_power, MCURR);
+	PRINT_BIAS("Laser bias current", sd.bias_cur[MCURR]);
+	PRINT_xX_PWR("Laser output power", sd.tx_power[MCURR]);
 
 	if (!sd.rx_power_type)
 		rx_power_string = "Receiver signal OMA";
 	else
 		rx_power_string = "Receiver signal average optical power";
 
-	PRINT_xX_PWR(rx_power_string, sd.rx_power, MCURR);
+	PRINT_xX_PWR(rx_power_string, sd.rx_power[MCURR]);
 
-	PRINT_TEMP("Module temperature", MCURR);
-	PRINT_VCC("Module voltage", MCURR);
+	PRINT_TEMP("Module temperature", sd.sfp_temp[MCURR]);
+	PRINT_VCC("Module voltage", sd.sfp_voltage[MCURR]);
 
 	printf("\t%-41s : %s\n", "Alarm/warning flags implemented",
 	       (sd.supports_alarms ? "Yes" : "No"));
@@ -323,40 +275,7 @@ void sff8472_show_all(const __u8 *id)
 			       id[SFF_A2_BASE + sff8472_aw_flags[i].offset]
 			       & sff8472_aw_flags[i].value ? "On" : "Off");
 		}
-
-		PRINT_BIAS("Laser bias current high alarm threshold",   HALRM);
-		PRINT_BIAS("Laser bias current low alarm threshold",    LALRM);
-		PRINT_BIAS("Laser bias current high warning threshold", HWARN);
-		PRINT_BIAS("Laser bias current low warning threshold",  LWARN);
-
-		PRINT_xX_PWR("Laser output power high alarm threshold",
-			     sd.tx_power, HALRM);
-		PRINT_xX_PWR("Laser output power low alarm threshold",
-			     sd.tx_power, LALRM);
-		PRINT_xX_PWR("Laser output power high warning threshold",
-			     sd.tx_power, HWARN);
-		PRINT_xX_PWR("Laser output power low warning threshold",
-			     sd.tx_power, LWARN);
-
-		PRINT_TEMP("Module temperature high alarm threshold",   HALRM);
-		PRINT_TEMP("Module temperature low alarm threshold",    LALRM);
-		PRINT_TEMP("Module temperature high warning threshold", HWARN);
-		PRINT_TEMP("Module temperature low warning threshold",  LWARN);
-
-		PRINT_VCC("Module voltage high alarm threshold",   HALRM);
-		PRINT_VCC("Module voltage low alarm threshold",    LALRM);
-		PRINT_VCC("Module voltage high warning threshold", HWARN);
-		PRINT_VCC("Module voltage low warning threshold",  LWARN);
-
-		PRINT_xX_PWR("Laser rx power high alarm threshold",
-			     sd.rx_power, HALRM);
-		PRINT_xX_PWR("Laser rx power low alarm threshold",
-			     sd.rx_power, LALRM);
-		PRINT_xX_PWR("Laser rx power high warning threshold",
-			     sd.rx_power, HWARN);
-		PRINT_xX_PWR("Laser rx power low warning threshold",
-			     sd.rx_power, LWARN);
+		sff_show_thresholds(sd);
 	}
-
 }
 
diff --git a/sfpid.c b/sfpid.c
index 0b5cd62..fd6415c 100644
--- a/sfpid.c
+++ b/sfpid.c
@@ -9,27 +9,11 @@
 
 #include <stdio.h>
 #include "internal.h"
+#include "sff-common.h"
 
 static void sff8079_show_identifier(const __u8 *id)
 {
-	printf("\t%-41s : 0x%02x", "Identifier", id[0]);
-	switch (id[0]) {
-	case 0x00:
-		printf(" (no module present, unknown, or unspecified)\n");
-		break;
-	case 0x01:
-		printf(" (GBIC)\n");
-		break;
-	case 0x02:
-		printf(" (module soldered to motherboard)\n");
-		break;
-	case 0x03:
-		printf(" (SFP)\n");
-		break;
-	default:
-		 printf(" (reserved or unknown)\n");
-		break;
-	}
+	sff8024_show_identifier(id, 0);
 }
 
 static void sff8079_show_ext_identifier(const __u8 *id)
@@ -47,60 +31,7 @@ static void sff8079_show_ext_identifier(const __u8 *id)
 
 static void sff8079_show_connector(const __u8 *id)
 {
-	printf("\t%-41s : 0x%02x", "Connector", id[2]);
-	switch (id[2]) {
-	case 0x00:
-		printf(" (unknown or unspecified)\n");
-		break;
-	case 0x01:
-		printf(" (SC)\n");
-		break;
-	case 0x02:
-		printf(" (Fibre Channel Style 1 copper)\n");
-		break;
-	case 0x03:
-		printf(" (Fibre Channel Style 2 copper)\n");
-		break;
-	case 0x04:
-		printf(" (BNC/TNC)\n");
-		break;
-	case 0x05:
-		printf(" (Fibre Channel coaxial headers)\n");
-		break;
-	case 0x06:
-		printf(" (FibreJack)\n");
-		break;
-	case 0x07:
-		printf(" (LC)\n");
-		break;
-	case 0x08:
-		printf(" (MT-RJ)\n");
-		break;
-	case 0x09:
-		printf(" (MU)\n");
-		break;
-	case 0x0a:
-		printf(" (SG)\n");
-		break;
-	case 0x0b:
-		printf(" (Optical pigtail)\n");
-		break;
-	case 0x0c:
-		printf(" (MPO Parallel Optic)\n");
-		break;
-	case 0x20:
-		printf(" (HSSDC II)\n");
-		break;
-	case 0x21:
-		printf(" (Copper pigtail)\n");
-		break;
-	case 0x22:
-		printf(" (RJ45)\n");
-		break;
-	default:
-		printf(" (reserved or unknown)\n");
-		break;
-	}
+	sff8024_show_connector(id, 2);
 }
 
 static void sff8079_show_transceiver(const __u8 *id)
@@ -241,33 +172,7 @@ static void sff8079_show_transceiver(const __u8 *id)
 
 static void sff8079_show_encoding(const __u8 *id)
 {
-	printf("\t%-41s : 0x%02x", "Encoding", id[11]);
-	switch (id[11]) {
-	case 0x00:
-		printf(" (unspecified)\n");
-		break;
-	case 0x01:
-		printf(" (8B/10B)\n");
-		break;
-	case 0x02:
-		printf(" (4B/5B)\n");
-		break;
-	case 0x03:
-		printf(" (NRZ)\n");
-		break;
-	case 0x04:
-		printf(" (Manchester)\n");
-		break;
-	case 0x05:
-		printf(" (SONET Scrambled)\n");
-		break;
-	case 0x06:
-		printf(" (64B/66B)\n");
-		break;
-	default:
-		printf(" (reserved or unknown)\n");
-		break;
-	}
+	sff8024_show_encoding(id, 11, ETH_MODULE_SFF_8472);
 }
 
 static void sff8079_show_rate_identifier(const __u8 *id)
-- 
2.1.4

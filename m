From: Stuart Hodgson <smhodgson@solarflare.com>
Subject: [PATCH 3/3] ethtool: Addition of -m option to dump module eeprom
Date: Fri, 18 May 2012 15:58:45 +0100
Message-ID: <4FB663A5.3060107@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58887 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752308Ab2ERO6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 10:58:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The -m option now allows for retrieval of EEPROM
information form a plug in module such as SFP+. This
shows specific information about the type and
capabilities of the module in use The format can be
easily extended to support other modules types such as
QSFP in future. Raw data dump is also supported.

Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
---
 Makefile.am    |    2 +-
 ethtool.8.in   |   10 ++
 ethtool.c      |   87 +++++++++++++
 internal.h     |    3 +
 sfpid.c        |  387 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 test-cmdline.c |   10 ++
 6 files changed, 498 insertions(+), 1 deletions(-)
 create mode 100644 sfpid.c

diff --git a/Makefile.am b/Makefile.am
index 4b0eb17..e40fc99 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -9,7 +9,7 @@ ethtool_SOURCES = ethtool.c ethtool-copy.h internal.h \
 		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
 		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
-		  rxclass.c
+		  rxclass.c sfpid.c
 
 TESTS = test-cmdline
 check_PROGRAMS = test-cmdline test-one-cmdline
diff --git a/ethtool.8.in b/ethtool.8.in
index 63d5d48..cba86ff 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -318,6 +318,13 @@ ethtool \- query or control network driver and hardware settings
 .BN other
 .BN combined
 .HP
+.B ethtool \-m|\-\-dump\-module\-eeprom
+.I devname
+.B2 raw on off
+.B2 hex on off
+.BN offset
+.BN length
+.HP
 .B ethtool \-\-show\-priv\-flags
 .I devname
 .HP
@@ -789,6 +796,9 @@ Changes the number of channels used only for other purposes e.g. link interrupts
 .BI combined \ N
 Changes the number of multi-purpose channels.
 .TP
+.B \-m \-\-dump\-module\-eeprom
+Retrieves and if possible decodes the EEPROM from plugin modules, e.g SFP+, QSFP
+.TP
 .B \-\-show\-priv\-flags
 Queries the specified network device for its private flags.  The
 names and meanings of private flags (if any) are defined by each
diff --git a/ethtool.c b/ethtool.c
index fdc21de..d9f1462 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3078,6 +3078,87 @@ static int do_sprivflags(struct cmd_context *ctx)
 	return 0;
 }
 
+static int do_getmodule(struct cmd_context *ctx)
+{
+	struct ethtool_modinfo modinfo;
+	struct ethtool_eeprom *eeprom;
+	u32 geeprom_offset = 0;
+	u32 geeprom_length = -1;
+	int geeprom_changed = 0;
+	int geeprom_dump_raw = 0;
+	int geeprom_dump_hex = 0;
+	int err;
+
+	struct cmdline_info cmdline_geeprom[] = {
+		{ "offset", CMDL_U32, &geeprom_offset, NULL },
+		{ "length", CMDL_U32, &geeprom_length, NULL },
+		{ "raw", CMDL_BOOL, &geeprom_dump_raw, NULL },
+		{ "hex", CMDL_BOOL, &geeprom_dump_hex, NULL },
+	};
+
+	parse_generic_cmdline(ctx, &geeprom_changed,
+			      cmdline_geeprom, ARRAY_SIZE(cmdline_geeprom));
+
+	if (geeprom_dump_raw && geeprom_dump_hex) {
+		printf("Hex and raw dump cannot be specified together\n");
+		return 1;
+	}
+
+	modinfo.cmd = ETHTOOL_GMODULEINFO;
+	err = send_ioctl(ctx, &modinfo);
+	if (err < 0) {
+		perror("Cannot get module EEPROM information");
+		return 1;
+	}
+
+	if (geeprom_length == -1)
+		geeprom_length = modinfo.eeprom_len;
+
+	if (modinfo.eeprom_len < geeprom_offset + geeprom_length)
+		geeprom_length = modinfo.eeprom_len - geeprom_offset;
+
+	eeprom = calloc(1, sizeof(*eeprom)+geeprom_length);
+	if (!eeprom) {
+		perror("Cannot allocate memory for Module EEPROM data");
+		return 1;
+	}
+
+	eeprom->cmd = ETHTOOL_GMODULEEEPROM;
+	eeprom->len = geeprom_length;
+	eeprom->offset = geeprom_offset;
+	err = send_ioctl(ctx, eeprom);
+	if (err < 0) {
+		perror("Cannot get Module EEPROM data");
+		free(eeprom);
+		return 1;
+	}
+
+	if (geeprom_dump_raw) {
+		fwrite(eeprom->data, 1, eeprom->len, stdout);
+	} else {
+		if (eeprom->offset != 0  ||
+		    (eeprom->len != modinfo.eeprom_len)) {
+			geeprom_dump_hex = 1;
+		} else if (!geeprom_dump_hex) {
+			switch (modinfo.type) {
+			case ETH_MODULE_SFF_8079:
+			case ETH_MODULE_SFF_8472:
+				sff8079_show_all(eeprom->data);
+				break;
+			default:
+				geeprom_dump_hex = 1;
+				break;
+			}
+		}
+		if (geeprom_dump_hex)
+			dump_hex(eeprom->data, eeprom->len, eeprom->offset);
+	}
+
+	free(eeprom);
+
+	return 0;
+}
+
 int send_ioctl(struct cmd_context *ctx, void *cmd)
 {
 #ifndef TEST_ETHTOOL
@@ -3232,6 +3313,12 @@ static const struct option {
 	{ "--show-priv-flags" , 1, do_gprivflags, "Query private flags" },
 	{ "--set-priv-flags", 1, do_sprivflags, "Set private flags",
 	  "		FLAG on|off ...\n" },
+	{ "-m|--dump-module-eeprom", 1, do_getmodule,
+	  "Qeuery/Decode Module EEPROM information",
+	  "		[ raw on|off ]\n"
+	  "		[ hex on|off ]\n"
+	  "		[ offset N ]\n"
+	  "		[ length N ]\n" },
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
 	{}
diff --git a/internal.h b/internal.h
index 867c0ea..576b79b 100644
--- a/internal.h
+++ b/internal.h
@@ -174,4 +174,7 @@ int rxclass_rule_ins(struct cmd_context *ctx,
 		     struct ethtool_rx_flow_spec *fsp);
 int rxclass_rule_del(struct cmd_context *ctx, __u32 loc);
 
+/* Module EEPROM parsing code */
+void sff8079_show_all(const __u8 *id);
+
 #endif /* ETHTOOL_INTERNAL_H__ */
diff --git a/sfpid.c b/sfpid.c
new file mode 100644
index 0000000..a4a671d
--- /dev/null
+++ b/sfpid.c
@@ -0,0 +1,387 @@
+/****************************************************************************
+ * Support for Solarflare Solarstorm network controllers and boards
+ * Copyright 2010 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <stdio.h>
+#include "internal.h"
+
+static void sff8079_show_identifier(const __u8 *id)
+{
+	printf("\tIdentifier          : 0x%02x", id[0]);
+	switch (id[0]) {
+	case 0x00:
+		printf(" (no module present, unknown, or unspecified)\n");
+		break;
+	case 0x01:
+		printf(" (GBIC)\n");
+		break;
+	case 0x02:
+		printf(" (module soldered to motherboard)\n");
+		break;
+	case 0x03:
+		printf(" (SFP)\n");
+		break;
+	default:
+		 printf(" (reserved or unknown)\n");
+		break;
+	}
+}
+
+static void sff8079_show_ext_identifier(const __u8 *id)
+{
+	printf("\tExtended identifier : 0x%02x", id[1]);
+	if (id[1] == 0x00)
+		printf(" (GBIC not specified / not MOD_DEF compliant)\n");
+	else if (id[1] == 0x04)
+		printf(" (GBIC/SFP defined by 2-wire interface ID)\n");
+	else if (id[1] <= 0x07)
+		printf(" (GBIC compliant with MOD_DEF %u)\n", id[1]);
+	else
+		printf(" (unknown)\n");
+}
+
+static void sff8079_show_connector(const __u8 *id)
+{
+	printf("\tConnector           : 0x%02x", id[2]);
+	switch (id[2]) {
+	case 0x00:
+		printf(" (unknown or unspecified)\n");
+		break;
+	case 0x01:
+		printf(" (SC)\n");
+		break;
+	case 0x02:
+		printf(" (Fibre Channel Style 1 copper)\n");
+		break;
+	case 0x03:
+		printf(" (Fibre Channel Style 2 copper)\n");
+		break;
+	case 0x04:
+		printf(" (BNC/TNC)\n");
+		break;
+	case 0x05:
+		printf(" (Fibre Channel coaxial headers)\n");
+		break;
+	case 0x06:
+		printf(" (FibreJack)\n");
+		break;
+	case 0x07:
+		printf(" (LC)\n");
+		break;
+	case 0x08:
+		printf(" (MT-RJ)\n");
+		break;
+	case 0x09:
+		printf(" (MU)\n");
+		break;
+	case 0x0a:
+		printf(" (SG)\n");
+		break;
+	case 0x0b:
+		printf(" (Optical pigtail)\n");
+		break;
+	case 0x0c:
+		printf(" (MPO Parallel Optic)\n");
+		break;
+	case 0x20:
+		printf(" (HSSDC II)\n");
+		break;
+	case 0x21:
+		printf(" (Copper pigtail)\n");
+		break;
+	case 0x22:
+		printf(" (RJ45)\n");
+		break;
+	default:
+		printf(" (reserved or unknown)\n");
+		break;
+	}
+}
+
+static void sff8079_show_transceiver(const __u8 *id)
+{
+	static const char *pfx = "\t                    :  =>";
+
+	printf("\tTransceiver codes   : 0x%02x 0x%02x 0x%02x" \
+	       "0x%02x 0x%02x 0x%02x 0x%02x 0x%02x\n",
+	       id[3], id[4], id[5], id[6],
+	       id[7], id[8], id[9], id[10]);
+	/* 10G Ethernet Compliance Codes */
+	if (id[3] & (1 << 7))
+		printf("%s 10G Ethernet: 10G Base-ER" \
+		       " [SFF-8472 rev10.4 only]\n", pfx);
+	if (id[3] & (1 << 6))
+		printf("%s 10G Ethernet: 10G Base-LRM\n", pfx);
+	if (id[3] & (1 << 5))
+		printf("%s 10G Ethernet: 10G Base-LR\n", pfx);
+	if (id[3] & (1 << 4))
+		printf("%s 10G Ethernet: 10G Base-SR\n", pfx);
+	/* Infiniband Compliance Codes */
+	if (id[3] & (1 << 3))
+		printf("%s Infiniband: 1X SX\n", pfx);
+	if (id[3] & (1 << 2))
+		printf("%s Infiniband: 1X LX\n", pfx);
+	if (id[3] & (1 << 1))
+		printf("%s Infiniband: 1X Copper Active\n", pfx);
+	if (id[3] & (1 << 0))
+		printf("%s Infiniband: 1X Copper Passive\n", pfx);
+	/* ESCON Compliance Codes */
+	if (id[4] & (1 << 7))
+		printf("%s ESCON: ESCON MMF, 1310nm LED\n", pfx);
+	if (id[4] & (1 << 6))
+		printf("%s ESCON: ESCON SMF, 1310nm Laser\n", pfx);
+	/* SONET Compliance Codes */
+	if (id[4] & (1 << 5))
+		printf("%s SONET: OC-192, short reach\n", pfx);
+	if (id[4] & (1 << 4))
+		printf("%s SONET: SONET reach specifier bit 1\n", pfx);
+	if (id[4] & (1 << 3))
+		printf("%s SONET: SONET reach specifier bit 2\n", pfx);
+	if (id[4] & (1 << 2))
+		printf("%s SONET: OC-48, long reach\n", pfx);
+	if (id[4] & (1 << 1))
+		printf("%s SONET: OC-48, intermediate reach\n", pfx);
+	if (id[4] & (1 << 0))
+		printf("%s SONET: OC-48, short reach\n", pfx);
+	if (id[5] & (1 << 6))
+		printf("%s SONET: OC-12, single mode, long reach\n", pfx);
+	if (id[5] & (1 << 5))
+		printf("%s SONET: OC-12, single mode, inter. reach\n", pfx);
+	if (id[5] & (1 << 4))
+		printf("%s SONET: OC-12, short reach\n", pfx);
+	if (id[5] & (1 << 2))
+		printf("%s SONET: OC-3, single mode, long reach\n", pfx);
+	if (id[5] & (1 << 1))
+		printf("%s SONET: OC-3, single mode, inter. reach\n", pfx);
+	if (id[5] & (1 << 0))
+		printf("%s SONET: OC-3, short reach\n", pfx);
+	/* Ethernet Compliance Codes */
+	if (id[6] & (1 << 7))
+		printf("%s Ethernet: BASE-PX\n", pfx);
+	if (id[6] & (1 << 6))
+		printf("%s Ethernet: BASE-BX10\n", pfx);
+	if (id[6] & (1 << 5))
+		printf("%s Ethernet: 100BASE-FX\n", pfx);
+	if (id[6] & (1 << 4))
+		printf("%s Ethernet: 100BASE-LX/LX10\n", pfx);
+	if (id[6] & (1 << 3))
+		printf("%s Ethernet: 1000BASE-T\n", pfx);
+	if (id[6] & (1 << 2))
+		printf("%s Ethernet: 1000BASE-CX\n", pfx);
+	if (id[6] & (1 << 1))
+		printf("%s Ethernet: 1000BASE-LX\n", pfx);
+	if (id[6] & (1 << 0))
+		printf("%s Ethernet: 1000BASE-SX\n", pfx);
+	/* Fibre Channel link length */
+	if (id[7] & (1 << 7))
+		printf("%s FC: very long distance (V)\n", pfx);
+	if (id[7] & (1 << 6))
+		printf("%s FC: short distance (S)\n", pfx);
+	if (id[7] & (1 << 5))
+		printf("%s FC: intermediate distance (I)\n", pfx);
+	if (id[7] & (1 << 4))
+		printf("%s FC: long distance (L)\n", pfx);
+	if (id[7] & (1 << 3))
+		printf("%s FC: medium distance (M)\n", pfx);
+	/* Fibre Channel transmitter technology */
+	if (id[7] & (1 << 2))
+		printf("%s FC: Shortwave laser, linear Rx (SA)\n", pfx);
+	if (id[7] & (1 << 1))
+		printf("%s FC: Longwave laser (LC)\n", pfx);
+	if (id[7] & (1 << 0))
+		printf("%s FC: Electrical inter-enclosure (EL)\n", pfx);
+	if (id[8] & (1 << 7))
+		printf("%s FC: Electrical intra-enclosure (EL)\n", pfx);
+	if (id[8] & (1 << 6))
+		printf("%s FC: Shortwave laser w/o OFC (SN)\n", pfx);
+	if (id[8] & (1 << 5))
+		printf("%s FC: Shortwave laser with OFC (SL)\n", pfx);
+	if (id[8] & (1 << 4))
+		printf("%s FC: Longwave laser (LL)\n", pfx);
+	if (id[8] & (1 << 3))
+		printf("%s FC: Copper Active\n", pfx);
+	if (id[8] & (1 << 2))
+		printf("%s FC: Copper Passive\n", pfx);
+	if (id[8] & (1 << 1))
+		printf("%s FC: Copper FC-BaseT\n", pfx);
+	/* Fibre Channel transmission media */
+	if (id[9] & (1 << 7))
+		printf("%s FC: Twin Axial Pair (TW)\n", pfx);
+	if (id[9] & (1 << 6))
+		printf("%s FC: Twisted Pair (TP)\n", pfx);
+	if (id[9] & (1 << 5))
+		printf("%s FC: Miniature Coax (MI)\n", pfx);
+	if (id[9] & (1 << 4))
+		printf("%s FC: Video Coax (TV)\n", pfx);
+	if (id[9] & (1 << 3))
+		printf("%s FC: Multimode, 62.5um (M6)\n", pfx);
+	if (id[9] & (1 << 2))
+		printf("%s FC: Multimode, 50um (M5)\n", pfx);
+	if (id[9] & (1 << 0))
+		printf("%s FC: Single Mode (SM)\n", pfx);
+	/* Fibre Channel speed */
+	if (id[10] & (1 << 7))
+		printf("%s FC: 1200 MBytes/sec\n", pfx);
+	if (id[10] & (1 << 6))
+		printf("%s FC: 800 MBytes/sec\n", pfx);
+	if (id[10] & (1 << 4))
+		printf("%s FC: 400 MBytes/sec\n", pfx);
+	if (id[10] & (1 << 2))
+		printf("%s FC: 200 MBytes/sec\n", pfx);
+	if (id[10] & (1 << 0))
+		printf("%s FC: 100 MBytes/sec\n", pfx);
+}
+
+static void sff8079_show_encoding(const __u8 *id)
+{
+	printf("\tEncoding            : 0x%02x", id[11]);
+	switch (id[11]) {
+	case 0x00:
+		printf(" (unspecified)\n");
+		break;
+	case 0x01:
+		printf(" (8B/10B)\n");
+		break;
+	case 0x02:
+		printf(" (4B/5B)\n");
+		break;
+	case 0x03:
+		printf(" (NRZ)\n");
+		break;
+	case 0x04:
+		printf(" (Manchester)\n");
+		break;
+	case 0x05:
+		printf(" (SONET Scrambled)\n");
+		break;
+	case 0x06:
+		printf(" (64B/66B)\n");
+		break;
+	default:
+		printf(" (reserved or unknown)\n");
+		break;
+	}
+}
+
+static void sff8079_show_rate_identifier(const __u8 *id)
+{
+	printf("\tRate identifier     : 0x%02x", id[13]);
+	switch (id[13]) {
+	case 0x00:
+		printf(" (unspecified)\n");
+		break;
+	case 0x01:
+		printf(" (4/2/1G Rate_Select & AS0/AS1)\n");
+		break;
+	case 0x02:
+		printf(" (8/4/2G Rx Rate_Select only)\n");
+		break;
+	case 0x03:
+		printf(" (8/4/2G Independent Rx & Tx Rate_Select)\n");
+		break;
+	case 0x04:
+		printf(" (8/4/2G Tx Rate_Select only)\n");
+		break;
+	default:
+		printf(" (reserved or unknown)\n");
+		break;
+	}
+}
+
+static void sff8079_show_oui(const __u8 *id)
+{
+	printf("\tVendor OUI          : %02x:%02x:%02x\n",
+	       id[37], id[38], id[39]);
+}
+
+static void sff8079_show_wavelength_or_copper_compliance(const __u8 *id)
+{
+	if (id[8] & (1 << 2)) {
+		printf("\tPassive Cu cmplnce. : 0x%02x", id[60]);
+		switch (id[60]) {
+		case 0x00:
+			printf(" (unspecified)");
+			break;
+		case 0x01:
+			printf(" (SFF-8431 appendix E)");
+			break;
+		default:
+			printf(" (unknown)");
+			break;
+		}
+		printf(" [SFF-8472 rev10.4 only]\n");
+	} else if (id[8] & (1 << 3)) {
+		printf("\tActive Cu cmplnce.  : 0x%02x", id[60]);
+		switch (id[60]) {
+		case 0x00:
+			printf(" (unspecified)");
+			break;
+		case 0x01:
+			printf(" (SFF-8431 appendix E)");
+			break;
+		case 0x04:
+			printf(" (SFF-8431 limiting)");
+			break;
+		default:
+			printf(" (unknown)");
+			break;
+		}
+		printf(" [SFF-8472 rev10.4 only]\n");
+	} else {
+		printf("\tLaser wavelength    : %unm\n",
+		       (id[60] << 8) | id[61]);
+	}
+}
+
+static void sff8079_show_value_with_unit(const __u8 *id, unsigned int reg,
+					 const char *name, unsigned int mult,
+					 const char *unit)
+{
+	unsigned int val = id[reg];
+
+	printf("\t%-20s: %u%s\n", name, val * mult, unit);
+}
+
+static void sff8079_show_ascii(const __u8 *id, unsigned int first_reg,
+			       unsigned int last_reg, const char *name)
+{
+	unsigned int reg, val;
+
+	printf("\t%-20s: ", name);
+	for (reg = first_reg; reg <= last_reg; reg++) {
+		val = id[reg];
+		putchar(((val >= 32) && (val <= 126)) ? val : '_');
+	}
+	printf("\n");
+}
+
+void sff8079_show_all(const __u8 *id)
+{
+	sff8079_show_identifier(id);
+	if ((id[0] == 0x03) && (id[1] == 0x04)) {
+		sff8079_show_ext_identifier(id);
+		sff8079_show_connector(id);
+		sff8079_show_transceiver(id);
+		sff8079_show_encoding(id);
+		sff8079_show_value_with_unit(id, 12, "BR, Nominal", 100, "MBd");
+		sff8079_show_rate_identifier(id);
+		sff8079_show_value_with_unit(id, 14,
+					     "Length (SMF,km)", 1, "km");
+		sff8079_show_value_with_unit(id, 15, "Length (SMF)", 100, "m");
+		sff8079_show_value_with_unit(id, 16, "Length (50um)", 10, "m");
+		sff8079_show_value_with_unit(id, 17,
+					     "Length (62.5um)", 10, "m");
+		sff8079_show_value_with_unit(id, 18, "Length (Copper)", 1, "m");
+		sff8079_show_value_with_unit(id, 19, "Length (OM3)", 10, "m");
+		sff8079_show_wavelength_or_copper_compliance(id);
+		sff8079_show_ascii(id, 20, 35, "Vendor name");
+		sff8079_show_oui(id);
+		sff8079_show_ascii(id, 40, 55, "Vendor PN");
+		sff8079_show_ascii(id, 56, 59, "Vendor rev");
+	}
+}
diff --git a/test-cmdline.c b/test-cmdline.c
index 4718842..f830d54 100644
--- a/test-cmdline.c
+++ b/test-cmdline.c
@@ -210,6 +210,16 @@ static struct test_case {
 	{ 0, "--show-priv-flags devname" },
 	{ 1, "--show-priv-flags devname foo" },
 	{ 1, "--show-priv-flags" },
+	{ 1, "-m" },
+	{ 0, "-m devname" },
+	{ 1, "--dump-module-eeprom" },
+	{ 0, "--dump-module-eeprom devname" },
+	{ 0, "-m devname raw on" },
+	{ 0, "-m devname raw off" },
+	{ 0, "-m devname hex on" },
+	{ 0, "-m devname hex off" },
+	{ 1, "-m devname hex on raw on" },
+	{ 0, "-m devname offset 4 length 6" },
 	/* can't test --set-priv-flags yet */
 	{ 0, "-h" },
 	{ 0, "--help" },
-- 
1.7.7.6

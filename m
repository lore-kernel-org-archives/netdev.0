From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH v2] ethtool: allow for a smaller build
Date: Thu, 27 Feb 2014 15:43:01 -0800
Message-ID: <1393544581-1252-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>
To: <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:5691 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbaB0XnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 18:43:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a new configure script option: --disable-pretty-dump which will
disable building the driver specific register, EEPROM and SFP
pretty printing objects, the saving are:

~500 Kbytes on a x86_64 build
~337 Kbytes on a arm build

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- reworked the small build around the ETHTOOL_ENABLE_PRETTY_DUMP
  option which is enabled by default
- updated the ethtool reported version accordingly
- upated the descriptions/comments to a mention of the SFP pretty
  dumps

 Makefile.am  |  6 +++++-
 configure.ac |  9 +++++++++
 ethtool.c    | 14 +++++++++++---
 3 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index db89d94b168e..fd3b17fe3bea 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -6,11 +6,15 @@ EXTRA_DIST = LICENSE ethtool.8 ethtool.spec.in aclocal.m4 ChangeLog autogen.sh
 
 sbin_PROGRAMS = ethtool
 ethtool_SOURCES = ethtool.c ethtool-copy.h internal.h net_tstamp-copy.h \
+		  rxclass.c
+if ETHTOOL_ENABLE_PRETTY_DUMP
+ethtool_SOURCES += \
 		  amd8111e.c de2104x.c e100.c e1000.c et131x.c igb.c	\
 		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
 		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
-		  rxclass.c sfpid.c sfpdiag.c ixgbevf.c
+		  sfpid.c sfpdiag.c ixgbevf.c
+endif
 
 TESTS = test-cmdline test-features
 check_PROGRAMS = test-cmdline test-features
diff --git a/configure.ac b/configure.ac
index ac7977a777f0..c2b7505f9a13 100644
--- a/configure.ac
+++ b/configure.ac
@@ -30,5 +30,14 @@ dnl Checks for library functions.
 AC_HEADER_STDC
 AC_CHECK_FUNCS(socket strtol)
 
+dnl Check for options
+AC_ARG_ENABLE(pretty-dump,
+	       [  --enable-pretty-dump	  enable registers, EEPROM and SFP pretty dumps (enabled by default)],,
+	       [if test x$enableval != xno; then
+			AC_DEFINE(ETHTOOL_ENABLE_PRETTY_DUMP, 1,
+			[Define this to enable register, EEPROM and SFP pretty dumps.]) enable_prettydump=yes
+		fi])
+AM_CONDITIONAL([ETHTOOL_ENABLE_PRETTY_DUMP], [test x$enable_prettydump = xyes])
+
 AC_CONFIG_FILES([Makefile ethtool.spec ethtool.8])
 AC_OUTPUT
diff --git a/ethtool.c b/ethtool.c
index acb4397e162f..b9aca1961e83 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -474,7 +474,11 @@ static int rxflow_str_to_type(const char *str)
 static int do_version(struct cmd_context *ctx)
 {
 	fprintf(stdout,
-		PACKAGE " version " VERSION "\n");
+		PACKAGE " version " VERSION
+#ifndef ETHTOOL_ENABLE_PRETTY_DUMP
+		" (pretty dumps disabled)"
+#endif
+		"\n");
 	return 0;
 }
 
@@ -879,6 +883,7 @@ static const struct {
 	int (*func)(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
 } driver_list[] = {
+#ifdef ETHTOOL_ENABLE_PRETTY_DUMP
 	{ "8139cp", realtek_dump_regs },
 	{ "8139too", realtek_dump_regs },
 	{ "r8169", realtek_dump_regs },
@@ -905,6 +910,7 @@ static const struct {
 	{ "st_mac100", st_mac100_dump_regs },
 	{ "st_gmac", st_gmac_dump_regs },
 	{ "et131x", et131x_dump_regs },
+#endif
 };
 
 void dump_hex(FILE *file, const u8 *data, int len, int offset)
@@ -973,13 +979,13 @@ static int dump_eeprom(int geeprom_dump_raw, struct ethtool_drvinfo *info,
 		fwrite(ee->data, 1, ee->len, stdout);
 		return 0;
 	}
-
+#ifdef ETHTOOL_ENABL_PRETTY_DUMP
 	if (!strncmp("natsemi", info->driver, ETHTOOL_BUSINFO_LEN)) {
 		return natsemi_dump_eeprom(info, ee);
 	} else if (!strncmp("tg3", info->driver, ETHTOOL_BUSINFO_LEN)) {
 		return tg3_dump_eeprom(info, ee);
 	}
-
+#endif
 	dump_hex(stdout, ee->data, ee->len, ee->offset);
 
 	return 0;
@@ -3635,6 +3641,7 @@ static int do_getmodule(struct cmd_context *ctx)
 			geeprom_dump_hex = 1;
 		} else if (!geeprom_dump_hex) {
 			switch (modinfo.type) {
+#ifdef ETHTOOL_ENABLE_PRETTY_DUMP
 			case ETH_MODULE_SFF_8079:
 				sff8079_show_all(eeprom->data);
 				break;
@@ -3642,6 +3649,7 @@ static int do_getmodule(struct cmd_context *ctx)
 				sff8079_show_all(eeprom->data);
 				sff8472_show_all(eeprom->data);
 				break;
+#endif
 			default:
 				geeprom_dump_hex = 1;
 				break;
-- 
1.8.3.2

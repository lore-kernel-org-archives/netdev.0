From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 2/2] ethtool: allow for a smaller build
Date: Wed, 26 Feb 2014 17:35:11 -0800
Message-ID: <1393464911-21593-3-git-send-email-f.fainelli@gmail.com>
References: <1393464911-21593-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>
To: <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:47076 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753594AbaB0BfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 20:35:19 -0500
In-Reply-To: <1393464911-21593-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a new configure script option: --enable-small which will
disable building the driver specific register dump objects, the savings
are:

~500 Kbytes on a x86_64 build
~337 Kbytes on a arm build

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Makefile.am  | 6 +++++-
 configure.ac | 8 ++++++++
 ethtool.c    | 8 ++++++--
 3 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index db89d94b168e..05d140008a9c 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -6,11 +6,15 @@ EXTRA_DIST = LICENSE ethtool.8 ethtool.spec.in aclocal.m4 ChangeLog autogen.sh
 
 sbin_PROGRAMS = ethtool
 ethtool_SOURCES = ethtool.c ethtool-copy.h internal.h net_tstamp-copy.h \
+		  rxclass.c
+if !SMALL
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
index ac7977a777f0..995d937db4c9 100644
--- a/configure.ac
+++ b/configure.ac
@@ -30,5 +30,13 @@ dnl Checks for library functions.
 AC_HEADER_STDC
 AC_CHECK_FUNCS(socket strtol)
 
+dnl Check for options
+AC_ARG_ENABLE(small,
+	       [  --enable-small	  disable registers and EEPROM pretty dumps (disabled by default)],
+	       [if test x$enableval = xyes; then
+			AC_DEFINE(SMALL, 1, [Define this to disable register and EEPROM pretty dumps.]) enable_small=yes
+		fi])
+AM_CONDITIONAL([SMALL], [test x$enable_small = xyes])
+
 AC_CONFIG_FILES([Makefile ethtool.spec ethtool.8])
 AC_OUTPUT
diff --git a/ethtool.c b/ethtool.c
index 315d00f5102f..ff4822389b67 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -877,6 +877,7 @@ static const struct {
 	int (*func)(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
 } driver_list[] = {
+#ifndef SMALL
 	{ "8139cp", realtek_dump_regs },
 	{ "8139too", realtek_dump_regs },
 	{ "r8169", realtek_dump_regs },
@@ -903,6 +904,7 @@ static const struct {
 	{ "st_mac100", st_mac100_dump_regs },
 	{ "st_gmac", st_gmac_dump_regs },
 	{ "et131x", et131x_dump_regs },
+#endif
 };
 
 void dump_hex(FILE *file, const u8 *data, int len, int offset)
@@ -971,13 +973,13 @@ static int dump_eeprom(int geeprom_dump_raw, struct ethtool_drvinfo *info,
 		fwrite(ee->data, 1, ee->len, stdout);
 		return 0;
 	}
-
+#ifndef SMALL
 	if (!strncmp("natsemi", info->driver, ETHTOOL_BUSINFO_LEN)) {
 		return natsemi_dump_eeprom(info, ee);
 	} else if (!strncmp("tg3", info->driver, ETHTOOL_BUSINFO_LEN)) {
 		return tg3_dump_eeprom(info, ee);
 	}
-
+#endif
 	dump_hex(stdout, ee->data, ee->len, ee->offset);
 
 	return 0;
@@ -3633,6 +3635,7 @@ static int do_getmodule(struct cmd_context *ctx)
 			geeprom_dump_hex = 1;
 		} else if (!geeprom_dump_hex) {
 			switch (modinfo.type) {
+#ifndef SMALL
 			case ETH_MODULE_SFF_8079:
 				sff8079_show_all(eeprom->data);
 				break;
@@ -3640,6 +3643,7 @@ static int do_getmodule(struct cmd_context *ctx)
 				sff8079_show_all(eeprom->data);
 				sff8472_show_all(eeprom->data);
 				break;
+#endif
 			default:
 				geeprom_dump_hex = 1;
 				break;
-- 
1.8.3.2

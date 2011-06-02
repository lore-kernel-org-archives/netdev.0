From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCHv6] ethtool: Added FW dump support
Date: Thu,  2 Jun 2011 12:00:26 -0700
Message-ID: <1307041226-11998-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:38428 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1752361Ab1FBTHf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2011 15:07:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben,

Thanks. This time I actually committed ethtool.8.in.

-Anirban

-----

Added support to take FW dump via ethtool.

Changes from v5:
Actually added the ethtool.8.in diffs.
Took care of the return value in get dump data path.

Changes from v4:
Removed updates to ethtool-copy.h file
Added check to compare length of data to copy vs. actual data length copied
in dump path.
Fixed return values in error path.
Fixed documentation issues

Changes since v3:
Updated documentation for ethtool_dump data structure

Changes from v2:
Folded get dump flag and data into one option
Added man page support

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 ethtool.8.in |   20 ++++++++++
 ethtool.c    |  120 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 139 insertions(+), 1 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 42d923b..7b1cdf5 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -254,6 +254,15 @@ ethtool \- query or control network driver and hardware settings
 .I ethX
 .RB [ rx\-flow\-hash \ \*(FL \  \*(HO]
 .HP
+.B ethtool \-w|\-\-get\-dump
+.I ethX
+.RB [ data
+.IR filename ]
+.HP
+.B ethtool\ \-W|\-\-set\-dump
+.I ethX
+.BI \ N
+.HP
 .B ethtool \-x|\-\-show\-rxfh\-indir
 .I ethX
 .HP
@@ -595,6 +604,17 @@ other options are ignored.
 T}
 .TE
 .TP
+.B \-w \-\-get\-dump
+Retrieves and prints firmware dump for the specified network device.
+By default, it prints out the dump flag, version and length of the dump data.
+When
+.I data
+is indicated, then ethtool fetches the dump data and directs it to a
+.I file.
+.TP
+.B \-W \-\-set\-dump
+Sets the dump flag for the device.
+.TP
 .B \-x \-\-show\-rxfh\-indir
 Retrieves the receive flow hash indirection table.
 .TP
diff --git a/ethtool.c b/ethtool.c
index b6fa6bd..49614e2 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -28,6 +28,7 @@
 #include <stdlib.h>
 #include <sys/stat.h>
 #include <stdio.h>
+#include <stddef.h>
 #include <errno.h>
 #include <sys/utsname.h>
 #include <limits.h>
@@ -96,6 +97,8 @@ static int do_srxclsrule(int fd, struct ifreq *ifr);
 static int do_grxclsrule(int fd, struct ifreq *ifr);
 static int do_flash(int fd, struct ifreq *ifr);
 static int do_permaddr(int fd, struct ifreq *ifr);
+static int do_getfwdump(int fd, struct ifreq *ifr);
+static int do_setfwdump(int fd, struct ifreq *ifr);
 
 static int send_ioctl(int fd, struct ifreq *ifr);
 
@@ -128,6 +131,8 @@ static enum {
 	MODE_GCLSRULE,
 	MODE_FLASHDEV,
 	MODE_PERMADDR,
+	MODE_SET_DUMP,
+	MODE_GET_DUMP,
 } mode = MODE_GSET;
 
 static struct option {
@@ -255,6 +260,12 @@ static struct option {
 		"		[ rule %d ]\n"},
     { "-P", "--show-permaddr", MODE_PERMADDR,
 		"Show permanent hardware address" },
+    { "-w", "--get-dump", MODE_GET_DUMP,
+		"Get dump flag, data",
+		"		[ data FILENAME ]\n" },
+    { "-W", "--set-dump", MODE_SET_DUMP,
+		"Set dump flag of the device",
+		"		N\n"},
     { "-h", "--help", MODE_HELP, "Show this help" },
     { NULL, "--version", MODE_VERSION, "Show version number" },
     {}
@@ -385,6 +396,8 @@ static int flash_region = -1;
 static int msglvl_changed;
 static u32 msglvl_wanted = 0;
 static u32 msglvl_mask = 0;
+static u32 dump_flag;
+static char *dump_file = NULL;
 
 static int rx_class_rule_get = -1;
 static int rx_class_rule_del = -1;
@@ -777,7 +790,9 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_GCLSRULE) ||
 			    (mode == MODE_PHYS_ID) ||
 			    (mode == MODE_FLASHDEV) ||
-			    (mode == MODE_PERMADDR)) {
+			    (mode == MODE_PERMADDR) ||
+			    (mode == MODE_SET_DUMP) ||
+			    (mode == MODE_GET_DUMP)) {
 				devname = argp[i];
 				break;
 			}
@@ -799,6 +814,9 @@ static void parse_cmdline(int argc, char **argp)
 				flash_file = argp[i];
 				flash = 1;
 				break;
+			} else if (mode == MODE_SET_DUMP) {
+				dump_flag = get_u32(argp[i], 0);
+				break;
 			}
 			/* fallthrough */
 		default:
@@ -974,6 +992,21 @@ static void parse_cmdline(int argc, char **argp)
 				}
 				break;
 			}
+			if (mode == MODE_GET_DUMP) {
+				if (argc != i + 2) {
+					exit_bad_args();
+					break;
+				}
+				if (!strcmp(argp[i++], "data"))
+					dump_flag = ETHTOOL_GET_DUMP_DATA;
+				else {
+					exit_bad_args();
+					break;
+				}
+				dump_file = argp[i];
+				i = argc;
+				break;
+			}
 			if (mode != MODE_SSET)
 				exit_bad_args();
 			if (!strcmp(argp[i], "speed")) {
@@ -1898,6 +1931,10 @@ static int doit(void)
 		return do_flash(fd, &ifr);
 	} else if (mode == MODE_PERMADDR) {
 		return do_permaddr(fd, &ifr);
+	} else if (mode == MODE_GET_DUMP) {
+		return do_getfwdump(fd, &ifr);
+	} else if (mode == MODE_SET_DUMP) {
+		return do_setfwdump(fd, &ifr);
 	}
 
 	return 69;
@@ -3204,6 +3241,87 @@ static int do_grxclsrule(int fd, struct ifreq *ifr)
 	return err ? 1 : 0;
 }
 
+static int do_writefwdump(struct ethtool_dump *dump)
+{
+	int err = 0;
+	FILE *f;
+	size_t bytes;
+
+	f = fopen(dump_file, "wb+");
+
+	if (!f) {
+		fprintf(stderr, "Can't open file %s: %s\n",
+			dump_file, strerror(errno));
+		return 1;
+	}
+	bytes = fwrite(dump->data, 1, dump->len, f);
+	if (bytes != dump->len) {
+		fprintf(stderr, "Can not write all of dump data\n");
+		err = 1;
+	}
+	if (fclose(f)) {
+		fprintf(stderr, "Can't close file %s: %s\n",
+			dump_file, strerror(errno));
+		err = 1;
+	}
+	return err;
+}
+
+static int do_getfwdump(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_dump edata;
+	struct ethtool_dump *data;
+
+	edata.cmd = ETHTOOL_GET_DUMP_FLAG;
+
+	ifr->ifr_data = (caddr_t) &edata;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Can not get dump level\n");
+		return 1;
+	}
+	if (dump_flag != ETHTOOL_GET_DUMP_DATA) {
+		fprintf(stdout, "flag: %u, version: %u, length: %u\n",
+			edata.flag, edata.version, edata.len);
+		return 0;
+	}
+	data = calloc(1, offsetof(struct ethtool_dump, data) + edata.len);
+	if (!data) {
+		perror("Can not allocate enough memory\n");
+		return 1;
+	}
+	data->cmd = ETHTOOL_GET_DUMP_DATA;
+	data->len = edata.len;
+	ifr->ifr_data = (caddr_t) data;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Can not get dump data\n");
+		err = 1;
+		goto free;
+	}
+	err = do_writefwdump(data);
+free:
+	free(data);
+	return err;
+}
+
+static int do_setfwdump(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_dump dump;
+
+	dump.cmd = ETHTOOL_SET_DUMP;
+	dump.flag = dump_flag;
+	ifr->ifr_data = (caddr_t)&dump;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Can not set dump level\n");
+		return 1;
+	}
+	return 0;
+}
+
 static int send_ioctl(int fd, struct ifreq *ifr)
 {
 	return ioctl(fd, SIOCETHTOOL, ifr);
-- 
1.7.4.1


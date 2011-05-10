From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCHv2] ethtool: Allow ethtool to take FW dump
Date: Mon,  9 May 2011 18:02:29 -0700
Message-ID: <1304989352-24810-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:57369 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1755943Ab1EJBIs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 21:08:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take FW dump via ethtool.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 ethtool-copy.h |   28 +++++++++++++-
 ethtool.c      |  116 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 141 insertions(+), 3 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 22215e9..d6115c5 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -76,6 +76,31 @@ struct ethtool_drvinfo {
 	__u32	regdump_len;	/* Size of data from ETHTOOL_GREGS (bytes) */
 };
 
+/**
+ * struct ethtool_dump - used for retrieving, setting device dump
+ * @type: type of operation, get dump settings or data
+ * @version: FW version of the dump
+ * @flag: flag for dump setting
+ * @len: length of dump data
+ * @data: data collected for this command
+ */
+struct ethtool_dump {
+	__u32	cmd;
+	__u32	type;
+	__u32	version;
+	__u32	flag;
+	__u32	len;
+	__u8	data[0];
+};
+
+/*
+ * ethtool_dump_op_type - used to determine type of fetch, flag or data
+ */
+enum ethtool_dump_op_type {
+	ETHTOOL_DUMP_FLAG	= 0,
+	ETHTOOL_DUMP_DATA,
+};
+
 #define SOPASS_MAX	6
 /* wake-on-lan settings */
 struct ethtool_wolinfo {
@@ -654,7 +679,6 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
 #define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
 
-
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
 #define ETHTOOL_SSET		0x00000002 /* Set settings. */
@@ -717,6 +741,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
 #define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n table */
 #define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n table */
+#define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
+#define ETHTOOL_GET_DUMP	0x0000003f /* Get dump settings */
 
 #define ETHTOOL_GFEATURES	0x0000003a /* Get device offload settings */
 #define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings */
diff --git a/ethtool.c b/ethtool.c
index cfdac65..5b91326 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -28,6 +28,7 @@
 #include <sys/types.h>
 #include <string.h>
 #include <stdlib.h>
+#include <stddef.h>
 #include <sys/types.h>
 #include <sys/ioctl.h>
 #include <sys/stat.h>
@@ -110,6 +111,8 @@ static int do_srxntuple(int fd, struct ifreq *ifr);
 static int do_grxntuple(int fd, struct ifreq *ifr);
 static int do_flash(int fd, struct ifreq *ifr);
 static int do_permaddr(int fd, struct ifreq *ifr);
+static int do_getfwdump(int fd, struct ifreq *ifr);
+static int do_setfwdump(int fd, struct ifreq *ifr);
 
 static int send_ioctl(int fd, struct ifreq *ifr);
 
@@ -142,6 +145,8 @@ static enum {
 	MODE_GNTUPLE,
 	MODE_FLASHDEV,
 	MODE_PERMADDR,
+	MODE_SET_DUMP,
+	MODE_GET_DUMP,
 } mode = MODE_GSET;
 
 static struct option {
@@ -263,6 +268,12 @@ static struct option {
 		"Get Rx ntuple filters and actions\n" },
     { "-P", "--show-permaddr", MODE_PERMADDR,
 		"Show permanent hardware address" },
+    { "-w", "--get-dump", MODE_GET_DUMP,
+		"Get dump and options",
+		"		[ data FILENAME ]\n" },
+    { "-W", "--set-dump", MODE_SET_DUMP,
+		"Set dump flag",
+		"		dumpflag" " Dump flag for the device\n" },
     { "-h", "--help", MODE_HELP, "Show this help" },
     { NULL, "--version", MODE_VERSION, "Show version number" },
     {}
@@ -413,6 +424,9 @@ static int flash_region = -1;
 static int msglvl_changed;
 static u32 msglvl_wanted = 0;
 static u32 msglvl_mask = 0;
+static u32 dump_flag;
+static u32 dump_type;
+static char *dump_file = NULL;
 
 static enum {
 	ONLINE=0,
@@ -852,7 +866,9 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_GNTUPLE) ||
 			    (mode == MODE_PHYS_ID) ||
 			    (mode == MODE_FLASHDEV) ||
-			    (mode == MODE_PERMADDR)) {
+			    (mode == MODE_PERMADDR) ||
+			    (mode == MODE_SET_DUMP) ||
+			    (mode == MODE_GET_DUMP)) {
 				devname = argp[i];
 				break;
 			}
@@ -874,6 +890,9 @@ static void parse_cmdline(int argc, char **argp)
 				flash_file = argp[i];
 				flash = 1;
 				break;
+			} else if (mode == MODE_SET_DUMP) {
+				dump_flag = get_u32(argp[i], 0);
+				break;
 			}
 			/* fallthrough */
 		default:
@@ -1020,6 +1039,23 @@ static void parse_cmdline(int argc, char **argp)
 				}
 				break;
 			}
+			if (mode == MODE_GET_DUMP) {
+				if (argc != i + 2) {
+					exit_bad_args();
+					break;
+				}
+				if (!strcmp(argp[i], "data"))
+					dump_type = ETHTOOL_DUMP_DATA;
+				else {
+					exit_bad_args();
+					break;
+				}
+				i += 1;
+				dump_file = argp[i];
+				i = argc;
+fprintf(stdout, "file name: %s\n", dump_file);
+				break;
+			}
 			if (mode != MODE_SSET)
 				exit_bad_args();
 			if (!strcmp(argp[i], "speed")) {
@@ -2042,6 +2078,10 @@ static int doit(void)
 		return do_flash(fd, &ifr);
 	} else if (mode == MODE_PERMADDR) {
 		return do_permaddr(fd, &ifr);
+	} else if (mode == MODE_GET_DUMP) {
+		return do_getfwdump(fd, &ifr);
+	} else if (mode == MODE_SET_DUMP) {
+		return do_setfwdump(fd, &ifr);
 	}
 
 	return 69;
@@ -2679,7 +2719,6 @@ static int do_gregs(int fd, struct ifreq *ifr)
 		perror("Cannot get driver information");
 		return 72;
 	}
-
 	regs = calloc(1, sizeof(*regs)+drvinfo.regdump_len);
 	if (!regs) {
 		perror("Cannot allocate memory for register dump");
@@ -3241,6 +3280,79 @@ static int do_grxntuple(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static void do_writedump(struct ethtool_dump *dump)
+{
+	FILE *f;
+	size_t bytes;
+
+	f = fopen(dump_file, "wb+");
+
+	if (!f) {
+		fprintf(stderr, "Can't open file %s: %s\n",
+			dump_file, strerror(errno));
+		return;
+	}
+	bytes = fwrite(dump->data, 1, dump->len, f);
+	if (fclose(f))
+		fprintf(stderr, "Can't close file %s: %s\n",
+			dump_file, strerror(errno));
+}
+
+static int do_getfwdump(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_dump edata;
+	struct ethtool_dump *data;
+
+	edata.cmd = ETHTOOL_GET_DUMP;
+	edata.type = ETHTOOL_DUMP_FLAG;
+
+	ifr->ifr_data = (caddr_t) &edata;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Can not get dump level");
+		return 74;
+	}
+	if (dump_type == ETHTOOL_DUMP_FLAG) {
+		fprintf(stdout, "flag: %u, version: %u length: %u\n",
+			edata.flag, edata.version, edata.len);
+		return 0;
+	}
+	data = calloc(1, offsetof(struct ethtool_dump, data) + edata.len);
+	if (!data) {
+		perror("Can not allocate enough memory");
+		return 0;
+	}
+	data->cmd = ETHTOOL_GET_DUMP;
+	data->type = dump_type;
+	ifr->ifr_data = (caddr_t) data;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Can not get dump data\n");
+		goto free;
+	}
+	do_writedump(data);
+free:
+	free(data);
+	return 0;
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
+		perror("Can not set dump level");
+		return 74;
+	}
+	return 0;
+}
+
 static int send_ioctl(int fd, struct ifreq *ifr)
 {
 	return ioctl(fd, SIOCETHTOOL, ifr);
-- 
1.7.4.1


From: anirban.chakraborty@qlogic.com
Subject: [ethtool PATCH] FW dump support
Date: Mon,  2 May 2011 16:29:16 -0700
Message-ID: <1304378957-24123-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: --no-chain-reply-to@mv.qlogic.com, bhutchings@solarflare.com,
	davem@davemloft.net,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:35312 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1751151Ab1EBXfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2011 19:35:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Added support to take FW dump via ethtool.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 ethtool-copy.h |   17 ++++++++-
 ethtool.c      |  113 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 127 insertions(+), 3 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 5b45442..0c0e847 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -76,6 +76,19 @@ struct ethtool_drvinfo {
 	__u32	regdump_len;	/* Size of data from ETHTOOL_GREGS (bytes) */
 };
 
+/* dump struct
+ * cmd: commnad to identify type of operation
+ * flag: specify dump related options
+ * len: length of dumped data
+ * data: dump data
+ */
+struct ethtool_dump {
+	__u32	cmd;
+	__u32	flag;
+	__u32	len;
+	__u8	data[0];
+};
+
 #define SOPASS_MAX	6
 /* wake-on-lan settings */
 struct ethtool_wolinfo {
@@ -538,7 +551,6 @@ struct ethtool_flash {
 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
 };
 
-
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
 #define ETHTOOL_SSET		0x00000002 /* Set settings. */
@@ -599,6 +611,9 @@ struct ethtool_flash {
 #define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
 #define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n table */
 #define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n table */
+#define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
+#define ETHTOOL_GET_DUMP	0x0000003f /* Get dump settings */
+#define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.c b/ethtool.c
index cfdac65..1a826ae 100644
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
@@ -110,6 +111,9 @@ static int do_srxntuple(int fd, struct ifreq *ifr);
 static int do_grxntuple(int fd, struct ifreq *ifr);
 static int do_flash(int fd, struct ifreq *ifr);
 static int do_permaddr(int fd, struct ifreq *ifr);
+static int do_getdump(int fd, struct ifreq *ifr);
+static int do_getdumpdata(int fd, struct ifreq *ifr);
+static int do_setdump(int fd, struct ifreq *ifr);
 
 static int send_ioctl(int fd, struct ifreq *ifr);
 
@@ -142,6 +146,9 @@ static enum {
 	MODE_GNTUPLE,
 	MODE_FLASHDEV,
 	MODE_PERMADDR,
+	MODE_SET_DUMP,
+	MODE_GET_DUMP,
+	MODE_GET_DUMP_DATA,
 } mode = MODE_GSET;
 
 static struct option {
@@ -263,6 +270,12 @@ static struct option {
 		"Get Rx ntuple filters and actions\n" },
     { "-P", "--show-permaddr", MODE_PERMADDR,
 		"Show permanent hardware address" },
+    { "-W", "--get-dump", MODE_GET_DUMP,
+		"Get dump level\n" },
+    { "-Wd", "--get-dump-data", MODE_GET_DUMP_DATA,
+		"Get dump data", "FILENAME " "Name of the dump file\n" },
+    { "-w", "--set-dump", MODE_SET_DUMP,
+		"Set dump level", "DUMPLEVEL " "Dump level for the device\n" },
     { "-h", "--help", MODE_HELP, "Show this help" },
     { NULL, "--version", MODE_VERSION, "Show version number" },
     {}
@@ -413,6 +426,8 @@ static int flash_region = -1;
 static int msglvl_changed;
 static u32 msglvl_wanted = 0;
 static u32 msglvl_mask = 0;
+static u32 dump_flag;
+static char *dump_file = NULL;
 
 static enum {
 	ONLINE=0,
@@ -852,7 +867,10 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_GNTUPLE) ||
 			    (mode == MODE_PHYS_ID) ||
 			    (mode == MODE_FLASHDEV) ||
-			    (mode == MODE_PERMADDR)) {
+			    (mode == MODE_PERMADDR) ||
+			    (mode == MODE_SET_DUMP) ||
+			    (mode == MODE_GET_DUMP_DATA) ||
+			    (mode == MODE_GET_DUMP)) {
 				devname = argp[i];
 				break;
 			}
@@ -874,6 +892,12 @@ static void parse_cmdline(int argc, char **argp)
 				flash_file = argp[i];
 				flash = 1;
 				break;
+			} else if (mode == MODE_SET_DUMP) {
+				dump_flag = get_u32(argp[i], 0);
+				break;
+			} else if (mode == MODE_GET_DUMP_DATA) {
+				dump_file = argp[i];
+				break;
 			}
 			/* fallthrough */
 		default:
@@ -2042,6 +2066,12 @@ static int doit(void)
 		return do_flash(fd, &ifr);
 	} else if (mode == MODE_PERMADDR) {
 		return do_permaddr(fd, &ifr);
+	} else if (mode == MODE_GET_DUMP_DATA) {
+		return do_getdumpdata(fd, &ifr);
+	} else if (mode == MODE_GET_DUMP) {
+		return do_getdump(fd, &ifr);
+	} else if (mode == MODE_SET_DUMP) {
+		return do_setdump(fd, &ifr);
 	}
 
 	return 69;
@@ -2679,7 +2709,6 @@ static int do_gregs(int fd, struct ifreq *ifr)
 		perror("Cannot get driver information");
 		return 72;
 	}
-
 	regs = calloc(1, sizeof(*regs)+drvinfo.regdump_len);
 	if (!regs) {
 		perror("Cannot allocate memory for register dump");
@@ -3241,6 +3270,86 @@ static int do_grxntuple(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static void do_writedump(struct ethtool_dump *dump)
+{
+	FILE *f = fopen(dump_file, "wb+");
+	size_t bytes;
+
+	if (!f ) {
+		fprintf(stderr, "Can't open file %s: %s\n",
+			dump_file, strerror(errno));
+		return;
+	}
+
+	bytes = fwrite(dump->data, 1, dump->len, f);
+	fclose(f);
+}
+
+static int do_getdump(int fd, struct ifreq *ifr)
+{
+	struct ethtool_dump ddata;
+	int err;
+
+	ddata.cmd = ETHTOOL_GET_DUMP;
+	ifr->ifr_data = (caddr_t) &ddata;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Can not get dump flag");
+		return 74;
+	}
+	fprintf(stdout, "Dump flag: 0x%x\n", ddata.flag);
+	return 0;
+}
+
+static int do_getdumpdata(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_dump edata;
+	struct ethtool_dump *data;
+
+	edata.cmd = ETHTOOL_GET_DUMP;
+
+	ifr->ifr_data = (caddr_t) &edata;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Can not get dump level");
+		return 74;
+	}
+	data = calloc(1, offsetof(struct ethtool_dump, data)+edata.len);
+	if (!data) {
+		perror("Can not allocate enough memory");
+		return 0;
+	}
+	data->cmd = ETHTOOL_GET_DUMP_DATA;
+	data->len = edata.len;
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
+static int do_setdump(int fd, struct ifreq *ifr)
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


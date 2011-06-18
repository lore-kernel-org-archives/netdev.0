From: greearb@candelatech.com
Subject: [PATCH v2 2/2] ethtool:  Support enabling rx of errored frames.
Date: Sat, 18 Jun 2011 13:58:43 -0700
Message-ID: <1308430723-25028-2-git-send-email-greearb@candelatech.com>
References: <1308430723-25028-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54381 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000Ab1FRU66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 16:58:58 -0400
In-Reply-To: <1308430723-25028-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This can be useful when sniffing dodgy networks.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 c059852... 91ad2e6... M	ethtool-copy.h
:100644 100644 e2eca31... ca146fb... M	ethtool.8.in
:100644 100644 b97552c... 3179ad8... M	ethtool.c
 ethtool-copy.h |    2 ++
 ethtool.8.in   |   19 +++++++++++++++++++
 ethtool.c      |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 75 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index c059852..91ad2e6 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -753,6 +753,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
 #define ETHTOOL_GET_SAVE_RXFCS	0x00000041 /* Get RX Save Frame Checksum */
 #define ETHTOOL_SET_SAVE_RXFCS	0x00000042 /* Set RX Save Frame Checksum */
+#define ETHTOOL_GET_SAVE_RXERR	0x00000043 /* Get RX Save Errored Frames */
+#define ETHTOOL_SET_SAVE_RXERR	0x00000044 /* Set RX Save Errored Frames */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.8.in b/ethtool.8.in
index e2eca31..ca146fb 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -281,6 +281,13 @@ ethtool \- query or control network driver and hardware settings
 .I ethX
 .BI \ N
 .HP
+.B ethtool \-b|\-\-get\-save\-rxerr
+.I ethX
+.HP
+.B ethtool\ \-B|\-\-set\-save\-rxerr
+.I ethX
+.BI \ N
+.HP
 .B ethtool \-f|\-\-flash
 .I ethX
 .RI FILE
@@ -648,6 +655,18 @@ Configures the receive frame checksum flag.
 Frame Checksum will be appended to the end of the packet.  This
 can be useful when sniffing packets.
 .TP
+.B \-b \-\-show\-save\-rxerr
+Retrieves the receive save errored frames flag.
+.TP
+.B \-B \-\-set\-save\-rxerr
+Configures the receive save errored frames flag.
+.TP
+.B N
+1 means enable, 0 means disable.  When enabled, the NIC should
+receive all possible frames and pass them up the stack, including
+frames with bad Ethernet checksums, bad length, etc.
+This can be useful when sniffing packets.
+.TP
 .B \-f \-\-flash \ FILE
 Flash firmware image from the specified file to a region on the adapter.
 By default this will flash all the regions on the adapter.
diff --git a/ethtool.c b/ethtool.c
index b97552c..3179ad8 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -101,6 +101,8 @@ static int do_getfwdump(int fd, struct ifreq *ifr);
 static int do_setfwdump(int fd, struct ifreq *ifr);
 static int do_set_save_rxfcs(int fd, struct ifreq *ifr);
 static int do_get_save_rxfcs(int fd, struct ifreq *ifr);
+static int do_set_save_rxerr(int fd, struct ifreq *ifr);
+static int do_get_save_rxerr(int fd, struct ifreq *ifr);
 
 static int send_ioctl(int fd, struct ifreq *ifr);
 
@@ -137,6 +139,8 @@ static enum {
 	MODE_GET_DUMP,
 	MODE_SET_SAVE_RXFCS,
 	MODE_GET_SAVE_RXFCS,
+	MODE_SET_SAVE_RXERR,
+	MODE_GET_SAVE_RXERR,
 } mode = MODE_GSET;
 
 static struct option {
@@ -275,6 +279,11 @@ static struct option {
     { "-Z", "--set-save-rxfcs", MODE_SET_SAVE_RXFCS,
 		"Set Save RX-FCS flag of the device",
 		"		N\n"},
+    { "-b", "--get-save-rxerr", MODE_GET_SAVE_RXERR,
+		"Get Save RX-ERR flag" },
+    { "-B", "--set-save-rxerr", MODE_SET_SAVE_RXERR,
+		"Set Save RX-ERR flag of the device",
+		"		N\n"},
     { "-h", "--help", MODE_HELP, "Show this help" },
     { NULL, "--version", MODE_VERSION, "Show version number" },
     {}
@@ -408,6 +417,7 @@ static u32 msglvl_mask = 0;
 static u32 dump_flag;
 static char *dump_file = NULL;
 static u32 save_rxfcs_flag;
+static u32 save_rxerr_flag;
 
 static int rx_class_rule_get = -1;
 static int rx_class_rule_del = -1;
@@ -804,7 +814,9 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_SET_DUMP) ||
 			    (mode == MODE_GET_DUMP) ||
 			    (mode == MODE_SET_SAVE_RXFCS) ||
-			    (mode == MODE_GET_SAVE_RXFCS)) {
+			    (mode == MODE_GET_SAVE_RXFCS) ||
+			    (mode == MODE_SET_SAVE_RXERR) ||
+			    (mode == MODE_GET_SAVE_RXERR)) {
 				devname = argp[i];
 				break;
 			}
@@ -832,6 +844,9 @@ static void parse_cmdline(int argc, char **argp)
 			} else if (mode == MODE_SET_SAVE_RXFCS) {
 				save_rxfcs_flag = get_u32(argp[i], 0);
 				break;
+			} else if (mode == MODE_SET_SAVE_RXERR) {
+				save_rxerr_flag = get_u32(argp[i], 0);
+				break;
 			}
 			/* fallthrough */
 		default:
@@ -1954,6 +1969,10 @@ static int doit(void)
 		return do_get_save_rxfcs(fd, &ifr);
 	} else if (mode == MODE_SET_SAVE_RXFCS) {
 		return do_set_save_rxfcs(fd, &ifr);
+	} else if (mode == MODE_GET_SAVE_RXERR) {
+		return do_get_save_rxerr(fd, &ifr);
+	} else if (mode == MODE_SET_SAVE_RXERR) {
+		return do_set_save_rxerr(fd, &ifr);
 	}
 
 	return 69;
@@ -3375,6 +3394,40 @@ static int do_get_save_rxfcs(int fd, struct ifreq *ifr)
 	}
 }
 
+static int do_set_save_rxerr(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_value edata;
+
+	edata.cmd = ETHTOOL_SET_SAVE_RXERR;
+	edata.data = save_rxerr_flag;
+	ifr->ifr_data = (caddr_t)&edata;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Can not set Save RX ERR flag.\n");
+		return 1;
+	}
+	return 0;
+}
+
+static int do_get_save_rxerr(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_value edata;
+
+	edata.cmd = ETHTOOL_GET_SAVE_RXERR;
+	ifr->ifr_data = (caddr_t)&edata;
+	err = send_ioctl(fd, ifr);
+	if (err == 0) {
+		fprintf(stdout, "	Save RX-ERR %s\n",
+			edata.data ? "Enabled" : "Disabled");
+		return 0;
+	} else {
+		perror("Can not get Save RX ERR flag\n");
+		return 1;
+	}
+}
+
 static int send_ioctl(int fd, struct ifreq *ifr)
 {
 	return ioctl(fd, SIOCETHTOOL, ifr);
-- 
1.7.3.4


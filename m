From: greearb@candelatech.com
Subject: [PATCH v2 1/2] ethtool:  Support get/set rx-save-fcs flag.
Date: Sat, 18 Jun 2011 13:58:42 -0700
Message-ID: <1308430723-25028-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54379 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935Ab1FRU6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 16:58:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows users to receive the Ethernet frame checksum
on supported drivers.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---

v2:  Fix typo in man-page description.

:100644 100644 c7a18f7... c059852... M	ethtool-copy.h
:100644 100644 7b1cdf5... e2eca31... M	ethtool.8.in
:100644 100644 c189c78... b97552c... M	ethtool.c
 ethtool-copy.h |    2 ++
 ethtool.8.in   |   18 ++++++++++++++++++
 ethtool.c      |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 74 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index c7a18f7..c059852 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -751,6 +751,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GET_SAVE_RXFCS	0x00000041 /* Get RX Save Frame Checksum */
+#define ETHTOOL_SET_SAVE_RXFCS	0x00000042 /* Set RX Save Frame Checksum */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.8.in b/ethtool.8.in
index 7b1cdf5..e2eca31 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -274,6 +274,13 @@ ethtool \- query or control network driver and hardware settings
 .IR W1
 .RB ...\ ]
 .HP
+.B ethtool \-z|\-\-get\-save\-rxfcs
+.I ethX
+.HP
+.B ethtool\ \-Z|\-\-set\-save\-rxfcs
+.I ethX
+.BI \ N
+.HP
 .B ethtool \-f|\-\-flash
 .I ethX
 .RI FILE
@@ -630,6 +637,17 @@ Sets the receive flow hash indirection table to spread flows between
 receive queues according to the given weights.  The sum of the weights
 must be non-zero and must not exceed the size of the indirection table.
 .TP
+.B \-z \-\-show\-save\-rxfcs
+Retrieves the receive frame checksum flag.
+.TP
+.B \-Z \-\-set\-save\-rxcfs
+Configures the receive frame checksum flag.
+.TP
+.B N
+1 means enable, 0 means disable.  When enabled, the 4-byte
+Frame Checksum will be appended to the end of the packet.  This
+can be useful when sniffing packets.
+.TP
 .B \-f \-\-flash \ FILE
 Flash firmware image from the specified file to a region on the adapter.
 By default this will flash all the regions on the adapter.
diff --git a/ethtool.c b/ethtool.c
index c189c78..b97552c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -99,6 +99,8 @@ static int do_flash(int fd, struct ifreq *ifr);
 static int do_permaddr(int fd, struct ifreq *ifr);
 static int do_getfwdump(int fd, struct ifreq *ifr);
 static int do_setfwdump(int fd, struct ifreq *ifr);
+static int do_set_save_rxfcs(int fd, struct ifreq *ifr);
+static int do_get_save_rxfcs(int fd, struct ifreq *ifr);
 
 static int send_ioctl(int fd, struct ifreq *ifr);
 
@@ -133,6 +135,8 @@ static enum {
 	MODE_PERMADDR,
 	MODE_SET_DUMP,
 	MODE_GET_DUMP,
+	MODE_SET_SAVE_RXFCS,
+	MODE_GET_SAVE_RXFCS,
 } mode = MODE_GSET;
 
 static struct option {
@@ -266,6 +270,11 @@ static struct option {
     { "-W", "--set-dump", MODE_SET_DUMP,
 		"Set dump flag of the device",
 		"		N\n"},
+    { "-z", "--get-save-rxfcs", MODE_GET_SAVE_RXFCS,
+		"Get Save RX-FCS flag" },
+    { "-Z", "--set-save-rxfcs", MODE_SET_SAVE_RXFCS,
+		"Set Save RX-FCS flag of the device",
+		"		N\n"},
     { "-h", "--help", MODE_HELP, "Show this help" },
     { NULL, "--version", MODE_VERSION, "Show version number" },
     {}
@@ -398,6 +407,7 @@ static u32 msglvl_wanted = 0;
 static u32 msglvl_mask = 0;
 static u32 dump_flag;
 static char *dump_file = NULL;
+static u32 save_rxfcs_flag;
 
 static int rx_class_rule_get = -1;
 static int rx_class_rule_del = -1;
@@ -792,7 +802,9 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_FLASHDEV) ||
 			    (mode == MODE_PERMADDR) ||
 			    (mode == MODE_SET_DUMP) ||
-			    (mode == MODE_GET_DUMP)) {
+			    (mode == MODE_GET_DUMP) ||
+			    (mode == MODE_SET_SAVE_RXFCS) ||
+			    (mode == MODE_GET_SAVE_RXFCS)) {
 				devname = argp[i];
 				break;
 			}
@@ -817,6 +829,9 @@ static void parse_cmdline(int argc, char **argp)
 			} else if (mode == MODE_SET_DUMP) {
 				dump_flag = get_u32(argp[i], 0);
 				break;
+			} else if (mode == MODE_SET_SAVE_RXFCS) {
+				save_rxfcs_flag = get_u32(argp[i], 0);
+				break;
 			}
 			/* fallthrough */
 		default:
@@ -1935,6 +1950,10 @@ static int doit(void)
 		return do_getfwdump(fd, &ifr);
 	} else if (mode == MODE_SET_DUMP) {
 		return do_setfwdump(fd, &ifr);
+	} else if (mode == MODE_GET_SAVE_RXFCS) {
+		return do_get_save_rxfcs(fd, &ifr);
+	} else if (mode == MODE_SET_SAVE_RXFCS) {
+		return do_set_save_rxfcs(fd, &ifr);
 	}
 
 	return 69;
@@ -3322,6 +3341,40 @@ static int do_setfwdump(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static int do_set_save_rxfcs(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_value edata;
+
+	edata.cmd = ETHTOOL_SET_SAVE_RXFCS;
+	edata.data = save_rxfcs_flag;
+	ifr->ifr_data = (caddr_t)&edata;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Can not set Save RX FCS level\n");
+		return 1;
+	}
+	return 0;
+}
+
+static int do_get_save_rxfcs(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_value edata;
+
+	edata.cmd = ETHTOOL_GET_SAVE_RXFCS;
+	ifr->ifr_data = (caddr_t)&edata;
+	err = send_ioctl(fd, ifr);
+	if (err == 0) {
+		fprintf(stdout, "	Save RX-FCS %s\n",
+			edata.data ? "Enabled" : "Disabled");
+		return 0;
+	} else {
+		perror("Can not get Save RX FCS flag\n");
+		return 1;
+	}
+}
+
 static int send_ioctl(int fd, struct ifreq *ifr)
 {
 	return ioctl(fd, SIOCETHTOOL, ifr);
-- 
1.7.3.4


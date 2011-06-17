From: greearb@candelatech.com
Subject: [RFC] ethtool:  Support get/set rx-save-fcs flag.
Date: Thu, 16 Jun 2011 22:25:05 -0700
Message-ID: <1308288305-11582-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35058 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754820Ab1FQFZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 01:25:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows users to receive the Ethernet frame checksum
on supported drivers.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 c7a18f7... 408b027... M	ethtool-copy.h
:100644 100644 7b1cdf5... 66a00d5... M	ethtool.8.in
:100644 100644 c189c78... 5e2d6eb... M	ethtool.c
 ethtool-copy.h |    2 ++
 ethtool.8.in   |   18 ++++++++++++++++++
 ethtool.c      |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 74 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index c7a18f7..408b027 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -751,6 +751,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GETRXFCS	0x00000041 /* Get RX Save Frame Checksum */
+#define ETHTOOL_SETRXFCS	0x00000042 /* Set RX Save Frame Checksum */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.8.in b/ethtool.8.in
index 7b1cdf5..66a00d5 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -274,6 +274,13 @@ ethtool \- query or control network driver and hardware settings
 .IR W1
 .RB ...\ ]
 .HP
+.B ethtool \-z|\-\-get\-rxfcs
+.I ethX
+.HP
+.B ethtool\ \-Z|\-\-set\-rxfcs
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
+.B \-z \-\-show\-rxfcs
+Retrieves the receive frame checksum flag.
+.TP
+.B \-Z \-\-set\-rxcfs
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
index c189c78..5e2d6eb 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -99,6 +99,8 @@ static int do_flash(int fd, struct ifreq *ifr);
 static int do_permaddr(int fd, struct ifreq *ifr);
 static int do_getfwdump(int fd, struct ifreq *ifr);
 static int do_setfwdump(int fd, struct ifreq *ifr);
+static int do_srxfcs(int fd, struct ifreq *ifr);
+static int do_grxfcs(int fd, struct ifreq *ifr);
 
 static int send_ioctl(int fd, struct ifreq *ifr);
 
@@ -133,6 +135,8 @@ static enum {
 	MODE_PERMADDR,
 	MODE_SET_DUMP,
 	MODE_GET_DUMP,
+	MODE_SET_RXFCS,
+	MODE_GET_RXFCS,
 } mode = MODE_GSET;
 
 static struct option {
@@ -266,6 +270,11 @@ static struct option {
     { "-W", "--set-dump", MODE_SET_DUMP,
 		"Set dump flag of the device",
 		"		N\n"},
+    { "-z", "--get-rxfcs", MODE_GET_RXFCS,
+		"Get RX-FCS flag" },
+    { "-Z", "--set-rxfcs", MODE_SET_RXFCS,
+		"Set RX-FCS flag of the device",
+		"		N\n"},
     { "-h", "--help", MODE_HELP, "Show this help" },
     { NULL, "--version", MODE_VERSION, "Show version number" },
     {}
@@ -398,6 +407,7 @@ static u32 msglvl_wanted = 0;
 static u32 msglvl_mask = 0;
 static u32 dump_flag;
 static char *dump_file = NULL;
+static u32 rxfcs_flag;
 
 static int rx_class_rule_get = -1;
 static int rx_class_rule_del = -1;
@@ -792,7 +802,9 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_FLASHDEV) ||
 			    (mode == MODE_PERMADDR) ||
 			    (mode == MODE_SET_DUMP) ||
-			    (mode == MODE_GET_DUMP)) {
+			    (mode == MODE_GET_DUMP) ||
+			    (mode == MODE_SET_RXFCS) ||
+			    (mode == MODE_GET_RXFCS)) {
 				devname = argp[i];
 				break;
 			}
@@ -817,6 +829,9 @@ static void parse_cmdline(int argc, char **argp)
 			} else if (mode == MODE_SET_DUMP) {
 				dump_flag = get_u32(argp[i], 0);
 				break;
+			} else if (mode == MODE_SET_RXFCS) {
+				rxfcs_flag = get_u32(argp[i], 0);
+				break;
 			}
 			/* fallthrough */
 		default:
@@ -1935,6 +1950,10 @@ static int doit(void)
 		return do_getfwdump(fd, &ifr);
 	} else if (mode == MODE_SET_DUMP) {
 		return do_setfwdump(fd, &ifr);
+	} else if (mode == MODE_GET_RXFCS) {
+		return do_grxfcs(fd, &ifr);
+	} else if (mode == MODE_SET_RXFCS) {
+		return do_srxfcs(fd, &ifr);
 	}
 
 	return 69;
@@ -3322,6 +3341,40 @@ static int do_setfwdump(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static int do_srxfcs(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_value edata;
+
+	edata.cmd = ETHTOOL_SETRXFCS;
+	edata.data = rxfcs_flag;
+	ifr->ifr_data = (caddr_t)&edata;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Can not set RX FCS level\n");
+		return 1;
+	}
+	return 0;
+}
+
+static int do_grxfcs(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_value edata;
+
+	edata.cmd = ETHTOOL_GETRXFCS;
+	ifr->ifr_data = (caddr_t)&edata;
+	err = send_ioctl(fd, ifr);
+	if (err == 0) {
+		fprintf(stdout, "	RX-FCS %s\n",
+			edata.data ? "Enabled" : "Disabled");
+		return 0;
+	} else {
+		perror("Can not get RX FCS level.\n");
+		return 1;
+	}
+}
+
 static int send_ioctl(int fd, struct ifreq *ifr)
 {
 	return ioctl(fd, SIOCETHTOOL, ifr);
-- 
1.7.3.4


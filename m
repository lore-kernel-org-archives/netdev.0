From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH] ethtool: Add "-f" option to flash firmware image to a
	network device.
Date: Wed, 5 Aug 2009 18:01:45 +0530
Message-ID: <20090805123143.GA6592@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:7914 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932841AbZHEMbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 08:31:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Attached  is a patch for ethtool utility to add a new "-f" option.
This will enable flashing a firmware image to a network interface.

Usage:
ethtool -f <interface name>

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 ethtool-copy.h |    1 +
 ethtool.c      |   22 +++++++++++++++++++++-
 2 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3ca4e2c..49b741b 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -338,6 +338,7 @@ struct ethtool_rxnfc {
 #define	ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
 #define ETHTOOL_GGRO		0x0000002b /* Get GRO enable (ethtool_value) */
 #define ETHTOOL_SGRO		0x0000002c /* Set GRO enable (ethtool_value) */
+#define ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.c b/ethtool.c
index 0110682..fedb3a2 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -77,6 +77,7 @@ static char *unparse_rxfhashopts(u64 opts);
 static int dump_rxfhash(int fhash, u64 val);
 static int do_srxclass(int fd, struct ifreq *ifr);
 static int do_grxclass(int fd, struct ifreq *ifr);
+static int do_flash(int fd, struct ifreq *ifr);
 static int send_ioctl(int fd, struct ifreq *ifr);
 
 static enum {
@@ -101,6 +102,7 @@ static enum {
 	MODE_GSTATS,
 	MODE_GNFC,
 	MODE_SNFC,
+	MODE_FLASHDEV,
 } mode = MODE_GSET;
 
 static struct option {
@@ -192,6 +194,7 @@ static struct option {
 		"classification options",
 		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
 		"tcp6|udp6|ah6|sctp6 p|m|v|t|s|d|f|n|r... ]\n" },
+    { "-f", "--flash", MODE_FLASHDEV, "Flash firmware to device" },
     { "-h", "--help", MODE_HELP, "Show this help" },
     {}
 };
@@ -496,7 +499,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_GSTATS) ||
 			    (mode == MODE_GNFC) ||
 			    (mode == MODE_SNFC) ||
-			    (mode == MODE_PHYS_ID)) {
+			    (mode == MODE_PHYS_ID) ||
+			    (mode == MODE_FLASHDEV)) {
 				devname = argp[i];
 				break;
 			}
@@ -1504,6 +1508,8 @@ static int doit(void)
 		return do_grxclass(fd, &ifr);
 	} else if (mode == MODE_SNFC) {
 		return do_srxclass(fd, &ifr);
+	} else if (mode == MODE_FLASHDEV) {
+		return do_flash(fd, &ifr);
 	}
 
 	return 69;
@@ -2398,6 +2404,20 @@ static int do_grxclass(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static int do_flash(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_value ecmd;
+
+	ecmd.cmd = ETHTOOL_FLASHDEV;
+	ifr->ifr_data = (caddr_t)&ecmd;
+	err = send_ioctl(fd, ifr);
+	if (err < 0)
+		perror("Flashing failed");
+
+	return err;
+}
+
 static int send_ioctl(int fd, struct ifreq *ifr)
 {
 	return ioctl(fd, SIOCETHTOOL, ifr);
-- 
1.6.0.4


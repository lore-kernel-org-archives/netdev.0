From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH] Add "-f" option to flash a firmware image from the
	specified file to a device.
Date: Fri, 14 Aug 2009 23:03:04 +0530
Message-ID: <20090814173247.GA25648@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:20112 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750827AbZHNRc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 13:32:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new "-f" option to the ethtool utility
to flash a firmware image to a network device. The filename is passed as a
command line argument. This filename is passed to the network driver which will flash the image on the chip using the request_firmware path.

Usage:
ethtool -f <interface name> <filename of firmware image>

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 ethtool-copy.h |    7 +++++++
 ethtool.c      |   45 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 51 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3ca4e2c..bd429e7 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -272,6 +272,12 @@ struct ethtool_perm_addr {
 	__u8	data[0];
 };
 
+/* for passing firmware flashing related parameters */
+struct ethtool_flash {
+	__u32	cmd;
+	__u8	*data;
+};
+
 /* boolean flags controlling per-interface behavior characteristics.
  * When reading, the flag indicates whether or not a certain behavior
  * is enabled/present.  When writing, the flag indicates whether
@@ -338,6 +344,7 @@ struct ethtool_rxnfc {
 #define	ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
 #define ETHTOOL_GGRO		0x0000002b /* Get GRO enable (ethtool_value) */
 #define ETHTOOL_SGRO		0x0000002c /* Set GRO enable (ethtool_value) */
+#define ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.c b/ethtool.c
index 0110682..c39b19b 100644
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
@@ -192,6 +194,8 @@ static struct option {
 		"classification options",
 		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
 		"tcp6|udp6|ah6|sctp6 p|m|v|t|s|d|f|n|r... ]\n" },
+    { "-f", "--flash", MODE_FLASHDEV, "FILENAME\t" "Flash firmware image",
+		"			from the specified file to device\n"},
     { "-h", "--help", MODE_HELP, "Show this help" },
     {}
 };
@@ -304,6 +308,7 @@ static int rx_fhash_get = 0;
 static int rx_fhash_set = 0;
 static u32 rx_fhash_val = 0;
 static int rx_fhash_changed = 0;
+static char *flash_file = NULL;
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -496,7 +501,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_GSTATS) ||
 			    (mode == MODE_GNFC) ||
 			    (mode == MODE_SNFC) ||
-			    (mode == MODE_PHYS_ID)) {
+			    (mode == MODE_PHYS_ID) ||
+			    (mode == MODE_FLASHDEV)) {
 				devname = argp[i];
 				break;
 			}
@@ -516,6 +522,9 @@ static void parse_cmdline(int argc, char **argp)
 				if (phys_id_time < 0)
 					show_usage(1);
 				break;
+			} else if (mode == MODE_FLASHDEV) {
+				flash_file = argp[i];
+				break;
 			}
 			/* fallthrough */
 		default:
@@ -1504,6 +1513,8 @@ static int doit(void)
 		return do_grxclass(fd, &ifr);
 	} else if (mode == MODE_SNFC) {
 		return do_srxclass(fd, &ifr);
+	} else if (mode == MODE_FLASHDEV) {
+		return do_flash(fd, &ifr);
 	}
 
 	return 69;
@@ -2398,6 +2409,38 @@ static int do_grxclass(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static int do_flash(int fd, struct ifreq *ifr)
+{
+	struct ethtool_flash efl;
+	int err;
+	char path[256] = "/lib/firmware/";
+	FILE *f;
+
+	if (!flash_file) {
+		fprintf(stdout, "Missing filename argument\n");
+		show_usage(1);
+		return -1;
+	}
+
+	strcat(path, flash_file);
+
+	f = fopen(path, "r");
+	if (!f) {
+		perror(path);
+		return -1;
+	}
+	fclose(f);
+
+	efl.cmd = ETHTOOL_FLASHDEV;
+	efl.data = (u8 *)flash_file;
+	ifr->ifr_data = (caddr_t)&efl;
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


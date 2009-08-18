From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH] ethtool: Add "-f" option to flash a firmware image from
	the specified file to a device.
Date: Tue, 18 Aug 2009 16:55:34 +0530
Message-ID: <20090818112522.GA22134@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:13337 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752854AbZHRLZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 07:25:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new "-f" option to the ethtool utility
to flash a firmware image specified by a file, to a network device.
The filename is passed to the network driver which will flash the image
on the chip using the request_firmware path.
The region to be flashed - like redboot, phy can be specified as an argument,
which will be passed to the driver.
More options for other flash regions can be added in future.
The default behavior is to flash all the regions on the chip.

Usage:
ethtool -f <interface name> <filename of firmware image>

ethtool -f <interface name> <filename of firmware image> [ all|redboot|phy ]

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 ethtool-copy.h |   16 ++++++++++++
 ethtool.c      |   71 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 86 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3ca4e2c..a7d11fb 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -272,6 +272,21 @@ struct ethtool_perm_addr {
 	__u8	data[0];
 };
 
+#define ETHTOOL_FLASH_MAX_FILENAME	128
+#define ETHTOOL_FLASH_OP_TYPE_SIZE	32
+enum ethtool_flash_op_type {
+	ETHTOOL_FLASH_ALL		= 0,
+	ETHTOOL_FLASH_PHY,
+	ETHTOOL_FLASH_REDBOOT,
+};
+
+/* for passing firmware flashing related parameters */
+struct ethtool_flash {
+	__u32	cmd;
+	__u32	op_type;
+	char	data[256];
+};
+
 /* boolean flags controlling per-interface behavior characteristics.
  * When reading, the flag indicates whether or not a certain behavior
  * is enabled/present.  When writing, the flag indicates whether
@@ -338,6 +353,7 @@ struct ethtool_rxnfc {
 #define	ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
 #define ETHTOOL_GGRO		0x0000002b /* Get GRO enable (ethtool_value) */
 #define ETHTOOL_SGRO		0x0000002c /* Set GRO enable (ethtool_value) */
+#define ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.c b/ethtool.c
index 0110682..d73ddc4 100644
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
@@ -192,6 +194,9 @@ static struct option {
 		"classification options",
 		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
 		"tcp6|udp6|ah6|sctp6 p|m|v|t|s|d|f|n|r... ]\n" },
+    { "-f", "--flash", MODE_FLASHDEV, "FILENAME " "Flash firmware image "
+		"from the specified file to device",
+		"		[ all|redboot|phy ]\n" },
     { "-h", "--help", MODE_HELP, "Show this help" },
     {}
 };
@@ -304,6 +309,9 @@ static int rx_fhash_get = 0;
 static int rx_fhash_set = 0;
 static u32 rx_fhash_val = 0;
 static int rx_fhash_changed = 0;
+static char flash_file[ETHTOOL_FLASH_MAX_FILENAME];
+static int flash = -1;
+static int flash_op = -1;
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -496,7 +504,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_GSTATS) ||
 			    (mode == MODE_GNFC) ||
 			    (mode == MODE_SNFC) ||
-			    (mode == MODE_PHYS_ID)) {
+			    (mode == MODE_PHYS_ID) ||
+			    (mode == MODE_FLASHDEV)) {
 				devname = argp[i];
 				break;
 			}
@@ -516,6 +525,10 @@ static void parse_cmdline(int argc, char **argp)
 				if (phys_id_time < 0)
 					show_usage(1);
 				break;
+			} else if (mode == MODE_FLASHDEV) {
+				sprintf(flash_file, "%s", argp[i]);
+				flash = 1;
+				break;
 			}
 			/* fallthrough */
 		default:
@@ -590,6 +603,17 @@ static void parse_cmdline(int argc, char **argp)
 					show_usage(1);
 				break;
 			}
+			if (mode == MODE_FLASHDEV) {
+				if (!strcmp(argp[i], "redboot"))
+					flash_op = ETHTOOL_FLASH_REDBOOT;
+				else if (!strcmp(argp[i], "phy"))
+					flash_op = ETHTOOL_FLASH_PHY;
+				else if (!strcmp(argp[i], "all"))
+					flash_op = ETHTOOL_FLASH_ALL;
+				else
+					show_usage(1);
+				break;
+			}
 			if (mode == MODE_SNFC) {
 				if (!strcmp(argp[i], "rx-flow-hash")) {
 					i += 1;
@@ -1504,6 +1528,8 @@ static int doit(void)
 		return do_grxclass(fd, &ifr);
 	} else if (mode == MODE_SNFC) {
 		return do_srxclass(fd, &ifr);
+	} else if (mode == MODE_FLASHDEV) {
+		return do_flash(fd, &ifr);
 	}
 
 	return 69;
@@ -2398,6 +2424,49 @@ static int do_grxclass(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static int do_flash(int fd, struct ifreq *ifr)
+{
+	struct ethtool_flash efl;
+	int err;
+	char path[ETHTOOL_FLASH_MAX_FILENAME * 2] = "/lib/firmware/";
+	FILE *f;
+
+	if (flash < 0) {
+		fprintf(stdout, "Missing filename argument\n");
+		show_usage(1);
+		return -EPERM;
+	}
+
+	strcat(path, flash_file);
+
+	if (strlen(flash_file) > ETHTOOL_FLASH_MAX_FILENAME) {
+		fprintf(stdout, "Filename too long\n");
+		return -EINVAL;
+	}
+
+	f = fopen(path, "r");
+	if (!f) {
+		perror(path);
+		return -ENOENT;
+	}
+	fclose(f);
+
+	efl.cmd = ETHTOOL_FLASHDEV;
+	sprintf(efl.data, "%s", flash_file);
+
+	if (flash_op < 0)
+		efl.op_type = ETHTOOL_FLASH_ALL;
+	else
+		efl.op_type = flash_op;
+
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


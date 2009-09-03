From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH] ethtool: Add a new ethtool option to flash a firmware
	image from the specified file to a device.
Date: Thu, 3 Sep 2009 08:33:08 +0530
Message-ID: <20090903030258.GA19401@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:27160 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754132AbZICDCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 23:02:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new "-f" option to the ethtool utility
to flash a firmware image specified by a file, to a network device.
The filename is passed to the network driver which will flash the image
on the chip using the request_firmware path.

The region "on the chip" to be flashed can be specified by an option.
It is upto the device driver to enumerate the region number passed by ethtool,
to the region to be flashed.

The default behavior is to flash all the regions on the chip.

Usage:
ethtool -f <interface name> <filename of firmware image>

ethtool -f <interface name> <filename of firmware image> [ REGION-NUMBER-TO-FLASH ]

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 ethtool-copy.h |   13 +++++++++++++
 ethtool.8      |   15 +++++++++++++++
 ethtool.c      |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 82 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3ca4e2c..66429e5 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -272,6 +272,18 @@ struct ethtool_perm_addr {
 	__u8	data[0];
 };
 
+#define ETHTOOL_FLASH_MAX_FILENAME	128
+enum ethtool_flash_op_type {
+	ETHTOOL_FLASH_ALL_REGIONS	= 0,
+};
+
+/* for passing firmware flashing related parameters */
+struct ethtool_flash {
+	__u32	cmd;
+	__u32	region;
+	char	data[ETHTOOL_FLASH_MAX_FILENAME];
+};
+
 /* boolean flags controlling per-interface behavior characteristics.
  * When reading, the flag indicates whether or not a certain behavior
  * is enabled/present.  When writing, the flag indicates whether
@@ -338,6 +350,7 @@ struct ethtool_rxnfc {
 #define	ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
 #define ETHTOOL_GGRO		0x0000002b /* Get GRO enable (ethtool_value) */
 #define ETHTOOL_SGRO		0x0000002c /* Set GRO enable (ethtool_value) */
+#define ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.8 b/ethtool.8
index 178f6ea..e42da55 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -207,6 +207,11 @@ ethtool \- Display or change ethernet card settings
 .I ethX
 .RB [ rx-flow-hash \ \*(FL
 .RB \ \*(HO]
+
+.B ethtool \-f|\-\-flash
+.I ethX
+.RI FILE
+.RI [ N ]
 .SH DESCRIPTION
 .BI ethtool
 is used for querying settings of an ethernet device and changing them.
@@ -501,6 +506,16 @@ Hash on bytes 2 and 3 of the Layer 4 header of the rx packet.
 Discard all packets of this flow type. When this option is set, all other options are ignored.
 .PD
 .RE
+.TP
+.B \-f \-\-flash \ FILE
+Flash firmware image from the specified file to a region on the adapter.
+By default this will flash all the regions on the adapter.
+.TP
+.B N
+A number to identify flash region where the image should be flashed.
+Default region is 0 which denotes all regions in the flash.
+.PD
+.RE
 .SH BUGS
 Not supported (in part or whole) on all ethernet drivers.
 .SH AUTHOR
diff --git a/ethtool.c b/ethtool.c
index 0110682..6b21bf2 100644
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
+		"from the specified file to a region on the device",
+		"		[ REGION-NUMBER-TO-FLASH ]\n" },
     { "-h", "--help", MODE_HELP, "Show this help" },
     {}
 };
@@ -304,6 +309,9 @@ static int rx_fhash_get = 0;
 static int rx_fhash_set = 0;
 static u32 rx_fhash_val = 0;
 static int rx_fhash_changed = 0;
+static char *flash_file = NULL;
+static int flash = -1;
+static int flash_region = -1;
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
+				flash_file = argp[i];
+				flash = 1;
+				break;
 			}
 			/* fallthrough */
 		default:
@@ -590,6 +603,12 @@ static void parse_cmdline(int argc, char **argp)
 					show_usage(1);
 				break;
 			}
+			if (mode == MODE_FLASHDEV) {
+				flash_region = strtol(argp[i], NULL, 0);
+				if ((flash_region < 0))
+					show_usage(1);
+				break;
+			}
 			if (mode == MODE_SNFC) {
 				if (!strcmp(argp[i], "rx-flow-hash")) {
 					i += 1;
@@ -1504,6 +1523,8 @@ static int doit(void)
 		return do_grxclass(fd, &ifr);
 	} else if (mode == MODE_SNFC) {
 		return do_srxclass(fd, &ifr);
+	} else if (mode == MODE_FLASHDEV) {
+		return do_flash(fd, &ifr);
 	}
 
 	return 69;
@@ -2398,6 +2419,38 @@ static int do_grxclass(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static int do_flash(int fd, struct ifreq *ifr)
+{
+	struct ethtool_flash efl;
+	int err;
+
+	if (flash < 0) {
+		fprintf(stdout, "Missing filename argument\n");
+		show_usage(1);
+		return 98;
+	}
+
+	if (strlen(flash_file) > ETHTOOL_FLASH_MAX_FILENAME - 1) {
+		fprintf(stdout, "Filename too long\n");
+		return 99;
+	}
+
+	efl.cmd = ETHTOOL_FLASHDEV;
+	strcpy(efl.data, flash_file);
+
+	if (flash_region < 0)
+		efl.region = ETHTOOL_FLASH_ALL_REGIONS;
+	else
+		efl.region = flash_region;
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


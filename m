From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] ethtool: RXHASH flag support
Date: Mon, 29 Mar 2010 17:53:52 -0700
Message-ID: <20100329175352.38008e05@nehalam>
References: <20100328154448.701c89ee@nehalam>
	<20100329174727.4654e19c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48930 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752971Ab0C3AyI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 20:54:08 -0400
In-Reply-To: <20100329174727.4654e19c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for RXHASH flag in ethtool offload.
Update to current net-next sanitized version of ethtool.h

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 ethtool-copy.h |   32 +++++++++++++++++++++++++-------
 ethtool.8      |    4 ++++
 ethtool.c      |   42 +++++++++++++++++++++++++++++++++++++-----
 3 files changed, 66 insertions(+), 12 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 8681f5e..0cf8f33 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -36,7 +36,7 @@ struct ethtool_cmd {
 	__u32	reserved[2];
 };
 
-static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
+static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 						__u32 speed)
 {
 
@@ -44,7 +44,7 @@ static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 	ep->speed_hi = (__u16)(speed >> 16);
 }
 
-static inline __u32 ethtool_cmd_speed(struct ethtool_cmd *ep)
+static __inline__ __u32 ethtool_cmd_speed(struct ethtool_cmd *ep)
 {
 	return (ep->speed_hi << 16) | ep->speed;
 }
@@ -61,6 +61,13 @@ struct ethtool_drvinfo {
 				/* For PCI devices, use pci_name(pci_dev). */
 	char	reserved1[32];
 	char	reserved2[12];
+				/*
+				 * Some struct members below are filled in
+				 * using ops->get_sset_count().  Obtaining
+				 * this info from ethtool_drvinfo is now
+				 * deprecated; Use ETHTOOL_GSSET_INFO
+				 * instead.
+				 */
 	__u32	n_priv_flags;	/* number of flags valid in ETHTOOL_GPFLAGS */
 	__u32	n_stats;	/* number of u64's from ETHTOOL_GSTATS */
 	__u32	testinfo_len;
@@ -253,6 +260,17 @@ struct ethtool_gstrings {
 	__u8	data[0];
 };
 
+struct ethtool_sset_info {
+	__u32	cmd;		/* ETHTOOL_GSSET_INFO */
+	__u32	reserved;
+	__u64	sset_mask;	/* input: each bit selects an sset to query */
+				/* output: each bit a returned sset */
+	__u32	data[0];	/* ETH_SS_xxx count, in order, based on bits
+				   in sset_mask.  One bit implies one
+				   __u32, two bits implies two
+				   __u32's, etc. */
+};
+
 enum ethtool_test_flags {
 	ETH_TEST_FL_OFFLINE	= (1 << 0),	/* online / offline */
 	ETH_TEST_FL_FAILED	= (1 << 1),	/* test passed / failed */
@@ -292,6 +310,7 @@ struct ethtool_perm_addr {
 enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
 	ETH_FLAG_NTUPLE		= (1 << 27),	/* N-tuple filters enabled */
+	ETH_FLAG_RXHASH		= (1 << 28),
 };
 
 /* The following structures are for supporting RX network flow
@@ -389,8 +408,6 @@ struct ethtool_rx_ntuple_flow_spec {
 #define ETHTOOL_RXNTUPLE_ACTION_DROP -1
 };
 
-#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
-#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
 struct ethtool_rx_ntuple {
 	__u32					cmd;
 	struct ethtool_rx_ntuple_flow_spec	fs;
@@ -408,6 +425,7 @@ struct ethtool_flash {
 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
 };
 
+
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
 #define ETHTOOL_SSET		0x00000002 /* Set settings. */
@@ -463,9 +481,9 @@ struct ethtool_flash {
 #define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
 #define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 #define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
-
-#define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
-#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+#define	ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
+#define	ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+#define	ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.8 b/ethtool.8
index eb6430b..a7b43d5 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -170,6 +170,7 @@ ethtool \- Display or change ethernet card settings
 .B2 gso on off
 .B2 gro on off
 .B2 lro on off
+.B2 rxhash on off
 
 .B ethtool \-p|\-\-identify
 .I ethX
@@ -362,6 +363,9 @@ Specifies whether generic receive offload should be enabled
 .A2 lro on off
 Specifies whether large receive offload should be enabled
 .TP
+.A2 rxhash on off
+Specifies whether receive hashing offload should be enabled
+.TP
 .B \-p \-\-identify
 Initiates adapter-specific action intended to enable an operator to
 easily identify the adapter by sight.  Typically this involves
diff --git a/ethtool.c b/ethtool.c
index fc9e419..26ab94b 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -173,6 +173,7 @@ static struct option {
 		"		[ gro on|off ]\n"
 		"		[ lro on|off ]\n"
 		"		[ ntuple on|off ]\n"
+		"		[ rxhash on|off ]\n"
     },
     { "-i", "--driver", MODE_GDRV, "Show driver information" },
     { "-d", "--register-dump", MODE_GREGS, "Do a register dump",
@@ -257,6 +258,7 @@ static int off_gso_wanted = -1;
 static int off_lro_wanted = -1;
 static int off_gro_wanted = -1;
 static int off_ntuple_wanted = -1;
+static int off_rxhash_wanted = -1;
 
 static struct ethtool_pauseparam epause;
 static int gpause_changed = 0;
@@ -382,6 +384,7 @@ static struct cmdline_info cmdline_offload[] = {
 	{ "lro", CMDL_BOOL, &off_lro_wanted, NULL },
 	{ "gro", CMDL_BOOL, &off_gro_wanted, NULL },
 	{ "ntuple", CMDL_BOOL, &off_ntuple_wanted, NULL },
+	{ "rxhash", CMDL_BOOL, &off_rxhash_wanted, NULL },
 };
 
 static struct cmdline_info cmdline_pause[] = {
@@ -1526,7 +1529,7 @@ static int dump_coalesce(void)
 }
 
 static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
-			int gro, int lro, int ntuple)
+			int gro, int lro, int ntuple, int rxhash)
 {
 	fprintf(stdout,
 		"rx-checksumming: %s\n"
@@ -1537,7 +1540,8 @@ static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
 		"generic-segmentation-offload: %s\n"
 		"generic-receive-offload: %s\n"
 		"large-receive-offload: %s\n"
-		"ntuple-filters: %s\n",
+		"ntuple-filters: %s\n"
+		"receive-hashing: %s\n",
 		rx ? "on" : "off",
 		tx ? "on" : "off",
 		sg ? "on" : "off",
@@ -1546,7 +1550,8 @@ static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
 		gso ? "on" : "off",
 		gro ? "on" : "off",
 		lro ? "on" : "off",
-		ntuple ? "on" : "off");
+		ntuple ? "on" : "off",
+		rxhash ? "on" : "off");
 
 	return 0;
 }
@@ -1863,7 +1868,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 {
 	struct ethtool_value eval;
 	int err, allfail = 1, rx = 0, tx = 0, sg = 0;
-	int tso = 0, ufo = 0, gso = 0, gro = 0, lro = 0, ntuple = 0;
+	int tso = 0, ufo = 0, gso = 0, gro = 0, lro = 0, ntuple = 0, rxhash = 0;
 
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
@@ -1935,6 +1940,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	} else {
 		lro = (eval.data & ETH_FLAG_LRO) != 0;
 		ntuple = (eval.data & ETH_FLAG_NTUPLE) != 0;
+		rxhash = (eval.data & ETH_FLAG_RXHASH) != 0;
 		allfail = 0;
 	}
 
@@ -1953,7 +1959,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		return 83;
 	}
 
-	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, ntuple);
+	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, ntuple, rxhash);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
@@ -2087,6 +2093,29 @@ static int do_soffload(int fd, struct ifreq *ifr)
 			return 93;
 		}
 	}
+	if (off_rxhash_wanted >= 0) {
+		changed = 1;
+		eval.cmd = ETHTOOL_GFLAGS;
+		eval.data = 0;
+		ifr->ifr_data = (caddr_t)&eval;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err) {
+			perror("Cannot get device flag settings");
+			return 91;
+		}
+
+		eval.cmd = ETHTOOL_SFLAGS;
+		if (off_rxhash_wanted)
+			eval.data |= ETH_FLAG_RXHASH;
+		else
+			eval.data &= ~ETH_FLAG_RXHASH;
+
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err) {
+			perror("Cannot set receive hash settings");
+			return 93;
+		}
+	}
 
 	if (!changed) {
 		fprintf(stdout, "no offload settings changed\n");
@@ -2655,6 +2684,9 @@ static int do_srxntuple(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
+#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
+
 static int do_grxntuple(int fd, struct ifreq *ifr)
 {
 	struct ethtool_gstrings *strings;
-- 
1.6.3.3


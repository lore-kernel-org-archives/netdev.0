From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ethtool: RXHASH flag support (v2)
Date: Fri, 2 Apr 2010 08:15:15 -0700
Message-ID: <20100402081515.1b963562@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38873 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751519Ab0DBPxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 11:53:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for RXHASH flag in ethtool offload.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 ethtool-copy.h |    1 +
 ethtool.8      |    4 ++++
 ethtool.c      |   39 ++++++++++++++++++++++++++++++++++-----
 3 files changed, 39 insertions(+), 5 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index a26dcbd..c5eb680 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -310,6 +310,7 @@ struct ethtool_perm_addr {
 enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
 	ETH_FLAG_NTUPLE		= (1 << 27),	/* N-tuple filters enabled */
+	ETH_FLAG_RXHASH		= (1 << 28),
 };
 
 /* The following structures are for supporting RX network flow
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
index 8550ba2..4226a67 100644
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
-- 
1.6.3.3


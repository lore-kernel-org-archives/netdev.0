From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/2] ethtool: Support no-cache copy in config
Date: Tue, 8 Mar 2011 21:05:11 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1103082056010.4814@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:3201 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849Ab1CIFFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 00:05:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for nccopy configuration as an offload option.  This allows
enabling and disabling no-cache copies in copy-from-user on
transmission for a device.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 ethtool-copy.h |    4 ++++
 ethtool.c      |   37 ++++++++++++++++++++++++++++++++-----
 2 files changed, 36 insertions(+), 5 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 75c3ae7..98529d8 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -585,6 +585,10 @@ struct ethtool_flash {
 #define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n table */
 #define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n table */
 
+#define	ETHTOOL_GNCCOPY		0x0000003c /* Get no-cache-copy enable
+					    * (ethtool_value). */
+#define	ETHTOOL_SNCCOPY		0x0000003d /* Set no-cache-copy enable
+					    * (ethtool_value). */
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
diff --git a/ethtool.c b/ethtool.c
index 1afdfe4..7be8270 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -210,6 +210,7 @@ static struct option {
 		"		[ txvlan on|off ]\n"
 		"		[ ntuple on|off ]\n"
 		"		[ rxhash on|off ]\n"
+		"		[ nccopy on|off ]\n"
     },
     { "-i", "--driver", MODE_GDRV, "Show driver information" },
     { "-d", "--register-dump", MODE_GREGS, "Do a register dump",
@@ -308,6 +309,7 @@ static int off_gso_wanted = -1;
 static u32 off_flags_wanted = 0;
 static u32 off_flags_mask = 0;
 static int off_gro_wanted = -1;
+static int off_nccopy_wanted = -1;
 
 static struct ethtool_pauseparam epause;
 static int gpause_changed = 0;
@@ -472,6 +474,7 @@ static struct cmdline_info cmdline_offload[] = {
 	{ "lro", CMDL_FLAG, &off_flags_wanted, NULL,
 	  ETH_FLAG_LRO, &off_flags_mask },
 	{ "gro", CMDL_BOOL, &off_gro_wanted, NULL },
+	{ "nccopy", CMDL_BOOL, &off_nccopy_wanted, NULL },
 	{ "rxvlan", CMDL_FLAG, &off_flags_wanted, NULL,
 	  ETH_FLAG_RXVLAN, &off_flags_mask },
 	{ "txvlan", CMDL_FLAG, &off_flags_wanted, NULL,
@@ -1874,7 +1877,7 @@ static int dump_coalesce(void)
 
 static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
 			int gro, int lro, int rxvlan, int txvlan, int ntuple,
-			int rxhash)
+			int rxhash, int nccopy)
 {
 	fprintf(stdout,
 		"rx-checksumming: %s\n"
@@ -1888,7 +1891,8 @@ static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
 		"rx-vlan-offload: %s\n"
 		"tx-vlan-offload: %s\n"
 		"ntuple-filters: %s\n"
-		"receive-hashing: %s\n",
+		"receive-hashing: %s\n"
+		"no-cache-copy: %s\n",
 		rx ? "on" : "off",
 		tx ? "on" : "off",
 		sg ? "on" : "off",
@@ -1900,7 +1904,8 @@ static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
 		rxvlan ? "on" : "off",
 		txvlan ? "on" : "off",
 		ntuple ? "on" : "off",
-		rxhash ? "on" : "off");
+		rxhash ? "on" : "off",
+		nccopy ? "on" : "off");
 
 	return 0;
 }
@@ -2224,7 +2229,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	struct ethtool_value eval;
 	int err, allfail = 1, rx = 0, tx = 0, sg = 0;
 	int tso = 0, ufo = 0, gso = 0, gro = 0, lro = 0, rxvlan = 0, txvlan = 0,
-	    ntuple = 0, rxhash = 0;
+	    ntuple = 0, rxhash = 0, nccopy = 0;
 
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
@@ -2312,13 +2317,23 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		allfail = 0;
 	}
 
+	eval.cmd = ETHTOOL_GNCCOPY;
+	ifr->ifr_data = (caddr_t)&eval;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err)
+		perror("Cannot get device no-cache copy settings");
+	else {
+		nccopy = eval.data;
+		allfail = 0;
+	}
+
 	if (allfail) {
 		fprintf(stdout, "no offload info available\n");
 		return 83;
 	}
 
 	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, rxvlan, txvlan,
-			    ntuple, rxhash);
+			    ntuple, rxhash, nccopy);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
@@ -2428,6 +2443,18 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		}
 	}
 
+	if (off_nccopy_wanted >= 0) {
+		changed = 1;
+		eval.cmd = ETHTOOL_SNCCOPY;
+		eval.data = (off_nccopy_wanted == 1);
+		ifr->ifr_data = (caddr_t)&eval;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err) {
+			perror("Cannot set device no-cache copy settings");
+			return 94;
+		}
+	}
+
 	if (!changed) {
 		fprintf(stdout, "no offload settings changed\n");
 	}
-- 
1.7.3.1


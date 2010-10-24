From: David Dillow <dave@thedillows.org>
Subject: [PATCH] Add support for new VLAN acceleration model
Date: Sun, 24 Oct 2010 16:24:40 -0400
Message-ID: <1287951880-25321-1-git-send-email-dave@thedillows.org>
Cc: jgarzik@redhat.com, davem@davemloft.net, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from amavis-smtp.knology.net ([75.76.199.6]:40394 "EHLO
	amavis-smtp.knology.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932187Ab0JXUYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 16:24:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Dillow <dave@thedillows.org>
---
I used this during testing of the typhoon conversion.

 ethtool-copy.h |    2 ++
 ethtool.c      |   23 +++++++++++++++++++----
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 894f1da..557425e 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -308,6 +308,8 @@ struct ethtool_perm_addr {
  * flag differs from the read-only value.
  */
 enum ethtool_flags {
+	ETH_FLAG_TXVLAN		= (1 << 7),	/* TX VLAN offload enabled */
+	ETH_FLAG_RXVLAN		= (1 << 8),	/* RX VLAN offload enabled */
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
 	ETH_FLAG_NTUPLE		= (1 << 27),	/* N-tuple filters enabled */
 	ETH_FLAG_RXHASH		= (1 << 28),
diff --git a/ethtool.c b/ethtool.c
index 6b2b7c8..b6d3bfb 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -202,6 +202,8 @@ static struct option {
 		"		[ lro on|off ]\n"
 		"		[ ntuple on|off ]\n"
 		"		[ rxhash on|off ]\n"
+		"		[ rxvlan on|off ]\n"
+		"		[ txvlan on|off ]\n"
     },
     { "-i", "--driver", MODE_GDRV, "Show driver information" },
     { "-d", "--register-dump", MODE_GREGS, "Do a register dump",
@@ -439,6 +441,10 @@ static struct cmdline_info cmdline_offload[] = {
 	  ETH_FLAG_NTUPLE, &off_flags_unwanted },
 	{ "rxhash", CMDL_FLAG, &off_flags_wanted, NULL,
 	  ETH_FLAG_RXHASH, &off_flags_unwanted },
+	{ "txvlan", CMDL_FLAG, &off_flags_wanted, NULL,
+	  ETH_FLAG_TXVLAN, &off_flags_unwanted },
+	{ "rxvlan", CMDL_FLAG, &off_flags_wanted, NULL,
+	  ETH_FLAG_RXVLAN, &off_flags_unwanted },
 };
 
 static struct cmdline_info cmdline_pause[] = {
@@ -1732,7 +1738,8 @@ static int dump_coalesce(void)
 }
 
 static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
-			int gro, int lro, int ntuple, int rxhash)
+			int gro, int lro, int ntuple, int rxhash, int rxvlan,
+			int txvlan)
 {
 	fprintf(stdout,
 		"rx-checksumming: %s\n"
@@ -1744,7 +1751,9 @@ static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
 		"generic-receive-offload: %s\n"
 		"large-receive-offload: %s\n"
 		"ntuple-filters: %s\n"
-		"receive-hashing: %s\n",
+		"receive-hashing: %s\n"
+		"rx-vlan-offload: %s\n"
+		"tx-vlan-offload: %s\n",
 		rx ? "on" : "off",
 		tx ? "on" : "off",
 		sg ? "on" : "off",
@@ -1754,7 +1763,9 @@ static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
 		gro ? "on" : "off",
 		lro ? "on" : "off",
 		ntuple ? "on" : "off",
-		rxhash ? "on" : "off");
+		rxhash ? "on" : "off",
+		rxvlan ? "on" : "off",
+		txvlan ? "on" : "off");
 
 	return 0;
 }
@@ -2076,6 +2087,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	struct ethtool_value eval;
 	int err, allfail = 1, rx = 0, tx = 0, sg = 0;
 	int tso = 0, ufo = 0, gso = 0, gro = 0, lro = 0, ntuple = 0, rxhash = 0;
+	int rxvlan = 0, txvlan = 0;
 
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
@@ -2148,6 +2160,8 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		lro = (eval.data & ETH_FLAG_LRO) != 0;
 		ntuple = (eval.data & ETH_FLAG_NTUPLE) != 0;
 		rxhash = (eval.data & ETH_FLAG_RXHASH) != 0;
+		rxvlan = (eval.data & ETH_FLAG_RXVLAN) != 0;
+		txvlan = (eval.data & ETH_FLAG_TXVLAN) != 0;
 		allfail = 0;
 	}
 
@@ -2166,7 +2180,8 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		return 83;
 	}
 
-	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, ntuple, rxhash);
+	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, ntuple, rxhash,
+			    rxvlan, txvlan);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
-- 
1.7.2.3


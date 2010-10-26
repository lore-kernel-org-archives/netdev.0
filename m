From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH] ethtool: Add support for vlan accleration.
Date: Mon, 25 Oct 2010 19:22:14 -0700
Message-ID: <1288059734-12916-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: jgarzik@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:52175 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757060Ab0JZCWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 22:22:20 -0400
Received: by qyk10 with SMTP id 10so2436470qyk.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 19:22:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel now has support for enabling and disabling vlan
acceleration, similar to other forms of offloading.  This
adds the complementary userspace support.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 ethtool-copy.h |    2 ++
 ethtool.8      |    8 ++++++++
 ethtool.c      |   21 ++++++++++++++++++---
 3 files changed, 28 insertions(+), 3 deletions(-)

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
diff --git a/ethtool.8 b/ethtool.8
index 3ca403c..7801797 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -170,6 +170,8 @@ ethtool \- Display or change ethernet card settings
 .B2 gso on off
 .B2 gro on off
 .B2 lro on off
+.B2 rxvlan on off
+.B2 txvlan on off
 .B2 rxhash on off
 
 .B ethtool \-p|\-\-identify
@@ -377,6 +379,12 @@ Specifies whether generic receive offload should be enabled
 .A2 lro on off
 Specifies whether large receive offload should be enabled
 .TP
+.A2 rxvlan on off
+Specifies whether RX VLAN acceleration should be enabled
+.TP
+.A2 txvlan on off
+Specifies whether TX VLAN acceleration should be enabled
+.TP
 .A2 rxhash on off
 Specifies whether receive hashing offload should be enabled
 .TP
diff --git a/ethtool.c b/ethtool.c
index 6b2b7c8..3d24d58 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -200,6 +200,8 @@ static struct option {
 		"		[ gso on|off ]\n"
 		"		[ gro on|off ]\n"
 		"		[ lro on|off ]\n"
+		"		[ rxvlan on|off ]\n"
+		"		[ txvlan on|off ]\n"
 		"		[ ntuple on|off ]\n"
 		"		[ rxhash on|off ]\n"
     },
@@ -435,6 +437,10 @@ static struct cmdline_info cmdline_offload[] = {
 	{ "lro", CMDL_FLAG, &off_flags_wanted, NULL,
 	  ETH_FLAG_LRO, &off_flags_unwanted },
 	{ "gro", CMDL_BOOL, &off_gro_wanted, NULL },
+	{ "rxvlan", CMDL_FLAG, &off_flags_wanted, NULL,
+	  ETH_FLAG_RXVLAN, &off_flags_unwanted },
+	{ "txvlan", CMDL_FLAG, &off_flags_wanted, NULL,
+	  ETH_FLAG_TXVLAN, &off_flags_unwanted },
 	{ "ntuple", CMDL_FLAG, &off_flags_wanted, NULL,
 	  ETH_FLAG_NTUPLE, &off_flags_unwanted },
 	{ "rxhash", CMDL_FLAG, &off_flags_wanted, NULL,
@@ -1732,7 +1738,8 @@ static int dump_coalesce(void)
 }
 
 static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
-			int gro, int lro, int ntuple, int rxhash)
+			int gro, int lro, int rxvlan, int txvlan, int ntuple,
+			int rxhash)
 {
 	fprintf(stdout,
 		"rx-checksumming: %s\n"
@@ -1743,6 +1750,8 @@ static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
 		"generic-segmentation-offload: %s\n"
 		"generic-receive-offload: %s\n"
 		"large-receive-offload: %s\n"
+		"rx-vlan-offload: %s\n"
+		"tx-vlan-offload: %s\n"
 		"ntuple-filters: %s\n"
 		"receive-hashing: %s\n",
 		rx ? "on" : "off",
@@ -1753,6 +1762,8 @@ static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
 		gso ? "on" : "off",
 		gro ? "on" : "off",
 		lro ? "on" : "off",
+		rxvlan ? "on" : "off",
+		txvlan ? "on" : "off",
 		ntuple ? "on" : "off",
 		rxhash ? "on" : "off");
 
@@ -2075,7 +2086,8 @@ static int do_goffload(int fd, struct ifreq *ifr)
 {
 	struct ethtool_value eval;
 	int err, allfail = 1, rx = 0, tx = 0, sg = 0;
-	int tso = 0, ufo = 0, gso = 0, gro = 0, lro = 0, ntuple = 0, rxhash = 0;
+	int tso = 0, ufo = 0, gso = 0, gro = 0, lro = 0, rxvlan = 0, txvlan = 0,
+	    ntuple = 0, rxhash = 0;
 
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
@@ -2146,6 +2158,8 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		perror("Cannot get device flags");
 	} else {
 		lro = (eval.data & ETH_FLAG_LRO) != 0;
+		rxvlan = (eval.data & ETH_FLAG_RXVLAN) != 0;
+		txvlan = (eval.data & ETH_FLAG_TXVLAN) != 0;
 		ntuple = (eval.data & ETH_FLAG_NTUPLE) != 0;
 		rxhash = (eval.data & ETH_FLAG_RXHASH) != 0;
 		allfail = 0;
@@ -2166,7 +2180,8 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		return 83;
 	}
 
-	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, ntuple, rxhash);
+	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, rxvlan, txvlan,
+			    ntuple, rxhash);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
-- 
1.7.1


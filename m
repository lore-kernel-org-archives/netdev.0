From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH v2] net/inet_lro: remove setting skb->ip_summed when not
	LRO-able
Date: Wed, 25 Jun 2008 18:29:12 +0300
Message-ID: <1214407752.23583.69.camel@mtls03>
Reply-To: eli@dev.mellanox.co.il
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: OpenFabrics General <general@lists.openfabrics.org>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Vladimir Sokolovsky <vlad@mellanox.co.il>,
	Roland Dreier <rdreier@cisco.com>
To: netdev <netdev@vger.kernel.org>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:19228 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290AbYFYP14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 11:27:56 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1143084ywe.1
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2008 08:27:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 9c5223b8574f364629de4cc8607d97b32f742a7c Mon Sep 17 00:00:00 2001
From: Eli Cohen <eli@mellanox.co.il>
Date: Tue, 24 Jun 2008 17:17:14 +0300
Subject: [PATCH] net/inet_lro: remove setting skb->ip_summed when not LRO-able

When an SKB cannot be chained to a session, the current code attempts
to "restore" its ip_summed field from lro_mgr->ip_summed. However,
lro_mgr->ip_summed does not hold the original value; in fact, we'd
better not touch skb->ip_summed since it is not modified by the code
in the path leading to a failure to chain it.
Also use a cleaer comment to the describe the ip_summed field of
struct net_lro_mgr.

Issue raised by Or Gerlitz <ogerlitz@voltaire.com>

Signed-off-by: Eli Cohen <eli@mellanox.co.il>
---
Changes since previous post:
Updated comment on inet_lro.h for more clarity.


 include/linux/inet_lro.h |    6 +++++-
 net/ipv4/inet_lro.c      |    3 +--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/inet_lro.h b/include/linux/inet_lro.h
index 80335b7..c4335fa 100644
--- a/include/linux/inet_lro.h
+++ b/include/linux/inet_lro.h
@@ -84,7 +84,11 @@ struct net_lro_mgr {
 				    from received packets and eth protocol
 				    is still ETH_P_8021Q */
 
-	u32 ip_summed;      /* Set in non generated SKBs in page mode */
+	/*
+	 * Set for generated SKBs that are not added to
+	 * the frag list in fragmented mode
+	 */
+	u32 ip_summed;
 	u32 ip_summed_aggr; /* Set in aggregated SKBs: CHECKSUM_UNNECESSARY
 			     * or CHECKSUM_NONE */
 
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index 4a4d49f..cfd034a 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -383,8 +383,7 @@ static int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
 out2: /* send aggregated SKBs to stack */
 	lro_flush(lro_mgr, lro_desc);
 
-out:  /* Original SKB has to be posted to stack */
-	skb->ip_summed = lro_mgr->ip_summed;
+out:
 	return 1;
 }
 
-- 
1.5.6




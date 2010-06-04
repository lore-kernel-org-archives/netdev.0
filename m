From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] act_mirred: don't clone skb when skb isn't shared
Date: Fri,  4 Jun 2010 21:43:10 +0800
Message-ID: <1275658990-15838-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:59181 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849Ab0FDPm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 11:42:58 -0400
Received: by pvg16 with SMTP id 16so631466pvg.19
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 08:42:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

don't clone skb when skb isn't shared

When the tcf_action is TC_ACT_STOLEN, and the skb isn't shared, we don't need
to clone a new skb. As the skb will be freed after this function returns, we
can use it freely once we get a reference to it.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/act_mirred.c |   17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index c0b6863..79d4318 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -169,13 +169,20 @@ static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
 		goto out;
 	}
 
-	skb2 = skb_act_clone(skb, GFP_ATOMIC);
-	if (skb2 == NULL)
-		goto out;
+	at = G_TC_AT(skb->tc_verd);
+	if (m->tcf_action == TC_ACT_STOLEN && !skb_shared(skb)) {
+		skb2 = skb_get(skb);
+		skb2->tc_verd = SET_TC_VERD(skb2->tc_verd, 0);
+		skb2->tc_verd = CLR_TC_OK2MUNGE(skb2->tc_verd);
+		skb2->tc_verd = CLR_TC_MUNGED(skb2->tc_verd);
+	} else {
+		skb2 = skb_act_clone(skb, GFP_ATOMIC);
+		if (skb2 == NULL)
+			goto out;
+	}
 
 	m->tcf_bstats.bytes += qdisc_pkt_len(skb2);
 	m->tcf_bstats.packets++;
-	at = G_TC_AT(skb->tc_verd);
 	if (!(at & AT_EGRESS)) {
 		if (m->tcfm_ok_push)
 			skb_push(skb2, skb2->dev->hard_header_len);
@@ -185,8 +192,8 @@ static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
 	if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
 		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
 
-	skb2->dev = dev;
 	skb2->skb_iif = skb->dev->ifindex;
+	skb2->dev = dev;
 	dev_queue_xmit(skb2);
 	err = 0;
 

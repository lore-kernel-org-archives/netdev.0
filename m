From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: act_mirred: Fix bogus header when redirecting from VLAN
Date: Fri, 17 Apr 2015 09:02:16 +0800
Message-ID: <20150417010216.GA22415@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:36391 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbbDQBCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 21:02:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When you redirect a VLAN device to an ifb device, you end up with
crap within the ifb device because they have unequal hard header
lengths and the redirected packet contains four extra bytes at the
start which then gets interpreted as part of the MAC address.

This patch fixes this by only pushing on the hard header length
of ifb.  This assumes that the original packet actually has enough
header for that so checks have been added to that effect.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 34f846b..1256d26 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -105,7 +105,7 @@ static void ri_tasklet(unsigned long dev)
 		if (from & AT_EGRESS) {
 			dev_queue_xmit(skb);
 		} else if (from & AT_INGRESS) {
-			skb_pull(skb, skb->dev->hard_header_len);
+			skb_pull(skb, _dev->hard_header_len);
 			netif_receive_skb(skb);
 		} else
 			BUG();
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 5953517..44e4d50 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -151,13 +151,25 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	}
 
 	at = G_TC_AT(skb->tc_verd);
+
+	if (!(at & AT_EGRESS) && m->tcfm_ok_push &&
+	    (skb_headroom(skb) < dev->hard_header_len ||
+	     skb->dev->hard_header_len < dev->hard_header_len)) {
+		net_notice_ratelimited(
+			"tc mirred: Insufficient headroom from %s to %s: "
+			"%d %d\n",
+			skb->dev->name, dev->name,
+			skb_headroom(skb), skb->dev->hard_header_len);
+		goto out;
+	}
+
 	skb2 = skb_act_clone(skb, GFP_ATOMIC, m->tcf_action);
 	if (skb2 == NULL)
 		goto out;
 
 	if (!(at & AT_EGRESS)) {
 		if (m->tcfm_ok_push)
-			skb_push(skb2, skb2->dev->hard_header_len);
+			skb_push(skb2, dev->hard_header_len);
 	}
 
 	/* mirror is always swallowed */
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

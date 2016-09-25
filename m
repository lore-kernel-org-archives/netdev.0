From: Yotam Gigi <yotam.gi@gmail.com>
Subject: [PATCH net v2 1/2] act_ife: Fix external mac header on encode
Date: Sun, 25 Sep 2016 15:31:50 +0300
Message-ID: <1474806711-64660-2-git-send-email-yotamg@mellanox.com>
References: <1474806711-64660-1-git-send-email-yotamg@mellanox.com>
To: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org,
        yotamg@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35569 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966316AbcIYMaL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 08:30:11 -0400
Received: by mail-wm0-f68.google.com with SMTP id 133so9873833wmq.2
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 05:30:10 -0700 (PDT)
In-Reply-To: <1474806711-64660-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ife encode side, external mac header is copied from the original packet
and may be overridden if the user requests. Before, the mac header copy
was done from memory region that might not be accessible anymore, as
skb_cow_head might free it and copy the packet. This led to random values
in the external mac header once the values were not set by user.

This fix takes the internal mac header from the packet, after the call to
skb_cow_head.

Fixes: ef6980b6becb ("net sched: introduce IFE action")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 net/sched/act_ife.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index ccf7b4b..b949d97 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -766,8 +766,6 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 		return TC_ACT_SHOT;
 	}
 
-	iethh = eth_hdr(skb);
-
 	err = skb_cow_head(skb, hdrm);
 	if (unlikely(err)) {
 		ife->tcf_qstats.drops++;
@@ -778,6 +776,7 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 	if (!(at & AT_EGRESS))
 		skb_push(skb, skb->dev->hard_header_len);
 
+	iethh = (struct ethhdr *)skb->data;
 	__skb_push(skb, hdrm);
 	memcpy(skb->data, iethh, skb->mac_len);
 	skb_reset_mac_header(skb);
-- 
2.4.11

From: Yotam Gigi <yotam.gi@gmail.com>
Subject: [PATCH net v3 1/2] act_ife: Fix external mac header on encode
Date: Mon, 26 Sep 2016 13:45:25 +0300
Message-ID: <1474886726-56363-2-git-send-email-yotamg@mellanox.com>
References: <1474886726-56363-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org,
        mlxsw@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36734 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031482AbcIZKnq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 06:43:46 -0400
Received: by mail-wm0-f67.google.com with SMTP id b184so13450041wma.3
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 03:43:45 -0700 (PDT)
In-Reply-To: <1474886726-56363-1-git-send-email-yotamg@mellanox.com>
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
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
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

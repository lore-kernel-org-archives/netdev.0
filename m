From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net 1/2] act_ife: Fix external mac header on encode
Date: Thu, 22 Sep 2016 15:55:25 +0300
Message-ID: <1474548926-22815-2-git-send-email-yotamg@mellanox.com>
References: <1474548926-22815-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yotam Gigi <yotamg@mellanox.com>
To: <jhs@mojatatu.com>, <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0079.outbound.protection.outlook.com ([104.47.2.79]:35424
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752165AbcIVNIv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 09:08:51 -0400
In-Reply-To: <1474548926-22815-1-git-send-email-yotamg@mellanox.com>
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
index 27b19ca..7f71a3d 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -758,8 +758,6 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 		return TC_ACT_SHOT;
 	}
 
-	iethh = eth_hdr(skb);
-
 	err = skb_cow_head(skb, reserve);
 	if (unlikely(err)) {
 		ife->tcf_qstats.drops++;
@@ -768,6 +766,7 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 	}
 
 	__skb_push(skb, total_push);
+	iethh = (struct ethhdr *)(skb->data + hdrm);
 	memcpy(skb->data, iethh, skb->mac_len);
 	skb_reset_mac_header(skb);
 	skboff += skb->mac_len;
-- 
2.4.11

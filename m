From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net 2/2] act_ife: Fix false parsing on decode side
Date: Thu, 22 Sep 2016 15:55:26 +0300
Message-ID: <1474548926-22815-3-git-send-email-yotamg@mellanox.com>
References: <1474548926-22815-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yotam Gigi <yotamg@mellanox.com>
To: <jhs@mojatatu.com>, <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0057.outbound.protection.outlook.com ([104.47.2.57]:20293
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756049AbcIVQZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 12:25:56 -0400
In-Reply-To: <1474548926-22815-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ife decode side, the action iterates over the tlvs in the ife header
and parses them one by one, where in each iteration the current pointer is
advanced according to the tlv size.

Before, the pointer was advanced in a wrong way, as the tlv type and size
bytes were not taken into account. This led to false parsing of ife
header. In addition, due to the fact that the loop counter was unsigned,
it could lead to infinite parsing loop.

This fix changes the loop counter to be signed and fixes the parsing to
take into account the tlv type and size.

Fixes: ef6980b6becb ("net sched: introduce IFE action")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 net/sched/act_ife.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 7f71a3d..4786b28 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -627,7 +627,7 @@ static int tcf_ife_decode(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_ife_info *ife = to_ife(a);
 	int action = ife->tcf_action;
 	struct ifeheadr *ifehdr = (struct ifeheadr *)skb->data;
-	u16 ifehdrln = ifehdr->metalen;
+	int ifehdrln = (int)ifehdr->metalen;
 	struct meta_tlvhdr *tlv = (struct meta_tlvhdr *)(ifehdr->tlv_data);
 
 	spin_lock(&ife->tcf_lock);
@@ -668,8 +668,8 @@ static int tcf_ife_decode(struct sk_buff *skb, const struct tc_action *a,
 			ife->tcf_qstats.overlimits++;
 		}
 
-		tlvdata += alen;
-		ifehdrln -= alen;
+		tlvdata += alen + sizeof(struct meta_tlvhdr);
+		ifehdrln -= alen + sizeof(struct meta_tlvhdr);
 		tlv = (struct meta_tlvhdr *)tlvdata;
 	}
 
-- 
2.4.11

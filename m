From: Yotam Gigi <yotam.gi@gmail.com>
Subject: [PATCH net v2 2/2] act_ife: Fix false parsing on decode side
Date: Sun, 25 Sep 2016 15:31:51 +0300
Message-ID: <1474806711-64660-3-git-send-email-yotamg@mellanox.com>
References: <1474806711-64660-1-git-send-email-yotamg@mellanox.com>
To: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org,
        yotamg@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36303 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034004AbcIYMaM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 08:30:12 -0400
Received: by mail-wm0-f65.google.com with SMTP id b184so9886930wma.3
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 05:30:12 -0700 (PDT)
In-Reply-To: <1474806711-64660-1-git-send-email-yotamg@mellanox.com>
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
index b949d97..1a055ea 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -653,7 +653,7 @@ static int tcf_ife_decode(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_ife_info *ife = to_ife(a);
 	int action = ife->tcf_action;
 	struct ifeheadr *ifehdr = (struct ifeheadr *)skb->data;
-	u16 ifehdrln = ifehdr->metalen;
+	int ifehdrln = (int)ifehdr->metalen;
 	struct meta_tlvhdr *tlv = (struct meta_tlvhdr *)(ifehdr->tlv_data);
 
 	spin_lock(&ife->tcf_lock);
@@ -694,8 +694,8 @@ static int tcf_ife_decode(struct sk_buff *skb, const struct tc_action *a,
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

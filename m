From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v2 12/27] net/core: use __vlan_hwaccel helpers
Date: Tue,  3 Jan 2017 21:52:35 +0100 (CET)
Message-ID: <1e3a7a956076ae0e7273fac03b823dc7fef1c98f.1483475202.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:34734 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935904AbdACUwm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 15:52:42 -0500
In-Reply-To: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes assumptions about VLAN_TAG_PRESENT bit.

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 net/core/dev.c       | 8 +++++---
 net/core/skbuff.c    | 2 +-
 net/sched/act_vlan.c | 2 +-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 56818f7eab2b..3e2d617970e4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4172,7 +4172,7 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 		 * and set skb->priority like in vlan_do_receive()
 		 * For the time being, just ignore Priority Code Point
 		 */
-		skb->vlan_tci = 0;
+		__vlan_hwaccel_clear_tag(skb);
 	}
 
 	type = skb->protocol;
@@ -4419,7 +4419,9 @@ static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
 		}
 
 		diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
-		diffs |= p->vlan_tci ^ skb->vlan_tci;
+		diffs |= skb_vlan_tag_present(p) ^ skb_vlan_tag_present(skb);
+		if (skb_vlan_tag_present(p))
+			diffs |= p->vlan_tci ^ skb->vlan_tci;
 		diffs |= skb_metadata_dst_cmp(p, skb);
 		if (maclen == ETH_HLEN)
 			diffs |= compare_ether_header(skb_mac_header(p),
@@ -4657,7 +4659,7 @@ static void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
 	__skb_pull(skb, skb_headlen(skb));
 	/* restore the reserve we had after netdev_alloc_skb_ip_align() */
 	skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN - skb_headroom(skb));
-	skb->vlan_tci = 0;
+	__vlan_hwaccel_clear_tag(skb);
 	skb->dev = napi->dev;
 	skb->skb_iif = 0;
 	skb->encapsulation = 0;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5a03730fbc1a..4b2aba3a28b2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4565,7 +4565,7 @@ int skb_vlan_pop(struct sk_buff *skb)
 	int err;
 
 	if (likely(skb_vlan_tag_present(skb))) {
-		skb->vlan_tci = 0;
+		__vlan_hwaccel_clear_tag(skb);
 	} else {
 		if (unlikely(!eth_type_vlan(skb->protocol)))
 			return 0;
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index 19e0dba305ce..8d563806f518 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -62,7 +62,7 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
 		/* extract existing tag (and guarantee no hw-accel tag) */
 		if (skb_vlan_tag_present(skb)) {
 			tci = skb_vlan_tag_get(skb);
-			skb->vlan_tci = 0;
+			__vlan_hwaccel_clear_tag(skb);
 		} else {
 			/* in-payload vlan tag, pop it */
 			err = __skb_vlan_pop(skb, &tci);
-- 
2.11.0

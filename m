From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/10] netfilter: bridge: honor frag_max_size when refragmenting
Date: Wed, 15 Mar 2017 18:01:08 +0100
Message-ID: <1489597272-30347-7-git-send-email-pablo@netfilter.org>
References: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

consider a bridge with mtu 9000, but end host sending smaller
packets to another host with mtu < 9000.

In this case, after reassembly, bridge+defrag would refragment,
and then attempt to send the reassembled packet as long as it
was below 9k.

Instead we have to cap by the largest fragment size seen.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter_hooks.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 95087e6e8258..3c5185021c1c 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -721,18 +721,20 @@ static unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 
 static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct nf_bridge_info *nf_bridge;
-	unsigned int mtu_reserved;
+	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
+	unsigned int mtu, mtu_reserved;
 
 	mtu_reserved = nf_bridge_mtu_reduction(skb);
+	mtu = skb->dev->mtu;
+
+	if (nf_bridge->frag_max_size && nf_bridge->frag_max_size < mtu)
+		mtu = nf_bridge->frag_max_size;
 
-	if (skb_is_gso(skb) || skb->len + mtu_reserved <= skb->dev->mtu) {
+	if (skb_is_gso(skb) || skb->len + mtu_reserved <= mtu) {
 		nf_bridge_info_free(skb);
 		return br_dev_queue_push_xmit(net, sk, skb);
 	}
 
-	nf_bridge = nf_bridge_info_get(skb);
-
 	/* This is wrong! We should preserve the original fragment
 	 * boundaries by preserving frag_list rather than refragmenting.
 	 */
-- 
2.1.4


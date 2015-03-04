From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 4/8] netfilter: bridge: refactor conditional in br_nf_dev_queue_xmit
Date: Thu,  5 Mar 2015 00:52:36 +0100
Message-ID: <1425513160-496-5-git-send-email-fw@strlen.de>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1425513160-496-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

simpilifies followup patch that re-works brnf ip_fragment handling.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/bridge/br_netfilter.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 5b3bceb..ef1fe28 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -803,13 +803,16 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
 	int ret;
 	int frag_max_size;
+	unsigned int mtu_reserved;
 
+	if (skb_is_gso(skb) || skb->protocol != htons(ETH_P_IP))
+		return br_dev_queue_push_xmit(skb);
+
+	mtu_reserved = nf_bridge_mtu_reduction(skb);
 	/* This is wrong! We should preserve the original fragment
 	 * boundaries by preserving frag_list rather than refragmenting.
 	 */
-	if (skb->protocol == htons(ETH_P_IP) &&
-	    skb->len + nf_bridge_mtu_reduction(skb) > skb->dev->mtu &&
-	    !skb_is_gso(skb)) {
+	if (skb->len + mtu_reserved > skb->dev->mtu) {
 		frag_max_size = BR_INPUT_SKB_CB(skb)->frag_max_size;
 		if (br_parse_ip_options(skb))
 			/* Drop invalid packet */
-- 
2.0.5


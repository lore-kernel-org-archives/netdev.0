From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 2/2] bridge: use is_skb_forwardable in forward path
Date: Wed, 26 Mar 2014 12:00:27 -0400
Message-ID: <1395849627-15711-4-git-send-email-vyasevic@redhat.com>
References: <1395849627-15711-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1395849627-15711-1-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Use existing function instead of trying to use our own.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_forward.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index d3409e6..e33d0b6 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -35,16 +35,11 @@ static inline int should_deliver(const struct net_bridge_port *p,
 		p->state == BR_STATE_FORWARDING;
 }
 
-static inline unsigned int packet_length(const struct sk_buff *skb)
-{
-	return skb->len - (skb->protocol == htons(ETH_P_8021Q) ? VLAN_HLEN : 0);
-}
-
 int br_dev_queue_push_xmit(struct sk_buff *skb)
 {
 	/* ip_fragment doesn't copy the MAC header */
 	if (nf_bridge_maybe_copy_header(skb) ||
-	    (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))) {
+	    !is_skb_forwardable(skb->dev, skb)) {
 		kfree_skb(skb);
 	} else {
 		skb_push(skb, ETH_HLEN);
-- 
1.8.5.3

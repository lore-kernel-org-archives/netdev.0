From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 8/8] netfilter: bridge: rename nf_bridge_info->data to dnat_orig_mac
Date: Thu,  5 Mar 2015 00:52:40 +0100
Message-ID: <1425513160-496-9-git-send-email-fw@strlen.de>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1425513160-496-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is no generic scratch space anymore, we removed all users
so far except the rare case of DNAT-ON-BRIDE.

That one is not trivial to remove, neigh->output queues skb
and eventually invokes dev_queue_xmit and we only get the packet
back into the bridge via bride_devices' ndo_start_xmit function.

The packet will re-enter bridge stack via br_dev_xmit(), and we pretend
it entered bridge forward logic (we inject it back into stack right after
br_netfilter invoked iptables PREROUTING).

This also means we don't need to care about fragmentation here --
it will be fragmented later when br_netfilter has finished with
POST_ROUTING traversal.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/skbuff.h    | 2 +-
 net/bridge/br_device.c    | 3 ++-
 net/bridge/br_netfilter.c | 5 +++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bba1330..b7d15da 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -169,7 +169,7 @@ struct nf_bridge_info {
 	unsigned int		mask;
 	struct net_device	*physindev;
 	struct net_device	*physoutdev;
-	unsigned long		data[32 / sizeof(unsigned long)];
+	char dnat_orig_mac[8]; /* mac src + type */
 };
 #endif
 
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 7e39b8d..d9768e0 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -43,7 +43,8 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 	nf_bridge->mask &= ~BRNF_BRIDGED_DNAT;
 
 	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN),
-				       skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
+				       skb->nf_bridge->dnat_orig_mac,
+				       ETH_HLEN-ETH_ALEN);
 	skb->dev = nf_bridge->physindev;
 	br_handle_frame_finish(skb);
 }
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 88e7656..825c5d7 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -305,17 +305,18 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 			skb->dev = nf_bridge->physindev;
 			ret = br_handle_frame_finish(skb);
 		} else {
+			BUILD_BUG_ON(sizeof(nf_bridge->dnat_orig_mac) != (ETH_HLEN-ETH_ALEN));
+
 			/* the neighbour function below overwrites the complete
 			 * MAC header, so we save the Ethernet source address and
 			 * protocol number.
 			 */
 			skb_copy_from_linear_data_offset(skb,
 							 -(ETH_HLEN-ETH_ALEN),
-							 skb->nf_bridge->data,
+							 nf_bridge->dnat_orig_mac,
 							 ETH_HLEN-ETH_ALEN);
 			/* tell br_dev_xmit to continue with forwarding */
 			nf_bridge->mask |= BRNF_BRIDGED_DNAT;
-			/* FIXME Need to refragment */
 			ret = neigh->output(neigh, skb);
 		}
 		neigh_release(neigh);
-- 
2.0.5


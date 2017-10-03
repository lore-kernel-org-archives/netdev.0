From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 3/7] ipv4: ipmr: Don't forward packets already forwarded by hardware
Date: Tue,  3 Oct 2017 09:58:08 +0200
Message-ID: <20171003075812.1540-4-jiri@resnulli.us>
References: <20171003075812.1540-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        dsa@cumulusnetworks.com, edumazet@google.com, willemb@google.com,
        johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com,
        daniel@iogearbox.net, f.fainelli@gmail.com, fw@strlen.de,
        gfree.wind@vip.163.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36940 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751197AbdJCH6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 03:58:18 -0400
Received: by mail-wr0-f194.google.com with SMTP id v38so2377006wrc.4
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 00:58:17 -0700 (PDT)
In-Reply-To: <20171003075812.1540-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Change the ipmr module to not forward packets if:
 - The packet is marked with the offload_mr_fwd_mark, and
 - Both input interface and output interface share the same parent ID.

This way, a packet can go through partial multicast forwarding in the
hardware, where it will be forwarded only to the devices that share the
same parent ID (AKA, reside inside the same hardware). The kernel will
forward the packet to all other interfaces.

To do this, add the ipmr_offload_forward helper, which per skb, ingress VIF
and egress VIF, returns whether the forwarding was offloaded to hardware.
The ipmr_queue_xmit frees the skb and does not forward it if the result is
a true value.

All the forwarding path code compiles out when the CONFIG_NET_SWITCHDEV is
not set.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
 - Use dev_parent_id.len field instead of the dev_parent_id_valid field
---
 net/ipv4/ipmr.c | 37 ++++++++++++++++++++++++++++++++-----
 1 file changed, 32 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 1b161ad..b3ee01b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1859,10 +1859,33 @@ static inline int ipmr_forward_finish(struct net *net, struct sock *sk,
 	return dst_output(net, sk, skb);
 }
 
+#ifdef CONFIG_NET_SWITCHDEV
+static bool ipmr_forward_offloaded(struct sk_buff *skb, struct mr_table *mrt,
+				   int in_vifi, int out_vifi)
+{
+	struct vif_device *out_vif = &mrt->vif_table[out_vifi];
+	struct vif_device *in_vif = &mrt->vif_table[in_vifi];
+
+	if (!skb->offload_mr_fwd_mark)
+		return false;
+	if (!out_vif->dev_parent_id.id_len || !in_vif->dev_parent_id.id_len)
+		return false;
+	return netdev_phys_item_id_same(&out_vif->dev_parent_id,
+					&in_vif->dev_parent_id);
+}
+#else
+static bool ipmr_forward_offloaded(struct sk_buff *skb, struct mr_table *mrt,
+				   int in_vifi, int out_vifi)
+{
+	return false;
+}
+#endif
+
 /* Processing handlers for ipmr_forward */
 
 static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
-			    struct sk_buff *skb, struct mfc_cache *c, int vifi)
+			    int in_vifi, struct sk_buff *skb,
+			    struct mfc_cache *c, int vifi)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct vif_device *vif = &mrt->vif_table[vifi];
@@ -1883,6 +1906,9 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 		goto out_free;
 	}
 
+	if (ipmr_forward_offloaded(skb, mrt, in_vifi, vifi))
+		goto out_free;
+
 	if (vif->flags & VIFF_TUNNEL) {
 		rt = ip_route_output_ports(net, &fl4, NULL,
 					   vif->remote, vif->local,
@@ -2060,8 +2086,8 @@ static void ip_mr_forward(struct net *net, struct mr_table *mrt,
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
 				if (skb2)
-					ipmr_queue_xmit(net, mrt, skb2, cache,
-							psend);
+					ipmr_queue_xmit(net, mrt, true_vifi,
+							skb2, cache, psend);
 			}
 			psend = ct;
 		}
@@ -2072,9 +2098,10 @@ static void ip_mr_forward(struct net *net, struct mr_table *mrt,
 			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
 			if (skb2)
-				ipmr_queue_xmit(net, mrt, skb2, cache, psend);
+				ipmr_queue_xmit(net, mrt, true_vifi, skb2,
+						cache, psend);
 		} else {
-			ipmr_queue_xmit(net, mrt, skb, cache, psend);
+			ipmr_queue_xmit(net, mrt, true_vifi, skb, cache, psend);
 			return;
 		}
 	}
-- 
2.9.5

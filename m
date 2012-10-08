From: Florian Zumbiehl <florz@florz.de>
Subject: [PATCH v2] vlan: don't deliver frames for unknown vlans to
 protocols
Date: Mon, 8 Oct 2012 03:51:58 +0200
Message-ID: <20121008015158.GE25895@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jpirko@redhat.com
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

6a32e4f9dd9219261f8856f817e6655114cfec2f made the vlan code skip marking
vlan-tagged frames for not locally configured vlans as PACKET_OTHERHOST if
there was an rx_handler, as the rx_handler could cause the frame to be received
on a different (virtual) vlan-capable interface where that vlan might be
configured.

As rx_handlers do not necessarily return RX_HANDLER_ANOTHER, this could cause
frames for unknown vlans to be delivered to the protocol stack as if they had
been received untagged.

For example, if an ipv6 router advertisement that's tagged for a locally not
configured vlan is received on an interface with macvlan interfaces attached,
macvlan's rx_handler returns RX_HANDLER_PASS after delivering the frame to the
macvlan interfaces, which caused it to be passed to the protocol stack, leading
to ipv6 addresses for the announced prefix being configured even though those
are completely unusable on the underlying interface.

The fix moves marking as PACKET_OTHERHOST after the rx_handler so the
rx_handler, if there is one, sees the frame unchanged, but afterwards,
before the frame is delivered to the protocol stack, it gets marked whether
there is an rx_handler or not.

Signed-off-by: Florian Zumbiehl <florz@florz.de>
---

NOTE: This was tested on 3.5.4, but massaged to apply on a recent stable
head--in any case this should be carefully reviewed by someone who knows the
code well, in case that wasn't obvious anyhow.

This version completely avoids any new state that could need to be spilled
to RAM, and instead re-checks existence and non-zeroness of the tag. What
do you think?

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index a810987..561e130 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -82,6 +82,8 @@ static inline int is_vlan_dev(struct net_device *dev)
 }
 
 #define vlan_tx_tag_present(__skb)	((__skb)->vlan_tci & VLAN_TAG_PRESENT)
+#define vlan_tx_nonzero_tag_present(__skb) \
+	(vlan_tx_tag_present(__skb) && ((__skb)->vlan_tci & VLAN_VID_MASK))
 #define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
@@ -91,7 +93,7 @@ extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
-extern bool vlan_do_receive(struct sk_buff **skb, bool last_handler);
+extern bool vlan_do_receive(struct sk_buff **skb);
 extern struct sk_buff *vlan_untag(struct sk_buff *skb);
 
 extern int vlan_vid_add(struct net_device *dev, unsigned short vid);
@@ -120,10 +122,8 @@ static inline u16 vlan_dev_vlan_id(const struct net_device *dev)
 	return 0;
 }
 
-static inline bool vlan_do_receive(struct sk_buff **skb, bool last_handler)
+static inline bool vlan_do_receive(struct sk_buff **skb)
 {
-	if (((*skb)->vlan_tci & VLAN_VID_MASK) && last_handler)
-		(*skb)->pkt_type = PACKET_OTHERHOST;
 	return false;
 }
 
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 8ca533c..f981d37 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -5,7 +5,7 @@
 #include <linux/export.h>
 #include "vlan.h"
 
-bool vlan_do_receive(struct sk_buff **skbp, bool last_handler)
+bool vlan_do_receive(struct sk_buff **skbp)
 {
 	struct sk_buff *skb = *skbp;
 	u16 vlan_id = skb->vlan_tci & VLAN_VID_MASK;
@@ -13,14 +13,8 @@ bool vlan_do_receive(struct sk_buff **skbp, bool last_handler)
 	struct vlan_pcpu_stats *rx_stats;
 
 	vlan_dev = vlan_find_dev(skb->dev, vlan_id);
-	if (!vlan_dev) {
-		/* Only the last call to vlan_do_receive() should change
-		 * pkt_type to PACKET_OTHERHOST
-		 */
-		if (vlan_id && last_handler)
-			skb->pkt_type = PACKET_OTHERHOST;
+	if (!vlan_dev)
 		return false;
-	}
 
 	skb = *skbp = skb_share_check(skb, GFP_ATOMIC);
 	if (unlikely(!skb))
diff --git a/net/core/dev.c b/net/core/dev.c
index 8398836..c580708 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3273,18 +3273,18 @@ ncls:
 				&& !skb_pfmemalloc_protocol(skb))
 		goto drop;
 
-	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (vlan_tx_tag_present(skb)) {
 		if (pt_prev) {
 			ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = NULL;
 		}
-		if (vlan_do_receive(&skb, !rx_handler))
+		if (vlan_do_receive(&skb))
 			goto another_round;
 		else if (unlikely(!skb))
 			goto unlock;
 	}
 
+	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {
 		if (pt_prev) {
 			ret = deliver_skb(skb, pt_prev, orig_dev);
@@ -3304,6 +3304,9 @@ ncls:
 		}
 	}
 
+	if (vlan_tx_nonzero_tag_present(skb))
+		skb->pkt_type = PACKET_OTHERHOST;
+
 	/* deliver only exact match when indicated */
 	null_or_dev = deliver_exact ? skb->dev : NULL;
 

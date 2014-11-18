From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net] vxlan: Inline vxlan_gso_check().
Date: Mon, 17 Nov 2014 16:24:54 -0800
Message-ID: <1416270294-21516-1-git-send-email-joestringer@nicira.com>
Cc: ogerlitz@mellanox.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Suggested-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 drivers/net/vxlan.c |   19 -------------------
 include/net/vxlan.h |   18 +++++++++++++++++-
 2 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6b65863..e1e335c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -67,12 +67,6 @@
 
 #define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
 
-/* VXLAN protocol header */
-struct vxlanhdr {
-	__be32 vx_flags;
-	__be32 vx_vni;
-};
-
 /* UDP port for VXLAN traffic.
  * The IANA assigned port is 4789, but the Linux default is 8472
  * for compatibility with early adopters.
@@ -1571,19 +1565,6 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	return false;
 }
 
-bool vxlan_gso_check(struct sk_buff *skb)
-{
-	if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
-	    (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
-	     skb->inner_protocol != htons(ETH_P_TEB) ||
-	     (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
-	      sizeof(struct udphdr) + sizeof(struct vxlanhdr))))
-		return false;
-
-	return true;
-}
-EXPORT_SYMBOL_GPL(vxlan_gso_check);
-
 #if IS_ENABLED(CONFIG_IPV6)
 static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 			   struct dst_entry *dst, struct sk_buff *skb,
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index afadf8e..57cccd0 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -8,6 +8,12 @@
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
 
+/* VXLAN protocol header */
+struct vxlanhdr {
+	__be32 vx_flags;
+	__be32 vx_vni;
+};
+
 struct vxlan_sock;
 typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb, __be32 key);
 
@@ -45,7 +51,17 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
 		   __be16 src_port, __be16 dst_port, __be32 vni, bool xnet);
 
-bool vxlan_gso_check(struct sk_buff *skb);
+static inline bool vxlan_gso_check(struct sk_buff *skb)
+{
+	if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
+	    (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
+	     skb->inner_protocol != htons(ETH_P_TEB) ||
+	     (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
+	      sizeof(struct udphdr) + sizeof(struct vxlanhdr))))
+		return false;
+
+	return true;
+}
 
 /* IP header + UDP + VXLAN + Ethernet header */
 #define VXLAN_HEADROOM (20 + 8 + 8 + 14)
-- 
1.7.10.4

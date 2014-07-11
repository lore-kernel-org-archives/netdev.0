From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/2 net-next] vxlan: Minimal support for Generic Protocol Extension (VXLAN-gpe)
Date: Fri, 11 Jul 2014 18:59:50 +0200
Message-ID: <db494140b57342d987291873dbaa2f88b2d43644.1405097440.git.tgraf@suug.ch>
References: <cover.1405097440.git.tgraf@suug.ch>
Cc: stephen@networkplumber.org, therbert@google.com,
	nicolas.dichtel@6wind.com, pshelar@nicira.com,
	xiyou.wangcong@gmail.com, ogerlitz@mellanox.com,
	dborkman@redhat.com, Madhu Challa <challa@noironetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39570 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbaGKQ77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 12:59:59 -0400
In-Reply-To: <cover.1405097440.git.tgraf@suug.ch>
In-Reply-To: <cover.1405097440.git.tgraf@suug.ch>
References: <cover.1405097440.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for the presence of the GPE bit and interpret the inner protocol
field accordingly. For now, only ethernet in VXLAN is supported. Other
protocol types will result in the packet being dropped.

Based on original work by Pritesh Kothari.

Cc: Madhu Challa <challa@noironetworks.com>
Co-authored-by: Pritesh Kothari (pritkoth) <pritesh.kothari@cisco.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/vxlan.c | 55 +++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 43 insertions(+), 12 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2e9fbcc..c9af24b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -65,28 +65,39 @@
 
 /* Base VXLAN header:
  * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * |R|R|R|R|I|R|R|R|               Reserved                        |
+ * |R|R|R|R|I|P|R|R|               Reserved                        |
  * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  * |                VXLAN Network Identifier (VNI) |   Reserved    |
  * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  *
  * I = 1	VXLAN Network Identifier (VNI) present
+ * P = 1	Generic Protocol Extension (VXLAN-gpe)
+ *
+ * VXLAN-gpe:
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |R|R|R|R|I|1|R|R|   Reserved    |     Inner Protocol Type       |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                VXLAN Network Identifier (VNI) |   Reserved    |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  */
+
 /* VXLAN protocol header */
 struct vxlanhdr {
 #ifdef __LITTLE_ENDIAN_BITFIELD
-	__u8	reserved_flags1:3,
+	__u8	reserved_flags1:2,
+		gpe:1,
 		vni_present:1,
 		reserved_flags2:4;
 #elif defined(__BIG_ENDIAN_BITFIELD)
 	__u8	reserved_flags2:4,
 		vni_present:1,
-		reserved_flags1:3;
+		gpe:1,
+		reserved_flags1:2;
 #else
 #error	"Please fix <asm/byteorder.h>"
 #endif
 	__u8	vx_reserved1;
-	__be16	vx_reserved2;
+	__be16	vx_inner_proto; /* Only valid if gpe flag is set */
 	__be32	vx_vni;
 };
 
@@ -98,8 +109,9 @@ union vxlan_oct_hdr {
 #define vxlan_flags(vxh) (((union vxlan_oct_hdr *)(vxh))->octets[0])
 
 enum {
+	VXLAN_FLAG_GPE		= 0x04,
 	VXLAN_FLAG_VNI		= 0x08,
-	VXLAN_FLAG_RESERVED	= 0xF7,
+	VXLAN_FLAG_RESERVED	= 0xF3,
 };
 
 /* UDP port for VXLAN traffic.
@@ -1162,6 +1174,26 @@ static void vxlan_igmp_leave(struct work_struct *work)
 	dev_put(vxlan->dev);
 }
 
+static int vxlan_handle_extensions(struct sk_buff *skb, struct vxlanhdr *vxh)
+{
+	if (!vxh->vni_present) {
+		netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
+			   vxlan_flags(vxh), ntohl(vxh->vx_vni));
+		return -EINVAL;
+	}
+
+	if (vxh->gpe) {
+		/* Only Ethernet in VXLAN supported for now */
+		if (vxh->vx_inner_proto != htons(ETH_P_TEB)) {
+			netdev_dbg(skb->dev, "unsupported inner vxlan proto %#x vni %#x\n",
+				   ntohs(vxh->vx_inner_proto), ntohl(vxh->vx_vni));
+			return -EPFNOSUPPORT;
+		}
+	}
+
+	return 0;
+}
+
 /* Callback from net/ipv4/udp.c to receive packets */
 static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
@@ -1173,11 +1205,10 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto error;
 
 	vxh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
-	if (!vxh->vni_present) {
-		netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
-			   vxlan_flags(vxh), ntohl(vxh->vx_vni));
-		goto error;
-	}
+
+	if (unlikely(vxlan_flags(vxh) != VXLAN_FLAG_VNI))
+		if (vxlan_handle_extensions(skb, vxh) < 0)
+			goto error;
 
 	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
 		goto drop;
@@ -1648,7 +1679,7 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxlan_flags(vxh) = VXLAN_FLAG_VNI;
 	vxh->vx_reserved1 = 0;
-	vxh->vx_reserved2 = 0;
+	vxh->vx_inner_proto = 0;
 	vxh->vx_vni = vni;
 
 	__skb_push(skb, sizeof(*uh));
@@ -1722,7 +1753,7 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxlan_flags(vxh) = VXLAN_FLAG_VNI;
 	vxh->vx_reserved1 = 0;
-	vxh->vx_reserved2 = 0;
+	vxh->vx_inner_proto = 0;
 	vxh->vx_vni = vni;
 
 	__skb_push(skb, sizeof(*uh));
-- 
1.9.3

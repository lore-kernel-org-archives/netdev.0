From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/6] vxlan: Allow for VXLAN extensions to be implemented
Date: Wed,  7 Jan 2015 03:05:36 +0100
Message-ID: <7c5e8240263a22a69042c45a632c9940e5ae1062.1420594925.git.tgraf@suug.ch>
References: <cover.1420594925.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: davem@davemloft.net, jesse@nicira.com, stephen@networkplumber.org,
	pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42676 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696AbbAGCFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 21:05:49 -0500
In-Reply-To: <cover.1420594925.git.tgraf@suug.ch>
In-Reply-To: <cover.1420594925.git.tgraf@suug.ch>
References: <cover.1420594925.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VXLAN receive code is currently conservative in what it accepts and
will reject any frame that uses any of the reserved VXLAN protocol fields.
The VXLAN draft specifies that "reserved fields MUST be set to zero on
transmit and ignored on receive.".

Retain the current conservative parsing behaviour by default but allows
these fields to be used by VXLAN extensions which are explicitly enabled
on the VXLAN socket respectively VXLAN net_device.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/vxlan.c | 29 +++++++++++++++++++----------
 include/net/vxlan.h | 32 +++++++++++++++++++++++++++++---
 2 files changed, 48 insertions(+), 13 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2ab0922..4d52aa9 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -65,7 +65,7 @@
 #define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
 #define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
 
-#define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
+#define VXLAN_FLAGS 0x08000000 /* struct vxlanhdr.vx_flags default value. */
 
 /* UDP port for VXLAN traffic.
  * The IANA assigned port is 4789, but the Linux default is 8472
@@ -1100,22 +1100,28 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
 		goto error;
 
+	vs = rcu_dereference_sk_user_data(sk);
+	if (!vs)
+		goto drop;
+
 	/* Return packets with reserved bits set */
 	vxh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
-	if (vxh->vx_flags != htonl(VXLAN_FLAGS) ||
-	    (vxh->vx_vni & htonl(0xff))) {
-		netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
-			   ntohl(vxh->vx_flags), ntohl(vxh->vx_vni));
-		goto error;
+
+	/* For backwards compatibility, only allow reserved fields to be
+	 * used by VXLAN extensions if explicitly requested.
+	 */
+	if (vs->exts) {
+		if (!vxh->vni_present)
+			goto error_invalid_header;
+	} else {
+		if (vxh->vx_flags != htonl(VXLAN_FLAGS) ||
+		    (vxh->vx_vni & htonl(0xff)))
+			goto error_invalid_header;
 	}
 
 	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
 		goto drop;
 
-	vs = rcu_dereference_sk_user_data(sk);
-	if (!vs)
-		goto drop;
-
 	vs->rcv(vs, skb, vxh->vx_vni);
 	return 0;
 
@@ -1124,6 +1130,9 @@ drop:
 	kfree_skb(skb);
 	return 0;
 
+error_invalid_header:
+	netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
+		   ntohl(vxh->vx_flags), ntohl(vxh->vx_vni));
 error:
 	/* Return non vxlan pkt */
 	return 1;
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 903461a..3e98d31 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -11,10 +11,35 @@
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
 
-/* VXLAN protocol header */
+/* VXLAN protocol header:
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |R|R|R|R|I|R|R|R|               Reserved                        |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                VXLAN Network Identifier (VNI) |   Reserved    |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * I = 1	VXLAN Network Identifier (VNI) present
+ */
 struct vxlanhdr {
-	__be32 vx_flags;
-	__be32 vx_vni;
+	union {
+		struct {
+#ifdef __LITTLE_ENDIAN_BITFIELD
+			__u8	reserved_flags1:3,
+				vni_present:1,
+				reserved_flags2:4;
+#elif defined(__BIG_ENDIAN_BITFIELD)
+			__u8	reserved_flags2:4,
+				vni_present:1,
+				reserved_flags1:3;
+#else
+#error	"Please fix <asm/byteorder.h>"
+#endif
+			__u8	vx_reserved1;
+			__be16	vx_reserved2;
+		};
+		__be32 vx_flags;
+	};
+	__be32	vx_vni;
 };
 
 struct vxlan_sock;
@@ -25,6 +50,7 @@ struct vxlan_sock {
 	struct hlist_node hlist;
 	vxlan_rcv_t	 *rcv;
 	void		 *data;
+	u32		  exts;
 	struct work_struct del_work;
 	struct socket	 *sock;
 	struct rcu_head	  rcu;
-- 
1.9.3

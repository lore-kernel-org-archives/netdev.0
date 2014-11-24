From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 3/3] vxlan: Remote checksum offload
Date: Mon, 24 Nov 2014 15:52:30 -0800
Message-ID: <1416873150-12260-4-git-send-email-therbert@google.com>
References: <1416873150-12260-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:51034 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbaKXXxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 18:53:09 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so9950686ier.18
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 15:53:08 -0800 (PST)
In-Reply-To: <1416873150-12260-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for remote checksum offload in VXLAN. This commandeers a
reserved bit to indicate that RCO is being done, and uses the low order
reserved eight bits of the VNI to hold the start and offset values in a
compressed manner.

Start is encoded in the low order seven bits of VNI. This is start >> 1
so that the checksum start offset is 0-254 using even values only.
Checksum offset (transport checksum field) is indicated in the high
order bit in the low order byte of the VNI. If the bit is set, the
checksum field is for UDP (so offset = start + 6), else checksum
field is for TCP (so offset = start + 16). Only TCP and UDP are
supported in this implementation.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c          | 188 +++++++++++++++++++++++++++++++++++++++++--
 include/net/vxlan.h          |   2 +
 include/uapi/linux/if_link.h |   1 +
 3 files changed, 183 insertions(+), 8 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e9f81d4..763f95e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -65,7 +65,17 @@
 #define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
 #define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
 
-#define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
+#define VXLAN_F_REQ	htonl(0x08000000) /* Required VXLAN flag */
+#define VXLAN_F_RCO	htonl(0x00400000) /* Remote checksum offload */
+
+#define VXLAN_MANDATORY_FLAGS (VXLAN_F_REQ)
+#define VXLAN_ALL_FLAGS (VXLAN_F_REQ | VXLAN_F_RCO)
+
+#define VXLAN_RCO_MASK	0x7f	/* Last byte of vni field */
+#define VXLAN_RCO_UDP	0x80	/* Indicate UDP RCO (TCP when not set *) */
+#define VXLAN_RCO_SHIFT	1	/* Left shift of start */
+#define VXLAN_RCO_SHIFT_MASK ((1 << VXLAN_RCO_SHIFT) - 1)
+#define VXLAN_MAX_REMCSUM_START (VXLAN_RCO_MASK << VXLAN_RCO_SHIFT)
 
 /* UDP port for VXLAN traffic.
  * The IANA assigned port is 4789, but the Linux default is 8472
@@ -545,6 +555,46 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 	return 1;
 }
 
+static struct vxlanhdr *vxlan_gro_remcsum(struct sk_buff *skb,
+					  unsigned int off,
+					  struct vxlanhdr *vh, size_t hdrlen,
+					  u32 data)
+{
+	size_t start, offset, plen;
+	__wsum delta;
+
+	if (skb->remcsum_offload)
+		return vh;
+
+	if (!NAPI_GRO_CB(skb)->csum_valid)
+		return NULL;
+
+	start = (data & VXLAN_RCO_MASK) << VXLAN_RCO_SHIFT;
+	offset = start + ((data & VXLAN_RCO_UDP) ?
+			  offsetof(struct udphdr, check) :
+			  offsetof(struct tcphdr, check));
+
+	plen = hdrlen + offset + sizeof(u16);
+
+	/* Pull checksum that will be written */
+	if (skb_gro_header_hard(skb, off + plen)) {
+		vh = skb_gro_header_slow(skb, off + plen, off);
+		if (!vh)
+			return NULL;
+	}
+
+	delta = remcsum_adjust((void *)vh + hdrlen,
+			       NAPI_GRO_CB(skb)->csum, start, offset);
+
+	/* Adjust skb->csum since we changed the packet */
+	skb->csum = csum_add(skb->csum, delta);
+	NAPI_GRO_CB(skb)->csum = csum_add(NAPI_GRO_CB(skb)->csum, delta);
+
+	skb->remcsum_offload = 1;
+
+	return vh;
+}
+
 static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
 	struct sk_buff *p, **pp = NULL;
@@ -566,6 +616,14 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff
 	skb_gro_pull(skb, sizeof(struct vxlanhdr)); /* pull vxlan header */
 	skb_gro_postpull_rcsum(skb, vh, sizeof(struct vxlanhdr));
 
+	if (vh->vx_flags & VXLAN_F_RCO) {
+		vh = vxlan_gro_remcsum(skb, off_vx, vh, sizeof(struct vxlanhdr),
+				       ntohl(vh->vx_vni));
+
+		if (!vh)
+			goto out;
+	}
+
 	off_eth = skb_gro_offset(skb);
 	hlen = off_eth + sizeof(*eh);
 	eh   = skb_gro_header_fast(skb, off_eth);
@@ -1131,6 +1189,42 @@ static void vxlan_igmp_leave(struct work_struct *work)
 	dev_put(vxlan->dev);
 }
 
+static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
+				      size_t hdrlen, u32 data)
+{
+	size_t start, offset, plen;
+	__wsum delta;
+
+	if (skb->remcsum_offload) {
+		/* Already processed in GRO path */
+		skb->remcsum_offload = 0;
+		return vh;
+	}
+
+	start = (data & VXLAN_RCO_MASK) << VXLAN_RCO_SHIFT;
+	offset = start + ((data & VXLAN_RCO_UDP) ?
+			  offsetof(struct udphdr, check) :
+			  offsetof(struct tcphdr, check));
+
+	plen = hdrlen + offset + sizeof(u16);
+
+	if (!pskb_may_pull(skb, plen))
+		return NULL;
+
+	vh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
+
+	if (unlikely(skb->ip_summed != CHECKSUM_COMPLETE))
+		__skb_checksum_complete(skb);
+
+	delta = remcsum_adjust((void *)vh + hdrlen,
+			       skb->csum, start, offset);
+
+	/* Adjust skb->csum since we changed the packet */
+	skb->csum = csum_add(skb->csum, delta);
+
+	return vh;
+}
+
 /* Callback from net/ipv4/udp.c to receive packets */
 static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
@@ -1143,8 +1237,8 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	/* Return packets with reserved bits set */
 	vxh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
-	if (vxh->vx_flags != htonl(VXLAN_FLAGS) ||
-	    (vxh->vx_vni & htonl(0xff))) {
+	if ((vxh->vx_flags & VXLAN_MANDATORY_FLAGS) != VXLAN_MANDATORY_FLAGS ||
+	    (vxh->vx_flags & ~VXLAN_ALL_FLAGS)) {
 		netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
 			   ntohl(vxh->vx_flags), ntohl(vxh->vx_vni));
 		goto error;
@@ -1152,6 +1246,14 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
 		goto drop;
+	vxh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
+
+	if (vxh->vx_flags & VXLAN_F_RCO) {
+		vxh = vxlan_remcsum(skb, vxh, sizeof(struct vxlanhdr),
+				    ntohl(vxh->vx_vni));
+		if (!vxh)
+			goto drop;
+	}
 
 	vs = rcu_dereference_sk_user_data(sk);
 	if (!vs)
@@ -1577,8 +1679,23 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	int min_headroom;
 	int err;
 	bool udp_sum = !udp_get_no_check6_tx(vs->sock->sk);
+	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+	u16 hdrlen = sizeof(struct vxlanhdr);
+
+	if ((vs->flags & VXLAN_F_REMCSUM) &&
+	    skb->ip_summed == CHECKSUM_PARTIAL) {
+		int csum_start = skb_checksum_start_offset(skb);
+
+		if (csum_start <= VXLAN_MAX_REMCSUM_START &&
+		    !(csum_start & VXLAN_RCO_SHIFT_MASK) &&
+		    (skb->csum_offset == offsetof(struct udphdr, check) ||
+		     skb->csum_offset == offsetof(struct tcphdr, check))) {
+			udp_sum = false;
+			type |= SKB_GSO_TUNNEL_REMCSUM;
+		}
+	}
 
-	skb = udp_tunnel_handle_offloads(skb, udp_sum);
+	skb = iptunnel_handle_offloads(skb, udp_sum, type);
 	if (IS_ERR(skb))
 		return -EINVAL;
 
@@ -1598,9 +1715,25 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 		return -ENOMEM;
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
-	vxh->vx_flags = htonl(VXLAN_FLAGS);
+	vxh->vx_flags = VXLAN_MANDATORY_FLAGS;
 	vxh->vx_vni = vni;
 
+	if (type & SKB_GSO_TUNNEL_REMCSUM) {
+		u32 data = (skb_checksum_start_offset(skb) - hdrlen) >>
+			   VXLAN_RCO_SHIFT;
+
+		if (skb->csum_offset == offsetof(struct udphdr, check))
+			data |= VXLAN_RCO_UDP;
+
+		vxh->vx_vni |= htonl(data);
+		vxh->vx_flags |= VXLAN_F_RCO;
+
+		if (!skb_is_gso(skb)) {
+			skb->ip_summed = CHECKSUM_NONE;
+			skb->encapsulation = 0;
+		}
+	}
+
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	udp_tunnel6_xmit_skb(vs->sock, dst, skb, dev, saddr, daddr, prio,
@@ -1618,8 +1751,23 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	int min_headroom;
 	int err;
 	bool udp_sum = !vs->sock->sk->sk_no_check_tx;
+	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+	u16 hdrlen = sizeof(struct vxlanhdr);
+
+	if ((vs->flags & VXLAN_F_REMCSUM) &&
+	    skb->ip_summed == CHECKSUM_PARTIAL) {
+		int csum_start = skb_checksum_start_offset(skb);
+
+		if (csum_start <= VXLAN_MAX_REMCSUM_START &&
+		    !(csum_start & VXLAN_RCO_SHIFT_MASK) &&
+		    (skb->csum_offset == offsetof(struct udphdr, check) ||
+		     skb->csum_offset == offsetof(struct tcphdr, check))) {
+			udp_sum = false;
+			type |= SKB_GSO_TUNNEL_REMCSUM;
+		}
+	}
 
-	skb = udp_tunnel_handle_offloads(skb, udp_sum);
+	skb = iptunnel_handle_offloads(skb, udp_sum, type);
 	if (IS_ERR(skb))
 		return -EINVAL;
 
@@ -1637,9 +1785,25 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 		return -ENOMEM;
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
-	vxh->vx_flags = htonl(VXLAN_FLAGS);
+	vxh->vx_flags = VXLAN_MANDATORY_FLAGS;
 	vxh->vx_vni = vni;
 
+	if (type & SKB_GSO_TUNNEL_REMCSUM) {
+		u32 data = (skb_checksum_start_offset(skb) - hdrlen) >>
+			   VXLAN_RCO_SHIFT;
+
+		if (skb->csum_offset == offsetof(struct udphdr, check))
+			data |= VXLAN_RCO_UDP;
+
+		vxh->vx_vni |= htonl(data);
+		vxh->vx_flags |= VXLAN_F_RCO;
+
+		if (!skb_is_gso(skb)) {
+			skb->ip_summed = CHECKSUM_NONE;
+			skb->encapsulation = 0;
+		}
+	}
+
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	return udp_tunnel_xmit_skb(vs->sock, rt, skb, src, dst, tos,
@@ -2229,6 +2393,7 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_UDP_CSUM]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_REMCSUM]	= { .type = NLA_U8 },
 };
 
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -2350,6 +2515,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	atomic_set(&vs->refcnt, 1);
 	vs->rcv = rcv;
 	vs->data = data;
+	vs->flags = flags;
 
 	/* Initialize the vxlan udp offloads structure */
 	vs->udp_offloads.port = port;
@@ -2547,6 +2713,9 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
 		vxlan->flags |= VXLAN_F_UDP_ZERO_CSUM6_RX;
 
+	if (data[IFLA_VXLAN_REMCSUM] && nla_get_u8(data[IFLA_VXLAN_REMCSUM]))
+		vxlan->flags |= VXLAN_F_REMCSUM;
+
 	if (vxlan_find_vni(net, vni, use_ipv6 ? AF_INET6 : AF_INET,
 			   vxlan->dst_port)) {
 		pr_info("duplicate VNI %u\n", vni);
@@ -2615,6 +2784,7 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_UDP_CSUM */
 		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_UDP_ZERO_CSUM6_TX */
 		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_UDP_ZERO_CSUM6_RX */
+		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_REMCSUM */
 		0;
 }
 
@@ -2680,7 +2850,9 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
 			!!(vxlan->flags & VXLAN_F_UDP_ZERO_CSUM6_TX)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
-			!!(vxlan->flags & VXLAN_F_UDP_ZERO_CSUM6_RX)))
+			!!(vxlan->flags & VXLAN_F_UDP_ZERO_CSUM6_RX)) ||
+	    nla_put_u8(skb, IFLA_VXLAN_REMCSUM,
+			!!(vxlan->flags & VXLAN_F_REMCSUM)))
 		goto nla_put_failure;
 
 	if (nla_put(skb, IFLA_VXLAN_PORT_RANGE, sizeof(ports), &ports))
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 57cccd0..652e0dc 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -28,6 +28,7 @@ struct vxlan_sock {
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 	atomic_t	  refcnt;
 	struct udp_offload udp_offloads;
+	u32		  flags;
 };
 
 #define VXLAN_F_LEARN			0x01
@@ -39,6 +40,7 @@ struct vxlan_sock {
 #define VXLAN_F_UDP_CSUM		0x40
 #define VXLAN_F_UDP_ZERO_CSUM6_TX	0x80
 #define VXLAN_F_UDP_ZERO_CSUM6_RX	0x100
+#define VXLAN_F_REMCSUM			0x200
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 7072d83..d9e31e2 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -353,6 +353,7 @@ enum {
 	IFLA_VXLAN_UDP_CSUM,
 	IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
 	IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
+	IFLA_VXLAN_REMCSUM,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
-- 
2.1.0.rc2.206.gedb03e5

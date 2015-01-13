From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next v2 2/2] vxlan: Remote checksum offload
Date: Mon, 12 Jan 2015 17:00:38 -0800
Message-ID: <1421110838-5146-3-git-send-email-therbert@google.com>
References: <1421110838-5146-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:40694 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929AbbAMBBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 20:01:17 -0500
Received: by mail-ie0-f169.google.com with SMTP id y20so206643ier.0
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 17:01:17 -0800 (PST)
In-Reply-To: <1421110838-5146-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for remote checksum offload in VXLAN. This uses a
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

Remote checksum offload for VXLAN is described in:

https://tools.ietf.org/html/draft-herbert-vxlan-rco-00

Tested by running 200 TCP_STREAM connections with VXLAN (over IPv4).

With UDP checksums and Remote Checksum Offload
  IPv4
      Client
        11.84% CPU utilization
      Server
        12.96% CPU utilization
      9197 Mbps
  IPv6
      Client
        12.46% CPU utilization
      Server
        14.48% CPU utilization
      8963 Mbps

With UDP checksums, no remote checksum offload
  IPv4
      Client
        15.67% CPU utilization
      Server
        14.83% CPU utilization
      9094 Mbps
  IPv6
      Client
        16.21% CPU utilization
      Server
        14.32% CPU utilization
      9058 Mbps

No UDP checksums
  IPv4
      Client
        15.03% CPU utilization
      Server
        23.09% CPU utilization
      9089 Mbps
  IPv6
      Client
        16.18% CPU utilization
      Server
        26.57% CPU utilization
       8954 Mbps

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c          | 191 +++++++++++++++++++++++++++++++++++++++++--
 include/net/vxlan.h          |  11 +++
 include/uapi/linux/if_link.h |   2 +
 3 files changed, 198 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 90e2f49..2cdab2b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -539,6 +539,46 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
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
 static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 					  struct sk_buff *skb,
 					  struct udp_offload *uoff)
@@ -547,6 +587,9 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 	struct vxlanhdr *vh, *vh2;
 	unsigned int hlen, off_vx;
 	int flush = 1;
+	struct vxlan_sock *vs = container_of(uoff, struct vxlan_sock,
+					     udp_offloads);
+	u32 flags;
 
 	off_vx = skb_gro_offset(skb);
 	hlen = off_vx + sizeof(*vh);
@@ -557,6 +600,19 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 			goto out;
 	}
 
+	skb_gro_pull(skb, sizeof(struct vxlanhdr)); /* pull vxlan header */
+	skb_gro_postpull_rcsum(skb, vh, sizeof(struct vxlanhdr));
+
+	flags = ntohl(vh->vx_flags);
+
+	if ((flags & VXLAN_HF_RCO) && (vs->flags & VXLAN_F_REMCSUM_RX)) {
+		vh = vxlan_gro_remcsum(skb, off_vx, vh, sizeof(struct vxlanhdr),
+				       ntohl(vh->vx_vni));
+
+		if (!vh)
+			goto out;
+	}
+
 	flush = 0;
 
 	for (p = *head; p; p = p->next) {
@@ -570,8 +626,6 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 		}
 	}
 
-	skb_gro_pull(skb, sizeof(struct vxlanhdr));
-	skb_gro_postpull_rcsum(skb, vh, sizeof(struct vxlanhdr));
 	pp = eth_gro_receive(head, skb);
 
 out:
@@ -1087,6 +1141,42 @@ static void vxlan_igmp_leave(struct work_struct *work)
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
@@ -1111,12 +1201,22 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
 		goto drop;
+	vxh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
 
 	vs = rcu_dereference_sk_user_data(sk);
 	if (!vs)
 		goto drop;
 
-	if (flags || (vni & 0xff)) {
+	if ((flags & VXLAN_HF_RCO) && (vs->flags & VXLAN_F_REMCSUM_RX)) {
+		vxh = vxlan_remcsum(skb, vxh, sizeof(struct vxlanhdr), vni);
+		if (!vxh)
+			goto drop;
+
+		flags &= ~VXLAN_HF_RCO;
+		vni &= VXLAN_VID_MASK;
+	}
+
+	if (flags || (vni & ~VXLAN_VID_MASK)) {
 		/* If there are any unprocessed flags remaining treat
 		 * this as a malformed packet. This behavior diverges from
 		 * VXLAN RFC (RFC7348) which stipulates that bits in reserved
@@ -1553,8 +1653,23 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	int min_headroom;
 	int err;
 	bool udp_sum = !udp_get_no_check6_tx(vs->sock->sk);
+	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+	u16 hdrlen = sizeof(struct vxlanhdr);
+
+	if ((vs->flags & VXLAN_F_REMCSUM_TX) &&
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
 	if (IS_ERR(skb)) {
 		err = -EINVAL;
 		goto err;
@@ -1583,6 +1698,22 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	vxh->vx_flags = htonl(VXLAN_HF_VNI);
 	vxh->vx_vni = vni;
 
+	if (type & SKB_GSO_TUNNEL_REMCSUM) {
+		u32 data = (skb_checksum_start_offset(skb) - hdrlen) >>
+			   VXLAN_RCO_SHIFT;
+
+		if (skb->csum_offset == offsetof(struct udphdr, check))
+			data |= VXLAN_RCO_UDP;
+
+		vxh->vx_vni |= htonl(data);
+		vxh->vx_flags |= htonl(VXLAN_HF_RCO);
+
+		if (!skb_is_gso(skb)) {
+			skb->ip_summed = CHECKSUM_NONE;
+			skb->encapsulation = 0;
+		}
+	}
+
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	udp_tunnel6_xmit_skb(vs->sock, dst, skb, dev, saddr, daddr, prio,
@@ -1603,8 +1734,23 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	int min_headroom;
 	int err;
 	bool udp_sum = !vs->sock->sk->sk_no_check_tx;
+	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+	u16 hdrlen = sizeof(struct vxlanhdr);
+
+	if ((vs->flags & VXLAN_F_REMCSUM_TX) &&
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
 		return PTR_ERR(skb);
 
@@ -1627,6 +1773,22 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	vxh->vx_flags = htonl(VXLAN_HF_VNI);
 	vxh->vx_vni = vni;
 
+	if (type & SKB_GSO_TUNNEL_REMCSUM) {
+		u32 data = (skb_checksum_start_offset(skb) - hdrlen) >>
+			   VXLAN_RCO_SHIFT;
+
+		if (skb->csum_offset == offsetof(struct udphdr, check))
+			data |= VXLAN_RCO_UDP;
+
+		vxh->vx_vni |= htonl(data);
+		vxh->vx_flags |= htonl(VXLAN_HF_RCO);
+
+		if (!skb_is_gso(skb)) {
+			skb->ip_summed = CHECKSUM_NONE;
+			skb->encapsulation = 0;
+		}
+	}
+
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	return udp_tunnel_xmit_skb(vs->sock, rt, skb, src, dst, tos,
@@ -2218,6 +2380,8 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_UDP_CSUM]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_REMCSUM_TX]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_REMCSUM_RX]	= { .type = NLA_U8 },
 };
 
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -2339,6 +2503,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	atomic_set(&vs->refcnt, 1);
 	vs->rcv = rcv;
 	vs->data = data;
+	vs->flags = flags;
 
 	/* Initialize the vxlan udp offloads structure */
 	vs->udp_offloads.port = port;
@@ -2533,6 +2698,14 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
 		vxlan->flags |= VXLAN_F_UDP_ZERO_CSUM6_RX;
 
+	if (data[IFLA_VXLAN_REMCSUM_TX] &&
+	    nla_get_u8(data[IFLA_VXLAN_REMCSUM_TX]))
+		vxlan->flags |= VXLAN_F_REMCSUM_TX;
+
+	if (data[IFLA_VXLAN_REMCSUM_RX] &&
+	    nla_get_u8(data[IFLA_VXLAN_REMCSUM_RX]))
+		vxlan->flags |= VXLAN_F_REMCSUM_RX;
+
 	if (vxlan_find_vni(net, vni, use_ipv6 ? AF_INET6 : AF_INET,
 			   vxlan->dst_port)) {
 		pr_info("duplicate VNI %u\n", vni);
@@ -2601,6 +2774,8 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_UDP_CSUM */
 		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_UDP_ZERO_CSUM6_TX */
 		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_UDP_ZERO_CSUM6_RX */
+		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_REMCSUM_TX */
+		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_REMCSUM_RX */
 		0;
 }
 
@@ -2666,7 +2841,11 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
 			!!(vxlan->flags & VXLAN_F_UDP_ZERO_CSUM6_TX)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
-			!!(vxlan->flags & VXLAN_F_UDP_ZERO_CSUM6_RX)))
+			!!(vxlan->flags & VXLAN_F_UDP_ZERO_CSUM6_RX)) ||
+	    nla_put_u8(skb, IFLA_VXLAN_REMCSUM_TX,
+			!!(vxlan->flags & VXLAN_F_REMCSUM_TX)) ||
+	    nla_put_u8(skb, IFLA_VXLAN_REMCSUM_RX,
+			!!(vxlan->flags & VXLAN_F_REMCSUM_RX)))
 		goto nla_put_failure;
 
 	if (nla_put(skb, IFLA_VXLAN_PORT_RANGE, sizeof(ports), &ports))
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index a0d8073..0a7443b 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -19,6 +19,14 @@ struct vxlanhdr {
 
 /* VXLAN header flags. */
 #define VXLAN_HF_VNI 0x08000000
+#define VXLAN_HF_RCO 0x00200000
+
+/* Remote checksum offload header option */
+#define VXLAN_RCO_MASK  0x7f    /* Last byte of vni field */
+#define VXLAN_RCO_UDP   0x80    /* Indicate UDP RCO (TCP when not set *) */
+#define VXLAN_RCO_SHIFT 1       /* Left shift of start */
+#define VXLAN_RCO_SHIFT_MASK ((1 << VXLAN_RCO_SHIFT) - 1)
+#define VXLAN_MAX_REMCSUM_START (VXLAN_RCO_MASK << VXLAN_RCO_SHIFT)
 
 #define VXLAN_N_VID     (1u << 24)
 #define VXLAN_VID_MASK  (VXLAN_N_VID - 1)
@@ -38,6 +46,7 @@ struct vxlan_sock {
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 	atomic_t	  refcnt;
 	struct udp_offload udp_offloads;
+	u32		  flags;
 };
 
 #define VXLAN_F_LEARN			0x01
@@ -49,6 +58,8 @@ struct vxlan_sock {
 #define VXLAN_F_UDP_CSUM		0x40
 #define VXLAN_F_UDP_ZERO_CSUM6_TX	0x80
 #define VXLAN_F_UDP_ZERO_CSUM6_RX	0x100
+#define VXLAN_F_REMCSUM_TX		0x200
+#define VXLAN_F_REMCSUM_RX		0x400
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index f7d0d2d..b2723f6 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -370,6 +370,8 @@ enum {
 	IFLA_VXLAN_UDP_CSUM,
 	IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
 	IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
+	IFLA_VXLAN_REMCSUM_TX,
+	IFLA_VXLAN_REMCSUM_RX,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
-- 
2.2.0.rc0.207.ga3a616c

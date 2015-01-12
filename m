From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Mon, 12 Jan 2015 18:37:37 +0100
Message-ID: <54B40661.9020408@6wind.com>
References: <cover.1420756324.git.tgraf@suug.ch> <7339e3bff124cecaf65cd04ea9bdc973c730ba34.1420756324.git.tgraf@suug.ch>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net, jesse@nicira.com,
	stephen@networkplumber.org, pshelar@nicira.com,
	therbert@google.com, alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:45723 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbALRhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 12:37:41 -0500
Received: by mail-la0-f50.google.com with SMTP id pn19so25656922lab.9
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 09:37:40 -0800 (PST)
In-Reply-To: <7339e3bff124cecaf65cd04ea9bdc973c730ba34.1420756324.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/01/2015 23:47, Thomas Graf a =C3=A9crit :
> Implements supports for the Group Policy VXLAN extension [0] to provi=
de
> a lightweight and simple security label mechanism across network peer=
s
> based on VXLAN. The security context and associated metadata is mappe=
d
> to/from skb->mark. This allows further mapping to a SELinux context
> using SECMARK, to implement ACLs directly with nftables, iptables, OV=
S,
> tc, etc.
>
> The group membership is defined by the lower 16 bits of skb->mark, th=
e
> upper 16 bits are used for flags.
>
> SELinux allows to manage label to secure local resources. However,
> distributed applications require ACLs to implemented across hosts. Th=
is
> is typically achieved by matching on L2-L4 fields to identify the
> original sending host and process on the receiver. On top of that,
> netlabel and specifically CIPSO [1] allow to map security contexts to
> universal labels.  However, netlabel and CIPSO are relatively complex=
=2E
> This patch provides a lightweight alternative for overlay network
> environments with a trusted underlay. No additional control protocol
> is required.
>
>             Host 1:                       Host 2:
>
>        Group A        Group B        Group B     Group A
>        +-----+   +-------------+    +-------+   +-----+
>        | lxc |   | SELinux CTX |    | httpd |   | VM  |
>        +--+--+   +--+----------+    +---+---+   +--+--+
> 	  \---+---/                     \----+---/
> 	      |                              |
> 	  +---+---+                      +---+---+
> 	  | vxlan |                      | vxlan |
> 	  +---+---+                      +---+---+
> 	      +------------------------------+
>
> Backwards compatibility:
> A VXLAN-GBP socket can receive standard VXLAN frames and will assign
> the default group 0x0000 to such frames. A Linux VXLAN socket will
> drop VXLAN-GBP  frames. The extension is therefore disabled by defaul=
t
> and needs to be specifically enabled:
>
>     ip link add [...] type vxlan [...] gbp
>
> In a mixed environment with VXLAN and VXLAN-GBP sockets, the GBP sock=
et
> must run on a separate port number.
>
> Examples:
>   iptables:
>    host1# iptables -I OUTPUT -m owner --uid-owner 101 -j MARK --set-m=
ark 0x200
>    host2# iptables -I INPUT -m mark --mark 0x200 -j DROP
>
>   OVS:
>    # ovs-ofctl add-flow br0 'in_port=3D1,actions=3Dload:0x200->NXM_NX=
_TUN_GBP_ID[],NORMAL'
>    # ovs-ofctl add-flow br0 'in_port=3D2,tun_gbp_id=3D0x200,actions=3D=
drop'
>
> [0] https://tools.ietf.org/html/draft-smith-vxlan-group-policy
> [1] http://lwn.net/Articles/204905/
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> v2:
>   - split GBP header definition into separate struct vxlanhdr_gbp as =
requested
>     by Alexei
>
>   drivers/net/vxlan.c           | 161 ++++++++++++++++++++++++++++++-=
-----------
>   include/net/vxlan.h           |  73 +++++++++++++++++--
>   include/uapi/linux/if_link.h  |   8 +++
>   net/openvswitch/vport-vxlan.c |   9 ++-
>   4 files changed, 198 insertions(+), 53 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 4d52aa9..b148739 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -132,6 +132,7 @@ struct vxlan_dev {
>   	__u8		  tos;		/* TOS override */
>   	__u8		  ttl;
>   	u32		  flags;	/* VXLAN_F_* in vxlan.h */
> +	u32		  exts;		/* Enabled extensions */
>
>   	struct work_struct sock_work;
>   	struct work_struct igmp_join;
> @@ -568,7 +569,8 @@ static struct sk_buff **vxlan_gro_receive(struct =
sk_buff **head, struct sk_buff
>   			continue;
>
>   		vh2 =3D (struct vxlanhdr *)(p->data + off_vx);
> -		if (vh->vx_vni !=3D vh2->vx_vni) {
> +		if (vh->vx_flags !=3D vh2->vx_flags ||
> +		    vh->vx_vni !=3D vh2->vx_vni) {
>   			NAPI_GRO_CB(p)->same_flow =3D 0;
>   			continue;
>   		}
> @@ -1095,6 +1097,7 @@ static int vxlan_udp_encap_recv(struct sock *sk=
, struct sk_buff *skb)
>   {
>   	struct vxlan_sock *vs;
>   	struct vxlanhdr *vxh;
> +	struct vxlan_metadata md =3D {0};
>
>   	/* Need Vxlan and inner Ethernet header to be present */
>   	if (!pskb_may_pull(skb, VXLAN_HLEN))
> @@ -1113,6 +1116,22 @@ static int vxlan_udp_encap_recv(struct sock *s=
k, struct sk_buff *skb)
>   	if (vs->exts) {
>   		if (!vxh->vni_present)
>   			goto error_invalid_header;
> +
> +		if (vxh->gbp_present) {
> +			struct vxlanhdr_gbp *gbp;
> +
> +			if (!(vs->exts & VXLAN_EXT_GBP))
> +				goto error_invalid_header;
> +
> +			gbp =3D (struct vxlanhdr_gbp *)vxh;
> +			md.gbp =3D ntohs(gbp->policy_id);
> +
> +			if (gbp->dont_learn)
> +				md.gbp |=3D VXLAN_GBP_DONT_LEARN;
> +
> +			if (gbp->policy_applied)
> +				md.gbp |=3D VXLAN_GBP_POLICY_APPLIED;
> +		}
>   	} else {
>   		if (vxh->vx_flags !=3D htonl(VXLAN_FLAGS) ||
>   		    (vxh->vx_vni & htonl(0xff)))
> @@ -1122,7 +1141,8 @@ static int vxlan_udp_encap_recv(struct sock *sk=
, struct sk_buff *skb)
>   	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
>   		goto drop;
>
> -	vs->rcv(vs, skb, vxh->vx_vni);
> +	md.vni =3D vxh->vx_vni;
> +	vs->rcv(vs, skb, &md);
>   	return 0;
>
>   drop:
> @@ -1138,8 +1158,8 @@ error:
>   	return 1;
>   }
>
> -static void vxlan_rcv(struct vxlan_sock *vs,
> -		      struct sk_buff *skb, __be32 vx_vni)
> +static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
> +		      struct vxlan_metadata *md)
>   {
>   	struct iphdr *oip =3D NULL;
>   	struct ipv6hdr *oip6 =3D NULL;
> @@ -1150,7 +1170,7 @@ static void vxlan_rcv(struct vxlan_sock *vs,
>   	int err =3D 0;
>   	union vxlan_addr *remote_ip;
>
> -	vni =3D ntohl(vx_vni) >> 8;
> +	vni =3D ntohl(md->vni) >> 8;
>   	/* Is this VNI defined? */
>   	vxlan =3D vxlan_vs_find_vni(vs, vni);
>   	if (!vxlan)
> @@ -1184,6 +1204,7 @@ static void vxlan_rcv(struct vxlan_sock *vs,
>   		goto drop;
>
>   	skb_reset_network_header(skb);
> +	skb->mark =3D md->gbp;
>
>   	if (oip6)
>   		err =3D IP6_ECN_decapsulate(oip6, skb);
> @@ -1533,15 +1554,57 @@ static bool route_shortcircuit(struct net_dev=
ice *dev, struct sk_buff *skb)
>   	return false;
>   }
>
> +static int vxlan_build_hdr(struct sk_buff *skb, struct vxlan_sock *v=
s,
> +			   int min_headroom, struct vxlan_metadata *md)
> +{
> +	struct vxlanhdr *vxh;
> +	int err;
> +
> +	/* Need space for new headers (invalidates iph ptr) */
> +	err =3D skb_cow_head(skb, min_headroom);
> +	if (unlikely(err)) {
> +		kfree_skb(skb);
> +		return err;
> +	}
> +
> +	skb =3D vlan_hwaccel_push_inside(skb);
> +	if (WARN_ON(!skb))
> +		return -ENOMEM;
> +
> +	vxh =3D (struct vxlanhdr *)__skb_push(skb, sizeof(*vxh));
> +	vxh->vx_flags =3D htonl(VXLAN_FLAGS);
> +	vxh->vx_vni =3D md->vni;
> +
> +	if (vs->exts)  {
> +		if (vs->exts & VXLAN_EXT_GBP) {
> +			struct vxlanhdr_gbp *gbp;
> +
> +			gbp =3D (struct vxlanhdr_gbp *)vxh;
> +			vxh->gbp_present =3D 1;
> +
> +			if (md->gbp & VXLAN_GBP_DONT_LEARN)
> +				gbp->dont_learn =3D 1;
> +
> +			if (md->gbp & VXLAN_GBP_POLICY_APPLIED)
> +				gbp->policy_applied =3D 1;
> +
> +			gbp->policy_id =3D htons(md->gbp & VXLAN_GBP_ID_MASK);
> +		}
> +	}
> +
> +	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
> +
> +	return 0;
> +}
> +
>   #if IS_ENABLED(CONFIG_IPV6)
>   static int vxlan6_xmit_skb(struct vxlan_sock *vs,
>   			   struct dst_entry *dst, struct sk_buff *skb,
>   			   struct net_device *dev, struct in6_addr *saddr,
>   			   struct in6_addr *daddr, __u8 prio, __u8 ttl,
> -			   __be16 src_port, __be16 dst_port, __be32 vni,
> -			   bool xnet)
> +			   __be16 src_port, __be16 dst_port,
> +			   struct vxlan_metadata *md, bool xnet)
>   {
> -	struct vxlanhdr *vxh;
>   	int min_headroom;
>   	int err;
>   	bool udp_sum =3D !udp_get_no_check6_tx(vs->sock->sk);
> @@ -1558,24 +1621,9 @@ static int vxlan6_xmit_skb(struct vxlan_sock *=
vs,
>   			+ VXLAN_HLEN + sizeof(struct ipv6hdr)
>   			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
>
> -	/* Need space for new headers (invalidates iph ptr) */
> -	err =3D skb_cow_head(skb, min_headroom);
> -	if (unlikely(err)) {
> -		kfree_skb(skb);
> -		goto err;
> -	}
> -
> -	skb =3D vlan_hwaccel_push_inside(skb);
> -	if (WARN_ON(!skb)) {
> -		err =3D -ENOMEM;
> +	err =3D vxlan_build_hdr(skb, vs, min_headroom, md);
> +	if (err)
>   		goto err;
> -	}
> -
> -	vxh =3D (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
> -	vxh->vx_flags =3D htonl(VXLAN_FLAGS);
> -	vxh->vx_vni =3D vni;
> -
> -	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
>
>   	udp_tunnel6_xmit_skb(vs->sock, dst, skb, dev, saddr, daddr, prio,
>   			     ttl, src_port, dst_port);
> @@ -1589,9 +1637,9 @@ err:
>   int vxlan_xmit_skb(struct vxlan_sock *vs,
>   		   struct rtable *rt, struct sk_buff *skb,
>   		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
> -		   __be16 src_port, __be16 dst_port, __be32 vni, bool xnet)
> +		   __be16 src_port, __be16 dst_port,
> +		   struct vxlan_metadata *md, bool xnet)
>   {
> -	struct vxlanhdr *vxh;
>   	int min_headroom;
>   	int err;
>   	bool udp_sum =3D !vs->sock->sk->sk_no_check_tx;
> @@ -1604,22 +1652,9 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
>   			+ VXLAN_HLEN + sizeof(struct iphdr)
>   			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
>
> -	/* Need space for new headers (invalidates iph ptr) */
> -	err =3D skb_cow_head(skb, min_headroom);
> -	if (unlikely(err)) {
> -		kfree_skb(skb);
> +	err =3D vxlan_build_hdr(skb, vs, min_headroom, md);
> +	if (err)
>   		return err;
> -	}
> -
> -	skb =3D vlan_hwaccel_push_inside(skb);
> -	if (WARN_ON(!skb))
> -		return -ENOMEM;
> -
> -	vxh =3D (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
> -	vxh->vx_flags =3D htonl(VXLAN_FLAGS);
> -	vxh->vx_vni =3D vni;
> -
> -	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
>
>   	return udp_tunnel_xmit_skb(vs->sock, rt, skb, src, dst, tos,
>   				   ttl, df, src_port, dst_port, xnet);
> @@ -1679,6 +1714,7 @@ static void vxlan_xmit_one(struct sk_buff *skb,=
 struct net_device *dev,
>   	const struct iphdr *old_iph;
>   	struct flowi4 fl4;
>   	union vxlan_addr *dst;
> +	struct vxlan_metadata md;
>   	__be16 src_port =3D 0, dst_port;
>   	u32 vni;
>   	__be16 df =3D 0;
> @@ -1749,11 +1785,12 @@ static void vxlan_xmit_one(struct sk_buff *sk=
b, struct net_device *dev,
>
>   		tos =3D ip_tunnel_ecn_encap(tos, old_iph, skb);
>   		ttl =3D ttl ? : ip4_dst_hoplimit(&rt->dst);
> +		md.vni =3D htonl(vni << 8);
> +		md.gbp =3D skb->mark;
>
>   		err =3D vxlan_xmit_skb(vxlan->vn_sock, rt, skb,
>   				     fl4.saddr, dst->sin.sin_addr.s_addr,
> -				     tos, ttl, df, src_port, dst_port,
> -				     htonl(vni << 8),
> +				     tos, ttl, df, src_port, dst_port, &md,
>   				     !net_eq(vxlan->net, dev_net(vxlan->dev)));
>   		if (err < 0) {
>   			/* skb is already freed. */
> @@ -1806,10 +1843,12 @@ static void vxlan_xmit_one(struct sk_buff *sk=
b, struct net_device *dev,
>   		}
>
>   		ttl =3D ttl ? : ip6_dst_hoplimit(ndst);
> +		md.vni =3D htonl(vni << 8);
> +		md.gbp =3D skb->mark;
>
>   		err =3D vxlan6_xmit_skb(vxlan->vn_sock, ndst, skb,
>   				      dev, &fl6.saddr, &fl6.daddr, 0, ttl,
> -				      src_port, dst_port, htonl(vni << 8),
> +				      src_port, dst_port, &md,
>   				      !net_eq(vxlan->net, dev_net(vxlan->dev)));
>   #endif
>   	}
> @@ -2210,6 +2249,11 @@ static const struct nla_policy vxlan_policy[IF=
LA_VXLAN_MAX + 1] =3D {
>   	[IFLA_VXLAN_UDP_CSUM]	=3D { .type =3D NLA_U8 },
>   	[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]	=3D { .type =3D NLA_U8 },
>   	[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]	=3D { .type =3D NLA_U8 },
> +	[IFLA_VXLAN_EXTENSION]	=3D { .type =3D NLA_NESTED },
> +};
> +
> +static const struct nla_policy vxlan_ext_policy[IFLA_VXLAN_EXT_MAX +=
 1] =3D {
> +	[IFLA_VXLAN_EXT_GBP]	=3D { .type =3D NLA_FLAG, },
>   };
>
>   static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[=
])
> @@ -2246,6 +2290,18 @@ static int vxlan_validate(struct nlattr *tb[],=
 struct nlattr *data[])
>   		}
>   	}
>
> +	if (data[IFLA_VXLAN_EXTENSION]) {
> +		int err;
> +
> +		err =3D nla_validate_nested(data[IFLA_VXLAN_EXTENSION],
> +					  IFLA_VXLAN_EXT_MAX, vxlan_ext_policy);
> +		if (err < 0) {
> +			pr_debug("invalid VXLAN extension configuration: %d\n",
> +				 err);
> +			return -EINVAL;
> +		}
> +	}
> +
>   	return 0;
>   }
>
> @@ -2400,6 +2456,18 @@ static void vxlan_sock_work(struct work_struct=
 *work)
>   	dev_put(vxlan->dev);
>   }
>
> +static void configure_vxlan_exts(struct vxlan_dev *vxlan, struct nla=
ttr *attr)
> +{
> +	struct nlattr *exts[IFLA_VXLAN_EXT_MAX+1];
> +
> +	/* Validated in vxlan_validate() */
> +	if (nla_parse_nested(exts, IFLA_VXLAN_EXT_MAX, attr, NULL) < 0)
> +		BUG();
> +
> +	if (exts[IFLA_VXLAN_EXT_GBP])
> +		vxlan->exts |=3D VXLAN_EXT_GBP;
> +}
> +
>   static int vxlan_newlink(struct net *net, struct net_device *dev,
>   			 struct nlattr *tb[], struct nlattr *data[])
>   {
> @@ -2525,6 +2593,9 @@ static int vxlan_newlink(struct net *net, struc=
t net_device *dev,
>   	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
>   		vxlan->flags |=3D VXLAN_F_UDP_ZERO_CSUM6_RX;
>
> +	if (data[IFLA_VXLAN_EXTENSION])
> +		configure_vxlan_exts(vxlan, data[IFLA_VXLAN_EXTENSION]);
> +
Can you also update vxlan_fill_info() so that these new attributes can =
be dumped=20
via netlink?


Thank you,
Nicolas

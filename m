From: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH v4 1/2] geneve: implement support for IPv6-based tunnels
Date: Wed, 21 Oct 2015 10:52:43 +0900
Message-ID: <5626EFEB.9050906@miraclelinux.com>
References: <1443638045-27229-1-git-send-email-linville@tuxdriver.com>
 <1445353866-32710-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Dave Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, Jiri Benc <jbenc@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33573 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbbJUBwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 21:52:47 -0400
Received: by pabrc13 with SMTP id rc13so38217254pab.0
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 18:52:46 -0700 (PDT)
In-Reply-To: <1445353866-32710-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

John W. Linville wrote:
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> v4:
> - treat mode field of ip_tunnel_info as flags
> - add a missing IS_ENABLED(CONFIG_IPV6) to geneve_rx
> - remove unneeded flags field in geneve_dev
> - NULL-check parameter for __geneve_sock_release
> - check remote socket family for AF_UNSPEC in geneve_configure
> - rename geneve_get_{rt,dst} as geneve_get_{v4_rt,v6_dst}
> - refactor some error handling in the xmit paths
> 
> v3:
> - declare geneve_remote_unspec as static
> 
> v2:
> - do not require remote address for tx on metadata tunnels
> - pass correct sockaddr family to udp_tun_rx_dst in geneve_rx
> - accommodate both ipv4 and ipv6 sockets open on same tunnel
> - move declaration of geneve_get_dst for aesthetic purposes
> 
>  drivers/net/geneve.c         | 459 +++++++++++++++++++++++++++++++++++--------
>  include/uapi/linux/if_link.h |   1 +
>  2 files changed, 377 insertions(+), 83 deletions(-)
> 
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 8f5c02eed47d..217b472ab9e7 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -46,16 +46,25 @@ struct geneve_net {
>  
>  static int geneve_net_id;
>  
> +union geneve_addr {
> +	struct sockaddr_in sin;
> +	struct sockaddr_in6 sin6;
> +	struct sockaddr sa;
> +};
> +
> +static union geneve_addr geneve_remote_unspec = { .sa.sa_family = AF_UNSPEC, };
> +
>  /* Pseudo network device */
>  struct geneve_dev {
>  	struct hlist_node  hlist;	/* vni hash table */
>  	struct net	   *net;	/* netns for packet i/o */
>  	struct net_device  *dev;	/* netdev for geneve tunnel */
> -	struct geneve_sock *sock;	/* socket used for geneve tunnel */
> +	struct geneve_sock *sock4;	/* IPv4 socket used for geneve tunnel */
> +	struct geneve_sock *sock6;	/* IPv6 socket used for geneve tunnel */
>  	u8                 vni[3];	/* virtual network ID for tunnel */
>  	u8                 ttl;		/* TTL override */
>  	u8                 tos;		/* TOS override */
> -	struct sockaddr_in remote;	/* IPv4 address for link partner */
> +	union geneve_addr  remote;	/* IP address for link partner */
>  	struct list_head   next;	/* geneve's per namespace list */
>  	__be16		   dst_port;
>  	bool		   collect_md;
> @@ -103,11 +112,32 @@ static struct geneve_dev *geneve_lookup(struct geneve_sock *gs,
>  	vni_list_head = &gs->vni_list[hash];
>  	hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
>  		if (!memcmp(vni, geneve->vni, sizeof(geneve->vni)) &&
> -		    addr == geneve->remote.sin_addr.s_addr)
> +		    addr == geneve->remote.sin.sin_addr.s_addr)
> +			return geneve;
> +	}
> +	return NULL;
> +}
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +static struct geneve_dev *geneve6_lookup(struct geneve_sock *gs,
> +					 struct in6_addr addr6, u8 vni[])
> +{
> +	struct hlist_head *vni_list_head;
> +	struct geneve_dev *geneve;
> +	__u32 hash;
> +
> +	/* Find the device for this VNI */
> +	hash = geneve_net_vni_hash(vni);
> +	vni_list_head = &gs->vni_list[hash];
> +	hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
> +		if (!memcmp(vni, geneve->vni, sizeof(geneve->vni)) &&
> +		    !memcmp(&addr6, &geneve->remote.sin6.sin6_addr,
> +			    sizeof(addr6)))

Please use ipv6_addr_equal().
How do you handle link-local addresses here?

>  			return geneve;
>  	}
>  	return NULL;
>  }
> +#endif
>  
>  static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
>  {
> @@ -121,24 +151,49 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
>  	struct metadata_dst *tun_dst = NULL;
>  	struct geneve_dev *geneve = NULL;
>  	struct pcpu_sw_netstats *stats;
> -	struct iphdr *iph;
> -	u8 *vni;
> +	struct iphdr *iph = NULL;
>  	__be32 addr;
> -	int err;
> +	static u8 zero_vni[3];
> +	u8 *vni;
> +	int err = 0;
> +	sa_family_t sa_family;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	struct ipv6hdr *ip6h = NULL;
> +	struct in6_addr addr6;
> +	static struct in6_addr zero_addr6;
> +#endif
>  
> -	iph = ip_hdr(skb); /* outer IP header... */
> +	sa_family = gs->sock->sk->sk_family;
>  
> -	if (gs->collect_md) {
> -		static u8 zero_vni[3];
> +	if (sa_family == AF_INET) {
> +		iph = ip_hdr(skb); /* outer IP header... */
>  
> -		vni = zero_vni;
> -		addr = 0;
> -	} else {
> -		vni = gnvh->vni;
> -		addr = iph->saddr;
> -	}
> +		if (gs->collect_md) {
> +			vni = zero_vni;
> +			addr = 0;
> +		} else {
> +			vni = gnvh->vni;
> +
> +			addr = iph->saddr;
> +		}
> +
> +		geneve = geneve_lookup(gs, addr, vni);
> +#if IS_ENABLED(CONFIG_IPV6)
> +	} else if (sa_family == AF_INET6) {
> +		ip6h = ipv6_hdr(skb); /* outer IPv6 header... */
> +
> +		if (gs->collect_md) {
> +			vni = zero_vni;
> +			addr6 = zero_addr6;
> +		} else {
> +			vni = gnvh->vni;
>  
> -	geneve = geneve_lookup(gs, addr, vni);
> +			addr6 = ip6h->saddr;
> +		}
> +
> +		geneve = geneve6_lookup(gs, addr6, vni);
> +#endif
> +	}
>  	if (!geneve)
>  		goto drop;
>  
> @@ -149,7 +204,7 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
>  			(gnvh->oam ? TUNNEL_OAM : 0) |
>  			(gnvh->critical ? TUNNEL_CRIT_OPT : 0);
>  
> -		tun_dst = udp_tun_rx_dst(skb, AF_INET, flags,
> +		tun_dst = udp_tun_rx_dst(skb, sa_family, flags,
>  					 vni_to_tunnel_id(gnvh->vni),
>  					 gnvh->opt_len * 4);
>  		if (!tun_dst)
> @@ -179,12 +234,21 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
>  
>  	skb_reset_network_header(skb);
>  
> -	err = IP_ECN_decapsulate(iph, skb);
> +	if (iph)
> +		err = IP_ECN_decapsulate(iph, skb);
> +	if (ip6h)
> +		err = IP6_ECN_decapsulate(ip6h, skb);
>  
>  	if (unlikely(err)) {
> -		if (log_ecn_error)
> -			net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
> -					     &iph->saddr, iph->tos);
> +		if (log_ecn_error) {
> +			if (iph)
> +				net_info_ratelimited("non-ECT from %pI4 "
> +						     "with TOS=%#x\n",
> +						     &iph->saddr, iph->tos);
> +			if (ip6h)
> +				net_info_ratelimited("non-ECT from %pI6\n",
> +						     &ip6h->saddr);
> +		}
>  		if (err > 1) {
>  			++geneve->dev->stats.rx_frame_errors;
>  			++geneve->dev->stats.rx_errors;
> @@ -284,6 +348,7 @@ static struct socket *geneve_create_sock(struct net *net, bool ipv6,
>  
>  	if (ipv6) {
>  		udp_conf.family = AF_INET6;
> +		udp_conf.ipv6_v6only = 1;
>  	} else {
>  		udp_conf.family = AF_INET;
>  		udp_conf.local_ip.s_addr = htonl(INADDR_ANY);
> @@ -458,9 +523,9 @@ static void geneve_notify_del_rx_port(struct geneve_sock *gs)
>  		udp_del_offload(&gs->udp_offloads);
>  }
>  
> -static void geneve_sock_release(struct geneve_sock *gs)
> +static void __geneve_sock_release(struct geneve_sock *gs)
>  {
> -	if (--gs->refcnt)
> +	if (!gs || --gs->refcnt)
>  		return;
>  
>  	list_del(&gs->list);
> @@ -469,58 +534,107 @@ static void geneve_sock_release(struct geneve_sock *gs)
>  	kfree_rcu(gs, rcu);
>  }
>  
> +static void geneve_sock_release(struct geneve_dev *geneve)
> +{
> +	__geneve_sock_release(geneve->sock4);
> +#if IS_ENABLED(CONFIG_IPV6)
> +	__geneve_sock_release(geneve->sock6);
> +#endif
> +}
> +
>  static struct geneve_sock *geneve_find_sock(struct geneve_net *gn,
> +					    sa_family_t family,
>  					    __be16 dst_port)
>  {
>  	struct geneve_sock *gs;
>  
>  	list_for_each_entry(gs, &gn->sock_list, list) {
>  		if (inet_sk(gs->sock->sk)->inet_sport == dst_port &&
> -		    inet_sk(gs->sock->sk)->sk.sk_family == AF_INET) {
> +		    inet_sk(gs->sock->sk)->sk.sk_family == family) {
>  			return gs;
>  		}
>  	}
>  	return NULL;
>  }
>  
> -static int geneve_open(struct net_device *dev)
> +static int geneve_sock_add(struct geneve_dev *geneve, bool ipv6)
>  {
> -	struct geneve_dev *geneve = netdev_priv(dev);
>  	struct net *net = geneve->net;
>  	struct geneve_net *gn = net_generic(net, geneve_net_id);
>  	struct geneve_sock *gs;
>  	__u32 hash;
>  
> -	gs = geneve_find_sock(gn, geneve->dst_port);
> +	gs = geneve_find_sock(gn, ipv6 ? AF_INET6 : AF_INET, geneve->dst_port);
>  	if (gs) {
>  		gs->refcnt++;
>  		goto out;
>  	}
>  
> -	gs = geneve_socket_create(net, geneve->dst_port, false);
> +	gs = geneve_socket_create(net, geneve->dst_port, ipv6);
>  	if (IS_ERR(gs))
>  		return PTR_ERR(gs);
>  
>  out:
>  	gs->collect_md = geneve->collect_md;
> -	geneve->sock = gs;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	if (ipv6)
> +		geneve->sock6 = gs;
> +	else
> +#endif
> +		geneve->sock4 = gs;
>  
>  	hash = geneve_net_vni_hash(geneve->vni);
>  	hlist_add_head_rcu(&geneve->hlist, &gs->vni_list[hash]);
>  	return 0;
>  }
>  
> +static int geneve_open(struct net_device *dev)
> +{
> +	struct geneve_dev *geneve = netdev_priv(dev);
> +	bool ipv6 = geneve->remote.sa.sa_family == AF_INET6;
> +	bool metadata = !!geneve->collect_md;
> +	int ret = 0;
> +
> +	geneve->sock4 = NULL;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	geneve->sock6 = NULL;
> +	if (ipv6 || metadata)
> +		ret = geneve_sock_add(geneve, true);
> +#endif
> +	if (!ret && (!ipv6 || metadata))
> +		ret = geneve_sock_add(geneve, false);
> +	if (ret < 0)
> +		geneve_sock_release(geneve);
> +
> +	return ret;
> +}
> +
>  static int geneve_stop(struct net_device *dev)
>  {
>  	struct geneve_dev *geneve = netdev_priv(dev);
> -	struct geneve_sock *gs = geneve->sock;
>  
>  	if (!hlist_unhashed(&geneve->hlist))
>  		hlist_del_rcu(&geneve->hlist);
> -	geneve_sock_release(gs);
> +	geneve_sock_release(geneve);
>  	return 0;
>  }
>  
> +static void geneve_build_header(struct genevehdr *geneveh,
> +				__be16 tun_flags, u8 vni[3],
> +				u8 options_len, u8 *options)
> +{
> +	geneveh->ver = GENEVE_VER;
> +	geneveh->opt_len = options_len / 4;
> +	geneveh->oam = !!(tun_flags & TUNNEL_OAM);
> +	geneveh->critical = !!(tun_flags & TUNNEL_CRIT_OPT);
> +	geneveh->rsvd1 = 0;
> +	memcpy(geneveh->vni, vni, 3);
> +	geneveh->proto_type = htons(ETH_P_TEB);
> +	geneveh->rsvd2 = 0;
> +
> +	memcpy(geneveh->options, options, options_len);
> +}
> +
>  static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
>  			    __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
>  			    bool csum)
> @@ -544,15 +658,7 @@ static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
>  	}
>  
>  	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
> -	gnvh->ver = GENEVE_VER;
> -	gnvh->opt_len = opt_len / 4;
> -	gnvh->oam = !!(tun_flags & TUNNEL_OAM);
> -	gnvh->critical = !!(tun_flags & TUNNEL_CRIT_OPT);
> -	gnvh->rsvd1 = 0;
> -	memcpy(gnvh->vni, vni, 3);
> -	gnvh->proto_type = htons(ETH_P_TEB);
> -	gnvh->rsvd2 = 0;
> -	memcpy(gnvh->options, opt, opt_len);
> +	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
>  
>  	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
>  	return 0;
> @@ -562,10 +668,47 @@ free_rt:
>  	return err;
>  }
>  
> -static struct rtable *geneve_get_rt(struct sk_buff *skb,
> -				    struct net_device *dev,
> -				    struct flowi4 *fl4,
> -				    struct ip_tunnel_info *info)
> +#if IS_ENABLED(CONFIG_IPV6)
> +static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
> +			     __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
> +			     bool csum, bool xnet)
> +{
> +	struct genevehdr *gnvh;
> +	int min_headroom;
> +	int err;
> +
> +	skb_scrub_packet(skb, xnet);
> +
> +	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
> +			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct ipv6hdr);
> +	err = skb_cow_head(skb, min_headroom);
> +	if (unlikely(err)) {
> +		kfree_skb(skb);
> +		goto free_dst;
> +	}
> +
> +	skb = udp_tunnel_handle_offloads(skb, csum);
> +	if (IS_ERR(skb)) {
> +		err = PTR_ERR(skb);
> +		goto free_dst;
> +	}
> +
> +	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
> +	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
> +
> +	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
> +	return 0;
> +
> +free_dst:
> +	dst_release(dst);
> +	return err;
> +}
> +#endif
> +
> +static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
> +				       struct net_device *dev,
> +				       struct flowi4 *fl4,
> +				       struct ip_tunnel_info *info)
>  {
>  	struct geneve_dev *geneve = netdev_priv(dev);
>  	struct rtable *rt = NULL;
> @@ -588,24 +731,42 @@ static struct rtable *geneve_get_rt(struct sk_buff *skb,
>  		}
>  
>  		fl4->flowi4_tos = RT_TOS(tos);
> -		fl4->daddr = geneve->remote.sin_addr.s_addr;
> +		fl4->daddr = geneve->remote.sin.sin_addr.s_addr;
>  	}
>  
>  	rt = ip_route_output_key(geneve->net, fl4);
> -	if (IS_ERR(rt)) {
> -		netdev_dbg(dev, "no route to %pI4\n", &fl4->daddr);
> -		dev->stats.tx_carrier_errors++;
> -		return rt;
> -	}
> -	if (rt->dst.dev == dev) { /* is this necessary? */
> -		netdev_dbg(dev, "circular route to %pI4\n", &fl4->daddr);
> -		dev->stats.collisions++;
> -		ip_rt_put(rt);
> -		return ERR_PTR(-EINVAL);
> -	}
> +
>  	return rt;
>  }
>  
> +#if IS_ENABLED(CONFIG_IPV6)
> +static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
> +					   struct net_device *dev,
> +					   struct flowi6 *fl6,
> +					   struct ip_tunnel_info *info)
> +{
> +	struct geneve_dev *geneve = netdev_priv(dev);
> +	struct geneve_sock *gs6 = geneve->sock6;
> +	struct dst_entry *dst = NULL;
> +
> +	memset(fl6, 0, sizeof(*fl6));
> +	fl6->flowi6_mark = skb->mark;
> +	fl6->flowi6_proto = IPPROTO_UDP;
> +
> +	if (info) {
> +		fl6->daddr = info->key.u.ipv6.dst;
> +		fl6->saddr = info->key.u.ipv6.src;
> +	} else {
> +		fl6->daddr = geneve->remote.sin6.sin6_addr;
> +	}
> +
> +	if (ipv6_stub->ipv6_dst_lookup(geneve->net, gs6->sock->sk, &dst, fl6))
> +		return ERR_PTR(-EHOSTUNREACH);
> +
> +	return dst;
> +}
> +#endif
> +
>  /* Convert 64 bit tunnel ID to 24 bit VNI. */
>  static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
>  {
> @@ -620,11 +781,11 @@ static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
>  #endif
>  }
>  
> -static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
> +static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
> +				   struct ip_tunnel_info *info)
>  {
>  	struct geneve_dev *geneve = netdev_priv(dev);
> -	struct geneve_sock *gs = geneve->sock;
> -	struct ip_tunnel_info *info = NULL;
> +	struct geneve_sock *gs4 = geneve->sock4;
>  	struct rtable *rt = NULL;
>  	const struct iphdr *iip; /* interior IP header */
>  	struct flowi4 fl4;
> @@ -635,7 +796,6 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
>  	int err;
>  
>  	if (geneve->collect_md) {
> -		info = skb_tunnel_info(skb);
>  		if (unlikely(info && !(info->mode & IP_TUNNEL_INFO_TX))) {
>  			netdev_dbg(dev, "no tunnel metadata\n");
>  			goto tx_error;
> @@ -644,12 +804,18 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
>  			goto tx_error;
>  	}
>  
> -	rt = geneve_get_rt(skb, dev, &fl4, info);
> +	rt = geneve_get_v4_rt(skb, dev, &fl4, info);
>  	if (IS_ERR(rt)) {
>  		netdev_dbg(dev, "no route to %pI4\n", &fl4.daddr);
>  		dev->stats.tx_carrier_errors++;
>  		goto tx_error;
>  	}
> +	if (rt->dst.dev == dev) { /* is this necessary? */
> +		netdev_dbg(dev, "circular route to %pI4\n", &fl4.daddr);
> +		dev->stats.collisions++;
> +		ip_rt_put(rt);
> +		goto tx_error;
> +	}
>  
>  	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
>  	skb_reset_mac_header(skb);
> @@ -688,7 +854,7 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
>  		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
>  		df = 0;
>  	}
> -	err = udp_tunnel_xmit_skb(rt, gs->sock->sk, skb, fl4.saddr, fl4.daddr,
> +	err = udp_tunnel_xmit_skb(rt, gs4->sock->sk, skb, fl4.saddr, fl4.daddr,
>  				  tos, ttl, df, sport, geneve->dst_port,
>  				  !net_eq(geneve->net, dev_net(geneve->dev)),
>  				  !udp_csum);
> @@ -703,6 +869,103 @@ err:
>  	return NETDEV_TX_OK;
>  }
>  
> +#if IS_ENABLED(CONFIG_IPV6)
> +static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
> +				    struct ip_tunnel_info *info)
> +{
> +	struct geneve_dev *geneve = netdev_priv(dev);
> +	struct geneve_sock *gs6 = geneve->sock6;
> +	struct dst_entry *dst = NULL;
> +	struct flowi6 fl6;
> +	__u8 ttl;
> +	__be16 sport;
> +	bool udp_csum;
> +	int err;
> +	bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
> +
> +	if (geneve->collect_md) {
> +		if (unlikely(info && !(info->mode & IP_TUNNEL_INFO_TX))) {
> +			netdev_dbg(dev, "no tunnel metadata\n");
> +			goto tx_error;
> +		}
> +	}
> +
> +	dst = geneve_get_v6_dst(skb, dev, &fl6, info);
> +	if (IS_ERR(dst)) {
> +		netdev_dbg(dev, "no route to %pI6\n", &fl6.daddr);
> +		dev->stats.tx_carrier_errors++;
> +		goto tx_error;
> +	}
> +	if (dst->dev == dev) { /* is this necessary? */
> +		netdev_dbg(dev, "circular route to %pI6\n", &fl6.daddr);
> +		dev->stats.collisions++;
> +		dst_release(dst);
> +		goto tx_error;
> +	}
> +
> +	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
> +	skb_reset_mac_header(skb);
> +
> +	if (info) {
> +		const struct ip_tunnel_key *key = &info->key;
> +		u8 *opts = NULL;
> +		u8 vni[3];
> +
> +		tunnel_id_to_vni(key->tun_id, vni);
> +		if (key->tun_flags & TUNNEL_GENEVE_OPT)
> +			opts = ip_tunnel_info_opts(info);
> +
> +		udp_csum = !!(key->tun_flags & TUNNEL_CSUM);
> +		err = geneve6_build_skb(dst, skb, key->tun_flags, vni,
> +					info->options_len, opts,
> +					udp_csum, xnet);
> +		if (unlikely(err))
> +			goto err;
> +
> +		ttl = key->ttl;
> +	} else {
> +		udp_csum = false;
> +		err = geneve6_build_skb(dst, skb, 0, geneve->vni,
> +					0, NULL, udp_csum, xnet);
> +		if (unlikely(err))
> +			goto err;
> +
> +		ttl = geneve->ttl;
> +		if (!ttl && ipv6_addr_is_multicast(&fl6.daddr))
> +			ttl = 1;
> +		ttl = ttl ? : ip6_dst_hoplimit(dst);
> +	}
> +	err = udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
> +				   &fl6.saddr, &fl6.daddr, 0, ttl,
> +				   sport, geneve->dst_port, !udp_csum);
> +
> +	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
> +	return NETDEV_TX_OK;
> +
> +tx_error:
> +	dev_kfree_skb(skb);
> +err:
> +	dev->stats.tx_errors++;
> +	return NETDEV_TX_OK;
> +}
> +#endif
> +
> +static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct geneve_dev *geneve = netdev_priv(dev);
> +	struct ip_tunnel_info *info = NULL;
> +
> +	if (geneve->collect_md)
> +		info = skb_tunnel_info(skb);
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +	if ((info && ip_tunnel_info_af(info) == AF_INET6) ||
> +	    (!info && geneve->remote.sa.sa_family == AF_INET6))
> +		return geneve6_xmit_skb(skb, dev, info);
> +#endif
> +	return geneve_xmit_skb(skb, dev, info);
> +}
> +
>  static const struct net_device_ops geneve_netdev_ops = {
>  	.ndo_init		= geneve_init,
>  	.ndo_uninit		= geneve_uninit,
> @@ -759,6 +1022,7 @@ static void geneve_setup(struct net_device *dev)
>  static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
>  	[IFLA_GENEVE_ID]		= { .type = NLA_U32 },
>  	[IFLA_GENEVE_REMOTE]		= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
> +	[IFLA_GENEVE_REMOTE6]		= { .len = sizeof(struct in6_addr) },
>  	[IFLA_GENEVE_TTL]		= { .type = NLA_U8 },
>  	[IFLA_GENEVE_TOS]		= { .type = NLA_U8 },
>  	[IFLA_GENEVE_PORT]		= { .type = NLA_U16 },
> @@ -790,7 +1054,7 @@ static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
>  
>  static struct geneve_dev *geneve_find_dev(struct geneve_net *gn,
>  					  __be16 dst_port,
> -					  __be32 rem_addr,
> +					  union geneve_addr *remote,
>  					  u8 vni[],
>  					  bool *tun_on_same_port,
>  					  bool *tun_collect_md)
> @@ -806,7 +1070,7 @@ static struct geneve_dev *geneve_find_dev(struct geneve_net *gn,
>  			*tun_on_same_port = true;
>  		}
>  		if (!memcmp(vni, geneve->vni, sizeof(geneve->vni)) &&
> -		    rem_addr == geneve->remote.sin_addr.s_addr &&
> +		    !memcmp(remote, &geneve->remote, sizeof(geneve->remote)) &&
>  		    dst_port == geneve->dst_port)
>  			t = geneve;
>  	}
> @@ -814,18 +1078,20 @@ static struct geneve_dev *geneve_find_dev(struct geneve_net *gn,
>  }
>  
>  static int geneve_configure(struct net *net, struct net_device *dev,
> -			    __be32 rem_addr, __u32 vni, __u8 ttl, __u8 tos,
> -			    __be16 dst_port, bool metadata)
> +			    union geneve_addr *remote,
> +			    __u32 vni, __u8 ttl, __u8 tos, __be16 dst_port,
> +			    bool metadata)
>  {
>  	struct geneve_net *gn = net_generic(net, geneve_net_id);
>  	struct geneve_dev *t, *geneve = netdev_priv(dev);
>  	bool tun_collect_md, tun_on_same_port;
>  	int err;
>  
> -	if (metadata) {
> -		if (rem_addr || vni || tos || ttl)
> -			return -EINVAL;
> -	}
> +	if (!remote)
> +		return -EINVAL;
> +	if (metadata &&
> +	    (remote->sa.sa_family != AF_UNSPEC || vni || tos || ttl))
> +		return -EINVAL;
>  
>  	geneve->net = net;
>  	geneve->dev = dev;
> @@ -834,16 +1100,19 @@ static int geneve_configure(struct net *net, struct net_device *dev,
>  	geneve->vni[1] = (vni & 0x0000ff00) >> 8;
>  	geneve->vni[2] =  vni & 0x000000ff;
>  
> -	geneve->remote.sin_addr.s_addr = rem_addr;
> -	if (IN_MULTICAST(ntohl(geneve->remote.sin_addr.s_addr)))
> +	if ((remote->sa.sa_family == AF_INET &&
> +	     IN_MULTICAST(ntohl(remote->sin.sin_addr.s_addr))) ||
> +	    (remote->sa.sa_family == AF_INET6 &&
> +	     ipv6_addr_is_multicast(&remote->sin6.sin6_addr)))
>  		return -EINVAL;
> +	geneve->remote = *remote;
>  
>  	geneve->ttl = ttl;
>  	geneve->tos = tos;
>  	geneve->dst_port = dst_port;
>  	geneve->collect_md = metadata;
>  
> -	t = geneve_find_dev(gn, dst_port, rem_addr, geneve->vni,
> +	t = geneve_find_dev(gn, dst_port, remote, geneve->vni,
>  			    &tun_on_same_port, &tun_collect_md);
>  	if (t)
>  		return -EBUSY;
> @@ -870,14 +1139,29 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
>  	__be16 dst_port = htons(GENEVE_UDP_PORT);
>  	__u8 ttl = 0, tos = 0;
>  	bool metadata = false;
> -	__be32 rem_addr;
> +	union geneve_addr remote;
>  	__u32 vni;
>  
> -	if (!data[IFLA_GENEVE_ID] || !data[IFLA_GENEVE_REMOTE])
> +	if (!data[IFLA_GENEVE_ID] ||
> +	    (data[IFLA_GENEVE_REMOTE] && data[IFLA_GENEVE_REMOTE6]) ||
> +	    (!data[IFLA_GENEVE_REMOTE] && !data[IFLA_GENEVE_REMOTE6]))
>  		return -EINVAL;
>  
>  	vni = nla_get_u32(data[IFLA_GENEVE_ID]);
> -	rem_addr = nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
> +
> +	memset(&remote, 0, sizeof(remote));
> +	if (data[IFLA_GENEVE_REMOTE]) {
> +		remote.sa.sa_family = AF_INET;
> +		remote.sin.sin_addr.s_addr =
> +			nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
> +	} else if (data[IFLA_GENEVE_REMOTE6]) {
> +		if (!IS_ENABLED(CONFIG_IPV6))
> +			return -EPFNOSUPPORT;
> +
> +		remote.sa.sa_family = AF_INET6;
> +		remote.sin6.sin6_addr =
> +			nla_get_in6_addr(data[IFLA_GENEVE_REMOTE6]);
> +	}
>  
>  	if (data[IFLA_GENEVE_TTL])
>  		ttl = nla_get_u8(data[IFLA_GENEVE_TTL]);
> @@ -891,8 +1175,8 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
>  	if (data[IFLA_GENEVE_COLLECT_METADATA])
>  		metadata = true;
>  
> -	return geneve_configure(net, dev, rem_addr, vni,
> -				ttl, tos, dst_port, metadata);
> +	return geneve_configure(net, dev, &remote, vni, ttl, tos, dst_port,
> +				metadata);
>  }
>  
>  static void geneve_dellink(struct net_device *dev, struct list_head *head)
> @@ -906,7 +1190,7 @@ static void geneve_dellink(struct net_device *dev, struct list_head *head)
>  static size_t geneve_get_size(const struct net_device *dev)
>  {
>  	return nla_total_size(sizeof(__u32)) +	/* IFLA_GENEVE_ID */
> -		nla_total_size(sizeof(struct in_addr)) + /* IFLA_GENEVE_REMOTE */
> +		nla_total_size(sizeof(struct in6_addr)) + /* IFLA_GENEVE_REMOTE{6} */
>  		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TTL */
>  		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TOS */
>  		nla_total_size(sizeof(__be16)) +  /* IFLA_GENEVE_PORT */
> @@ -923,9 +1207,17 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
>  	if (nla_put_u32(skb, IFLA_GENEVE_ID, vni))
>  		goto nla_put_failure;
>  
> -	if (nla_put_in_addr(skb, IFLA_GENEVE_REMOTE,
> -			    geneve->remote.sin_addr.s_addr))
> -		goto nla_put_failure;
> +	if (geneve->remote.sa.sa_family == AF_INET) {
> +		if (nla_put_in_addr(skb, IFLA_GENEVE_REMOTE,
> +				    geneve->remote.sin.sin_addr.s_addr))
> +			goto nla_put_failure;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	} else {
> +		if (nla_put_in6_addr(skb, IFLA_GENEVE_REMOTE6,
> +				     &geneve->remote.sin6.sin6_addr))
> +			goto nla_put_failure;
> +#endif
> +	}
>  
>  	if (nla_put_u8(skb, IFLA_GENEVE_TTL, geneve->ttl) ||
>  	    nla_put_u8(skb, IFLA_GENEVE_TOS, geneve->tos))
> @@ -971,7 +1263,8 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
>  	if (IS_ERR(dev))
>  		return dev;
>  
> -	err = geneve_configure(net, dev, 0, 0, 0, 0, htons(dst_port), true);
> +	err = geneve_configure(net, dev, &geneve_remote_unspec,
> +			       0, 0, 0, htons(dst_port), true);
>  	if (err) {
>  		free_netdev(dev);
>  		return ERR_PTR(err);
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index e3b6217f34f1..45e3a48550f9 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -461,6 +461,7 @@ enum {
>  	IFLA_GENEVE_TOS,
>  	IFLA_GENEVE_PORT,	/* destination port */
>  	IFLA_GENEVE_COLLECT_METADATA,
> +	IFLA_GENEVE_REMOTE6,
>  	__IFLA_GENEVE_MAX
>  };
>  #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
> 

-- 
吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
ミラクル・リナックス株式会社 技術本部 サポート部

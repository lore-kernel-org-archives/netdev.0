From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 3/6] geneve: Add support to collect tunnel metadata.
Date: Wed, 12 Aug 2015 13:53:12 -0700
Message-ID: <CAEP_g=8_BLeNjxpraZ4zYpJwurXROtxoSSzvanSMupJzVZ6d9Q@mail.gmail.com>
References: <1439356664-21784-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:34239 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbbHLUxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 16:53:33 -0400
Received: by labd1 with SMTP id d1so15948700lab.1
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 13:53:32 -0700 (PDT)
In-Reply-To: <1439356664-21784-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2015 at 10:17 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 5e9bab8..a463383 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> +static struct geneve_dev *geneve_lookup(struct geneve_net *gn,
> +                                       struct iphdr *iph,
> +                                       struct genevehdr *gnvh)
>  {
> -       struct genevehdr *gnvh = geneve_hdr(skb);
> -       struct geneve_dev *dummy, *geneve = NULL;
> -       struct geneve_net *gn;
> -       struct iphdr *iph = NULL;
> -       struct pcpu_sw_netstats *stats;
>         struct hlist_head *vni_list_head;
> -       int err = 0;
> +       struct geneve_dev *geneve;
>         __u32 hash;
>
> -       iph = ip_hdr(skb); /* Still outer IP header... */
> -
> -       gn = gs->rcv_data;
> -
>         /* Find the device for this VNI */
>         hash = geneve_net_vni_hash(gnvh->vni);
>         vni_list_head = &gn->vni_list[hash];
> -       hlist_for_each_entry_rcu(dummy, vni_list_head, hlist) {
> -               if (!memcmp(gnvh->vni, dummy->vni, sizeof(dummy->vni)) &&
> -                   iph->saddr == dummy->remote.sin_addr.s_addr) {
> -                       geneve = dummy;
> -                       break;
> +       hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
> +               if (!memcmp(gnvh->vni, geneve->vni, sizeof(geneve->vni)) &&
> +                   iph->saddr == geneve->remote.sin_addr.s_addr) {
> +                       return geneve;
>                 }
>         }
> +
> +       return rcu_dereference(gn->collect_md_tun);
> +}

I think this operates differently from VXLAN (and GRE I believe) where
you can't have tunnels based on the VNI overlapping the
collect_md_tun. VXLAN is nice because it can go straight from the
socket to collecting metadata without having to an additional lookup
that doesn't give any additional information and it seems a little
simpler because we don't need to keep track of a flow-based device.
However, at the very least the behavior should be consistent.

> +/* geneve receive/decap routine */
> +static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
> +{
> +       struct genevehdr *gnvh = geneve_hdr(skb);
> +       struct metadata_dst *tun_dst = NULL;
> +       struct geneve_dev *geneve = NULL;
> +       struct pcpu_sw_netstats *stats;
> +       struct geneve_net *gn;
> +       struct iphdr *iph;
> +       int err;
> +
> +       iph = ip_hdr(skb); /* Still outer IP header... */
> +       gn = gs->rcv_data;
> +       geneve = geneve_lookup(gn, iph, gnvh);
>         if (!geneve)
>                 goto drop;
>
> -       /* Drop packets w/ critical options,
> -        * since we don't support any...
> -        */
> -       if (gnvh->critical)
> -               goto drop;
> +       if (geneve->collect_md) {

Should this also check ip_tunnel_collect_metadata()? GRE has the same issue.

> @@ -103,7 +146,8 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
>         skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
>
>         /* Ignore packet loops (and multicast echo) */
> -       if (ether_addr_equal(eth_hdr(skb)->h_source, geneve->dev->dev_addr))
> +       if (!geneve->collect_md &&
> +           ether_addr_equal(eth_hdr(skb)->h_source, geneve->dev->dev_addr))
>                 goto drop;

Why is this different in the collect_md case?

> @@ -128,10 +169,18 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
>         stats->rx_bytes += skb->len;
>         u64_stats_update_end(&stats->syncp);
>
> +       if (tun_dst)
> +               skb_dst_set(skb, (struct dst_entry *)tun_dst);

I think there is a leak if we allocate the dst but then drop the
packet before we set it on the skb. It seems easier to just set it
earlier.

> -static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
> +static struct rtable *geneve_get_rt(struct sk_buff *skb,
> +                                   struct net_device *dev,
> +                                   struct flowi4 *fl4,
> +                                   struct ip_tunnel_info *info)
>  {
[...]
> +       if (info) {
> +               fl4->daddr = info->key.ipv4_dst;
> +               fl4->saddr = info->key.ipv4_src;
> +               fl4->flowi4_tos = RT_TOS(info->key.ipv4_tos);
> +               fl4->flowi4_mark = skb->mark;
> +               fl4->flowi4_proto = IPPROTO_UDP;
> +       } else {
> +               tos = geneve->tos;
> +               if (tos == 1) {
> +                       const struct iphdr *iip = ip_hdr(skb);
> +
> +                       tos = ip_tunnel_get_dsfield(iip, skb);
> +               }

Should the mark and protocol be used in both cases?

> +static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +       struct geneve_dev *geneve = netdev_priv(dev);
> +       struct geneve_sock *gs = geneve->sock;
> +       struct ip_tunnel_info *info = NULL;
> +       struct rtable *rt = NULL;
> +       const struct iphdr *iip; /* interior IP header */
> +       struct flowi4 fl4;
> +       __u8 tos, ttl;
> +       __be16 sport;
> +       bool xnet;
> +       int err;
>
> -       /* no need to handle local destination and encap bypass...yet... */
> +       sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
>
> -       err = geneve_xmit_skb(gs, rt, skb, fl4.saddr, fl4.daddr,
> -                             tos, ttl, 0, sport, geneve->dst_port, 0,
> -                             geneve->vni, 0, NULL, false,
> -                             !net_eq(geneve->net, dev_net(geneve->dev)));
> +       if (geneve->collect_md) {
> +               info = skb_tunnel_info(skb, AF_INET);
> +               if (info && info->mode != IP_TUNNEL_INFO_TX)
> +                       info = NULL;

Should we just return at this point? Best case, it prints an error
message that is slightly less clear than it could be. Worst case, it
somehow keeps going and does something weird.

> +struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
> +                                       u8 name_assign_type, u16 dst_port)
> +{
> +       struct nlattr *tb[IFLA_MAX + 1];
> +       struct net_device *dev;
> +       int err;
> +
> +       memset(tb, 0, sizeof(tb));
> +       dev = rtnl_create_link(net, name, name_assign_type,
> +                              &geneve_link_ops, tb);
> +       if (IS_ERR(dev))
> +               return dev;
> +
> +       err = geneve_configure(net, dev, 0, 0, 0, 0, dst_port, true);
> +       if (err) {
> +               free_netdev(dev);
> +               return ERR_PTR(err);
> +       }
> +
> +       eth_hw_addr_random(dev);

VXLAN calls eth_hw_addr_random in its setup function. Maybe that's a
better place? I think that would also take care of the existing call
that we have to eth_hw_addr_random.

From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCHv2 next 3/3] ipvlan: Introduce l3s mode
Date: Tue, 13 Sep 2016 21:24:05 -0600
Message-ID: <1177f2c5-6c2d-32e1-1628-f272d6b0b5c6@cumulusnetworks.com>
References: <1473703312-26757-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34559 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751518AbcINDYI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 23:24:08 -0400
Received: by mail-pf0-f173.google.com with SMTP id p64so758500pfb.1
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 20:24:08 -0700 (PDT)
In-Reply-To: <1473703312-26757-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/12/16 12:01 PM, Mahesh Bandewar wrote:

> +struct sk_buff *ipvlan_l3_rcv(struct net_device *dev, struct sk_buff *skb,
> +			      u16 proto)
> +{
> +	struct ipvl_addr *addr;
> +	struct net_device *sdev;
> +
> +	addr = ipvlan_skb_to_addr(skb, dev);
> +	if (!addr)
> +		goto out;
> +
> +	sdev = addr->master->dev;
> +	switch (proto) {
> +	case AF_INET:
> +	{
> +		int err;
> +		struct iphdr *ip4h = ip_hdr(skb);
> +
> +		err = ip_route_input_noref(skb, ip4h->daddr, ip4h->saddr,
> +					   ip4h->tos, sdev);
> +		if (unlikely(err))
> +			goto out;
> +		break;
> +	}
> +	case AF_INET6:
> +	{
> +		struct dst_entry *dst;
> +		struct ipv6hdr *ip6h = ipv6_hdr(skb);
> +		int flags = RT6_LOOKUP_F_HAS_SADDR;
> +		struct flowi6 fl6 = {
> +			.flowi6_iif   = sdev->ifindex,
> +			.daddr        = ip6h->daddr,
> +			.saddr        = ip6h->saddr,
> +			.flowlabel    = ip6_flowinfo(ip6h),
> +			.flowi6_mark  = skb->mark,
> +			.flowi6_proto = ip6h->nexthdr,
> +		};
> +
> +		skb_dst_drop(skb);
> +		dst = ip6_route_input_lookup(dev_net(sdev), sdev, &fl6, flags);
> +		skb_dst_set(skb, dst);
> +		break;
> +	}
> +	default:
> +		break;
> +	}

Nit: why not put the above in separate per-version functions (ipvlan_ip_rcv and ipvlan_ip6_rcv) similar to what is done for ipvlan_process_outbound?


> +
> +out:
> +	return skb;
> +}
> +
> +unsigned int ipvlan_nf_input(void *priv, struct sk_buff *skb,
> +			     const struct nf_hook_state *state)
> +{
> +	struct ipvl_addr *addr;
> +	unsigned int len;
> +
> +	addr = ipvlan_skb_to_addr(skb, skb->dev);
> +	if (!addr)
> +		goto out;
> +
> +	skb->dev = addr->master->dev;
> +	len = skb->len + ETH_HLEN;
> +	ipvlan_count_rx(addr->master, len, true, false);
> +out:
> +	return NF_ACCEPT;
> +}
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 18b4e8c7f68a..d02be277e1db 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -9,24 +9,65 @@
>  
>  #include "ipvlan.h"
>  
> +static struct nf_hook_ops ipvl_nfops[] __read_mostly = {
> +	{
> +		.hook     = ipvlan_nf_input,
> +		.pf       = NFPROTO_IPV4,
> +		.hooknum  = NF_INET_LOCAL_IN,
> +		.priority = INT_MAX,
> +	},
> +	{
> +		.hook     = ipvlan_nf_input,
> +		.pf       = NFPROTO_IPV6,
> +		.hooknum  = NF_INET_LOCAL_IN,
> +		.priority = INT_MAX,
> +	},
> +};
> +
> +static struct l3mdev_ops ipvl_l3mdev_ops __read_mostly = {
> +	.l3mdev_l3_rcv = ipvlan_l3_rcv,
> +};
> +
>  static void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev)
>  {
>  	ipvlan->dev->mtu = dev->mtu - ipvlan->mtu_adj;
>  }
>  
> -static void ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
> +static int ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
>  {
>  	struct ipvl_dev *ipvlan;
> +	int err = 0;
>  
> +	ASSERT_RTNL();
>  	if (port->mode != nval) {
> +		if (nval == IPVLAN_MODE_L3S) {
> +			port->dev->l3mdev_ops = &ipvl_l3mdev_ops;
> +			port->dev->priv_flags |= IFF_L3MDEV_MASTER;
> +			if (!port->ipt_hook_added) {
> +				err = _nf_register_hooks(ipvl_nfops,
> +							ARRAY_SIZE(ipvl_nfops));

That's clever. The hooks are not device based so why do the register for each device? Alternatively, you could use a static dst like VRF does for Tx. In the ipvlan rcv function set the dst input handler to send the packet back to the ipvlan driver via dst->input. From there send the packet through the netfilter hooks and then do the real lookup, update the dst and call its input function. I have working code for VRF driver somewhere that shows how to do this.

 
> +				if (!err)
> +					port->ipt_hook_added = true;
> +				else
> +					return err;
> +			}
> +		} else {
> +			port->dev->priv_flags &= ~IFF_L3MDEV_MASTER;
> +			port->dev->l3mdev_ops = NULL;
> +			if (port->ipt_hook_added)
> +				_nf_unregister_hooks(ipvl_nfops,
> +						     ARRAY_SIZE(ipvl_nfops));
> +			port->ipt_hook_added = false;
> +		}

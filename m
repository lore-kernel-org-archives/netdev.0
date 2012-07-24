From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] ipv4: Change rt->rt_iif encoding.
Date: Tue, 24 Jul 2012 10:41:37 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207240954001.1615@ja.ssi.bg>
References: <20120723.160541.184307938805782289.davem@davemloft.net> <20120723.161446.36265037346365173.davem@davemloft.net> <alpine.LFD.2.00.1207240226340.2633@ja.ssi.bg> <20120723.174312.898352203879290533.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:36264 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755434Ab2GXHlm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2012 03:41:42 -0400
In-Reply-To: <20120723.174312.898352203879290533.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 23 Jul 2012, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Tue, 24 Jul 2012 03:24:38 +0300 (EEST)
> 
> > On Mon, 23 Jul 2012, David Miller wrote:
> > 
> >> Hmmm, the problem is that when we decapsulate VLAN devices, we're left
> >> with the parent device's index in skb->skb_iif.
> > 
> > 	Not sure if it is a problem with VLANs, can be also
> > with some virtual devices but may be they use dev_forward_skb()
> > where skb_iif is zeroed.
> 
> dev_forward_skb() gives the packet to netif_rx() which will thus send
> the packet down to __netif_receive_skb() which will set the
> skb->skb_iif to the new device's ifindex.  It will not stay at zero
> :-)
> 
> > 	I was also worrying about ip_mc_output looping packets with
> > skb_iif because skb_clone copies the field but may be such loops
> > happen only for locally originated traffic where skb_iif starts with
> > 0.
> 
> Loopback of multicast packets is done in ip_mc_output(), via
> the clone that you mention, via dev_loopback_xmit().
> 
> dev_loopback_xmit() gives the packet to netif_rx_ni() which again
> lands it back at __netif_receive_skb(), which (with my changes)
> will adjust the skb->skb_iif to match whatever sits in skb->dev
> at the time.
> 
> It should be alright.

	Yes, I know that now it is set in all cases, I was
wondering why __netif_receive_skb was prepared to see
non-zero value. Please also check xfrm4_fill_dst, the
possible case where the new skb_iif usage can differ from
rt_iif is for forwarded packets where skb->dst is changed
with new version, for example:

ip_forward -> *xfrm*_policy_check* -> __xfrm_decode_session ->
_decode_session4 memsets flowi4_iif (now to get skb_iif).

ip_forward -> xfrm4_route_forward -> ... xfrm_lookup ->
... -> xfrm4_fill_dst now will use skb_iif ?

	XFRM is still magic for me and I'm not sure if
we need some other device instead of skb_iif. Should we
prefer dst->dev for output routes? For example:

static inline int inet_iif(const struct sk_buff *skb)
{
	struct rtable *rt = skb_rtable(skb);
	int iif = rt->rt_iif;

	if (iif)
		return iif;
	if (rt_is_output_route(rt))
		return rt->dst.dev->ifindex;
	return skb->skb_iif;
}

	but may be it is same if we restore the
rth->rt_iif	= orig_oif ? : dev_out->ifindex;

	code in __mkroute_output? By this way we will have
correct rt_iif at the time of routing call, before the
packet is looped via this device. Then skb_iif will remain
as default only for input routes. By this way we will be
less worried for places like xfrm or when skb->dst is
replaced in forwarding path. IPIP tunnels also replace
skb->dst but this can hurt only code like route4_classify.

Regards

--
Julian Anastasov <ja@ssi.bg>

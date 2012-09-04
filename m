From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH 0/2] RFC: Caching IPv6 exthdr in skb->cb[]
Date: Tue, 4 Sep 2012 10:26:21 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1209040955460.1704@ja.ssi.bg>
References: <Pine.GSO.4.63.1208291427170.26100@stinky-local.trash.net> <20120903211504.8851.6894.stgit@dragon>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Hans Schillstrom <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120903211504.8851.6894.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 3 Sep 2012, Jesper Dangaard Brouer wrote:

> Hi Patrick and Hans,
> 
> This is my followup to:
>   [PATCH 2/3] ipvs: Fix faulty IPv6 extension header handling in IPVS
> 
> Where you proposed improving the overall architecture of IPv6
> extension header parsing not only for IPVS but for other related
> Netfilter subsystems as well.
> 
> We discussed using/extending inet6_skb_parm/IP6CB.  There was not
> enough room for extending inet6_skb_parm directly, so I have
> introduced a struct inet6_skb_exthdr_cache/IP6CB_EXTHDR, which extend
> IP6CB.
> 
> The question is if this approach will work.  Can netfilter be allowed
> to modify data after inet6_skb_parm/IP6CB, given all the different
> HOOKs ?

	Yes, as long as we do not reach the protocol
receiving handlers, eg. tcp_v4_rcv. But the problem is 
that many modules can use this CB part but nobody knows
if it is valid - it is not reset.

	If data is part of IP6CB it is reset in ipv6_rcv
with memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));

	One option is to extend this memset to cover this
new IP6CB_EXTHDR part if CONFIG_NF_DEFRAG_IPV6 is defined.
I.e. we can create new struct inet6_skb_parm_exthdr, DCCP, TCP
will continue to use/extend inet6_skb_parm but
ipv6_find_hdr_cb will know that their part is reset. Then
above memset can become:

memset(IP6CB_EXTHDR(skb), 0, sizeof(struct inet6_skb_parm_exthdr));

struct inet6_skb_parm_exthdr {
	struct inet6_skb_parm	h6;
#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
	__u16	thoff; ...
	...
#endif
};

	Not sure if it should depend only on
CONFIG_NF_DEFRAG_IPV6.

> If we find this is a valid approach, then I'll update the IPVS patches
> to also use this.

Regards

--
Julian Anastasov <ja@ssi.bg>

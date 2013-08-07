From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/5] netfilter: add SYNPROXY core/target
Date: Thu, 8 Aug 2013 01:37:11 +0200
Message-ID: <20130807233707.GA23937@macbook.localnet>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
 <1375897371-18430-4-git-send-email-kaber@trash.net>
 <1375913514.4004.63.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, jesper.brouer@gmail.com,
	as@one.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49502 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932633Ab3HGXhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 19:37:15 -0400
Content-Disposition: inline
In-Reply-To: <1375913514.4004.63.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 07, 2013 at 03:11:54PM -0700, Eric Dumazet wrote:
> On Wed, 2013-08-07 at 19:42 +0200, Patrick McHardy wrote:
> > Add a SYNPROXY for netfilter. The code is split into two parts, the synproxy
> > core with common functions and an address family specific target.
> > 
> > The SYNPROXY receives the connection request from the client, responds with
> > a SYN/ACK containing a SYN cookie and announcing a zero window and checks
> > whether the final ACK from the client contains a valid cookie.
> > 
> > It then establishes a connection to the original destination and, if
> > successful, sends a window update to the client with the window size
> > announced by the server.
> > 
> > Support for timestamps, SACK, window scaling and MSS options can be
> > statically configured as target parameters if the features of the server
> > are known. If timestamps are used, the timestamp value sent back to
> > the client in the SYN/ACK will be different from the real timestamp of
> > the server. In order to now break PAWS, the timestamps are translated in
> > the direction server->client.
> > 
> > Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> 
> > +static struct iphdr *
> > +synproxy_build_ip(struct sk_buff *skb, u32 saddr, u32 daddr)
> > +{
> > +	struct iphdr *iph;
> > +
> > +	skb_reset_network_header(skb);
> > +	iph = (struct iphdr *)skb_put(skb, sizeof(*iph));
> > +	iph->version	= 4;
> > +	iph->ihl	= sizeof(*iph) / 4;
> > +	iph->tos	= 0;
> > +	iph->id		= 0;
> > +	iph->frag_off	= htons(IP_DF);
> > +	iph->ttl	= 64;
> 
> sysctl_ip_default_ttl ?

Will do, thanks.

> > +static void
> > +synproxy_send_client_synack(const struct sk_buff *skb, const struct tcphdr *th,
> > +			    const struct synproxy_options *opts)
> > +{
> > +	struct sk_buff *nskb;
> > +	struct iphdr *iph, *niph;
> > +	struct tcphdr *nth;
> > +	unsigned int tcp_hdr_size;
> > +	u16 mss = opts->mss;
> > +
> > +	iph = ip_hdr(skb);
> > +
> > +	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
> > +	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + LL_MAX_HEADER,
> > +			 GFP_ATOMIC);
> > +	if (nskb == NULL)
> > +		return;
> > +	skb_reserve(nskb, LL_MAX_HEADER);
> 
> s/LL_MAX_HEADER/MAX_TCP_HEADER ? 

ACK.

> > +	niph = synproxy_build_ip(nskb, iph->daddr, iph->saddr);
> > +
> > +	skb_reset_transport_header(nskb);
> > +	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
> > +	nth->source	= th->dest;
> > +	nth->dest	= th->source;
> > +	nth->seq	= htonl(__cookie_v4_init_sequence(iph, th, &mss));
> > +	nth->ack_seq	= htonl(ntohl(th->seq) + 1);
> > +	tcp_flag_word(nth) = TCP_FLAG_SYN | TCP_FLAG_ACK;
> > +	if (opts->options & XT_SYNPROXY_OPT_ECN)
> > +		tcp_flag_word(nth) |= TCP_FLAG_ECE;
> > +	nth->doff	= tcp_hdr_size / 4;
> > +	nth->window	= 0;
> > +	nth->check	= 0;
> > +	nth->urg_ptr	= 0;
> > +
> > +	synproxy_build_options(nth, opts);
> > +
> > +	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
> > +			  niph, nth, tcp_hdr_size);
> > +}
> 
> Also please check your uses of kfree_skb() .
> 
> Some of them would better be consume_skb() (for example in
> ipv4_synproxy_hook())

I'll look into that.

> I wonder if this code could be generic for IPv4/IPv6, instead of
> duplicating in IPv6

I considered that, in fact I started under that assumption. But it would
result in lots of functions taking 10+ (long) arguments, so in my opinion
the code gets less readable. Alternative would be lots of callbacks.

This seemed like the cleanest way so far, but I'd certainly welcome
concrete proposals for removing duplicated code.

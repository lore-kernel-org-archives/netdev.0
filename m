From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/3] [LLC]: skb allocation size for responses
Date: Sat, 29 Mar 2008 09:02:23 -0300
Message-ID: <20080329120223.GZ14945@ghostprotocols.net>
References: <1206691159-10872-1-git-send-email-joonwpark81@gmail.com> <20080328131202.GP14945@ghostprotocols.net> <20080329060655.GA15023@tp64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43368 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbYC2MCa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2008 08:02:30 -0400
Content-Disposition: inline
In-Reply-To: <20080329060655.GA15023@tp64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Mar 29, 2008 at 03:06:55PM +0900, Joonwoo Park escreveu:
> On Fri, Mar 28, 2008 at 10:12:02AM -0300, Arnaldo Carvalho de Melo wrote:
> > 
> > > +static int llc_mac_header_len(unsigned short devtype)
> > > +{
> > > +	switch (devtype) {
> > > +	case ARPHRD_ETHER:
> > > +	case ARPHRD_LOOPBACK:
> > > +		return sizeof(struct ethhdr);
> > > +	}
> > > +
> > > +	return __llc_tr_mac_header_len(devtype);
> > > +}
> > 
> > Nah, just drop __llc_tr_mac_header_len altogether and have another case
> > entry for ARPHDR_IEEE802_TR.
> > 
> > >  /**
> > >   *	llc_alloc_frame - allocates sk_buff for frame
> > >   *	@dev: network device this skb will be sent over
> > > + *	@type: pdu type to allocate
> > > + *	@data_size: data size to allocate
> > >   *
> > >   *	Allocates an sk_buff for frame and initializes sk_buff fields.
> > >   *	Returns allocated skb or %NULL when out of memory.
> > >   */
> > > -struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev)
> > > +struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev,
> > > +				u8 type, u32 data_size)
> > >  {
> > > -	struct sk_buff *skb = alloc_skb(128, GFP_ATOMIC);
> > > +	int hlen = type == LLC_PDU_TYPE_U ? 3 : 4;
> > > +	struct sk_buff *skb;
> > > +
> > > +	hlen += llc_mac_header_len(dev->type);
> > > +	skb = alloc_skb(hlen + data_size, GFP_ATOMIC);
> > >  
> > >  	if (skb) {
> > >  		skb_reset_mac_header(skb);
> > > -		skb_reserve(skb, 50);
> > > +		skb_reserve(skb, hlen);
> > 
> > Well done, now it is better documented (LLC_PDU_TYPE_U passed) and uses
> > less memory, no more magic numbers, good.
> > 
> > - Arnaldo
> 
> 
> I've respined the patch, thanks Arnaldo.
> 
> ---
> [LLC]: skb allocation size for responses
> 
> Allocate the skb for llc responses with the received packet size by
> using the size adjustable llc_frame_alloc.
> Don't allocate useless extra payload.
> Cleanup magic numbers.
> 
> So, this fixes oops.
> Reported by Jim Westfall:
> kernel: skb_over_panic: text:c0541fc7 len:1000 put:997 head:c166ac00 data:c166ac2f tail:0xc166b017 end:0xc166ac80 dev:eth0
> kernel: ------------[ cut here ]------------
> kernel: kernel BUG at net/core/skbuff.c:95!

Perfect, thanks a lot:

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

- Arnaldo

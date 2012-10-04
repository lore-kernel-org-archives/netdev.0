From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [RFC] vxlan: use ether header as fallback hash
Date: Wed, 03 Oct 2012 22:06:34 -0700 (PDT)
Message-ID: <730dc96c-3b06-4cc2-ba07-d4f756a6aad7@tahiti.vyatta.com>
References: <1349326673.16011.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43349 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752631Ab2JDFGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 01:06:36 -0400
In-Reply-To: <1349326673.16011.5.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Wed, 2012-10-03 at 21:39 -0700, Stephen Hemminger wrote:
> > VXLAN bases source UDP port based on flow to help the
> > receiver to be able to load balance based on outer header
> > contents.
> > 
> > This patches changes the algorithm to better handle packets
> > that can not be categorized by the rxhash() function.
> > It adds a fallback to use jhash on the Ether header.
> > 
> > It also fixes a bug where the old code could assign 0 as a port
> > value.
> > 
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > ---
> > RFC for now, compile tested only
> > 
> > --- a/drivers/net/vxlan.c	2012-10-03 21:25:43.747968165 -0700
> > +++ b/drivers/net/vxlan.c	2012-10-03 21:36:10.213805422 -0700
> > @@ -622,12 +622,30 @@ static inline u8 vxlan_ecn_encap(u8 tos,
> >  	return INET_ECN_encapsulate(tos, inner);
> >  }
> >  
> 
> #include <linux/jhash.h>
> 
> > +/* Compute hash to use for source port
> > + *   first choice to use L4 flow hash since it will spread
> > + *     better and maybe available from hardware
> > + *   secondary choice is to use jhash on the Ethernet header
> > + * Always returns non-zero value
> > + */
> > +static u16 vxlan_flow_hash(struct sk_buff *skb)
> > +{
> > +	u16 hash = skb_get_rxhash(skb);
> 
> skb_get_rxhash(skb) returns an u32, that could have low order 16bits
> set
> to 0.
> 
> So I would use u32 hash = skb_get_rxhash(skb);


Turns out that 0 is a valid source port if no reply is requested
(per RFC and wikipedia)

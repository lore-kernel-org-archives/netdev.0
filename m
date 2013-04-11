From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Reallocate headroom if it would overflow csum_start
Date: Thu, 11 Apr 2013 10:57:32 -0700
Message-ID: <1365703052.3887.183.camel@edumazet-glaptop>
References: <c35c262084e8907098dc2db5ea9690d2119b4916.1365678820.git.tgraf@suug.ch>
	 <1365695394.3887.162.camel@edumazet-glaptop>
	 <1365702765.7355.3.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:55994 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161156Ab3DKR5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 13:57:34 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa11so1021285pad.41
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 10:57:34 -0700 (PDT)
In-Reply-To: <1365702765.7355.3.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-11 at 18:52 +0100, Ben Hutchings wrote:
> On Thu, 2013-04-11 at 08:49 -0700, Eric Dumazet wrote:
> > On Thu, 2013-04-11 at 13:19 +0200, Thomas Graf wrote:
> > > If a TCP retransmission gets partially ACKed and collapsed multiple
> > > times it is possible for the headroom to grow beyond 64K which will
> > > overflow the 16bit skb->csum_start which is based on the start of
> > > the headroom. It has been observed rarely in the wild with IPoIB due
> > > to the 64K MTU.
> > > 
> > > Verify if the acking and collapsing resulted in a headroom exceeding
> > > what csum_start can cover and reallocate the headroom if so.
> > > 
> > > LLNL has been running the patch for a while and has not seen the
> > > problem occur since.
> > > 
> > > A big thank you to Jim Foraker <foraker1@llnl.gov> and the team at
> > > LLNL for helping out with the investigation and testing.
> > > 
> > > Reported-by: Jim Foraker <foraker1@llnl.gov>
> > > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > > ---
> > > v2: reallocate headroom instead of preventing further collapsing
> > > 
> > >  net/ipv4/tcp_output.c | 7 +++++--
> > >  1 file changed, 5 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > > index b44cf81..bf6ceb7 100644
> > > --- a/net/ipv4/tcp_output.c
> > > +++ b/net/ipv4/tcp_output.c
> > > @@ -2388,8 +2388,11 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
> > >  	 */
> > >  	TCP_SKB_CB(skb)->when = tcp_time_stamp;
> > >  
> > > -	/* make sure skb->data is aligned on arches that require it */
> > > -	if (unlikely(NET_IP_ALIGN && ((unsigned long)skb->data & 3))) {
> > > +	/* make sure skb->data is aligned on arches that require it
> > > +	 * and check if ack-trimming & collapsing extended the headroom
> > > +	 * beyond what csum_start can cover. */
> > > +	if (unlikely(NET_IP_ALIGN && ((unsigned long)skb->data & 3) ||
> > > +		     skb_headroom(skb) >= 0xFFFF)) {
> > >  		struct sk_buff *nskb = __pskb_copy(skb, MAX_TCP_HEADER,
> > >  						   GFP_ATOMIC);
> > >  		return nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
> > 
> > Strange... It was tested on an arch with NET_IP_ALIGN == 2 I presume ?
> > 
> > This fix should also be done for other arches (x86 for example)
> > 
> > I would code the condition like that instead
> > 
> > if ((NET_IP_ALIGN && ((unsigned long)skb->data & 3)) ||
> >     skb_headroom(skb) >= 0xFFFF)
> 
> You dropped the unlikely() and added redundant parentheses, which may be
> clearer but is still equivalent.

I see what you mean...

I just don't like

if (A && B || C)

I prefer in this case

if ((A && B) || C)

Then add the unlikely() if we really care in this _ultra_ slow path

if (unlikely((A && B) || C)) 

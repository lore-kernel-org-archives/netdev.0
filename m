From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netem: fix possible skb leak
Date: Mon, 30 Apr 2012 09:44:43 -0700
Message-ID: <20120430094443.3ace544c@nehalam.linuxnetplumber.net>
References: <1335726502.3897.8.camel@edumazet-glaptop>
	<20120430092509.54b89ae6@nehalam.linuxnetplumber.net>
	<1335804016.2296.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43410 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756320Ab2D3Qoq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 12:44:46 -0400
In-Reply-To: <1335804016.2296.5.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Apr 2012 18:40:16 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2012-04-30 at 09:25 -0700, Stephen Hemminger wrote:
> > On Sun, 29 Apr 2012 21:08:22 +0200
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > skb_checksum_help(skb) can return an error, we must free skb in this
> > > case. qdisc_drop(skb, sch) can also be feeded with a NULL skb (if
> > > skb_unshare() failed), so lets use this generic helper.
> > > 
> > > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > > Cc: Stephen Hemminger <shemminger@osdl.org>
> > > ---
> > >  net/sched/sch_netem.c |    6 ++----
> > >  1 file changed, 2 insertions(+), 4 deletions(-)
> > > 
> > > diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> > > index 5da548f..ebd2296 100644
> > > --- a/net/sched/sch_netem.c
> > > +++ b/net/sched/sch_netem.c
> > > @@ -408,10 +408,8 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> > >  	if (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor)) {
> > >  		if (!(skb = skb_unshare(skb, GFP_ATOMIC)) ||
> > >  		    (skb->ip_summed == CHECKSUM_PARTIAL &&
> > > -		     skb_checksum_help(skb))) {
> > > -			sch->qstats.drops++;
> > > -			return NET_XMIT_DROP;
> > > -		}
> > > +		     skb_checksum_help(skb)))
> > > +			return qdisc_drop(skb, sch);
> > >  
> > >  		skb->data[net_random() % skb_headlen(skb)] ^= 1<<(net_random() % 8);
> > >  	}
> > > 
> > > 
> > 
> > This would crater if skb_unshare() returned NULL. I think the conditional
> > needs to be split into two paths.
> 
> Maybe you can read the changelog where I explained this was safe ;)

Ok, I am surprised that qdisc_drop() is safe with NULL skb, but yes.

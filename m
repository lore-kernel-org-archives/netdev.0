From: Julian Anastasov <ja@ssi.bg>
Subject: Re: 100% CPU load when generating traffic to destination network
 that nexthop is not reachable
Date: Wed, 16 Aug 2017 00:49:12 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1708160035510.2947@ja.home.ssi.bg>
References: <177465a0-aaba-4063-e451-ebbf46728b77@itcare.pl>          <1502816253.4936.85.camel@edumazet-glaptop3.roam.corp.google.com>          <baa1807d-cc00-0182-4b34-4d986d62ebcb@itcare.pl>  <1502824260.4936.86.camel@edumazet-glaptop3.roam.corp.google.com>
  <alpine.LFD.2.20.1708152236360.1666@ja.home.ssi.bg> <1502831185.4936.87.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47418 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750989AbdHOVtY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 17:49:24 -0400
In-Reply-To: <1502831185.4936.87.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 15 Aug 2017, Eric Dumazet wrote:

> On Tue, 2017-08-15 at 22:45 +0300, Julian Anastasov wrote:
> > 	Hello,
> > 
> > On Tue, 15 Aug 2017, Eric Dumazet wrote:
> > 
> > > Please try this :
> > > diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> > > index 16a1a4c4eb57fa1147f230916e2e62e18ef89562..95e0d7702029b583de8229e3c3eb923f6395b072 100644
> > > --- a/net/core/neighbour.c
> > > +++ b/net/core/neighbour.c
> > > @@ -991,14 +991,18 @@ static void neigh_timer_handler(unsigned long arg)
> > >  
> > >  int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
> > >  {
> > > -	int rc;
> > >  	bool immediate_probe = false;
> > > +	int rc;
> > > +
> > > +	/* We _should_ test this under write_lock_bh(&neigh->lock),
> > > +	 * but this is too costly.
> > > +	 */
> > > +	if (READ_ONCE(neigh->nud_state) & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
> > > +		return 0;
> > 
> > 	The same fast check is already done in the only caller,
> > neigh_event_send. Now we risk to enter the
> > 'if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {' block...
> 
> 
> Right you are.
> 
> It must be possible to add a fast path without locks.
> 
> (say if jiffies has not changed before last state change)

	I thought about this, it is possible in
neigh_event_send:

        if (neigh->used != now)
                neigh->used = now;
	else if (neigh->nud_state == NUD_INCOMPLETE &&
		 neigh->arp_queue_len_bytes + skb->truesize >
		 NEIGH_VAR(neigh->parms, QUEUE_LEN_BYTES)
		return 1;

	But this is really in fast path and not sure it is
worth it. May be if we can move it somehow in __neigh_event_send
but as neigh->used is changed early we need a better idea
how to reduce the arp_queue hit rate...

Regards

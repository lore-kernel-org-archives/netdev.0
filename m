From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 100% CPU load when generating traffic to destination network
 that nexthop is not reachable
Date: Tue, 15 Aug 2017 14:06:25 -0700
Message-ID: <1502831185.4936.87.camel@edumazet-glaptop3.roam.corp.google.com>
References: <177465a0-aaba-4063-e451-ebbf46728b77@itcare.pl>
                 <1502816253.4936.85.camel@edumazet-glaptop3.roam.corp.google.com>
                 <baa1807d-cc00-0182-4b34-4d986d62ebcb@itcare.pl>
         <1502824260.4936.86.camel@edumazet-glaptop3.roam.corp.google.com>
         <alpine.LFD.2.20.1708152236360.1666@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36795 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbdHOVG1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 17:06:27 -0400
Received: by mail-pg0-f67.google.com with SMTP id y129so3129030pgy.3
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 14:06:27 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.20.1708152236360.1666@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-15 at 22:45 +0300, Julian Anastasov wrote:
> 	Hello,
> 
> On Tue, 15 Aug 2017, Eric Dumazet wrote:
> 
> > Please try this :
> > diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> > index 16a1a4c4eb57fa1147f230916e2e62e18ef89562..95e0d7702029b583de8229e3c3eb923f6395b072 100644
> > --- a/net/core/neighbour.c
> > +++ b/net/core/neighbour.c
> > @@ -991,14 +991,18 @@ static void neigh_timer_handler(unsigned long arg)
> >  
> >  int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
> >  {
> > -	int rc;
> >  	bool immediate_probe = false;
> > +	int rc;
> > +
> > +	/* We _should_ test this under write_lock_bh(&neigh->lock),
> > +	 * but this is too costly.
> > +	 */
> > +	if (READ_ONCE(neigh->nud_state) & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
> > +		return 0;
> 
> 	The same fast check is already done in the only caller,
> neigh_event_send. Now we risk to enter the
> 'if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {' block...


Right you are.

It must be possible to add a fast path without locks.

(say if jiffies has not changed before last state change)

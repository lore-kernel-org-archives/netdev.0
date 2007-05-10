From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Thu, 10 May 2007 08:50:37 -0400
Message-ID: <1178801437.4074.37.camel@localhost>
References: <1178725965.4058.75.camel@localhost>
	 <OFF9085DDC.F5960247-ON652572D7.001B794E-652572D7.001CA7E2@in.ibm.com>
	 <20070510115039.GA24439@gondor.apana.org.au>
	 <20070510.045534.90119358.davem@davemloft.net>
	 <1178799661.4074.20.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:44969 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758802AbXEJMum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 08:50:42 -0400
Received: by wx-out-0506.google.com with SMTP id h31so523691wxd
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 05:50:41 -0700 (PDT)
In-Reply-To: <1178799661.4074.20.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Never mind, I was wrong. qdisc run will be invoked by cpu0; i.e:
 
 CPU0                 CPU1
  + grab qlock         |
  |                    + find that return code is 0
  | enq pkt X          + release qdisc running
  |                    |
  + grab qdisc running | ==> outta here
  | call qdisc_run
  + release qlock     

Should have looked at my netconf slides first ;->

cheers,
jamal

On Thu, 2007-10-05 at 08:21 -0400, jamal wrote:
> On Thu, 2007-10-05 at 04:55 -0700, David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Thu, 10 May 2007 21:50:39 +1000
> > 
> 
> > T_SCHED]: Rationalise return value of qdisc_restart
> > > 
> > > The current return value scheme and associated comment was invented
> > > back in the 20th century when we still had that tbusy flag.  Things
> > > have changed quite a bit since then (even Tony Blair is moving on
> > > now, not to mention the new French president).
> > > 
> > > All we need to indicate now is whether the caller should continue
> > > processing the queue.  Therefore it's sufficient if we return 0 if
> > > we want to stop and non-zero otherwise.
> > > 
> > > This is based on a patch by Krishna Kumar.
> > > 
> > > Signed-off-by: <herbert@gondor.apana.org.au>
> > 
> > Fair enough, patch applied :-)
> 
> Ok, see if this makes sense:
> 
> CPU0                 CPU1 (holding qdisc running)
>   .                    |
>   .                    |
>   .                    + grab qlock
>   .                    |
>   .                    | deq pkt
>   .                    + release qlock
>   .                    + grab txlock
>   .                    |  send pkt
>   .                    + release txlock
>   .                    + grab qlock
>    has pktX            | (NEW: qlen = 0); return 0 instead of -1
>    waiting for qlock   + release qlock
>   + grab qlock         |
>   |                    + find that return code is 0
>   | enq pkt X          + release qdisc running
>   |                    |
>   + release qlock      | ==> outta here
> 
> pkt X is stuck unless some event happens such as a new pkt arrival. 
> In other words it sits there for an indeterminate period.
> 
> cheers,
> jamal


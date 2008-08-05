From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Eliminate unnecessary forward delay
Date: Tue, 05 Aug 2008 01:40:06 -0700 (PDT)
Message-ID: <20080805.014006.00973775.davem@davemloft.net>
References: <20080804170439.GA13546@gondor.apana.org.au>
	<20080804103534.6b7896d9@extreme>
	<20080805021240.GA18159@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46628
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756193AbYHEIkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 04:40:06 -0400
In-Reply-To: <20080805021240.GA18159@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 5 Aug 2008 10:12:40 +0800

> On Mon, Aug 04, 2008 at 10:35:34AM -0700, Stephen Hemminger wrote:
> >
> > Same again, this time compile tested...
> > 
> > --- a/net/bridge/br_stp.c	2008-08-04 10:20:21.000000000 -0700
> > +++ b/net/bridge/br_stp.c	2008-08-04 10:29:26.000000000 -0700
> > @@ -368,14 +368,25 @@ static void br_make_blocking(struct net_
> >  /* called under bridge lock */
> >  static void br_make_forwarding(struct net_bridge_port *p)
> >  {
> > -	if (p->state == BR_STATE_BLOCKING) {
> 
> Is it safe to remove this check, especially if the forward delay
> is non-zero?

He's not deleting it as far as I can tell.

The old code is:

	if (p->state == BR_STATE_BLOCKING) {
		if (p->br->stp_enabled == BR_KERNEL_STP)
			p->state = BR_STATE_LISTENING;
		else
			p->state = BR_STATE_LEARNING;

		br_log_state(p);
		mod_timer(&p->forward_delay_timer, jiffies + p->br->forward_delay);
	}

and the new code is:

	struct net_bridge *br = p->br;
 
	if (p->state != BR_STATE_BLOCKING)
		return;

	if (br->forward_delay == 0) {
		p->state = BR_STATE_FORWARDING;
		br_topology_change_detection(br);
		del_timer(&p->forward_delay_timer);
	}
	else if (p->br->stp_enabled == BR_KERNEL_STP)
		p->state = BR_STATE_LISTENING;
	else
		p->state = BR_STATE_LEARNING;

	br_log_state(p);

	if (br->forward_delay != 0)
		mod_timer(&p->forward_delay_timer, jiffies + br->forward_delay);

So when p->state is not BR_STATE_BLOCKING, both before and after this
patch, the function does nothing.

Are your concerns still present?  I'd like to apply this, so let me know.

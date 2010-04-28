From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] forcedeth: Stay in NAPI as long as there's work
Date: Wed, 28 Apr 2010 11:13:54 -0700
Message-ID: <20100428111354.49a6ec1a@nehalam>
References: <alpine.DEB.1.00.1004272332350.30235@pokey.mtv.corp.google.com>
	<1272477251.18228.36.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	aabdulla@nvidia.com, davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51470 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752939Ab0D1SOP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Apr 2010 14:14:15 -0400
In-Reply-To: <1272477251.18228.36.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Apr 2010 10:54:11 -0700
Joe Perches <joe@perches.com> wrote:

> On Tue, 2010-04-27 at 23:36 -0700, Tom Herbert wrote:
> > Add loop in NAPI poll routine to keep processing RX and TX as long as
> > there is more work to do.  This is similar to what tg3 and some other
> > drivers do.
> > Signed-off-by: Tom Herbert <therbert@google.com>
> > ---
> > diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> > index a1c0e7b..1e4de7b 100644
> > --- a/drivers/net/forcedeth.c
> > +++ b/drivers/net/forcedeth.c
> > @@ -3736,6 +3736,23 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
> >  }
> >  
> >  #ifdef CONFIG_FORCEDETH_NAPI
> > +static inline int nv_has_work(struct fe_priv *np)
> > +{
> > +	if (nv_optimized(np)) {
> > +		return (
> > +		    ((np->get_rx.ex != np->put_rx.ex) &&
> > +		     !(le32_to_cpu(np->get_rx.ex->flaglen) & NV_RX2_AVAIL)) ||
> > +		    ((np->get_tx.ex != np->put_tx.ex) &&
> > +		     !(le32_to_cpu(np->get_tx.ex->flaglen) & NV_TX_VALID)));
> > +	} else {
> > +		return (
> > +		    ((np->get_rx.orig != np->put_rx.orig) &&
> > +		     !(le32_to_cpu(np->get_rx.orig->flaglen) & NV_RX_AVAIL)) ||
> > +		    ((np->get_tx.orig != np->put_tx.orig) &&
> > +		     !(le32_to_cpu(np->get_tx.orig->flaglen) & NV_TX_VALID)));
> > +	}
> > +}

Why than adding another check step, why not just keep going until
rx_done returns 0?


From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] ibm_newemac: MAL support for PowerPC 405EZ
Date: Thu, 4 Sep 2008 23:41:45 -0400
Message-ID: <20080904234145.17f55cc2@zod.rchland.ibm.com>
References: <cover.1220540078.git.jwboyer@linux.vnet.ibm.com>
	<20080904150216.GD2479@yoda.jdub.homelinux.org>
	<20080905021037.GG14128@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:56930 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752598AbYIEDls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 23:41:48 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m853fl31006731
	for <netdev@vger.kernel.org>; Thu, 4 Sep 2008 23:41:47 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m853flIc235286
	for <netdev@vger.kernel.org>; Thu, 4 Sep 2008 23:41:47 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m853flRZ003252
	for <netdev@vger.kernel.org>; Thu, 4 Sep 2008 23:41:47 -0400
In-Reply-To: <20080905021037.GG14128@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Sep 2008 12:10:37 +1000
Simon Horman <horms@verge.net.au> wrote:
 
> > +static irqreturn_t mal_int(int irq, void *dev_instance)
> > +{
> > +	struct mal_instance *mal = dev_instance;
> > +	u32 esr = get_mal_dcrn(mal, MAL_ESR);
> > +
> > +	if (esr & MAL_ESR_EVB) {
> > +		/* descriptor error */
> > +		if (esr & MAL_ESR_DE) {
> > +			if (esr & MAL_ESR_CIDT)
> > +				return (mal_rxde(irq, dev_instance));
> 
> 	Return statements shouldn't be enlosed in brackets according to
> 	checkpatch.pl. Also in a few other places.

I hate checkpatch, but that's easy enough to fix.  Though I don't see
what other places I add with that mistake.

> > +			else
> > +				return (mal_txde(irq, dev_instance));
> > +		} else { /* SERR */
> > +			return (mal_serr(irq, dev_instance));
> > +		}
> > +	}
> > +	return IRQ_HANDLED;
> > +}
> > +
> >  void mal_poll_disable(struct mal_instance *mal, struct mal_commac *commac)
> >  {
> >  	/* Spinlock-type semantics: only one caller disable poll at a time */
> > @@ -542,11 +568,22 @@ static int __devinit mal_probe(struct of_device *ofdev,
> >  		goto fail;
> >  	}
> >  
> > -	mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
> > -	mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
> > -	mal->serr_irq = irq_of_parse_and_map(ofdev->node, 2);
> > -	mal->txde_irq = irq_of_parse_and_map(ofdev->node, 3);
> > -	mal->rxde_irq = irq_of_parse_and_map(ofdev->node, 4);
> > +	if (of_device_is_compatible(ofdev->node, "ibm,mcmal-405ez"))
> > +		mal->features |= (MAL_FTR_CLEAR_ICINTSTAT | MAL_FTR_COMMON_ERR_INT);
> 
> The above like is >80 characters wide.
> But I'm not sure that anyone cares.

I don't.  If Ben complains I'll change it.

> > +
> > +	if (mal_has_feature(mal, MAL_FTR_COMMON_ERR_INT)) {
> > +		mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
> > +		mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
> > +		mal->serr_irq = irq_of_parse_and_map(ofdev->node, 2);
> > +		mal->txde_irq = mal->rxde_irq = mal->serr_irq;
> > +	} else {
> > +		mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
> > +		mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
> > +		mal->serr_irq = irq_of_parse_and_map(ofdev->node, 2);
> > +		mal->txde_irq = irq_of_parse_and_map(ofdev->node, 3);
> > +		mal->rxde_irq = irq_of_parse_and_map(ofdev->node, 4);
> > +	}
> 
> It seems that that first three calls to irq_of_parse_and_map() could
> be moved outside of the if/else clause.
> 
> 	mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
> 	mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
> 	mal->serr_irq = irq_of_parse_and_map(ofdev->node, 2);
> 	if (mal_has_feature(mal, MAL_FTR_COMMON_ERR_INT)) {
> 		mal->txde_irq = mal->rxde_irq = mal->serr_irq;
> 	} else {
> 		mal->txde_irq = irq_of_parse_and_map(ofdev->node, 3);
> 		mal->rxde_irq = irq_of_parse_and_map(ofdev->node, 4);
> 	}

Indeed they could.  Good catch.

> > +
> >  	if (mal->txeob_irq == NO_IRQ || mal->rxeob_irq == NO_IRQ ||
> >  	    mal->serr_irq == NO_IRQ || mal->txde_irq == NO_IRQ ||
> >  	    mal->rxde_irq == NO_IRQ) {
> > @@ -608,21 +645,42 @@ static int __devinit mal_probe(struct of_device *ofdev,
> >  			     sizeof(struct mal_descriptor) *
> >  			     mal_rx_bd_offset(mal, i));
> >  
> > -	err = request_irq(mal->serr_irq, mal_serr, 0, "MAL SERR", mal);
> > -	if (err)
> > -		goto fail2;
> > -	err = request_irq(mal->txde_irq, mal_txde, 0, "MAL TX DE", mal);
> > -	if (err)
> > -		goto fail3;
> > -	err = request_irq(mal->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
> > -	if (err)
> > -		goto fail4;
> > -	err = request_irq(mal->rxde_irq, mal_rxde, 0, "MAL RX DE", mal);
> > -	if (err)
> > -		goto fail5;
> > -	err = request_irq(mal->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
> > -	if (err)
> > -		goto fail6;
> > +	if (mal_has_feature(mal, MAL_FTR_COMMON_ERR_INT)) {
> > +		err = request_irq(mal->serr_irq, mal_int, IRQF_SHARED,
> > +				"MAL SERR", mal);
> > +		if (err)
> > +			goto fail2;
> > +		err = request_irq(mal->txde_irq, mal_int, IRQF_SHARED,
> > +				"MAL TX DE", mal);
> > +		if (err)
> > +			goto fail3;
> > +		err = request_irq(mal->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
> > +		if (err)
> > +			goto fail4;
> > +		err = request_irq(mal->rxde_irq, mal_int, IRQF_SHARED,
> > +				"MAL RX DE", mal);
> > +		if (err)
> > +			goto fail5;
> > +		err = request_irq(mal->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
> > +		if (err)
> > +			goto fail6;
> > +	} else {
> > +		err = request_irq(mal->serr_irq, mal_serr, 0, "MAL SERR", mal);
> > +		if (err)
> > +			goto fail2;
> > +		err = request_irq(mal->txde_irq, mal_txde, 0, "MAL TX DE", mal);
> > +		if (err)
> > +			goto fail3;
> > +		err = request_irq(mal->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
> > +		if (err)
> > +			goto fail4;
> > +		err = request_irq(mal->rxde_irq, mal_rxde, 0, "MAL RX DE", mal);
> > +		if (err)
> > +			goto fail5;
> > +		err = request_irq(mal->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
> > +		if (err)
> > +			goto fail6;
> > +	}
> 
> There seems to be a lot of repention in the above if/else clauses.
> I wonder if something like this might be nicer.
> 
> 	if (mal_has_feature(mal, MAL_FTR_COMMON_ERR_INT)) {
> 		irqflags = IRQF_SHARED;
> 		hdlr_serr = hdlr_txde = hdlr_rxde = mal_int;
> 	} else {
> 		irqflags = 0;
> 		hdlr_serr = mal_serr;
> 		hdlr_txde = mal_txde;
> 		hdlr_rxde = mal_rxde;
> 	}
> 	err = request_irq(mal->serr_irq, hdlr_serr, irqflags, "MAL SERR", mal);
> 	if (err)
> 		goto fail2;
> 	err = request_irq(mal->txde_irq, hdlr_txde, irqflags, "MAL TX DE", mal);
> 	if (err)
> 		goto fail3;
> 	err = request_irq(mal->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
> 	if (err)
> 		goto fail4;
> 	err = request_irq(mal->rxde_irq, hdlr_rxde, irqflags, "MAL RX DE", mal);
> 	if (err)
> 		goto fail5;
> 	err = request_irq(mal->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
> 	if (err)
> 		goto fail6;

I like it.  Much cleaner.  I'll fix that up too.

josh

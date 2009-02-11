From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: off by one, try #2
Date: Wed, 11 Feb 2009 21:58:54 +0100
Message-ID: <20090211205854.GB2550@ami.dom.local>
References: <20090211133341.GB12362@ff.dom.local> <4992DF3C.7070802@gmail.com> <20090211171403.GA2539@ami.dom.local> <49932805.7050309@gmail.com> <20090211202755.GA2550@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:41543 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756426AbZBKU7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 15:59:00 -0500
Received: by bwz5 with SMTP id 5so577080bwz.13
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 12:58:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090211202755.GA2550@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 11, 2009 at 09:27:55PM +0100, Jarek Poplawski wrote:
> On Wed, Feb 11, 2009 at 08:33:25PM +0100, Roel Kluin wrote:
...

One more thing below...

> > Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> > ---
> > diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
> > index 6124605..4ade64a 100644
> > --- a/drivers/net/3c505.c
> > +++ b/drivers/net/3c505.c
> > @@ -493,15 +493,21 @@ static bool receive_pcb(struct net_device *dev, pcb_struct * pcb)
> >  	}
> >  	/* read the data */
> >  	spin_lock_irqsave(&adapter->lock, flags);
> > -	i = 0;
> > -	do {
> > -		j = 0;
> > -		while (((stat = get_status(dev->base_addr)) & ACRF) == 0 && j++ < 20000);
> > -		pcb->data.raw[i++] = inb_command(dev->base_addr);
> > -		if (i > MAX_PCB_DATA)
> > -			INVALID_PCB_MSG(i);
> > -	} while ((stat & ASF_PCB_MASK) != ASF_PCB_END && j < 20000);
> > +	for (i = 0; i < MAX_PCB_DATA; i++) {
> > +		for (j = 0; j < 20000; j++) {
> > +			stat = get_status(dev->base_addr);
> > +			if (stat & ACRF)
> > +				break;
> > +		}
> > +		pcb->data.raw[i] = inb_command(dev->base_addr);
> > +		if (stat & ASF_PCB_MASK == ASF_PCB_END || j >= 20000)
> > +			break;

Here is no ++i after breaking the loop, so no need for [--i] later;
please, check this more.

Jarek P.

> > +	}
> >  	spin_unlock_irqrestore(&adapter->lock, flags);
> > +	if (i >= MAX_PCB_DATA) {
> > +		INVALID_PCB_MSG(i);
> > +		return false;
> > +	}
> >  	if (j >= 20000) {
> >  		TIMEOUT_MSG(__LINE__);
> >  		return false;
> > diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
> > index 7eafdca..85e88da 100644
> > --- a/drivers/net/irda/mcs7780.c
> > +++ b/drivers/net/irda/mcs7780.c
> > @@ -585,7 +585,7 @@ static int mcs_speed_change(struct mcs_cb *mcs)
> >  		mcs_get_reg(mcs, MCS_RESV_REG, &rval);
> >  	} while(cnt++ < 100 && (rval & MCS_IRINTX));
> >  
> > -	if(cnt >= 100) {
> > +	if (cnt > 100) {
> >  		IRDA_ERROR("unable to change speed\n");
> >  		ret = -EIO;
> >  		goto error;
> > 

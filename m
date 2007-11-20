From: Ben Dooks <ben@fluff.org>
Subject: Re: [patch 06/22] NET: DM9000: Use kthread to probe MII status
	when device open
Date: Tue, 20 Nov 2007 10:13:33 +0000
Message-ID: <20071120101333.GA3244@fluff.org.uk>
References: <20071119203910.687238131@fluff.org> <20071119204013.745821010@fluff.org> <20071120074627.GA31558@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org,
	vince@simtec.co.uk
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:49461 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752459AbXKTKNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 05:13:44 -0500
Content-Disposition: inline
In-Reply-To: <20071120074627.GA31558@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2007 at 07:46:27AM +0000, Christoph Hellwig wrote:
> > +static void dm9000_start_thread(struct net_device *dev)
> > +{
> > +	board_info_t *db = (board_info_t *) dev->priv;
> > +
> > +	/* Create a thread to keep track of the state of the phy
> > +	 * as we do not get an interrupt when the PHY state changes.
> > +	 *
> > +	 * Note, we do not abort the open if we fail to create the
> > +	 * thread, as this is mainly to ensure the user is kept up to
> > +	 * date with the device's state. PHY accesses will still work
> > +	 * via the MII read and write methods.
> > +	 */
> > +
> > +	db->thread = kthread_create(dm9000_mii_thread, db, dev->name);
> > +	if (IS_ERR(db->thread)) {
> > +		dev_err(db->dev, "failed to create MII thread\n");
> > +		db->thread = NULL;
> > +	} else
> > +		wake_up_process(db->thread);
> > +}
> > +
> >  /*
> >   *  Open the interface.
> >   *  The interface is opened whenever "ifconfig" actives it.
> > @@ -704,12 +724,7 @@ dm9000_open(struct net_device *dev)
> >  	/* Init driver variable */
> >  	db->dbug_cnt = 0;
> >  
> > -	/* set and active a timer process */
> > -	init_timer(&db->timer);
> > -	db->timer.expires  = DM9000_TIMER_WUT;
> > -	db->timer.data     = (unsigned long) dev;
> > -	db->timer.function = &dm9000_timer;
> > -	add_timer(&db->timer);
> > +	dm9000_start_thread(dev);
> 
> Please don't just ignore the error.  Just inline the content of
> dm9000_start_thread into the caller and use proper goto-based
> unwinding.

The error is not important, I would be happy with adding an
error print in there, but not having the MII system print
an message if the link status changes is not an driver threatening
error.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'

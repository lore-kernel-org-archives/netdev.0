From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [irda-users] [BUG] 2.6.20.1-rt8 irnet + pppd recursive spinlock...
Date: Tue, 1 May 2007 03:53:23 +0300
Message-ID: <20070501005323.GB3407@sortiz.org>
References: <Pine.LNX.4.63.0704050846480.534@pcgl.dsa-ac.de> <Pine.LNX.4.63.0704051250170.534@pcgl.dsa-ac.de> <20070407005926.GE4177@sortiz.org> <20070410181037.GA3780@sortiz.org> <Pine.LNX.4.63.0704301451510.19781@pcgl.dsa-ac.de>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: irda-users@lists.sourceforge.net,
	Paul Mackerras <paulus@samba.org>,
	linux-rt-users@vger.kernel.org, netdev@vger.kernel.org
To: Guennadi Liakhovetski <gl@dsa-ac.de>
Return-path: <linux-rt-users-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.63.0704301451510.19781@pcgl.dsa-ac.de>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 30, 2007 at 03:24:05PM +0200, Guennadi Liakhovetski wrote:
> On Tue, 10 Apr 2007, Samuel Ortiz wrote:
> 
> > Hi Guennadi,
> > 
> > The patch below schedules irnet_flow_indication() asynchronously. Could
> > you please give it a try (it builds, but I couldn't test it...) ? :
> 
> Ok, your patch (still below) works too (now that I fixed that state 
> machine race, btw, we still have to decide on the final form how it goes 
> in the mainline) __after__ you also add the line
> 
> +	INIT_WORK(&new->irnet_flow_work, irttp_flow_restart);
> 
> in irttp_dup() (remember spinlock_init()?:-)), otherwise it oopses.
good catch, again...Yes, I do remember the irttp_dup bug ;-)

 
> Generally, I like your patch better than mine to ppp_generic.c, where I 
> explicitly check if a recursion is occurring. Still, I am a bit concerned 
> about introducing yet another execution context into irda... We have seen 
> a couple of locking issues there already in the last 2-3 months especially 
> under rt-preempt... Would you be able to run some tests too? 
I think I can run some tests here as well, but probably not as many as you:
I'm not doing IrDA stuff full time while it seems you currently are.
But I will definitely spend some time this week running my IrDA stack with this
patch applied. I didn't bother to do that earlier as you first reported some
oops with this patch applied.

> I will be 
> testing it too, but don't know how much longer and how intensively. Do you 
> think we might get some new problems with this new context?
It seems quite safe to me. But more importantly, I thing we do want to call
the flow indication routine asynchronously in that specific case. 
There is one thing that this patch is missing though: we should probably
clean the worqueue right before we destroy the TTP instance. The work routine
checks for NULL pointer, but still...

Cheers,
Samuel.


> Thanks
> Guennadi
> 
> > 
> > diff --git a/include/net/irda/irttp.h b/include/net/irda/irttp.h
> > index a899e58..941f0f1 100644
> > --- a/include/net/irda/irttp.h
> > +++ b/include/net/irda/irttp.h
> > @@ -128,6 +128,7 @@ struct tsap_cb {
> >  
> >  	struct net_device_stats stats;
> >  	struct timer_list todo_timer; 
> > +	struct work_struct irnet_flow_work;   /* irttp asynchronous flow restart */
> >  
> >  	__u32 max_seg_size;     /* Max data that fit into an IrLAP frame */
> >  	__u8  max_header_size;
> > diff --git a/net/irda/irnet/irnet.h b/net/irda/irnet/irnet.h
> > diff --git a/net/irda/irttp.c b/net/irda/irttp.c
> > index 7069e4a..a0d0f26 100644
> > --- a/net/irda/irttp.c
> > +++ b/net/irda/irttp.c
> > @@ -367,6 +367,29 @@ static int irttp_param_max_sdu_size(void *instance, irda_param_t *param,
> >  /*************************** CLIENT CALLS ***************************/
 > >  /************************** LMP CALLBACKS **************************/
> >  /* Everything is happily mixed up. Waiting for next clean up - Jean II */
> > +static void irttp_flow_restart(struct work_struct *work)
> > +{
> > +	struct tsap_cb * self =
> > +		container_of(work, struct tsap_cb, irnet_flow_work);
> > +
> > +	if (self == NULL)
> > +		return;
> > +
> > +	/* Check if we can accept more frames from client. */
> > +	if ((self->tx_sdu_busy) &&
> > +	    (skb_queue_len(&self->tx_queue) < TTP_TX_LOW_THRESHOLD) &&
> > +	    (!self->close_pend)) {
> > +		if (self->notify.flow_indication)
> > +			self->notify.flow_indication(self->notify.instance,
> > +						     self, FLOW_START);
> > +
> > +		/* self->tx_sdu_busy is the state of the client.
> > +		 * We don't really have a race here, but it's always safer
> > +		 * to update our state after the client - Jean II */
> > +		self->tx_sdu_busy = FALSE;
> > +	}
> > +}
> > +
> >  
> >  /*
> >   * Function irttp_open_tsap (stsap, notify)
> > @@ -402,6 +425,8 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
> >  	self->todo_timer.data     = (unsigned long) self;
> >  	self->todo_timer.function = &irttp_todo_expired;
> >  
> > +	INIT_WORK(&self->irnet_flow_work, irttp_flow_restart);
> > +
> >  	/* Initialize callbacks for IrLMP to use */
> >  	irda_notify_init(&ttp_notify);
> >  	ttp_notify.connect_confirm = irttp_connect_confirm;
> > @@ -761,25 +786,10 @@ static void irttp_run_tx_queue(struct tsap_cb *self)
> >  		self->stats.tx_packets++;
> >  	}
> >  
> > -	/* Check if we can accept more frames from client.
> > -	 * We don't want to wait until the todo timer to do that, and we
> > -	 * can't use tasklets (grr...), so we are obliged to give control
> > -	 * to client. That's ok, this test will be true not too often
> > -	 * (max once per LAP window) and we are called from places
> > -	 * where we can spend a bit of time doing stuff. - Jean II */
> >  	if ((self->tx_sdu_busy) &&
> >  	    (skb_queue_len(&self->tx_queue) < TTP_TX_LOW_THRESHOLD) &&
> >  	    (!self->close_pend))
> > -	{
> > -		if (self->notify.flow_indication)
> > -			self->notify.flow_indication(self->notify.instance,
> > -						     self, FLOW_START);
> > -
> > -		/* self->tx_sdu_busy is the state of the client.
> > -		 * We don't really have a race here, but it's always safer
> > -		 * to update our state after the client - Jean II */
> > -		self->tx_sdu_busy = FALSE;
> > -	}
> > +		schedule_work(&self->irnet_flow_work);
> >  
> >  	/* Reset lock */
> >  	self->tx_queue_lock = 0;
> > 
> > 
> > 
> 
> ---------------------------------
> Guennadi Liakhovetski, Ph.D.
> DSA Daten- und Systemtechnik GmbH
> Pascalstr. 28
> D-52076 Aachen
> Germany
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> irda-users mailing list
> irda-users@lists.sourceforge.net
> http://lists.sourceforge.net/lists/listinfo/irda-users

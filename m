From: Guennadi Liakhovetski <gl@dsa-ac.de>
Subject: Re: [irda-users] [BUG] 2.6.20.1-rt8 irnet + pppd recursive spinlock...
Date: Wed, 2 May 2007 13:05:08 +0200 (CEST)
Message-ID: <Pine.LNX.4.63.0705021154000.19781@pcgl.dsa-ac.de>
References: <Pine.LNX.4.63.0704050846480.534@pcgl.dsa-ac.de>
 <Pine.LNX.4.63.0704051250170.534@pcgl.dsa-ac.de> <20070407005926.GE4177@sortiz.org>
 <20070410181037.GA3780@sortiz.org> <Pine.LNX.4.63.0704301451510.19781@pcgl.dsa-ac.de>
 <20070501005323.GB3407@sortiz.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: irda-users@lists.sourceforge.net,
	Paul Mackerras <paulus@samba.org>,
	linux-rt-users@vger.kernel.org, netdev@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20070501005323.GB3407@sortiz.org>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 May 2007, Samuel Ortiz wrote:
> But I will definitely spend some time this week running my IrDA stack 
> with this patch applied. I didn't bother to do that earlier as you first 
> reported some oops with this patch applied.

I think, what I reported was not an Oops, but the race that we're also 
fixing ATM - the one in the state machine. So, unrelated.

> On Mon, Apr 30, 2007 at 03:24:05PM +0200, Guennadi Liakhovetski wrote:

> > in irttp_dup() (remember spinlock_init()?:-)), otherwise it oopses.
> good catch, again...Yes, I do remember the irttp_dup bug ;-)

I've put a tsap_init() function that does those common initialisation 
calls, so we have a smaller chance of forgetting the dup() path next 
time...

> > I will be 
> > testing it too, but don't know how much longer and how intensively. Do you 
> > think we might get some new problems with this new context?
> It seems quite safe to me. But more importantly, I thing we do want to call
> the flow indication routine asynchronously in that specific case. 
> There is one thing that this patch is missing though: we should probably
> clean the worqueue right before we destroy the TTP instance. The work routine
> checks for NULL pointer, but still...

I thought about it too, but the only thing you can do is 
flush_scheduled_work(), is this what you mean?

The test with your patch stopped inside a ftp transfer - the ftp client 
was doing a get, and it stopped half-way through. On the client side only 
the control tcp connection was still open, on the client both ftp-server 
forked children were dead, no connection open. No errors in logs. Weird. 
With my "ugly" patch it ran the weekend through.

...and it just stopped again - this time after just 13 minutes.

A couple of comments to your patch:

> > > +static void irttp_flow_restart(struct work_struct *work)
> > > +{
> > > +	struct tsap_cb * self =
> > > +		container_of(work, struct tsap_cb, irnet_flow_work);
> > > +
> > > +	if (self == NULL)
> > > +		return;

self will not be NULL here. How about

+	IRDA_ASSERT(work != NULL, return;);
+	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);

> > > -	/* Check if we can accept more frames from client.
> > > -	 * We don't want to wait until the todo timer to do that, and we
> > > -	 * can't use tasklets (grr...), so we are obliged to give control
> > > -	 * to client. That's ok, this test will be true not too often
> > > -	 * (max once per LAP window) and we are called from places
> > > -	 * where we can spend a bit of time doing stuff. - Jean II */
> > >  	if ((self->tx_sdu_busy) &&
> > >  	    (skb_queue_len(&self->tx_queue) < TTP_TX_LOW_THRESHOLD) &&
> > >  	    (!self->close_pend))

Is this test still needed here? You do it again in the work-function, and 
the conditions can change, so, should we schedule_work unconditionally 
here?

Thanks
Guennadi
---------------------------------
Guennadi Liakhovetski, Ph.D.
DSA Daten- und Systemtechnik GmbH
Pascalstr. 28
D-52076 Aachen
Germany

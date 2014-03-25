From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: disable rogue vif in
 kthread context
Date: Tue, 25 Mar 2014 00:55:03 +0000
Message-ID: <20140325005503.GA22245@zion.uk.xensource.com>
References: <1395663214-14133-1-git-send-email-wei.liu2@citrix.com>
 <533029C7.1080006@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, <paul.durrant@citrix.com>,
	<edwin@etorok.net>, Ian Campbell <ian.campbell@citrix.com>,
	<zoltan.kiss@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:62899 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbaCYAzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 20:55:05 -0400
Content-Disposition: inline
In-Reply-To: <533029C7.1080006@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 24, 2014 at 12:49:11PM +0000, David Vrabel wrote:
> On 24/03/14 12:13, Wei Liu wrote:
> > When netback discovers frontend is sending malformed packet it will
> > disables the interface which serves that frontend.
> > 
> > However disabling a network interface involving taking a mutex which
> > cannot be done in softirq context, so we need to defer this process to
> > kthread context.
> > 
> > This patch does the following:
> > 1. introduce a flag to indicate the interface is disabled.
> > 2. check that flag in TX path, don't do any work if it's true.
> > 3. check that flag in RX path, turn off that interface if it's true.
> > 
> > The reason to disable it in RX path is because RX uses kthread. After
> > this change the behavior of netback is still consistent -- it won't do
> > any TX work for a rogue frontend, and the interface will be eventually
> > turned off.
> > 
> > Also change a "continue" to "break" after xenvif_fatal_tx_err, as it
> > doesn't make sense to continue processing packets if frontend is rogue.
> [...]
> > --- a/drivers/net/xen-netback/interface.c
> > +++ b/drivers/net/xen-netback/interface.c
> > @@ -62,6 +62,13 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
> >  	struct xenvif *vif = container_of(napi, struct xenvif, napi);
> >  	int work_done;
> >  
> > +	/* This vif is rogue, we pretend we've used up all budget to
> > +	 * deschedule it from NAPI. But this interface will be turned
> > +	 * off in thread context later.
> > +	 */
> > +	if (unlikely(vif->disabled))
> > +		return budget;
> 
> Shouldn't you call __napi_complete() and return 0?  Returning budget
> will make NAPI poll repeatedly (since you're pretending to do work).
> 

Yes. You're right.

> > diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> > index 438d0c0..94e7261 100644
> > --- a/drivers/net/xen-netback/netback.c
> > +++ b/drivers/net/xen-netback/netback.c
> > @@ -655,7 +655,7 @@ static void xenvif_tx_err(struct xenvif *vif,
> >  static void xenvif_fatal_tx_err(struct xenvif *vif)
> >  {
> >  	netdev_err(vif->dev, "fatal error; disabling device\n");
> > -	xenvif_carrier_off(vif);
> > +	vif->disabled = true;
> 
> Do you need to wake the thread here?
> 

That's a better approach.

> > @@ -1549,6 +1549,16 @@ int xenvif_kthread(void *data)
> >  		wait_event_interruptible(vif->wq,
> >  					 rx_work_todo(vif) ||
> >  					 kthread_should_stop());
> 
>                                          || vif->disabled ?
> 
> > +
> > +		/* This frontend is found to be rogue, disable it in
> > +		 * kthread context. Currently this is only set when
> > +		 * netback finds out frontend sends malformed packet,
> > +		 * but we cannot disable the interface in softirq
> > +		 * context so we defer it here.
> > +		 */
> > +		if (unlikely(vif->disabled) && netif_carrier_ok(vif->dev))
> > +			xenvif_carrier_off(vif);
> > +
> >  		if (kthread_should_stop())
> >  			break;
> >  
> 
> As an aside, since I happened to be looking at xenvif_poll(), disabling
> local irqs to avoid problems with concurrent events looks unsafe as the
> event may occur on another VCPU.
> 

Are you seeing any problem? If this is not related to this fix we should
probably discuss this in another thread.

>    __napi_complete(napi);
>    RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
>    if (more_to_do)
>        napi_schedule(napi);
> 
> Would work I think.
> 

Not sure I get your suggestion. Sorry. If you're talking about the code
in xenvif_poll, there's comment up there describing a race. Again, this
should be discussed in separate thread.

Wei.

> David

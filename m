From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net V2] xen-netback: disable rogue vif in
 kthread context
Date: Tue, 25 Mar 2014 13:38:34 +0000
Message-ID: <20140325133834.GE31766@zion.uk.xensource.com>
References: <1395750051-15932-1-git-send-email-wei.liu2@citrix.com>
 <53317ECA.4040406@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, Ian Campbell <ian.campbell@citrix.com>,
	<edwin@etorok.net>, <paul.durrant@citrix.com>,
	<zoltan.kiss@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:38324 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751539AbaCYNjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2014 09:39:09 -0400
Content-Disposition: inline
In-Reply-To: <53317ECA.4040406@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2014 at 01:04:10PM +0000, David Vrabel wrote:
> On 25/03/14 12:20, Wei Liu wrote:
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
> [...]
> > --- a/drivers/net/xen-netback/interface.c
> > +++ b/drivers/net/xen-netback/interface.c
> > @@ -61,12 +61,23 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
> >  {
> >  	struct xenvif *vif = container_of(napi, struct xenvif, napi);
> >  	int work_done;
> > +	unsigned long flags;
> > +
> > +	/* This vif is rogue, we pretend we've there is nothing to do
> > +	 * for this vif to deschedule it from NAPI. But this interface
> > +	 * will be turned off in thread context later.
> > +	 */
> > +	if (unlikely(vif->disabled)) {
> > +		local_irq_save(flags);
> > +		__napi_complete(napi);
> > +		local_irq_restore(flags);
> 
> Why isn't this napi_complete(napi) (which uses local_irq_save/restore()
> internally)?
> 

The difference between napi_complete and __napi_complete is that
napi_complete will not descheduled this instance if it's being served on
another CPU.

Wei.

> David

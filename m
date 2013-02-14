From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 2/2] xen-netback: cancel the credit timer
 when taking the vif down
Date: Thu, 14 Feb 2013 16:48:59 +0000
Message-ID: <1360860539.16636.162.camel@zion.uk.xensource.com>
References: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>
	 <1360847938-11185-3-git-send-email-david.vrabel@citrix.com>
	 <1360859947.20449.465.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, David Vrabel <david.vrabel@citrix.com>,
	"Christopher S. Aker" <caker@theshore.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"Wei Liu (3P)" <wei.liu@citrix.com>,
	Jan Beulich <jbeulich@suse.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:25463 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934247Ab3BNQtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 11:49:01 -0500
In-Reply-To: <1360859947.20449.465.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 16:39 +0000, Ian Campbell wrote:
> On Thu, 2013-02-14 at 13:18 +0000, David Vrabel wrote:
> > From: David Vrabel <david.vrabel@citrix.com>
> > 
> > If the credit timer is left armed after calling
> > xen_netbk_remove_xenvif(), then it may fire and attempt to schedule
> > the vif which will then oops as vif->netbk == NULL.
> > 
> > This may happen both in the fatal error path and during normal
> > disconnection from the front end.
> > 
> > The sequencing during shutdown is critical to ensure that: a)
> > vif->netbk doesn't become unexpectedly NULL; and b) the net device/vif
> > is not freed.
> > 
> > 1. Mark as unschedulable (netif_carrier_off()).
> > 2. Synchronously cancel the timer.
> > 3. Remove the vif from the schedule list.
> > 4. Remove it from it netback thread group.
> > 5. Wait for vif->refcnt to become 0.
> > 
> > Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> 
> Was this one also Reported-by Christopher S. Aker or was it just
> discovered in the process of investigating?
> 

His bug report did prod me to look into this, so I think it is worth
adding

Reported-by: Christopher S. Aker <caker@theshore.net>


Wei.

> Another stable candidate please Dave.
> 
> > ---
> >  drivers/net/xen-netback/interface.c |    3 +--
> >  1 files changed, 1 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> > index b8c5193..221f426 100644
> > --- a/drivers/net/xen-netback/interface.c
> > +++ b/drivers/net/xen-netback/interface.c
> > @@ -132,6 +132,7 @@ static void xenvif_up(struct xenvif *vif)
> >  static void xenvif_down(struct xenvif *vif)
> >  {
> >  	disable_irq(vif->irq);
> > +	del_timer_sync(&vif->credit_timeout);
> >  	xen_netbk_deschedule_xenvif(vif);
> >  	xen_netbk_remove_xenvif(vif);
> >  }
> > @@ -363,8 +364,6 @@ void xenvif_disconnect(struct xenvif *vif)
> >  	atomic_dec(&vif->refcnt);
> >  	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) == 0);
> >  
> > -	del_timer_sync(&vif->credit_timeout);
> > -
> >  	if (vif->irq)
> >  		unbind_from_irqhandler(vif->irq, vif);
> >  
> 
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel

From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH V3 05/16] netback: add module get/put operations
 along with vif connect/disconnect.
Date: Tue, 31 Jan 2012 10:39:59 +0000
Message-ID: <1328006399.5553.58.camel@leeds.uk.xensource.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
	 <1327934734-8908-6-git-send-email-wei.liu2@citrix.com>
	 <1328005476.26983.335.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:30795 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635Ab2AaKjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 05:39:47 -0500
In-Reply-To: <1328005476.26983.335.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-31 at 10:24 +0000, Ian Campbell wrote:
> On Mon, 2012-01-30 at 14:45 +0000, Wei Liu wrote:
> > If there is vif running and user unloads netback, it will certainly
> > cause problems -- guest's network interface just mysteriously stops
> > working.
> 
> This seems like a bug fix for  02/16 "netback: add module unload
> function". Please could you fold back such fixes where appropriate? I
> think there's a handful of these sorts of patches in the series.
> 

Sure.

> > v2: fix module_put path
> > 
> > disconnect function may get called by the generic framework even
> > before vif connects.
> > 
> > Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> > ---
> >  drivers/net/xen-netback/interface.c |   11 ++++++++++-
> >  1 files changed, 10 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> > index dfc04f8..7914f60 100644
> > --- a/drivers/net/xen-netback/interface.c
> > +++ b/drivers/net/xen-netback/interface.c
> > @@ -323,6 +323,8 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
> >  	if (vif->irq)
> >  		return 0;
> >  
> > +	__module_get(THIS_MODULE);
> > +
> >  	err = xen_netbk_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
> >  	if (err < 0)
> >  		goto err;
> > @@ -372,12 +374,14 @@ err_unbind:
> >  err_unmap:
> >  	xen_netbk_unmap_frontend_rings(vif);
> >  err:
> > +	module_put(THIS_MODULE);
> >  	return err;
> >  }
> >  
> >  void xenvif_disconnect(struct xenvif *vif)
> >  {
> >  	struct net_device *dev = vif->dev;
> > +	int need_module_put = 0;
> >  
> >  	if (netif_carrier_ok(dev)) {
> >  		rtnl_lock();
> > @@ -397,12 +401,17 @@ void xenvif_disconnect(struct xenvif *vif)
> >  
> >  	del_timer_sync(&vif->credit_timeout);
> >  
> > -	if (vif->irq)
> > +	if (vif->irq) {
> >  		unbind_from_irqhandler(vif->irq, vif);
> > +		need_module_put = 1;
> 
> This seems like a slightly odd condition. Why is the put not
> unconditional?
> 

This is what I observed. The framework will call disconnect
unconditionally in the cleanup phase. If the frontend fails to
initialize, the connect function will not get called, so there lacks a
corresponding module_get().


Wei.

> 
> > +	}
> >  
> >  	unregister_netdev(vif->dev);
> >  
> >  	xen_netbk_unmap_frontend_rings(vif);
> >  
> >  	free_netdev(vif->dev);
> > +
> > +	if (need_module_put)
> > +		module_put(THIS_MODULE);
> >  }
> 
> 

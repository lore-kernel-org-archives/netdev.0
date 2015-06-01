From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net] xen: netback: read hotplug script once at start of
 day.
Date: Mon, 1 Jun 2015 10:07:04 +0100
Message-ID: <20150601090704.GJ30474@zion.uk.xensource.com>
References: <1432916693-21121-1-git-send-email-ian.campbell@citrix.com>
 <20150529173850.GI30474@zion.uk.xensource.com>
 <1433148765.15036.79.camel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <david.vrabel@citrix.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:50981 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbFAJHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 05:07:06 -0400
Content-Disposition: inline
In-Reply-To: <1433148765.15036.79.camel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 01, 2015 at 09:52:45AM +0100, Ian Campbell wrote:
> On Fri, 2015-05-29 at 18:38 +0100, Wei Liu wrote:
> > On Fri, May 29, 2015 at 05:24:53PM +0100, Ian Campbell wrote:
> > [...]
> > >  	if (be->vif != NULL)
> > >  		return 0;
> > > @@ -417,12 +409,23 @@ static int backend_create_xenvif(struct backend_info *be)
> > >  		return (err < 0) ? err : -EINVAL;
> > >  	}
> > >  
> > > +	script = xenbus_read(XBT_NIL, dev->nodename, "script", NULL);
> > > +	if (IS_ERR(script)) {
> > > +		int err = PTR_ERR(script);
> > > +		xenbus_dev_fatal(dev, err, "reading script");
> > > +		return err;
> > > +	}
> > > +
> > >  	vif = xenvif_alloc(&dev->dev, dev->otherend_id, handle);
> > >  	if (IS_ERR(vif)) {
> > >  		err = PTR_ERR(vif);
> > >  		xenbus_dev_fatal(dev, err, "creating interface");
> > > +		kfree(script);
> > >  		return err;
> > >  	}
> > > +
> > > +	vif->hotplug_script = script;
> > > +
> > 
> > IMO it's better we make xenvif_alloc accept a new parameter called
> > "script" then allocate vif->hotplug_script there. Then free
> > vif->hotplug_script in xenvif_free. This way it's less error prone
> > because all memory allocated for vif is managed in proper place -
> > xenvif_alloc and xenvif_free.
> 
> Well, except the allocation is still in xenbus_read via
> backend_create_xenvif, but yes I think that refactoring would be an
> improvement.
> 
> What about storing it in struct backend_info and setting/restoring in
> netback_{probe,remove}? That might be best of all?
> 

Yes, that would be best.

Wei.

> Ian.
> 

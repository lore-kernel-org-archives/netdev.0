From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v1] xen-netback: implement dynamic multicast
 control
Date: Tue, 2 Feb 2016 11:15:21 +0000
Message-ID: <f46a7ff6d59642c08fc5e2bec9177494@AMSPEX02CL03.citrite.net>
References: <1454337653-8517-1-git-send-email-paul.durrant@citrix.com>
 <20160202110837.GY25660@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"Ian Campbell" <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:2302 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499AbcBBL1s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 06:27:48 -0500
In-Reply-To: <20160202110837.GY25660@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 02 February 2016 11:09
> To: Paul Durrant
> Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org; Ian Campbell;
> Wei Liu
> Subject: Re: [PATCH net-next v1] xen-netback: implement dynamic multicast
> control
> 
> On Mon, Feb 01, 2016 at 02:40:53PM +0000, Paul Durrant wrote:
> [...]
> > +static int xen_register_mcast_ctrl_watch(struct xenbus_device *dev,
> > +					 struct xenvif *vif)
> > +{
> > +	int err = 0;
> > +	char *node;
> > +	unsigned maxlen = strlen(dev->otherend) +
> > +		sizeof("/request-multicast-control");
> > +
> > +	if (vif->mcast_ctrl_watch.node)
> > +		return -EADDRINUSE;
> > +
> > +	node = kmalloc(maxlen, GFP_KERNEL);
> > +	if (!node)
> > +		return -ENOMEM;
> 
> This is one error path that has no logging, so please either add logging
> in each error patch ...
> 

Sure.

> > +	snprintf(node, maxlen, "%s/request-multicast-control",
> > +		 dev->otherend);
> > +	vif->mcast_ctrl_watch.node = node;
> > +	vif->mcast_ctrl_watch.callback = xen_mcast_ctrl_changed;
> > +	err = register_xenbus_watch(&vif->mcast_ctrl_watch);
> > +	if (err) {
> > +		pr_err("Failed to set watcher %s\n",
> > +		       vif->mcast_ctrl_watch.node);
> > +		kfree(node);
> > +		vif->mcast_ctrl_watch.node = NULL;
> > +		vif->mcast_ctrl_watch.callback = NULL;
> > +	}
> > +	return err;
> > +}
> > +
> > +static void xen_unregister_mcast_ctrl_watch(struct xenvif *vif)
> > +{
> > +	if (vif->mcast_ctrl_watch.node) {
> > +		unregister_xenbus_watch(&vif->mcast_ctrl_watch);
> > +		kfree(vif->mcast_ctrl_watch.node);
> > +		vif->mcast_ctrl_watch.node = NULL;
> > +	}
> > +}
> > +
> > +static void xen_register_watchers(struct xenbus_device *dev,
> > +				  struct xenvif *vif)
> > +{
> > +	xen_register_credit_watch(dev, vif);
> > +	xen_register_mcast_ctrl_watch(dev, vif);
> > +}
> > +
> > +static void xen_unregister_watchers(struct xenvif *vif)
> > +{
> > +	xen_unregister_mcast_ctrl_watch(vif);
> > +	xen_unregister_credit_watch(vif);
> > +}
> 
> ... or check if these register/unregister function calls' return value
> and log if something fails.
> 

Given that the similar failure path in credit watch registration never logged adding a check here may create noise where there was none before.

  Paul

> Wei.

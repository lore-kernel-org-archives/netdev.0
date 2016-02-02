From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v1] xen-netback: implement dynamic multicast
 control
Date: Tue, 2 Feb 2016 11:08:37 +0000
Message-ID: <20160202110837.GY25660@citrix.com>
References: <1454337653-8517-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:4172 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754556AbcBBLIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 06:08:39 -0500
Content-Disposition: inline
In-Reply-To: <1454337653-8517-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 01, 2016 at 02:40:53PM +0000, Paul Durrant wrote:
[...]
> +static int xen_register_mcast_ctrl_watch(struct xenbus_device *dev,
> +					 struct xenvif *vif)
> +{
> +	int err = 0;
> +	char *node;
> +	unsigned maxlen = strlen(dev->otherend) +
> +		sizeof("/request-multicast-control");
> +
> +	if (vif->mcast_ctrl_watch.node)
> +		return -EADDRINUSE;
> +
> +	node = kmalloc(maxlen, GFP_KERNEL);
> +	if (!node)
> +		return -ENOMEM;

This is one error path that has no logging, so please either add logging
in each error patch ...

> +	snprintf(node, maxlen, "%s/request-multicast-control",
> +		 dev->otherend);
> +	vif->mcast_ctrl_watch.node = node;
> +	vif->mcast_ctrl_watch.callback = xen_mcast_ctrl_changed;
> +	err = register_xenbus_watch(&vif->mcast_ctrl_watch);
> +	if (err) {
> +		pr_err("Failed to set watcher %s\n",
> +		       vif->mcast_ctrl_watch.node);
> +		kfree(node);
> +		vif->mcast_ctrl_watch.node = NULL;
> +		vif->mcast_ctrl_watch.callback = NULL;
> +	}
> +	return err;
> +}
> +
> +static void xen_unregister_mcast_ctrl_watch(struct xenvif *vif)
> +{
> +	if (vif->mcast_ctrl_watch.node) {
> +		unregister_xenbus_watch(&vif->mcast_ctrl_watch);
> +		kfree(vif->mcast_ctrl_watch.node);
> +		vif->mcast_ctrl_watch.node = NULL;
> +	}
> +}
> +
> +static void xen_register_watchers(struct xenbus_device *dev,
> +				  struct xenvif *vif)
> +{
> +	xen_register_credit_watch(dev, vif);
> +	xen_register_mcast_ctrl_watch(dev, vif);
> +}
> +
> +static void xen_unregister_watchers(struct xenvif *vif)
> +{
> +	xen_unregister_mcast_ctrl_watch(vif);
> +	xen_unregister_credit_watch(vif);
> +}

... or check if these register/unregister function calls' return value
and log if something fails.

Wei.

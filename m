From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net] xen: netback: read hotplug script once at start of
 day.
Date: Fri, 29 May 2015 18:38:50 +0100
Message-ID: <20150529173850.GI30474@zion.uk.xensource.com>
References: <1432916693-21121-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>, <david.vrabel@citrix.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45118 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756652AbbE2Riy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 13:38:54 -0400
Content-Disposition: inline
In-Reply-To: <1432916693-21121-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2015 at 05:24:53PM +0100, Ian Campbell wrote:
[...]
>  	if (be->vif != NULL)
>  		return 0;
> @@ -417,12 +409,23 @@ static int backend_create_xenvif(struct backend_info *be)
>  		return (err < 0) ? err : -EINVAL;
>  	}
>  
> +	script = xenbus_read(XBT_NIL, dev->nodename, "script", NULL);
> +	if (IS_ERR(script)) {
> +		int err = PTR_ERR(script);
> +		xenbus_dev_fatal(dev, err, "reading script");
> +		return err;
> +	}
> +
>  	vif = xenvif_alloc(&dev->dev, dev->otherend_id, handle);
>  	if (IS_ERR(vif)) {
>  		err = PTR_ERR(vif);
>  		xenbus_dev_fatal(dev, err, "creating interface");
> +		kfree(script);
>  		return err;
>  	}
> +
> +	vif->hotplug_script = script;
> +

IMO it's better we make xenvif_alloc accept a new parameter called
"script" then allocate vif->hotplug_script there. Then free
vif->hotplug_script in xenvif_free. This way it's less error prone
because all memory allocated for vif is managed in proper place -
xenvif_alloc and xenvif_free.

Wei.

>  	be->vif = vif;
>  
>  	kobject_uevent(&dev->dev.kobj, KOBJ_ONLINE);
> -- 
> 1.7.10.4

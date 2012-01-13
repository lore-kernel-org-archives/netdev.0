From: David Vrabel <dvrabel@cantab.net>
Subject: Re: [Xen-devel] [RFC PATCH 2/6] netback: add module unload function.
Date: Fri, 13 Jan 2012 18:47:41 +0000
Message-ID: <4F107C4D.7090309@cantab.net>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com> <1326473949-22389-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:50260 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541Ab2AMSrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 13:47:46 -0500
Received: by yhnn56 with SMTP id n56so410890yhn.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 10:47:46 -0800 (PST)
In-Reply-To: <1326473949-22389-3-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/01/12 16:59, Wei Liu wrote:
> Enables users to unload netback module.
[...]
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 26af7b7..dd10c0d 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1653,5 +1653,19 @@ failed_init:
>  
>  module_init(netback_init);
>  
> +static void __exit netback_exit(void)
> +{
> +	int i;
> +	for (i = 0; i < xen_netbk_group_nr; i++) {
> +		struct xen_netbk *netbk = &xen_netbk[i];
> +		del_timer(&netbk->net_timer);
> +		kthread_stop(netbk->task);
> +	}
> +	vfree(xen_netbk);
> +	page_pool_destroy();
> +	xenvif_xenbus_exit();

I think you need to call xenvif_xenbus_exit() first, before cleaning up
all the other bits and pieces.

> +}
> +module_exit(netback_exit);
> +
>  MODULE_LICENSE("Dual BSD/GPL");
>  MODULE_ALIAS("xen-backend:vif");
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 410018c..65d14f2 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -485,3 +485,8 @@ int xenvif_xenbus_init(void)
>  {
>  	return xenbus_register_backend(&netback_driver);
>  }
> +
> +void xenvif_xenbus_exit(void)
> +{
> +	return xenbus_unregister_driver(&netback_driver);
> +}

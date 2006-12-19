From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH] irlan: handle out of memory errors
Date: Wed, 20 Dec 2006 00:47:26 +0200
Message-ID: <20061219224726.GC4274@sortiz.org>
References: <20061219085601.GL4049@APFDCB5C>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.18]:61272 "EHLO smtp19.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932994AbWLSXfg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Dec 2006 18:35:36 -0500
Received: from smtp19.orange.fr (mwinf1913 [172.22.129.41])
	by mwinf1915.orange.fr (SMTP Server) with ESMTP id 93A015C01C60
	for <netdev@vger.kernel.org>; Tue, 19 Dec 2006 23:47:53 +0100 (CET)
To: Akinobu Mita <akinobu.mita@gmail.com>
Content-Disposition: inline
In-Reply-To: <20061219085601.GL4049@APFDCB5C>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 19, 2006 at 05:56:01PM +0900, Akinobu Mita wrote:
> This patch checks return values:
> 
> - irlmp_register_client()
> - irlmp_register_service()
> - irlan_open()
> 
> Cc: Samuel Ortiz <samuel@sortiz.org>
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
This one seems correct as well, thanks again.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Cheers,
Samuel.


> 
> ---
>  net/irda/irlan/irlan_common.c |   23 ++++++++++++++++++++---
>  1 file changed, 20 insertions(+), 3 deletions(-)
> 
> Index: 2.6-mm/net/irda/irlan/irlan_common.c
> ===================================================================
> --- 2.6-mm.orig/net/irda/irlan/irlan_common.c
> +++ 2.6-mm/net/irda/irlan/irlan_common.c
> @@ -144,12 +144,18 @@ static int __init irlan_init(void)
>  	/* Register with IrLMP as a client */
>  	ckey = irlmp_register_client(hints, &irlan_client_discovery_indication,
>  				     NULL, NULL);
> -	
> +	if (!ckey)
> +		goto err_ckey;
> +
>  	/* Register with IrLMP as a service */
> - 	skey = irlmp_register_service(hints);
> +	skey = irlmp_register_service(hints);
> +	if (!skey)
> +		goto err_skey;
>  
>  	/* Start the master IrLAN instance (the only one for now) */
> - 	new = irlan_open(DEV_ADDR_ANY, DEV_ADDR_ANY);
> +	new = irlan_open(DEV_ADDR_ANY, DEV_ADDR_ANY);
> +	if (!new)
> +		goto err_open;
>  
>  	/* The master will only open its (listen) control TSAP */
>  	irlan_provider_open_ctrl_tsap(new);
> @@ -158,6 +164,17 @@ static int __init irlan_init(void)
>  	irlmp_discovery_request(DISCOVERY_DEFAULT_SLOTS);
>  
>  	return 0;
> +
> +err_open:
> +	irlmp_unregister_service(skey);
> +err_skey:
> +	irlmp_unregister_client(ckey);
> +err_ckey:
> +#ifdef CONFIG_PROC_FS
> +	remove_proc_entry("irlan", proc_irda);
> +#endif /* CONFIG_PROC_FS */
> +
> +	return -ENOMEM;
>  }
>  
>  static void __exit irlan_cleanup(void) 

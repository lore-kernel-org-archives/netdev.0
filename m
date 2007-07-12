From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: Re: [PATCH v2 -mm 9/9] netconsole: Support dynamic reconfiguration
 using configfs
Date: Thu, 12 Jul 2007 19:04:40 +0900
Message-ID: <4695FCB8.8090102@bx.jp.nec.com>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in> <20070710092006.23907.33652.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:39529 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758983AbXGLKIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 06:08:06 -0400
In-Reply-To: <20070710092006.23907.33652.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Satyam,

>  struct netconsole_target {
>  	struct list_head	list;
> +#ifdef	CONFIG_NETCONSOLE_DYNAMIC
> +	struct config_item	item;
> +	int			enabled;
> +#endif
>  	struct netpoll		np;
>  };

If CONFIG_NETCONSOLE_DYNAMIC is unset, we can't access to the "enabled" member.
So, the compile errors occur because the following functions make use of 
the above one.

> +/* Allocate new target (from boot/module param) and setup netpoll for it */
> +static struct netconsole_target *alloc_param_target(char *target_config)
>  {
>  	int err = -ENOMEM;
>  	struct netconsole_target *nt;
>  
> -	/* Allocate and initialize with defaults */
> +	/*
> +	 * Allocate and initialize with defaults.
> +	 * Note that these targets get their config_item fields zeroed-out.
> +	 */
>  	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
>  	if (!nt) {
>  		printk(KERN_ERR "netconsole: failed to allocate memory\n");
> @@ -106,6 +188,8 @@ static struct netconsole_target *alloc_t
>  	if (err)
>  		goto fail;
>  
> +	nt->enabled = 1;
> +
>  	return nt;
>  
>  fail:
> @@ -113,13 +197,469 @@ fail:
>  	return ERR_PTR(err);
>  }


> @@ -169,7 +711,8 @@ static void write_msg(struct console *co
>  
>  	spin_lock_irqsave(&target_list_lock, flags);
>  	list_for_each_entry(nt, &target_list, list) {
> -		if (netif_running(nt->np.dev)) {
> +		netconsole_target_get(nt);
> +		if (nt->enabled && netif_running(nt->np.dev)) {
>  			/*
>  			 * We nest this inside the for-each-target loop above
>  			 * so that we're able to get as much logging out to
> @@ -184,6 +727,7 @@ static void write_msg(struct console *co
>  				left -= frag;
>  			}
>  		}
> +		netconsole_target_put(nt);
>  	}
>  	spin_unlock_irqrestore(&target_list_lock, flags);
>  }

I created the following patch for performing some tests.
If there is nothing wrong with the patch, I'm going to continue to test.

Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>

Index: mm/drivers/net/netconsole.c
===================================================================
--- mm.orig/drivers/net/netconsole.c
+++ mm/drivers/net/netconsole.c
@@ -94,8 +94,8 @@ struct netconsole_target {
        struct list_head        list;
 #ifdef CONFIG_NETCONSOLE_DYNAMIC
        struct config_item      item;
-       int                     enabled;
 #endif
+       int                     enabled;
        struct netpoll          np;
 };


Thanks
-- 
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com

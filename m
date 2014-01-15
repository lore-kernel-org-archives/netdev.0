From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/ipv4: don't use module_init in non-modular
 gre_offload
Date: Wed, 15 Jan 2014 07:11:54 -0800
Message-ID: <1389798714.31367.343.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389797534-15657-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:45782 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbaAOPL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 10:11:57 -0500
Received: by mail-pb0-f48.google.com with SMTP id rr13so1242764pbb.21
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 07:11:56 -0800 (PST)
In-Reply-To: <1389797534-15657-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-15 at 09:52 -0500, Paul Gortmaker wrote:
> Recent commit 438e38fadca2f6e57eeecc08326c8a95758594d4
> ("gre_offload: statically build GRE offloading support") added
> new module_init/module_exit calls to the gre_offload.c file.
> 
> The file is obj-y and can't be anything other than built-in.
> Currently it can never be built modular, so using module_init
> as an alias for __initcall can be somewhat misleading.
> 
> Fix this up now, so that we can relocate module_init from
> init.h into module.h in the future.  If we don't do this, we'd
> have to add module.h to obviously non-modular code, and that
> would be a worse thing.  We also make the inclusion explicit.
> 
> Note that direct use of __initcall is discouraged, vs. one
> of the priority categorized subgroups.  As __initcall gets
> mapped onto device_initcall, our use of device_initcall
> directly in this change means that the runtime impact is
> zero -- it will remain at level 6 in initcall ordering.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index 29512e3e7e7c..ed968daf2380 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -11,6 +11,7 @@
>   */
>  
>  #include <linux/skbuff.h>
> +#include <linux/init.h>
>  #include <net/protocol.h>
>  #include <net/gre.h>
>  
> @@ -283,11 +284,10 @@ static int __init gre_offload_init(void)
>  {
>  	return inet_add_offload(&gre_offload, IPPROTO_GRE);
>  }
> +device_initcall(gre_offload_init);
>  
>  static void __exit gre_offload_exit(void)
>  {
>  	inet_del_offload(&gre_offload, IPPROTO_GRE);
>  }
> -
> -module_init(gre_offload_init);
> -module_exit(gre_offload_exit);
> +__exitcall(gre_offload_exit);

I guess we could remove gre_offload_exit() instead of using
this strange __exitcall()

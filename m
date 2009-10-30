From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC, PATCH] net: suspicious test in dev_change_name()
Date: Sat, 31 Oct 2009 00:50:09 +0100
Message-ID: <4AEB7BB1.9000901@gmail.com>
References: <4AEAAFC4.9050309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:40213 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754303AbZJ3Xu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 19:50:26 -0400
Received: by bwz27 with SMTP id 27so4187162bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 16:50:27 -0700 (PDT)
In-Reply-To: <4AEAAFC4.9050309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, On 10/30/2009 10:20 AM:

> While preparing a patch for net-next-2.6, I noticed following code in dev_change_name()
> 
> int err = 0;
> ...
>         ret = call_netdevice_notifiers(NETDEV_CHANGENAME, dev);
>         ret = notifier_to_errno(ret);
> 
>         if (ret) {
> << HERE >>      if (err) {
>                         printk(KERN_ERR
>                                "%s: name change rollback failed: %d.\n",
>                                dev->name, ret);
>                 } else {
>                         err = ret;
>                         memcpy(dev->name, oldname, IFNAMSIZ);
>                         goto rollback;
>                 }
>         }
> 
> 
> It seems intent was to test if notifier_to_errno() was null ?


I don't think so: err stores the previous ret meaning rollback and
is checked for this later. But somebody forgot err can store previous
(positive) value here, so IMHO you're right: there is a bug in this
place ;-)

Jarek P.

> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b8f74cf..029cd41 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -939,9 +939,9 @@ rollback:
>  	write_unlock_bh(&dev_base_lock);
>  
>  	ret = call_netdevice_notifiers(NETDEV_CHANGENAME, dev);
> -	ret = notifier_to_errno(ret);
>  
>  	if (ret) {
> +		err = notifier_to_errno(ret);
>  		if (err) {
>  			printk(KERN_ERR
>  			       "%s: name change rollback failed: %d.\n",
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 



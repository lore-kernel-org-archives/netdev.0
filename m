From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH][NETNS]: Fix arbitrary net_device-s corruptions on net_ns
 stop.
Date: Wed, 07 May 2008 17:33:57 +0200
Message-ID: <4821CBE5.5090801@fr.ibm.com>
References: <48216398.9050509@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:45002 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755700AbYEGPgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 11:36:43 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m47FZpwY589922
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 15:35:51 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m47FZpCD753886
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 16:35:51 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m47FZpvP014778
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 16:35:51 +0100
In-Reply-To: <48216398.9050509@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> When a net namespace is destroyed, some devices (those, not killed
> on ns stop explicitly) are moved back to init_net.
> 
> The problem, is that this net_ns change has one point of failure -
> the __dev_alloc_name() may be called if a name collision occurs (and
> this is easy to trigger). This allocator performs a likely-to-fail
> GFP_ATOMIC allocation to find a suitable number. Other possible 
> conditions that may cause error (for device being ns local or not
> registered) are always false in this case.
> 
> So, when this call fails, the device is unregistered. But this is
> *not* the right thing to do, since after this the device may be
> released (and kfree-ed) improperly. E. g. bridges require more
> actions (sysfs update, timer disarming, etc.), some other devices 
> want to remove their private areas from lists, etc.
> 
> I. e. arbitrary use-after-free cases may occur.
> 
> The proposed fix is the following: since the only reason for the
> dev_change_net_namespace to fail is the name generation, we may
> give it a unique fall-back name w/o %d-s in it - the dev<ifindex>
> one, since ifindexes are still unique.
> 
> So make this change, raise the failure-case printk loglevel to 
> EMERG and replace the unregister_netdevice call with BUG().
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---

Good catch :)

> diff --git a/net/core/dev.c b/net/core/dev.c
> index d334446..86da6aa 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4480,17 +4480,19 @@ static void __net_exit default_device_exit(struct net *net)
>  	rtnl_lock();
>  	for_each_netdev_safe(net, dev, next) {
>  		int err;
> +		char fb_name[IFNAMSIZ];
> 
>  		/* Ignore unmoveable devices (i.e. loopback) */
>  		if (dev->features & NETIF_F_NETNS_LOCAL)
>  			continue;
> 
>  		/* Push remaing network devices to init_net */
> -		err = dev_change_net_namespace(dev, &init_net, "dev%d");
> +		sprintf(fb_name, "dev%d", dev->ifindex);

The computed interface name can not exceed IFNAMSIZ, 3 ('dev') + 10 (max 
int) + 1 ('\0'). In this case there is no risk to corrupt the stack but 
may be it is more secure to change that to snprintf(fb_name, IFNAMSIZ, 
"dev%d", dev->ifindex), just in case, no ?

> +		err = dev_change_net_namespace(dev, &init_net, fb_name);
>  		if (err) {
> -			printk(KERN_WARNING "%s: failed to move %s to init_net: %d\n",
> +			printk(KERN_EMERG "%s: failed to move %s to init_net: %d\n",
>  				__func__, dev->name, err);
> -			unregister_netdevice(dev);
> +			BUG();
>  		}
>  	}
>  	rtnl_unlock();
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


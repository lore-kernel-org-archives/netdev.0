From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Re: Nested VLAN causes recursive locking error
Date: Mon, 31 Dec 2007 16:04:17 +0100
Message-ID: <477904F1.6090403@trash.net>
References: <20071220135253.GA10932@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert@redhat.com>, Netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42453 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbXLaPEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 10:04:38 -0500
In-Reply-To: <20071220135253.GA10932@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> diff -Nurp linux-2.6.24-rc5-/net/8021q/vlan.c linux-2.6.24-rc5+/net/8021q/vlan.c
> --- linux-2.6.24-rc5-/net/8021q/vlan.c	2007-12-17 13:29:19.000000000 +0100
> +++ linux-2.6.24-rc5+/net/8021q/vlan.c	2007-12-20 14:21:02.000000000 +0100
> @@ -307,12 +307,15 @@ int unregister_vlan_device(struct net_de
>  	return ret;
>  }
>  
> +#ifdef CONFIG_LOCKDEP
>  /*
>   * vlan network devices have devices nesting below it, and are a special
>   * "super class" of normal network devices; split their locks off into a
>   * separate class since they always nest.
>   */
>  static struct lock_class_key vlan_netdev_xmit_lock_key;
> +static int subclass; /* vlan nesting vlan */
> +#endif
>  
>  static const struct header_ops vlan_header_ops = {
>  	.create	 = vlan_dev_hard_header,
> @@ -349,7 +352,14 @@ static int vlan_dev_init(struct net_devi
>  		dev->hard_start_xmit = vlan_dev_hard_start_xmit;
>  	}
>  
> -	lockdep_set_class(&dev->_xmit_lock, &vlan_netdev_xmit_lock_key);
> +#ifdef CONFIG_LOCKDEP
> +	if ((real_dev->priv_flags & IFF_802_1Q_VLAN) &&
> +	    subclass < MAX_LOCKDEP_SUBCLASSES - 1)
> +		subclass++;
> +

That will increment the subclass globally, but it should actually just
use real_dev->subclass + 1. Otherwise we'll permenently fail after
registering 8 nested devices and unregistering them again.



From: Andrew Morton <akpm@osdl.org>
Subject: Re: Multicast filtering for tun.c [PATCH]
Date: Wed, 1 Dec 2004 23:34:00 -0800
Message-ID: <20041201233400.45078efe.akpm@osdl.org>
References: <7f45d9390411251715138b35d0@mail.gmail.com>
	<20041127011006.03232bb6.akpm@osdl.org>
	<7f45d939041201140329d0273f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shaun Jackman <sjackman@gmail.com>
In-Reply-To: <7f45d939041201140329d0273f@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Shaun Jackman <sjackman@gmail.com> wrote:
>
> This patch adds multicast filtering to the TUN network driver, for
> packets being sent from the network device to the character device. It
> applies against the 2.6.8.1 kernel tree.
> 
> ...

Minor points:


> diff -ur linux-2.6.8.1.orig/drivers/net/tun.c linux-2.6.8.1/drivers/net/tun.c
> --- linux-2.6.8.1.orig/drivers/net/tun.c	2004-08-14 03:55:23.000000000 -0700
> +++ linux-2.6.8.1/drivers/net/tun.c	2004-11-25 17:00:22.000000000 -0800
> @@ -41,6 +41,7 @@
>  #include <linux/if_arp.h>
>  #include <linux/if_ether.h>
>  #include <linux/if_tun.h>
> +#include <linux/crc32.h>

You're sure this shouldn't be using crc-ccitt?

> +del_multi(u32* filter, const u8* addr)

	del_multi(u32 *filter, const u8 *addr)

would be a more typical layout.

>  static struct net_device_stats *tun_net_stats(struct net_device *dev)
> @@ -301,6 +333,10 @@
>  
>  	add_wait_queue(&tun->read_wait, &wait);
>  	while (len) {
> +		const u8 ones[ ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };

The space after the `[' is gratuitous.

This array will be allocated onthe stack and populated by hand each time
this function is called.   It should be made static.

> +		u8 addr[ ETH_ALEN];

extraneous space.

> +		memcpy(addr, skb->data, min(sizeof addr, skb->len));

We normally put parentheses around the argument of the sizeof operator, for
no particular reason ;)

> +		if (copy_from_user(&ifr, argp, sizeof ifr))

Ditto

> +	case SIOCGIFFLAGS:
> +		ifr.ifr_flags = tun->if_flags;
> +		if (copy_to_user( argp, &ifr, sizeof ifr))

extraneous space.

> +		if (copy_to_user( argp, &ifr, sizeof ifr))

ditto

> +		DBG(KERN_DEBUG "%s: add multi: %x:%x:%x:%x:%x:%x\n",
> +				tun->dev->name,
> +				(u8)ifr.ifr_hwaddr.sa_data[0], (u8)ifr.ifr_hwaddr.sa_data[1],
> +				(u8)ifr.ifr_hwaddr.sa_data[2], (u8)ifr.ifr_hwaddr.sa_data[3],
> +				(u8)ifr.ifr_hwaddr.sa_data[4], (u8)ifr.ifr_hwaddr.sa_data[5]);

Why all the typecasts?

> +	case SIOCDELMULTI:
> +		/** Remove the specified group from the character device's multicast
> +		 * filter list. */
> +		del_multi(tun->chr_filter, ifr.ifr_hwaddr.sa_data);
> +		DBG(KERN_DEBUG "%s: del multi: %x:%x:%x:%x:%x:%x\n",
> +				tun->dev->name,
> +				(u8)ifr.ifr_hwaddr.sa_data[0], (u8)ifr.ifr_hwaddr.sa_data[1],
> +				(u8)ifr.ifr_hwaddr.sa_data[2], (u8)ifr.ifr_hwaddr.sa_data[3],
> +				(u8)ifr.ifr_hwaddr.sa_data[4], (u8)ifr.ifr_hwaddr.sa_data[5]);

ditto.

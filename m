From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [2.6.23 PATCH 13/18] dm: netlink
Date: Wed, 11 Jul 2007 14:27:12 -0700
Message-ID: <20070711142712.e646995b.akpm@linux-foundation.org>
References: <20070711210137.GE24114@agk.fab.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dm-devel@redhat.com, linux-kernel@vger.kernel.org,
	Mike Anderson <andmike@us.ibm.com>, netdev@vger.kernel.org
To: Alasdair G Kergon <agk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44148 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758594AbXGKV1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 17:27:36 -0400
In-Reply-To: <20070711210137.GE24114@agk.fab.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Jul 2007 22:01:37 +0100
Alasdair G Kergon <agk@redhat.com> wrote:

> From: Mike Anderson <andmike@us.ibm.com>
> 
> This patch adds a dm-netlink skeleton support to the Makefile, and the dm
> directory.
> 
> ...
>  
> +config DM_NETLINK
> +	bool "DM netlink events (EXPERIMENTAL)"
> +	depends on BLK_DEV_DM && EXPERIMENTAL
> +	---help---
> +	Generate netlink events for DM events.

Need a dependency on NET there?

> ...
>
> +#ifdef CONFIG_DM_NETLINK
> +
> +int dm_netlink_init(void);
> +void dm_netlink_exit(void);
> +
> +#else	/* CONFIG_DM_NETLINK */
> +
> +static inline int __init dm_netlink_init(void)

The __init here isn't needed (doesn't make sense, is missing the required
#include anyway)

> +{
> +	return 0;
> +}
> +static inline void dm_netlink_exit(void)
> +{
> +}
> +
> +#endif	/* CONFIG_DM_NETLINK */
> +
> +#endif	/* DM_NETLINK_H */
> Index: linux/drivers/md/dm.c
> ===================================================================
> --- linux.orig/drivers/md/dm.c	2007-07-11 21:37:47.000000000 +0100
> +++ linux/drivers/md/dm.c	2007-07-11 21:37:50.000000000 +0100
> @@ -7,6 +7,7 @@
>  
>  #include "dm.h"
>  #include "dm-bio-list.h"
> +#include "dm-netlink.h"
>  
>  #include <linux/init.h>
>  #include <linux/module.h>
> @@ -176,6 +177,7 @@ int (*_inits[])(void) __initdata = {
>  	dm_linear_init,
>  	dm_stripe_init,
>  	dm_interface_init,
> +	dm_netlink_init,
>  };
>  
>  void (*_exits[])(void) = {
> @@ -184,6 +186,7 @@ void (*_exits[])(void) = {
>  	dm_linear_exit,
>  	dm_stripe_exit,
>  	dm_interface_exit,
> +	dm_netlink_exit,
>  };

hm, so if CONFIG_DM_NETLINK=n we end up taking the address of an inlined
function.  So the __init above _did_ make sense, in a peculiar way.  I
don't know that gcc will actually put that converted-to-non-inline function
into the desired section though.

There's no way in which those inlined functions will ever get inlined.
Perhaps all this would be better if there was no implementation of
dm_netlink_init() and dm_netlink_exit() if CONFIG_DM_NETLINK=n and you just
whack the requisite ifdefs into these tables here?

>  static int __init dm_init(void)
> Index: linux/include/linux/netlink.h
> ===================================================================
> --- linux.orig/include/linux/netlink.h	2007-07-11 21:37:31.000000000 +0100
> +++ linux/include/linux/netlink.h	2007-07-11 21:37:50.000000000 +0100
> @@ -21,7 +21,7 @@
>  #define NETLINK_DNRTMSG		14	/* DECnet routing messages */
>  #define NETLINK_KOBJECT_UEVENT	15	/* Kernel messages to userspace */
>  #define NETLINK_GENERIC		16
> -/* leave room for NETLINK_DM (DM Events) */
> +#define NETLINK_DM		17	/* Device Mapper */
>  #define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
>  #define NETLINK_ECRYPTFS	19

Have the net guys checked this?  


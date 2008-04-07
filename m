From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-2.6.26 1/2] Shrink size of net_device by filling alignment
 holes in it.
Date: Mon, 07 Apr 2008 19:04:38 +0200
Message-ID: <47FA5426.10704@cosmosbay.com>
References: <47FA4ADE.1020308@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([80.12.242.26]:34865 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752268AbYDGREs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 13:04:48 -0400
In-Reply-To: <47FA4ADE.1020308@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov a =E9crit :
> I've found a much easier way to shrink the net_device structure=20
> rather that moving all the operations out of it. However, since
> the net_device may grow further, moving the operations into a
> separate place may look reasonable.
>
> The pahole tool showed, that there are a 124 and 80 bytes holes
> before the queue_lock and the _xmit_lock respectively. Moving most
> of the devices callbacks into the 2nd hole makes the sizeof of the
> structure be 1024 bytes.
>
>  =20
On 32 bits platform and CONFIG_X86_L1_CACHE_SHIFT=3D7
I presume :)

Could you check if x86_64 machines with  X86_L1_CACHE_SHIFT =3D 7 or 8=20
dont suffer from this patch ?

At first glance I would say it seems OK, but this net_device is really=20
touchy for SMP performance :)

> The hard_start_xmit callback is not moved to keep it in previous
> cacheline.
>
> I think it's OK to make such a reordering, since all these hooks
> are a) read-only and b) not called on fast paths, so their place=20
> within the structure looks not very important.
>
> Unfortunately diff makes the patch look like moving other fields,
> rater than the ops :)
>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>
> ---
>  include/linux/netdevice.h |   47 +++++++++++++++++++++++------------=
----------
>  1 files changed, 24 insertions(+), 23 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 8b17ed4..3397919 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -483,9 +483,6 @@ struct net_device
>  	struct list_head	napi_list;
>  #endif
>  =09
> -	/* The device initialization function. Called only once. */
> -	int			(*init)(struct net_device *dev);
> -
>  	/* ------- Fields preinitialized in Space.c finish here ------- */
> =20
>  	/* Net device features */
> @@ -641,27 +638,9 @@ struct net_device
>  	int			watchdog_timeo; /* used by dev_watchdog() */
>  	struct timer_list	watchdog_timer;
> =20
> -/*
> - * refcnt is a very hot point, so align it on SMP
> - */
> -	/* Number of references to this device */
> -	atomic_t		refcnt ____cacheline_aligned_in_smp;
> -
> -	/* delayed register/unregister */
> -	struct list_head	todo_list;
> -	/* device index hash chain */
> -	struct hlist_node	index_hlist;
> -
> -	struct net_device	*link_watch_next;
> -
> -	/* register/unregister state machine */
> -	enum { NETREG_UNINITIALIZED=3D0,
> -	       NETREG_REGISTERED,	/* completed register_netdevice */
> -	       NETREG_UNREGISTERING,	/* called unregister_netdevice */
> -	       NETREG_UNREGISTERED,	/* completed unregister todo */
> -	       NETREG_RELEASED,		/* called free_netdev */
> -	} reg_state;
> =20
> +	/* The device initialization function. Called only once. */
> +	int			(*init)(struct net_device *dev);
>  	/* Called after device is detached from network. */
>  	void			(*uninit)(struct net_device *dev);
>  	/* Called after last user reference disappears. */
> @@ -703,6 +682,28 @@ struct net_device
>  						    unsigned short vid);
> =20
>  	int			(*neigh_setup)(struct net_device *dev, struct neigh_parms *);
> +
> +/*
> + * refcnt is a very hot point, so align it on SMP
> + */
> +	/* Number of references to this device */
> +	atomic_t		refcnt ____cacheline_aligned_in_smp;
> +
> +	/* delayed register/unregister */
> +	struct list_head	todo_list;
> +	/* device index hash chain */
> +	struct hlist_node	index_hlist;
> +
> +	struct net_device	*link_watch_next;
> +
> +	/* register/unregister state machine */
> +	enum { NETREG_UNINITIALIZED=3D0,
> +	       NETREG_REGISTERED,	/* completed register_netdevice */
> +	       NETREG_UNREGISTERING,	/* called unregister_netdevice */
> +	       NETREG_UNREGISTERED,	/* completed unregister todo */
> +	       NETREG_RELEASED,		/* called free_netdev */
> +	} reg_state;
> +
>  #ifdef CONFIG_NETPOLL
>  	struct netpoll_info	*npinfo;
>  #endif
>  =20





From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb
 V3
Date: Fri, 28 May 2010 09:02:43 +0200
Message-ID: <1275030163.2650.3.camel@edumazet-laptop>
References: <20100527180813.GA3714@psychotron.redhat.com>
	 <20100527130822.02cb1661@nehalam>
	 <20100528055154.GB2823@psychotron.redhat.com>
	 <20100528061241.GC2823@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	kaber@trash.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38355 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455Ab0E1HCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 03:02:47 -0400
Received: by wyb29 with SMTP id 29so605269wyb.19
        for <netdev@vger.kernel.org>; Fri, 28 May 2010 00:02:46 -0700 (PDT)
In-Reply-To: <20100528061241.GC2823@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 28 mai 2010 =C3=A0 08:12 +0200, Jiri Pirko a =C3=A9crit :

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a1bff65..f54b97d 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -254,6 +254,16 @@ struct netdev_hw_addr_list {
>  #define netdev_for_each_mc_addr(ha, dev) \
>  	netdev_hw_addr_list_for_each(ha, &(dev)->mc)
> =20
> +
> +struct netdev_rx_handler {
> +	struct list_head	list;
> +	unsigned int		order;
> +#define NETDEV_RX_HANDLER_ORDER_BRIDGE	1
> +#define NETDEV_RX_HANDLER_ORDER_MACVLAN	2
> +	struct sk_buff		*(*callback)(struct sk_buff *skb);
> +	struct rcu_head		rcu;
> +};
> +
>  struct hh_cache {
>  	struct hh_cache *hh_next;	/* Next entry			     */
>  	atomic_t	hh_refcnt;	/* number of users                   */
> @@ -1031,6 +1041,9 @@ struct net_device {
>  	/* GARP */
>  	struct garp_port	*garp_port;
> =20
> +	/* receive handlers (hooks) list */
> +	struct list_head	rx_handlers;
> +
>  	/* class/net/name entry */
>  	struct device		dev;
>  	/* space for optional device, statistics, and wireless sysfs groups=
 */
> @@ -1685,6 +1698,11 @@ static inline void napi_free_frags(struct napi=
_struct *napi)
>  	napi->skb =3D NULL;
>  }
> =20

Please chose another place to hold rx_handlers, to keep rx path memory
needs to minimum cache lines. Somewhere in the following section :

/*
 * Cache line mostly used on receive path (including eth_type_trans())
 */
        unsigned long           last_rx;        /* Time of last Rx     =
 */
        /* Interface address info used in eth_type_trans() */
        unsigned char           *dev_addr;      /* hw address, (before =
bcast
                                                   because most packets=
 are
                                                   unicast) */

        struct netdev_hw_addr_list      dev_addrs; /* list of device
                                                      hw addresses */

        unsigned char           broadcast[MAX_ADDR_LEN];        /* hw b=
cast add */

#ifdef CONFIG_RPS
        struct kset             *queues_kset;

        struct netdev_rx_queue  *_rx;

        /* Number of RX queues allocated at alloc_netdev_mq() time  */
        unsigned int            num_rx_queues;
#endif

        struct netdev_queue     rx_queue;


and before the :

	struct netdev_queue     *_tx ____cacheline_aligned_in_smp;




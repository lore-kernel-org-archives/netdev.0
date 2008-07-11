From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/13]: netdev: Allocate multiple queues for TX.
Date: Fri, 11 Jul 2008 23:19:39 +0200
Message-ID: <4877CE6B.2050805@cosmosbay.com>
References: <20080710.035610.167480342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.113]:35244 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754433AbYGKVX3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 17:23:29 -0400
In-Reply-To: <20080710.035610.167480342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> alloc_netdev_mq() now allocates an array of netdev_queue
> structures for TX, based upon the queue_count argument.
>=20
> Furthermore, all accesses to the TX queues are now vectored
> through the netdev_get_tx_queue() and netdev_for_each_tx_queue()
> interfaces.  This makes it easy to grep the tree for all
> things that want to get to a TX queue of a net device.
>=20
> Problem spots which are not really multiqueue aware yet, and
> only work with one queue, can easily be spotted by grepping
> for all netdev_get_tx_queue() calls that pass in a zero index.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

>  	}
> =20
> +	tx =3D kzalloc(sizeof(struct netdev_queue) * queue_count, GFP_KERNE=
L);
> +	if (!tx) {
> +		printk(KERN_ERR "alloc_netdev: Unable to allocate "
> +		       "tx qdiscs.\n");
> +		kfree(p);
> +		return NULL;
> +	}
> +


On i386 for example, sizeof(struct netdev_queue) =3D 0x2c

Shouldnt we make sure each queue sits on its own cache line on CONFIG_S=
MP ?

Also, dev->_tx and dev->num_tx_queues might share a cache line with dev=
->rx_queue, was it intended ?

> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -640,7 +640,9 @@ struct net_device
>  	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
> =20
>  	struct netdev_queue	rx_queue;
> -	struct netdev_queue	tx_queue ____cacheline_aligned_in_smp;
> +
> +	struct netdev_queue	*_tx;
> +	unsigned int		num_tx_queues;
>  	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
=20




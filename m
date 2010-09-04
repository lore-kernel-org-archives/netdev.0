From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch 03/21] ibmveth: Remove LLTX
Date: Sat, 04 Sep 2010 08:41:36 +0200
Message-ID: <1283582496.2320.4.camel@edumazet-laptop>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
	 <20100904042815.2655.71537.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com, anton@samba.org
To: Santiago Leon <santil@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37759 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab0IDGlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 02:41:40 -0400
Received: by wyf22 with SMTP id 22so776038wyf.19
        for <netdev@vger.kernel.org>; Fri, 03 Sep 2010 23:41:39 -0700 (PDT)
In-Reply-To: <20100904042815.2655.71537.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 septembre 2010 =C3=A0 23:28 -0500, Santiago Leon a =C3=A9=
crit :
> The ibmveth adapter needs locking in the transmit routine to protect
> the bounce_buffer but it sets LLTX and forgets to add any of its own
> locking.
>=20
> Just remove the deprecated LLTX option. Remove the stats lock in the =
process.
>=20
> Signed-off-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
> ---
>=20
> Index: net-next-2.6/drivers/net/ibmveth.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:18:39.0000=
00000 -0500
> +++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:18:40.000000000 =
-0500
> @@ -903,7 +903,6 @@ static netdev_tx_t ibmveth_start_xmit(st
>  	union ibmveth_buf_desc desc;
>  	unsigned long lpar_rc;
>  	unsigned long correlator;
> -	unsigned long flags;
>  	unsigned int retry_count;
>  	unsigned int tx_dropped =3D 0;
>  	unsigned int tx_bytes =3D 0;

Why dont you remove these local variables then ?=20
tx_dropped, tx_bytes, tx_packets ?

> @@ -965,20 +964,18 @@ static netdev_tx_t ibmveth_start_xmit(st
>  	} else {
>  		tx_packets++;
>  		tx_bytes +=3D skb->len;
> -		netdev->trans_start =3D jiffies; /* NETIF_F_LLTX driver :( */
>  	}
> =20
>  	if (!used_bounce)
>  		dma_unmap_single(&adapter->vdev->dev, data_dma_addr,
>  				 skb->len, DMA_TO_DEVICE);
> =20
> -out:	spin_lock_irqsave(&adapter->stats_lock, flags);
> +out:
>  	netdev->stats.tx_dropped +=3D tx_dropped;
>  	netdev->stats.tx_bytes +=3D tx_bytes;
>  	netdev->stats.tx_packets +=3D tx_packets;
>  	adapter->tx_send_failed +=3D tx_send_failed;
>  	adapter->tx_map_failed +=3D tx_map_failed;
> -	spin_unlock_irqrestore(&adapter->stats_lock, flags);
> =20
>  	dev_kfree_skb(skb);
>  	return NETDEV_TX_OK;
> @@ -1290,8 +1287,6 @@ static int __devinit ibmveth_probe(struc
>  	netdev->netdev_ops =3D &ibmveth_netdev_ops;
>  	netdev->ethtool_ops =3D &netdev_ethtool_ops;
>  	SET_NETDEV_DEV(netdev, &dev->dev);
> - 	netdev->features |=3D NETIF_F_LLTX;
> -	spin_lock_init(&adapter->stats_lock);
> =20
>  	memcpy(netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
> =20
> Index: net-next-2.6/drivers/net/ibmveth.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next-2.6.orig//drivers/net/ibmveth.h	2010-09-03 22:18:39.0000=
00000 -0500
> +++ net-next-2.6/drivers/net/ibmveth.h	2010-09-03 22:18:40.000000000 =
-0500
> @@ -158,7 +158,6 @@ struct ibmveth_adapter {
>      u64 rx_no_buffer;
>      u64 tx_map_failed;
>      u64 tx_send_failed;
> -    spinlock_t stats_lock;
>  };
> =20
>  struct ibmveth_buf_desc_fields {
> --



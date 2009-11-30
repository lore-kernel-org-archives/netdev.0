From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2: avoid flushing statistics when doing a MTU change
Date: Mon, 30 Nov 2009 11:30:42 +0100
Message-ID: <4B139ED2.2060500@gmail.com>
References: <1259341163-12775-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38110 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbZK3Kaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 05:30:52 -0500
In-Reply-To: <1259341163-12775-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

leitao@linux.vnet.ibm.com a =E9crit :
> Actually when bnx2 changes the interface's MTU size, it resets
> the chip and consequently flushes the interface statistics.
> This patch saves the statistics in a temporary space in order to
> maintain the statistics correct after the chip reset.
>=20
> Signed-off-by: Breno Leitao<leitao@linux.vnet.ibm.com>


 =20
>  	return net_stats;
>  }
> @@ -6989,6 +7004,11 @@ bnx2_change_ring_size(struct bnx2 *bp, u32 rx,=
 u32 tx)
>  {
>  	if (netif_running(bp->dev)) {
>  		bnx2_netif_stop(bp);

I wonder if you need to renew this stats before copying them ?
 (eg calling bnx2_get_stats())


> +
> +		/* Save statistics that is going to be reseted */
> +		memcpy(bp->stats_extra, &bp->dev->stats,
> +			sizeof(struct net_device_stats));
> +
>  		bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
>  		bnx2_free_skbs(bp);
>  		bnx2_free_mem(bp);
> @@ -7649,6 +7669,7 @@ bnx2_init_board(struct pci_dev *pdev, struct ne=
t_device *dev)
> =20
>  	bp->flags =3D 0;
>  	bp->phy_flags =3D 0;
> +	bp->stats_extra =3D kzalloc(sizeof(struct net_device_stats), GFP_KE=
RNEL);

There is no test of failed allocation.

> =20
>  	/* enable device (incl. PCI PM wakeup), and bus-mastering */
>  	rc =3D pci_enable_device(pdev);
> @@ -8162,6 +8183,7 @@ bnx2_remove_one(struct pci_dev *pdev)
>  	if (bp->regview)
>  		iounmap(bp->regview);
> =20
> +	kfree(bp->stats_extra);
>  	free_netdev(dev);
>  	pci_release_regions(pdev);
>  	pci_disable_device(pdev);

Structure is small anyway, why not including it in struct bnx2 ?

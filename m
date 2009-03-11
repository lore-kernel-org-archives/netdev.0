From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 05:00:58 +0100
Message-ID: <49B7377A.2070006@cosmosbay.com>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, wd@denx.de, dzu@denx.de
To: Ilya Yanok <yanok@emcraft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37688 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbZCKEB1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 00:01:27 -0400
In-Reply-To: <1236738549-16703-1-git-send-email-yanok@emcraft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilya Yanok a =E9crit :
> Driver for Dave DNET ethernet controller found on Dave/DENX QongEVB-L=
ITE
> FPGA. Heavily based on Dave sources, I've just adopted it to current
> kernel version and done some code cleanup.
>=20
> Signed-off-by: Ilya Yanok <yanok@emcraft.com>

> +		skb =3D dev_alloc_skb(pkt_len + 5);
> +		if (skb !=3D NULL) {


> +			skb->dev =3D dev;

minor nit : This is not necessary anymore
=20
	eth_type_trans(skb, dev) does the skb->dev =3D dev; initialization
in recent kernels.

commit 4c13eb6657fe9ef7b4dc8f1a405c902e9e5234e0
Author: Arnaldo Carvalho de Melo <acme@redhat.com>
Date:   Wed Apr 25 17:40:23 2007 -0700

    [ETH]: Make eth_type_trans set skb->dev like the other *_type_trans

    One less thing for drivers writers to worry about.

    Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


> +			/* Align IP on 16 byte boundaries */
> +			skb_reserve(skb, 2);
> +			/*
> +			 * 'skb_put()' points to the start of sk_buff
> +			 * data area.
> +			 */
> +			data_ptr =3D (unsigned int *)skb_put(skb, pkt_len);
> +			for (i =3D 0; i < (pkt_len + 3) >> 2; i++)
> +				*data_ptr++ =3D dnet_readl(bp, RX_DATA_FIFO);
> +			skb->protocol =3D eth_type_trans(skb, dev);
> +			netif_receive_skb(skb);
> +			bp->dev->last_rx =3D jiffies;


This last_rx init is not anymore needed :

commit babcda74e9d96bb58fd9c6c5112dbdbff169e695
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Nov 3 21:11:17 2008 -0800

    drivers/net: Kill now superfluous ->last_rx stores.

    The generic packet receive code takes care of setting
    netdev->last_rx when necessary, for the sake of the
    bonding ARP monitor.

    Drivers need not do it any more.

    Some cases had to be skipped over because the drivers
    were making use of the ->last_rx value themselves.

    Signed-off-by: David S. Miller <davem@davemloft.net>



> +			npackets++;
> +		} else
> +			printk(KERN_NOTICE
> +			       "%s: No memory to allocate a sk_buff of "
> +			       "size %d.\n", dev->name, pkt_len);

pkt_len is an "unsigned int", so please use %u

> +	}
> +




+static struct ethtool_ops dnet_ethtool_ops =3D {
+	.get_settings		=3D dnet_get_settings,
+	.set_settings		=3D dnet_set_settings,
+	.get_drvinfo		=3D dnet_get_drvinfo,
+	.get_link		=3D ethtool_op_get_link,
+};
+

Please add a const qualifier to this.



struct dnet {
+	void __iomem			*regs;
+	spinlock_t			lock;
+	struct platform_device	*pdev;
+	struct net_device		*dev;
+	struct net_device_stats	stats;
+	struct dnet_stats		hw_stats;
+	unsigned int			capabilities; /* read from FPGA */
+	struct napi_struct		napi;


Are you sure you need a "struct net_device_stats stats;" in "struct dne=
t" ?
One is already included in "struct net_device", you probably can use it=
=2E

Thank you


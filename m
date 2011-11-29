From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sky2: add bql support
Date: Tue, 29 Nov 2011 07:38:56 +0100
Message-ID: <1322548736.2970.61.camel@edumazet-laptop>
References: <20111128201907.6d31d4c3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54620 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023Ab1K2GjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 01:39:01 -0500
Received: by eaak14 with SMTP id k14so2651723eaa.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 22:39:00 -0800 (PST)
In-Reply-To: <20111128201907.6d31d4c3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 novembre 2011 =C3=A0 20:19 -0800, Stephen Hemminger a =C3=A9=
crit :
> Just for testing, here is how to add BQL support to sky2
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


> @@ -2022,6 +2024,8 @@ static void sky2_tx_complete(struct sky2
>  			sky2->tx_stats.bytes +=3D skb->len;
>  			u64_stats_update_end(&sky2->tx_stats.syncp);
> =20
> +			netdev_completed_queue(dev, 1, skb->len);
> +
>  			re->skb =3D NULL;
>  			dev_kfree_skb_any(skb);
> =20

I believe you should batch these calls as much as possible.

This would also reduce the burden on
u64_stats_update_begin/u64_stats_update_end

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet=
/marvell/sky2.c
index 29adc78..1277c95 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2003,6 +2003,7 @@ static void sky2_tx_complete(struct sky2_port *sk=
y2, u16 done)
 {
 	struct net_device *dev =3D sky2->netdev;
 	unsigned idx;
+	unsigned long pkts =3D 0, bytes =3D 0;
=20
 	BUG_ON(done >=3D sky2->tx_ring_size);
=20
@@ -2017,10 +2018,8 @@ static void sky2_tx_complete(struct sky2_port *s=
ky2, u16 done)
 			netif_printk(sky2, tx_done, KERN_DEBUG, dev,
 				     "tx done %u\n", idx);
=20
-			u64_stats_update_begin(&sky2->tx_stats.syncp);
-			++sky2->tx_stats.packets;
-			sky2->tx_stats.bytes +=3D skb->len;
-			u64_stats_update_end(&sky2->tx_stats.syncp);
+			pkts++;
+			bytes +=3D skb->len;
=20
 			re->skb =3D NULL;
 			dev_kfree_skb_any(skb);
@@ -2031,6 +2030,11 @@ static void sky2_tx_complete(struct sky2_port *s=
ky2, u16 done)
=20
 	sky2->tx_cons =3D idx;
 	smp_mb();
+	u64_stats_update_begin(&sky2->tx_stats.syncp);
+	sky2->tx_stats.packets +=3D pkts;
+	sky2->tx_stats.bytes +=3D bytes;
+	u64_stats_update_end(&sky2->tx_stats.syncp);
+	netdev_completed_queue(dev, pkts, bytes);
 }
=20
 static void sky2_tx_reset(struct sky2_hw *hw, unsigned port)

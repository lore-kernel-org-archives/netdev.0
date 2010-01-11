From: "Wu Jiajun-B06378" <B06378@freescale.com>
Subject: RE: [PATCH 1/3] ucc_geth: Fix empty TX queue processing
Date: Mon, 11 Jan 2010 19:52:26 +0800
Message-ID: <100CB1A1877FF245BDB7AF83A0E73FFE26BEC3@zch01exm28.fsl.freescale.net>
References: <0A1FE637C2C7E148B9573BB60CC630E56C3E90@zch01exm26.fsl.freescale.net> <100CB1A1877FF245BDB7AF83A0E73FFE26BE4D@zch01exm28.fsl.freescale.net> <20100111105248.GA28580@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linuxppc-dev@ozlabs.org>, <netdev@vger.kernel.org>,
	<lsorense@csclub.uwaterloo.ca>, <davem@davemloft.net>
To: <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:54033 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784Ab0AKLw3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 06:52:29 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id o0BBqTpn001044
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2010 04:52:29 -0700 (MST)
Received: from zch01exm28.fsl.freescale.net (zch01exm28.ap.freescale.net [10.192.129.225])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id o0BBvblX018009
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2010 05:57:38 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20100111105248.GA28580@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Yes,'if (!skb)' is enough.
You can reproduce transmitting stopping if you use 'if ((bd =3D=3D uget=
h->txBd[txQ])' and run ipforwarding with MTU=3D64 1Gbps 100%linerate.


-----Original Message-----
=46rom: Anton Vorontsov [mailto:avorontsov@ru.mvista.com]=20
Sent: 2010=C4=EA1=D4=C211=C8=D5 18:53
To: Wu Jiajun-B06378
Cc: linuxppc-dev@ozlabs.org; netdev@vger.kernel.org; lsorense@csclub.uw=
aterloo.ca; davem@davemloft.net
Subject: Re: [PATCH 1/3] ucc_geth: Fix empty TX queue processing

On Mon, Jan 11, 2010 at 11:47:37AM +0800, Wu Jiajun-B06378 wrote:
> =20
> 'bd =3D=3D ugeth->txBd[txQ]' has two possible statuses: 1)full queue.
> 2)empty queue.
> Removing 'netif_queue_stopped() =3D=3D 0' will make transmitting stop=
ping=20
> when the queue is full.
>=20
> I made a new patch for this oops.
[...]
> +		if ((bd =3D=3D ugeth->txBd[txQ]) && (skb =3D=3D NULL))
>  			break;

Hm. I wonder why do we need the 'bd =3D=3D ugeth->txBd[txQ]' check at a=
ll? The null skb will cause a kernel oops anyway.

I think the patch below should be sufficient for the fix.
Can you try it? Or if you tell me how to reproduce the issue you observ=
e, I can try it myself.

Thanks a lot!

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c index 41ad=
2f3..a1a6d06 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3279,13 +3279,12 @@ static int ucc_geth_tx(struct net_device *dev, =
u8 txQ)
 		/* Handle the transmitted buffer and release */
 		/* the BD to be used with the current frame  */
=20
-		if (bd =3D=3D ugeth->txBd[txQ]) /* queue empty? */
+		skb =3D ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]];
+		if (!skb)
 			break;
=20
 		dev->stats.tx_packets++;
=20
-		skb =3D ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]];
-
 		if (skb_queue_len(&ugeth->rx_recycle) < RX_BD_RING_LEN &&
 			     skb_recycle_check(skb,
 				    ugeth->ug_info->uf_info.max_rx_buf_length +


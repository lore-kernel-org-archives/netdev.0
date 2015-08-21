From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: fix uncleaned dma flags
Date: Fri, 21 Aug 2015 10:12:21 +0900
Message-ID: <D93181E5-EDC1-4192-B8EA-7209646DA963@gmail.com>
References: <1440040627-59949-1-git-send-email-jaedon.shin@gmail.com> <55D64F09.1090802@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35043 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbbHUBM2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 21:12:28 -0400
Received: by pdob1 with SMTP id b1so20166306pdo.2
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 18:12:27 -0700 (PDT)
In-Reply-To: <55D64F09.1090802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 2015. 8. 21., =BF=C0=C0=FC 7:04, Florian Fainelli <f.fainelli@gmail.c=
om> =C0=DB=BC=BA:
>=20
> On 19/08/15 20:17, Jaedon Shin wrote:
>> Clean the dma flags of multiq ring buffer int the interface stop
>> process. This patch fixes that the genet is not running while the
>> interface is re-enabled.
>>=20
>> $ ifup eth0 - running after booting
>> $ ifdown eth0
>> $ ifup eth0 - not running and occur tx_timeout
>>=20
>> The bcmgenet_dma_disable() in bcmgenet_open() do clean ring16 dma fl=
ag
>> only. If the genet has multiq, the dma register is not cleaned. and
>> bcmgenet_init_dma() is not done correctly. in case
>> GENET_V2(tx_queues=3D4), tdma_ctrl has 0x1e after running
>> bcmgenet_dma_disable().
>=20
> It sounds like this should be moved to bcmgenet_dma_disable() where w=
e
> are already modifying DMA_CTRL and returning a dma_ctrl value back to
> the caller, or at the very last bcmgenet_dma_teardown().
>=20
> Thanks!
>=20

I will send the changes immediately.

Thanks.

>>=20
>> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
>> ---
>> drivers/net/ethernet/broadcom/genet/bcmgenet.c | 16 ++++++++++++++++
>> 1 file changed, 16 insertions(+)
>>=20
>> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/driver=
s/net/ethernet/broadcom/genet/bcmgenet.c
>> index 64c1e9db6b0b..81bde6fa70b7 100644
>> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> @@ -2174,6 +2174,8 @@ static int bcmgenet_dma_teardown(struct bcmgen=
et_priv *priv)
>>=20
>> static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
>> {
>> +	u32 dma_ctrl;
>> +	u32 reg;
>> 	int i;
>>=20
>> 	bcmgenet_fini_rx_napi(priv);
>> @@ -2182,6 +2184,20 @@ static void bcmgenet_fini_dma(struct bcmgenet=
_priv *priv)
>> 	/* disable DMA */
>> 	bcmgenet_dma_teardown(priv);
>>=20
>> +	dma_ctrl =3D 0;
>> +	for (i =3D 0; i < priv->hw_params->rx_queues; i++)
>> +		dma_ctrl |=3D (1 << (i + DMA_RING_BUF_EN_SHIFT));
>> +	reg =3D bcmgenet_rdma_readl(priv, DMA_CTRL);
>> +	reg &=3D ~dma_ctrl;
>> +	bcmgenet_rdma_writel(priv, reg, DMA_CTRL);
>> +
>> +	dma_ctrl =3D 0;
>> +	for (i =3D 0; i < priv->hw_params->tx_queues; i++)
>> +		dma_ctrl |=3D (1 << (i + DMA_RING_BUF_EN_SHIFT));
>> +	reg =3D bcmgenet_tdma_readl(priv, DMA_CTRL);
>> +	reg &=3D ~dma_ctrl;
>> +	bcmgenet_tdma_writel(priv, reg, DMA_CTRL);
>> +
>> 	for (i =3D 0; i < priv->num_tx_bds; i++) {
>> 		if (priv->tx_cbs[i].skb !=3D NULL) {
>> 			dev_kfree_skb(priv->tx_cbs[i].skb);
>>=20
>=20
>=20
> --=20
> Florian

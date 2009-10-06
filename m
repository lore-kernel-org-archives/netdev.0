From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: add support for STMicroelectronics Ethernet controllers.
Date: Tue, 06 Oct 2009 15:35:49 +0200
Message-ID: <4ACB47B5.5050700@gmail.com>
References: <1254815493-17576-1-git-send-email-peppe.cavallaro@st.com> <4ACB1B95.4090701@gmail.com> <4ACB3A42.9070600@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47463 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932588AbZJFNga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 09:36:30 -0400
In-Reply-To: <4ACB3A42.9070600@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Giuseppe CAVALLARO a =E9crit :

>> Why call dev_kfree_skb_any() here ? From NAPI context it is overkill=
=2E
>=20
> The logic behind this piece of code should be the same one adopted in
> other drivers like gianfar, ucc_geth and mv643xx_eth. What am I missi=
ng?

Dont trust driver code too much, many of them are not upd2date.

gianfar disables irqs, so it calls dev_kfree_skb_any()

if (spin_trylock_irqsave(&priv->txlock, flags)) {
	tx_cleaned =3D gfar_clean_tx_ring(dev);
	spin_unlock_irqrestore(&priv->txlock, flags);
}

but in your case,

stmmac_clean_tx() runs in sofirq mode, you can call dev_kfree_skb()/con=
sume_skb()

Please check drivers/net/tg3.c, function tg3_tx() for a _good_ example.

>=20
>> static int stmmac_poll(struct napi_struct *napi, int budget)
>> +{
> [snip]
>> +
>> +	tx_cleaned =3D stmmac_clean_tx(dev);
>> +
>> +	work_done =3D stmmac_rx(dev, budget);
>> +
>>
>>
>> +	if (tx_cleaned)
>> +		return budget;
>>
>> Why tx_cleaned is used here to exit early ?
>=20
> I've found interesting the approach used in gianfar (see commit
> 42199884594bc336c9185441cbed99a9324dab34).
>=20

This looks buggy and not a clone of e1000 code, despite its Changelog c=
laim.

e1000 code is OK, not gianfar.

static int e1000_clean(struct napi_struct *napi, int budget)
{
	tx_clean_complete =3D e1000_clean_tx_irq(adapter, &adapter->tx_ring[0]=
);

	adapter->clean_rx(adapter, &adapter->rx_ring[0], &work_done, budget);

	if (!tx_clean_complete)
		work_done =3D budget; // we say budget is fully consumed to force ano=
ther poll round

	if (work_done < budget) {
		...
		napi_complete(napi);
		...
	}
}

You can see e1000_clean_tx_irq() doesnt return "number of completed skb=
s", but a=20
boolean saying if more skb are still in tx queue "(count < tx_ring->cou=
nt)"

This is because we want to check again tx queue before napi_complete(th=
is_adapter)


Your code forces a poll() round if at least *one* skb was completed, th=
is is very strange.

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: add support for STMicroelectronics Ethernet controllers.
Date: Tue, 06 Oct 2009 15:42:12 +0200
Message-ID: <4ACB4934.8090407@st.com>
References: <1254815493-17576-1-git-send-email-peppe.cavallaro@st.com> <4ACB1B95.4090701@gmail.com> <4ACB3A42.9070600@st.com> <4ACB47B5.5050700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:35482 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757391AbZJFNm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 09:42:58 -0400
In-Reply-To: <4ACB47B5.5050700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi Eric.

Eric Dumazet wrote:
> Giuseppe CAVALLARO a =E9crit :
>=20
>>> Why call dev_kfree_skb_any() here ? From NAPI context it is overkil=
l.
>> The logic behind this piece of code should be the same one adopted i=
n
>> other drivers like gianfar, ucc_geth and mv643xx_eth. What am I miss=
ing?
>=20
> Dont trust driver code too much, many of them are not upd2date.
>=20
> gianfar disables irqs, so it calls dev_kfree_skb_any()
>=20
> if (spin_trylock_irqsave(&priv->txlock, flags)) {
> 	tx_cleaned =3D gfar_clean_tx_ring(dev);
> 	spin_unlock_irqrestore(&priv->txlock, flags);
> }
>=20
> but in your case,
>=20
> stmmac_clean_tx() runs in sofirq mode, you can call dev_kfree_skb()/c=
onsume_skb()
>=20
> Please check drivers/net/tg3.c, function tg3_tx() for a _good_ exampl=
e.

Thanks, I'll fix it taking as example the tg3 d.d.

>>> static int stmmac_poll(struct napi_struct *napi, int budget)
>>> +{
>> [snip]
>>> +
>>> +	tx_cleaned =3D stmmac_clean_tx(dev);
>>> +
>>> +	work_done =3D stmmac_rx(dev, budget);
>>> +
>>>
>>>
>>> +	if (tx_cleaned)
>>> +		return budget;
>>>
>>> Why tx_cleaned is used here to exit early ?
>> I've found interesting the approach used in gianfar (see commit
>> 42199884594bc336c9185441cbed99a9324dab34).
>>
>=20
> This looks buggy and not a clone of e1000 code, despite its Changelog=
 claim.
>=20
> e1000 code is OK, not gianfar.
>=20
> static int e1000_clean(struct napi_struct *napi, int budget)
> {
> 	tx_clean_complete =3D e1000_clean_tx_irq(adapter, &adapter->tx_ring[=
0]);
>=20
> 	adapter->clean_rx(adapter, &adapter->rx_ring[0], &work_done, budget)=
;
>=20
> 	if (!tx_clean_complete)
> 		work_done =3D budget; // we say budget is fully consumed to force a=
nother poll round
>=20
> 	if (work_done < budget) {
> 		...
> 		napi_complete(napi);
> 		...
> 	}
> }
>=20
> You can see e1000_clean_tx_irq() doesnt return "number of completed s=
kbs", but a=20
> boolean saying if more skb are still in tx queue "(count < tx_ring->c=
ount)"
>=20
> This is because we want to check again tx queue before napi_complete(=
this_adapter)
>=20
>=20
> Your code forces a poll() round if at least *one* skb was completed, =
this is very strange.
>=20

I'll fix this too.

I'm going to post a new patch for the stmmac as soon as I fix all these
points.

Many thanks.
Regards,
Peppe
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkrLSTQACgkQ2Xo3j31MSSIKgQCeL733CI46GAUhDk/safdFH2Wj
q98An09JpuvsNGb0bihuy5dEaAIDUIIV
=3DR6wJ
-----END PGP SIGNATURE-----

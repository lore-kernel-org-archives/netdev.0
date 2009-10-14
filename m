From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: add support for STMicroelectronics Ethernet controllers.
Date: Wed, 14 Oct 2009 06:07:13 +0200
Message-ID: <4AD54E71.7070400@gmail.com>
References: <1254815493-17576-1-git-send-email-peppe.cavallaro@st.com> <4ACB1B95.4090701@gmail.com> <4ACB3A42.9070600@st.com> <4ACB47B5.5050700@gmail.com> <4ACB4934.8090407@st.com> <4AD47425.7050003@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34802 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbZJNEHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 00:07:52 -0400
In-Reply-To: <4AD47425.7050003@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Giuseppe CAVALLARO a =E9crit :
> Hi Eric,
>=20
> Giuseppe CAVALLARO wrote:
>> I'm going to post a new patch for the stmmac as soon as I fix all th=
ese
>> points.
>=20
> Hoping to have well followed all your advice, I'm attaching the
> patch again.
>=20
> As you will see, I've reviewed the tx clean process by removing the
> wrong check that improperly impacted the poll logic.
> I've noticed an improvement in terms of performances as well (*).
> Taking as example the tg3 driver, I've reviewed and modified the
> locking mechanism (fixing the issue on tso you had raised).
>=20
> Please, let me know if you have other suggestions and/or advice.
>=20
> Regards,
> Peppe
>=20
>=20
> P.S. (*)
> I've just done some stress tests on our STB (mb618 - STi7111 SH4-300
> @450MHz) and I cannot see any failures or strange issues at this time=
=2E
>=20

Hi Giuseppe

I reviewed your code and found no obvious issues

Could you please avoid defining this

#define STMMAC_IP_ALIGN NET_IP_ALIGN

(I see tg3.c uses a similar TG3_RAW_IP_ALIGN, this is probably why you =
felt it was necessary :
In case of tg3, TG3_RAW_IP_ALIGN is used in cases where we always want =
to align the
IP/network header on dword boundaries, even on platforms where NET_IP_A=
LIGN)

I am not sure this is what you want for STM.

In that case, please check new netdev_alloc_skb_ip_align() helper

+		skb =3D netdev_alloc_skb(dev, bfsize);
+		if (unlikely(skb =3D=3D NULL)) {
+			pr_err("%s: Rx init fails; skb is NULL\n",
+			       __func__);
+			break;
+		}
+		skb_reserve(skb, STMMAC_IP_ALIGN);
+
+		priv->rx_skbuff[i] =3D skb;
+		priv->rx_skbuff_dma[i] =3D dma_map_single(priv->device,
+						skb->data,
+						bfsize - STMMAC_IP_ALIGN,
+						DMA_FROM_DEVICE);

becomes  (pktsize being real packet size, not packet size + NET_IP_ALIG=
N)

+		skb =3D netdev_alloc_skb_ip_align(dev, pktsize);
+		if (unlikely(skb =3D=3D NULL)) {
+			pr_err("%s: Rx init fails; skb is NULL\n",
+			       __func__);
+			break;
+		}
+
+		priv->rx_skbuff[i] =3D skb;
+		priv->rx_skbuff_dma[i] =3D dma_map_single(priv->device,
+						skb->data,
+						pktsize,
+						DMA_FROM_DEVICE);



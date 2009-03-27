From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH] gianfar: fix headroom expansion code
Date: Fri, 27 Mar 2009 12:26:33 +0800
Message-ID: <2a27d3730903262126v1a0282a5u6c8ee234dff8708d@mail.gmail.com>
References: <20090325.172139.142233386.davem@davemloft.net>
	 <20090326100856.265f7872@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:9157 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171AbZC0E0f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 00:26:35 -0400
Received: by wf-out-1314.google.com with SMTP id 29so1094891wff.4
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2009 21:26:33 -0700 (PDT)
In-Reply-To: <20090326100856.265f7872@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2009 at 1:08 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> The code that was added to increase headroom was wrong.
> It doesn't handle the case where gfar_add_fcb() changes the skb.

Oops.  I messed up the pointer to pointer manipulating.

> Better to do check at start of transmit (outside of lock), where
> error handling is better anyway.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>
> --- a/drivers/net/gianfar.c =C2=A0 =C2=A0 2009-03-26 09:14:39.2736699=
29 -0700
> +++ b/drivers/net/gianfar.c =C2=A0 =C2=A0 2009-03-26 09:22:46.4775450=
04 -0700
> @@ -1239,19 +1239,9 @@ static int gfar_enet_open(struct net_dev
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return err;
> =C2=A0}
>
> -static inline struct txfcb *gfar_add_fcb(struct sk_buff **skbp)
> +static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 struct txfcb *fcb;
> - =C2=A0 =C2=A0 =C2=A0 struct sk_buff *skb =3D *skbp;
> -
> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(skb_headroom(skb) < GMAC_FCB_LEN)=
) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct sk_buff *ol=
d_skb =3D skb;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb =3D skb_reallo=
c_headroom(old_skb, GMAC_FCB_LEN);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!skb)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 return NULL;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_kfree_skb_any(=
old_skb);
> - =C2=A0 =C2=A0 =C2=A0 }
> - =C2=A0 =C2=A0 =C2=A0 fcb =3D (struct txfcb *)skb_push(skb, GMAC_FCB=
_LEN);
> + =C2=A0 =C2=A0 =C2=A0 struct txfcb *fcb =3D (struct txfcb *)skb_push=
(skb, GMAC_FCB_LEN);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cacheable_memzero(fcb, GMAC_FCB_LEN);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return fcb;
> @@ -1320,6 +1310,20 @@ static int gfar_start_xmit(struct sk_buf
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0base =3D priv->tx_bd_base;
>
> + =C2=A0 =C2=A0 =C2=A0 /* make space for additional header */
> + =C2=A0 =C2=A0 =C2=A0 if (skb_headroom(skb) < GMAC_FCB_LEN) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct sk_buff *sk=
b_new;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb_new =3D skb_re=
alloc_headroom(skb, GMAC_FCB_LEN);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!skb_new) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 dev->stats.tx_errors++;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 kfree(skb);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 return NETDEV_TX_OK;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree_skb(skb);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb =3D skb_new;
> + =C2=A0 =C2=A0 =C2=A0 }
> +

We have legacy devices without the offloading feature.  And we can
even turn off the IP checksum offloading at runtime.  Your code will
cause unnecessary realloc for these cases.

I can propose a new patch to fix the pointer problem and add more
error handling.

> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* total number of fragments in the SKB */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_frags =3D skb_shinfo(skb)->nr_frags;
>
> @@ -1372,20 +1376,18 @@ static int gfar_start_xmit(struct sk_buf
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Set up checksumming */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (CHECKSUM_PARTIAL =3D=3D skb->ip_summed=
) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fcb =3D gfar_add_f=
cb(&skb);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(fcb !=3D=
 NULL)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 lstatus |=3D BD_LFLAG(TXBD_TOE);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 gfar_tx_checksum(skb, fcb);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fcb =3D gfar_add_f=
cb(skb);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lstatus |=3D BD_LF=
LAG(TXBD_TOE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 gfar_tx_checksum(s=
kb, fcb);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (priv->vlgrp && vlan_tx_tag_present(skb=
)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(NULL =
=3D=3D fcb))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 fcb =3D gfar_add_fcb(&skb);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(fcb !=3D=
 NULL)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(NULL =
=3D=3D fcb)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 fcb =3D gfar_add_fcb(skb);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0lstatus |=3D BD_LFLAG(TXBD_TOE);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 gfar_tx_vlan(skb, fcb);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 gfar_tx_vlan(skb, =
fcb);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* setup the TxBD length and buffer pointe=
r for the first BD */
> @@ -1433,7 +1435,7 @@ static int gfar_start_xmit(struct sk_buf
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Unlock priv */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&priv->txlock, flag=
s);
>
> - =C2=A0 =C2=A0 =C2=A0 return 0;
> + =C2=A0 =C2=A0 =C2=A0 return NETDEV_TX_OK;
> =C2=A0}
>
> =C2=A0/* Stops the kernel queue, and halts the controller */

From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH] ucc_geth: Rework the TX logic.
Date: Fri, 27 Mar 2009 18:39:07 +0800
Message-ID: <2a27d3730903270339l44ccb55fo9079402104afc458@mail.gmail.com>
References: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <2a27d3730903270245k6e8633eehfb5cd3fcebd36240@mail.gmail.com>
	 <OFDCE90357.0EDC5DC1-ONC1257586.003759A3-C1257586.00390AD3@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: avorontsov@ru.mvista.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:20209 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbZC0KjJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 06:39:09 -0400
Received: by wf-out-1314.google.com with SMTP id 29so1247305wff.4
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2009 03:39:07 -0700 (PDT)
In-Reply-To: <OFDCE90357.0EDC5DC1-ONC1257586.003759A3-C1257586.00390AD3@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2009 at 6:23 PM, Joakim Tjernlund
<Joakim.Tjernlund@transmode.se> wrote:
> pku.leo@gmail.com wrote on 27/03/2009 10:45:12:
>> On Fri, Mar 27, 2009 at 1:44 AM, Joakim Tjernlund
>> <Joakim.Tjernlund@transmode.se> wrote:
>> > The line:
>> > =C2=A0if ((bd =3D=3D ugeth->txBd[txQ]) && (netif_queue_stopped(dev=
) =3D=3D 0))
>> > =C2=A0 =C2=A0 =C2=A0 break;
>> > in ucc_geth_tx() didn not make sense to me. Rework & cleanup
>> > this logic to something understandable.
>> > ---
>> >
>> > Reworked the patch according to Antons comments.
>> >
>> > =C2=A0drivers/net/ucc_geth.c | =C2=A0 66
> +++++++++++++++++++++++++++--------------------
>> > =C2=A01 files changed, 38 insertions(+), 28 deletions(-)
>> >
>> > diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
>> > index 7fc91aa..465de3a 100644
>> > --- a/drivers/net/ucc_geth.c
>> > +++ b/drivers/net/ucc_geth.c
>> > @@ -161,6 +161,17 @@ static struct ucc_geth_info ugeth_primary_inf=
o =3D
> {
>> >
>> > =C2=A0static struct ucc_geth_info ugeth_info[8];
>> >
>> > +
>> > +static inline u32 __iomem *bd2buf(u8 __iomem *bd)
>> > +{
>> > + =C2=A0 =C2=A0 =C2=A0 return (u32 __iomem *)(bd+4);
>> > +}
>> > +
>> > +static inline u32 __iomem *bd2status(u8 __iomem *bd)
>> > +{
>> > + =C2=A0 =C2=A0 =C2=A0 return (u32 __iomem *)bd;
>> > +}
>>
>>
>> When the driver was reviewed for upstream merge, I was told to remov=
e
>> this kind of thing in favor of direct struct qe_bd access. =C2=A0So =
do we
>> really have a guideline on this? =C2=A0Or it's just a matter of pers=
onal
>> preference?
>
> This is a bit better than the current type casts. Moving over to qe_b=
d
> accesses is a bigger cleanup that will have to be a seperate patch.
> I am not sure it is an all win as you probably loose the ability
> to read both status and len in one access.
>
>>
>> > +
>> > =C2=A0#ifdef DEBUG
>> > =C2=A0static void mem_disp(u8 *addr, int size)
>> > =C2=A0{
>> > @@ -3048,6 +3059,7 @@ static int ucc_geth_start_xmit(struct sk_buf=
f
> *skb, struct net_device *dev)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 __iomem *bd; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* BD pointer */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 bd_status;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 txQ =3D 0;
>> > + =C2=A0 =C2=A0 =C2=A0 int tx_ind;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0ugeth_vdbg("%s: IN", __func__);
>> >
>> > @@ -3057,21 +3069,19 @@ static int ucc_geth_start_xmit(struct sk_b=
uff
> *skb, struct net_device *dev)
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Start from the next BD that should b=
e filled */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0bd =3D ugeth->txBd[txQ];
>> > - =C2=A0 =C2=A0 =C2=A0 bd_status =3D in_be32((u32 __iomem *)bd);
>> > + =C2=A0 =C2=A0 =C2=A0 bd_status =3D in_be32(bd2status(bd));
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Save the skb pointer so we can free =
it later */
>> > - =C2=A0 =C2=A0 =C2=A0 ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]=
] =3D skb;
>> > + =C2=A0 =C2=A0 =C2=A0 tx_ind =3D ugeth->skb_curtx[txQ];
>> > + =C2=A0 =C2=A0 =C2=A0 ugeth->tx_skbuff[txQ][tx_ind] =3D skb;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Update the current skb pointer (wrap=
ping if this was the
> last) */
>> > - =C2=A0 =C2=A0 =C2=A0 ugeth->skb_curtx[txQ] =3D
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (ugeth->skb_curtx[txQ] +
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01) & TX_RING_MOD_MASK(u=
geth->ug_info->bdRingLenTx[txQ]);
>> > + =C2=A0 =C2=A0 =C2=A0 tx_ind =3D (tx_ind + 1) &
> TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
>> > + =C2=A0 =C2=A0 =C2=A0 ugeth->skb_curtx[txQ] =3D tx_ind;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* set up the buffer descriptor */
>> > - =C2=A0 =C2=A0 =C2=A0 out_be32(&((struct qe_bd __iomem *)bd)->buf=
,
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 dma_map_single(&ugeth->dev->dev, skb->data,
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb->len, DMA_TO_DEVICE));
>> > -
>> > - =C2=A0 =C2=A0 =C2=A0 /* printk(KERN_DEBUG"skb->data is 0x%x\n",s=
kb->data); */
>> > + =C2=A0 =C2=A0 =C2=A0 out_be32(bd2buf(bd),
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dma_map_s=
ingle(&ugeth->dev->dev, skb->data,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb->len, DMA_TO_DEVICE));
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0bd_status =3D (bd_status & T_W) | T_R |=
 T_I | T_L | skb->len;
>> >
>> > @@ -3088,9 +3098,9 @@ static int ucc_geth_start_xmit(struct sk_buf=
f
> *skb, struct net_device *dev)
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If the next BD still needs to be cle=
aned up, then the bds
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 are full. =C2=A0We need to tell=
 the kernel to stop sending us
> stuff. */
>> > - =C2=A0 =C2=A0 =C2=A0 if (bd =3D=3D ugeth->confBd[txQ]) {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!netif_queu=
e_stopped(dev))
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 netif_stop_queue(dev);
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 if (!in_be32(bd2buf(bd))) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netif_stop_queu=
e(dev);
>>
>> Why does this make more sense? =C2=A0The BD with a NULL buffer means=
 the
>> ring is full? =C2=A0It's not the normal case.
>>
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0ugeth->txBd[txQ] =3D bd;
>> > @@ -3198,41 +3208,41 @@ static int ucc_geth_tx(struct net_device *=
dev,
> u8 txQ)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ucc_geth_private *ugeth =3D netd=
ev_priv(dev);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 __iomem *bd; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* BD pointer */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 bd_status;
>> > + =C2=A0 =C2=A0 =C2=A0 int tx_ind, num_freed;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0bd =3D ugeth->confBd[txQ];
>> > - =C2=A0 =C2=A0 =C2=A0 bd_status =3D in_be32((u32 __iomem *)bd);
>> > -
>> > + =C2=A0 =C2=A0 =C2=A0 bd_status =3D in_be32(bd2status(bd));
>> > + =C2=A0 =C2=A0 =C2=A0 tx_ind =3D ugeth->skb_dirtytx[txQ];
>> > + =C2=A0 =C2=A0 =C2=A0 num_freed =3D 0;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Normal processing. */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0while ((bd_status & T_R) =3D=3D 0) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* BD conta=
ins already transmitted buffer. =C2=A0 */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Handle t=
he transmitted buffer and release */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* the BD t=
o be used with the current frame =C2=A0*/
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((bd =3D=3D =
ugeth->txBd[txQ]) &&
> (netif_queue_stopped(dev) =3D=3D 0))
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 break;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (bd =3D=3D u=
geth->txBd[txQ])
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 break; /* Queue is empty */
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->stats.=
tx_packets++;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Free the=
 sk buffer associated with this TxBD */
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_kfree_skb(u=
geth->
>> > -
> tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]]);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ugeth->tx_skbuf=
f[txQ][ugeth->skb_dirtytx[txQ]] =3D NULL;
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ugeth->skb_dirt=
ytx[txQ] =3D
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (=
ugeth->skb_dirtytx[txQ] +
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A01) &
> TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
>> > -
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* We freed a b=
uffer, so now we can restart
> transmission */
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (netif_queue=
_stopped(dev))
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 netif_wake_queue(dev);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_kfree_skb(u=
geth->tx_skbuff[txQ][tx_ind]);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ugeth->tx_skbuf=
f[txQ][tx_ind] =3D NULL;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 out_be32(bd2buf=
(bd), 0); /* Mark it free */
>>
>> Now I see why you depend on the buffer to judge if the BD ring is
>> full. =C2=A0If you want to do this, make sure it's well documented i=
n code,
>> or others will be confused. =C2=A0And as Anton already commented, in=
/out
>> access is slow. =C2=A0I think the original way can be fixed if you t=
hink
>> it's broken, and will have better performance.
>
> The code could use a better comment, but I really think this method
> is superior and more robust. The problem is that in/out functions is
> much slower than it has to be for QE IO memory.
>
> The original way is broken and I tired to fix it but it always broke
> as soon one applied some load.

The only difference I see between your method and the original code is
that you update the cleanup progress on every BD.  The original code
updates progress only after all sent BDs are processed.  You can try
move ugeth->confBd[txQ] =3D bd; into the loop then it will be the same
as your proposed code.

- Leo

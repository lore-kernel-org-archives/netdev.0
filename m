From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Mon, 28 Jun 2010 02:33:26 -0700
Message-ID: <5E7CE189-1002-4723-ACB2-D537B71BA5F3@earthlink.net>
References: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com> <1277716394.4235.235.camel@edumazet-laptop>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Courtier-Dutton <james.dutton@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:37318 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750867Ab0F1Jdf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 05:33:35 -0400
In-Reply-To: <1277716394.4235.235.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 28, 2010, at 2:13 AM, Eric Dumazet wrote:

> Le lundi 28 juin 2010 =E0 08:41 +0100, James Courtier-Dutton a =E9cri=
t :
>> Hi,
>>=20
>> Reference:
>> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/279102
>>=20
>> I can see this bug and can reproduce it 100% on demand.
>> The problem seems to be that when the b44 has a incoming FIFO buffer
>> overflow, it resets the entire card, dis-associates with the access
>> point and therefore takes some time before it can pass traffic again=
=2E
>> Can anyone point me to some code that would just recover the FIFO
>> instead of reset the entire card?
>>=20
>> I am a kernel developer, but I don't have any data sheets on this ca=
rd
>> so was hoping someone with more knowledge of its workings, could hel=
p
>> me.
>>=20
>> I can then test it, and see if it is a good fix or not.
>>=20
>=20
> Hi
>=20
> Problem is we dont know if a Receive Fifo overflow is a minor or majo=
r
> indication from b44 chip.
>=20
> A minor indication would be : Chip tells us one or more frame were lo=
st.
> No special action needed from driver.
>=20
> A major indication (as of current implemented in b44 driver) is :
> I am completely out of order and need a reset. Please do it.
>=20
> Patch to switch from major to minor indication is easy, but we dont k=
now
> if its valid or not.
>=20
> diff --git a/drivers/net/b44.h b/drivers/net/b44.h
> index e1905a4..514dc3a 100644
> --- a/drivers/net/b44.h
> +++ b/drivers/net/b44.h
> @@ -42,7 +42,7 @@
> #define  ISTAT_EMAC		0x04000000 /* EMAC Interrupt */
> #define  ISTAT_MII_WRITE	0x08000000 /* MII Write Interrupt */
> #define  ISTAT_MII_READ		0x10000000 /* MII Read Interrupt */
> -#define  ISTAT_ERRORS (ISTAT_DSCE|ISTAT_DATAE|ISTAT_DPE|ISTAT_RDU|IS=
TAT_RFO|ISTAT_TFU)
> +#define  ISTAT_ERRORS (ISTAT_DSCE|ISTAT_DATAE|ISTAT_DPE|ISTAT_RDU|IS=
TAT_TFU)
> #define B44_IMASK	0x0024UL /* Interrupt Mask */
> #define  IMASK_DEF		(ISTAT_ERRORS | ISTAT_TO | ISTAT_RX | ISTAT_TX)
> #define B44_GPTIMER	0x0028UL /* General Purpose Timer */
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Why wouldn't the ability to recv frames after a Recv FIFO overflow
 indicate that a reset is NOT required?

Thus,  should't it be an indication of congestion if associated with a =
single
flow and either speed up (reduce latency to service) the recv side or=20
slow down the xmit side?

Mitchell Erblich
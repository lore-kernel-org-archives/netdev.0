From: zeal <zealcook@gmail.com>
Subject: Re: [PATCH 1/2 v2] KS8695: fix ks8695_rx_irq() bug.
Date: Mon, 16 Nov 2009 23:18:10 +0800
Message-ID: <efc9214f0911160718o4c7cd0ecv2e86b8d5ad7691ae@mail.gmail.com>
References: <4b016886.1d255e0a.16f1.ffff866a@mx.google.com>
	 <1258043088.1931.13.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ben@simtec.co.uk, davem@davemloft.net
To: "Figo.zhang" <figo1802@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:39907 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbZKPPSF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 10:18:05 -0500
Received: by yxe17 with SMTP id 17so4778351yxe.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 07:18:10 -0800 (PST)
In-Reply-To: <1258043088.1931.13.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 12:24 AM, Figo.zhang <figo1802@gmail.com> wrote=
:
> On Mon, 2009-11-16 at 22:58 +0800, zeal wrote:
>> From: zeal <zealcook@gmail.com>
>>
>> Sorry for the previously patches. THEY'RE NOT RIGHT. It's my mistake=
=2E
>> Please forgive my noise.
>> Please review the following patches and ignore the last (v1).
>>
>> ks8695 rx irq is edge-level. Before arriving at irq handler, the
>> corresponding status bit has been clear(irq's ack).
>> So we should not check it after that.
>
> see <KS8695X Integrated Multi-Port Gateway Solution Register
> Description> Version 1.00
>
> Interrupt Status Register(INTST Offset 0xE208)
>
> it has said: This edge-triggered interrupt status is cleared by writt=
ing
> 1 , so we should write 1 to clear status bit manually.
>
Yeah, but irq_chip's ack has done that.
Please check arch/arm/mach-ks8695/irq.c ks8695_irq_edge_chip->ack()

>>
>> Signed-off-by: zeal <zealcook@gmail.com>
>> ---
>> =A0drivers/net/arm/ks8695net.c | =A0 22 +++++++---------------
>> =A01 files changed, 7 insertions(+), 15 deletions(-)
>>
>> diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net=
=2Ec
>> index 0073d19..e15451a 100644
>> --- a/drivers/net/arm/ks8695net.c
>> +++ b/drivers/net/arm/ks8695net.c
>> @@ -433,24 +433,16 @@ ks8695_rx_irq(int irq, void *dev_id)
>> =A0{
>> =A0 =A0 =A0 struct net_device *ndev =3D (struct net_device *)dev_id;
>> =A0 =A0 =A0 struct ks8695_priv *ksp =3D netdev_priv(ndev);
>> - =A0 =A0 unsigned long status;
>> -
>> - =A0 =A0 unsigned long mask_bit =3D 1 << ks8695_get_rx_enable_bit(k=
sp);
>>
>> =A0 =A0 =A0 spin_lock(&ksp->rx_lock);
>>
>> - =A0 =A0 status =3D readl(KS8695_IRQ_VA + KS8695_INTST);
>> -
>> - =A0 =A0 /*clean rx status bit*/
>> - =A0 =A0 writel(status | mask_bit , KS8695_IRQ_VA + KS8695_INTST);
>> -
>> - =A0 =A0 if (status & mask_bit) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (napi_schedule_prep(&ksp->napi)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*disable rx interrupt*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status &=3D ~mask_bit;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 writel(status , KS8695_IRQ=
_VA + KS8695_INTEN);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __napi_schedule(&ksp->napi=
);
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 if (napi_schedule_prep(&ksp->napi)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 unsigned long status =3D readl(KS8695_IRQ_=
VA + KS8695_INTEN);
>> + =A0 =A0 =A0 =A0 =A0 =A0 unsigned long mask_bit =3D 1 << ks8695_get=
_rx_enable_bit(ksp);
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*disable rx interrupt*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 status &=3D ~mask_bit;
>> + =A0 =A0 =A0 =A0 =A0 =A0 writel(status , KS8695_IRQ_VA + KS8695_INT=
EN);
>> + =A0 =A0 =A0 =A0 =A0 =A0 __napi_schedule(&ksp->napi);
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 spin_unlock(&ksp->rx_lock);
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Thanks & Regards

zeal

From: "Figo.zhang" <figo1802@gmail.com>
Subject: Re: [PATCH 1/2 v2] KS8695: fix ks8695_rx_irq() bug.
Date: Fri, 13 Nov 2009 01:11:50 +0800
Message-ID: <1258045910.1931.16.camel@myhost>
References: <4b016886.1d255e0a.16f1.ffff866a@mx.google.com>
	 <1258043088.1931.13.camel@myhost>
	 <efc9214f0911160718o4c7cd0ecv2e86b8d5ad7691ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@simtec.co.uk, davem@davemloft.net
To: zeal <zealcook@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:59592 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbZKPP7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 10:59:42 -0500
Received: by pzk1 with SMTP id 1so2866542pzk.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 07:59:47 -0800 (PST)
In-Reply-To: <efc9214f0911160718o4c7cd0ecv2e86b8d5ad7691ae@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-16 at 23:18 +0800, zeal wrote:
> On Fri, Nov 13, 2009 at 12:24 AM, Figo.zhang <figo1802@gmail.com> wrote:
> > On Mon, 2009-11-16 at 22:58 +0800, zeal wrote:
> >> From: zeal <zealcook@gmail.com>
> >>
> >> Sorry for the previously patches. THEY'RE NOT RIGHT. It's my mistake.
> >> Please forgive my noise.
> >> Please review the following patches and ignore the last (v1).
> >>
> >> ks8695 rx irq is edge-level. Before arriving at irq handler, the
> >> corresponding status bit has been clear(irq's ack).
> >> So we should not check it after that.
> >
> > see <KS8695X Integrated Multi-Port Gateway Solution Register
> > Description> Version 1.00
> >
> > Interrupt Status Register(INTST Offset 0xE208)
> >
> > it has said: This edge-triggered interrupt status is cleared by writting
> > 1 , so we should write 1 to clear status bit manually.
> >
> Yeah, but irq_chip's ack has done that.
> Please check arch/arm/mach-ks8695/irq.c ks8695_irq_edge_chip->ack()

yes, you are right, but you have better add this description at commit
log.
> 
> >>
> >> Signed-off-by: zeal <zealcook@gmail.com>
> >> ---
> >>  drivers/net/arm/ks8695net.c |   22 +++++++---------------
> >>  1 files changed, 7 insertions(+), 15 deletions(-)
> >>
> >> diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
> >> index 0073d19..e15451a 100644
> >> --- a/drivers/net/arm/ks8695net.c
> >> +++ b/drivers/net/arm/ks8695net.c
> >> @@ -433,24 +433,16 @@ ks8695_rx_irq(int irq, void *dev_id)
> >>  {
> >>       struct net_device *ndev = (struct net_device *)dev_id;
> >>       struct ks8695_priv *ksp = netdev_priv(ndev);
> >> -     unsigned long status;
> >> -
> >> -     unsigned long mask_bit = 1 << ks8695_get_rx_enable_bit(ksp);
> >>
> >>       spin_lock(&ksp->rx_lock);
> >>
> >> -     status = readl(KS8695_IRQ_VA + KS8695_INTST);
> >> -
> >> -     /*clean rx status bit*/
> >> -     writel(status | mask_bit , KS8695_IRQ_VA + KS8695_INTST);
> >> -
> >> -     if (status & mask_bit) {
> >> -             if (napi_schedule_prep(&ksp->napi)) {
> >> -                     /*disable rx interrupt*/
> >> -                     status &= ~mask_bit;
> >> -                     writel(status , KS8695_IRQ_VA + KS8695_INTEN);
> >> -                     __napi_schedule(&ksp->napi);
> >> -             }
> >> +     if (napi_schedule_prep(&ksp->napi)) {
> >> +             unsigned long status = readl(KS8695_IRQ_VA + KS8695_INTEN);
> >> +             unsigned long mask_bit = 1 << ks8695_get_rx_enable_bit(ksp);
> >> +             /*disable rx interrupt*/
> >> +             status &= ~mask_bit;
> >> +             writel(status , KS8695_IRQ_VA + KS8695_INTEN);
> >> +             __napi_schedule(&ksp->napi);
> >>       }
> >>
> >>       spin_unlock(&ksp->rx_lock);
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 
> 
> 



From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH 3/4] net: ethernet: cpsw: split out IRQ handler
Date: Fri, 2 Jan 2015 14:56:36 -0800
Message-ID: <CAA93jw4BckMYOz_fUMVkW8m1YVO8uGjsb1srrhiF-meDoiD1WA@mail.gmail.com>
References: <1420222228-31949-1-git-send-email-balbi@ti.com>
	<1420222228-31949-4-git-send-email-balbi@ti.com>
	<CAA93jw7qyZjdHGKXjiBhiYp4BWBFrUFM6FF-Lzc0i7eOnM6cNg@mail.gmail.com>
	<20150102185535.GB4920@saruman>
	<CAA93jw7=aFM3yQLO+vtN4uHW2gMnfNaY=BdbA+b0WYq-0+gSYQ@mail.gmail.com>
	<20150102190350.GC4920@saruman>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:35017 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309AbbABW4h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 17:56:37 -0500
In-Reply-To: <20150102190350.GC4920@saruman>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 2, 2015 at 11:03 AM, Felipe Balbi <balbi@ti.com> wrote:
> Hi,
>
> (please use reply-all to keep mailing lists in Cc, also avoid
> top-posting)

I am trying not to read netdev right now... and failing, obviously.

>
> On Fri, Jan 02, 2015 at 10:58:29AM -0800, Dave Taht wrote:
>> The beaglebone only has a 100mbit phy, so you aren't going to get mo=
re
>> than that.
>
> very true :-) Still, with AM437x SK which is definitely GigE, I'm
> getting 201Mbits/sec.
>
>> (so do a lot of IoT devices).
>>
>> So you have the two patches that went by on BQL and on NAPI for the =
beagle?
>
> no, got any pointers ?

the relevant thread was "am335x: cpsw: phy ignores max-speed setting"

and the initial very small BQL enablement patch was here:

https://patchwork.ozlabs.org/patch/407640/

(it needed a saner treatment of a failure to dma something in
cpsw_tx_packet_submit  - the patch as is has also been part of nelsons
trees for the beaglebone for a while)

But it was rightly pointed out later in the thread that this change

+#define CPSW_POLL_WEIGHT 16

made for the biggest part of the improvement, and someone else on the
thread proposed handling that more dynamically for 100mbit phys with
another patch (that I can't find at the moment)

=2E.. but the root cause of the excessive latency in this driver was th=
e
single tx/rx dma queue, which you are addressing  in your patch set.
So if you glop on more of the above, mo better, perhaps you will win
bigger.

I will try to slice out some time to boot up a beagle on net-next next =
week.

>> On Fri, Jan 2, 2015 at 10:55 AM, Felipe Balbi <balbi@ti.com> wrote:
>> > Hi,
>> >
>> > On Fri, Jan 02, 2015 at 10:49:49AM -0800, Dave Taht wrote:
>> >> +1.
>> >>
>> >> We'd had a thread on netdev (can't find it now) where we discusse=
d
>> >> adding BQL support and also something saner for the NAPI handling=
 to
>> >> this driver.
>> >
>> > yeah, currently is completely borked. I'm on a gigabit network and=
 I'm
>> > getting 94Mbits/sec, total crap.
>> >
>> >> Initial results for the beaglebone black were pretty spectacular,=
 and
>> >> it does look like this is way cleaner infrastructure underneat th=
 deal
>> >> with. Are you testing
>> >
>> > cool, if I new more about networking I'd certainly help, but I can=
 help
>> > testing for sure, just keep me in Cc ;-)
>> >
>> >> on the beaglebone black.? do you remember that convo?
>> >
>> > yeah, testing on beagleboneblack and AM437x SK.
>> >
>> > cheers
>> >
>> >> On Fri, Jan 2, 2015 at 10:10 AM, Felipe Balbi <balbi@ti.com> wrot=
e:
>> >> > Now we can introduce dedicated IRQ handlers
>> >> > for each of the IRQ events. This helps with
>> >> > cleaning up a little bit of the clutter in
>> >> > cpsw_interrupt() while also making sure that
>> >> > TX IRQs will try to handle TX buffers while
>> >> > RX IRQs will try to handle RX buffers.
>> >> >
>> >> > Signed-off-by: Felipe Balbi <balbi@ti.com>
>> >> > ---
>> >> >  drivers/net/ethernet/ti/cpsw.c | 41 ++++++++++++++++++++++++++=
++++-----------
>> >> >  1 file changed, 30 insertions(+), 11 deletions(-)
>> >> >
>> >> > diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ether=
net/ti/cpsw.c
>> >> > index 6e04128..c9081bd 100644
>> >> > --- a/drivers/net/ethernet/ti/cpsw.c
>> >> > +++ b/drivers/net/ethernet/ti/cpsw.c
>> >> > @@ -754,18 +754,36 @@ requeue:
>> >> >                 dev_kfree_skb_any(new_skb);
>> >> >  }
>> >> >
>> >> > -static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
>> >> > +static irqreturn_t cpsw_dummy_interrupt(int irq, void *dev_id)
>> >> >  {
>> >> >         struct cpsw_priv *priv =3D dev_id;
>> >> >         int value =3D irq - priv->irqs_table[0];
>> >> >
>> >> > -       /* NOTICE: Ending IRQ here. The trick with the 'value' =
variable above
>> >> > -        * is to make sure we will always write the correct val=
ue to the EOI
>> >> > -        * register. Namely 0 for RX_THRESH Interrupt, 1 for RX=
 Interrupt, 2
>> >> > -        * for TX Interrupt and 3 for MISC Interrupt.
>> >> > -        */
>> >> >         cpdma_ctlr_eoi(priv->dma, value);
>> >> >
>> >> > +       return IRQ_HANDLED;
>> >> > +}
>> >> > +
>> >> > +static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
>> >> > +{
>> >> > +       struct cpsw_priv *priv =3D dev_id;
>> >> > +
>> >> > +       cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
>> >> > +       cpdma_chan_process(priv->txch, 128);
>> >> > +
>> >> > +       priv =3D cpsw_get_slave_priv(priv, 1);
>> >> > +       if (priv)
>> >> > +               cpdma_chan_process(priv->txch, 128);
>> >> > +
>> >> > +       return IRQ_HANDLED;
>> >> > +}
>> >> > +
>> >> > +static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
>> >> > +{
>> >> > +       struct cpsw_priv *priv =3D dev_id;
>> >> > +
>> >> > +       cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
>> >> > +
>> >> >         cpsw_intr_disable(priv);
>> >> >         if (priv->irq_enabled =3D=3D true) {
>> >> >                 cpsw_disable_irq(priv);
>> >> > @@ -1617,7 +1635,8 @@ static void cpsw_ndo_poll_controller(stru=
ct net_device *ndev)
>> >> >
>> >> >         cpsw_intr_disable(priv);
>> >> >         cpdma_ctlr_int_ctrl(priv->dma, false);
>> >> > -       cpsw_interrupt(ndev->irq, priv);
>> >> > +       cpsw_rx_interrupt(priv->irq[1], priv);
>> >> > +       cpsw_tx_interrupt(priv->irq[2], priv);
>> >> >         cpdma_ctlr_int_ctrl(priv->dma, true);
>> >> >         cpsw_intr_enable(priv);
>> >> >  }
>> >> > @@ -2351,7 +2370,7 @@ static int cpsw_probe(struct platform_dev=
ice *pdev)
>> >> >                 goto clean_ale_ret;
>> >> >
>> >> >         priv->irqs_table[0] =3D irq;
>> >> > -       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_interrup=
t,
>> >> > +       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_dummy_in=
terrupt,
>> >> >                         0, dev_name(&pdev->dev), priv);
>> >> >         if (ret < 0) {
>> >> >                 dev_err(priv->dev, "error attaching irq (%d)\n"=
, ret);
>> >> > @@ -2363,7 +2382,7 @@ static int cpsw_probe(struct platform_dev=
ice *pdev)
>> >> >                 goto clean_ale_ret;
>> >> >
>> >> >         priv->irqs_table[1] =3D irq;
>> >> > -       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_interrup=
t,
>> >> > +       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_rx_inter=
rupt,
>> >> >                         0, dev_name(&pdev->dev), priv);
>> >> >         if (ret < 0) {
>> >> >                 dev_err(priv->dev, "error attaching irq (%d)\n"=
, ret);
>> >> > @@ -2375,7 +2394,7 @@ static int cpsw_probe(struct platform_dev=
ice *pdev)
>> >> >                 goto clean_ale_ret;
>> >> >
>> >> >         priv->irqs_table[2] =3D irq;
>> >> > -       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_interrup=
t,
>> >> > +       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_tx_inter=
rupt,
>> >> >                         0, dev_name(&pdev->dev), priv);
>> >> >         if (ret < 0) {
>> >> >                 dev_err(priv->dev, "error attaching irq (%d)\n"=
, ret);
>> >> > @@ -2387,7 +2406,7 @@ static int cpsw_probe(struct platform_dev=
ice *pdev)
>> >> >                 goto clean_ale_ret;
>> >> >
>> >> >         priv->irqs_table[3] =3D irq;
>> >> > -       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_interrup=
t,
>> >> > +       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_dummy_in=
terrupt,
>> >> >                         0, dev_name(&pdev->dev), priv);
>> >> >         if (ret < 0) {
>> >> >                 dev_err(priv->dev, "error attaching irq (%d)\n"=
, ret);
>> >> > --
>> >> > 2.2.0
>> >> >
>> >> > --
>> >> > To unsubscribe from this list: send the line "unsubscribe netde=
v" in
>> >> > the body of a message to majordomo@vger.kernel.org
>> >> > More majordomo info at  http://vger.kernel.org/majordomo-info.h=
tml
>> >>
>> >>
>> >>
>> >> --
>> >> Dave T=C3=A4ht
>> >>
>> >> thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
>> >
>> > --
>> > balbi
>>
>>
>>
>> --
>> Dave T=C3=A4ht
>>
>> thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
>
> --
> balbi



--=20
Dave T=C3=A4ht

thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks

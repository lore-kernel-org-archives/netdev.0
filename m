From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v3] add the driver for Analog Devices Blackfin on-chip
 CAN	controllers
Date: Thu, 10 Dec 2009 11:35:55 +0100
Message-ID: <4B20CF0B.9070208@grandegger.com>
References: <1260430072-21106-1-git-send-email-21cnbao@gmail.com> 	<4B20BB36.50509@grandegger.com> <3c17e3570912100214k4b3eb038u1108c82bfa346389@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de,
	uclinux-dist-devel@blackfin.uclinux.org, davem@davemloft.net,
	"H.J. Oertel" <oe@port.de>, netdev@vger.kernel.org
To: Barry Song <21cnbao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:51070 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933627AbZLJKgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 05:36:35 -0500
In-Reply-To: <3c17e3570912100214k4b3eb038u1108c82bfa346389@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Barry Song wrote:
> On Thu, Dec 10, 2009 at 5:11 PM, Wolfgang Grandegger <wg@grandegger.com> wrote:
>> Barry Song wrote:
>>> Signed-off-by: Barry Song <21cnbao@gmail.com>
>>> Signed-off-by: H.J. Oertel <oe@port.de>
>>> ---
>>>  -v3: use structures to describe the layout of registers
>> Wow, that was quick, thanks for your effort and patience.
>>
>> Please use checkpath.pl to detect the obvious coding style problems,
>> especially the "WARNING: line over 80 characters".
>>
>> I also think the declaration of reg should have the __iomem as well:
>>
>>        struct bfin_can_regs __iomem *reg = priv->membase;
>>
>>>  drivers/net/can/Kconfig    |    9 +
>>>  drivers/net/can/Makefile   |    1 +
>>>  drivers/net/can/bfin_can.c |  836 ++++++++++++++++++++++++++++++++++++++++++++
>>>  3 files changed, 846 insertions(+), 0 deletions(-)
>>>  create mode 100644 drivers/net/can/bfin_can.c
>>>
[snip]
>>> diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
>>> new file mode 100644
>>> index 0000000..b94169d
>>> --- /dev/null
>>> +++ b/drivers/net/can/bfin_can.c
>>> @@ -0,0 +1,836 @@
>>> +/*
>>> + * Blackfin On-Chip CAN Driver
>>> + *
>>> + * Copyright 2004-2009 Analog Devices Inc.
>> Consider adding your copyright here, with a name and address.
>>
>>> + *
>>> + * Enter bugs at http://blackfin.uclinux.org/
>>> + *
>>> + * Licensed under the GPL-2 or later.
>> Please add the usual "GPL-2 or later" bla-bla here.
> Here I am not completely sure. But I am sure I am using the head file
> template of ADI which has been used widely in kernel and should be
> right.

Well, at least it's not the usual bla bla. Maybe somebody else could
clarify that. David?

[snip]
>>> +static void bfin_can_set_reset_mode(struct net_device *dev)
>>> +{
>>> +     struct bfin_can_priv *priv = netdev_priv(dev);
>>> +     struct bfin_can_regs *reg = priv->membase;
>>> +     int timeout = BFIN_CAN_TIMEOUT;
>>> +     int i;
>>> +
>>> +     /* disable interrupts */
>>> +     writew(0, &reg->mbim1);
>>> +     writew(0, &reg->mbim2);
>>> +     writew(0, &reg->gim);
>>> +
>>> +     /* reset can and enter configuration mode */
>>> +     writew(SRS | CCR, &reg->ctrl);
>>> +     SSYNC();
>>> +     writew(CCR, &reg->ctrl);
>>> +     SSYNC();
>>> +     while (!(readw(&reg->ctrl) & CCA)) {
>>> +             udelay(10);
>>> +             if (--timeout == 0) {
>>> +                     dev_err(dev->dev.parent, "fail to enter configuration mode\n");
>>> +                     BUG();
>>> +             }
>>> +     }
>> Isn't using BUG() to harsh here? Using and handling a proper return code
>> might already be sufficient.
> Due to the hardware design, here timeout will never happen. If it
> happens, that means hardware component has crashed.

OK.

[snip]
>>> +static int bfin_can_err(struct net_device *dev, u16 isrc, u16 status)
>>> +{
>>> +     struct bfin_can_priv *priv = netdev_priv(dev);
>>> +     struct bfin_can_regs *reg = priv->membase;
>>> +     struct net_device_stats *stats = &dev->stats;
>>> +     struct can_frame *cf;
>>> +     struct sk_buff *skb;
>>> +     enum can_state state = priv->can.state;
>>> +
>>> +     skb = alloc_can_err_skb(dev, &cf);
>>> +     if (skb == NULL)
>>> +             return -ENOMEM;
>>> +
>>> +     if (isrc & RMLIS) {
>>> +             /* data overrun interrupt */
>>> +             dev_dbg(dev->dev.parent, "data overrun interrupt\n");
>>> +             cf->can_id |= CAN_ERR_CRTL;
>>> +             cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
>>> +             stats->rx_over_errors++;
>>> +             stats->rx_errors++;
>>> +     }
>>> +
>>> +     if (isrc & BOIS) {
>>> +             dev_dbg(dev->dev.parent, "bus-off mode interrupt\n");
>>> +
>> Empty line?
>>
>>> +             state = CAN_STATE_BUS_OFF;
>>> +             cf->can_id |= CAN_ERR_BUSOFF;
>>> +             can_bus_off(dev);
>>> +     }
>>> +
>>> +     if (isrc & EPIS) {
>>> +             /* error passive interrupt */
>>> +             dev_dbg(dev->dev.parent, "error passive interrupt\n");
>>> +             state = CAN_STATE_ERROR_PASSIVE;
>>> +     }
>>> +
>>> +     if ((isrc & EWTIS) || (isrc & EWRIS)) {
>>> +             dev_dbg(dev->dev.parent, "Error Warning Transmit/Receive Interrupt\n");
>>> +             state = CAN_STATE_ERROR_WARNING;
>>> +     }
>>> +
>>> +     if (state != priv->can.state && (state == CAN_STATE_ERROR_WARNING ||
>>> +                             state == CAN_STATE_ERROR_PASSIVE)) {
>>> +             u16 cec = readw(&reg->cec);
>>> +             u8 rxerr = cec;
>>> +             u8 txerr = cec >> 8;
>> Add an empty line here, please.
>>
>>> +             cf->can_id |= CAN_ERR_CRTL;
>>> +             if (state == CAN_STATE_ERROR_WARNING) {
>>> +                     priv->can.can_stats.error_warning++;
>>> +                     cf->data[1] = (txerr > rxerr) ?
>>> +                             CAN_ERR_CRTL_TX_WARNING :
>>> +                             CAN_ERR_CRTL_RX_WARNING;
>>> +             } else {
>>> +                     priv->can.can_stats.error_passive++;
>>> +                     cf->data[1] = (txerr > rxerr) ?
>>> +                             CAN_ERR_CRTL_TX_PASSIVE :
>>> +                             CAN_ERR_CRTL_RX_PASSIVE;
>>> +             }
>>> +     }
>>> +
>>> +     if (status) {
>>> +             priv->can.can_stats.bus_error++;
>>> +
>>> +             cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>> +
>>> +             if (status & BEF)
>>> +                     cf->data[2] |= CAN_ERR_PROT_BIT;
>>> +             else if (status & FER)
>>> +                     cf->data[2] |= CAN_ERR_PROT_FORM;
>>> +             else if (status & SER)
>>> +                     cf->data[2] |= CAN_ERR_PROT_STUFF;
>>> +             else
>>> +                     cf->data[2] |= CAN_ERR_PROT_UNSPEC;
>>> +     }
>> Add {} here as well.
> {} will cause checkpatch warning if it is given to only one line.

Of course, my fault. Forget it.

>>> +     priv->can.state = state;
>>> +
>>> +     netif_rx(skb);
>>> +
>>> +     stats->rx_packets++;
>>> +     stats->rx_bytes += cf->can_dlc;
>>> +
>>> +     return 0;
>>> +}
>>> +
>>> +irqreturn_t bfin_can_interrupt(int irq, void *dev_id)
>>> +{
>>> +     struct net_device *dev = dev_id;
>>> +     struct bfin_can_priv *priv = netdev_priv(dev);
>>> +     struct bfin_can_regs *reg = priv->membase;
>>> +     struct net_device_stats *stats = &dev->stats;
>>> +     u16 status, isrc;
>>> +
>>> +     if ((irq == priv->tx_irq) && readw(&reg->mbtif2)) {
>>> +             /* transmission complete interrupt */
>>> +             writew(0xFFFF, &reg->mbtif2);
>>> +             stats->tx_packets++;
>>> +             stats->tx_bytes += bfin_can_read_dlc(priv, TRANSMIT_CHL);
>>> +             can_get_echo_skb(dev, 0);
>>> +             netif_wake_queue(dev);
>>> +     } else if ((irq == priv->rx_irq) && readw(&reg->mbrif1)) {
>>> +             /* receive interrupt */
>>> +             isrc = readw(&reg->mbrif1);
>>> +             writew(0xFFFF, &reg->mbrif1);
>>> +             bfin_can_rx(dev, isrc);
>>> +     } else if ((irq == priv->err_irq) && readw(&reg->gis)) {
>>> +             /* error interrupt */
>>> +             isrc = readw(&reg->gis);
>>> +             status = readw(&reg->esr);
>>> +             writew(0x7FF, &reg->gis);
>>> +             bfin_can_err(dev, isrc, status);
>>> +     } else
>>> +             return IRQ_NONE;
>> Use {} here as well.
> {} will cause checkpatch warning if it is given to only one line.

But here it should be added as explained here:

http://lxr.linux.no/#linux+v2.6.32/Documentation/CodingStyle#L171

Does checkpatch really complain?

[snip]
>>> +#ifdef CONFIG_PM
>>> +static int bfin_can_suspend(struct platform_device *pdev, pm_message_t mesg)
>>> +{
>>> +     struct net_device *dev = dev_get_drvdata(&pdev->dev);
>>> +     struct bfin_can_priv *priv = netdev_priv(dev);
>>> +     struct bfin_can_regs *reg = priv->membase;
>>> +     int timeout = BFIN_CAN_TIMEOUT;
>>> +
>>> +     if (netif_running(dev)) {
>>> +             /* enter sleep mode */
>>> +             writew(readw(&reg->ctrl) | SMR, &reg->ctrl);
>>> +             SSYNC();
>>> +             while (!(readw(&reg->intr) & SMACK)) {
>>> +                     udelay(10);
>>> +                     if (--timeout == 0) {
>>> +                             dev_err(dev->dev.parent, "fail to enter sleep mode\n");
>>> +                             BUG();
>>> +                     }
>>> +             }
>> It's already the third time that this timeout check is used. A common
>> function would make sense.
> Every time, the check condition is different and print information
> will change. It is ugly to define only one function.

OK, I obviously missed that. Sorry for the noise.

Wolfgang.

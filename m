From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] net-next:can: add TI CAN (HECC) driver
Date: Mon, 31 Aug 2009 10:59:41 +0200
Message-ID: <4A9B90FD.3000301@grandegger.com>
References: <2A3DCF3DA181AD40BDE86A3150B27B6B02F621106B@dbde02.ent.ti.com>	<4A98D36E.9070903@grandegger.com> <2A3DCF3DA181AD40BDE86A3150B27B6B02F6211427@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core@lists.berlios.de" <Socketcan-core@lists.berlios.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "Gole, Anant" <anantgole@TI.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:53484 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbZHaI7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 04:59:44 -0400
In-Reply-To: <2A3DCF3DA181AD40BDE86A3150B27B6B02F6211427@dbde02.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gole, Anant wrote:
>> -----Original Message-----
>> From: Wolfgang Grandegger [mailto:wg@grandegger.com]
>> Sent: Saturday, August 29, 2009 12:36 PM
>> To: Gole, Anant
>> Cc: Linux Netdev List; Socketcan-core@lists.berlios.de
>> Subject: Re: [PATCH] net-next:can: add TI CAN (HECC) driver
>>
>>> TI HECC (High End CAN Controller) module is found on many TI devices. It
>> has
>>> 32 harwdare mailboxes with full implementation of CAN protocol version
>> 2.0B
>>> and bus speeds up to 1Mbps. The module specifications are available at TI
>> web
>>> <http://www.ti.com>.
>>>
>>> This driver is tested on OMAP3517 EVM. Suspend/Resume not tested as yet.
>> Nice driver, even using the NAPI interface. First some general comments.
>> Please remove debugging code mainly useful for development, e.g. the
>> CONFIG_DEBUG_FS block, many dev_info calls and special statistics
>> counters. Also use dev_dbg for the remaining debug messages useful for
>> the normal user, like state changes. More comments inline.
> 
> Ack on most comments you gave - some good bugs uncovered with this review. Thanks. I am answering those which I have some comment on.
> 
> [snip]
> 
>>> +#define HECC_MODULE_VERSION     "0.2"
>> A version number is will usually not maintained. May drivers have it but
>> it's never changed.
> 
> I understand but unless this is a strong objection I would like to keep it as it would be nice to update it when any major change happens.

It's *not* a strong objection but I personally believe that git is doing
a much better job.

> [snip]
> 
>>> +
>>> +/* CAN Bittiming constants as per HECC specs */
>>> +static struct can_bittiming_const ti_hecc_bittiming_const = {
>>> +       .name = DRV_NAME,
>>> +       .tseg1_min = 1,
>>> +       .tseg1_max = 16,
>>> +       .tseg2_min = 1,
>> Please check if tseg2_min is a valid value. Usually it's larger.
>>
> Yes I did. This controller allows tseg2_min = 1

OK.
> 
> [snip]
>>> +       struct napi_struct napi;
>>> +       struct net_device *ndev;
>>> +       struct clk *clk;
>>> +       void __iomem *base;
>>> +       unsigned int scc_ram_offset;
>>> +       unsigned int hecc_ram_offset;
>>> +       unsigned int mbox_offset;
>>> +       unsigned int int_line;
>>> +       DECLARE_BITMAP(tx_free_mbx, TI_HECC_MAX_TX_MBOX);
>>> +       spinlock_t tx_lock;
>> Please document the spinlock tx_lock. What is it used for.
> 
> It is to protect the tx_free_mbx bitmap above - will document.

I know, but for kernel inclusion it should be documented.

> [snip]
> 
>> Right, automatic bus-off recovery should be disabled. To make that clear:
>>
>>           hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_ABO);
> 
> Since CANMC register is set to 0 and ABO bit is part of it I did not make this statement explicitly (it will be redundant). I will update the comment above to state that if it changes in future then enable auto bus off with that statement

OK.

> [snip]
> 
>>> +
>>> +static int ti_hecc_do_set_mode(struct net_device *ndev, enum can_mode
>> mode)
>>> +{
>>> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
>>> +       int ret = 0;
>>> +
>>> +       switch (mode) {
>>> +       case CAN_MODE_SLEEP:
>>> +               dev_info(priv->ndev->dev.parent, "device going to
>> sleep\n");
>>> +               if (netif_running(ndev)) {
>>> +                       netif_stop_queue(ndev);
>>> +                       netif_device_detach(ndev);
>>> +                       /* Put HECC in low power mode */
>>> +                       hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>>> +               }
>>> +               priv->can.state = CAN_STATE_SLEEPING;
>>> +               break;
>> Has sleeping been tested? Actually, we do not have an interface yet to
>> enter sleep mode. Please remove. If there is a need for it, we should
>> work togehter to refine the interface and to provide a solution.
>>
> No I have not yet tested sleep/suspend/resume. Will remove based upon response to CAN_MODE_STOP comment below
> 
>>> +       case CAN_MODE_STOP:
>>> +               dev_info(priv->ndev->dev.parent, "device stopping\n");
>>> +               ti_hecc_stop(ndev);
>>> +               break;
>> Only CAN_MODE_START is used by the CAN devicde interface for bus-off
>> recovery.
>>
> I saw other drivers (like mscan) also have the code for sleep/stop. Agreed that I have not tested it as you mentioned that the CAN infrastructure does not call it right now. Do you want me to remove it?

Yes, for kernel inclusion it should be removed. We are more relaxed to
keep that "preliminary" and "un-tested" code in the BerliOS SVN
repository. Note that the MSCAN driver is not yet mainline

> [snip]
> 
>>> +
>>> +       }
>>> +       set_bit(mbxno, priv->tx_free_mbx);
>>> +       spin_unlock_irqrestore(&priv->tx_lock, flags);
>> Hm, I wonder how the driver ensures that packages go out in order. How
>> does the CAN hardware schedule pending TX message objects? Vladislav
>> posted a test programs recently to check message ordering. See:
>>
>> https://lists.berlios.de/pipermail/socketcan-core/2009-August/002871.html
> 
> TI HECC hardware has mailbox priority field and higher mailbox number will transmit if two mailboxes have same priority level. But the code does not use that feature as yet. Let me think of how I can ensure out of order issue.

Have a look to the AT91 driver, it seems to be quite similar.

> [snip]
>>> +
>>> +       pending_pkts = hecc_read(priv, HECC_CANRMP);
>>> +       while (pending_pkts && (num_pkts < quota)) {
>>> +               mbxno = find_first_bit(&pending_pkts,
>> HECC_MAX_MAILBOXES);
>>
>> Here I also wonder if the messages are handled in the correct order.
> 
> No I have not taken care of that. Let me look into the pkt handling to see how I can do it based upon hardware capability.
> 
> [snip]
> 
>>> +
>>> +       ti_hecc_error(ndev, int_status, hecc_read(priv, HECC_CANES));
>> Hm, you create an error frame for each interrupt!? What do you see with:
>>
>> # candump any,0:0,#FFFFFFFF
>>
> Good catch. I did not observe unnecessary error frames via candump (or I really missed them). But I will correct this anyway.

I see. That's because the error code of can_id is 0 and the mask does
not trigger.

>>> +
>>> +       /* Handle Abort acknowledge interrupt */
>>> +       if (int_status & HECC_CANGIF_AAIF) {
>>> +               ack = hecc_read(priv, HECC_CANAA);
>>> +               while (ack) {
>>> +                       mbxno = find_first_bit(&ack, HECC_MAX_MAILBOXES);
>>> +                       if (mbxno == HECC_MAX_MAILBOXES) {
>>> +                               break;
>>> +                       } else {
>>> +                               clear_bit(mbxno, &ack);
>>> +                               /* release echo pkt & update counters */
>>> +                               hecc_set_bit(priv, HECC_CANAA, (1 <<
>> mbxno));
>>> +                               hecc_clear_bit(priv, HECC_CANME, (1 <<
>> mbxno));
>>> +                               /* FIXME: since net-next tree's dev.h
>> does not
>>> +                                * include can_free_echo_skb() doing
>> equivalent
>>> +                                * of can_free_echo_skb(ndev, mbxno);
>>> +                                */
>>> +                               if (priv->can.echo_skb[mbxno]) {
>>> +                                       kfree_skb(priv-
>>> can.echo_skb[mbxno]);
>>> +                                       priv->can.echo_skb[mbxno] = NULL;
>>> +                               }
>>> +                               if (netif_queue_stopped(ndev))
>>> +                                       netif_wake_queue(ndev);
>>> +                               spin_lock_irqsave(&priv->tx_lock, flags);
>>> +                               clear_bit(mbxno, priv->tx_free_mbx);
>>> +                               spin_unlock_irqrestore(&priv->tx_lock,
>> flags);
>>> +                       }
>>> +               }
>>> +       }
>> Can that interrupt happen? I have not found any code aborting messages.
> 
> It can happen only if a tx mailbox is told to abort. This interrupt is an ack for the same. I am not using the tx abort feature so will remove this.
> 
> [snip]
>>> +       }
>>> +
>>> +       /* Open common can device */
>>> +       err = open_candev(ndev);
>>> +       if (err) {
>>> +               dev_err(ndev->dev.parent, "open_candev() failed %08X\n",
>> err);
>>
>> free_irq?
> 
> Good catch. Will fix it.
> 
>>> +               return err;
>>> +       }
>>> +
>> Thanks for your contribution.
>>
>> Wolfgang.
>>
> 
> Appreciate the review. I will send v2 of patch. Not sure still if the original patch reached the socketcan mailing list due to size.

v2 will fit but I'm wondering who is moderating the ML. Oliver?

Wolfgang.

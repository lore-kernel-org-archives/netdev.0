From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [RFC] tulip: Support for byte queue limits
Date: Fri, 12 Jul 2013 09:31:08 -0700
Message-ID: <CAP6odjhsL8QPKwurP_H88M3kAoBW-z_jGHtEhL0Tj7AfZNutHA@mail.gmail.com>
References: <20130712132054.16269.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Grant Grundler <grundler@parisc-linux.org>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>
To: George Spelvin <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:62191 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964992Ab3GLQbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 12:31:09 -0400
Received: by mail-ob0-f179.google.com with SMTP id xk17so11562889obc.10
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 09:31:08 -0700 (PDT)
In-Reply-To: <20130712132054.16269.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 12, 2013 at 6:20 AM, George Spelvin <linux@horizon.com> wrote:
> The New Hotness of fq_codel wants bql support, but my WAN link is on my
> Old And Busted tulip card, which lacks it.
>
> It's just a few lines, but the important thing is knowing where to
> put them, and I've sort of guessed.  In particular, it seems like the
> netdev_sent_queue call could be almost anywhere in tulip_start_xmit and
> I'm not sure if there are reasons to prefer any particular position.

Hi George,
While you are right that functionally it doesn't matter, my preference
would be to have nothing between the wmb() and iowrite() that kicks
off the TX. This marginally helps kick off the TX process consistently
slightly sooner. On modern HW, probably irrelevant, but not on the HW
these chips are used on.

I don't have a clue about fq_codel and trust Eric thinks the change is good.

Lastly, given I haven't powered up a system in two years which has
tulip, any one want to take over maintainer for tulip driver?
It's basically obsolete with a few rare patches like this one coming in.

cheers,
grant

>
> (You may have my S-o-b on copyright grounds, but I'd like to test it
> some more before declaring this patch ready to be merged.)
>
>
> diff --git a/drivers/net/ethernet/dec/tulip/interrupt.c b/drivers/net/ethernet/dec/tulip/interrupt.c
> index 92306b3..d74426e 100644
> --- a/drivers/net/ethernet/dec/tulip/interrupt.c
> +++ b/drivers/net/ethernet/dec/tulip/interrupt.c
> @@ -532,6 +532,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
>  #endif
>         unsigned int work_count = tulip_max_interrupt_work;
>         unsigned int handled = 0;
> +       unsigned int bytes_compl = 0;
>
>         /* Let's see whether the interrupt really is for us */
>         csr5 = ioread32(ioaddr + CSR5);
> @@ -634,6 +635,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
>                                                  PCI_DMA_TODEVICE);
>
>                                 /* Free the original skb. */
> +                               bytes_compl += tp->tx_buffers[entry].skb->len;
>                                 dev_kfree_skb_irq(tp->tx_buffers[entry].skb);
>                                 tp->tx_buffers[entry].skb = NULL;
>                                 tp->tx_buffers[entry].mapping = 0;
> @@ -802,6 +804,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
>         }
>  #endif /* CONFIG_TULIP_NAPI */
>
> +       netdev_completed_queue(dev, tx, bytes_compl);
>         if ((missed = ioread32(ioaddr + CSR8) & 0x1ffff)) {
>                 dev->stats.rx_dropped += missed & 0x10000 ? 0x10000 : missed;
>         }
> diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
> index 1e9443d..b4249f3 100644
> --- a/drivers/net/ethernet/dec/tulip/tulip_core.c
> +++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
> @@ -703,6 +703,7 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
>         wmb();
>
>         tp->cur_tx++;
> +       netdev_sent_queue(dev, skb->len);
>
>         /* Trigger an immediate transmit demand. */
>         iowrite32(0, tp->base_addr + CSR1);
> @@ -746,6 +747,7 @@ static void tulip_clean_tx_ring(struct tulip_private *tp)
>                 tp->tx_buffers[entry].skb = NULL;
>                 tp->tx_buffers[entry].mapping = 0;
>         }
> +       netdev_reset_queue(tp->dev);
>  }
>
>  static void tulip_down (struct net_device *dev)

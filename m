From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: fealnx oopses
Date: Sat, 27 Mar 2004 00:14:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403270014.23088.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <200403262157.21624.vda@port.imtp.ilyichevsk.odessa.ua> <40648CAF.5010203@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andreas Henriksson <andreas@fjortis.info>, netdev@oss.sgi.com,
        romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40648CAF.5010203@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 26 March 2004 22:03, Jeff Garzik wrote:
> Denis Vlasenko wrote:
> > ------- Additional Comment #1 From Francois Romieu  2004-02-27 14:53
> > ------- Afaiks, np->{free_tx_count/really_tx_count} update in start_xmit
> > is not atomic wrt the irq handler and the irq handler updates these
> > variables as well. So we could have:
> > - start_xmit reads really_tx_count (first step to update
> > really_tx_count); - first tx irq takes place in and updates
> > really_tx_count
> > - start_xmit ends updating really_tx_count, ignoring the value set in the
> > irq handler
> > - second tx irq takes place and reads an erroneously high really_tx_count
> > value
> > - <censored>
> >
> > Nice explanation, but on x86 uniprocessor it can't happen.
>
> An irq in the middle of start_tx() can definitely happen on uniprocessor...

Yes. But on x86 a++ is atomic vs interrupts - it's a single instruction
and interrupts happen on instruction boundaries only.

Entire start_tx() is included below sig. Where it can race
against intr? I see no such place... do you?

In other words: patch is needed for SMP, but Andreas was bitten
by something else.

> Can you try the patch I just posted?

I can. The problem is, I cannot reproduce oops _without_ patch,
and this renders testing useless.
I will work on reproducing.
>
> 	Jeff
--
vda

static int start_tx(struct sk_buff *skb, struct net_device *dev)
{
        struct netdev_private *np = dev->priv;
        np->cur_tx_copy->skbuff = skb;
#define one_buffer
#define BPT 1022
#if defined(one_buffer)
        np->cur_tx_copy->buffer = pci_map_single(np->pci_dev, skb->data,
                skb->len, PCI_DMA_TODEVICE);
        np->cur_tx_copy->control = TXIC | TXLD | TXFD | CRCEnable | PADEnable;
        np->cur_tx_copy->control |= (skb->len << PKTSShift);    /* pkt size */
        np->cur_tx_copy->control |= (skb->len << TBSShift);     /* buffer size */
// 89/12/29 add,
        if (np->pci_dev->device == 0x891)
                np->cur_tx_copy->control |= ETIControl | RetryTxLC;
        np->cur_tx_copy->status = TXOWN;
        np->cur_tx_copy = np->cur_tx_copy->next_desc_logical;
        --np->free_tx_count;
#elif defined(two_buffer)
...dead code...
#endif
        if (np->free_tx_count < 2)
                netif_stop_queue(dev);
        ++np->really_tx_count;
        writel(0, dev->base_addr + TXPDR);
        dev->trans_start = jiffies;
        return 0;
}

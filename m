From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: fealnx oopses
Date: Fri, 26 Mar 2004 12:14:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: andreas@fjortis.info, Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
        Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'll appreciate any comments from netdev@oss.sgi.com readers.
Especially on "or else?? np->cur_rx->skbuff stays NULL..." part.

> From: Andreas Henriksson <andreas@fjortis.info>
> To: vda@port.imtp.ilyichevsk.odessa.ua
>
> I've had the same problem for some time (although I've been using 2.6).
>
> Try the attached patch.... it works reliably for me with it (except that
> the controller sometimes get reset because of "transmit timed out").
> I guess there isn't much changed in the driver between 2.4 and 2.6 so it
> will hopefully apply cleanly.
> I have opened a bug about this (which I've already marked "resolved"):
> http://bugzilla.kernel.org/show_bug.cgi?id=1902
> Also see http://fjortis.info/pub/panic/fealnx/ for verbose information
> about my quest to solve the problem ... :)
> Please try this out and report to me if it helps.... I've been thinking
> of submitting this for some time but I haven't found anyone who can help
> me test the patch....

Andreas,

You concluded that your oops happened in
	dev_kfree_skb_irq(np->cur_tx->skbuff);
because np->cur_tx->skbuff==NULL.
In my case I saw oops in
	skb_put(skb = np->cur_rx->skbuff, pkt_len);
because np->cur_rx->skbuff==NULL.
(I am 100% sure, I traced it to exact assembler instruction
and C source line)

Seems similar but not exactly the same.

Another similarity is that you saw two do_IRQ's in your
oops traces, just like me: http://lkml.org/lkml/2004/3/21/119
Looks like it indeed can be caused by race between
network stack trying to stuff more tx data into card
and interrupts from card.


Another thread of me tried to guess how cur_rx->skbuff
can end up being NULL.
Here we are in interrupt context, processing rx intr:
static int netdev_rx(struct net_device *dev)
...
we just received large packet, pass it to network stack:
                        } else {
                                skb_put(skb = np->cur_rx->skbuff, pkt_len);
                                np->cur_rx->skbuff = NULL;   <--------- set to NULL here
                                if (np->really_rx_count == RX_RING_SIZE)
                                        np->lack_rxbuf = np->cur_rx;
                                --np->really_rx_count;
                        }
                        skb->protocol = eth_type_trans(skb, dev);
                        netif_rx(skb);
                        dev->last_rx = jiffies;
                        np->stats.rx_packets++;
                        np->stats.rx_bytes += pkt_len;
                }
                if (np->cur_rx->skbuff == NULL) {
aha. need to allocate new rx buffer
                        struct sk_buff *skb;
                        skb = dev_alloc_skb(np->rx_buf_sz);
                        if (skb != NULL) {
                                skb->dev = dev; /* Mark as being used by this device. */
                                np->cur_rx->buffer = pci_map_single(np->pci_dev, skb->tail,
                                        np->rx_buf_sz, PCI_DMA_FROMDEVICE);
                                np->cur_rx->skbuff = skb;
                                ++np->really_rx_count;
                        }
or else?? np->cur_rx->skbuff stays NULL...
                }
                if (np->cur_rx->skbuff != NULL)
                        free_one_rx_descriptor(np);
this does np->cur_rx = np->cur_rx->next_desc_logical inside
bit ONLY if( !=NULL). This is the only place which can possibly
change ->cur_tx (I grepped entire driver). Will something change
cur_rx->skbuff later? lets see:
        }                       /* end of while loop */
        /*  allocate skb for rx buffers */
        allocate_rx_buffers(dev);
this function will try to allocate all remaining unallocated
rx buffers but may fail if low on memory, leaving cur_rx->skbuff == NULL!
        return 0;
}
end of handler. If next rx intr struck us right now, we will oops.
Am I right?

BTW, my box is indeed slow and low on RAM, this fits.


Regarding your patch: I looked in start_tx(). Apart from latent
bug in commented out part of code:
	next = (struct fealnx *) np->cur_tx_copy.next_desc_logical;
which must be
	next = (struct fealnx_desc *) np->cur_tx_copy->next_desc_logical;
I can't see anything racy there. The function just submits more
tx buffers for the card, it never touch cur_tx or cur_tx->skbuff...

If I miss something and it indeed races with interrupt, you
definitely need to add
        spin_lock(&np->lock);
...
        spin_unlock(&np->lock);
around interrupt handler body or at least around tx part
of it, or else your patch is incomplete (race will still
be possible on SMP).

Anyway, I applied your patch and flooded with UDP again.
My box did not oops. Unfortunately, it did not oops when
I reverted back to old, presumably buggy driver. I cannot
reproduce it anymore with old driver too! Bad. :(
--
vda

> --- old-fealnx.c	2004-03-23 12:43:21.000000000 +0100
> +++ fealnx.c	2004-03-23 12:44:17.000000000 +0100
> @@ -1311,6 +1311,9 @@ static void init_ring(struct net_device
>  static int start_tx(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct netdev_private *np = dev->priv;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&np->lock, flags);
>
>  	np->cur_tx_copy->skbuff = skb;
>
> @@ -1377,6 +1380,8 @@ static int start_tx(struct sk_buff *skb,
>  	writel(0, dev->base_addr + TXPDR);
>  	dev->trans_start = jiffies;
>
> +	spin_unlock_irqrestore(&np->lock, flags);
> +
>  	return 0;
>  }

From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: fealnx oopses
Date: Mon, 29 Mar 2004 23:49:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403292349.07070.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <20040329013834.B24996@electric-eye.fr.zoreil.com> <20040329170143.GA28822@scream.fjortis.info>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andreas Henriksson <andreas@fjortis.info>, Jeff Garzik <jgarzik@pobox.com>,
        netdev@oss.sgi.com,
        Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Henriksson <andreas@fjortis.info>,
        Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040329170143.GA28822@scream.fjortis.info>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[CCed myself to have nice thread view in Kmail]

> I tried this one:
> > It may be simpler/safer to turn (init_ring):
> >         np->lack_rxbuf = NULL;
> > into
> >         np->lack_rxbuf = np->rx_ring;
> >
> > I'll check the whole thing tomorrow. It's time to sleep now.
>
> And everything seems to work better then ever before.. :)
>
> I transfered 2 GB of data over my lan and didn't even get a single
> "transmit timed out" or anything.

I tested this. Does not oops. Drowns in 'too much work in interrupt'
and 0-order alloc failures instead. I cannot ctrl-C my netcat
in order to stop UDP flood. I shall be able to do it.

I revieved patched driver code a bit and have a couple of questions.
I'll post code chunks and then questions below. Code contains
my debugging additions, all flagged with '//vda' comments.
I did not come up with a new patch because I don't feel
stupid (brave?) enough to decide what to do with rx
when there is no buffers. I don't fully understand how
this stuff interacts with PCI bus and card's hardware
(how does rx packet data end up in RAM).

        struct fealnx_desc *cur_rx;
        struct fealnx_desc *lack_rxbuf;
please, lack_rx without 'buf'. Sometimes I grep for
'_rx->something'.

        np->cur_rx = &np->rx_ring[0];
        np->lack_rxbuf = np->rx_ring;
same value, differently expressed.

                /* for the last descriptor */
                next = np->cur_tx_copy.next_desc_logical;
this code is #ifdef'ed out, but this ^^^ is still a bug.
shall be '->'

Now, more serious stuff:

in intr_handler():
                if (--boguscnt < 0) {
                        printk(KERN_WARNING "%s: Too much work at interrupt, "
                               "status=0x%4.4x.\n", dev->name, intr_status);
                        break;
                }
Shall we do something with this condition?
What if card is simply go mad? Maybe card reset?


static int netdev_rx(struct net_device *dev)
{
        struct netdev_private *np = dev->priv;

        if( ! (!(np->cur_rx->status & RXOWN) && np->cur_rx->skbuff) ) { //vda:
                printk(KERN_ERR "netdev_rx(): nothing to do?! (np->cur_rx->status & RXOWN) == 0x%04x, np->cur_rx->skbuff == %p\n"
                        ,(np->cur_rx->status & RXOWN)
                        ,np->cur_rx->skbuff
                );
        }
I added this. If we trigger this, netdev_rx won't enter
while() loop and will do essentially nothing
except for trying to allocate_rx_buffers(dev).
I have a suspicion that device will trigger intr
again _for the same packet_.
Do we need some code to tell device to drop this packet?

I did trigger this right before 'too much work'
(RXOWN was set, ->skbuff was not NULL).
What does it mean? Card received a packet but _not_
into this buffer? How card decides into which buffer
to receive? Shall we check them all?


        if (np->really_rx_count == 0) { //vda:
                printk(KERN_ERR "netdev_rx(): np->really_rx_count is 0 before while()\n");
        }
did not trigger this, but if it happens, above comment
apply. There were no free rx buffers, yet we are in rx intr.
Time to cry out loud!

        /* If EOP is set on the next entry, it's a new packet. Send it up. */
        while (!(np->cur_rx->status & RXOWN) && np->cur_rx->skbuff) {
                s32 rx_status = np->cur_rx->status;
...


further in netdev_rx():
                        if (pkt_len < rx_copybreak &&
                            (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
                                skb->dev = dev;
                                skb_reserve(skb, 2);    /* 16 byte align the IP header */
16 *bit* align maybe?
                                /* Call copy + cksum if available. */

#if ! defined(__alpha__)
                                eth_copy_and_sum(skb,
                                        np->cur_rx->skbuff->tail, pkt_len, 0);
                                skb_put(skb, pkt_len);
#else
                                memcpy(skb_put(skb, pkt_len),
                                        np->cur_rx->skbuff->tail, pkt_len);
#endif
                        } else {
                                skb_put(skb = np->cur_rx->skbuff, pkt_len);
                                np->cur_rx->skbuff = NULL;
                                --np->really_rx_count;
                        }
                        skb->protocol = eth_type_trans(skb, dev);
                        netif_rx(skb);
                        dev->last_rx = jiffies;
                        np->stats.rx_packets++;
                        np->stats.rx_bytes += pkt_len;
                }

                np->cur_rx = np->cur_rx->next_desc_logical;
        }                       /* end of while loop */
if(pkt_len < rx_copybreak...) path is taken, skbuff is still usable
for next rx, no? Then why np->cur_rx = np->cur_rx->next_desc_logical?
--
vda

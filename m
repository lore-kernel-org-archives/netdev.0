From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: fealnx oopses
Date: Sat, 27 Mar 2004 23:28:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403272328.51291.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <20040326233514.B26347@electric-eye.fr.zoreil.com> <4064BB35.4050301@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andreas Henriksson <andreas@fjortis.info>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <4064BB35.4050301@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 27 March 2004 01:22, Jeff Garzik wrote:
> Francois Romieu wrote:
> > Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua> :
> > [...]
> >
> >>Yes. But on x86 a++ is atomic vs interrupts - it's a single instruction
> >>and interrupts happen on instruction boundaries only.
> >
> > Do you realize that you are saying that the CPU can atomically increment
> > an integer which sits _in memory_ ?
>
> Sure you can...
>
> But start_tx() has two variables free_tx_count and
> really_tx_count, and about six or seven places those are used.
>
> And this comment...
>
> > I can. The problem is, I cannot reproduce oops _without_ patch,
> > and this renders testing useless.
>
> Sounds like it fixes the problem, to me.
>
> 	Jeff

Okay I can reproduce it now. 16 Mb of RAM and underclock to 125 MHz
did the trick ;)

Sorry Jeff your patch does not fix my problem.
I also verified that it happens this way:
(1) rx skb is processed and freed
(2) allocation failure for new skb
(3) next rx intr occurs, cur_rx->skbuff still == NULL
(4) oops

I modified code as follows and I did see all these printk()s
in sequence:

                        } else {
                                if(np->cur_rx->skbuff == NULL)
(3)                                     printk(KERN_ERR "vda: np->cur_rx->skbuff == NULL!\n"); //vda
(4)                             skb_put(skb = np->cur_rx->skbuff, pkt_len);
(1)                             np->cur_rx->skbuff = NULL;
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
                        struct sk_buff *skb;

                        skb = dev_alloc_skb(np->rx_buf_sz);

                        if (skb != NULL) {
                                skb->dev = dev; /* Mark as being used by this device. */
                                np->cur_rx->buffer = pci_map_single(np->pci_dev, skb->tail,
                                        np->rx_buf_sz, PCI_DMA_FROMDEVICE);
                                np->cur_rx->skbuff = skb;
                                ++np->really_rx_count;
                        } else { //vda
(2)                             printk(KERN_ERR "vda: low on mem, cannot allocate skb!\n");
                        }
                }
--
vda

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: fealnx oopses
Date: Tue, 30 Mar 2004 00:20:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040330002047.D4744@electric-eye.fr.zoreil.com>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <20040329013834.B24996@electric-eye.fr.zoreil.com> <20040329170143.GA28822@scream.fjortis.info> <200403292349.07070.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Henriksson <andreas@fjortis.info>, Jeff Garzik <jgarzik@pobox.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200403292349.07070.vda@port.imtp.ilyichevsk.odessa.ua>; from vda@port.imtp.ilyichevsk.odessa.ua on Mon, Mar 29, 2004 at 11:49:06PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua> :
[...]
> in intr_handler():
>                 if (--boguscnt < 0) {
>                         printk(KERN_WARNING "%s: Too much work at interrupt, "
>                                "status=0x%4.4x.\n", dev->name, intr_status);
>                         break;
>                 }
> Shall we do something with this condition?
> What if card is simply go mad? Maybe card reset?

1 - Yes.
2 - disable the offending interruption/NAPI (reset is not needed)

[...]
> static int netdev_rx(struct net_device *dev)
> {
>         struct netdev_private *np = dev->priv;
> 
>         if( ! (!(np->cur_rx->status & RXOWN) && np->cur_rx->skbuff) ) { //vda:
>                 printk(KERN_ERR "netdev_rx(): nothing to do?! (np->cur_rx->status & RXOWN) == 0x%04x, np->cur_rx->skbuff == %p\n"
>                         ,(np->cur_rx->status & RXOWN)
>                         ,np->cur_rx->skbuff
>                 );
>         }
> I added this. If we trigger this, netdev_rx won't enter
> while() loop and will do essentially nothing
> except for trying to allocate_rx_buffers(dev).

It is supposed to mean that there is an unallocated buffer in the ring and
that the driver has simply wrapped to the point where it met it again.
So there is only one thing to do: try to allocate.

[...]
> I did trigger this right before 'too much work'
> (RXOWN was set, ->skbuff was not NULL).
> What does it mean? Card received a packet but _not_
> into this buffer? How card decides into which buffer
> to receive? Shall we check them all?

It probably means that several packets were processed during a previous
interruption so when this interruption is triggered, there's nothing to
do.

[...]
> further in netdev_rx():
>                         if (pkt_len < rx_copybreak &&
>                             (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
>                                 skb->dev = dev;
>                                 skb_reserve(skb, 2);    /* 16 byte align the IP header */
> 16 *bit* align maybe?

Classical typo. Don't change it :o)

[...]
>                 np->cur_rx = np->cur_rx->next_desc_logical;
>         }                       /* end of while loop */
> if(pkt_len < rx_copybreak...) path is taken, skbuff is still usable
> for next rx, no? Then why np->cur_rx = np->cur_rx->next_desc_logical?

Not for the next Rx: the whole ring will have to be processed first. The
sole difference when copybreak does not apply is that an allocation should
be performed for the relevant descriptor. The descriptor are set up in a
circular list and the asic walks this list. So whatever happens, the driver
must consider the next descriptor as current for the upcoming interruption.

--
Ueimor

From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: fealnx oopses
Date: Tue, 30 Mar 2004 00:50:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403300050.42367.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <200403292349.07070.vda@port.imtp.ilyichevsk.odessa.ua> <20040330002047.D4744@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andreas Henriksson <andreas@fjortis.info>, Jeff Garzik <jgarzik@pobox.com>,
        netdev@oss.sgi.com,
        Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040330002047.D4744@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I think bug can be considered fixed if I can start
netcat UDP flood, wait however long I want, then press
ctrl-C and get my bash prompt back. Local netcat
closes socket and exits, remote netcat gets its
icmp 'port unreachable' and exits too. Everybody's
happy.

Oopses are gone but it looks like box is so much interrupt
flooded that userspace has no chance of processing ctrl-C.
What can we do? I think driver can do something useful
whet it detects 'too much work in interrupt'. Disabling rx
for several ms seems like 'quick and dirty' way.

Francois what do you think? Can you code something up
for me to test?

On Tuesday 30 March 2004 00:20, Francois Romieu wrote:
> Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>:
> [...]
>
> > in intr_handler():
> >                 if (--boguscnt < 0) {
> >                         printk(KERN_WARNING "%s: Too much work at
> > interrupt, " "status=0x%4.4x.\n", dev->name, intr_status); break;
> >                 }
> > Shall we do something with this condition?
> > What if card is simply go mad? Maybe card reset?
>
> 1 - Yes.
> 2 - disable the offending interruption/NAPI (reset is not needed)

Imagine that hardware got stuck with intr constantly asserted.
Reset can cure that. In any event, it might give us a needed
pause of several ms, just what I want.

If you worry about lost packets, that's not a concern -
if we reached this, we are dropping tons of them already.

> [...]
>
> > static int netdev_rx(struct net_device *dev)
> > {
> >         struct netdev_private *np = dev->priv;
> >
> >         if( ! (!(np->cur_rx->status & RXOWN) && np->cur_rx->skbuff) ) {
> > //vda: printk(KERN_ERR "netdev_rx(): nothing to do?! (np->cur_rx->status
> > & RXOWN) == 0x%04x, np->cur_rx->skbuff == %p\n" ,(np->cur_rx->status &
> > RXOWN)
> >                         ,np->cur_rx->skbuff
> >                 );
> >         }
> > I added this. If we trigger this, netdev_rx won't enter
> > while() loop and will do essentially nothing
> > except for trying to allocate_rx_buffers(dev).
>
> It is supposed to mean that there is an unallocated buffer in the ring and
> that the driver has simply wrapped to the point where it met it again.
> So there is only one thing to do: try to allocate.

Hm, but why we got rx intr at all? Card couldn't receive packet into
non-allocated buffer, right?

> [...]
>
> > I did trigger this right before 'too much work'
> > (RXOWN was set, ->skbuff was not NULL).
> > What does it mean? Card received a packet but _not_
> > into this buffer? How card decides into which buffer
> > to receive? Shall we check them all?
>
> It probably means that several packets were processed during a previous
> interruption so when this interruption is triggered, there's nothing to
> do.

Aha, card didn't know that and prods CPU again. I got it.

> [...]
>
> >                 np->cur_rx = np->cur_rx->next_desc_logical;
> >         }                       /* end of while loop */
> > if(pkt_len < rx_copybreak...) path is taken, skbuff is still usable
> > for next rx, no? Then why np->cur_rx = np->cur_rx->next_desc_logical?
>
> Not for the next Rx: the whole ring will have to be processed first. The
> sole difference when copybreak does not apply is that an allocation should
> be performed for the relevant descriptor. The descriptor are set up in a
> circular list and the asic walks this list. So whatever happens, the driver
> must consider the next descriptor as current for the upcoming interruption.

/me feels enlightened
--
vda

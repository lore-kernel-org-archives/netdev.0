From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: fealnx oopses
Date: Mon, 29 Mar 2004 01:38:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329013834.B24996@electric-eye.fr.zoreil.com>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <200403272328.51291.vda@port.imtp.ilyichevsk.odessa.ua> <20040328005533.A6117@electric-eye.fr.zoreil.com> <200403282219.56799.vda@port.imtp.ilyichevsk.odessa.ua> <20040328232707.GA17524@scream.fjortis.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
        Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Henriksson <andreas@fjortis.info>
Content-Disposition: inline
In-Reply-To: <20040328232707.GA17524@scream.fjortis.info>; from andreas@fjortis.info on Mon, Mar 29, 2004 at 01:27:07AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andreas Henriksson <andreas@fjortis.info> :
[...]
> > --- fealnx.c.orig	Fri Nov 28 20:26:20 2003
> > +++ fealnx.c	Sun Mar 28 21:32:56 2004
> > @@ -1134,15 +1134,17 @@
> >  		struct sk_buff *skb;
> >  
> >  		skb = dev_alloc_skb(np->rx_buf_sz);
> > -		np->lack_rxbuf->skbuff = skb;
> > -
> >  		if (skb == NULL)
> >  			break;	/* Better luck next round. */
> >  
> 
> np->lack_rxbuf == NULL here....
> 
> (verified by inserting a "BUG_ON(np->lack_rxbuf==NULL);"...)

Oops, I forgot to initialize np->lack_rxbuf correctly.

If you have some time to spend, you can change in netdev_rx:
                                pci_unmap_single(np->pci_dev,
                                                 np->cur_rx->buffer,
                                                 np->rx_buf_sz,
                                                 PCI_DMA_FROMDEVICE);
                                skb_put(skb = np->cur_rx->skbuff, pkt_len);
                                np->cur_rx->skbuff = NULL;
                                --np->really_rx_count;
into:
                                pci_unmap_single(np->pci_dev,
                                                 np->cur_rx->buffer,
                                                 np->rx_buf_sz,
                                                 PCI_DMA_FROMDEVICE);
                                skb_put(skb = np->cur_rx->skbuff, pkt_len);
                                np->cur_rx->skbuff = NULL;
				if (!np->lack_rxbuf)                 <<<
					np->lack_rxbuf = np->cur_rx; <<<
                                np->cur_rx->skbuff = NULL;
                                --np->really_rx_count;

It may be simpler/safer to turn (init_ring):
        np->lack_rxbuf = NULL;
into
        np->lack_rxbuf = np->rx_ring;

I'll check the whole thing tomorrow. It's time to sleep now.

Thanks for your report.

--
Ueimor

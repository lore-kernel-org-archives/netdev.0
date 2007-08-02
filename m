From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net driver error accounting
Date: Thu, 2 Aug 2007 13:45:34 -0700
Message-ID: <20070802134534.ec33042a.akpm@linux-foundation.org>
References: <20070802131718.84543097.akpm@linux-foundation.org>
	<46B240B1.9080003@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Natalie Protasevich <protasnb@gmail.com>,
	Tim Hockin <thockin@hockin.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51745 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760269AbXHBUpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 16:45:55 -0400
In-Reply-To: <46B240B1.9080003@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 02 Aug 2007 16:38:09 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Andrew Morton wrote:
> > Looking at http://bugzilla.kernel.org/show_bug.cgi?id=8106
> > 
> > Guys, could we please have a ruling here?
> > 
> > When a net driver encounters a tx_fifo_error, should this also contribute
> > to the tx_error count, or should it not?
> 
> For each TX error, (a) tx_error is incremented and (b) a more-specific 
> TX error stat is also potentially incremented.  So, yes, tx_error 
> accumulates.
> 
> See cp_tx() in 8139cp.
> 
> 
> > More generally, should netdev drivers accumulate all the detailed
> > rx_errors into net_device_stats.rx_errors in real time, or should they not?
> 
> For each RX error, (a) rx_error is incremented and (b) a more-specific 
> RX error stat is also potentially incremented.  So, yes, rx_error 
> accumulates.
> 
> See cp_rx_err_acct() in 8139cp.
> 

OK, thanks.

One does wonder why the overall rx_error exists all all, but whatever.  The
main thing is to get all the net drivers doing the same thing.


So I guess bug 8106 wants something like this?


diff -puN drivers/net/natsemi.c~a drivers/net/natsemi.c
--- a/drivers/net/natsemi.c~a
+++ a/drivers/net/natsemi.c
@@ -2438,13 +2438,16 @@ static void netdev_error(struct net_devi
 				dev->name);
 		}
 		np->stats.rx_fifo_errors++;
+		np->stats.rx_errors++;
 	}
 	/* Hmmmmm, it's not clear how to recover from PCI faults. */
 	if (intr_status & IntrPCIErr) {
 		printk(KERN_NOTICE "%s: PCI error %#08x\n", dev->name,
 			intr_status & IntrPCIErr);
 		np->stats.tx_fifo_errors++;
+		np->stats.tx_errors++;
 		np->stats.rx_fifo_errors++;
+		np->stats.rx_errors++;
 	}
 	spin_unlock(&np->lock);
 }
_


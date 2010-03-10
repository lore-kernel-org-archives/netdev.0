From: David Howells <dhowells@redhat.com>
Subject: Re: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Wed, 10 Mar 2010 17:19:30 +0000
Message-ID: <31550.1268241570@redhat.com>
References: <31355.1268240990@redhat.com> <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com>
Cc: dhowells@redhat.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Eilon Greenstein <eilong@broadcom.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58727 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932520Ab0CJRTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 12:19:37 -0500
In-Reply-To: <31355.1268240990@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> > -	barrier(); /* Tell compiler that prod and cons can change */
> > +	/* prod and cons can change on other cpu, want to see
> > +	   consistend available space and queue (stop/running) state */
> > +	smp_mb();
> > +
> >  	prod = fp->tx_bd_prod;
> >  	cons = fp->tx_bd_cons;
> 
> I suspect that this isn't what you want.
> 
> The barrier() didn't tell the compiler that fp->tx_bd_prod and fp->tx_bd_cons
> could change.  What it did was to say that the accesses to those two variables
> must be performed after all the other accesses issued by that CPU prior to the
> barrier - at least as far as the compiler is concerned.
> 
> You don't need to separate the reads of tx_bd_prod and tx_bd_cons above with a
> memory barrier.  They aren't ever altered in the same place.

Having said that, you might need a memory barrier before reading tx_bd_prod in
the consumer if the producer waggles a flag in memory to indicate to the
consumer that it should consume, and a memory barrier in the producer before
waggling that flag:

	[producer]
	...
	smp_wmb(); /* commit buffer contents before incrementing index */
	fp->tx_bd_prod = TX_BD(bd_prod + 1);
	smp_wmb(); /* commit increment index before prodding consumer */
	prod_consumer();

	[consumer]
	check_prod_flag();
	smp_rmb(); /* read producer index after checking prod flag */
	bd_prod = fp->tx_bd_prod;
	bd_cons = fp->tx_bd_cons;
	smp_read_barrier_depends(); /* read index before reading contents */

David

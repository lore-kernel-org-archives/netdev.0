From: David Howells <dhowells@redhat.com>
Subject: Re: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Wed, 10 Mar 2010 17:09:50 +0000
Message-ID: <31355.1268240990@redhat.com>
References: <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com>
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43749 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932478Ab0CJRJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 12:09:57 -0500
In-Reply-To: <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw Gruszka <sgruszka@redhat.com> wrote:

> -	barrier(); /* Tell compiler that prod and cons can change */
> +	/* prod and cons can change on other cpu, want to see
> +	   consistend available space and queue (stop/running) state */
> +	smp_mb();
> +
>  	prod = fp->tx_bd_prod;
>  	cons = fp->tx_bd_cons;

I suspect that this isn't what you want.

The barrier() didn't tell the compiler that fp->tx_bd_prod and fp->tx_bd_cons
could change.  What it did was to say that the accesses to those two variables
must be performed after all the other accesses issued by that CPU prior to the
barrier - at least as far as the compiler is concerned.

You don't need to separate the reads of tx_bd_prod and tx_bd_cons above with a
memory barrier.  They aren't ever altered in the same place.


What you want is something more like the following pseudocode.

To insert into a circular buffer:

	bd_prod = fp->tx_bd_prod;
	bd_cons = fp->tx_bd_cons;

	if (CIRC_SPACE(bd_cons, bd_prod, NUM_TX_BD) <= 0)
		goto no_space;

	/* get a tx_buf and first BD */
	tx_start_bd = &fp->tx_desc_ring[bd_prod].start_bd;
	tx_start_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_START_BD;
	tx_start_bd->general_data = (UNICAST_ADDRESS <<
				     ETH_TX_START_BD_ETH_ADDR_TYPE_SHIFT);
	tx_start_bd->general_data |= (1 << ETH_TX_START_BD_HDR_NBDS_SHIFT);

	smp_wmb(); /* commit buffer contents before incrementing index */

	fp->tx_bd_prod = TX_BD(bd_prod + 1);

To read from a circular buffer:

	bd_prod = fp->tx_bd_prod;
	bd_cons = fp->tx_bd_cons;

	smp_read_barrier_depends(); /* read index before reading contents */

	if (CIRC_CNT(bd_cons, bd_prod, NUM_TX_BD) <= 0)
		goto no_data;

	tx_start_bd = &fp->tx_desc_ring[bd_cons].start_bd;
	munge_descriptor(tx_start_bd);

	smp_mb(); /* finish reading descriptor before incrementing index */

	fp->tx_bd_cons = TX_BD(bd_cons + 1);

At least, I'm fairly certain that's correct.

David

From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ixgbevf: potential NULL dereference on allocation
 failure
Date: Fri, 10 Sep 2010 13:21:37 -0700 (PDT)
Message-ID: <20100910.132137.212394088.davem@davemloft.net>
References: <20100910115234.GB5959@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39914
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753036Ab0IJUVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 16:21:19 -0400
In-Reply-To: <20100910115234.GB5959@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Fri, 10 Sep 2010 13:52:34 +0200

> If "rx_ring" is NULL then it will oops when we try:
> 
> 	memcpy(rx_ring, adapter->rx_ring,
> 		adapter->num_rx_queues * sizeof(struct ixgbevf_ring));
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> To be honest, I'm not sure why the check for need_tx_update is there.
> This change has only been compile tested.

It's trying to optimize out the "down/up" of the device, which needs
to be done if we allocated a new TX ring.

It also adjusts the semantics of the error return,  in that if the
TX ring re-sizing went OK but the RX resizing failed, it returns
success.

That's kind of crummy semantics, if any part fails we should unwind
and return an error.  So just do the necessary memory allocations
first, and don't make any changes unless they all succeed.

This code also seems to be incredibly racy.  It allocates the new RING
structure, and copies the existing entries over.  Meanwhile the chip
is still running and we're potentially processing these same ring
entries, so by the time we actually assign adapter->{rx,tx}_ring
pointers the contents could have changed.

Probably the simplest thing to do is to structure this such that the
chip is quiesced around the entire ring set operation, so something
like:

	tx_ring = kcalloc();
	if (!tx_ring)
		goto do_err;
	rx_ring = kcalloc();
	if (!rx_ring)
		goto rx_ring_free_err;

	ixgbevf_down(adapter);

	err = setup_tx_ring(adapter, tx_ring);
	if (err)
		goto device_up_err;
	err = setup_rx_ring(adapter, rx_ring);
	if (err)
		goto device_up_err;

	ixgbevf_up(adapter);

	return 0;

device_up_err:
	tear_down_tx_ring(adapter, tx_ring);
	tear_down_rx_ring(adapter, rx_ring);
	kfree(tx_ring);
rx_ring_free_err:
	kfree(rx_ring);
do_err:
	return err;

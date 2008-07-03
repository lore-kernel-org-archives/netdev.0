From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 24/39]: netdev: Allocate multiple queues for TX.
Date: Thu, 03 Jul 2008 02:58:50 -0700 (PDT)
Message-ID: <20080703.025850.265931489.davem@davemloft.net>
References: <20080703.000436.77009639.davem@davemloft.net>
	<OF4D241345.95F11555-ON6525747B.002760BE-6525747B.00360059@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, Matheos.Worku@Sun.COM,
	mchan@broadcom.com, netdev@vger.kernel.org,
	vinay@linux.vnet.ibm.com
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36819
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752960AbYGCNCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 09:02:25 -0400
In-Reply-To: <OF4D241345.95F11555-ON6525747B.002760BE-6525747B.00360059@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Thu, 3 Jul 2008 15:19:50 +0530

> 1. Some netdev_queue variables are called dev_queue and others are
>    called txq. Is it to signify difference between functions that are
>    single queue vs multiqueue? Can it be made consistent to use txq
>    instead since everything is a transmit queue?

My mind is between two places as I write this code, that is
the answer :-)

I want to somehow apply these interfaces to receive.  But
as it stands now, the variable name inconsistency is stupid
and I will fix that.

To get an idea of what I might do later, consider how perhaps we could
have multiple RX queues hung off of struct net_device too.  We could
embed a napi_struct in there, for example.  And such a napi_struct
member would be in a union to share space with TX specific items such
as the _xmit_lock and xmit_lock_owner fields.

> 2. netif_queue_stopped and netif_subqueue_stopped can be both made to
>    call netif_tx_queue_stopped to make them look consistent. Then you
>    can delete __netif_subqueue_stopped(). However, I haven't looked if
>    any other user of this function is there or not (due to download
>    issue).

Sure.

> 3. Since many functions iterate over the list of tx-queues, you could
>    optimize all those functions (saving a few cycles per loop), eg:

I don't want to expose the implementation of the TX queue
layout to anything outside of alloc_netdev(), free_netdev(),
and the two accessor routines netdev_get_tx_queue() and
netdev_for_each_tx_queue().

If we start doing optimizations like this, it's going to be
so painful to audit any further changes in representation.

And all of this stuff is in slow paths.  The hot paths
only touch one queue.

> And since there are many functions doing:
>       for (i = 0; i < dev->num_tx_queues; i++) {
>             struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
> 
> this can be changed to:
>       list_for_each_txq(...)?

It's not a list, it's an array.  And like I said I don't want to
expose the representation.

There are two accessors, and they are enough.

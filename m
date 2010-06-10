From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [PATCH] ucc_geth: fix for RX skb buffers recycling
Date: Wed, 09 Jun 2010 18:02:40 -0700 (PDT)
Message-ID: <20100609.180240.59675642.davem@davemloft.net>
References: <1275935894-30483-1-git-send-email-geomatsi@gmail.com>
	<1275935894-30483-2-git-send-email-geomatsi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leoli@freescale.com,
	avorontsov@ru.mvista.com
To: geomatsi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56207
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754869Ab0FJBC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 21:02:29 -0400
In-Reply-To: <1275935894-30483-2-git-send-email-geomatsi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Matyukevich <geomatsi@gmail.com>
Date: Mon,  7 Jun 2010 22:38:14 +0400

> This patch implements a proper recycling of skb buffers belonging to RX error
> path. The suggested fix actually follows the recycling scheme implemented for
> TX skb buffers in the same driver (see 'ucc_geth_tx' function): skb buffers
> are checked by 'skb_recycle_check' function and deleted if can't be recycled.
> 
> This problem in recycling of skb buffers was discovered by accident in a setup
> when ethernet interface on one link end was full-duplex while another was
> half-duplex. In this case numerous corrupted frames were received by
> full-duplex interface due to late collisions. RX skb buffers with error
> frames were not properly recycled, that is why overflow occured from time to
> time on the next use of those buffers. Here is example of crush dump:

The lack of skb_recycle_check() is not the true cause of this bug.
You should never, ever, need to make skb_recycle_check() tests on
packets in this situation.  Once the skb pointers are properly adjusted
it will have sufficient room.

And that points to what the real problem is, the problem is the
skb->data assignment.  It's trying to get the SKB data pointers back
into the same state they are in when dev_alloc_skb() returns a packet
buffer.

But this assignment isn't accomplishing that, in fact it's corrupting
the SKB because after adjusting skb->data, skb->tail and skb->len will
become incorrect.  And this is what you need to fix.

That's why you get the skb_put() over panics, not because you lack
a skb_recycle_check() call here.

In fact, what your patch makes happen is that the error packets will
never get recycled.  The skb_recycle_check() will always fail.

Please fix this bug properly by correctly restoring the SKB pointers
and lengths to their initial state, then you can retain the
unconditional queueing of the error packet onto the recycle list.

Once you do that, all of the checks done by skb_recycle_check() are
superfluous and will always pass, and we know this.  The buffer is
not fragmented, there aren't any clones or external references to it,
and once you fix up the data pointers properly it will have enough
room as necessary for the RX buffer size the driver is currently using.

There are numerous helper routines in linux/skbuff.h that can be used
to do this properly, which will adjust a pointer and make the
corresponding adjustment to skb->len as well when necessary.

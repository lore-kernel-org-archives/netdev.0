From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] Re-check for a VIO_DESC_READY data
 descriptor after short udelay()
Date: Thu, 04 Sep 2014 22:36:48 -0700 (PDT)
Message-ID: <20140904.223648.559995846094457545.davem@davemloft.net>
References: <20140902162029.GC31516@oracle.com>
	<5405EFE7.4090302@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbaIEFgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 01:36:49 -0400
In-Reply-To: <5405EFE7.4090302@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Tue, 02 Sep 2014 12:27:19 -0400

> 	That fix may make this one moot. Maybe not, but certainly there is
> an unnecessary delay in notifying the peer because of that bug. The fix is
> simply to move the "wmb()" after, instead of before, setting VIO_DESC_READY.
> I mentioned it in our stand-up last week, which you couldn't attend, because
> I pointed it out for the VDC driver, which also has the same problem.

The memory barrier exists in order to make sure the cookies et al. are
globally visible before the VIO_DESC_READY.  We don't want stores to
be reordered such that the VIO_DESC_READY is seen too early.

I'm having a hard time imagining that putting the wmb() afterwards
would help, except by adding a new delay in a different place.

I say that because the TX trigger is going to make a hypervisor call,
and I bet that hypervisor trap syncs the store buffer of invoking cpu
thread.

Thinking further, another issue to consider is that the wmb() might no
be necessary considering all of the above, because the remote entity
should not look at this descriptor until the tx trigger occurs.

Anyways, if the hypervisor trap to signal the tx trigger does not
flush the local cpu thread's store buffer, then yes moving the memory
barrier might make sense.

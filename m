From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: bookkeep number of queues in our own
 module
Date: Sun, 22 Jun 2014 00:13:55 -0700 (PDT)
Message-ID: <20140622.001355.624567316306796984.davem@davemloft.net>
References: <1403100558-12866-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	boris.ostrovsky@oracle.com, ian.campbell@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbaFVHN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 03:13:58 -0400
In-Reply-To: <1403100558-12866-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Wed, 18 Jun 2014 15:09:18 +0100

> The original code uses netdev->real_num_tx_queues to bookkeep number of
> queues and invokes netif_set_real_num_tx_queues to set the number of
> queues. However, netif_set_real_num_tx_queues doesn't allow
> real_num_tx_queues to be smaller than 1, which means setting the number
> to 0 will not work and real_num_tx_queues is untouched.
> 
> This is bogus when xenvif_free is invoked before any number of queues is
> allocated. That function needs to iterate through all queues to free
> resources. Using the wrong number of queues results in NULL pointer
> dereference.
> 
> So we bookkeep the number of queues in xen-netback to solve this
> problem. The usage of real_num_tx_queues in core driver is to cap queue
> index to a valid value. In start_xmit we've already guarded against out
> of range queue index so we should be fine.
> 
> This fixes a regression introduced by multiqueue patchset in 3.16-rc1.
> 
> Reported-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

I say you should have a select queue method at all.

You're essentially providing a half-assed version of __netdev_pick_tx()
except that:

1) You're _completely_ ignoring the socket hash, if any.

2) You're not allowing XPS to work, _at all_.

I think you need to serious reevaluate providing any select queue
method at all, just let netdev_pick_tx() do all the work.

If you have some issue maintaining the release of queue resources,
maintain that privately and keep those details in the queue resource
allocation and freeing code _only_.  Don't make it an issue that
interferes at all with the normal mechanisms for SKB tx queue
selection.

Thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: fix use after free race in send path when
 dev is released
Date: Tue, 19 Nov 2013 20:34:51 -0500 (EST)
Message-ID: <20131119.203451.358808893783927503.davem@davemloft.net>
References: <1384902503-1588-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, noureddine@aristanetworks.com,
	greearb@candelatech.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707Ab3KTBez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 20:34:55 -0500
In-Reply-To: <1384902503-1588-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 20 Nov 2013 00:08:23 +0100

> To avoid reverting 827d9780 entirely, we could make use of po->running
> member that gets reset when we're calling __unregister_prot_hook() in
> packet_notifier() when we receive NETDEV_DOWN or NETDEV_UNREGISTER
> notification. Plus, we still need to hold ref to the netdev, so
> that we can assure it won't be released while we're in send path.

The avoidance of the atomic ref counting of the network device is the
main performance gain we get from that commit.

Now we'll be doing the refcount _and_ taking a spinlock, it'll be
worse than beforehand.

And this is doubly silly because we already have a reference
when we install the device into po->prot_hook.dev

I bet you can fix this by just deferring the NETDEV_UNREGISTER
AF_PACKET notifier work to RCU.

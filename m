From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] net: remove erroneous sk null assignment in timestamping
Date: Fri, 07 Oct 2011 19:47:24 +0200
Message-ID: <1318009644.3988.33.camel@jlt3.sipsolutions.net>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
	 <20111007.133356.489094996618032061.davem@davemloft.net>
	 <1318009222.3988.28.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:56879 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755607Ab1JGRr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 13:47:26 -0400
In-Reply-To: <1318009222.3988.28.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-10-07 at 19:40 +0200, Johannes Berg wrote:

> > It looks like skb_clone_tx_timestamp() sets clone->sk without any
> > proper refcounting, so I bet this NULL'ing it out is working
> > around that bug.
> 
> You're right. But this bug can actually trigger another way: The only
> user of this is dp83640_txtstamp() which might do kfree_skb() on this
> skb, in which case that'll likely crash trying to clean up the sk.

Not only that -- I don't even see what causes the socket to not go away
while we're waiting for the ts_work that dp83640_txtstamp() fires off to
run.

And actually, no, this is all wrong. It shouldn't kick off ts_work
anyway, ts_work only handles *RX* timestamps, never *TX*. The *TX*
timestamps are handled by decode_txts() which is called when we receive
a TXTS frame from the device... *that* dequeues the skb from tx_queue
there.

I'm afraid as is this is terminally broken. I don't have a device with a
dp83640 PHY, but I bet you can cause kernel crashes by doing something
like

while (1)
	fd = open()
	enable tx timestamping on fd;
	send(fd, frame)
	close(fd);

I don't even think any of this is privileged.

johannes

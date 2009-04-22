From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Software receive packet steering
Date: Wed, 22 Apr 2009 02:21:20 -0700 (PDT)
Message-ID: <20090422.022120.211323498.davem@davemloft.net>
References: <49ED967B.4070105@cosmosbay.com>
	<20090421084636.198b181e@nehalam>
	<65634d660904211152l6c17aa6dpf7e626474acfe499@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dada1@cosmosbay.com, andi@firstfloor.org,
	netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42699
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751947AbZDVJV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 05:21:28 -0400
In-Reply-To: <65634d660904211152l6c17aa6dpf7e626474acfe499@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 21 Apr 2009 11:52:07 -0700

> That is possible and don't think the design of our patch would
> preclude it, but I am worried that each time the mapping from a
> connection to a CPU changes this could cause of out of order
> packets.  I suppose this is similar problem to changing the RSS hash
> mappings in a device.

Yes, out of order packet processing is a serious issue.

There are some things I've been brainstorming about.

One thought I keep coming back to is the hack the block layer
is using right now.  It remembers which CPU a block I/O request
comes in on, and it makes sure the completion runs on that
cpu too.

We could remember the cpu that the last socket level operation
occurred upon, and use that as a target for packets.  This requires a
bit of work.

First we'd need some kind of pre-demux at netif_receive_skb()
time to look up the cpu target, and reference this blob from
the socket somehow, and keep it uptodate at various specific
locations (read/write/poll, whatever...).

Or we could pre-demux the real socket.  That could be exciting.

But then we come back to the cpu number changing issue.  There is a
cool way to handle this, because it seems that we can just keep
queueing to the previous cpu and it can check the socket cpu cookie.
If that changes, the old target can push the rest of it's queue to
that cpu and then update the cpu target blob.

Anyways, just some ideas.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: Increase default copybreak limits to 2k
Date: Sun, 24 Oct 2010 15:40:23 -0700 (PDT)
Message-ID: <20101024.154023.70195854.davem@davemloft.net>
References: <20101021143753.GA5567@linux.vnet.ibm.com>
	<20101021.074525.71113963.davem@davemloft.net>
	<20101021151746.GB5567@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rcj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752882Ab0JXWkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 18:40:00 -0400
In-Reply-To: <20101021151746.GB5567@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Jennings <rcj@linux.vnet.ibm.com>
Date: Thu, 21 Oct 2010 10:17:46 -0500

> The value of copybreak is the point where we stop using the bounce
> buffer and start to copy data to new buffers; having the overhead of
> additional TCE entry setup/teardown.  For the default MTU of 1500,
> increasing the copybreak value to 2k will result in all packets using
> the bounce buffer now.  Expanding the use of the bounce buffer up to 2k
> with the default MTU resulted in ~10% throughput improvement.

On the RX side the copybreak serves another purpose.

First of all, when you RX a < ~128 byte frame, you incur the cost
mostly of the cache miss to touch the packet headers.  The extra
allocated SKB and the copy are close to free.

But more importantly, if you always pass the RX descriptor SKB
into the network stack, even for tiny frames, the skb->truesize
(which is what gets charged to the socket) is larger than we
want it to be.

For a 128 byte frame, the socket gets charged the full MTU packet
size.  Because that is how much memory it is really using.

This is what the RX side copybreak is dealing with and you
therefore cannot remove it so trivially.

I am not applying this patch.

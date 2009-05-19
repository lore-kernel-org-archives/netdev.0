From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] virtio: orphan skbs if we're relying on timer to free
 them
Date: Mon, 18 May 2009 19:40:13 -0700 (PDT)
Message-ID: <20090518.194013.109631461.davem@davemloft.net>
References: <200905182218.47975.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34792
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753004AbZESCkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 22:40:16 -0400
In-Reply-To: <200905182218.47975.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 18 May 2009 22:18:47 +0930

> We check for finished xmit skbs on every xmit, or on a timer (unless
> the host promises to force an interrupt when the xmit ring is empty).
> This can penalize userspace tasks which fill their sockbuf.  Not much
> difference with TSO, but measurable with large numbers of packets.
> 
> There are a finite number of packets which can be in the transmission
> queue.  We could fire the timer more than every 100ms, but that would
> just hurt performance for a corner case.  This seems neatest.
 ...
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

If this is so great for virtio it would also be a great idea
universally, but we don't do it.

What you're doing by orphan'ing is creating a situation where a single
UDP socket can loop doing sends and monopolize the TX queue of a
device.  The only control we have over a sender for fairness in
datagram protocols is that send buffer allocation.

I'm guilty of doing this too in the NIU driver, also because there I
lack a "TX queue empty" interrupt and this can keep TCP sockets from
getting stuck.

I think we need a generic solution to this issue because it is getting
quite common to see cases where the packets in the TX queue of a
device can sit there indefinitely.

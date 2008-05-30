From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core/sock.c remove extra wakeup
Date: Fri, 30 May 2008 02:52:54 -0700 (PDT)
Message-ID: <20080530.025254.99938262.davem@davemloft.net>
References: <483E80AB020000C70003891C@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: GHaskins@novell.com, netdev@vger.kernel.org
To: pmullaney@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46468
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756599AbYE3Jw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 05:52:58 -0400
In-Reply-To: <483E80AB020000C70003891C@lucius.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Patrick Mullaney" <pmullaney@novell.com>
Date: Thu, 29 May 2008 10:08:43 -0600

> We have noticed an extra wakeup of a task waiting on a udp receive
> while testing with CONFIG_PREEMPT_RT. The following patch
> eliminates the source of the extra wakeup by only waking a task
> if it is waiting on the writable condition(the SOCK_NOSPACE
> bit has been set). The patch is against 2.6.25.
> 
> Signed-off-by: Patrick Mullaney <pmullaney@novell.com>

This looks Ok on the surface, but I'm really worried about
races.

If you clear that bit, another thread which set that bit
and already checked the socket space, might sleep and never
wake up.

I think that is fundamentally why we don't try to optimize
this in that way.

And why is this so expensive?  Once the first wakeup occurs,
the subsequent attemps will merely see that the wait queue
is empty and do nothing.

The only cost is the read lock on the callback lock, and that
is about as expensive as this new atomic operation you are
adding to clear the SOCK_NOSPACE bit.

So the benefit is not clear, and neither is the correctness of
this change.

Sorry.

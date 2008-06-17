From: David Miller <davem@davemloft.net>
Subject: Re: Killing sk->sk_callback_lock
Date: Mon, 16 Jun 2008 21:56:32 -0700 (PDT)
Message-ID: <20080616.215632.119969915.davem@davemloft.net>
References: <4856C12F020000C700039679@lucius.provo.novell.com>
	<20080616.185328.85842051.davem@davemloft.net>
	<4856FEC9.BA47.005A.0@novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: PMullaney@novell.com, herbert@gondor.apana.org.au,
	chuck.lever@oracle.com, netdev@vger.kernel.org
To: ghaskins@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49095
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751482AbYFQE4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 00:56:32 -0400
In-Reply-To: <4856FEC9.BA47.005A.0@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Gregory Haskins" <ghaskins@novell.com>
Date: Mon, 16 Jun 2008 22:01:13 -0600

> This seemed odd to us, so we investigated further to see if an
> improvement was lurking or whether this was expected.  We traced
> back the source of each wakeup to be coming from 1) the wmem/nospace
> code, and 2) from the rx-wakeup code from the softirq.  First the
> softirq would process the tx-completions which would wake_up() the
> wait-queue for NOSPACE signaling.  Since the client was waiting for
> a packet on the same wait-queue, this was where the first wakeup
> came from.  Then later the softirq finally pushed an actual packet
> to the queue, and the client was once again re-awoken via the same
> overloaded wait-queue.  This time it would successfully find a
> packet and return to userspace.
>
> Since the client does not care about wmem/nospace in the UDP rx
> path, yet the two events share a single wait-queue, the first wakeup
> was completely wasted.  It just causes extra scheduling activity
> that does not help in any way (and is quite expensive in the
> grand-scheme of things).  Based on this lead, Pat devised a solution
> which eliminates the extra wake-up() when there are no clients
> waiting for that particular NOSPACE event.  With his patch applied,
> we observed two things:

Why is the application checking for receive packets even on the
write-space wakeup?

poll/select/epoll should be giving the correct event indication,
therefore the application would know to not check for receive
packets when a write-wakeup event occurs.

Yes the wakeup is spurious and we should avoid it.  But this
application is also buggy.

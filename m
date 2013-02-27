From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: avoid wakeups for pure ACK
Date: Wed, 27 Feb 2013 10:17:39 -0800
Message-ID: <1361989059.11403.50.camel@edumazet-glaptop>
References: <1361984703.11403.43.camel@edumazet-glaptop>
	 <20130227.130444.2188252064827683663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	ycheng@google.com, ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32939 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759708Ab3B0SRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 13:17:42 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so590068pab.19
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 10:17:42 -0800 (PST)
In-Reply-To: <20130227.130444.2188252064827683663.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-27 at 13:04 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 27 Feb 2013 09:05:03 -0800
> 
> > Processing pure ACK on behalf of the thread blocked in tcp_recvmsg()
> > is a waste of resources, as thread has to immediately sleep again
> > because it got no payload.
> 
> More than one thread can be operating on the socket, the other one
> could be waiting for the window to open up in order to do a send.  Are
> you absolutely sure that we won't have a problem in that situation?


Yes, more than one thread can be operating, but the prequeue wakeups the
one blocked in tcp_recvmsg() only, because of :

wake_up_interruptible_sync_poll(sk_sleep(sk),
				POLLIN | POLLRDNORM | POLLRDBAND);


Then the ACK processing might/should wakeup the other thread blocked in
tcp_sendmsg().

So this patch will also help this (not very usual) situation, as we will
only wakeup the tcp_sendmsg() thread when ACK is processed from softirq
handler, and let the thread blocked in tcp_recvmsg() sleeping.


> In fact I wonder if that does the right thing right now.

Right now it is working, because at least one thread will process the
prequeue at the exit of tcp_recvmsg()

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: set SOCK_NOSPACE under memory presure
Date: Tue, 21 Apr 2015 17:33:00 -0400 (EDT)
Message-ID: <20150421.173300.553980773035401270.davem@davemloft.net>
References: <20150420200513.11D8E202D@prod-mail-relay06.akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55834 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932620AbbDUVdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 17:33:06 -0400
In-Reply-To: <20150420200513.11D8E202D@prod-mail-relay06.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>
Date: Mon, 20 Apr 2015 20:05:13 +0000 (GMT)

> Under tcp memory pressure, calling epoll_wait() in edge triggered
> mode after -EAGAIN, can result in an indefinite hang in epoll_wait(),
> even when there is suffcient memory available to continue making
> progress. The problem is that __sk_mem_schedule() can return 0,
> under memory pressure without having set the SOCK_NOSPACE flag. Thus,
> even though all the outstanding packets have been acked, we never
> get the EPOLLOUT that we are expecting from epoll_wait().
> 
> This issue is currently limited to epoll when used in edge trigger
> mode, since 'tcp_poll()', does in fact currently set SOCK_NOSPACE.
> This is sufficient for poll()/select() and epoll() in level trigger
> mode. However, in edge trigger mode, epoll() is relying on the write
> path to set SOCK_NOSPACE. So I view this patch as bringing us into
> sync with poll()/select() and epoll() level trigger behavior.

Can you explain exactly how epoll in edge trigger mode is
depending upon SOCK_NOSPACE being set in this way?  I tried
to read the epoll code and it just seems to call ->poll()
in the normal way when returning event state.

Also, there are exactly two call sites of sk_stream_wait_space()
for TCP, and they both look like this:

====================
wait_for_sndbuf:
		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
wait_for_memory:
		tcp_push(sk, flags & ~MSG_MORE, mss_now,
			 TCP_NAGLE_PUSH, size_goal);

		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
			goto do_error;
====================

Definitely, the person who wrote this code intended SOCK_NOSPACE to be
set only when we are waiting for sndbuf space rather than just memory.

At a minimum, I need a more detailed commit log message for this,
showing the exact code paths in epoll() that have this requirement and
thus create the looping condition.  Because with a casual scan of the
epoll code I could not figure it out.

Thanks.

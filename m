From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 13 Jan 2009 15:26:36 -0800 (PST)
Message-ID: <20090113.152636.07760819.davem@davemloft.net>
References: <49667534.5060501@zeus.com>
	<20090108.135515.85489589.davem@davemloft.net>
	<4966F2F4.9080901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@zeus.com, w@1wt.eu, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755127AbZAMX0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 18:26:35 -0500
In-Reply-To: <4966F2F4.9080901@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 09 Jan 2009 07:47:16 +0100

> I found this patch usefull in my testings, but had a feeling something
> was not complete. If the goal is to reduce number of splice() calls,
> we also should reduce number of wakeups. If splice() is used in non
> blocking mode, nothing we can do here of course, since the application
> will use a poll()/select()/epoll() event before calling splice(). A
> good setting of SO_RCVLOWAT to (16*PAGE_SIZE)/2 might improve things.

Spice read does not handle SO_RCVLOWAT like tcp_recvmsg() does.

We should probably add a:

	target = sock_rcvlowat(sk, flags & MSG_WAITALL, len);

and check 'target' against 'spliced' in the main loop of
tcp_splice_read().

> About tcp_recvmsg(), we might also remove the "!timeo" test as well,
> more testings are needed. But remind that if an application provides
> a large buffer to tcp_recvmsg() call, removing the test will reduce
> the number of syscalls but might use more DCACHE. It could reduce
> performance on old cpus. With splice() call, we expect to not
> copy memory and trash DCACHE, and pipe buffers being limited to 16,
> we cope with a limited working set. 

I sometimes have a suspicion we can remove this test too, but it's
not really that clear.

If an application is doing non-blocking reads and they care about
latency, they shouldn't be providing huge buffers.  This much I
agree with, but...

If you look at where this check is placed in the recvmsg() case, it is
done after we have verified that there is no socket backlog.

		if (copied >= target && !sk->sk_backlog.tail)
			break;

		if (copied) {
			if (sk->sk_err ||
			    sk->sk_state == TCP_CLOSE ||
			    (sk->sk_shutdown & RCV_SHUTDOWN) ||
			    !timeo ||
			    signal_pending(current))
				break;
		} else {

So either:

1) We haven't met the target.  And note that target is one unless
   the user makes an explicit receive low-water setting.

2) Or there is no backlog.

When we get to the 'if (copied)' check.

You can view this "!timeo" check as meaning "non-blocking".  When
we get to it, we are guarenteed that we haven't met the target
and we have no backlog.  So it is absolutely appropriate to break
out of recvmsg() processing here if non-blocking.

There is a lot of logic and feature handling in tcp_splice_read() and
that's why the semantics of "!timeo" cases are not being handled
properly here.

From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Thu, 8 Jan 2009 23:20:39 +0100
Message-ID: <20090108222039.GC24243@1wt.eu>
References: <20090108173028.GA22531@1wt.eu> <49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ben@zeus.com, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1283 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762824AbZAHWUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 17:20:54 -0500
Content-Disposition: inline
In-Reply-To: <20090108.135515.85489589.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 01:55:15PM -0800, David Miller wrote:
> From: Ben Mansell <ben@zeus.com>
> Date: Thu, 08 Jan 2009 21:50:44 +0000
> 
> > > From fafe76713523c8e9767805cfdc7b73323d7bf180 Mon Sep 17 00:00:00 2001
> > > From: Willy Tarreau <w@1wt.eu>
> > > Date: Thu, 8 Jan 2009 17:10:13 +0100
> > > Subject: [PATCH] tcp: splice as many packets as possible at once
> > > Currently, in non-blocking mode, tcp_splice_read() returns after
> > > splicing one segment regardless of the len argument. This results
> > > in low performance and very high overhead due to syscall rate when
> > > splicing from interfaces which do not support LRO.
> > > The fix simply consists in not breaking out of the loop after the
> > > first read. That way, we can read up to the size requested by the
> > > caller and still return when there is no data left.
> > > Performance has significantly improved with this fix, with the
> > > number of calls to splice() divided by about 20, and CPU usage
> > > dropped from 100% to 75%.
> > > 
> > 
> > I get similar results with my testing here. Benchmarking an application with this patch shows that more than one packet is being splice()d in at once, as a result I see a doubling in throughput.
> > 
> > Tested-by: Ben Mansell <ben@zeus.com>
> 
> I'm not applying this until someone explains to me why
> we should remove this test from the splice receive but
> keep it in the tcp_recvmsg() code where it has been
> essentially forever.

In my opinion, the code structure is different between both functions. In
tcp_recvmsg(), we test for it if (copied > 0), where copied is the sum of
all data which have been processed since the entry in the function. If we
removed the test here, we could not break out of the loop once we have
copied something. In tcp_splice_read(), the test is still present in the
(!ret) code path, where ret is the last number of bytes processed, so the
test is still performed regardless of what has been previously transferred.

So in summary, in tcp_splice_read without this test, we get back to the
top of the loop, and if __tcp_splice_read() returns 0, then we break out
of the loop.

I don't know if my explanation is clear or not, it's easier to follow the
loops in front of the code :-/

Willy


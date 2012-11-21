From: "Yan, Zheng" <zheng.z.yan@linux.intel.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Wed, 21 Nov 2012 16:05:27 +0800
Message-ID: <CAAM7YAkC+xMwJCjsi0ojkj+JYgXQgqzM+6NF9L-=j5eh7xh2mQ@mail.gmail.com>
References: <1347868144.26523.71.camel@edumazet-glaptop>
	<CAAM7YAm+XJKTxJStLMoo4RRV85oogN5wCHfXorkEiUHKqNKHDQ@mail.gmail.com>
	<1352987246.4497.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:54000 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051Ab2KUIF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 03:05:29 -0500
Received: by mail-la0-f46.google.com with SMTP id p5so2597628lag.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 00:05:27 -0800 (PST)
In-Reply-To: <1352987246.4497.36.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 15, 2012 at 9:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-11-15 at 15:52 +0800, Yan, Zheng wrote:
>> LLC misses happen on the receiver size. It means most pages allocated by the
>> senders are cache hot. But when using order-3 pages, 2048 * 32k = 64M, 64M
>> is much larger than LLC size.
>
> By the way, this 2048*32k is wrong, as the receiver only uses fragments
> in pages, and its not related to the "tcp: use order-3 pages in
> tcp_sendmsg()" commit
>
> Many drivers use order-0 pages to hold ethernet frames, regardless of
> what was used by the sender ;)
>
>
Hi,

I think we found root cause of this regression. The test case runs
2048 instance of
netperf TCP loopback stream test on a two sockets core2 machine. There is more
LLC misses when using order-3 pages. core2 is not NUMA architecture, there is
only one memory node. Order-3 pages used by one socket may be later re-used by
another socket, which causes lots of LLC invalidation.  Using order-0
page doesn't
have this issue is because the kernel page allocator uses per-cpu list
to optimize
order-0 page allocation.

Regards
Yan, Zheng

From: "Yan, Zheng " <yanzheng@21cn.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Thu, 15 Nov 2012 15:52:07 +0800
Message-ID: <CAAM7YAm+XJKTxJStLMoo4RRV85oogN5wCHfXorkEiUHKqNKHDQ@mail.gmail.com>
References: <1347868144.26523.71.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:44269 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536Ab2KOHwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 02:52:08 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so1373621vbb.19
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 23:52:07 -0800 (PST)
In-Reply-To: <1347868144.26523.71.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 17, 2012 at 3:49 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> We currently use per socket page reserve for tcp_sendmsg() operations.
>
> Its done to raise the probability of coalescing small write() in to
> single segments in the skbs.
>
> But it wastes a lot of memory for applications handling a lot of mostly
> idle sockets, since each socket holds one page in sk->sk_sndmsg_page
>
> I did a small experiment to use order-3 pages and it gave me a 10% boost
> of performance, because each TSO skb can use only two frags of 32KB,
> instead of 16 frags of 4KB, so we spend less time in ndo_start_xmit() to
> setup the tx descriptor and TX completion path to unmap the frags and
> free them.
>
> We also spend less time in tcp_sendmsg(), because we call page allocator
> 8x less often.
>
> Now back to the per socket page, what about trying to factorize it ?
>
> Since we can sleep (or/and do a cpu migration) in tcp_sendmsg(), we cant
> really use a percpu page reserve as we do in __netdev_alloc_frag()
>
> We could instead use a per thread reserve, at the cost of adding a test
> in task exit handler.
>
> Recap :
>
> 1) Use a per thread page reserve instead of a per socket one
> 2) Use order-3 pages (or order-0 pages if page size is >= 32768)
>
>

Hi,

This commit makes one of our test case on core 2 machine drop in performance
by about 60%. The test case runs 2048 instances of netperf 64k stream test at
the same time.  Analysis showed using order-3 pages causes more LLC misses,
most new LLC misses happen when the senders copy data to the socket buffer.
If revert to use single page, the sender side only trigger a few LLC
misses, most
LLC misses happen on the receiver size. It means most pages allocated by the
senders are cache hot. But when using order-3 pages, 2048 * 32k = 64M, 64M
is much larger than LLC size. Should this regression be worried? or
our test case
is too unpractical?

Regards
Yan, Zheng

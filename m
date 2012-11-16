From: "Yan, Zheng " <yanzheng@21cn.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Fri, 16 Nov 2012 10:36:30 +0800
Message-ID: <CAAM7YAm13mTaOPqwaq1rEx9Q+OXJjneSwH_cg5QRZTvF-qyCrA@mail.gmail.com>
References: <1347868144.26523.71.camel@edumazet-glaptop>
	<CAAM7YAm+XJKTxJStLMoo4RRV85oogN5wCHfXorkEiUHKqNKHDQ@mail.gmail.com>
	<1352984761.4497.22.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, rick.jones2@hp.com,
	"Yan, Zheng" <zheng.z.yan@linux.intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:52044 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804Ab2KPCgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 21:36:31 -0500
Received: by mail-lb0-f174.google.com with SMTP id gp3so1827305lbb.19
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2012 18:36:30 -0800 (PST)
In-Reply-To: <1352984761.4497.22.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 15, 2012 at 9:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-11-15 at 15:52 +0800, Yan, Zheng wrote:
>> On Mon, Sep 17, 2012 at 3:49 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > We currently use per socket page reserve for tcp_sendmsg() operations.
>> >
>> > Its done to raise the probability of coalescing small write() in to
>> > single segments in the skbs.
>> >
>> > But it wastes a lot of memory for applications handling a lot of mostly
>> > idle sockets, since each socket holds one page in sk->sk_sndmsg_page
>> >
>> > I did a small experiment to use order-3 pages and it gave me a 10% boost
>> > of performance, because each TSO skb can use only two frags of 32KB,
>> > instead of 16 frags of 4KB, so we spend less time in ndo_start_xmit() to
>> > setup the tx descriptor and TX completion path to unmap the frags and
>> > free them.
>> >
>> > We also spend less time in tcp_sendmsg(), because we call page allocator
>> > 8x less often.
>> >
>> > Now back to the per socket page, what about trying to factorize it ?
>> >
>> > Since we can sleep (or/and do a cpu migration) in tcp_sendmsg(), we cant
>> > really use a percpu page reserve as we do in __netdev_alloc_frag()
>> >
>> > We could instead use a per thread reserve, at the cost of adding a test
>> > in task exit handler.
>> >
>> > Recap :
>> >
>> > 1) Use a per thread page reserve instead of a per socket one
>> > 2) Use order-3 pages (or order-0 pages if page size is >= 32768)
>> >
>> >
>>
>> Hi,
>>
>> This commit makes one of our test case on core 2 machine drop in performance
>> by about 60%. The test case runs 2048 instances of netperf 64k stream test at
>> the same time.  Analysis showed using order-3 pages causes more LLC misses,
>> most new LLC misses happen when the senders copy data to the socket buffer.
>> If revert to use single page, the sender side only trigger a few LLC
>> misses, most
>> LLC misses happen on the receiver size. It means most pages allocated by the
>> senders are cache hot. But when using order-3 pages, 2048 * 32k = 64M, 64M
>> is much larger than LLC size. Should this regression be worried? or
>> our test case
>> is too unpractical?
>
> Hi Yan
>
> You forgot to give some basic information with this mail, like the
> hardware configuration, NIC driver, ...
>
> Increasing performance can sometime change the balance you had on a
> prior workload.
>
> Number of in flight bytes do not depend on the order of the pages, but
> sizes of TCP buffers (receiver, sender)
>
> TCP Small queue was an attempt to reduce the number of in-flight bytes,
> you should try to change either SO_SNDBUF or SO_RCVBUF settings (instead
> of letting the system autotune them) if you really need 2048 concurrent
> flows.
>
> Otherwise, each flow can consume up to 6 MB of memory, so obviously your
> cpu caches wont hold 2048*6MB of memory...
>
> If the sender is faster (because of this commit), but receiver is slow
> to drain the receive queues, then you can have a situation where the
> consumed memory on receiver is higher and the receiver might be actually
> slower.
>

I'm sorry, I forgot to mention the test ran on loopback device. It's
one test case in
our kernel performance test project. This test case is very sensitive to memory
allocation and scheduler behavior changes.

Regards
Yan, Zheng

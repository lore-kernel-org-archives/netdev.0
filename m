From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH net-next] tcp: reduce cpu usage when SO_SNDBUF is set
Date: Tue, 21 Jun 2016 11:24:01 -0400
Message-ID: <57695C11.6070201@akamai.com>
References: <1466457781-24123-1-git-send-email-jbaron@akamai.com>
 <1466461744.6850.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:28353 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751696AbcFUPYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 11:24:03 -0400
In-Reply-To: <1466461744.6850.29.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/20/2016 06:29 PM, Eric Dumazet wrote:
> On Mon, 2016-06-20 at 17:23 -0400, Jason Baron wrote:
>> From: Jason Baron <jbaron@akamai.com>
>>
>> When SO_SNDBUF is set and we are under tcp memory pressure, the effective
>> write buffer space can be much lower than what was set using SO_SNDBUF. For
>> example, we may have set the buffer to 100kb, but we may only be able to
>> write 10kb. In this scenario poll()/select()/epoll(), are going to
>> continuously return POLLOUT, followed by -EAGAIN from write(), and thus
>> result in a tight loop. Note that epoll in edge-triggered does not have
>> this issue since it only triggers once data has been ack'd. There is no
>> issue here when SO_SNDBUF is not set, since the tcp layer will auto tune
>> the sk->sndbuf.
>>
>> Introduce a new socket flag, SOCK_SHORT_WRITE, such that we can mark the
>> socket when we have a short write due to memory pressure. By then testing
>> for SOCK_SHORT_WRITE in tcp_poll(), we hold off the POLLOUT until a
>> non-zero amount of data has been ack'd. In a previous approach:
>> http://marc.info/?l=linux-netdev&m=143930393211782&w=2, I had introduced a
>> new field in 'struct sock' to solve this issue, but its undesirable to add
>> bloat to 'struct sock'. We also could address this issue, by waiting for
>> the buffer to become completely empty, but that may reduce throughput since
>> the write buffer would be empty while waiting for subsequent writes. This
>> change brings us in line with the current epoll edge-trigger behavior for
>> the poll()/select() and epoll level-trigger.
>>
>> We guarantee that SOCK_SHORT_WRITE will eventually clear, since when we set
>> SOCK_SHORT_WRITE, we make sure that sk_wmem_queued is non-zero and
>> SOCK_NOSPACE is set as well (in sk_stream_wait_memory()).
>>
>> I tested this patch using 10,000 sockets, and setting SO_SNDBUF on the
>> server side, to induce tcp memory pressure. A single server thread reduced
>> its cpu usage from 100% to 19%, while maintaining the same level of
>> throughput.
>>
>> Signed-off-by: Jason Baron <jbaron@akamai.com>
>> ---
> 
> 
> When this bug was added, and by which commit ?
> 

I think we have always had this behavior, I've seen it at least back
to 3.10. It requires SO_SNDBUF, lots of sockets and memory pressure...
That said its quite easy to reproduce.

> This looks serious, but your patch looks way too complex.
> 
> This SOCK_SHORT_WRITE bit constantly cleared in sk_stream_write_space()
> is expensive, because it dirties sk_flags which is not supposed to
> written often. This field is located in a read mostly cache line.
> 
> I believe my suggestion was not to add a per socket bit,
> but have a global state like tcp_memory_pressure. (or reuse it)
> 
> Ie , when under global memory pressure, tcp_poll() should apply a
> strategy to give POLLOUT only on sockets having less than 4K
> (tcp_wmem[0]) of memory consumed in their write queue.
> 
> 
> 
> 

ok, I think you're saying to just add:

if (sk_under_memory_pressure(sk) && sk->sk_wmem_queued > tcp_wmem[0])
	return false;

to the beginning of sk_stream_is_writeable().

My concern is that it then allows the sndbuf to basically completely
empty before we are triggered to write again. The patch I presented
attempts to write against as soon as any new space is available for
the flow.

I also didn't necessarily want to affect all flows. If so_sndbuf is
not set, we generally don't need to change the wakeup behavior b/c
the sndbuf shrinks to the point where the normal write wakeup does
not cause these tight poll()/write() loops, where we don't make
any progress. We also don't need to change the behavior if we are
under memory pressure but but have written enough (filled more than 2/3
of the buffer), such that the normal wakeups again would work fine.
So we could incorporate some of this logic into the above check, but
it becomes more complex.

In my patch, I could replace the:

sock_reset_flag(sk, SOCK_QUEUE_SHRUNK);

in tcp_check_space() with something like:

sk->sk_flags &= ~((1UL << SOCK_QUEUE_SHRUNK) | (1UL << SOCK_SHORT_WRITE));

Since we are already writing to sk_flags there this should have very
minimal overhead. And then remove the clear in sk_stream_write_space().

Thanks,

-Jason

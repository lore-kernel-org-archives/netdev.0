From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH] tcp: set SOCK_NOSPACE under memory presure
Date: Thu, 30 Apr 2015 10:34:17 -0400
Message-ID: <55423D69.7000907@akamai.com>
References: <20150420200513.11D8E202D@prod-mail-relay06.akamai.com> <20150421.173300.553980773035401270.davem@davemloft.net> <5537AF76.1020108@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jason Baron <jbaron@akamai.com>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:49688 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750719AbbD3OeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 10:34:18 -0400
In-Reply-To: <5537AF76.1020108@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2015 10:25 AM, Jason Baron wrote:
> On 04/21/2015 05:33 PM, David Miller wrote:
>> From: Jason Baron <jbaron@akamai.com>
>> Date: Mon, 20 Apr 2015 20:05:13 +0000 (GMT)
>>
>>> Under tcp memory pressure, calling epoll_wait() in edge triggered
>>> mode after -EAGAIN, can result in an indefinite hang in epoll_wait(),
>>> even when there is suffcient memory available to continue making
>>> progress. The problem is that __sk_mem_schedule() can return 0,
>>> under memory pressure without having set the SOCK_NOSPACE flag. Thus,
>>> even though all the outstanding packets have been acked, we never
>>> get the EPOLLOUT that we are expecting from epoll_wait().
>>>
>>> This issue is currently limited to epoll when used in edge trigger
>>> mode, since 'tcp_poll()', does in fact currently set SOCK_NOSPACE.
>>> This is sufficient for poll()/select() and epoll() in level trigger
>>> mode. However, in edge trigger mode, epoll() is relying on the write
>>> path to set SOCK_NOSPACE. So I view this patch as bringing us into
>>> sync with poll()/select() and epoll() level trigger behavior.
>> Can you explain exactly how epoll in edge trigger mode is
>> depending upon SOCK_NOSPACE being set in this way?  I tried
>> to read the epoll code and it just seems to call ->poll()
>> in the normal way when returning event state.
> In edge trigger mode, when we receive a wakeup event we
> call ->poll() in the normal way, *but* we do not leave the event
> as still pending. (Specifically, in the epoll() code we are not
> re-adding it (fs/eventpoll.c:ep_send_events_proc())). This is
> because we are only interested in the 'edge' or the event
> going high. In level trigger mode, we do leave the event
> pending if its 'high', such that it will re-trigger again for us on
> the next epoll_wait().
>
> EPOLL(7) is clear that in edge-trigger mode we can only do
> epoll_wait() after read/write return -EAGAIN. Thus, in the
> case of the socket write, we are relying on the fact that
> tcp_sendmsg()/network layer is going to issue a wakeup
> for us at some point in the future when we get -EAGAIN.
>
> This all works fine in the case you pointed out where we
> have exceeded the sk->sndbuf and set SOCK_NOSPACE.
> However, when we return -EAGAIN from the write path
> b/c we are over the tcp memory limits and not b/c we are
> over the sndbuf, we are never going to get another wakeup
> (since SOCK_NOSPACE is not set in this case). Level trigger
> avoids this since the subsequent epoll_wait() is going to
> re-try the ->poll() (and set SOCK_NOSPACE if it fails).
>
> Now, in the memory failure case, we are not really
> waiting for the buffer to empty, but rather for there to be
> memory more generally available. So it could be argued
> that we need to implement a wakeup here based on memory
> being available as opposed to the write queue emptying.
> That is one potential option here.
>
> I think the other one is the route I was proposing, which was
> to treat the out of memory case, in the same way as the
> sk->sndbuf queue full case, as select(), poll() and epoll() level
> trigger are currently doing. And potentially add maybe an
> -ENOSPC return if the write queue really is empty...I thought
> that approach made sense b/c even under memory pressure
> (over sk_prot_mem_limits(sk, 1), but not over
> sk_prot_mem_limits(sk, 2)) we continue to guarantee a
> minimum sndbuf size (implying we can keep making progress).
> That said, there is a case, over sk_prot_mem_limits(sk, 2),
> where we do not guarantee the minimum buffer size, but I
> think in practice that is very hard to hit (since we are reducing
> usage over sk_prot_mem_limits(sk, 1) aggressively).
>
> There is also the case where we actually are out of memory
> on the system, ie kmalloc() etc. are failing, in which case
> we could maybe return -ENOSPC, or else we would potentially
> need a larger change to wait on memory being available
> as opposed to the buffer emptying.
>
> Thanks,
>
> -Jason

Hi,

Just curious if anybody had any further reaction on this issue.
I think making the epoll edge trigger case, as least match what
we are seeing for poll()/select()/epoll() level trigger seems
reasonable here.

Thanks,

-Jason

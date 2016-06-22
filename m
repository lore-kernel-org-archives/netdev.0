From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH v2 net-next 2/2] tcp: reduce cpu usage when SO_SNDBUF is
 set
Date: Wed, 22 Jun 2016 15:20:23 -0400
Message-ID: <576AE4F7.4060204@akamai.com>
References: <cover.1466608332.git.jbaron@akamai.com>
 <c873de17bfcf341eafda5ee7762c3f2c26579ff1.1466608332.git.jbaron@akamai.com>
 <1466616854.6850.69.camel@edumazet-glaptop3.roam.corp.google.com>
 <576AD666.7050809@akamai.com>
 <1466621021.6850.71.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466621479.6850.75.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:40382 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751726AbcFVTUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 15:20:49 -0400
In-Reply-To: <1466621479.6850.75.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/22/2016 02:51 PM, Eric Dumazet wrote:
> On Wed, 2016-06-22 at 11:43 -0700, Eric Dumazet wrote:
>> On Wed, 2016-06-22 at 14:18 -0400, Jason Baron wrote:
>>> For 1/2, the getting the correct memory barrier, should I re-submit
>>> that as a separate patch?
>> Are you sure a full memory barrier (smp_mb() is needed ?
>>
>> Maybe smp_wmb() would be enough ?
>>
>> (And smp_rmb() in tcp_poll() ?)
> Well, in tcp_poll() smp_mb__after_atomic() is fine as it follows
> set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
>
> (although we might add a comment why we should keep
> sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk) before the set_bit() !)
>
> But presumably smp_wmb() would be enough in tcp_check_space()
>
>
>
>

hmm, I think we need the smp_mb() there. From
tcp_poll() we have:

1) set_bit(SOCK_NOSPACE, ...)  (write)
2) smp_mb__after_atomic();
3) if (sk_stream_is_writeable(sk)) (read)

while in tcp_check_space() its:

1) the state that sk_stream_is_writeable() cares about (write)
2) smp_mb();
3) if (sk->sk_socket && test_bit(SOCK_NOSPACE,...) (read)

So if we can show that there are sufficient barriers
for #1 (directly above), maybe it can be down-graded or
eliminated. But it would still seem somewhat fragile.

Note I didn't observe any missing wakeups here, but I
just wanted to make sure we didn't miss any, since they
can be quite hard to debug.

Thanks,

-Jason

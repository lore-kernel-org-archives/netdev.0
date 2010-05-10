From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH v2] sctp: Fix a race between ICMP protocol unreachable
 and connect()
Date: Mon, 10 May 2010 09:59:32 -0400
Message-ID: <4BE81144.8020806@hp.com>
References: <1273087783-18250-1-git-send-email-vladislav.yasevich@hp.com> <1273088166-18391-1-git-send-email-vladislav.yasevich@hp.com> <4BE775C7.9070702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:37160 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754358Ab0EJN7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 09:59:35 -0400
In-Reply-To: <4BE775C7.9070702@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Wei Yongjun wrote:
> Hi Vlad:
> 
>> [.. removed leftover debuggin printk. should probably be queued for stable
>>  as well... ]
>>
>> ICMP protocol unreachable handling completely disregarded
>> the fact that the user may have locket the socket.  It proceeded
>> to destroy the association, even though the user may have
>> held the lock and had a ref on the association.  This resulted
>> in the following:
>>
>> Attempt to release alive inet socket f6afcc00
>>
>> =========================
>> [ BUG: held lock freed! ]
>> -------------------------
>> somenu/2672 is freeing memory f6afcc00-f6afcfff, with a lock still held
>> there!
>>  (sk_lock-AF_INET){+.+.+.}, at: [<c122098a>] sctp_connect+0x13/0x4c
>> 1 lock held by somenu/2672:
>>  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<c122098a>] sctp_connect+0x13/0x4c
>>
>> stack backtrace:
>> Pid: 2672, comm: somenu Not tainted 2.6.32-telco #55
>> Call Trace:
>>  [<c1232266>] ? printk+0xf/0x11
>>  [<c1038553>] debug_check_no_locks_freed+0xce/0xff
>>  [<c10620b4>] kmem_cache_free+0x21/0x66
>>  [<c1185f25>] __sk_free+0x9d/0xab
>>  [<c1185f9c>] sk_free+0x1c/0x1e
>>  [<c1216e38>] sctp_association_put+0x32/0x89
>>  [<c1220865>] __sctp_connect+0x36d/0x3f4
>>  [<c122098a>] ? sctp_connect+0x13/0x4c
>>  [<c102d073>] ? autoremove_wake_function+0x0/0x33
>>  [<c12209a8>] sctp_connect+0x31/0x4c
>>  [<c11d1e80>] inet_dgram_connect+0x4b/0x55
>>  [<c11834fa>] sys_connect+0x54/0x71
>>  [<c103a3a2>] ? lock_release_non_nested+0x88/0x239
>>  [<c1054026>] ? might_fault+0x42/0x7c
>>  [<c1054026>] ? might_fault+0x42/0x7c
>>  [<c11847ab>] sys_socketcall+0x6d/0x178
>>  [<c10da994>] ? trace_hardirqs_on_thunk+0xc/0x10
>>  [<c1002959>] syscall_call+0x7/0xb
>>
>> This was because the sctp_wait_for_connect() would aqcure the socket
>> lock and then proceed to release the last reference count on the
>> association, thus cause the fully destruction path to finish freeing
>> the socket.
>>
>> The simplest solution is to start a very short timer in case the socket
>> is owned by user.  When the timer expires, we can do some verification
>> and be able to do the release properly.
>>   
> 
> After reviewed this patch, I think we should delete active ICMP proto
> unreachable timer when free transport. since I don't reproduce this BUG,
> so I just do compile test only, sorry.

Hi Wei

To reproduce with the original code (before my patch), add the following rule

# iptables -A INPUT -p sctp -j REJECT --reject-with icmp-proto-unreachable

and then try connecting to the localhost.  I was never able to reproduce the race
on any kind of network, but on localhost it happens every time.

> 
> [PATCH] sctp: delete active ICMP proto unreachable timer when free transport
> 
> transport may be free before ICMP proto unreachable timer expire, so
> we should delete active ICMP proto unreachable timer when transport
> is going away.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> ---
>  net/sctp/transport.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> index 4a36803..165d54e 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -173,6 +173,10 @@ void sctp_transport_free(struct sctp_transport *transport)
>  	    del_timer(&transport->T3_rtx_timer))
>  		sctp_transport_put(transport);
>  
> +	/* Delete the ICMP proto unreachable timer if it's active. */
> +	if (timer_pending(&transport->proto_unreach_timer) &&
> +	    del_timer(&transport->proto_unreach_timer))
> +		sctp_association_put(transport->asoc);
>  
>  	sctp_transport_put(transport);
>  }

ACK.  This fixes a race against close().  Although that will be fairly hard to
do, it is possible.

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

-vlad

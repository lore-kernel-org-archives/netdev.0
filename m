From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Fri, 1 Apr 2016 02:21:34 +0200
Message-ID: <56FDBF0E.8020309@stressinduktion.org>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBA6E.5030508@stressinduktion.org>
 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:54883 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757913AbcDAAVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 20:21:38 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 73F9B20CD0
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 20:21:37 -0400 (EDT)
In-Reply-To: <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.04.2016 02:12, Eric Dumazet wrote:
> On Fri, 2016-04-01 at 02:01 +0200, Hannes Frederic Sowa wrote:
>> Hi Eric,
>>
>> On 01.04.2016 01:39, Eric Dumazet wrote:
>>> On Fri, 2016-04-01 at 01:29 +0200, Hannes Frederic Sowa wrote:
>>>> Various fixes which were discovered by this changeset. More probably
>>>> to come...
>>>
>>>
>>> Really ?
>>>
>>> Again, TCP stack locks the socket most of the time.
>>>
>>> The fact that lockdep does not understand this is not a reason to add
>>> this overhead.
>>
>> I don't see how lockdep does not understand this? I think I added the
>> appropriate helper to exactly verify if we have the socket lock with
>> lockdep, please have a look at lockdep_sock_is_held in patch #2.
>>
>> Some of the patches also just reorder the rcu_read_lock, which is anyway
>> mostly free.
>
> I strongly disagree. Adding rcu_read_lock() everywhere as you did gives
> a sense of 'security' by merely shutting down maybe good signals.

I did those patches by adding the first patches and running tcp tests, 
so I have splats for every single one of those. I just didn't bother 
them into the changelog. I certainly can do so.

> Your changelog explains nothing, and your patch makes absolutely no
> sense to me.
>
> Lets take following example :
>
>   struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
>   {
> -       struct dst_entry *dst = __sk_dst_get(sk);
> +       struct dst_entry *dst;
>
> +       rcu_read_lock();
> +       dst = __sk_dst_get(sk);
>          if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
>                  sk_tx_queue_clear(sk);
>                  RCU_INIT_POINTER(sk->sk_dst_cache, NULL);
>                  dst_release(dst);
> -               return NULL;
> +               dst = NULL;
>          }
> +       rcu_read_unlock();
>
>          return dst;
>   }
>
>
> Since this function does not take a reference on the dst, how could it
> be safe ?

This is stupid by me, I am sorry, thanks for pointing this out. I will
fix this. Just looking too long at all those lockdep reports.

I will find another fix for this.

> As soon as you exit the function, dst would possibly point to something
> obsolete/freed.
>
> This works because the caller owns the socket.
>
> If you believe one path needs to be fixed, tell me which one it is.
>
> Please ?

[   31.064029] ===============================
[   31.064030] [ INFO: suspicious RCU usage. ]
[   31.064032] 4.5.0+ #13 Not tainted
[   31.064033] -------------------------------
[   31.064034] include/net/sock.h:1594 suspicious 
rcu_dereference_check() usage!
[   31.064035]
                other info that might help us debug this:

[   31.064041]
                rcu_scheduler_active = 1, debug_locks = 1
[   31.064042] no locks held by ssh/817.
[   31.064043]
                stack backtrace:
[   31.064045] CPU: 0 PID: 817 Comm: ssh Not tainted 4.5.0+ #13
[   31.064046] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.8.2-20150714_191134- 04/01/2014
[   31.064047]  0000000000000286 000000006730b46b ffff8800badf7bd0 
ffffffff81442b33
[   31.064050]  ffff8800b8c78000 0000000000000001 ffff8800badf7c00 
ffffffff8110ae75
[   31.064052]  ffff880035ea2f00 ffff8800b8e28000 0000000000000003 
00000000000004c4
[   31.064054] Call Trace:
[   31.064058]  [<ffffffff81442b33>] dump_stack+0x85/0xc2
[   31.064062]  [<ffffffff8110ae75>] lockdep_rcu_suspicious+0xc5/0x100
[   31.064064]  [<ffffffff8173bf57>] __sk_dst_check+0x77/0xb0
[   31.064066]  [<ffffffff8182e502>] inet6_sk_rebuild_header+0x52/0x300
[   31.064068]  [<ffffffff813bb61e>] ? selinux_skb_peerlbl_sid+0x5e/0xa0
[   31.064070]  [<ffffffff813bb69e>] ? 
selinux_inet_conn_established+0x3e/0x40
[   31.064072]  [<ffffffff817c2bad>] tcp_finish_connect+0x4d/0x270
[   31.064074]  [<ffffffff817c33f7>] tcp_rcv_state_process+0x627/0xe40
[   31.064076]  [<ffffffff81866584>] tcp_v6_do_rcv+0xd4/0x410
[   31.064078]  [<ffffffff8173bc65>] release_sock+0x85/0x1c0
[   31.064079]  [<ffffffff817e9983>] __inet_stream_connect+0x1c3/0x340
[   31.064081]  [<ffffffff8173b089>] ? lock_sock_nested+0x49/0xb0
[   31.064083]  [<ffffffff81100270>] ? abort_exclusive_wait+0xb0/0xb0
[   31.064084]  [<ffffffff817e9b38>] inet_stream_connect+0x38/0x50
[   31.064086]  [<ffffffff8173794f>] SYSC_connect+0xcf/0xf0
[   31.064088]  [<ffffffff8110d069>] ? trace_hardirqs_on_caller+0x129/0x1b0
[   31.064090]  [<ffffffff8100301b>] ? trace_hardirqs_on_thunk+0x1b/0x1d
[   31.064091]  [<ffffffff8173854e>] SyS_connect+0xe/0x10
[   31.064094]  [<ffffffff818a0e7c>] entry_SYSCALL_64_fastpath+0x1f/0xbd

Bye,
Hannes

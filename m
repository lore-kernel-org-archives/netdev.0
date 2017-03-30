From: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Subject: Re: [PATCH] tcp: possible race between tcp_done() and tcp_poll()
Date: Thu, 30 Mar 2017 11:55:43 +0900
Message-ID: <3c8a7438-9ce4-593a-d492-ec8117d71af4@jp.fujitsu.com>
References: <34d952a3-77cd-ea53-c3e3-ccde91d5cf63@jp.fujitsu.com>
 <75d1b617-b143-3061-fcc7-4cca26ffc9fe@jp.fujitsu.com>
 <1490841090.24891.58.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm03.jp.fujitsu.com ([202.219.69.170]:33229 "EHLO
        mgwkm03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754551AbdC3C4W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 22:56:22 -0400
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
        by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id D3F77AC00C8
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 11:56:12 +0900 (JST)
In-Reply-To: <1490841090.24891.58.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 2017-03-30 11:31, Eric Dumazet wrote:
> On Thu, 2017-03-30 at 09:35 +0900, Seiichi Ikarashi wrote:
>> Similar to a4d258036ed9 ("tcp: Fix race in tcp_poll").
>>
>> Between receiving a packet and tcp_poll(), sk->sk_err is protected by memory barriers but
>> sk->sk_shutdown and sk->sk_state are not.
> 
> ...
> 
>>  So possibly, POLLIN|POLLRDNORM|POLLRDHUP might
>> not be set even when receiving a RST packet.
>>
>> Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
>>
>> ---
>>  net/ipv4/tcp.c | 7 +++++--
>>  1 file changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
>> index cf45555..c8bc86e 100644
>> --- a/net/ipv4/tcp.c
>> +++ b/net/ipv4/tcp.c
>> @@ -456,6 +456,8 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
>>  
>>  	sock_poll_wait(file, sk_sleep(sk), wait);
>>  
>> +	/* This barrier is coupled with smp_wmb() in tcp_reset() */
>> +	smp_rmb();
>>  	state = sk_state_load(sk);
> 
> Are you telling us that sk_state_load() has no barrier ?
> 
> This would imply that smp_load_acquire() should be replaced ?

Ooops, of course you're right.
sk->sk_state _is_ protected by sk_state_{load,store}().

So my concern is only for sk->sk_shutdown.

> 
>>  	if (state == TCP_LISTEN)
>>  		return inet_csk_listen_poll(sk);
>> @@ -540,8 +542,6 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
>>  		 */
>>  		mask |= POLLOUT | POLLWRNORM;
>>  	}
>> -	/* This barrier is coupled with smp_wmb() in tcp_reset() */
>> -	smp_rmb();
>>  	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
>>  		mask |= POLLERR;
>>  
>> @@ -3291,6 +3291,9 @@ void tcp_done(struct sock *sk)
>>  
>>  	sk->sk_shutdown = SHUTDOWN_MASK;
>>  
>> +	/* This barrier is coupled with smp_rmb() in tcp_poll() */
>> +	smp_wmb();
>> +
>>  	if (!sock_flag(sk, SOCK_DEAD))
>>  		sk->sk_state_change(sk);
>>  	else
> 
> Might I ask on which arch you got a problem ?

I got a report that receiving a RST packet but poll() got only POLLERR, no POLLIN|POLLRDHUP .
It was an old x86_64 kernel which does not include sk_state_{load,store} functions.
I suspected some race might have occur above.

Thanks,
Seiichi

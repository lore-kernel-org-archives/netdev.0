From: subashab@codeaurora.org
Subject: Re: [PATCH] net: ipv4: Fix incorrect free in ICMP receive
Date: Fri, 16 Jan 2015 20:59:14 -0000
Message-ID: <ff3aa93b48dfedd7721d7fcc8ee7624b.squirrel@www.codeaurora.org>
References: <05e337f44c7a71ac317194cfa3dcdf62.squirrel@www.codeaurora.org>
    <1421412775.11734.117.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:49254 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757034AbbAPU7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 15:59:15 -0500
In-Reply-To: <1421412775.11734.117.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>skb_queue_purge() is also calling skb_orphan() on all skb
>From my reading, it looked like skb_queue_purge() is dequeuing and calling
kfree_skb() which will release a reference. I did not see skb_orphan()
being called directly. Am I missing something?
I think that if it had really orphaned the skb, then this crash would not
be seen in the first place.

>And no, sock_put() does not free the socket.
>We release a refcount that was acquired when we did the socket lookup.
I agree that the refcount is released, but it looked to me like inside
sock_put() the reference count reached 0 hence the socket was freed.

Here is why I say this
(from dmesg)
WARN stack trace @       WARN_ON(atomic_read(&sk->sk_rmem_alloc));
dump_backtrace+0x0/0x248
show_stack+0x10/0x1c
dump_stack+0x1c/0x28
warn_slowpath_common+0x74/0x9c
warn_slowpath_null+0x14/0x20
inet_sock_destruct+0x130/0x1a0
__sk_free+0x1c/0x168
sk_free+0x24/0x30            [sock_put() inlined hence not seen in the
stack trace I believe]
ping_rcv+0xf4/0x124
icmp_rcv+0x224/0x2c4
ip_local_deliver_finish+0x108/0x214

and here is stack at the time of the exception
-007|sk_mem_uncharge   [trying to access freed sk structure]
-007|sock_rfree
-008|skb_release_head_state
-009|skb_release_all
-009|__kfree_skb
-010|kfree_skb
-011|icmp_rcv
-012|ip_local_deliver_finish

I am not sure why the ref reached zero and if that is even the right trail
of thought. Could the userspace have released the sock reference also and
this is race condition? Any thoughts?

Note that we are using the 3.10 kernel version and does not have Rick
Jones patch in this area e3e3217029a35c579bf100998b43976d0b1cb8d7
"icmp: Remove some spurious dropped packet profile hits from the ICMP",
although it looks to me that this patch would not solve this problem
either.

Thanks
KS
-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
 a Linux Foundation Collaborative Project

> On Fri, 2015-01-16 at 07:48 +0000, subashab@codeaurora.org wrote:
>> An exception is seen in ICMP ping receive path where the skb
>> destructor sock_rfree() tries to access a freed socket. This happens
>> because ping_rcv() releases socket reference with sock_put() and this
>> internally frees up the socket. Later icmp_rcv() will try to free the
>> skb and as part of this, skb destructor is called and panics as the
>> socket is freed already in ping_rcv().
>>
>> WARN stack trace @       WARN_ON(atomic_read(&sk->sk_rmem_alloc));
>> dump_backtrace+0x0/0x248
>> show_stack+0x10/0x1c
>> dump_stack+0x1c/0x28
>> warn_slowpath_common+0x74/0x9c
>> warn_slowpath_null+0x14/0x20
>> inet_sock_destruct+0x130/0x1a0
>> __sk_free+0x1c/0x168
>> sk_free+0x24/0x30
>> ping_rcv+0xf4/0x124
>> icmp_rcv+0x224/0x2c4
>> ip_local_deliver_finish+0x108/0x214
>> ip_local_deliver+0x88/0xa0
>> ip_rcv_finish+0x234/0x284
>> ip_rcv+0x258/0x2e8
>> __netif_receive_skb_core+0x640/0x6b4
>> <snip>
>>
>> -->|exception
>> -007|sk_mem_uncharge
>> -007|sock_rfree
>> -008|skb_release_head_state
>> -009|skb_release_all
>> -009|__kfree_skb
>> -010|kfree_skb
>> -011|icmp_rcv
>> -012|ip_local_deliver_finish
>>
>> Fix this by orphaning the skb's before freeing the socket
>>
>> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
>> ---
>>  net/ipv4/af_inet.c | 6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
>> index b507a47..0c58f0e5 100644
>> --- a/net/ipv4/af_inet.c
>> +++ b/net/ipv4/af_inet.c
>> @@ -147,6 +147,12 @@ EXPORT_SYMBOL(ipv4_config);
>>  void inet_sock_destruct(struct sock *sk)
>>  {
>>  	struct inet_sock *inet = inet_sk(sk);
>> +	struct sk_buff *skb;
>> +
>> +	skb_queue_walk(&sk->sk_receive_queue, skb)
>> +		skb_orphan(skb);
>> +	skb_queue_walk(&sk->sk_error_queue, skb)
>> +		skb_orphan(skb);
>>
>>  	__skb_queue_purge(&sk->sk_receive_queue);
>>  	__skb_queue_purge(&sk->sk_error_queue);
>
> Sorry this makes absolutely no sense to me.
>
> skb_queue_purge() is also calling skb_orphan() on all skb.
>
> And no, sock_put() does not free the socket.
> We release a refcount that was acquired when we did the socket lookup.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: do sanity checks before migrating the asoc
Date: Tue, 19 Jan 2016 13:59:00 -0200
Message-ID: <569E5D44.5000103@gmail.com>
References: <CACT4Y+Z6jY_n_cpmbFz366=JzoLX=u4Zc_o8gHFwJw8ApKf4zw@mail.gmail.com>
 <10616913996c7a4cbe8a2bb23cf4e78fcfa0a13a.1452891824.git.marcelo.leitner@gmail.com>
 <569E45FD.4040801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, dvyukov@google.com,
	eric.dumazet@gmail.com, syzkaller@googlegroups.com, kcc@google.com,
	glider@google.com, sasha.levin@oracle.com
To: Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33599 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932168AbcASP7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 10:59:08 -0500
In-Reply-To: <569E45FD.4040801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 19-01-2016 12:19, Vlad Yasevich escreveu:
> On 01/15/2016 04:40 PM, Marcelo Ricardo Leitner wrote:
>> On Fri, Jan 15, 2016 at 08:11:03PM +0100, Dmitry Vyukov wrote:
>>> On Fri, Jan 15, 2016 at 7:46 PM, Marcelo Ricardo Leitner
>>> <marcelo.leitner@gmail.com> wrote:
>>>> On Wed, Dec 30, 2015 at 09:42:27PM +0100, Dmitry Vyukov wrote:
>>>>> Hello,
>>>>>
>>>>> The following program leads to a leak of two sock objects:
>>>> ...
>>>>>
>>>>> On commit 8513342170278468bac126640a5d2d12ffbff106 (Dec 28).
>>>>
>>>> I'm afraid I cannot reproduce this one?
>>>> I enabled dynprintk at sctp_destroy_sock and it does print twice when I
>>>> run this test app.
>>>> Also added debugs to check association lifetime, and then it was
>>>> destroyed. Same for endpoint.
>>>>
>>>> Checking with trace-cmd, both calls to sctp_close() resulted in
>>>> sctp_destroy_sock() being called.
>>>>
>>>> As for sock_hold/put, they are matched too.
>>>>
>>>> Ideas? Log is below for double checking
>>>
>>>
>>> Hummm... I can reproduce it pretty reliably.
>>>
>>> [  197.459024] kmemleak: 11 new suspected memory leaks (see
>>> /sys/kernel/debug/kmemleak)
>>> [  307.494874] kmemleak: 409 new suspected memory leaks (see
>>> /sys/kernel/debug/kmemleak)
>>> [  549.784022] kmemleak: 125 new suspected memory leaks (see
>>> /sys/kernel/debug/kmemleak)
>>>
>>> I double checked via /proc/slabinfo:
>>>
>>> SCTPv6              4373   4420   2368   13    8 : tunables    0    0
>>>    0 : slabdata    340    340      0
>>>
>>> SCTPv6 starts with almost 0, but grows infinitely while I run the
>>> program in a loop.
>>>
>>> Here is my SCTP related configs:
>>>
>>> CONFIG_IP_SCTP=y
>>> CONFIG_NET_SCTPPROBE=y
>>> CONFIG_SCTP_DBG_OBJCNT=y
>>> # CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
>>> # CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
>>> CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE=y
>>> # CONFIG_SCTP_COOKIE_HMAC_MD5 is not set
>>> # CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
>>>
>>> I am on commit 67990608c8b95d2b8ccc29932376ae73d5818727 and I don't
>>> seem to have any sctp-related changes on top.
>>
>> Ok, now I can. Enabled slub debugs, now I cannot see calls to
>> sctp_destroy_sock. I see to sctp_close, but not to sctp_destroy_sock.
>>
>> And SCTPv6 grew by 2 sockets after the execution.
>>
>> Further checking, it's a race within SCTP asoc migration:
>> thread 0                thread 1
>> - app creates a sock
>>                          - sends a packet to itself
>> 			  - sctp will create an asoc and do implicit
>> 			    handshake
>> 			  - send the packet
>> - listen()
>> - accept() is called and
>>    that asoc is migrated
>>                   - packet is delivered
>>                     - skb->destructor is called, BUT:
>>
>> (note that if accept() is called after packet is delivered and skb is freed, it
>> doesn't happen)
>>
>> static void sctp_wfree(struct sk_buff *skb)
>> {
>>          struct sctp_chunk *chunk = skb_shinfo(skb)->destructor_arg;
>>          struct sctp_association *asoc = chunk->asoc;
>>          struct sock *sk = asoc->base.sk;
>> ...
>>          atomic_sub(sizeof(struct sctp_chunk), &sk->sk_wmem_alloc);
>>
>> and it's pointing to the new socket already. So one socket gets a leak
>> on sk_wmem_alloc and another gets a negative value:
>>
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -1537,12 +1537,14 @@ static void sctp_close(struct sock *sk, long timeout)
>>          /* Hold the sock, since sk_common_release() will put sock_put()
>>           * and we have just a little more cleanup.
>>           */
>> +       printk("%s sock_hold %p\n", __func__, sk);
>>          sock_hold(sk);
>>          sk_common_release(sk);
>>
>>          bh_unlock_sock(sk);
>>          spin_unlock_bh(&net->sctp.addr_wq_lock);
>>
>> +       printk("%s sock_put %p %d %d\n", __func__, sk, atomic_read(&sk->sk_refcnt), atomic_read(&sk->sk_wmem_alloc));
>>          sock_put(sk);
>>
>>          SCTP_DBG_OBJCNT_DEC(sock);
>>
>>
>> gave me:
>>
>> [   99.456944] sctp_close sock_hold ffff880137df8940
>> ...
>> [   99.457337] sctp_close sock_put ffff880137df8940 1 -247
>> [   99.458313] sctp_close sock_hold ffff880137dfef00
>> ...
>> [   99.458383] sctp_close sock_put ffff880137dfef00 1 249
>>
>> That's why the socket is not freed..
>>
>
> Interesting...  sctp_sock_migrate() accounts for this race in the
> receive buffer, but not the send buffer.
>
> On the one hand I am not crazy about the connect-to-self scenario.
> On the other, I think to support it correctly, we should support
> skb migrations for the send case just like we do the receive case.


Yes, not thrilled here either about connect-to-self.

But there is a big difference on how both works. For rx we can just look 
for wanted skbs in rx queue, as they aren't going anywhere, but for tx I 
don't think we can easily block sctp_wfree() call because that may be 
happening on another CPU (or am I mistaken here? sctp still doesn't have 
RFS but even irqbalance could affect this AFAICT) and more than one skb 
may be in transit at a time.

The lockings for this on sctp_chunk would be pretty nasty, I think, and 
normal usage lets say wouldn't be benefit from it. Considering the 
possible migration, as we can't trust chunk->asoc right away in 
sctp_wfree, the lock would reside in sctp_chunk and we would have to go 
on taking locks one by one on tx queue for the migration. Ugh ;)

Marcelo

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: do sanity checks before migrating the asoc
Date: Tue, 19 Jan 2016 18:08:48 -0200
Message-ID: <569E97D0.7050109@gmail.com>
References: <CACT4Y+Z6jY_n_cpmbFz366=JzoLX=u4Zc_o8gHFwJw8ApKf4zw@mail.gmail.com>
 <10616913996c7a4cbe8a2bb23cf4e78fcfa0a13a.1452891824.git.marcelo.leitner@gmail.com>
 <569E45FD.4040801@gmail.com> <569E5D44.5000103@gmail.com>
 <569E8280.9080701@gmail.com> <569E8F2F.5070906@gmail.com>
 <569E94CF.4030409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, dvyukov@google.com,
	eric.dumazet@gmail.com, syzkaller@googlegroups.com, kcc@google.com,
	glider@google.com, sasha.levin@oracle.com
To: Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:35277 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756018AbcASUIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 15:08:54 -0500
In-Reply-To: <569E94CF.4030409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 19-01-2016 17:55, Vlad Yasevich escreveu:
> On 01/19/2016 02:31 PM, Marcelo Ricardo Leitner wrote:
>> Em 19-01-2016 16:37, Vlad Yasevich escreveu:
>>> On 01/19/2016 10:59 AM, Marcelo Ricardo Leitner wrote:
>>>> Yes, not thrilled here either about connect-to-self.
>>>>
>>>> But there is a big difference on how both works. For rx we can just look for wanted skbs
>>>> in rx queue, as they aren't going anywhere, but for tx I don't think we can easily block
>>>> sctp_wfree() call because that may be happening on another CPU (or am I mistaken here?
>>>> sctp still doesn't have RFS but even irqbalance could affect this AFAICT) and more than
>>>> one skb may be in transit at a time.
>>>
>>> The way it's done now, we wouldn't have to block sctp_wfree.  Chunks are released under
>>> lock when they are acked, so we are OK here.  The tx completions will just put 1 byte back
>>> to the socket associated with the tx'ed skb, and that should still be ok as
>>> sctp_packet_release_owner will call sk_free().
>>
>> Please let me rephrase it. I'm actually worried about the asoc->base.sk part of the story
>> and how it's fetched in sctp_wfree(). I think we can update that sk pointer after
>> sock_wfree() has fetched it but not used it yet, possibly leading to accounting it twice,
>> one during migration and one on sock_wfree.
>> In sock_wfree() it will update some sk stats like sk->sk_wmem_alloc, among others.
>
> sctp_wfree() is only used on skbs that were created as sctp chunks to be transmitted.
> Right now, these skbs aren't actually submitted to the IP or to nic to be transmitted.
> They are queued at the association level (either in transports or in the outqueue).
> They are only freed during ACK processing.
>
> The ACK processing happens under a socket lock and thus asoc->base.sk can not move.
>
> The migration process also happens under a socket lock.  As a result, during migration
> we are guaranteed the chunk queues remain consistent and that asoc->base.sk linkage
> remains consistent.  In fact, if you look at the sctp_sock_migrate, we lock both
> sockets when we reassign the assoc->base.sk so we know both sockets are properly locked.
>
> So, I am not sure that what you are worried about can happen.  Please feel free to
> double-check the above of course.

Ohh, right. That makes sense. I'll rework the patch. Thanks Vlad.

   Marcelo

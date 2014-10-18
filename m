From: Weiping Pan <panweiping3@gmail.com>
Subject: Re: [PATCH] tcp: refine autocork condition check
Date: Sat, 18 Oct 2014 17:22:09 +0800
Message-ID: <54423141.2040800@gmail.com>
References: <8e0610510498c7f6ecbe2e99ab6044030f93f792.1413369212.git.panweiping3@gmail.com> <1413373669.17365.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:53534 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbaJRJWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 05:22:15 -0400
Received: by mail-pd0-f173.google.com with SMTP id g10so2123999pdj.4
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 02:22:15 -0700 (PDT)
In-Reply-To: <1413373669.17365.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 10/15/2014 07:47 PM, Eric Dumazet wrote:
> On Wed, 2014-10-15 at 18:34 +0800, Weiping Pan wrote:
>> Inspired by commit b2532eb9abd8 (tcp: fix ooo_okay setting vs Small Queues).
>>
>> The last check in tcp_should_autocork() was meant to check that whether we
>> only have an ACK in Qdisc/NIC queues, or if TX completion was delayed after we
>> processed ACK packet, if so, we should push the packet immediately instead of
>> corking it.
>> Therefore we should compare sk_wmem_alloc with SKB_TRUESIZE(1) instead of
>> skb->truesize.
>>
>> After this patch, tcp should have more chances to be corked, and the
>> performance should be a little better.  And netperf shows that this patch
>> works as expected.
>>
>> ./super_netperf.sh 300 -H 10.16.42.249 -t TCP_STREAM -- -m 1 -M 1
>> 	      speed	TCPAutoCorking
>> Before patch: 169.38    222278
>> After patch:  173.27    232988
>>
> I do not see how this patch changes anything on this workload, I suspect
> noise in your tests ? Full nstat output would give some hints maybe.
>
> TCP_STREAM netperfs send no ACK packets at all.
>
> I am concerned that this patch adds some latencies, and this wont be
> seen with your TCP_STREAM test.
>
> Autocorking is a trade off between throughput and latencies.
>
> We need extensive tests, using TCP_RR with various sizes.
With different packet size (1 128 1024 4096 10240 65536 131072),
TCP_RR test shows that the throughput does not have much difference,
and so with CPU usage and  TCPAutoCorking times.

I thought pure ack would block the next data packet, but actually it is not.
I think that is because  pure ack is sent out before the next data 
packet is ready for transmit,
or it can be piggybacked.

>
> Existing behavior is telling that if a prior packet is in qdisc, and
> this skb has a bigger truesize, we do not autocork.
>
>
> In practice, you might hold now packets that are quite big, (more than
> SKB_WITH_OVERHEAD(2048 - MAX_TCP_HEADER) bytes of payload.
>
> Typical cases is applications using two writes, one to send a small
> header, one for the body of the request/answer.

> Existing code is better because we allow the second send() to be pushed
> to the qdisc/NIC, before first send is TX completed.
Agreed.

thanks
Weiping Pan

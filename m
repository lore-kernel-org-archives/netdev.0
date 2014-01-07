From: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
Subject: Re: single process receives own frames due to PACKET_MMAP
Date: Tue, 07 Jan 2014 14:16:03 +0100
Message-ID: <52CBFE13.8@aimvalley.nl>
References: <52B4465E.2090904@aimvalley.nl> <52CB34F9.6020906@aimvalley.nl> <52CBC991.8030701@redhat.com> <20140107110609.74f71979@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	uaca@alumni.uv.es
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mika.eatserver.nl ([195.20.9.75]:47458 "EHLO mika.eatserver.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751636AbaAGNRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 08:17:22 -0500
In-Reply-To: <20140107110609.74f71979@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/14 11:06, Jesper Dangaard Brouer wrote:
> On Tue, 07 Jan 2014 10:32:01 +0100
> Daniel Borkmann<dborkman@redhat.com>  wrote:
>
>> On 01/06/2014 11:58 PM, Norbert van Bolhuis wrote:
>>>
>>> Our application uses raw AF_PACKET socket to send and receive
>>> on one particular ethernet interface.
>>>
>>> Recently we started using PACKET_MMAP (TPACKET_V2). This makes
>>> the Appl use a TX socket and a RX socket.
>>> Both sockets are bound to the same (eth) interface. I noticed
>>> the RX socket receives all frames that are sent via the
>>> TX socket (same process, different thread). This I do not want.
>>>
>>> I know it is supposed to happen for different processes
>>> (otherwise wireshark won't work), but I did not expect it to
>>> happen for one single process (with different threads).
>>>
>>> I can filter them out in user-space (PACKET_OUTGOING)
>>> or via kernel packet filter (SO_ATTACH_FILTER), but performance is
>>> critical.
>>>
>>> I wonder whether this (PACKET_MMAP) behaviour is OK.
>>
>> For your use-case, we recently introduced in d346a3fae3ff1
>> ("packet: introduce PACKET_QDISC_BYPASS socket option") a
>> bypass of dev_queue_xmit() (that internally invokes
>> dev_queue_xmit_nit()).
>>
>>> It did not happen before (with a non-PACKET_MMAP AF_PACKET socket
>>> which was used by both threads of the same Appl process). So
>>> why is it happening now ?
>>
>> Can you elaborate a bit on which kernel versions that behaviour
>> changed?


Sorry, I wasn't very clear. This does not regard kernel (versions).
With "before" I mean our previous version of our application which
used an AF_PACKET socket, but not the PACKET_MMAP option.


>>
>>> I'd say it makes no sense to make the same process receive its
>>> own transmitted frames on that same interface (unless its lo).
>
> Have you setup:
>   ring->s_ll.sll_protocol = 0
>
> This is what I did in trafgen to avoid this problem.
>
> See line 55 in netsniff-ng/ring.c:
>   https://github.com/borkmann/netsniff-ng/blob/c3602a995b21e8133c7f4fd1fb1e7e21b6a844f1/ring.c#L55
>
> Commit:
>   https://github.com/borkmann/netsniff-ng/commit/c3602a995b21e8133c7f4fd1fb1e7e21b6a844f1
>


No I did not do that, I was checking my code against netsniff-ng-0.5.8-rc4.

But I just tried it, I believe I do the same as netsniff-ng-0.5.8-rc5, but it doesn't
work for me. Maybe because I have an old FC14 system (kernel 2.6.35.14-106.fc14.x86_64).

So I tried to see whether netsniff-ng-0.5.8-rc5/trafgen still makes the
kernel call packet_rcv() on my FC14 system. So I build and run it, but I'm not sure
how to (easily) check that. In anyway, Wireshark does capture the trafgen generated
frames, does that say anything ?

In the future, I can at least use PACKET_QDISC_BYPASS as a "workaround".

Thanks a lot for your answers.

---
Norbert

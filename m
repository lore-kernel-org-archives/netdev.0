From: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
Subject: Re: single process receives own frames due to PACKET_MMAP
Date: Tue, 07 Jan 2014 16:16:49 +0100
Message-ID: <52CC1A61.5080205@aimvalley.nl>
References: <52B4465E.2090904@aimvalley.nl> <52CB34F9.6020906@aimvalley.nl> <52CBC991.8030701@redhat.com> <20140107110609.74f71979@redhat.com> <52CBFE13.8@aimvalley.nl> <20140107150938.1058b358@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	uaca@alumni.uv.es
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mika.eatserver.nl ([195.20.9.75]:51061 "EHLO mika.eatserver.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751000AbaAGPSD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 10:18:03 -0500
In-Reply-To: <20140107150938.1058b358@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/14 15:09, Jesper Dangaard Brouer wrote:
>
> On Tue, 07 Jan 2014 14:16:03 +0100
> Norbert van Bolhuis<nvbolhuis@aimvalley.nl>  wrote:
>> On 01/07/14 11:06, Jesper Dangaard Brouer wrote:
>>> On Tue, 07 Jan 2014 10:32:01 +0100
>>> Daniel Borkmann<dborkman@redhat.com>   wrote:
>>>
>>>> On 01/06/2014 11:58 PM, Norbert van Bolhuis wrote:
>>>>>
> [...]
>>>>
>>>>> I'd say it makes no sense to make the same process receive its
>>>>> own transmitted frames on that same interface (unless its lo).
>>>
>>> Have you setup:
>>>    ring->s_ll.sll_protocol = 0
>>>
>>> This is what I did in trafgen to avoid this problem.
>>>
>>> See line 55 in netsniff-ng/ring.c:
>>>    https://github.com/borkmann/netsniff-ng/blob/c3602a995b21e8133c7f4fd1fb1e7e21b6a844f1/ring.c#L55
>>>
>>> Commit:
>>>    https://github.com/borkmann/netsniff-ng/commit/c3602a995b21e8133c7f4fd1fb1e7e21b6a844f1
>>>
>>
>>
>> No I did not do that, I was checking my code against netsniff-ng-0.5.8-rc4.
>>
>> But I just tried it, I believe I do the same as netsniff-ng-0.5.8-rc5, but it doesn't
>> work for me. Maybe because I have an old FC14 system (kernel 2.6.35.14-106.fc14.x86_64).
>>
>> So I tried to see whether netsniff-ng-0.5.8-rc5/trafgen still makes the
>> kernel call packet_rcv() on my FC14 system. So I build and run it, but I'm not sure
>> how to (easily) check that.
>
> The easiest way is to:
>    cat /proc/net/ptype
> And look if someone registered a proto handler/function: packet_rcv (or tpacket_rcv).
>
> The more exact method is, to run "perf record -a -g" and then look (at
> the result with "perf report") for a lock contention, and "expand" the
> spin_lock and see if packet_rcv() is calling this spin lock.
>


I checked the easy way.
Even on my old FC14 system the "protocol=0 patch" seems to make a difference
for trafgen.
Without the patch I see for each CPU in use by trafgen a "packet_rcv entry" in
/proc/net/ptype.
With the patch I see no additional "packet_rcv entry".

It could be my Appl is wrong or maybe the "protocol=0 patch" does not help.
I think the latter, afterall my Appl has, unlike trafgen, another RX
(AF_PACKET) socket.


>
>> In anyway, Wireshark does capture the trafgen generated
>> frames, does that say anything ?
>
> Be careful not to start a wireshark/tcpdump, at the sametime, as this
> will slow you down.
>
>> In the future, I can at least use PACKET_QDISC_BYPASS as a "workaround".
>
> And in the future with PACKET_QDISC_BYPASS, your wireshark will not
> catch these packets, remember that.
>


Yes, this is why I would love to see the "protocol=0 patch" work for my Appl.

So I will try my Appl with the latest net-next kernel to see if that makes
it work. Hopefully I can find some time in the next coming days, I will keep
you informed.

---
Norbert

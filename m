From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [RFC net-next 0/4] gianfar: Use separate NAPI for Tx confirmation
 processing
Date: Thu, 9 Aug 2012 18:07:10 +0300
Message-ID: <5023D21E.1000008@freescale.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com> <20120808162423.GC11043@windriver.com> <1344444267.28967.225.camel@edumazet-glaptop> <CAOy7UX2AW2w8TE0=7HGqRDJnX3Te5XZmW8UfC8F6HZg1RdWCYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Tomas Hruby <thruby@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe001.messaging.microsoft.com ([216.32.180.184]:56619
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030785Ab2HIPHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 11:07:23 -0400
In-Reply-To: <CAOy7UX2AW2w8TE0=7HGqRDJnX3Te5XZmW8UfC8F6HZg1RdWCYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/9/2012 2:06 AM, Tomas Hruby wrote:
> On Wed, Aug 8, 2012 at 9:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Wed, 2012-08-08 at 12:24 -0400, Paul Gortmaker wrote:
>>> [[RFC net-next 0/4] gianfar: Use separate NAPI for Tx confirmation processing] On 08/08/2012 (Wed 15:26) Claudiu Manoil wrote:
>>>
>>>> Hi all,
>>>> This set of patches basically splits the existing napi poll routine into
>>>> two separate napi functions, one for Rx processing (triggered by frame
>>>> receive interrupts only) and one for the Tx confirmation path processing
>>>> (triggerred by Tx confirmation interrupts only). The polling algorithm
>>>> behind remains much the same.
>>>>
>>>> Important throughput improvements have been noted on low power boards with
>>>> this set of changes.
>>>> For instance, for the following netperf test:
>>>> netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
>>>> yields a throughput gain from oscilating ~500-~700 Mbps to steady ~940 Mbps,
>>>> (if the Rx/Tx paths are processed on different cores), w/ no increase in CPU%,
>>>> on a p1020rdb - 2 core machine featuring etsec2.0 (Multi-Queue Multi-Group
>>>> driver mode).
>>>
>>> It would be interesting to know more about what was causing that large
>>> an oscillation -- presumably you will have it reappear once one core
>>> becomes 100% utilized.  Also, any thoughts on how the change will change
>>> performance on an older low power single core gianfar system (e.g.  83xx)?
>>
>> I also was wondering if this low performance could be caused by BQL
>>
>> Since TCP stack is driven by incoming ACKS, a NAPI run could have to
>> handle 10 TCP acks in a row, and resulting xmits could hit BQL and
>> transit on qdisc (Because NAPI handler wont handle TX completions in the
>> middle of RX handler)
>
> Does disabling BQL help? Is the BQL limit stable? To what value is it
> set? I would be very much interested in more data if the issue is BQL
> related.
>
> .
>

I agree that more tests should be run to investigate why gianfar under-
performs on the low power p1020rdb platform, and BQL seems to be
a good starting point (thanks for the hint). What I can say now is that
the issue is not apparent on p2020rdb, for instance, which is a more
powerful platform: the CPUs - 1200 MHz instead of 800 MHz; twice the
size of L2 cache (512 KB), greater bus (CCB) frequency ... On this
board (p2020rdb) the netperf test reaches 940Mbps both w/ and w/o these
patches.

For a single core system I'm not expecting any performance degradation,
simply because I don't see why the proposed napi poll implementation
would be slower than the existing one. I'll do some measurements on a
p1010rdb too (single core, CPU:800 MHz) and get back to you with the
results.

Thanks.
Claudiu

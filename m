From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC net-next PATCH V3 0/2] qdisc bulk dequeuing and utilizing
 delayed tailptr updates
Date: Fri, 19 Sep 2014 17:31:02 -0700
Message-ID: <CA+mtBx-t4nonk3XH4V2J=DBBZ5SJLkXp4mF8Cz=Gfm67cEn7tg@mail.gmail.com>
References: <20140919204706.3231.59125.stgit@dragon>
	<1411160360.26859.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>,
	Tino Reichardt <milky-kernel@mcmilk.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:36939 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756392AbaITAbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 20:31:04 -0400
Received: by mail-ie0-f170.google.com with SMTP id x19so1687811ier.1
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 17:31:03 -0700 (PDT)
In-Reply-To: <1411160360.26859.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 1:59 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-09-19 at 22:49 +0200, Jesper Dangaard Brouer wrote:
>> This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
>> from the qdisc layer, to implement dequeue bulking.
>>
>> RFC V3: Keeping the ball rolling.
>>
>> This patchset should now use BQL correctly.  I've done lots of testing
>> for Head-of-Line blocking issues that can occur due to requeue of a
>> SKB bulk list.  I've not been able to provoke any HoL blocking
>> situation, simply because BQL is doing such a good job, thus I'm
>> unable to "overshoot" HW/BQL limits with more than a single packet.
>>
>> This patch chooses a very conservative approach, as by default only
>> allowing dequeue of one extra packet, besides the normal dequeue.
>>
>> Open questions:
>>
>> - How do we expose tuning to userspace?
>>   Patch adds /proc/sys/net/core/qdisc_bulk_dequeue_limit but I don't like it...
>>   Per device tunable?
>>
>
> bql is using /sys, of course ;)
>
> # grep . /sys/class/net/eth1/queues/tx-0/byte_queue_limits/*
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/hold_time:1000
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/inflight:0
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit:113314
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit_max:1879048192
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit_min:0
>
> Maybe you could simply reuse byte_queue_limits/limit, I am not sure we
> need a specific tunable.
>
>
>> - Can/should we limit dequeue bulking to devices supporting BQL?
>>
>
> Yes please. This will be an incentive to get BQL on drivers.
>
I think we can refine the expectation a bit. Bulk qdisc dequeue should
work for devices that don't support BQL, but the packet dequeue limit
is fixed number of packets (we don't want to create new mechanisms to
track fragments or packets that are outstanding in device). However,
in order to get bulk device transmit for a device, I think it
reasonable to request that BQL is supported since whoever is adding
that is already mucking in driver TX path anyway.

Tom

>
>

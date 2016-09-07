From: Michal Soltys <soltys@ziu.info>
Subject: Re: XPS configuration question (on tg3)
Date: Thu, 8 Sep 2016 01:45:56 +0200
Message-ID: <606e134e-ef0b-1b01-e8ec-8c0922172e53@ziu.info>
References: <5b9c6d9d-6905-e3ee-515f-cc68c63078f7@ziu.info>
 <CAKgT0Ud3bRbi0muyB-0nRTS-NbimrgxzhG0cop1bs6MhrV2V-A@mail.gmail.com>
 <6d222016-5ec5-7805-08f3-82844b49c872@ziu.info>
 <1473207563.10725.22.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:38596 "EHLO drutsystem.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751824AbcIGXqF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 19:46:05 -0400
In-Reply-To: <1473207563.10725.22.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-09-07 02:19, Eric Dumazet wrote:
> On Tue, 2016-09-06 at 23:00 +0200, Michal Soltys wrote:
>> On 2016-09-06 22:21, Alexander Duyck wrote:
>> > On Tue, Sep 6, 2016 at 11:46 AM, Michal Soltys <soltys@ziu.info> wrote:
>> >> Hi,
>> >>
>> >> I've been testing different configurations and I didn't manage to get XPS to "behave" correctly - so I'm probably misunderstanding or forgetting something. The nic in question (under tg3 driver - BCM5720 and BCM5719 models) was configured to 3 tx and 4 rx queues. 3 irqs were shared (tx and rx), 1 was unused (this got me scratching my head a bit) and the remaining one was for the last rx (though due to another bug recently fixed the 4th rx queue was inconfigurable on receive side). The names were: eth1b-0, eth1b-txrx-1, eth1b-txrx-2, eth1b-txrx-3, eth1b-rx-4.
>> >>
>> >> The XPS was configured as:
>> >>
>> >> echo f >/sys/class/net/eth1b/queues/tx-0/xps_cpus
>> >> echo f0 >/sys/class/net/eth1b/queues/tx-1/xps_cpus
>> >> echo ff00 >/sys/class/net/eth1b/queues/tx-2/xps_cpus
>> >>
>> >> So as far as I understand - cpus 0-3 should be allowed to use tx-0 queue only, 4-7 tx-1 and 8-15 tx-2.
>> >>
>> >> Just in case rx side could get in the way as far as flows go, relevant irqs were pinned to specific cpus - txrx-1 to 2, txrx-2 to 4, txrx-3 to 10 - falling into groups defined by the above masks.
>> >>
>> >> I tested both with mq and multiq scheduler, essentially either this:
>> >>
>> >> qdisc mq 2: root
>> >> qdisc pfifo_fast 0: parent 2:1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>> >> qdisc pfifo_fast 0: parent 2:2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>> >> qdisc pfifo_fast 0: parent 2:3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>> >>
>> >> or this (for the record, skbaction queue_mapping was behaving correctly with the one below):
>> >>
>> >> qdisc multiq 3: root refcnt 6 bands 3/5
>> >> qdisc pfifo_fast 31: parent 3:1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>> >> qdisc pfifo_fast 32: parent 3:2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>> >> qdisc pfifo_fast 33: parent 3:3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>> >>
>> >> Now, do I understand correctly, that under the above setup - commands such as
>> >>
>> >> taskset 400 nc -p $prt host_ip 12345 </dev/zero
>> >> or
>> >> yancat -i /dev/zero -o t:host_ip:12345 -u 10 -U 10
>> >>
>> >> ITOW - pinning simple nc command on cpu #10 (or using a tool that supports affinity by itself) and sending data to some other host on the net - should *always* use tx-2 queue ?
>> >> I also tested variation such as: taskset 400 nc -l -p host_ip 12345 </dev/zero (just in case taskset was "too late" with the affinity).
>> >>
>> >> In my case, what queue it used was basically random (on top of that it sometimes changed the used queue mid-transfer) what could be easily confirmed through both /proc/interrupts and tc -s qdisc show. And I'm a bit at loss now, as I though xps configuration should be absolute.
>> >>
>> >> Well, I'd be greatful for some pointers / hints.
>> > 
>> > So it sounds like you have everything configured correctly.  The one
>> > question I would have is if we are certain the CPU pinning is working
>> > for the application.  You might try using something like perf to
>> > verify what is running on CPU 10, and what is running on the CPUs that
>> > the queues are associated with.
>> > 
>> 
>> I did verify with 'top' in this case. I'll double check tommorow just to
>> be sure. Other than testing, there was nothing else running on the machine.
>> 
>> > Also after you have configured things you may want to double check and
>> > verify the xps_cpus value is still set.  I know under some
>> > circumstances the value can be reset by a device driver if the number
>> > of queues changes, or if the interface toggles between being
>> > administratively up/down.
>> 
>> Hmm, none of this was happening during tests.
>> 
>> Are there any other circumstances where xps settings could be ignored or
>> changed during the test (that is during the actual transfer, not between
>> separate attempts) ?
>> 
>> One thing I'm a bit afraid is that kernel was not exactly the newest
>> (3.16), maybe I'm missing some crucial fixes, though xps was added much
>> earlier than that. Either way, I'll try to redo tests with current
>> kernel tommorow.
>> 
> 
> Keep in mind that TCP stack can send packets, responding to incoming
> ACK.
> 
> So you might check that incoming ACK are handled by the 'right' cpu.
> 
> Without RFS, there is no such guarantee.
> 
> echo 32768 >/proc/sys/net/core/rps_sock_flow_entries
> echo 8192 >/sys/class/net/eth1/queues/rx-0/rps_flow_cnt
> echo 8192 >/sys/class/net/eth1/queues/rx-1/rps_flow_cnt
> echo 8192 >/sys/class/net/eth1/queues/rx-2/rps_flow_cnt
> echo 8192 >/sys/class/net/eth1/queues/rx-3/rps_flow_cnt
> 

Did some more testing today, indeed RFS helped with TCP flows, but ....
it got me wondering:

In scenario such as: XPS off, RFS/RPS off, irqs pinned, process
transfering data pinned - one tx queue was chosen (through hash) and
consistently persisted throughout the whole transfer. No exceptions, at
least none in the tests I did.

When XPS is getting enabled, the only thing that changes is that instead
of using hash to select one of available queues, the cpu running process
is specifically told which queue it can use (and eventually selects one
through hash if more than one is available). Shouldn't the choice
persist throughout the transfer as well then ?

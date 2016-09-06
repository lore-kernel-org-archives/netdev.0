From: Michal Soltys <soltys@ziu.info>
Subject: XPS configuration question (on tg3)
Date: Tue, 6 Sep 2016 20:46:52 +0200
Message-ID: <5b9c6d9d-6905-e3ee-515f-cc68c63078f7@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:34114 "EHLO drutsystem.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755253AbcIFSrB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 14:47:01 -0400
Received: from [10.0.0.2] (89-65-85-89.dynamic.chello.pl [89.65.85.89])
        (Authenticated sender: nozo)
        by drutsystem.com (Postfix) with ESMTPA id 6BD1AD1EBA
        for <netdev@vger.kernel.org>; Tue,  6 Sep 2016 20:46:52 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've been testing different configurations and I didn't manage to get XPS to "behave" correctly - so I'm probably misunderstanding or forgetting something. The nic in question (under tg3 driver - BCM5720 and BCM5719 models) was configured to 3 tx and 4 rx queues. 3 irqs were shared (tx and rx), 1 was unused (this got me scratching my head a bit) and the remaining one was for the last rx (though due to another bug recently fixed the 4th rx queue was inconfigurable on receive side). The names were: eth1b-0, eth1b-txrx-1, eth1b-txrx-2, eth1b-txrx-3, eth1b-rx-4.

The XPS was configured as:

echo f >/sys/class/net/eth1b/queues/tx-0/xps_cpus
echo f0 >/sys/class/net/eth1b/queues/tx-1/xps_cpus
echo ff00 >/sys/class/net/eth1b/queues/tx-2/xps_cpus

So as far as I understand - cpus 0-3 should be allowed to use tx-0 queue only, 4-7 tx-1 and 8-15 tx-2.

Just in case rx side could get in the way as far as flows go, relevant irqs were pinned to specific cpus - txrx-1 to 2, txrx-2 to 4, txrx-3 to 10 - falling into groups defined by the above masks.

I tested both with mx and multiq scheduler, essentially either this:

qdisc mq 2: root
qdisc pfifo_fast 0: parent 2:1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent 2:2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent 2:3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 

or this (for the record, skbaction queue_mapping was behaving correctly with the one below):

qdisc multiq 3: root refcnt 6 bands 3/5
qdisc pfifo_fast 31: parent 3:1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 32: parent 3:2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 33: parent 3:3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 

Now, do I understand correctly, that under the above setup - commands such as

taskset 400 nc -p $prt host_ip 12345 </dev/zero
or
yancat -i /dev/zero -o t:host_ip:12345 -u 10 -U 10

ITOW - pinning simple nc command on cpu #10 (or using a tool that supports affinity by itself) and sending data to some other host on the net - should *always* use tx-2 queue ?
I also tested variation such as: taskset 400 nc -l -p host_ip 12345 </dev/zero (just in case taskset was "too late" with the affinity).

In my case, what queue it used was basically random (on top of that it sometimes changed the used queue mid-transfer) what could be easily confirmed through both /proc/interrupts and tc -s qdisc show. And I'm a bit at loss now, as I though xps configuration should be absolute.

Well, I'd be greatful for some pointers / hints.

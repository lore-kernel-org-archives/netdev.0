From: Greg <gvrose8192@gmail.com>
Subject: Re: Intel Ethernet driver igb causes huge latencies with cyclictest
 (rt-tests)
Date: Wed, 05 Oct 2016 07:04:42 -0700
Message-ID: <1475676282.3279.8.camel@gmail.com>
References: <d18971eee9ad4d13b8f59304063b932a@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33499 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752516AbcJEOEo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 10:04:44 -0400
Received: by mail-pf0-f172.google.com with SMTP id 190so41843571pfv.0
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2016 07:04:44 -0700 (PDT)
In-Reply-To: <d18971eee9ad4d13b8f59304063b932a@FE-MBX1012.de.bosch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-10-05 at 08:29 +0000, Koehrer Mathias (ETAS/ESW5) wrote:
> Hi all,
> 
> I noticed that with fairly new versions of the Linux kernel, the igb driver
> causes huge latencies with the cyclictest in a RT_PREEMPT environment.
> The root cause seems to be the number of interrupts that are used for the igb
> NIC devices as multiple of these irqs may occur at the same time (see below).
> 
> With the kernel 4.6.7-rt14 the igb uses 9 (!) irqs per NIC on an Intel Core i7 PC (x86-64):
> E.g. eth2, and eth2-TxRx-0, eth2-TxRx-1, ... , eth2-TxRx-7.
> 
> Running the very same machine with kernel 3.18.27-rt27 there are only 2 irqs:
> eth2 and eth2-TxRx0
> 
> The issue with the many irqs is now that they are all fired roughly the same time
> even if the link is down as nothing is connected to the NIC.
> I analyzed the execution of the cyclictest tool using the kernel tracer on kernel 4.6.7-rt14:
> 
> kworker/-5       0dN.h2.. 1504647372us : sched_wakeup: comm=cyclictest pid=5887 prio=19 target_cpu=000
> kworker/-5       0dN.h3.. 1504647374us : sched_wakeup: comm=irq/54-eth2-TxR pid=5883 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647375us : sched_wakeup: comm=irq/53-eth2-TxR pid=5882 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647377us : sched_wakeup: comm=irq/52-eth2-TxR pid=5881 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647378us : sched_wakeup: comm=irq/51-eth2-TxR pid=5880 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647380us : sched_wakeup: comm=irq/50-eth2-TxR pid=5879 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647381us : sched_wakeup: comm=irq/49-eth2-TxR pid=5878 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647382us : sched_wakeup: comm=irq/48-eth2-TxR pid=5877 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647383us : sched_wakeup: comm=irq/47-eth2-TxR pid=5876 prio=49 target_cpu=000
> kworker/-5       0d...2.. 1504647384us : sched_switch: prev_comm=kworker/0:0 prev_pid=5 prev_prio=120 prev_state=R+ ==> next_comm=cyclictest next_pid=5887 next_prio=19
> 
> Here it can be clearly seen that eight irqs from the igb are coming in at the same time.
> This leads to a fairly long phase of running in irq mode which hurts the real time latency.
> 
> In my setup I have no cable connected to the eth2,
> I do a 
> # modprobe igb
> # ifconfig eth2 up 192.168.100.111
> 
> I did multiple tests with analyzing and modifying the igb driver.
> The function "igb_watchdog_task" seems to be the root cause of the issue.
> Whenever I disable this function the cyclictest shows great results.
> 
> There has been lengthy discussion on that topic on the rt-users mailing list:
> http://marc.info/?t=147454836600003&r=1&w=2 
> 
> My question is now:
> How can I either use only 1 irq per NIC using the igb driver or how can 
> the driver be reorganized to let the watchdog task trigger the irqs alternately.

Have you tried the ethtool channel command to reduce the number of
queues/channels?  I don't have an Intel part but I can do this with a
broadcom:

[root@galilei ~]# ethtool -l em1
Channel parameters for em1:
Pre-set maximums:
RX:             4
TX:             4
Other:          0
Combined:       0
Current hardware settings:
RX:             4
TX:             1
Other:          0
Combined:       0

[root@galilei ~]# grep em1 /proc/interrupts
 38:         16          2          2     145912  IR-PCI-MSI-edge
em1-tx-0
 39:      80893      29784          2          0  IR-PCI-MSI-edge
em1-rx-1
 40:      76123     281434          1          0  IR-PCI-MSI-edge
em1-rx-2
 41:          5          0     240184          0  IR-PCI-MSI-edge
em1-rx-3
 42:          2          1          0      16132  IR-PCI-MSI-edge
em1-rx-4

[root@galilei ~]# ethtool -L em1 rx 2 tx 2
[root@galilei ~]# grep em1 /proc/interrupts
 38:          2          0          0          0  IR-PCI-MSI-edge
em1-0
 39:         54          2          0          0  IR-PCI-MSI-edge
em1-txrx-1
 40:         71          0          1          0  IR-PCI-MSI-edge
em1-txrx-

Give it a try and see if it helps.

- Greg


> 
> Thanks for any feedback
> 
> Regards
> 
> Mathias

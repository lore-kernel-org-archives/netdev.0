From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: bond + tc regression ?
Date: Tue, 5 May 2009 20:41:35 +0300
Message-ID: <20090505174135.GA29716@francoudi.com>
References: <1241538358.27647.9.camel@hazard2.francoudi.com> <4A0069F3.5030607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:2749 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbZEERll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 13:41:41 -0400
Content-Disposition: inline
In-Reply-To: <4A0069F3.5030607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > On both kernels, the system is running with at least 70% idle CPU.
> > The network interrupts are distributed accross the cores.
> 
> You should not distribute interrupts, but bound a NIC to one CPU

Kernels 2.6.28 and 2.6.29 do this by default, so I thought its correct.
The defaults are wrong?

I have tried with IRQs bound to one CPU per NIC. Same result.

> > I thought it was a e1000e driver issue, but tweaking e1000e ring buffers
> > didn't help. I tried using e1000 on 2.6.28 by adding necessary PCI IDs,
> > I tried running on a different server with bnx cards, I tried disabling
> > NO_HZ and HRTICK, but still I have the same problem.
> > 
> > However, if I don't utilize bond, but just apply rules on normal ethX
> > interfaces, there is no packet loss with 2.6.28/29. 
> > 
> > So, the problem appears only when I use 2.6.28/29 + bond + classful tc
> > combination. 
> > 
> > Any ideas ?
> > 
> 
> Yes, we need much more information :)
> Is it a forwarding setup only ?

Yes, the server is doing nothing else but forwarding, no iptables.

> cat /proc/interrupts

           CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6       CPU7
  0:        130          0          0          0          0          0          0          0   IO-APIC-edge      timer
  1:          2          0          0          0          0          0          0          0   IO-APIC-edge      i8042
  3:          0          0          0          1          0          1          0          0   IO-APIC-edge
  4:          0          0          1          0          0          0          1          0   IO-APIC-edge
  9:          0          0          0          0          0          0          0          0   IO-APIC-fasteoi   acpi
 12:          4          0          0          0          0          0          0          0   IO-APIC-edge      i8042
 14:          0          0          0          0          0          0          0          0   IO-APIC-edge      ata_piix
 15:          0          0          0          0          0          0          0          0   IO-APIC-edge      ata_piix
 17:      30901      31910      31446      30655      31618      30550      31543      30958   IO-APIC-fasteoi   aacraid
 20:          0          0          0          0          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
 21:          0          0          0          0          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb5, ahci
 22:     298387     297642     295508     294368     295533     295430     295275     296036   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb2
 23:      10868      10926      10980      10738      10939      10615      10761      10909   IO-APIC-fasteoi   uhci_hcd:usb3
 57: 1486251823 1486835830 1486677250 1487105983 1488000303 1485941815 1487728317 1486624997   PCI-MSI-edge      eth0
 58: 1510676329 1509708161 1510347202 1509969755 1508599471 1511220118 1509094578 1509727616   PCI-MSI-edge      eth1
 59: 1482578890 1483618556 1482963700 1483164528 1484561615 1482130645 1484116749 1483557717   PCI-MSI-edge      eth2
 60: 1507341647 1506685822 1506862759 1506612818 1505689367 1507559672 1505911622 1506940613   PCI-MSI-edge      eth3
NMI:          0          0          0          0          0          0          0          0   Non-maskable interrupts
LOC: 1020533656 1020535165 1020533613 1020534967 1020535173 1020534409 1020534985 1020534220   Local timer interrupts
RES:      18605      21215      15957      18637      22429      19493      16649      15589   Rescheduling interrupts
CAL:        160        214        186        185        199        205        190        180   Function call interrupts
TLB:     259515     264126     309016     312222     263163     265601     306189     305430   TLB shootdowns
TRM:          0          0          0          0          0          0          0          0   Thermal event interrupts
SPU:          0          0          0          0          0          0          0          0   Spurious interrupts
ERR:          0
MIS:          0

> tc -s -d qdisc

For test sake, I just put "tc qdisc add dev $IFACE root handle 1: prio" and no filters at all. 
I get the same with HTB "tc qdisc add dev $IFACE root handle 1: htb default 99" and no subclasses.

qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 13287736273644 bytes 1263672018 pkt (dropped 0, overlimits 0 requeues 2928480094)
 rate 0bit 0pps backlog 0b 0p requeues 2928480094
qdisc pfifo_fast 0: dev eth1 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 40064376195000 bytes 1747026586 pkt (dropped 0, overlimits 0 requeues 463621814)
 rate 0bit 0pps backlog 0b 0p requeues 463621814
qdisc pfifo_fast 0: dev eth2 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 13350145517965 bytes 1350897201 pkt (dropped 0, overlimits 0 requeues 2930879507)
 rate 0bit 0pps backlog 0b 0p requeues 2930879507
qdisc pfifo_fast 0: dev eth3 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 40193456126884 bytes 1950653764 pkt (dropped 0, overlimits 0 requeues 465511120)
 rate 0bit 0pps backlog 0b 0p requeues 465511120
qdisc prio 1: dev bond0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 985164834 bytes 2720991 pkt (dropped 241834, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc prio 1: dev bond1 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 2347118738 bytes 3089171 pkt (dropped 304601, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

** Drops on bond0/bond1 are increasing by approximately 5000 per second:

qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 13287874353796 bytes 1264050808 pkt (dropped 0, overlimits 0 requeues 2928520779)
 rate 0bit 0pps backlog 0b 0p requeues 2928520779
qdisc pfifo_fast 0: dev eth1 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 40064706826018 bytes 1747459793 pkt (dropped 0, overlimits 0 requeues 463669610)
 rate 0bit 0pps backlog 0b 0p requeues 463669610
qdisc pfifo_fast 0: dev eth2 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 13350283202695 bytes 1351277761 pkt (dropped 0, overlimits 0 requeues 2930918488)
 rate 0bit 0pps backlog 0b 0p requeues 2930918488
qdisc pfifo_fast 0: dev eth3 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 40193784868074 bytes 1951084029 pkt (dropped 0, overlimits 0 requeues 465558015)
 rate 0bit 0pps backlog 0b 0p requeues 465558015
qdisc prio 1: dev bond0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 1260929539 bytes 3480340 pkt (dropped 311145, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc prio 1: dev bond1 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 3006490946 bytes 3952643 pkt (dropped 396850, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

With same setup on 2.6.23, drops are increasing only by 50/sec or so.

As soon as I do "tc qdisc del dev $IFACE root", packet loss stops.

> cat /proc/net/bonding/bond0

Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer3+4 (1)
MII Status: up
MII Polling Interval (ms): 80
Up Delay (ms): 0
Down Delay (ms): 0

802.3ad info
LACP rate: slow
Aggregator selection policy (ad_select): stable
Active Aggregator Info:
        Aggregator ID: 1
        Number of ports: 2
        Actor Key: 17
        Partner Key: 4
        Partner Mac Address: 00:19:e7:b2:07:80

Slave Interface: eth0
MII Status: up
Link Failure Count: 1
Permanent HW addr: 00:1b:24:bd:e9:cc
Aggregator ID: 1

Slave Interface: eth2
MII Status: up
Link Failure Count: 1
Permanent HW addr: 00:1b:24:bd:e9:ce
Aggregator ID: 1

> cat /proc/net/bonding/bond1

Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer3+4 (1)
MII Status: up
MII Polling Interval (ms): 80
Up Delay (ms): 0
Down Delay (ms): 0

802.3ad info
LACP rate: slow
Aggregator selection policy (ad_select): stable
Active Aggregator Info:
        Aggregator ID: 2
        Number of ports: 2
        Actor Key: 17
        Partner Key: 5
        Partner Mac Address: 00:19:e7:b2:07:80

Slave Interface: eth1
MII Status: up
Link Failure Count: 1
Permanent HW addr: 00:1b:24:bd:e9:cd
Aggregator ID: 2

Slave Interface: eth3
MII Status: up
Link Failure Count: 2
Permanent HW addr: 00:1b:24:bd:e9:cf
Aggregator ID: 2


> mpstat -P ALL 10

08:04:36 PM  CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal   %idle    intr/s
08:04:46 PM  all    0.00    0.00    0.01    0.00    0.00    1.05    0.00   98.94  70525.73
08:04:46 PM    0    0.00    0.00    0.00    0.00    0.00    0.70    0.00   99.30   7814.41
08:04:46 PM    1    0.00    0.00    0.00    0.00    0.00    2.10    0.00   97.90   7814.41
08:04:46 PM    2    0.00    0.00    0.00    0.00    0.00    0.20    0.00   99.80   7814.41
08:04:46 PM    3    0.00    0.00    0.10    0.00    0.00    1.30    0.00   98.60   7814.51
08:04:46 PM    4    0.00    0.00    0.00    0.00    0.00    0.50    0.00   99.50   7814.41
08:04:46 PM    5    0.00    0.00    0.00    0.00    0.00    1.90    0.00   98.10   7814.41
08:04:46 PM    6    0.00    0.00    0.00    0.00    0.00    0.60    0.00   99.40   7814.41
08:04:46 PM    7    0.00    0.00    0.10    0.00    0.00    0.90    0.00   99.00   7814.51
08:04:46 PM    8    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00      0.00

08:04:46 PM  CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal   %idle    intr/s
08:04:56 PM  all    0.00    0.00    0.01    0.00    0.00    1.49    0.00   98.50  66429.30
08:04:56 PM    0    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00   7303.50
08:04:56 PM    1    0.00    0.00    0.00    0.00    0.00    1.60    0.00   98.40   7303.50
08:04:56 PM    2    0.00    0.00    0.00    0.00    0.00    1.20    0.00   98.80   7303.50
08:04:56 PM    3    0.00    0.00    0.00    0.00    0.00    3.20    0.00   96.80   7303.40
08:04:56 PM    4    0.00    0.00    0.00    0.00    0.00    1.90    0.00   98.10   7303.60
08:04:56 PM    5    0.00    0.00    0.00    0.00    0.00    1.20    0.00   98.80   7303.50
08:04:56 PM    6    0.00    0.00    0.10    0.00    0.00    1.80    0.00   98.10   7303.50
08:04:56 PM    7    0.00    0.00    0.00    0.00    0.00    1.20    0.00   98.80   7303.50
08:04:56 PM    8    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00      0.00

> ifconfig -a

bond0     Link encap:Ethernet  HWaddr 00:1B:24:BD:E9:CC
          inet addr:xxx.xxx.135.44  Bcast:xxx.xxx.135.47  Mask:255.255.255.248
          inet6 addr: fe80::21b:24ff:febd:e9cc/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:436076190 errors:0 dropped:391250 overruns:0 frame:0
          TX packets:2620156321 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:4210046233 (3.9 GiB)  TX bytes:2520272242 (2.3 GiB)

bond1     Link encap:Ethernet  HWaddr 00:1B:24:BD:E9:CD
          inet addr:xxx.xxx.70.156  Bcast:xxx.xxx.70.159  Mask:255.255.255.248
          inet6 addr: fe80::21b:24ff:febd:e9cd/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:239471641 errors:0 dropped:344 overruns:0 frame:0
          TX packets:3704083902 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2488754745 (2.3 GiB)  TX bytes:2685275089 (2.5 GiB)

eth0      Link encap:Ethernet  HWaddr 00:1B:24:BD:E9:CC
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:2235085582 errors:0 dropped:353786 overruns:0 frame:0
          TX packets:1266449269 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:3768096439 (3.5 GiB)  TX bytes:113363829 (108.1 MiB)
          Memory:fc6e0000-fc700000

eth1      Link encap:Ethernet  HWaddr 00:1B:24:BD:E9:CD
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:4228974804 errors:0 dropped:344 overruns:0 frame:0
          TX packets:1750216649 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:3350270261 (3.1 GiB)  TX bytes:3358220645 (3.1 GiB)
          Memory:fc6c0000-fc6e0000

eth2      Link encap:Ethernet  HWaddr 00:1B:24:BD:E9:CC
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:2495958020 errors:0 dropped:37464 overruns:0 frame:0
          TX packets:1353707165 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:442055526 (421.5 MiB)  TX bytes:2406943933 (2.2 GiB)
          Memory:fcde0000-fce00000

eth3      Link encap:Ethernet  HWaddr 00:1B:24:BD:E9:CD
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:305464222 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1953867360 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:3433479245 (3.1 GiB)  TX bytes:3622113909 (3.3 GiB)
          Memory:fcd80000-fcda0000

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:53537 errors:0 dropped:0 overruns:0 frame:0
          TX packets:53537 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:431006433 (411.0 MiB)  TX bytes:431006433 (411.0 MiB)


NOTE: ifconfig drops on bond0/bond1 are *NOT* increasing. These drops are there from before.

-- 
Best Regards
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel, Cyprus - www.prime-tel.com

From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH v2] net: Do not enable tx-nocache-copy by default
Date: Tue,  7 Jan 2014 10:11:10 -0500
Message-ID: <1389107470-18213-1-git-send-email-bpoirier@suse.de>
References: <20140106.200002.1747627391067832069.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Tom Herbert <therbert@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:35396 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbaAGPLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 10:11:23 -0500
In-Reply-To: <20140106.200002.1747627391067832069.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are many cases where this feature does not improve performance or=
 even
reduces it.

=46or example, here are the results from tests that I've run using 3.12=
=2E6 on one
Intel Xeon W3565 and one i7 920 connected by ixgbe adapters. The result=
s are
from the Xeon, but they're similar on the i7. All numbers report the
mean=C2=B1stddev over 10 runs of 10s.

1) latency tests similar to what is described in "c6e1a0d net: Allow no=
-cache
copy from user on transmit"
There is no statistically significant difference between tx-nocache-cop=
y
on/off.
nic irqs spread out (one queue per cpu)

200x netperf -r 1400,1
tx-nocache-copy off
        692000=C2=B11000 tps
        50/90/95/99% latency (us): 275=C2=B12/643.8=C2=B10.4/799=C2=B11=
/2474.4=C2=B10.3
tx-nocache-copy on
        693000=C2=B11000 tps
        50/90/95/99% latency (us): 274=C2=B11/644.1=C2=B10.7/800=C2=B12=
/2474.5=C2=B10.7

200x netperf -r 14000,14000
tx-nocache-copy off
        86450=C2=B180 tps
        50/90/95/99% latency (us): 334.37=C2=B10.02/838=C2=B11/2100=C2=B1=
20/3990=C2=B140
tx-nocache-copy on
        86110=C2=B160 tps
        50/90/95/99% latency (us): 334.28=C2=B10.01/837=C2=B12/2110=C2=B1=
20/3990=C2=B120

2) single stream throughput tests
tx-nocache-copy leads to higher service demand

                        throughput  cpu0        cpu1        demand
                        (Gb/s)      (Gcycle)    (Gcycle)    (cycle/B)

nic irqs and netperf on cpu0 (1x netperf -T0,0 -t omni -- -d send)

tx-nocache-copy off     9402=C2=B15      9.4=C2=B10.2                 0=
=2E80=C2=B10.01
tx-nocache-copy on      9403=C2=B13      9.85=C2=B10.04               0=
=2E838=C2=B10.004

nic irqs on cpu0, netperf on cpu1 (1x netperf -T1,1 -t omni -- -d send)

tx-nocache-copy off     9401=C2=B15      5.83=C2=B10.03   5.0=C2=B10.1 =
    0.923=C2=B10.007
tx-nocache-copy on      9404=C2=B12      5.74=C2=B10.03   5.523=C2=B10.=
009 0.958=C2=B10.002

As a second example, here are some results from Eric Dumazet with lates=
t
net-next.
tx-nocache-copy also leads to higher service demand

(cpu is Intel(R) Xeon(R) CPU X5660  @ 2.80GHz)

lpq83:~# ./ethtool -K eth0 tx-nocache-copy on
lpq83:~# perf stat ./netperf -H lpq84 -c
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpq84=
=2Eprod.google.com () port 0 AF_INET
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384  16384    10.00      9407.44   2.50     -1.00    0.522   =
-1.000

 Performance counter stats for './netperf -H lpq84 -c':

       4282.648396 task-clock                #    0.423 CPUs utilized
             9,348 context-switches          #    0.002 M/sec
                88 CPU-migrations            #    0.021 K/sec
               355 page-faults               #    0.083 K/sec
    11,812,797,651 cycles                    #    2.758 GHz            =
         [82.79%]
     9,020,522,817 stalled-cycles-frontend   #   76.36% frontend cycles=
 idle    [82.54%]
     4,579,889,681 stalled-cycles-backend    #   38.77% backend  cycles=
 idle    [67.33%]
     6,053,172,792 instructions              #    0.51  insns per cycle
                                             #    1.49  stalled cycles =
per insn [83.64%]
       597,275,583 branches                  #  139.464 M/sec          =
         [83.70%]
         8,960,541 branch-misses             #    1.50% of all branches=
         [83.65%]

      10.128990264 seconds time elapsed

lpq83:~# ./ethtool -K eth0 tx-nocache-copy off
lpq83:~# perf stat ./netperf -H lpq84 -c
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpq84=
=2Eprod.google.com () port 0 AF_INET
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384  16384    10.00      9412.45   2.15     -1.00    0.449   =
-1.000

 Performance counter stats for './netperf -H lpq84 -c':

       2847.375441 task-clock                #    0.281 CPUs utilized
            11,632 context-switches          #    0.004 M/sec
                49 CPU-migrations            #    0.017 K/sec
               354 page-faults               #    0.124 K/sec
     7,646,889,749 cycles                    #    2.686 GHz            =
         [83.34%]
     6,115,050,032 stalled-cycles-frontend   #   79.97% frontend cycles=
 idle    [83.31%]
     1,726,460,071 stalled-cycles-backend    #   22.58% backend  cycles=
 idle    [66.55%]
     2,079,702,453 instructions              #    0.27  insns per cycle
                                             #    2.94  stalled cycles =
per insn [83.22%]
       363,773,213 branches                  #  127.757 M/sec          =
         [83.29%]
         4,242,732 branch-misses             #    1.17% of all branches=
         [83.51%]

      10.128449949 seconds time elapsed

CC: Tom Herbert <therbert@google.com>
Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
---
 net/core/dev.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4fc1722..0e82e77 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5831,13 +5831,8 @@ int register_netdevice(struct net_device *dev)
 	dev->features |=3D NETIF_F_SOFT_FEATURES;
 	dev->wanted_features =3D dev->features & dev->hw_features;
=20
-	/* Turn on no cache copy if HW is doing checksum */
 	if (!(dev->flags & IFF_LOOPBACK)) {
 		dev->hw_features |=3D NETIF_F_NOCACHE_COPY;
-		if (dev->features & NETIF_F_ALL_CSUM) {
-			dev->wanted_features |=3D NETIF_F_NOCACHE_COPY;
-			dev->features |=3D NETIF_F_NOCACHE_COPY;
-		}
 	}
=20
 	/* Make NETIF_F_HIGHDMA inheritable to VLAN devices.
--=20
1.8.4

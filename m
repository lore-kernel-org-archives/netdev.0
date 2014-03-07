From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next v2 0/2] gianfar: Tx timeout issue
Date: Fri, 7 Mar 2014 14:42:44 +0200
Message-ID: <1394196166-24932-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:1973 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751669AbaCGMo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 07:44:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

There's an older Tx timeout issue showing up on etsec2 devices
with 2 CPUs.  I pinned this issue down to processing overhead
incurred by supporting multiple Tx/Rx rings, as explained in
the 2nd patch below.  But before this, there's also a concurency
issue leading to Rx/Tx spurrious interrupts, addressed by the
'Tx NAPI' patch below.
The Tx timeout can be triggered with multiple Tx flows,
'iperf -c -N 8' commands, on a 2 CPUs etsec2 based (P1020) board.

Before the patches:
"""
root@p1020rdb-pc:~# iperf -c 172.16.1.3 -n 1000M -P 8 &
[...]
root@p1020rdb-pc:~# NETDEV WATCHDOG: eth1 (fsl-gianfar): transmit queue 1 timed out
WARNING: at net/sched/sch_generic.c:279
Modules linked in:
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.13.0-rc3-03386-g89ea59c #23
task: ed84ef40 ti: ed868000 task.ti: ed868000
NIP: c04627a8 LR: c04627a8 CTR: c02fb270
REGS: ed869d00 TRAP: 0700   Not tainted  (3.13.0-rc3-03386-g89ea59c)
MSR: 00029000 <CE,EE,ME>  CR: 44000022  XER: 20000000
[...]

root@p1020rdb-pc:~# [ ID] Interval       Transfer     Bandwidth
[  5]  0.0-19.3 sec  1000 MBytes    434 Mbits/sec
[  8]  0.0-39.7 sec  1000 MBytes    211 Mbits/sec
[  9]  0.0-40.1 sec  1000 MBytes    209 Mbits/sec
[  3]  0.0-40.2 sec  1000 MBytes    209 Mbits/sec
[ 10]  0.0-59.0 sec  1000 MBytes    142 Mbits/sec
[  7]  0.0-74.6 sec  1000 MBytes    112 Mbits/sec
[  6]  0.0-74.7 sec  1000 MBytes    112 Mbits/sec
[  4]  0.0-74.7 sec  1000 MBytes    112 Mbits/sec
[SUM]  0.0-74.7 sec  7.81 GBytes    898 Mbits/sec

root@p1020rdb-pc:~# ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:04:9f:00:13:01  
          inet addr:172.16.1.1  Bcast:172.16.255.255  Mask:255.255.0.0
          inet6 addr: fe80::204:9fff:fe00:1301/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:708722 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8717849 errors:6 dropped:0 overruns:1470 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:58118018 (55.4 MiB)  TX bytes:274069482 (261.3 MiB)
          Base address:0xa000 

"""

After applying the patches:
"""
root@p1020rdb-pc:~# iperf -c 172.16.1.3 -n 1000M -P 8 &
[...]
root@p1020rdb-pc:~# [ ID] Interval       Transfer     Bandwidth
[  9]  0.0-70.5 sec  1000 MBytes    119 Mbits/sec
[  5]  0.0-70.5 sec  1000 MBytes    119 Mbits/sec
[  6]  0.0-70.7 sec  1000 MBytes    119 Mbits/sec
[  4]  0.0-71.0 sec  1000 MBytes    118 Mbits/sec
[  8]  0.0-71.1 sec  1000 MBytes    118 Mbits/sec
[  3]  0.0-71.2 sec  1000 MBytes    118 Mbits/sec
[ 10]  0.0-71.3 sec  1000 MBytes    118 Mbits/sec
[  7]  0.0-71.3 sec  1000 MBytes    118 Mbits/sec
[SUM]  0.0-71.3 sec  7.81 GBytes    942 Mbits/sec

root@p1020rdb-pc:~# ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:04:9f:00:13:01  
          inet addr:172.16.1.1  Bcast:172.16.255.255  Mask:255.255.0.0
          inet6 addr: fe80::204:9fff:fe00:1301/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:728446 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8690057 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:59732650 (56.9 MiB)  TX bytes:271554306 (258.9 MiB)
          Base address:0xa000 
"""


Thanks.
--
v2: PATCH 2:
    Replaced CPP check with run-time condition to
    limit the number of queues. Updated comments.

Claudiu Manoil (2):
  gianfar: Separate out the Tx interrupt handling (Tx NAPI)
  gianfar: Use Single-Queue polling for "fsl,etsec2"

 drivers/net/ethernet/freescale/gianfar.c | 274 ++++++++++++++++++++++---------
 drivers/net/ethernet/freescale/gianfar.h |  52 ++++--
 2 files changed, 232 insertions(+), 94 deletions(-)

-- 
1.7.11.7

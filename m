From: Niklas Cassel <niklas.cassel@axis.com>
Subject: network stream fairness
Date: Mon, 9 Nov 2015 16:41:32 +0100
Message-ID: <5640BEAC.10404@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:58930 "EHLO bes.se.axis.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805AbbKIPlh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2015 10:41:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a ethernet driver for a 100 Mbps NIC.
The NIC has dedicated hardware for offloading.
The driver has implemented TSO, GSO and BQL.
Since the CPU on the SoC is rather weak, I'd rather
not increase the CPU load by turning off offloading.

Since commit
605ad7f184b6 ("tcp: refine TSO autosizing")

the bandwidth is no longer fair between streams.
see output at the end of the mail, where I'm testing with 2 streams.


If I revert 605ad7f184b6 on 4.3, I get a stable 45 Mbps per stream.

I can also use vanilla 4.3 and do:
echo 3000 > /sys/class/net/eth0/queues/tx-0/byte_queue_limits/limit_max
to also get a stable 45 Mbps per stream.

My question is, am I supposed to set the BQL limit explicitly?
It is possible that I have missed something in my driver,
but my understanding is that the TCP stack sets and adjusts
the BQL limit automatically.


Perhaps the following info might help:

After running iperf3 on vanilla 4.3:
/sys/class/net/eth0/queues/tx-0/byte_queue_limits/
limit 89908
limit_max 1879048192

After running iperf3 on vanilla 4.3 + BQL explicitly set:
/sys/class/net/eth0/queues/tx-0/byte_queue_limits/
limit 3000
limit_max 3000

After running iperf3 on 4.3 + 605ad7f184b6 reverted:
/sys/class/net/eth0/queues/tx-0/byte_queue_limits/
limit 8886
limit_max 1879048192




Vanilla 4.3, no BQL limit explicitly set.

iperf3 -R -c 192.168.0.141 -t 240 -P 2
Connecting to host 192.168.0.141, port 5201
Reverse mode, remote host 192.168.0.141 is sending
[  4] local 192.168.0.1 port 50902 connected to 192.168.0.141 port 5201
[  6] local 192.168.0.1 port 50904 connected to 192.168.0.141 port 5201
[ ID] Interval           Transfer     Bandwidth
[  4]   0.00-1.00   sec  7.24 MBytes  60.7 Mbits/sec
[  6]   0.00-1.00   sec  3.56 MBytes  29.9 Mbits/sec
[SUM]   0.00-1.00   sec  10.8 MBytes  90.6 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   1.00-2.00   sec  7.40 MBytes  62.1 Mbits/sec
[  6]   1.00-2.00   sec  3.40 MBytes  28.5 Mbits/sec
[SUM]   1.00-2.00   sec  10.8 MBytes  90.6 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   2.00-3.00   sec  7.45 MBytes  62.5 Mbits/sec
[  6]   2.00-3.00   sec  3.36 MBytes  28.2 Mbits/sec
[SUM]   2.00-3.00   sec  10.8 MBytes  90.7 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   3.00-4.00   sec  7.72 MBytes  64.8 Mbits/sec
[  6]   3.00-4.00   sec  3.08 MBytes  25.9 Mbits/sec
[SUM]   3.00-4.00   sec  10.8 MBytes  90.7 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   4.00-5.00   sec  8.01 MBytes  67.2 Mbits/sec
[  6]   4.00-5.00   sec  2.80 MBytes  23.5 Mbits/sec
[SUM]   4.00-5.00   sec  10.8 MBytes  90.7 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   5.00-6.00   sec  7.91 MBytes  66.3 Mbits/sec
[  6]   5.00-6.00   sec  2.90 MBytes  24.3 Mbits/sec
[SUM]   5.00-6.00   sec  10.8 MBytes  90.7 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   6.00-7.00   sec  7.77 MBytes  65.2 Mbits/sec
[  6]   6.00-7.00   sec  3.04 MBytes  25.5 Mbits/sec
[SUM]   6.00-7.00   sec  10.8 MBytes  90.7 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   7.00-8.00   sec  6.99 MBytes  58.6 Mbits/sec
[  6]   7.00-8.00   sec  3.82 MBytes  32.0 Mbits/sec
[SUM]   7.00-8.00   sec  10.8 MBytes  90.7 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   8.00-9.00   sec  7.08 MBytes  59.4 Mbits/sec
[  6]   8.00-9.00   sec  3.73 MBytes  31.3 Mbits/sec
[SUM]   8.00-9.00   sec  10.8 MBytes  90.7 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   9.00-10.00  sec  6.93 MBytes  58.1 Mbits/sec
[  6]   9.00-10.00  sec  3.88 MBytes  32.6 Mbits/sec
[SUM]   9.00-10.00  sec  10.8 MBytes  90.7 Mbits/sec

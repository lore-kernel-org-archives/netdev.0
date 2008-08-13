From: Andrew Gallatin <gallatin@myri.com>
Subject: CPU utilization increased in 2.6.27rc
Date: Tue, 12 Aug 2008 20:56:23 -0400
Message-ID: <48A23137.2010107@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1794 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752998AbYHMA43 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2008 20:56:29 -0400
Received: from [172.31.134.217] (drew2-ovpn.sw.myri.com [172.31.134.217])
	by myri.com (8.13.7+Sun/8.13.7) with ESMTP id m7D0uPCk024534
	for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 17:56:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I noticed a performance degradation in the 2.6.27rc series having to
do with TCP transmits.  The problem seems to be most noticeable
when using a fast (10GbE) network and a pitifully slow (2.0GHz
athlon64) host with a small (1500b) MTU using TSO and sendpage,
but I also see it with 1GbE hardware, without TSO and sendpage.

I used git-bisect to track down where the problem seems
to have been introduced in Linus' tree:

37437bb2e1ae8af470dfcd5b4ff454110894ccaf is first bad commit
commit 37437bb2e1ae8af470dfcd5b4ff454110894ccaf
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Jul 16 02:15:04 2008 -0700

     pkt_sched: Schedule qdiscs instead of netdev_queue.


Something about this is maxing out the CPU on my very-low end test
machines. Just prior to the above commit, I see the same
good performance as 2.6.26.2 and the rest of the 2.6 series.
Here is output from netperf -tTCP_SENDFILE -C -c between 2 of
my low end hosts:

Forcedeth (1GbE)
  87380  65536  65536    10.05       949.03   14.54    20.01    2.510 
3.455
Myri10ge (10GbE):
  87380  65536  65536    10.01      9466.27   19.00    73.43    0.329 
1.271

Just after the above commit, the CPU utilization increases
dramatically.  Note the large difference in CPU utilization
for both 1GbE (14.5% -> 46.5%) and 10GbE (19% -> 49.8%):

Forcedeth (1GbE)
  87380  65536  65536    10.01       947.04   46.48    20.05    8.042 
3.468
Myri10ge (10GbE):
  87380  65536  65536    10.00      7693.19   49.81    60.03    1.061 
1.278


For 1GbE, I see a similar increase in CPU utilization from
when using normal socket writes (netperf -t TCP_STREAM):


  87380  65536  65536    10.05       948.92   19.89    18.65    3.434 
3.220
	vs
  87380  65536  65536    10.07       949.35   49.38    20.77    8.523 
3.584

Without TSO enabled, the difference is less evident, but still
there (~30% -> 49%).

For 10GbE, this only seems to happen for sendpage. Normal socket
write (netperf TCP_STREAM) tests do not seem to show this degradation,
perhaps because a CPU is already maxed out copying data...

According to oprofile, the system is spending a lot of
time in __qdisc_run() when sending on the 1GbE forcedeth
interface:

17978    17.5929  vmlinux                  __qdisc_run
9828      9.6175  vmlinux                  net_tx_action
8306      8.1281  vmlinux                  _raw_spin_lock
5762      5.6386  oprofiled                (no symbols)
5443      5.3264  vmlinux                  __netif_schedule
5352      5.2374  vmlinux                  _raw_spin_unlock
4921      4.8156  vmlinux                  __do_softirq
3366      3.2939  vmlinux                  raise_softirq_irqoff
1730      1.6929  vmlinux                  pfifo_fast_requeue
1689      1.6528  vmlinux                  pfifo_fast_dequeue
1406      1.3759  oprofile                 (no symbols)
1346      1.3172  vmlinux                  _raw_spin_trylock
1194      1.1684  vmlinux                  nv_start_xmit_optimized
1114      1.0901  vmlinux                  handle_IRQ_event
1031      1.0089  vmlinux                  tcp_ack
<....>

Does anybody understand what's happening?

Thanks,

Drew

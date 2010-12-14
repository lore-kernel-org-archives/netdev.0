From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Possible regression: Packet drops during iptables calls
Date: Tue, 14 Dec 2010 15:46:14 +0100
Message-ID: <1292337974.9155.68.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:37489 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757610Ab0LNOwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 09:52:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm experiencing RX packet drops during call to iptables, on my
production servers.

Further investigations showed, that its only the CPU executing the
iptables command that experience packet drops!?  Thus, a quick fix was
to force the iptables command to run on one of the idle CPUs (This can
be achieved with the "taskset" command).

I have a 2x Xeon 5550 CPU system, thus 16 CPUs (with HT enabled).  We
only use 8 CPUs due to a multiqueue limitation of 8 queues in the
1Gbit/s NICs (82576 chips).  CPUs 0 to 7 is assigned for packet
processing via smp_affinity.

Can someone explain why the packet drops only occur on the CPU
executing the iptables command?


What can we do to solve this issue?


I should note that I have a very large ruleset on this machine, and
the production machine is routing around 800 Mbit/s, in each
direction.  The issue occurs on a simple iptables rule listing.


I think (untested) the problem is related to kernel git commit:

 commit 942e4a2bd680c606af0211e64eb216be2e19bf61
 Author: Stephen Hemminger <shemminger@vyatta.com>
 Date: Tue Apr 28 22:36:33 2009 -0700

 netfilter: revised locking for x_tables

 The x_tables are organized with a table structure and a per-cpu copies
 of the counters and rules. On older kernels there was a reader/writer
 lock per table which was a performance bottleneck. In 2.6.30-rc, this
 was converted to use RCU and the counters/rules which solved the performance
 problems for do_table but made replacing rules much slower because of
 the necessary RCU grace period.

 This version uses a per-cpu set of spinlocks and counters to allow to
 table processing to proceed without the cache thrashing of a global
 reader lock and keeps the same performance for table updates.

 Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
 Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
 Signed-off-by: David S. Miller <davem@davemloft.net>

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer



From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/5] Optimizing "pktgen" for single CPU performance
Date: Wed, 14 May 2014 16:17:38 +0200
Message-ID: <20140514141545.20309.28343.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	John Fastabend <john.r.fastabend@intel.com>, danieltt@kth.se,
	zhouzhouyi@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3447 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447AbaENOSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 10:18:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm on a quest to push the packet per sec (pps) limits of our network
stack, with a special focus on single CPU performance.

My first action is to measure and identify bottlenecks in the transmit
path. For achieving this goal, I need a fast in-kernel packet
generator, like "pktgen". It turned out that "pktgen" were too slow.

Thus, this series focus on optimizing "pktgen" for single CPU performance.

Overview 1xCPU performance Packet Per Sec (pps) stats:
 * baseline: 3,930,068 pps
 * patch2:   5,362,722 pps -- TXSZ=1024
 * patch3:   5,608,781 pps --> 178.29ns per pkt
 * patch4:   5,857,065 pps --> 170.73ns ( -7.56ns)
 * patch5:   6,346,500 pps --> 157.56ns (-13.17ns)
 * No-lock:  6,642,948 pps --> 150.53ns ( -7.03ns)

The last result "No-lock" removes the HARD_TX_{UN}LOCK, and is not
applicable to upstream.  It removes two "LOCK" instructions (cost 8ns
each), thus I were expecting to see an improvement of 16ns, but we
only see 7ns.  This leads me to believe, that we have reached the
ixgbe driver limit, single queue.

Setup according to blogpost:
 http://netoptimizer.blogspot.dk/2014/04/basic-tuning-for-network-overload.html

Hardware:
 System: CPU E5-2630
 NIC: Intel ixgbe/82599 chip

Testing done with net-next git tree on top of
 commit 79e0f1c9f (ipv6: Need to sock_put on csum error).

Pktgen script exercising race condition:
 https://github.com/netoptimizer/network-testing/blob/master/pktgen/unit_test01_race_add_rem_device_loop.sh

---

Jesper Dangaard Brouer (5):
      pktgen: RCU'ify "if_list" to remove lock in next_to_run()
      pktgen: avoid expensive set_current_state() call in loop
      pktgen: avoid atomic_inc per packet in xmit loop
      ixgbe: increase default TX ring buffer to 1024
      ixgbe: trivial fixes while reading code


 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    2 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 
 net/core/pktgen.c                             |  115 +++++++++++++------------
 3 files changed, 61 insertions(+), 58 deletions(-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 3/5] pktgen: avoid atomic_inc per packet in xmit loop
Date: Wed, 14 May 2014 16:17:53 +0200
Message-ID: <20140514141753.20309.19785.stgit@dragon>
References: <20140514141545.20309.28343.stgit@dragon>
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
Received: from mx1.redhat.com ([209.132.183.28]:27581 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752525AbaENOSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 10:18:20 -0400
In-Reply-To: <20140514141545.20309.28343.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid the expensive atomic refcnt increase in the pktgen xmit loop, by
simply setting the refcnt only when a new SKB gets allocated. Setting
it according to how many times we are spinning the same SKB (and
handling the case of skb_clone=0).

Performance data with CLONE_SKB==100000 and TX ring buffer size=1024:
 (single CPU performance, ixgbe 10Gbit/s, E5-2630)
 * Before: 5,362,722 pps --> 186.47ns per pkt (1/5362722*10^9)
 * Now:    5,608,781 pps --> 178.29ns per pkt (1/5608781*10^9)
 * Diff:    +246,059 pps -->  -8.18ns

The performance increase converted to nanoseconds (8.18ns), correspond
well to the measured overhead of LOCK prefixed assembler instructions
on my E5-2630 CPU which is measured to be 8.23ns.

Note, with TX ring size 768 I see some "tx_restart_queue" events.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/core/pktgen.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 0304f98..7752806 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3327,6 +3327,9 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 			pkt_dev->clone_count--;	/* back out increment, OOM */
 			return;
 		}
+		/* Avoid atomic inc for every packet before xmit call */
+		atomic_set(&(pkt_dev->skb->users),
+			   max(2,(pkt_dev->clone_skb+1)));
 		pkt_dev->last_pkt_size = pkt_dev->skb->len;
 		pkt_dev->allocated_skbs++;
 		pkt_dev->clone_count = 0;	/* reset counter */
@@ -3347,7 +3350,6 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->last_ok = 0;
 		goto unlock;
 	}
-	atomic_inc(&(pkt_dev->skb->users));
 	ret = (*xmit)(pkt_dev->skb, odev);
 
 	switch (ret) {

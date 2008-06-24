From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/2] net: Add the CPU id to skb->queue_mapping's upper 8 bits
Date: Tue, 24 Jun 2008 16:27:12 -0700
Message-ID: <20080624232545.11654.65805.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30248 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753761AbYFXX1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 19:27:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch adds the CPU index to the upper 8 bits of the queue_mapping in
the skb.  This will support 256 CPUs and 256 Tx queues.  The reason for
this is the qdisc layer can obscure which CPU is generating a certain flow
of packets, so network drivers don't have any insight which CPU generated a
particular packet.  If the driver knows which CPU generated the packet,
then it could adjust Rx filtering in the hardware to redirect the packet
back to the CPU who owns the process that generated this packet.
Preventing the cache miss and reschedule of a process to a different CPU is
a big win in network performance, especially at 10 gigabit speeds.

Signed-off-by: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/sched/sch_prio.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 4aa2b45..84bbd10 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -86,6 +86,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 #endif
 
+	skb->queue_mapping |= (get_cpu() << 8);
 	if ((ret = qdisc->enqueue(skb, qdisc)) == NET_XMIT_SUCCESS) {
 		sch->bstats.bytes += skb->len;
 		sch->bstats.packets++;


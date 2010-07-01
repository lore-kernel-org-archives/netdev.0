From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] sched: qdisc_reset_all_tx is calling qdisc_reset
	without qdisc_lock
Date: Thu, 01 Jul 2010 16:21:35 -0700
Message-ID: <20100701232103.15685.48453.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:56121
	"EHLO qmta04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752177Ab0GAXV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 19:21:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

When calling qdisc_reset() the qdisc lock needs to be held.  In
this case there is at least one driver i4l which is using this
without holding the lock.  Add the locking here.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/net/sch_generic.h |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 03ca5d8..ba749be 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -317,8 +317,16 @@ extern void tcf_destroy_chain(struct tcf_proto **fl);
 static inline void qdisc_reset_all_tx(struct net_device *dev)
 {
 	unsigned int i;
-	for (i = 0; i < dev->num_tx_queues; i++)
-		qdisc_reset(netdev_get_tx_queue(dev, i)->qdisc);
+	struct Qdisc *qdisc;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		qdisc = netdev_get_tx_queue(dev, i)->qdisc;
+		if (qdisc) {
+			spin_lock_bh(qdisc_lock(qdisc));
+			qdisc_reset(qdisc);
+			spin_unlock_bh(qdisc_lock(qdisc));
+		}
+	}
 }
 
 /* Are all TX queues of the device empty?  */


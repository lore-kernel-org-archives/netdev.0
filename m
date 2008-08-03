From: David Miller <davem@davemloft.net>
Subject: [PATCH]: qdisc_root_lock() requires RTNML
Date: Sat, 02 Aug 2008 23:55:37 -0700 (PDT)
Message-ID: <20080802.235537.203812172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47301
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751744AbYHCGzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 02:55:37 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B805DC8C1CF
	for <netdev@vger.kernel.org>; Sat,  2 Aug 2008 23:55:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Another followup after:

http://marc.info/?l=linux-netdev&m=121763401922311&w=2

Committed to net-2.6

--------------------

pkt_sched: Make sure RTNL is held in qdisc_root_lock().

It is the only legal environment in which this can be
used.

Add some commentary explaining the situation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sch_generic.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b5f40d7..c5bb130 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -193,10 +193,22 @@ static inline struct Qdisc *qdisc_root(struct Qdisc *qdisc)
 	return qdisc->dev_queue->qdisc;
 }
 
+/* The qdisc root lock is a mechanism by which to top level
+ * of a qdisc tree can be locked from any qdisc node in the
+ * forest.  This allows changing the configuration of some
+ * aspect of the qdisc tree while blocking out asynchronous
+ * qdisc access in the packet processing paths.
+ *
+ * It is only legal to do this when the root will not change
+ * on us.  Otherwise we'll potentially lock the wrong qdisc
+ * root.  This is enforced by holding the RTNL semaphore, which
+ * all users of this lock accessor must do.
+ */
 static inline spinlock_t *qdisc_root_lock(struct Qdisc *qdisc)
 {
 	struct Qdisc *root = qdisc_root(qdisc);
 
+	ASSERT_RTNL();
 	return qdisc_lock(root);
 }
 
-- 
1.5.6.GIT



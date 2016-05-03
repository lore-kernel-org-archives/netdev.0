From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] netdevice: shrink size of struct netdev_queue
Date: Tue,  3 May 2016 03:29:09 +0200
Message-ID: <1462238949-3271-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47922 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932486AbcECB2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 21:28:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- trans_timeout is incremented when tx queue timed out (tx watchdog).
- tx_maxrate is set via sysfs

Moving tx_maxrate to read-mostly part shrinks the struct by 64 bytes.
While at it, also move trans_timeout (it is out-of-place in the
'write-mostly' part).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netdevice.h | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 52914a8..f218259 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -569,6 +569,12 @@ struct netdev_queue {
 #if defined(CONFIG_XPS) && defined(CONFIG_NUMA)
 	int			numa_node;
 #endif
+	unsigned long		tx_maxrate;
+	/*
+	 * Number of TX timeouts for this queue
+	 * (/sys/class/net/DEV/Q/trans_timeout)
+	 */
+	unsigned long		trans_timeout;
 /*
  * write-mostly part
  */
@@ -579,18 +585,11 @@ struct netdev_queue {
 	 */
 	unsigned long		trans_start;
 
-	/*
-	 * Number of TX timeouts for this queue
-	 * (/sys/class/net/DEV/Q/trans_timeout)
-	 */
-	unsigned long		trans_timeout;
-
 	unsigned long		state;
 
 #ifdef CONFIG_BQL
 	struct dql		dql;
 #endif
-	unsigned long		tx_maxrate;
 } ____cacheline_aligned_in_smp;
 
 static inline int netdev_queue_numa_node_read(const struct netdev_queue *q)
-- 
2.7.3

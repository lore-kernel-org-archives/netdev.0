From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next] net: Functions to report space available in
 device TX queues
Date: Mon, 25 Aug 2014 08:27:56 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408250823440.31745@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:40459 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756046AbaHYP15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 11:27:57 -0400
Received: by mail-ig0-f202.google.com with SMTP id r2so433360igi.1
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 08:27:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds netdev_tx_avail_queue and netdev_avail_queue which are
used to report number of bytes available in transmit queues per BQL. The
functions call dql_avail which returns BQL limit minus number of
inflight bytes. These functions can be called without txlock, for
instance to ascertain how much data should be dequeued from a qdisc in
a batch. When called without the tx_lock, the result is technically a
hint, subsequently when the tx_lock is done for a transmit it is
possible the availability has changed (for example a transmit
completion may have freed up more space in the queue or changed the
limit).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h | 28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0fac884..bdf6c85 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2544,6 +2544,30 @@ static inline void netdev_completed_queue(struct net_device *dev,
 	netdev_tx_completed_queue(netdev_get_tx_queue(dev, 0), pkts, bytes);
 }
 
+static inline int netdev_tx_avail_queue(struct netdev_queue *dev_queue)
+{
+#ifdef CONFIG_BQL
+	return dql_avail(&dev_queue->dql);
+#else
+	return DQL_MAX_LIMIT;
+#endif
+}
+
+/**
+ *	netdev_avail_queue - report how much space is availble for xmit
+ *	@dev: network device
+ *
+ *	Report the amount of space available in the TX queue in terms of
+ *	number of bytes. This returns the number of bytes avaiable per
+ *	DQL. This function may be called without taking the txlock on
+ *	the device, however in that case the result should be taken as
+ *	a (strong) hint.
+ */
+static inline int netdev_avail_queue(struct net_device *dev)
+{
+	return netdev_tx_avail_queue(netdev_get_tx_queue(dev, 0));
+}
+
 static inline void netdev_tx_reset_queue(struct netdev_queue *q)
 {
 #ifdef CONFIG_BQL
@@ -2559,9 +2583,9 @@ static inline void netdev_tx_reset_queue(struct netdev_queue *q)
  * 	Reset the bytes and packet count of a network device and clear the
  * 	software flow control OFF bit for this network device
  */
-static inline void netdev_reset_queue(struct net_device *dev_queue)
+static inline void netdev_reset_queue(struct net_device *dev)
 {
-	netdev_tx_reset_queue(netdev_get_tx_queue(dev_queue, 0));
+	netdev_tx_reset_queue(netdev_get_tx_queue(dev, 0));
 }
 
 /**
-- 
2.1.0.rc2.206.gedb03e5

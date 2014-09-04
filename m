From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH V2 1/3] net: Functions to report space available
	in device TX queues
Date: Thu, 04 Sep 2014 14:54:33 +0200
Message-ID: <20140904125425.4108.72776.stgit@dragon>
References: <20140904125247.4108.8132.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37230 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751945AbaIDMyw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 08:54:52 -0400
In-Reply-To: <20140904125247.4108.8132.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>

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
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
 - Fixed spelling in comments

 include/linux/netdevice.h |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5be20a7..5a4384a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2567,6 +2567,30 @@ static inline void netdev_completed_queue(struct net_device *dev,
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
+ *	netdev_avail_queue - report how much space is available for xmit
+ *	@dev: network device
+ *
+ *	Report the amount of space available in the TX queue in terms of
+ *	number of bytes. This returns the number of bytes available per
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
@@ -2582,9 +2606,9 @@ static inline void netdev_tx_reset_queue(struct netdev_queue *q)
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

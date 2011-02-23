From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 1/2] bonding: fix incorrect transmit queue offset
Date: Wed, 23 Feb 2011 14:42:49 -0500
Message-ID: <1298490169-5224-1-git-send-email-andy@greyhouse.net>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org, Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751902Ab1BWTnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 14:43:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users noticed the following messages:

kernel: bond0 selects TX queue 16, but real number of TX queues is 16

were filling their logs when frames received from a device that
contained 16 input queues were being forwarded out of a bonded device.
Ben pointed out that the contents of skb->queue_mapping cannot be
directly mapped to a transmit queue, so I went with his suggestion for a
solution to the offset problem.

The function now also warns the user to increase the default value for
tx_queues if needed and returns a valid tx queue to dev_pick_tx.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Reported-by: Phil Oester <kernel@linuxace.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/bonding/bond_main.c |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 77e3c6a..1512c83 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4533,15 +4533,25 @@ out:
 	return res;
 }
 
+/*
+ * This helper function exists to help dev_pick_tx get the correct
+ * destination queue.  Using a helper function skips the a call to
+ * skb_tx_hash and will put the skbs in the queue we expect on their
+ * way down to the bonding driver.
+ */
 static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
-	/*
-	 * This helper function exists to help dev_pick_tx get the correct
-	 * destination queue.  Using a helper function skips the a call to
-	 * skb_tx_hash and will put the skbs in the queue we expect on their
-	 * way down to the bonding driver.
-	 */
-	return skb->queue_mapping;
+	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
+
+	while (txq >= dev->real_num_tx_queues) {
+		/* let the user know if we do not have enough tx queues */
+		if (net_ratelimit())
+			pr_warning("%s selects invalid tx queue %d.  Consider"
+				   " setting module option tx_queues > %d.",
+				   dev->name, txq, dev->real_num_tx_queues);
+		txq -= dev->real_num_tx_queues;
+	}
+	return txq;
 }
 
 static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
-- 
1.7.4


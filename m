From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [RFC PATCH net-next 1/3] macvtap: mutiple qdiscs support
Date: Sun,  7 Feb 2016 22:14:54 -0500
Message-ID: <1454901296-9915-2-git-send-email-vyasevic@redhat.com>
References: <1454901296-9915-1-git-send-email-vyasevic@redhat.com>
Cc: jasowang@redhat.com, mst@redhat.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:33032 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755184AbcBHDPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 22:15:05 -0500
Received: by mail-qg0-f66.google.com with SMTP id y89so3251484qge.0
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 19:15:05 -0800 (PST)
In-Reply-To: <1454901296-9915-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 6acf54f1cf0a6747bac9fea26f34cfc5a9029523
    macvtap: Add support of packet capture on macvtap device.

macvtap has been using dev_queue_xmit() call.  Since macvtap
set the queue length, it ended up using a qdisc and that caused
lock contention when multi-queue macvtap was used.

This patch extends the macvtap multi-queue support that adds
multiple qudiscs.   If macvtap is crated without a spcified
number of queues, we default to MAX_MACVTAP_QUEUES.  We always
start with one real queue.  After the that, every time the user
opens a macvtap device (for every open after the first one), we'll
update the number of real queues.  We also update the number of
queues upon queue disables and enables.  This is different then tap
bacuase, unlike tap device, macvtap will actually completely unlink
the tap queue  from the vlan and change the queue index.  As a result,
a disable/enable sequence will cause the queue index change and we
account for this by updating real queues.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvtap.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index d636d05..810e7d3 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -161,6 +161,12 @@ static struct macvlan_dev *macvtap_get_vlan_rcu(const struct net_device *dev)
  * when both our references and any pending SKBs are gone.
  */
 
+static void macvtap_set_real_num_queues(struct net_device *dev, int q)
+{
+	netif_set_real_num_tx_queues(dev, q);
+	netif_set_real_num_rx_queues(dev, q);
+}
+
 static int macvtap_enable_queue(struct net_device *dev, struct file *file,
 				struct macvtap_queue *q)
 {
@@ -178,6 +184,7 @@ static int macvtap_enable_queue(struct net_device *dev, struct file *file,
 	q->enabled = true;
 
 	vlan->numvtaps++;
+	macvtap_set_real_num_queues(dev, vlan->numvtaps);
 out:
 	return err;
 }
@@ -204,6 +211,7 @@ static int macvtap_set_queue(struct net_device *dev, struct file *file,
 	vlan->numvtaps++;
 	vlan->numqueues++;
 
+	macvtap_set_real_num_queues(dev, vlan->numvtaps);
 	return 0;
 }
 
@@ -229,6 +237,7 @@ static int macvtap_disable_queue(struct macvtap_queue *q)
 		q->enabled = false;
 
 		vlan->numvtaps--;
+		macvtap_set_real_num_queues(vlan->dev, vlan->numvtaps);
 	}
 
 	return 0;
@@ -481,15 +490,24 @@ static void macvtap_dellink(struct net_device *dev,
 
 static void macvtap_setup(struct net_device *dev)
 {
+	/* Start with 1 queue and will update as user adds them */
+	macvtap_set_real_num_queues(dev, 1);
 	macvlan_common_setup(dev);
 	dev->tx_queue_len = TUN_READQ_SIZE;
 }
 
+static unsigned int macvtap_get_num_queues(void)
+{
+	return MAX_MACVTAP_QUEUES;
+}
+
 static struct rtnl_link_ops macvtap_link_ops __read_mostly = {
 	.kind		= "macvtap",
 	.setup		= macvtap_setup,
 	.newlink	= macvtap_newlink,
 	.dellink	= macvtap_dellink,
+	.get_num_tx_queues = macvtap_get_num_queues,
+	.get_num_rx_queues = macvtap_get_num_queues,
 };
 
 
-- 
2.1.0

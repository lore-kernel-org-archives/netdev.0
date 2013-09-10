From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 21/27] net: add a function to get the next private
Date: Tue, 10 Sep 2013 22:58:05 +0200
Message-ID: <1378846691-9717-22-git-send-email-vfalico@redhat.com>
References: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34725 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751255Ab3IJU6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 16:58:53 -0400
In-Reply-To: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It searches for the provided private and returns the next one. If private
is not found or next list element is list head - returns NULL.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    Drop the bool switch - it only goes to ->next now, and rework it so
    that it doesn't go over the head, but rather returns NULL.

 include/linux/netdevice.h |  2 ++
 net/core/dev.c            | 27 +++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 72d1631..b487302 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2866,6 +2866,8 @@ extern void *netdev_lower_dev_get_private_rcu(struct net_device *dev,
 					      struct net_device *lower_dev);
 extern void *netdev_lower_dev_get_private(struct net_device *dev,
 					  struct net_device *lower_dev);
+extern void *netdev_lower_dev_get_next_private(struct net_device *dev,
+					       void *private);
 extern int skb_checksum_help(struct sk_buff *skb);
 extern struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 	netdev_features_t features, bool tx_path);
diff --git a/net/core/dev.c b/net/core/dev.c
index 24c7d17..d58ca53 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5055,6 +5055,33 @@ void *netdev_lower_dev_get_private(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_lower_dev_get_private);
 
+/* netdev_lower_dev_get_next_private - return the ->private of the list
+ *				       element whos ->private == private.
+ * @dev - device to search
+ * @private - private pointer to search for.
+ *
+ * Returns the next ->private pointer, if ->next is not head and private is
+ * found.
+ */
+extern void *netdev_lower_dev_get_next_private(struct net_device *dev,
+					       void *private)
+{
+	struct netdev_adjacent *lower;
+
+	list_for_each_entry(lower, &dev->adj_list.lower, list) {
+		if (lower->private == private) {
+			lower = list_entry(lower->list.next,
+					   struct netdev_adjacent, list);
+			if (&lower->list == &dev->adj_list.lower)
+				return NULL;
+			return lower->private;
+		}
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(netdev_lower_dev_get_next_private);
+
 static void dev_change_rx_flags(struct net_device *dev, int flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
-- 
1.8.4

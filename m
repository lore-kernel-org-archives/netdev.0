From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 18/21] net: add a function to get the next/prev private
Date: Mon,  2 Sep 2013 23:39:22 +0200
Message-ID: <1378157965-17537-19-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44574 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932259Ab3IBVji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:39:38 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The boolean flag specifies which direction to go.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 include/linux/netdevice.h |  2 ++
 net/core/dev.c            | 24 ++++++++++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bde2244..a112ccc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2835,6 +2835,8 @@ extern void *netdev_lower_dev_get_private_rcu(struct net_device *dev,
 					      struct net_device *lower_dev);
 extern void *netdev_lower_dev_get_private(struct net_device *dev,
 					  struct net_device *lower_dev);
+extern void *netdev_lower_dev_get_next_private(struct net_device *dev,
+					       void *private, bool prev);
 extern int skb_checksum_help(struct sk_buff *skb);
 extern struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 	netdev_features_t features, bool tx_path);
diff --git a/net/core/dev.c b/net/core/dev.c
index 6df11a0..c694059 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5163,6 +5163,30 @@ void *netdev_lower_dev_get_private(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_lower_dev_get_private);
 
+extern void *netdev_lower_dev_get_next_private(struct net_device *dev,
+					       void *private, bool prev)
+{
+	struct netdev_adjacent *lower;
+
+	list_for_each_entry(lower, &dev->neighbour_dev_list.lower, list)
+		if (lower->private == private)
+			break;
+
+	if (&lower->list == &dev->neighbour_dev_list.lower)
+		return NULL;
+
+	lower = prev ? list_entry(lower->list.prev, struct netdev_adjacent, list) :
+		       list_entry(lower->list.next, struct netdev_adjacent, list);
+	if (&lower->list != &dev->neighbour_dev_list.lower)
+		return lower->private;
+
+	lower = prev ? list_entry(lower->list.prev, struct netdev_adjacent, list) :
+		       list_entry(lower->list.next, struct netdev_adjacent, list);
+
+	return lower->private;
+}
+EXPORT_SYMBOL(netdev_lower_dev_get_next_private);
+
 static void dev_change_rx_flags(struct net_device *dev, int flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
-- 
1.8.4

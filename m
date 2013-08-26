From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v1 1/9] net: add netdev_upper_get_next_dev(dev, iter)
Date: Mon, 26 Aug 2013 22:32:34 +0200
Message-ID: <1377549162-7522-2-git-send-email-vfalico@redhat.com>
References: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752425Ab3HZUcd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 16:32:33 -0400
In-Reply-To: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function returns the next dev in the dev->upper_dev_list after the
struct list_head **iter position, and updates *iter accordingly. Returns
NULL if there are no devices left.

v1: new patch

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 net/core/dev.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1ed2b66..566e99a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4477,6 +4477,31 @@ struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_master_upper_dev_get);
 
+/* netdev_upper_get_next_dev - Get the next dev from upper list
+ * @dev: device
+ * @iter: list_head ** of the current position
+ *
+ * Gets the next device from the dev's upper list, starting from iter
+ * position. The caller must hold RCU read lock.
+ */
+struct net_device *netdev_upper_get_next_dev(struct net_device *dev,
+					     struct list_head **iter)
+{
+	struct netdev_upper *upper;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	upper = list_entry_rcu((*iter)->next, struct netdev_upper, list);
+
+	if (&upper->list == &dev->upper_dev_list)
+		return NULL;
+
+	*iter = &upper->list;
+
+	return upper->dev;
+}
+EXPORT_SYMBOL(netdev_upper_get_next_dev);
+
 /**
  * netdev_master_upper_dev_get_rcu - Get master upper device
  * @dev: device
-- 
1.7.1

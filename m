From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 2/2] net: rename sysfs symlinks on device name change
Date: Tue, 14 Jan 2014 17:36:00 +0100
Message-ID: <1389717360-13920-3-git-send-email-vfalico@redhat.com>
References: <1389717360-13920-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44983 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752435AbaANQkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 11:40:22 -0500
In-Reply-To: <1389717360-13920-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we don't rename the upper/lower_ifc symlinks in
/sys/class/net/*/ , which might result stale/duplicate links/names.

Fix this by adding netdev_adjacent_rename_links(dev, oldname) which renames
all the upper/lower interface's links to dev from the upper/lower_oldname
to the new name.

We don't need a rollback because only we control these symlinks and if we
fail to rename them - sysfs will anyway complain.

Reported-by: Ding Tianhong <dingtianhong@huawei.com>
CC: Ding Tianhong <dingtianhong@huawei.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 include/linux/netdevice.h |  1 +
 net/core/dev.c            | 23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a2a70cc..61f8338 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2937,6 +2937,7 @@ int netdev_master_upper_dev_link_private(struct net_device *dev,
 					 void *private);
 void netdev_upper_dev_unlink(struct net_device *dev,
 			     struct net_device *upper_dev);
+void netdev_adjacent_rename_links(struct net_device *dev, char *oldname);
 void *netdev_lower_dev_get_private(struct net_device *dev,
 				   struct net_device *lower_dev);
 int skb_checksum_help(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index c578d4e..5bf0950 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1117,6 +1117,8 @@ rollback:
 
 	write_seqcount_end(&devnet_rename_seq);
 
+	netdev_adjacent_rename_links(dev, oldname);
+
 	write_lock_bh(&dev_base_lock);
 	hlist_del_rcu(&dev->name_hlist);
 	write_unlock_bh(&dev_base_lock);
@@ -1136,6 +1138,7 @@ rollback:
 			err = ret;
 			write_seqcount_begin(&devnet_rename_seq);
 			memcpy(dev->name, oldname, IFNAMSIZ);
+			memcpy(oldname, newname, IFNAMSIZ);
 			goto rollback;
 		} else {
 			pr_err("%s: name change rollback failed: %d\n",
@@ -4971,6 +4974,26 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
+void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
+{
+	struct netdev_adjacent *iter;
+
+	list_for_each_entry(iter, &dev->adj_list.upper, list) {
+		netdev_adjacent_sysfs_del(iter->dev, oldname,
+					  &iter->dev->adj_list.lower);
+		netdev_adjacent_sysfs_add(iter->dev, dev,
+					  &iter->dev->adj_list.lower);
+	}
+
+	list_for_each_entry(iter, &dev->adj_list.lower, list) {
+		netdev_adjacent_sysfs_del(iter->dev, oldname,
+					  &iter->dev->adj_list.upper);
+		netdev_adjacent_sysfs_add(iter->dev, dev,
+					  &iter->dev->adj_list.upper);
+	}
+}
+EXPORT_SYMBOL(netdev_adjacent_rename_links);
+
 void *netdev_lower_dev_get_private(struct net_device *dev,
 				   struct net_device *lower_dev)
 {
-- 
1.8.4

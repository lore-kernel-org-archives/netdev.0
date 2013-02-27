From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] net: dev: deinit list in unregister_netdevice_many
Date: Wed, 27 Feb 2013 14:59:51 +0800
Message-ID: <1361948391-4906-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:8331 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752229Ab3B0G7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 01:59:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ceaaec98ad99859ac90ac6863ad0a6cd075d8e0e
"net: deinit automatic LIST_HEAD"  has already done
part of the deinit list jobs.

This patch push list_del into unregister_netdevice_many
to make sure the unreg_list of netdevice object has valid
pointer always.

Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/net/macvlan.c | 1 -
 net/core/dev.c        | 5 ++++-
 net/core/rtnetlink.c  | 1 -
 net/mac80211/iface.c  | 1 -
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index defcd8a..9b728f1 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -945,7 +945,6 @@ static int macvlan_device_event(struct notifier_block *unused,
 		list_for_each_entry_safe(vlan, next, &port->vlans, list)
 			vlan->dev->rtnl_link_ops->dellink(vlan->dev, &list_kill);
 		unregister_netdevice_many(&list_kill);
-		list_del(&list_kill);
 		break;
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* Forbid underlaying device to change its type. */
diff --git a/net/core/dev.c b/net/core/dev.c
index 18d8b5a..c10f322 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5747,6 +5747,9 @@ EXPORT_SYMBOL(unregister_netdevice_queue);
 /**
  *	unregister_netdevice_many - unregister many devices
  *	@head: list of devices
+ *
+ *	Call list_del after unregister devices to make sure
+ *	the unreg_list of netdevice object has valid pointer.
  */
 void unregister_netdevice_many(struct list_head *head)
 {
@@ -5756,6 +5759,7 @@ void unregister_netdevice_many(struct list_head *head)
 		rollback_registered_many(head);
 		list_for_each_entry(dev, head, unreg_list)
 			net_set_todo(dev);
+		list_del(head);
 	}
 }
 EXPORT_SYMBOL(unregister_netdevice_many);
@@ -6172,7 +6176,6 @@ static void __net_exit default_device_exit_batch(struct list_head *net_list)
 		}
 	}
 	unregister_netdevice_many(&dev_kill_list);
-	list_del(&dev_kill_list);
 	rtnl_unlock();
 }
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d8aa20f..8e35210 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1613,7 +1613,6 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 	ops->dellink(dev, &list_kill);
 	unregister_netdevice_many(&list_kill);
-	list_del(&list_kill);
 	return 0;
 }
 
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 2c059e5..a799629 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1639,7 +1639,6 @@ void ieee80211_remove_interfaces(struct ieee80211_local *local)
 	}
 	mutex_unlock(&local->iflist_mtx);
 	unregister_netdevice_many(&unreg_list);
-	list_del(&unreg_list);
 
 	list_for_each_entry_safe(sdata, tmp, &wdev_list, list) {
 		list_del(&sdata->list);
-- 
1.7.11.7

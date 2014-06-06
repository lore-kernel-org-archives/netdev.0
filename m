From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: force a list_del() in
 unregister_netdevice_many()
Date: Fri, 06 Jun 2014 06:44:03 -0700
Message-ID: <1402062243.3645.295.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1401840715-16375-2-git-send-email-xiyou.wangcong@gmail.com>
	 <1401842581.3645.241.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpWeq6a+ighGoLXqDp06t+D97adFrtRpM+ACqtf3J4SUNg@mail.gmail.com>
	 <1402060661.3645.289.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:39912 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbaFFNoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 09:44:06 -0400
Received: by mail-pb0-f43.google.com with SMTP id up15so2508175pbc.30
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 06:44:04 -0700 (PDT)
In-Reply-To: <1402060661.3645.289.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

unregister_netdevice_many() API is error prone and we had too
many bugs because of dangling LIST_HEAD on stacks.

See commit f87e6f47933e3e ("net: dont leave active on stack LIST_HEAD")

In fact, instead of making sure no caller leaves an active list_head,
just force a list_del() in the callee. No one seems to need to access
the list after unregister_netdevice_many()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
I based this patch on net-next, but it seems to close existing bugs,
so its probably a stable candidate.

 drivers/net/macvlan.c |    1 -
 net/core/dev.c        |    5 ++++-
 net/core/rtnetlink.c  |    1 -
 net/mac80211/iface.c  |    1 -
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 453d55a02492..958df383068a 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1204,7 +1204,6 @@ static int macvlan_device_event(struct notifier_block *unused,
 		list_for_each_entry_safe(vlan, next, &port->vlans, list)
 			vlan->dev->rtnl_link_ops->dellink(vlan->dev, &list_kill);
 		unregister_netdevice_many(&list_kill);
-		list_del(&list_kill);
 		break;
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* Forbid underlaying device to change its type. */
diff --git a/net/core/dev.c b/net/core/dev.c
index ed8fe62d41af..ab6c491bd2d3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6634,6 +6634,9 @@ EXPORT_SYMBOL(unregister_netdevice_queue);
 /**
  *	unregister_netdevice_many - unregister many devices
  *	@head: list of devices
+ *
+ *  Note: As most callers use a stack allocated list_head,
+ *  we force a list_del() to make sure stack wont be corrupted later.
  */
 void unregister_netdevice_many(struct list_head *head)
 {
@@ -6643,6 +6646,7 @@ void unregister_netdevice_many(struct list_head *head)
 		rollback_registered_many(head);
 		list_for_each_entry(dev, head, unreg_list)
 			net_set_todo(dev);
+		list_del(head);
 	}
 }
 EXPORT_SYMBOL(unregister_netdevice_many);
@@ -7098,7 +7102,6 @@ static void __net_exit default_device_exit_batch(struct list_head *net_list)
 		}
 	}
 	unregister_netdevice_many(&dev_kill_list);
-	list_del(&dev_kill_list);
 	rtnl_unlock();
 }
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 741b22c62acf..0ebc181521b6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1770,7 +1770,6 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ops->dellink(dev, &list_kill);
 	unregister_netdevice_many(&list_kill);
-	list_del(&list_kill);
 	return 0;
 }
 
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 81a8e2a0b6aa..388b863e821c 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1780,7 +1780,6 @@ void ieee80211_remove_interfaces(struct ieee80211_local *local)
 	}
 	mutex_unlock(&local->iflist_mtx);
 	unregister_netdevice_many(&unreg_list);
-	list_del(&unreg_list);
 
 	list_for_each_entry_safe(sdata, tmp, &wdev_list, list) {
 		list_del(&sdata->list);

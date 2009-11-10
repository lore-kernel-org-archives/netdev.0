From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 01/10] netdev: add netdev_continue_rcu
Date: Tue, 10 Nov 2009 09:54:47 -0800
Message-ID: <20091110175647.200655064@vyatta.com>
References: <20091110175446.280423729@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58707 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755299AbZKJSHK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 13:07:10 -0500
Content-Disposition: inline; filename=continue-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds an RCU macro for continuing search, useful for some
network devices like vlan.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/netdevice.h	2009-11-09 22:19:08.511480873 -0800
+++ b/include/linux/netdevice.h	2009-11-10 09:27:17.973376267 -0800
@@ -1079,6 +1079,8 @@ extern rwlock_t				dev_base_lock;		/* De
 		list_for_each_entry_safe(d, n, &(net)->dev_base_head, dev_list)
 #define for_each_netdev_continue(net, d)		\
 		list_for_each_entry_continue(d, &(net)->dev_base_head, dev_list)
+#define for_each_netdev_continue_rcu(net, d)		\
+	list_for_each_entry_continue_rcu(d, &(net)->dev_base_head, dev_list)
 #define net_device_entry(lh)	list_entry(lh, struct net_device, dev_list)
 
 static inline struct net_device *next_net_device(struct net_device *dev)
--- a/include/linux/rculist.h	2009-11-09 22:19:08.529480859 -0800
+++ b/include/linux/rculist.h	2009-11-10 09:27:17.974376609 -0800
@@ -262,6 +262,20 @@ static inline void list_splice_init_rcu(
 		(pos) = rcu_dereference((pos)->next))
 
 /**
+ * list_for_each_entry_continue_rcu - continue iteration over list of given type
+ * @pos:	the type * to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ *
+ * Continue to iterate over list of given type, continuing after
+ * the current position.
+ */
+#define list_for_each_entry_continue_rcu(pos, head, member) 		\
+	for (pos = list_entry_rcu(pos->member.next, typeof(*pos), member); \
+	     prefetch(pos->member.next), &pos->member != (head);	\
+	     pos = list_entry_rcu(pos->member.next, typeof(*pos), member))
+
+/**
  * hlist_del_rcu - deletes entry from hash list without re-initialization
  * @n: the element to delete from the hash list.
  *

-- 


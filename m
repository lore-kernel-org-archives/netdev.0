From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/5] net: allow netdev_all_upper_get_next_dev_rcu with rtnl lock held
Date: Tue, 17 Dec 2013 23:19:42 -0800
Message-ID: <1387351186-23389-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387351186-23389-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Veaceslav Falico <vfalico@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58137 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068Ab3LRHTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 02:19:49 -0500
In-Reply-To: <1387351186-23389-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

It is useful to be able to walk all upper devices when bringing
a device online where the RTNL lock is held. In this case it
is safe to walk the all_adj_list because the RTNL lock is used
to protect the write side as well.

This patch adds a check to see if the rtnl lock is held before
throwing a warning in netdev_all_upper_get_next_dev_rcu().

Also because we now have a call site for lockdep_rtnl_is_held()
outside COFIG_LOCK_PROVING an inline definition returning 1 is
needed. Similar to the rcu_read_lock_is_held().

Fixes: 2a47fa45d4df ("ixgbe: enable l2 forwarding acceleration for macvlans")
CC: Veaceslav Falico <vfalico@redhat.com>
Reported-by: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/rtnetlink.h | 5 +++++
 net/core/dev.c            | 2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 939428a..8e3e66a 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -24,6 +24,11 @@ extern int rtnl_trylock(void);
 extern int rtnl_is_locked(void);
 #ifdef CONFIG_PROVE_LOCKING
 extern int lockdep_rtnl_is_held(void);
+#else
+static inline int lockdep_rtnl_is_held(void)
+{
+	return 1;
+}
 #endif /* #ifdef CONFIG_PROVE_LOCKING */
 
 /**
diff --git a/net/core/dev.c b/net/core/dev.c
index ba3b7ea..4fc1722 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4500,7 +4500,7 @@ struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
 {
 	struct netdev_adjacent *upper;
 
-	WARN_ON_ONCE(!rcu_read_lock_held());
+	WARN_ON_ONCE(!rcu_read_lock_held() && !lockdep_rtnl_is_held());
 
 	upper = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
 
-- 
1.8.3.1

From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v1 3/9] bonding: use netdev_upper list in bond_vlan_used
Date: Mon, 26 Aug 2013 22:32:36 +0200
Message-ID: <1377549162-7522-4-git-send-email-vfalico@redhat.com>
References: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61715 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653Ab3HZUeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 16:34:22 -0400
In-Reply-To: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert bond_vlan_used() to traverse the upper device list to see if we
have any vlans above us. It's protected by rcu, and in case we are holding
rtnl_lock we should call vlan_uses_dev() instead - it's faster.

v1: use netdev_for_each_upper_dev()

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bonding.h |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 4bf52d5..9392e00 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -267,9 +267,22 @@ struct bonding {
 #endif /* CONFIG_DEBUG_FS */
 };
 
+/* if we hold rtnl_lock() - call vlan_uses_dev() */
 static inline bool bond_vlan_used(struct bonding *bond)
 {
-	return !list_empty(&bond->vlan_list);
+	struct net_device *upper;
+	struct list_head *iter;
+
+	rcu_read_lock();
+	netdev_for_each_upper_dev(bond->dev, upper, iter) {
+		if (upper->priv_flags & IFF_802_1Q_VLAN) {
+			rcu_read_unlock();
+			return true;
+		}
+	}
+	rcu_read_unlock();
+
+	return false;
 }
 
 #define bond_slave_get_rcu(dev) \
-- 
1.7.1

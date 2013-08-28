From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v4 06/13] bonding: use netdev_upper list in bond_vlan_used
Date: Wed, 28 Aug 2013 23:25:09 +0200
Message-ID: <1377725116-31126-7-git-send-email-vfalico@redhat.com>
References: <1377725116-31126-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34475 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755963Ab3H1V0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 17:26:07 -0400
In-Reply-To: <1377725116-31126-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert bond_vlan_used() to traverse the upper device list to see if we
have any vlans above us. It's protected by rcu, and in case we are holding
rtnl_lock we should call vlan_uses_dev() instead - it's faster.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v1: use netdev_for_each_upper_dev()
    v2: use netdev_for_each_upper_dev_rcu()
    v3: no change
    v4: no change

 drivers/net/bonding/bonding.h | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 4bf52d5..230197d 100644
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
+	netdev_for_each_upper_dev_rcu(bond->dev, upper, iter) {
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
1.8.4

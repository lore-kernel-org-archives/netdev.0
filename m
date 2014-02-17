From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/3] bonding: add new slave param and  bond_slave_state_notify()
Date: Mon, 17 Feb 2014 16:35:50 +0800
Message-ID: <1392626151-23916-3-git-send-email-dingtianhong@huawei.com>
References: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <cwang@twopensource.com>, <jiri@resnulli.us>,
	<thomas@glanzmann.de>, <eric.dumazet@gmail.com>,
	<sfeldma@cumulusnetworks.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:64792 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbaBQIgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 03:36:40 -0500
In-Reply-To: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new slave parameter which called should_notify, if the slave's state
changed and don't notify yet, the parameter will be set to 1, and then if
the slave's state changed again, the param will be set to 0, it indicate that
the slave's state has been restored, no need to notify any one.

The bond_slave_state_notify() will check whether the status changed and then
decide to notify or not.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bonding.h | 44 +++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 42 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index d210124..4d0cd41 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -195,7 +195,8 @@ struct slave {
 	s8     new_link;
 	u8     backup:1,   /* indicates backup slave. Value corresponds with
 			      BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
-	       inactive:1; /* indicates inactive slave */
+	       inactive:1, /* indicates inactive slave */
+	       should_notify:1; /* indicateds whether the state changed */
 	u8     duplex;
 	u32    original_mtu;
 	u32    link_failure_count;
@@ -311,8 +312,47 @@ static inline void bond_set_slave_state(struct slave *slave,
 	else
 		return;
 
-	if (notify)
+	if (notify) {
 		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
+		slave->should_notify = 0;
+	} else {
+		if (slave->should_notify)
+			slave->should_notify = 0;
+		else
+			slave->should_notify = 1;
+	}
+}
+
+static inline void bond_slave_state_notify(struct bonding *bond,
+					   bool rtnl_locked)
+{
+	struct list_head *iter;
+	struct slave *tmp;
+
+	rcu_read_lock();
+	bond_for_each_slave_rcu(bond, tmp, iter) {
+		if (tmp->should_notify) {
+			rcu_read_unlock();
+			goto should_notify;
+		}
+	}
+	rcu_read_unlock();
+	return;
+
+should_notify:
+
+	if (!rtnl_locked && !rtnl_trylock())
+		return;
+
+	bond_for_each_slave(bond, tmp, iter) {
+		if (tmp->should_notify) {
+			rtmsg_ifinfo(RTM_NEWLINK, tmp->dev, 0, GFP_KERNEL);
+			tmp->should_notify = 0;
+		}
+	}
+
+	if (!rtnl_locked)
+		rtnl_unlock();
 }
 
 static inline void bond_slave_state_change(struct bonding *bond)
-- 
1.8.0

From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/3] bonding: add bond_set_slave_state/flags()
Date: Mon, 17 Feb 2014 16:35:49 +0800
Message-ID: <1392626151-23916-2-git-send-email-dingtianhong@huawei.com>
References: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <cwang@twopensource.com>, <jiri@resnulli.us>,
	<thomas@glanzmann.de>, <eric.dumazet@gmail.com>,
	<sfeldma@cumulusnetworks.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:49432 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbaBQIgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 03:36:51 -0500
In-Reply-To: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new function could change the slave state and flags, then call
rtmsg_ifinfo() according to the input parameters notify.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bonding.h | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 86ccfb9..d210124 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -303,6 +303,18 @@ static inline void bond_set_backup_slave(struct slave *slave)
 	}
 }
 
+static inline void bond_set_slave_state(struct slave *slave,
+					int slave_state, bool notify)
+{
+	if (slave->backup != slave_state)
+		slave->backup = slave_state;
+	else
+		return;
+
+	if (notify)
+		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
+}
+
 static inline void bond_slave_state_change(struct bonding *bond)
 {
 	struct list_head *iter;
@@ -408,6 +420,20 @@ static inline void bond_set_slave_active_flags(struct slave *slave)
 	slave->inactive = 0;
 }
 
+static inline void bond_set_slave_flags(struct slave *slave,
+					int state, bool notify)
+
+{
+	if (state == BOND_STATE_ACTIVE) {
+		bond_set_slave_state(slave, state, notify);
+		slave->inactive = 0;
+	} else if (state == BOND_STATE_BACKUP && !bond_is_lb(slave->bond)) {
+		bond_set_slave_state(slave, state, notify);
+		if (!slave->bond->params.all_slaves_active)
+			slave->inactive = 1;
+	}
+}
+
 static inline bool bond_is_slave_inactive(struct slave *slave)
 {
 	return slave->inactive;
-- 
1.8.0

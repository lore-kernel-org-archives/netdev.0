From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 1/3] bonding: remove rtmsg_ifinfo called in bond_master_upper_dev_link
Date: Tue, 17 Oct 2017 17:39:39 +0800
Message-ID: <54188a4761376d409cde7bf746edc877b4c3f0ae.1508233044.git.lucien.xin@gmail.com>
References: <cover.1508233044.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Jiri Pirko <jiri@resnulli.us>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:55097 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934799AbdJQJj6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 05:39:58 -0400
Received: by mail-pf0-f195.google.com with SMTP id n89so941880pfk.11
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 02:39:58 -0700 (PDT)
In-Reply-To: <cover.1508233044.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508233044.git.lucien.xin@gmail.com>
References: <cover.1508233044.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 42e52bf9e3ae ("net: add netnotifier event for upper device
change"), netdev_master_upper_dev_link has generated NETDEV_CHANGEUPPER
event which would send a notification to userspace in rtnetlink_event.

There's no need to call rtmsg_ifinfo to send the notification any more.
So this patch is to remove it from bond_master_upper_dev_link as well
as bond_upper_dev_unlink to avoid the redundant notifications.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 drivers/net/bonding/bond_main.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c99dc59..ba75014 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1220,22 +1220,17 @@ static enum netdev_lag_tx_type bond_lag_tx_type(struct bonding *bond)
 static int bond_master_upper_dev_link(struct bonding *bond, struct slave *slave)
 {
 	struct netdev_lag_upper_info lag_upper_info;
-	int err;
 
 	lag_upper_info.tx_type = bond_lag_tx_type(bond);
-	err = netdev_master_upper_dev_link(slave->dev, bond->dev, slave,
-					   &lag_upper_info);
-	if (err)
-		return err;
-	rtmsg_ifinfo(RTM_NEWLINK, slave->dev, IFF_SLAVE, GFP_KERNEL);
-	return 0;
+
+	return netdev_master_upper_dev_link(slave->dev, bond->dev, slave,
+					    &lag_upper_info);
 }
 
 static void bond_upper_dev_unlink(struct bonding *bond, struct slave *slave)
 {
 	netdev_upper_dev_unlink(slave->dev, bond->dev);
 	slave->dev->flags &= ~IFF_SLAVE;
-	rtmsg_ifinfo(RTM_NEWLINK, slave->dev, IFF_SLAVE, GFP_KERNEL);
 }
 
 static struct slave *bond_alloc_slave(struct bonding *bond)
-- 
2.1.0

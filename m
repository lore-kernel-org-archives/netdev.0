From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 2/4] bonding: remove rtmsg_ifinfo called in bond_master_upper_dev_link
Date: Tue, 24 Oct 2017 13:54:18 +0800
Message-ID: <1e175dc56b1dbd2a42ce7c8e6fc29d6c19185240.1508824093.git.lucien.xin@gmail.com>
References: <cover.1508824093.git.lucien.xin@gmail.com>
 <7e91d225f138a96c791574d050c95679c08c80d8.1508824093.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, David Ahern <dsahern@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:55387 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751398AbdJXFyp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 01:54:45 -0400
Received: by mail-pf0-f194.google.com with SMTP id 17so18892507pfn.12
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 22:54:45 -0700 (PDT)
In-Reply-To: <7e91d225f138a96c791574d050c95679c08c80d8.1508824093.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508824093.git.lucien.xin@gmail.com>
References: <cover.1508824093.git.lucien.xin@gmail.com>
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
index 172eeeb..18b58e1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1221,22 +1221,17 @@ static int bond_master_upper_dev_link(struct bonding *bond, struct slave *slave,
 				      struct netlink_ext_ack *extack)
 {
 	struct netdev_lag_upper_info lag_upper_info;
-	int err;
 
 	lag_upper_info.tx_type = bond_lag_tx_type(bond);
-	err = netdev_master_upper_dev_link(slave->dev, bond->dev, slave,
-					   &lag_upper_info, extack);
-	if (err)
-		return err;
-	rtmsg_ifinfo(RTM_NEWLINK, slave->dev, IFF_SLAVE, GFP_KERNEL);
-	return 0;
+
+	return netdev_master_upper_dev_link(slave->dev, bond->dev, slave,
+					    &lag_upper_info, extack);
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

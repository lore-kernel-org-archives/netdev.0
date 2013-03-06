From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] bonding: fire NETDEV_RELEASE event only on 0 slaves
Date: Wed,  6 Mar 2013 18:10:32 +0100
Message-ID: <1362589832-9526-1-git-send-email-vfalico@redhat.com>
Cc: nhorman@tuxdriver.com, fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62046 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974Ab3CFRNs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 12:13:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if we set up netconsole over bonding and release a slave,
netconsole will stop logging on the whole bonding device. Change the
behavior to stop the netconsole only when the last slave is released.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7bd068a..8b4e96e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1964,7 +1964,6 @@ static int __bond_release_one(struct net_device *bond_dev,
 	}
 
 	block_netpoll_tx();
-	call_netdevice_notifiers(NETDEV_RELEASE, bond_dev);
 	write_lock_bh(&bond->lock);
 
 	slave = bond_get_slave_by_dev(bond, slave_dev);
@@ -2066,8 +2065,10 @@ static int __bond_release_one(struct net_device *bond_dev,
 	write_unlock_bh(&bond->lock);
 	unblock_netpoll_tx();
 
-	if (bond->slave_cnt == 0)
+	if (bond->slave_cnt == 0) {
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
+		call_netdevice_notifiers(NETDEV_RELEASE, bond->dev);
+	}
 
 	bond_compute_features(bond);
 	if (!(bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
-- 
1.7.1

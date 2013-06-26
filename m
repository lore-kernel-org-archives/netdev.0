From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 1/3] bonding: remove unnecessary setup_by_slave member
Date: Wed, 26 Jun 2013 17:13:37 +0200
Message-ID: <1372259619-32430-2-git-send-email-nikolay@redhat.com>
References: <1372259619-32430-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14748 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751569Ab3FZPRR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 11:17:17 -0400
In-Reply-To: <1372259619-32430-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a member called setup_by_slave in struct bonding to denote if the
bond dev has different type than ARPHRD_ETHER, but that is already denoted
in bond's netdev type variable if it was setup by the slave, so use that
instead of the member.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 5 +----
 drivers/net/bonding/bonding.h   | 1 -
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 142d55d..2e8b9f1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1382,8 +1382,6 @@ done:
 static void bond_setup_by_slave(struct net_device *bond_dev,
 				struct net_device *slave_dev)
 {
-	struct bonding *bond = netdev_priv(bond_dev);
-
 	bond_dev->header_ops	    = slave_dev->header_ops;
 
 	bond_dev->type		    = slave_dev->type;
@@ -1392,7 +1390,6 @@ static void bond_setup_by_slave(struct net_device *bond_dev,
 
 	memcpy(bond_dev->broadcast, slave_dev->broadcast,
 		slave_dev->addr_len);
-	bond->setup_by_slave = 1;
 }
 
 /* On bonding slaves other than the currently active slave, suppress
@@ -3187,7 +3184,7 @@ static int bond_slave_netdev_event(unsigned long event,
 
 	switch (event) {
 	case NETDEV_UNREGISTER:
-		if (bond->setup_by_slave)
+		if (bond_dev->type != ARPHRD_ETHER)
 			bond_release_and_destroy(bond_dev, slave_dev);
 		else
 			bond_release(bond_dev, slave_dev);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 3fb73cc..c6c8d03 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -226,7 +226,6 @@ struct bonding {
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
 	u8	 send_peer_notif;
-	s8	 setup_by_slave;
 	u8       igmp_retrans;
 #ifdef CONFIG_PROC_FS
 	struct   proc_dir_entry *proc_entry;
-- 
1.8.1.4

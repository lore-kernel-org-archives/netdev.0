From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 4/7] bonding: convert curr_slave_lock to a spinlock and rename it
Date: Thu, 11 Sep 2014 22:49:25 +0200
Message-ID: <1410468568-13781-5-git-send-email-nikolay@redhat.com>
References: <1410468568-13781-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757377AbaIKUur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 16:50:47 -0400
In-Reply-To: <1410468568-13781-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

curr_slave_lock is now a misleading name, a much better name is
mode_lock as it'll be used for each mode's purposes and it's no longer
necessary to use a rwlock, a simple spinlock is enough.

Suggested-by: Jay Vosburgh <jay.vosburgh@canonical.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_3ad.c  | 4 ++--
 drivers/net/bonding/bond_main.c | 7 +++----
 drivers/net/bonding/bonding.h   | 2 +-
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index dfd3a7835d17..1824d1df4d09 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2057,7 +2057,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	struct port *port;
 	bool should_notify_rtnl = BOND_SLAVE_NOTIFY_LATER;
 
-	read_lock(&bond->curr_slave_lock);
+	spin_lock_bh(&bond->mode_lock);
 	rcu_read_lock();
 
 	/* check if there are any slaves */
@@ -2120,7 +2120,7 @@ re_arm:
 		}
 	}
 	rcu_read_unlock();
-	read_unlock(&bond->curr_slave_lock);
+	spin_unlock_bh(&bond->mode_lock);
 
 	if (should_notify_rtnl && rtnl_trylock()) {
 		bond_slave_state_notify(bond);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3b06685260b8..99d21c2fd44f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1679,9 +1679,9 @@ static int __bond_release_one(struct net_device *bond_dev,
 		/* Sync against bond_3ad_rx_indication and
 		 * bond_3ad_state_machine_handler
 		 */
-		write_lock_bh(&bond->curr_slave_lock);
+		spin_lock_bh(&bond->mode_lock);
 		bond_3ad_unbind_slave(slave);
-		write_unlock_bh(&bond->curr_slave_lock);
+		spin_unlock_bh(&bond->mode_lock);
 	}
 
 	netdev_info(bond_dev, "Releasing %s interface %s\n",
@@ -3850,8 +3850,7 @@ void bond_setup(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
-	/* initialize rwlocks */
-	rwlock_init(&bond->curr_slave_lock);
+	spin_lock_init(&bond->mode_lock);
 	bond->params = bonding_defaults;
 
 	/* Initialize pointers */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 02afdeb08765..0cda34b827f8 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -195,7 +195,7 @@ struct bonding {
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	int     (*recv_probe)(const struct sk_buff *, struct bonding *,
 			      struct slave *);
-	rwlock_t curr_slave_lock;
+	spinlock_t mode_lock;
 	u8	 send_peer_notif;
 	u8       igmp_retrans;
 #ifdef CONFIG_PROC_FS
-- 
1.9.3

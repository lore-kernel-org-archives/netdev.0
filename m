From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 2/7] bonding: 3ad: use curr_slave_lock instead of bond->lock
Date: Tue,  9 Sep 2014 23:16:58 +0200
Message-ID: <1410297423-26624-3-git-send-email-nikolay@redhat.com>
References: <1410297423-26624-1-git-send-email-nikolay@redhat.com>
Cc: hariprasad@chelsio.com, vfalico@gmail.com, j.vosburgh@gmail.com,
	andy@greyhouse.net, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46636 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751387AbaIIVRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 17:17:20 -0400
In-Reply-To: <1410297423-26624-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 3ad mode the only syncing needed by bond->lock is for the wq
and the recv handler, so change them to use curr_slave_lock.
There're no locking dependencies here as 3ad doesn't use
curr_slave_lock at all.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_3ad.c  |  9 ++++-----
 drivers/net/bonding/bond_main.c | 12 +++++++-----
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index ee2c73a9de39..5d27a6207384 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2057,7 +2057,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	struct port *port;
 	bool should_notify_rtnl = BOND_SLAVE_NOTIFY_LATER;
 
-	read_lock(&bond->lock);
+	read_lock(&bond->curr_slave_lock);
 	rcu_read_lock();
 
 	/* check if there are any slaves */
@@ -2120,7 +2120,7 @@ re_arm:
 		}
 	}
 	rcu_read_unlock();
-	read_unlock(&bond->lock);
+	read_unlock(&bond->curr_slave_lock);
 
 	if (should_notify_rtnl && rtnl_trylock()) {
 		bond_slave_state_notify(bond);
@@ -2395,7 +2395,6 @@ int __bond_3ad_get_active_agg_info(struct bonding *bond,
 	return 0;
 }
 
-/* Wrapper used to hold bond->lock so no slave manipulation can occur */
 int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
 {
 	int ret;
@@ -2487,9 +2486,9 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 	if (!lacpdu)
 		return ret;
 
-	read_lock(&bond->lock);
+	read_lock(&bond->curr_slave_lock);
 	ret = bond_3ad_rx_indication(lacpdu, slave, skb->len);
-	read_unlock(&bond->lock);
+	read_unlock(&bond->curr_slave_lock);
 	return ret;
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f0f5eab0fab1..dcd331bd0c17 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1687,13 +1687,15 @@ static int __bond_release_one(struct net_device *bond_dev,
 	 * for this slave anymore.
 	 */
 	netdev_rx_handler_unregister(slave_dev);
-	write_lock_bh(&bond->lock);
 
-	/* Inform AD package of unbinding of slave. */
-	if (BOND_MODE(bond) == BOND_MODE_8023AD)
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
+		/* Sync against bond_3ad_rx_indication and
+		 * bond_3ad_state_machine_handler
+		 */
+		write_lock_bh(&bond->curr_slave_lock);
 		bond_3ad_unbind_slave(slave);
-
-	write_unlock_bh(&bond->lock);
+		write_unlock_bh(&bond->curr_slave_lock);
+	}
 
 	netdev_info(bond_dev, "Releasing %s interface %s\n",
 		    bond_is_active_slave(slave) ? "active" : "backup",
-- 
1.9.3

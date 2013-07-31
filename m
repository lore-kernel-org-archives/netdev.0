From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 2/5] bonding: remove unnecessary read_locks of curr_slave_lock
Date: Wed, 31 Jul 2013 17:12:30 +0200
Message-ID: <1375283553-32070-3-git-send-email-nikolay@redhat.com>
References: <1375283553-32070-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, davem@davemloft.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60198 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759193Ab3GaPQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 11:16:50 -0400
In-Reply-To: <1375283553-32070-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In all the cases we already hold bond->lock for reading, so the slave
can't get away and the check != NULL is sufficient. curr_active_slave
can still change after the read_lock is unlocked prior to use of the
dereferenced value, so there's no need for it. It either contains a
valid slave which we use (and can't get away), or it is NULL which is
checked.
In some places the read_lock of curr_slave_lock was left because we need
it not to change while performing some action (e.g. syncing current
active slave's addresses, sending ARP requests through the active slave)
such cases will be dealt with individually while converting to RCU.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 33 ++++++++-------------------------
 1 file changed, 8 insertions(+), 25 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d50a511..92f8aed 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2092,23 +2092,19 @@ static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_devi
 
 	read_lock(&bond->lock);
 
-	read_lock(&bond->curr_slave_lock);
 	old_active = bond->curr_active_slave;
-	read_unlock(&bond->curr_slave_lock);
-
 	new_active = bond_get_slave_by_dev(bond, slave_dev);
-
 	/*
 	 * Changing to the current active: do nothing; return success.
 	 */
-	if (new_active && (new_active == old_active)) {
+	if (new_active && new_active == old_active) {
 		read_unlock(&bond->lock);
 		return 0;
 	}
 
-	if ((new_active) &&
-	    (old_active) &&
-	    (new_active->link == BOND_LINK_UP) &&
+	if (new_active &&
+	    old_active &&
+	    new_active->link == BOND_LINK_UP &&
 	    IS_UP(new_active->dev)) {
 		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
@@ -2662,10 +2658,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	if (bond->slave_cnt == 0)
 		goto re_arm;
 
-	read_lock(&bond->curr_slave_lock);
 	oldcurrent = bond->curr_active_slave;
-	read_unlock(&bond->curr_slave_lock);
-
 	/* see if any of the previous devices are up now (i.e. they have
 	 * xmt and rcv traffic). the curr_active_slave does not come into
 	 * the picture unless it is null. also, slave->jiffies is not needed
@@ -3824,11 +3817,7 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 	 */
 	if ((iph->protocol == IPPROTO_IGMP) &&
 	    (skb->protocol == htons(ETH_P_IP))) {
-
-		read_lock(&bond->curr_slave_lock);
 		slave = bond->curr_active_slave;
-		read_unlock(&bond->curr_slave_lock);
-
 		if (!slave)
 			goto out;
 	} else {
@@ -3873,15 +3862,12 @@ out:
 static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave;
 	int res = 1;
 
-	read_lock(&bond->curr_slave_lock);
-
-	if (bond->curr_active_slave)
-		res = bond_dev_queue_xmit(bond, skb,
-			bond->curr_active_slave->dev);
-
-	read_unlock(&bond->curr_slave_lock);
+	slave = bond->curr_active_slave;
+	if (slave)
+		res = bond_dev_queue_xmit(bond, skb, slave->dev);
 
 	if (res)
 		/* no suitable interface, frame not sent */
@@ -3941,10 +3927,7 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 	int i;
 	int res = 1;
 
-	read_lock(&bond->curr_slave_lock);
 	start_at = bond->curr_active_slave;
-	read_unlock(&bond->curr_slave_lock);
-
 	if (!start_at)
 		goto out;
 
-- 
1.8.1.4

From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [RFC net-next 4/5] bonding: options: remove bond->lock usage
Date: Fri,  5 Sep 2014 20:16:50 +0200
Message-ID: <1409941011-5494-5-git-send-email-nikolay@redhat.com>
References: <1409941011-5494-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28361 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751536AbaIESRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 14:17:09 -0400
In-Reply-To: <1409941011-5494-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're safe to remove the bond->lock use from the arp targets because
arp_rcv_probe no longer acquires bond->lock, only rcu_read_lock.
Also setting the primary slave is safe because noone uses the bond->lock
as a syncing mechanism for that anymore.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_options.c | 19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index d8dc17faa6b4..67a1c9bcdc43 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -955,14 +955,7 @@ static int _bond_option_arp_ip_target_add(struct bonding *bond, __be32 target)
 
 static int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target)
 {
-	int ret;
-
-	/* not to race with bond_arp_rcv */
-	write_lock_bh(&bond->lock);
-	ret = _bond_option_arp_ip_target_add(bond, target);
-	write_unlock_bh(&bond->lock);
-
-	return ret;
+	return _bond_option_arp_ip_target_add(bond, target);
 }
 
 static int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target)
@@ -991,9 +984,6 @@ static int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target)
 
 	netdev_info(bond->dev, "Removing ARP target %pI4\n", &target);
 
-	/* not to race with bond_arp_rcv */
-	write_lock_bh(&bond->lock);
-
 	bond_for_each_slave(bond, slave, iter) {
 		targets_rx = slave->target_last_arp_rx;
 		for (i = ind; (i < BOND_MAX_ARP_TARGETS-1) && targets[i+1]; i++)
@@ -1004,8 +994,6 @@ static int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target)
 		targets[i] = targets[i+1];
 	targets[i] = 0;
 
-	write_unlock_bh(&bond->lock);
-
 	return 0;
 }
 
@@ -1013,11 +1001,8 @@ void bond_option_arp_ip_targets_clear(struct bonding *bond)
 {
 	int i;
 
-	/* not to race with bond_arp_rcv */
-	write_lock_bh(&bond->lock);
 	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
 		_bond_options_arp_ip_target_set(bond, i, 0, 0);
-	write_unlock_bh(&bond->lock);
 }
 
 static int bond_option_arp_ip_targets_set(struct bonding *bond,
@@ -1081,7 +1066,6 @@ static int bond_option_primary_set(struct bonding *bond,
 	struct slave *slave;
 
 	block_netpoll_tx();
-	read_lock(&bond->lock);
 	write_lock_bh(&bond->curr_slave_lock);
 
 	p = strchr(primary, '\n');
@@ -1120,7 +1104,6 @@ static int bond_option_primary_set(struct bonding *bond,
 
 out:
 	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
 	unblock_netpoll_tx();
 
 	return 0;
-- 
1.9.3

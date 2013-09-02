From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 1/5] bonding: simplify and fix peer notification
Date: Mon,  2 Sep 2013 13:51:38 +0200
Message-ID: <1378122702-28943-2-git-send-email-nikolay@redhat.com>
References: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57494 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754338Ab3IBLzW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 07:55:22 -0400
In-Reply-To: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch aims to remove a use of the bond->lock for mutual exclusion
which will later allow easier migration to RCU of the users of this
functionality. We use RTNL as a synchronizing mechanism since it's
always held when send_peer_notif is set, and when it is decremented from
the notifier function. We can also drop some locking, and fix the
leakage of the send_peer_notif counter.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c50679f..05e638b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -828,7 +828,6 @@ static bool bond_should_notify_peers(struct bonding *bond)
 	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
 		return false;
 
-	bond->send_peer_notif--;
 	return true;
 }
 
@@ -2259,12 +2258,8 @@ re_arm:
 	read_unlock(&bond->lock);
 
 	if (should_notify_peers) {
-		if (!rtnl_trylock()) {
-			read_lock(&bond->lock);
-			bond->send_peer_notif++;
-			read_unlock(&bond->lock);
+		if (!rtnl_trylock())
 			return;
-		}
 		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
 		rtnl_unlock();
 	}
@@ -2876,12 +2871,8 @@ re_arm:
 	read_unlock(&bond->lock);
 
 	if (should_notify_peers) {
-		if (!rtnl_trylock()) {
-			read_lock(&bond->lock);
-			bond->send_peer_notif++;
-			read_unlock(&bond->lock);
+		if (!rtnl_trylock())
 			return;
-		}
 		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
 		rtnl_unlock();
 	}
@@ -2916,6 +2907,10 @@ static int bond_master_netdev_event(unsigned long event,
 	case NETDEV_REGISTER:
 		bond_create_proc_entry(event_bond);
 		break;
+	case NETDEV_NOTIFY_PEERS:
+		if (event_bond->send_peer_notif)
+			event_bond->send_peer_notif--;
+		break;
 	default:
 		break;
 	}
@@ -3213,11 +3208,8 @@ static int bond_close(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
-	write_lock_bh(&bond->lock);
-	bond->send_peer_notif = 0;
-	write_unlock_bh(&bond->lock);
-
 	bond_work_cancel_all(bond);
+	bond->send_peer_notif = 0;
 	if (bond_is_lb(bond)) {
 		/* Must be called only after all
 		 * slaves have been released
-- 
1.8.1.4

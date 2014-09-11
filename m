From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 1/7] bonding: 3ad: clean up curr_slave_lock usage
Date: Thu, 11 Sep 2014 13:38:37 +0200
Message-ID: <1410435523-7520-2-git-send-email-nikolay@redhat.com>
References: <1410435523-7520-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46717 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754475AbaIKLi4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 07:38:56 -0400
In-Reply-To: <1410435523-7520-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the read_lock in bond_3ad_lacpdu_recv() since when the slave is
being released its rx_handler is removed before 3ad unbind, so even if
packets arrive, they won't see the slave in an inconsistent state.
In bond_3ad_state_machine_handler() move the use of curr_slave_lock
around the only place that needs it: ad_agg_selection_logic. Since it
can traverse the lag_ports instead of the slave list, it could reach the
detached slave.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 5d27a6207384..6512c1cee666 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2057,7 +2057,6 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	struct port *port;
 	bool should_notify_rtnl = BOND_SLAVE_NOTIFY_LATER;
 
-	read_lock(&bond->curr_slave_lock);
 	rcu_read_lock();
 
 	/* check if there are any slaves */
@@ -2078,8 +2077,10 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 				goto re_arm;
 			}
 
+			read_lock(&bond->curr_slave_lock);
 			aggregator = __get_first_agg(port);
 			ad_agg_selection_logic(aggregator);
+			read_unlock(&bond->curr_slave_lock);
 		}
 		bond_3ad_set_carrier(bond);
 	}
@@ -2120,7 +2121,6 @@ re_arm:
 		}
 	}
 	rcu_read_unlock();
-	read_unlock(&bond->curr_slave_lock);
 
 	if (should_notify_rtnl && rtnl_trylock()) {
 		bond_slave_state_notify(bond);
@@ -2476,20 +2476,16 @@ err_free:
 int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 			 struct slave *slave)
 {
-	int ret = RX_HANDLER_ANOTHER;
 	struct lacpdu *lacpdu, _lacpdu;
 
 	if (skb->protocol != PKT_TYPE_LACPDU)
-		return ret;
+		return RX_HANDLER_ANOTHER;
 
 	lacpdu = skb_header_pointer(skb, 0, sizeof(_lacpdu), &_lacpdu);
 	if (!lacpdu)
-		return ret;
+		return RX_HANDLER_ANOTHER;
 
-	read_lock(&bond->curr_slave_lock);
-	ret = bond_3ad_rx_indication(lacpdu, slave, skb->len);
-	read_unlock(&bond->curr_slave_lock);
-	return ret;
+	return bond_3ad_rx_indication(lacpdu, slave, skb->len);
 }
 
 /**
-- 
1.9.3

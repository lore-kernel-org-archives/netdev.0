From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 10/10] net: dsa: Add lockdep class to tx queues to avoid lockdep splat
Date: Wed,  6 May 2015 01:09:56 +0200
Message-ID: <1430867396-2268-11-git-send-email-andrew@lunn.ch>
References: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44498 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbbEEXOv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 19:14:51 -0400
In-Reply-To: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSA stacks an Ethernet device on top of an Ethernet device. This can
cause false positive lockdep splats for the transmit queue:

=============================================
[ INFO: possible recursive locking detected ]
4.0.0-rc7-01838-g70621a215fc7 #386 Not tainted
---------------------------------------------
kworker/0:0/4 is trying to acquire lock:
 (_xmit_ETHER#2){+.-...}, at: [<c040e95c>] sch_direct_xmit+0xa8/0x1fc

but task is already holding lock:
 (_xmit_ETHER#2){+.-...}, at: [<c03f4208>] __dev_queue_xmit+0x4d4/0x56c

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(_xmit_ETHER#2);
  lock(_xmit_ETHER#2);

To avoid this, walk the tq queues of the dsa slaves and set a lockdep
class.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/slave.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 827cda560a55..03e041addea3 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -810,12 +810,19 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	return 0;
 }
 
+static struct lock_class_key dsa_slave_netdev_xmit_lock_key;
+static void dsa_slave_set_lockdep_class_one(struct net_device *dev,
+					    struct netdev_queue *txq,
+					    void *_unused)
+{
+	lockdep_set_class(&txq->_xmit_lock,
+			  &dsa_slave_netdev_xmit_lock_key);
+}
+
 int dsa_slave_suspend(struct net_device *slave_dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(slave_dev);
 
-	netif_device_detach(slave_dev);
-
 	if (p->phy) {
 		phy_stop(p->phy);
 		p->old_pause = -1;
@@ -861,6 +868,9 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	slave_dev->netdev_ops = &dsa_slave_netdev_ops;
 	slave_dev->swdev_ops = &dsa_slave_swdev_ops;
 
+	netdev_for_each_tx_queue(slave_dev, dsa_slave_set_lockdep_class_one,
+				 NULL);
+
 	SET_NETDEV_DEV(slave_dev, parent);
 	slave_dev->dev.of_node = ds->pd->port_dn[port];
 	slave_dev->vlan_features = master->vlan_features;
-- 
2.1.4

From: David Miller <davem@davemloft.net>
Subject: [PATCH 32/42] caif: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:34:06 -0700 (PDT)
Message-ID: <20110417.173406.241931499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51081
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754137Ab1DRAel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:41 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9DA1024C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:34:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'caifdef' is set but unused in modemcmd().

Similarly for 'net' in receive(), and 'res' in
caif_device_notify() and caif_exit_net().

Just kill them off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/caif/caif_dev.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index a518fdd..75e00d5 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -133,9 +133,7 @@ static int transmit(struct cflayer *layer, struct cfpkt *pkt)
 static int modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
 {
 	struct caif_device_entry *caifd;
-	struct caif_dev_common *caifdev;
 	caifd = container_of(layr, struct caif_device_entry, layer);
-	caifdev = netdev_priv(caifd->netdev);
 	if (ctrl == _CAIF_MODEMCMD_PHYIF_USEFULL) {
 		atomic_set(&caifd->in_use, 1);
 		wake_up_interruptible(&caifd->event);
@@ -154,10 +152,8 @@ static int modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
 static int receive(struct sk_buff *skb, struct net_device *dev,
 		   struct packet_type *pkttype, struct net_device *orig_dev)
 {
-	struct net *net;
 	struct cfpkt *pkt;
 	struct caif_device_entry *caifd;
-	net = dev_net(dev);
 	pkt = cfpkt_fromnative(CAIF_DIR_IN, skb);
 	caifd = caif_get(dev);
 	if (!caifd || !caifd->layer.up || !caifd->layer.up->receive)
@@ -195,7 +191,6 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 	struct caif_device_entry *caifd = NULL;
 	struct caif_dev_common *caifdev;
 	enum cfcnfg_phy_preference pref;
-	int res = -EINVAL;
 	enum cfcnfg_phy_type phy_type;
 
 	if (dev->type != ARPHRD_CAIF)
@@ -210,7 +205,6 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 		caifdev = netdev_priv(dev);
 		caifdev->flowctrl = dev_flowctrl;
 		atomic_set(&caifd->state, what);
-		res = 0;
 		break;
 
 	case NETDEV_UP:
@@ -274,7 +268,7 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 					 _CAIF_CTRLCMD_PHYIF_DOWN_IND,
 					 caifd->layer.id);
 		might_sleep();
-		res = wait_event_interruptible_timeout(caifd->event,
+		wait_event_interruptible_timeout(caifd->event,
 					atomic_read(&caifd->in_use) == 0,
 					TIMEOUT);
 		break;
@@ -344,12 +338,11 @@ static int caif_init_net(struct net *net)
 static void caif_exit_net(struct net *net)
 {
 	struct net_device *dev;
-	int res;
 	rtnl_lock();
 	for_each_netdev(net, dev) {
 		if (dev->type != ARPHRD_CAIF)
 			continue;
-		res = dev_close(dev);
+		dev_close(dev);
 		caif_device_destroy(dev);
 	}
 	rtnl_unlock();
-- 
1.7.4.3


From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] macsec: use after free when deleting the underlying device
Date: Thu, 11 Aug 2016 15:24:27 +0200
Message-ID: <33fb7087b1e258144cc5d2ab155ecf11a8f410bb.1470921449.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42858 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751839AbcHKNYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2016 09:24:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macsec_notify() loops over the list of macsec devices configured on the
underlying device when this device is being removed.  This list is part
of the rx_handler data.

However, macsec_dellink unregisters the rx_handler and frees the
rx_handler data when the last macsec device is removed from the
underlying device.

Add macsec_common_dellink() to delete macsec devices without
unregistering the rx_handler and freeing the associated data.

Fixes: 960d5848dbf1 ("macsec: fix memory leaks around rx_handler (un)registration")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index d13e6e15d7b5..dbd590a8177f 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -3047,22 +3047,29 @@ static void macsec_del_dev(struct macsec_dev *macsec)
 	}
 }
 
+static void macsec_common_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct macsec_dev *macsec = macsec_priv(dev);
+
+	unregister_netdevice_queue(dev, head);
+	list_del_rcu(&macsec->secys);
+	macsec_del_dev(macsec);
+
+	macsec_generation++;
+}
+
 static void macsec_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct macsec_dev *macsec = macsec_priv(dev);
 	struct net_device *real_dev = macsec->real_dev;
 	struct macsec_rxh_data *rxd = macsec_data_rtnl(real_dev);
 
-	macsec_generation++;
+	macsec_common_dellink(dev, head);
 
-	unregister_netdevice_queue(dev, head);
-	list_del_rcu(&macsec->secys);
 	if (list_empty(&rxd->secys)) {
 		netdev_rx_handler_unregister(real_dev);
 		kfree(rxd);
 	}
-
-	macsec_del_dev(macsec);
 }
 
 static int register_macsec_dev(struct net_device *real_dev,
@@ -3382,8 +3389,12 @@ static int macsec_notify(struct notifier_block *this, unsigned long event,
 
 		rxd = macsec_data_rtnl(real_dev);
 		list_for_each_entry_safe(m, n, &rxd->secys, secys) {
-			macsec_dellink(m->secy.netdev, &head);
+			macsec_common_dellink(m->secy.netdev, &head);
 		}
+
+		netdev_rx_handler_unregister(real_dev);
+		kfree(rxd);
+
 		unregister_netdevice_many(&head);
 		break;
 	}
-- 
2.9.2

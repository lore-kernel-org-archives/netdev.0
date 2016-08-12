From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net 1/2] macsec: fix lockdep splats when nesting devices
Date: Fri, 12 Aug 2016 16:10:32 +0200
Message-ID: <4c1a6a53725cc0ec023f92dae1165f3ade1e7862.1470951139.git.sd@queasysnail.net>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47708 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596AbcHLOLO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 10:11:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, trying to setup a vlan over a macsec device, or other
combinations of devices, triggers a lockdep warning.

Use netdev_lockdep_set_classes and ndo_get_lock_subclass, similar to
what macvlan does.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index dbd590a8177f..2043e8c97a81 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -270,6 +270,7 @@ struct macsec_dev {
 	struct pcpu_secy_stats __percpu *stats;
 	struct list_head secys;
 	struct gro_cells gro_cells;
+	unsigned int nest_level;
 };
 
 /**
@@ -2699,6 +2700,8 @@ static netdev_tx_t macsec_start_xmit(struct sk_buff *skb,
 
 #define MACSEC_FEATURES \
 	(NETIF_F_SG | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST)
+static struct lock_class_key macsec_netdev_addr_lock_key;
+
 static int macsec_dev_init(struct net_device *dev)
 {
 	struct macsec_dev *macsec = macsec_priv(dev);
@@ -2910,6 +2913,13 @@ static int macsec_get_iflink(const struct net_device *dev)
 	return macsec_priv(dev)->real_dev->ifindex;
 }
 
+
+static int macsec_get_nest_level(struct net_device *dev)
+{
+	return macsec_priv(dev)->nest_level;
+}
+
+
 static const struct net_device_ops macsec_netdev_ops = {
 	.ndo_init		= macsec_dev_init,
 	.ndo_uninit		= macsec_dev_uninit,
@@ -2923,6 +2933,7 @@ static const struct net_device_ops macsec_netdev_ops = {
 	.ndo_start_xmit		= macsec_start_xmit,
 	.ndo_get_stats64	= macsec_get_stats64,
 	.ndo_get_iflink		= macsec_get_iflink,
+	.ndo_get_lock_subclass  = macsec_get_nest_level,
 };
 
 static const struct device_type macsec_type = {
@@ -3050,10 +3061,12 @@ static void macsec_del_dev(struct macsec_dev *macsec)
 static void macsec_common_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct macsec_dev *macsec = macsec_priv(dev);
+	struct net_device *real_dev = macsec->real_dev;
 
 	unregister_netdevice_queue(dev, head);
 	list_del_rcu(&macsec->secys);
 	macsec_del_dev(macsec);
+	netdev_upper_dev_unlink(real_dev, dev);
 
 	macsec_generation++;
 }
@@ -3188,6 +3201,16 @@ static int macsec_newlink(struct net *net, struct net_device *dev,
 
 	dev_hold(real_dev);
 
+	macsec->nest_level = dev_get_nest_level(real_dev, netif_is_macsec) + 1;
+	netdev_lockdep_set_classes(dev);
+	lockdep_set_class_and_subclass(&dev->addr_list_lock,
+				       &macsec_netdev_addr_lock_key,
+				       macsec_get_nest_level(dev));
+
+	err = netdev_upper_dev_link(real_dev, dev);
+	if (err < 0)
+		goto unregister;
+
 	/* need to be already registered so that ->init has run and
 	 * the MAC addr is set
 	 */
@@ -3200,12 +3223,12 @@ static int macsec_newlink(struct net *net, struct net_device *dev,
 
 	if (rx_handler && sci_exists(real_dev, sci)) {
 		err = -EBUSY;
-		goto unregister;
+		goto unlink;
 	}
 
 	err = macsec_add_dev(dev, sci, icv_len);
 	if (err)
-		goto unregister;
+		goto unlink;
 
 	if (data)
 		macsec_changelink_common(dev, data);
@@ -3220,6 +3243,8 @@ static int macsec_newlink(struct net *net, struct net_device *dev,
 
 del_dev:
 	macsec_del_dev(macsec);
+unlink:
+	netdev_upper_dev_unlink(real_dev, dev);
 unregister:
 	unregister_netdevice(dev);
 	return err;
-- 
2.9.2

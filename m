From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/2] atm: [lec] initialize .netdev_ops before calling register_netdev()
Date: Fri, 04 Dec 2009 10:19:30 -0500
Message-ID: <200912041519.nB4FJUs4027018@cmf.nrl.navy.mil>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:57005 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbZLDPe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 10:34:26 -0500
Received: from cmf.nrl.navy.mil (thirdoffive.cmf.nrl.navy.mil [134.207.12.180])
	by hedwig.cmf.nrl.navy.mil (8.14.2/8.14.2) with ESMTP id nB4FJVW6031356
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 4 Dec 2009 10:19:32 -0500
Received: from thirdoffive.cmf.nrl.navy.mil (chas@localhost)
	by cmf.nrl.navy.mil (8.14.3/8.14.3/Submit) with ESMTP id nB4FJUs4027018
	for <netdev@vger.kernel.org>; Fri, 4 Dec 2009 10:19:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

atm: [lec] initialize .netdev_ops before calling register_netdev()

fix oops when initializing lane interfaces. lec should probably be
changed to use alloc_netdev() instead.

Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

diff --git a/net/atm/lec.c b/net/atm/lec.c
index b2d6445..42749b7 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -62,7 +62,6 @@ static int lec_open(struct net_device *dev);
 static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 				  struct net_device *dev);
 static int lec_close(struct net_device *dev);
-static void lec_init(struct net_device *dev);
 static struct lec_arp_table *lec_arp_find(struct lec_priv *priv,
 					  const unsigned char *mac_addr);
 static int lec_arp_remove(struct lec_priv *priv,
@@ -670,13 +669,6 @@ static const struct net_device_ops lec_netdev_ops = {
 	.ndo_set_multicast_list	= lec_set_multicast_list,
 };
 
-
-static void lec_init(struct net_device *dev)
-{
-	dev->netdev_ops = &lec_netdev_ops;
-	printk("%s: Initialized!\n", dev->name);
-}
-
 static const unsigned char lec_ctrl_magic[] = {
 	0xff,
 	0x00,
@@ -893,6 +885,7 @@ static int lecd_attach(struct atm_vcc *vcc, int arg)
 			dev_lec[i] = alloc_etherdev(size);
 		if (!dev_lec[i])
 			return -ENOMEM;
+		dev_lec[i]->netdev_ops = &lec_netdev_ops;
 		snprintf(dev_lec[i]->name, IFNAMSIZ, "lec%d", i);
 		if (register_netdev(dev_lec[i])) {
 			free_netdev(dev_lec[i]);
@@ -901,7 +894,6 @@ static int lecd_attach(struct atm_vcc *vcc, int arg)
 
 		priv = netdev_priv(dev_lec[i]);
 		priv->is_trdev = is_trdev;
-		lec_init(dev_lec[i]);
 	} else {
 		priv = netdev_priv(dev_lec[i]);
 		if (priv->lecd)

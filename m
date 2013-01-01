From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/7] um: net: use eth_hw_addr_random() to generate random mac
Date: Tue,  1 Jan 2013 14:30:18 +0100
Message-ID: <1357047019-1037-7-git-send-email-jiri@resnulli.us>
References: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	sassmann@redhat.com, kaber@trash.net, richard@nod.at
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:33763 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341Ab3AANao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2013 08:30:44 -0500
Received: by mail-ee0-f47.google.com with SMTP id e51so6378803eek.6
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2013 05:30:43 -0800 (PST)
In-Reply-To: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also remove unused "mac" from uml_net struct.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 arch/um/drivers/net_kern.c        | 22 ++++++++--------------
 arch/um/include/shared/net_kern.h |  1 -
 2 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index b1314eb..fd9090d 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -293,8 +293,9 @@ static void uml_net_user_timer_expire(unsigned long _conn)
 #endif
 }
 
-static int setup_etheraddr(char *str, unsigned char *addr, char *name)
+static void setup_etheraddr(struct net_device *dev, char *str)
 {
+	unsigned char *addr = dev->dev_addr;
 	char *end;
 	int i;
 
@@ -334,13 +335,12 @@ static int setup_etheraddr(char *str, unsigned char *addr, char *name)
 		       addr[0] | 0x02, addr[1], addr[2], addr[3], addr[4],
 		       addr[5]);
 	}
-	return 0;
+	return;
 
 random:
 	printk(KERN_INFO
-	       "Choosing a random ethernet address for device %s\n", name);
-	eth_random_addr(addr);
-	return 1;
+	       "Choosing a random ethernet address for device %s\n", dev->name);
+	eth_hw_addr_random(dev);
 }
 
 static DEFINE_SPINLOCK(devices_lock);
@@ -392,7 +392,6 @@ static void eth_configure(int n, void *init, char *mac,
 	struct net_device *dev;
 	struct uml_net_private *lp;
 	int err, size;
-	int random_mac;
 
 	size = transport->private_size + sizeof(struct uml_net_private);
 
@@ -419,9 +418,9 @@ static void eth_configure(int n, void *init, char *mac,
 	 */
 	snprintf(dev->name, sizeof(dev->name), "eth%d", n);
 
-	random_mac = setup_etheraddr(mac, device->mac, dev->name);
+	setup_etheraddr(dev, mac);
 
-	printk(KERN_INFO "Netdevice %d (%pM) : ", n, device->mac);
+	printk(KERN_INFO "Netdevice %d (%pM) : ", n, dev->dev_addr);
 
 	lp = netdev_priv(dev);
 	/* This points to the transport private data. It's still clear, but we
@@ -468,17 +467,12 @@ static void eth_configure(int n, void *init, char *mac,
 	init_timer(&lp->tl);
 	spin_lock_init(&lp->lock);
 	lp->tl.function = uml_net_user_timer_expire;
-	memcpy(lp->mac, device->mac, sizeof(lp->mac));
+	memcpy(lp->mac, dev->dev_addr, sizeof(lp->mac));
 
 	if ((transport->user->init != NULL) &&
 	    ((*transport->user->init)(&lp->user, dev) != 0))
 		goto out_unregister;
 
-	/* don't use eth_mac_addr, it will not work here */
-	memcpy(dev->dev_addr, device->mac, ETH_ALEN);
-	if (random_mac)
-		dev->addr_assign_type |= NET_ADDR_RANDOM;
-
 	dev->mtu = transport->user->mtu;
 	dev->netdev_ops = &uml_netdev_ops;
 	dev->ethtool_ops = &uml_net_ethtool_ops;
diff --git a/arch/um/include/shared/net_kern.h b/arch/um/include/shared/net_kern.h
index 5c367f2..012ac87 100644
--- a/arch/um/include/shared/net_kern.h
+++ b/arch/um/include/shared/net_kern.h
@@ -18,7 +18,6 @@ struct uml_net {
 	struct net_device *dev;
 	struct platform_device pdev;
 	int index;
-	unsigned char mac[ETH_ALEN];
 };
 
 struct uml_net_private {
-- 
1.8.0

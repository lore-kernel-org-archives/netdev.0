From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] forcedeth: add set_mac_address support
Date: Fri, 22 Jul 2005 22:48:02 +0200
Message-ID: <42E15B82.9020006@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090704050606080709090205"
Cc: Netdev <netdev@oss.sgi.com>, Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090704050606080709090205
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff,

Ayaz wrote a patch that adds set_mac_address to the forcedeth nic.
Could you add it to your tree? set_mac_address is required for some 
bonding modes.

Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>

--------------090704050606080709090205
Content-Type: text/plain;
 name="patch-forcedeth-040-set_mac_address"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-040-set_mac_address"

--- 2.6/drivers/net/forcedeth.c	2005-07-22 22:47:01.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2005-07-22 22:47:31.000000000 +0200
@@ -90,6 +90,7 @@
  *	0.38: 16 Jul 2005: tx irq rewrite: Use global flags instead of
  *			   per-packet flags.
  *      0.39: 18 Jul 2005: Add 64bit descriptor support.
+ *      0.40: 19 Jul 2005: Add support for mac address change.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -1417,6 +1418,54 @@
 }
 
 /*
+ * nv_set_mac_address: dev->set_mac_address function
+ * Called with rtnl_lock() held.
+ */
+static int nv_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct fe_priv *np = get_nvpriv(dev);
+	u8 *base = get_hwbase(dev);
+	struct sockaddr *macaddr = (struct sockaddr*)addr;
+	u32 mac[2];
+
+	if(!is_valid_ether_addr(macaddr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	/* synchronized against open : rtnl_lock() held by caller */
+	if (netif_running(dev)) {
+		spin_lock_bh(&dev->xmit_lock);
+		spin_lock_irq(&np->lock);
+
+		/* stop rx engine */
+		nv_stop_rx(dev);
+
+		/* set mac address */
+		memcpy(dev->dev_addr, macaddr->sa_data, ETH_ALEN);
+		mac[0] = (dev->dev_addr[0] << 0) + (dev->dev_addr[1] << 8) +
+				(dev->dev_addr[2] << 16) + (dev->dev_addr[3] << 24);
+		mac[1] = (dev->dev_addr[4] << 0) + (dev->dev_addr[5] << 8);
+
+		writel(mac[0], base + NvRegMacAddrA);
+		writel(mac[1], base + NvRegMacAddrB);
+	
+		/* restart rx engine */
+		nv_start_rx(dev);
+		spin_unlock_irq(&np->lock);
+		spin_unlock_bh(&dev->xmit_lock);
+	} else {
+		/* set mac address */
+		memcpy(dev->dev_addr, macaddr->sa_data, ETH_ALEN);
+		mac[0] = (dev->dev_addr[0] << 0) + (dev->dev_addr[1] << 8) +
+				(dev->dev_addr[2] << 16) + (dev->dev_addr[3] << 24);
+		mac[1] = (dev->dev_addr[4] << 0) + (dev->dev_addr[5] << 8);
+
+		writel(mac[0], base + NvRegMacAddrA);
+		writel(mac[1], base + NvRegMacAddrB);
+	}
+	return 0;
+}
+
+/*
  * nv_set_multicast: dev->set_multicast function
  * Called with dev->xmit_lock held.
  */
@@ -2298,6 +2347,7 @@
 	dev->hard_start_xmit = nv_start_xmit;
 	dev->get_stats = nv_get_stats;
 	dev->change_mtu = nv_change_mtu;
+	dev->set_mac_address = nv_set_mac_address;
 	dev->set_multicast_list = nv_set_multicast;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = nv_poll_controller;

--------------090704050606080709090205--

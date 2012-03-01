From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 1/7] net: validate MAC address directly in dev_set_mac_address()
Date: Thu,  1 Mar 2012 17:52:21 +0100
Message-ID: <1330620747-4047-2-git-send-email-danny.kukawka@bisect.de>
References: <1330620747-4047-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Jiri Pirko <jpirko@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wp188.webpack.hosteurope.de ([80.237.132.195]:51683 "EHLO
	wp188.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758659Ab2CAQxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 11:53:20 -0500
In-Reply-To: <1330620747-4047-1-git-send-email-danny.kukawka@bisect.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Validate the given MAC address directly in dev_set_mac_address()
if a .ndo_validate_addr function is available before calling
the .ndo_set_mac_address function.

Changed .ndo_validate_addr to take a second parameter containing
a sockaddr struct to be checked instead of the net_device dev_addr.
The behaviour of .ndo_validate_addr is now: if the second parameter
is NULL the net_device->dev_addr gets validate, if != NULL
the given parameter/sockaddr gets validated instead.

Removed is_valid_ether_addr() check from eth_mac_addr() since
this is now done in dev_set_mac_address(). Adapted eth_validate_addr()
to the changes.

Adopted bnx2x_validate_addr() to changes in .ndo_validate_addr,
handle second parameter to be validated.

v2: - collect parameter for bnx2x_is_valid_ether_addr() and
      is_valid_ether_addr() and call them only once at end of
      the functions.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   11 +++++++++--
 include/linux/etherdevice.h                      |    2 +-
 include/linux/netdevice.h                        |    7 +++++--
 net/core/dev.c                                   |    7 ++++++-
 net/ethernet/eth.c                               |   13 +++++++++----
 5 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b4afef6..3ffdbd3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10532,12 +10532,19 @@ static void poll_bnx2x(struct net_device *dev)
 }
 #endif
 
-static int bnx2x_validate_addr(struct net_device *dev)
+static int bnx2x_validate_addr(struct net_device *dev, void *addr)
 {
 	struct bnx2x *bp = netdev_priv(dev);
+	u8 *vaddr;
 
-	if (!bnx2x_is_valid_ether_addr(bp, dev->dev_addr))
+	if (addr)
+		vaddr = ((struct sockaddr *) addr)->sa_data;
+	else
+		vaddr = dev->dev_addr;
+
+	if (!bnx2x_is_valid_ether_addr(bp, vaddr))
 		return -EADDRNOTAVAIL;
+
 	return 0;
 }
 
diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 8a18358..ee3091f 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -44,7 +44,7 @@ extern void eth_header_cache_update(struct hh_cache *hh,
 				    const unsigned char *haddr);
 extern int eth_mac_addr(struct net_device *dev, void *p);
 extern int eth_change_mtu(struct net_device *dev, int new_mtu);
-extern int eth_validate_addr(struct net_device *dev);
+extern int eth_validate_addr(struct net_device *dev, void *addr);
 
 
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f1b7d03..08186e3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -772,8 +772,10 @@ struct netdev_fcoe_hbainfo {
  *	needs to be changed. If this interface is not defined, the
  *	mac address can not be changed.
  *
- * int (*ndo_validate_addr)(struct net_device *dev);
+ * int (*ndo_validate_addr)(struct net_device *dev, void *addr);
  *	Test if Media Access Control address is valid for the device.
+ *      If addr is NULL the Media Access Control address of the device
+ *      get validated, otherwise the MAC of the net_device.
  *
  * int (*ndo_do_ioctl)(struct net_device *dev, struct ifreq *ifr, int cmd);
  *	Called when a user request an ioctl which can't be handled by
@@ -919,7 +921,8 @@ struct net_device_ops {
 	void			(*ndo_set_rx_mode)(struct net_device *dev);
 	int			(*ndo_set_mac_address)(struct net_device *dev,
 						       void *addr);
-	int			(*ndo_validate_addr)(struct net_device *dev);
+	int			(*ndo_validate_addr)(struct net_device *dev,
+						     void *addr);
 	int			(*ndo_do_ioctl)(struct net_device *dev,
 					        struct ifreq *ifr, int cmd);
 	int			(*ndo_set_config)(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 763a0ed..27a5a66 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1162,7 +1162,7 @@ static int __dev_open(struct net_device *dev)
 	set_bit(__LINK_STATE_START, &dev->state);
 
 	if (ops->ndo_validate_addr)
-		ret = ops->ndo_validate_addr(dev);
+		ret = ops->ndo_validate_addr(dev, NULL);
 
 	if (!ret && ops->ndo_open)
 		ret = ops->ndo_open(dev);
@@ -4820,6 +4820,11 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 		return -EINVAL;
 	if (!netif_device_present(dev))
 		return -ENODEV;
+	if (ops->ndo_validate_addr) {
+		err = ops->ndo_validate_addr(dev, sa);
+		if (err)
+			return err;
+	}
 	err = ops->ndo_set_mac_address(dev, sa);
 	if (!err)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index a93af86..86e939b 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -285,8 +285,6 @@ int eth_mac_addr(struct net_device *dev, void *p)
 
 	if (netif_running(dev))
 		return -EBUSY;
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 	/* if device marked as NET_ADDR_RANDOM, reset it */
 	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
@@ -311,9 +309,16 @@ int eth_change_mtu(struct net_device *dev, int new_mtu)
 }
 EXPORT_SYMBOL(eth_change_mtu);
 
-int eth_validate_addr(struct net_device *dev)
+int eth_validate_addr(struct net_device *dev, void *addr)
 {
-	if (!is_valid_ether_addr(dev->dev_addr))
+	u8 *vaddr;
+
+	if (addr)
+		vaddr = ((struct sockaddr *) addr)->sa_data;
+	else
+		vaddr = dev->dev_addr;
+
+	if (!is_valid_ether_addr(vaddr))
 		return -EADDRNOTAVAIL;
 
 	return 0;
-- 
1.7.8.3

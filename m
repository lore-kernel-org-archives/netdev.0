From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH] net: Add DEVTYPE support for Ethernet based devices
Date: Tue,  1 Sep 2009 00:08:19 -0700
Message-ID: <1251788899-30156-1-git-send-email-marcel@holtmann.org>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	johannes@sipsolutions.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:40854 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbZIAHJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 03:09:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Ethernet framing is used for a lot of devices these days. Most
prominent are WiFi and WiMAX based devices. However for userspace
application it is important to classify these devices correctly and
not only see them as Ethernet devices. The daemons like HAL, DeviceKit
or even NetworkManager with udev support tries to do the classification
in userspace with a lot trickery and extra system calls. This is not
good and actually reaches its limitations. Especially since the kernel
does know the type of the Ethernet device it is pretty stupid.

To solve this problem the underlying device type needs to be set and
then the value will be exported as DEVTYPE via uevents and available
within udev.

  # cat /sys/class/net/wlan0/uevent
  DEVTYPE=wlan
  INTERFACE=wlan0
  IFINDEX=5

This is similar to subsystems like USB and SCSI that distinguish
between hosts, devices, disks, partitions etc.

The new SET_NETDEV_DEVTYPE() is a convenience helper to set the actual
device type. All device types are free form, but for convenience the
same strings as used with RFKILL are choosen.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/net/usb/hso.c           |    5 +++++
 drivers/net/wimax/i2400m/sdio.c |    5 +++++
 drivers/net/wimax/i2400m/usb.c  |    5 +++++
 include/linux/netdevice.h       |    6 ++++++
 net/bluetooth/bnep/core.c       |    5 +++++
 net/bridge/br_if.c              |    6 ++++++
 net/mac80211/iface.c            |    5 +++++
 7 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index ffe4106..5d47a73 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2534,6 +2534,10 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
 	}
 }
 
+static struct device_type hso_type = {
+	.name	= "wwan",
+};
+
 /* Creates our network device */
 static struct hso_device *hso_create_net_device(struct usb_interface *interface,
 						int port_spec)
@@ -2574,6 +2578,7 @@ static struct hso_device *hso_create_net_device(struct usb_interface *interface,
 		goto exit;
 	}
 	SET_NETDEV_DEV(net, &interface->dev);
+	SET_NETDEV_DEVTYPE(net, &hso_type);
 
 	/* registering our net device */
 	result = register_netdev(net);
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index ea7b290..2981e21 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -371,6 +371,10 @@ error:
 }
 
 
+static struct device_type i2400ms_type = {
+	.name	= "wimax",
+};
+
 /*
  * Probe a i2400m interface and register it
  *
@@ -412,6 +416,7 @@ int i2400ms_probe(struct sdio_func *func,
 		goto error_alloc_netdev;
 	}
 	SET_NETDEV_DEV(net_dev, dev);
+	SET_NETDEV_DEVTYPE(net_dev, &i2400ms_type);
 	i2400m = net_dev_to_i2400m(net_dev);
 	i2400ms = container_of(i2400m, struct i2400ms, i2400m);
 	i2400m->wimax_dev.net_dev = net_dev;
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index cfdaf69..7eadd11 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -351,6 +351,10 @@ error:
 }
 
 
+static struct device_type i2400mu_type = {
+	.name	= "wimax",
+};
+
 /*
  * Probe a i2400m interface and register it
  *
@@ -388,6 +392,7 @@ int i2400mu_probe(struct usb_interface *iface,
 		goto error_alloc_netdev;
 	}
 	SET_NETDEV_DEV(net_dev, dev);
+	SET_NETDEV_DEVTYPE(net_dev, &i2400mu_type);
 	i2400m = net_dev_to_i2400m(net_dev);
 	i2400mu = container_of(i2400m, struct i2400mu, i2400m);
 	i2400m->wimax_dev.net_dev = net_dev;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 60d3aac..8e00e03 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -989,6 +989,12 @@ static inline void *netdev_priv(const struct net_device *dev)
  */
 #define SET_NETDEV_DEV(net, pdev)	((net)->dev.parent = (pdev))
 
+/* Set the sysfs device type for the network logical device to allow
+ * fin grained indentification of different network device types. For
+ * example Ethernet, Wirelss LAN, Bluetooth, WiMAX etc.
+ */
+#define SET_NETDEV_DEVTYPE(net, devtype)	((net)->dev.type = (devtype))
+
 /**
  *	netif_napi_add - initialize a napi context
  *	@dev:  network device
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index 52a6ce0..cafe9f5 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -533,6 +533,10 @@ static struct device *bnep_get_device(struct bnep_session *session)
 	return conn ? &conn->dev : NULL;
 }
 
+static struct device_type bnep_type = {
+	.name	= "bluetooth",
+};
+
 int bnep_add_connection(struct bnep_connadd_req *req, struct socket *sock)
 {
 	struct net_device *dev;
@@ -586,6 +590,7 @@ int bnep_add_connection(struct bnep_connadd_req *req, struct socket *sock)
 #endif
 
 	SET_NETDEV_DEV(dev, bnep_get_device(s));
+	SET_NETDEV_DEVTYPE(dev, &bnep_type);
 
 	err = register_netdev(dev);
 	if (err) {
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index e486f1f..142ebac 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -264,6 +264,10 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	return p;
 }
 
+static struct device_type br_type = {
+	.name	= "bridge",
+};
+
 int br_add_bridge(struct net *net, const char *name)
 {
 	struct net_device *dev;
@@ -280,6 +284,8 @@ int br_add_bridge(struct net *net, const char *name)
 			goto out_free;
 	}
 
+	SET_NETDEV_DEVTYPE(dev, &br_type);
+
 	ret = register_netdevice(dev);
 	if (ret)
 		goto out_free;
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index f6005ad..b8295cb 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -754,6 +754,10 @@ int ieee80211_if_change_type(struct ieee80211_sub_if_data *sdata,
 	return 0;
 }
 
+static struct device_type wiphy_type = {
+	.name	= "wlan",
+};
+
 int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 		     struct net_device **new_dev, enum nl80211_iftype type,
 		     struct vif_params *params)
@@ -785,6 +789,7 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 
 	memcpy(ndev->dev_addr, local->hw.wiphy->perm_addr, ETH_ALEN);
 	SET_NETDEV_DEV(ndev, wiphy_dev(local->hw.wiphy));
+	SET_NETDEV_DEVTYPE(ndev, &wiphy_type);
 
 	/* don't use IEEE80211_DEV_TO_SUB_IF because it checks too much */
 	sdata = netdev_priv(ndev);
-- 
1.6.2.5


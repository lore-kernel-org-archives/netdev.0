From: Greg Kroah-Hartman <gregkh@suse.de>
Subject: [PATCH] net: remove driver_data direct access of struct device
	from more drivers
Date: Mon, 4 May 2009 13:01:45 -0700
Message-ID: <20090504200145.GA22855@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@redhat.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, Greg KH <greg@kroah.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:56026 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754625AbZEDUFI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2009 16:05:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Kroah-Hartman <gregkh@suse.de>

In the near future, the driver core is going to not allow direct access
to the driver_data pointer in struct device.  Instead, the functions
dev_get_drvdata() and dev_set_drvdata() should be used.  These functions
have been around since the beginning, so are backwards compatible with
all older kernel versions.

Cc: netdev@vger.kernel.org
Cc: David S. Miller <davem@davemloft.net>
Cc: Jeff Garzik <jgarzik@redhat.com>
Cc: Jan-Bernd Themann <themann@de.ibm.com>
Cc: Thomas Klein <tklein@de.ibm.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/ehea/ehea_main.c |    8 ++++----
 drivers/net/ibmveth.c        |    8 ++++----
 drivers/net/sb1250-mac.c     |    6 +++---
 3 files changed, 11 insertions(+), 11 deletions(-)

--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3256,7 +3256,7 @@ static ssize_t ehea_probe_port(struct de
 			       struct device_attribute *attr,
 			       const char *buf, size_t count)
 {
-	struct ehea_adapter *adapter = dev->driver_data;
+	struct ehea_adapter *adapter = dev_get_drvdata(dev);
 	struct ehea_port *port;
 	struct device_node *eth_dn = NULL;
 	int i;
@@ -3311,7 +3311,7 @@ static ssize_t ehea_remove_port(struct d
 				struct device_attribute *attr,
 				const char *buf, size_t count)
 {
-	struct ehea_adapter *adapter = dev->driver_data;
+	struct ehea_adapter *adapter = dev_get_drvdata(dev);
 	struct ehea_port *port;
 	int i;
 	u32 logical_port_id;
@@ -3399,7 +3399,7 @@ static int __devinit ehea_probe_adapter(
 
 	adapter->pd = EHEA_PD_ID;
 
-	dev->dev.driver_data = adapter;
+	dev_set_drvdata(&dev->dev, adapter);
 
 
 	/* initialize adapter and ports */
@@ -3463,7 +3463,7 @@ out:
 
 static int __devexit ehea_remove(struct of_device *dev)
 {
-	struct ehea_adapter *adapter = dev->dev.driver_data;
+	struct ehea_adapter *adapter = dev_get_drvdata(&dev->dev);
 	int i;
 
 	for (i = 0; i < EHEA_MAX_PORTS; i++)
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1241,7 +1241,7 @@ static int __devinit ibmveth_probe(struc
 		return -ENOMEM;
 
 	adapter = netdev_priv(netdev);
-	dev->dev.driver_data = netdev;
+	dev_set_drvdata(&dev->dev, netdev);
 
 	adapter->vdev = dev;
 	adapter->netdev = netdev;
@@ -1335,7 +1335,7 @@ static int __devinit ibmveth_probe(struc
 
 static int __devexit ibmveth_remove(struct vio_dev *dev)
 {
-	struct net_device *netdev = dev->dev.driver_data;
+	struct net_device *netdev = dev_get_drvdata(&dev->dev);
 	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	int i;
 
@@ -1468,8 +1468,8 @@ const char * buf, size_t count)
 	struct ibmveth_buff_pool *pool = container_of(kobj,
 						      struct ibmveth_buff_pool,
 						      kobj);
-	struct net_device *netdev =
-	    container_of(kobj->parent, struct device, kobj)->driver_data;
+	struct net_device *netdev = dev_get_drvdata(
+	    container_of(kobj->parent, struct device, kobj));
 	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	long value = simple_strtol(buf, NULL, 10);
 	long rc;
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2285,7 +2285,7 @@ static int sb1250_change_mtu(struct net_
 
 static int sbmac_init(struct platform_device *pldev, long long base)
 {
-	struct net_device *dev = pldev->dev.driver_data;
+	struct net_device *dev = dev_get_drvdata(&pldev->dev);
 	int idx = pldev->id;
 	struct sbmac_softc *sc = netdev_priv(dev);
 	unsigned char *eaddr;
@@ -2726,7 +2726,7 @@ static int __init sbmac_probe(struct pla
 		goto out_unmap;
 	}
 
-	pldev->dev.driver_data = dev;
+	dev_set_drvdata(&pldev->dev, dev);
 	SET_NETDEV_DEV(dev, &pldev->dev);
 
 	sc = netdev_priv(dev);
@@ -2751,7 +2751,7 @@ out_out:
 
 static int __exit sbmac_remove(struct platform_device *pldev)
 {
-	struct net_device *dev = pldev->dev.driver_data;
+	struct net_device *dev = dev_get_drvdata(&pldev->dev);
 	struct sbmac_softc *sc = netdev_priv(dev);
 
 	unregister_netdev(dev);

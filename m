From: Takashi Iwai <tiwai@suse.de>
Subject: [PATCH] xen-netfront: Use static attribute groups for sysfs entries
Date: Wed,  4 Feb 2015 14:38:55 +0100
Message-ID: <1423057135-6939-1-git-send-email-tiwai@suse.de>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43892 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965000AbbBDNi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 08:38:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of manual calls of device_create_file() and
device_remove_files(), assign the static attribute groups to netdev
groups array.  This simplifies the code and avoids the possible
races.

Signed-off-by: Takashi Iwai <tiwai@suse.de>
---
 drivers/net/xen-netfront.c | 62 ++++++++++++----------------------------------
 1 file changed, 16 insertions(+), 46 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d8c10764f130..1524d2ee1c21 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -223,11 +223,7 @@ static grant_ref_t xennet_get_rx_ref(struct netfront_queue *queue,
 }
 
 #ifdef CONFIG_SYSFS
-static int xennet_sysfs_addif(struct net_device *netdev);
-static void xennet_sysfs_delif(struct net_device *netdev);
-#else /* !CONFIG_SYSFS */
-#define xennet_sysfs_addif(dev) (0)
-#define xennet_sysfs_delif(dev) do { } while (0)
+static const struct attribute_group xennet_dev_group;
 #endif
 
 static bool xennet_can_sg(struct net_device *dev)
@@ -1367,20 +1363,15 @@ static int netfront_probe(struct xenbus_device *dev,
 
 	info = netdev_priv(netdev);
 	dev_set_drvdata(&dev->dev, info);
-
+#ifdef CONFIG_SYSFS
+	info->netdev->sysfs_groups[0] = &xennet_dev_group;
+#endif
 	err = register_netdev(info->netdev);
 	if (err) {
 		pr_warn("%s: register_netdev err=%d\n", __func__, err);
 		goto fail;
 	}
 
-	err = xennet_sysfs_addif(info->netdev);
-	if (err) {
-		unregister_netdev(info->netdev);
-		pr_warn("%s: add sysfs failed err=%d\n", __func__, err);
-		goto fail;
-	}
-
 	return 0;
 
  fail:
@@ -2144,39 +2135,20 @@ static ssize_t store_rxbuf(struct device *dev,
 	return len;
 }
 
-static struct device_attribute xennet_attrs[] = {
-	__ATTR(rxbuf_min, S_IRUGO|S_IWUSR, show_rxbuf, store_rxbuf),
-	__ATTR(rxbuf_max, S_IRUGO|S_IWUSR, show_rxbuf, store_rxbuf),
-	__ATTR(rxbuf_cur, S_IRUGO, show_rxbuf, NULL),
-};
+static DEVICE_ATTR(rxbuf_min, S_IRUGO|S_IWUSR, show_rxbuf, store_rxbuf);
+static DEVICE_ATTR(rxbuf_max, S_IRUGO|S_IWUSR, show_rxbuf, store_rxbuf);
+static DEVICE_ATTR(rxbuf_cur, S_IRUGO, show_rxbuf, NULL);
 
-static int xennet_sysfs_addif(struct net_device *netdev)
-{
-	int i;
-	int err;
-
-	for (i = 0; i < ARRAY_SIZE(xennet_attrs); i++) {
-		err = device_create_file(&netdev->dev,
-					   &xennet_attrs[i]);
-		if (err)
-			goto fail;
-	}
-	return 0;
-
- fail:
-	while (--i >= 0)
-		device_remove_file(&netdev->dev, &xennet_attrs[i]);
-	return err;
-}
-
-static void xennet_sysfs_delif(struct net_device *netdev)
-{
-	int i;
-
-	for (i = 0; i < ARRAY_SIZE(xennet_attrs); i++)
-		device_remove_file(&netdev->dev, &xennet_attrs[i]);
-}
+static struct attribute *xennet_dev_attrs[] = {
+	&dev_attr_rxbuf_min.attr,
+	&dev_attr_rxbuf_max.attr,
+	&dev_attr_rxbuf_cur.attr,
+	NULL
+};
 
+static const struct attribute_group xennet_dev_group = {
+	.attrs = xennet_dev_attrs
+};
 #endif /* CONFIG_SYSFS */
 
 static int xennet_remove(struct xenbus_device *dev)
@@ -2190,8 +2162,6 @@ static int xennet_remove(struct xenbus_device *dev)
 
 	xennet_disconnect_backend(info);
 
-	xennet_sysfs_delif(info->netdev);
-
 	unregister_netdev(info->netdev);
 
 	for (i = 0; i < num_queues; ++i) {
-- 
2.2.2

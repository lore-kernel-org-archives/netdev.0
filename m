From: Alexander Aring <aar@pengutronix.de>
Subject: [PATCHv4 net-next 11/12] 6lowpan: add support for getting short address
Date: Wed, 15 Jun 2016 21:20:26 +0200
Message-ID: <20160615192027.4064-12-aar@pengutronix.de>
References: <20160615192027.4064-1-aar@pengutronix.de>
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	stefan@osg.samsung.com, mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Aring <aar@pengutronix.de>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:54314 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933085AbcFOTVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 15:21:21 -0400
In-Reply-To: <20160615192027.4064-1-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of sending RA messages we need some way to get the short address
from an 802.15.4 6LoWPAN interface. This patch will add a temporary
debugfs entry for experimental userspace api.

Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
Signed-off-by: Alexander Aring <aar@pengutronix.de>
---
 net/6lowpan/debugfs.c | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/net/6lowpan/debugfs.c b/net/6lowpan/debugfs.c
index acbaa3d..24915e0 100644
--- a/net/6lowpan/debugfs.c
+++ b/net/6lowpan/debugfs.c
@@ -245,6 +245,41 @@ static const struct file_operations lowpan_context_fops = {
 	.release	= single_release,
 };
 
+static int lowpan_short_addr_get(void *data, u64 *val)
+{
+	struct wpan_dev *wdev = data;
+
+	rtnl_lock();
+	*val = le16_to_cpu(wdev->short_addr);
+	rtnl_unlock();
+
+	return 0;
+}
+
+DEFINE_SIMPLE_ATTRIBUTE(lowpan_short_addr_fops, lowpan_short_addr_get,
+			NULL, "0x%04llx\n");
+
+static int lowpan_dev_debugfs_802154_init(const struct net_device *dev,
+					  struct lowpan_dev *ldev)
+{
+	struct dentry *dentry, *root;
+
+	if (!lowpan_is_ll(dev, LOWPAN_LLTYPE_IEEE802154))
+		return 0;
+
+	root = debugfs_create_dir("ieee802154", ldev->iface_debugfs);
+	if (!root)
+		return -EINVAL;
+
+	dentry = debugfs_create_file("short_addr", 0444, root,
+				     lowpan_802154_dev(dev)->wdev->ieee802154_ptr,
+				     &lowpan_short_addr_fops);
+	if (!dentry)
+		return -EINVAL;
+
+	return 0;
+}
+
 int lowpan_dev_debugfs_init(struct net_device *dev)
 {
 	struct lowpan_dev *ldev = lowpan_dev(dev);
@@ -272,6 +307,10 @@ int lowpan_dev_debugfs_init(struct net_device *dev)
 			goto remove_root;
 	}
 
+	ret = lowpan_dev_debugfs_802154_init(dev, ldev);
+	if (ret < 0)
+		goto remove_root;
+
 	return 0;
 
 remove_root:
-- 
2.8.3

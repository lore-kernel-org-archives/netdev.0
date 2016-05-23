From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [RFC 11/12] 6lowpan: add support for getting short address
Date: Mon, 23 May 2016 21:22:07 +0200
Message-ID: <1464031328-17524-12-git-send-email-aar@pengutronix.de>
References: <1464031328-17524-1-git-send-email-aar@pengutronix.de>
Cc: kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464031328-17524-1-git-send-email-aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In case of sending RA messages we need some way to get the short address
from an 802.15.4 6LoWPAN interface. This patch will add a temporary
debugfs entry for experimental userspace api.

Signed-off-by: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 net/6lowpan/debugfs.c | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/net/6lowpan/debugfs.c b/net/6lowpan/debugfs.c
index acbaa3d..638ae59 100644
--- a/net/6lowpan/debugfs.c
+++ b/net/6lowpan/debugfs.c
@@ -245,6 +245,37 @@ static const struct file_operations lowpan_context_fops = {
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
+	struct dentry *dentry;
+
+	if (!lowpan_is_ll(dev, LOWPAN_LLTYPE_IEEE802154))
+		return 0;
+
+	dentry = debugfs_create_file("short_addr", 0444, ldev->iface_debugfs,
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
@@ -272,6 +303,10 @@ int lowpan_dev_debugfs_init(struct net_device *dev)
 			goto remove_root;
 	}
 
+	ret = lowpan_dev_debugfs_802154_init(dev, ldev);
+	if (ret < 0)
+		goto remove_root;
+
 	return 0;
 
 remove_root:
-- 
2.8.2

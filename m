From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 6/6] C/R: Add checkpoint support to macvlan driver
Date: Thu, 25 Feb 2010 12:43:15 -0800
Message-ID: <1267130595-23637-7-git-send-email-danms@us.ibm.com>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
Cc: benjamin.thery@bull.net, den@openvz.org, ebiederm@xmission.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stein.danplanet.com ([71.245.107.83]:38793 "EHLO
	stein.danplanet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933713Ab0BYUpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 15:45:32 -0500
In-Reply-To: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This has an small hidden gotcha.  Since the macvlan device is moved
completely into a container's network namespace, the init netns cannot
freeze traffic to and from it in order to migrate live network connections
by simply utilizing its netfilter tables.  A helper process in the container
or something like what was recently discussed on the containers list[1]
would provide a way to do this.

[1]: https://lists.linux-foundation.org/pipermail/containers/2010-February/023001.html

Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 drivers/net/macvlan.c |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 21a9c9a..07d006a 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -28,6 +28,8 @@
 #include <linux/if_arp.h>
 #include <linux/if_link.h>
 #include <linux/if_macvlan.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
 #include <net/rtnetlink.h>
 #include <net/xfrm.h>
 
@@ -493,6 +495,49 @@ static struct net_device_stats *macvlan_dev_get_stats(struct net_device *dev)
 	return stats;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int macvlan_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct ckpt_hdr_netdev *h;
+	struct ckpt_netdev_addr *addrs;
+	int ret;
+
+	ckpt_debug("Checkpointing macvlan %s:%s\n",
+		   dev->name, vlan->lowerdev->name);
+
+	h = ckpt_netdev_base(ctx, dev, &addrs);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	h->type = CKPT_NETDEV_MACVLAN;
+
+	h->macvlan.mode = vlan->mode;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *)h);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_buffer(ctx, dev->name, IFNAMSIZ);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_buffer(ctx, vlan->lowerdev->name, IFNAMSIZ);
+	if (ret < 0)
+		goto out;
+
+	if (h->inet_addrs > 0) {
+		int len = (sizeof(struct ckpt_netdev_addr) * h->inet_addrs);
+		ret = ckpt_write_buffer(ctx, addrs, len);
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+	kfree(addrs);
+
+	return ret;
+}
+#endif
+
 static void macvlan_ethtool_get_drvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *drvinfo)
 {
@@ -539,6 +584,9 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_set_multicast_list	= macvlan_set_multicast_list,
 	.ndo_get_stats		= macvlan_dev_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_CHECKPOINT
+	.ndo_checkpoint		= macvlan_checkpoint,
+#endif
 };
 
 static void macvlan_setup(struct net_device *dev)
-- 
1.6.2.5


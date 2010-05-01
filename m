From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [PATCH v21 099/100] c/r: Add checkpoint support to macvlan driver
Date: Sat,  1 May 2010 10:16:21 -0400
Message-ID: <1272723382-19470-100-git-send-email-orenl@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Dan Smith <danms@us.ibm.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Smith <danms@us.ibm.com>

Changelog[v21]:
  - Do not include checkpoint_hdr.h explicitly
  - Unbreak compiling with CONFIG_CHECKPOINT=n or CONFIG_NET_NS=n

Cc: netdev@vger.kernel.org
Signed-off-by: Dan Smith <danms@us.ibm.com>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Acked-by: Oren Laadan <oreln@cs.columbia.edu>
---
 drivers/net/macvlan.c |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 40faa36..360828e 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -455,6 +455,51 @@ static struct net_device_stats *macvlan_dev_get_stats(struct net_device *dev)
 	return stats;
 }
 
+#include <linux/checkpoint.h>
+
+#ifdef CONFIG_NETNS_CHECKPOINT
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
@@ -501,6 +546,9 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_set_multicast_list	= macvlan_set_multicast_list,
 	.ndo_get_stats		= macvlan_dev_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NETNS_CHECKPOINT
+	.ndo_checkpoint		= macvlan_checkpoint,
+#endif
 };
 
 static void macvlan_setup(struct net_device *dev)
-- 
1.6.3.3

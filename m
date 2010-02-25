From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 3/6] C/R: Add checkpoint support for veth devices (v2)
Date: Thu, 25 Feb 2010 12:43:12 -0800
Message-ID: <1267130595-23637-4-git-send-email-danms@us.ibm.com>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
Cc: benjamin.thery@bull.net, den@openvz.org, ebiederm@xmission.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stein.danplanet.com ([71.245.107.83]:38780 "EHLO
	stein.danplanet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933710Ab0BYUpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 15:45:32 -0500
In-Reply-To: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds an ndo_checkpoint() handler for veth devices to checkpoint themselves.
Writes out the pairing information, addresses, and initiates a checkpoint
on the peer if the peer won't be reached from another netns.  Throws an
error of our peer's netns isn't already in the hash (i.e., a tree leak).

Changes in v2:
 - Fix check detecting if peer is in the init netns

Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 drivers/net/veth.c |   76 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 76 insertions(+), 0 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 3a15de5..db92de8 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -16,6 +16,9 @@
 #include <net/xfrm.h>
 #include <linux/veth.h>
 
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
 #define DRV_NAME	"veth"
 #define DRV_VERSION	"1.0"
 
@@ -284,6 +287,76 @@ static void veth_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int veth_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev)
+{
+	struct ckpt_hdr_netdev *h;
+	struct veth_priv *priv = netdev_priv(dev);
+	struct net_device *peer = priv->peer;
+	struct ckpt_netdev_addr *addrs;
+	int ret;
+	int n;
+
+	if (!peer) {
+		ckpt_err(ctx, -EINVAL, "veth device has no peer!\n");
+		return -EINVAL;
+	}
+
+	h = ckpt_netdev_base(ctx, dev, &addrs);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	h->type = CKPT_NETDEV_VETH;
+
+	ret = h->veth.this_ref = ckpt_obj_lookup_add(ctx, dev,
+						     CKPT_OBJ_NETDEV, &n);
+	if (ret < 0)
+		goto out;
+
+	ret = h->veth.peer_ref = ckpt_obj_lookup_add(ctx, peer,
+						     CKPT_OBJ_NETDEV, &n);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *)h);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_buffer(ctx, dev->name, IFNAMSIZ);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_buffer(ctx, peer->name, IFNAMSIZ);
+	if (ret < 0)
+		goto out;
+
+	if (h->inet_addrs > 0) {
+		int len = (sizeof(struct ckpt_netdev_addr) * h->inet_addrs);
+		ret = ckpt_write_buffer(ctx, addrs, len);
+		if (ret)
+			goto out;
+	}
+
+	/* Only checkpoint peer if we're not going to arrive at it
+	 * via another task's netns.  Fail if the pipe exits
+	 * our container to a netns not already in the hash
+	 */
+	if (ckpt_netdev_in_init_netns(ctx, peer))
+		ret = checkpoint_obj(ctx, peer, CKPT_OBJ_NETDEV);
+	else if (!ckpt_obj_lookup(ctx, peer->nd_net, CKPT_OBJ_NET_NS)) {
+		ret = -EINVAL;
+		ckpt_err(ctx, ret,
+			 "Peer %s of %s not in checkpointed namespaces\n",
+			 peer->name, dev->name);
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+	kfree(addrs);
+
+	return ret;
+}
+#endif
+
 static const struct net_device_ops veth_netdev_ops = {
 	.ndo_init            = veth_dev_init,
 	.ndo_open            = veth_open,
@@ -292,6 +365,9 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_change_mtu      = veth_change_mtu,
 	.ndo_get_stats       = veth_get_stats,
 	.ndo_set_mac_address = eth_mac_addr,
+#ifdef CONFIG_CHECKPOINT
+	.ndo_checkpoint      = veth_checkpoint,
+#endif
 };
 
 static void veth_setup(struct net_device *dev)
-- 
1.6.2.5


From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [PATCH v21 096/100] c/r: Add checkpoint support for veth devices (v2)
Date: Sat,  1 May 2010 10:16:18 -0400
Message-ID: <1272723382-19470-97-git-send-email-orenl@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Dan Smith <danms@us.ibm.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tarap.cc.columbia.edu ([128.59.29.7]:64441 "EHLO
	tarap.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933042Ab0EAOiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 10:38:55 -0400
In-Reply-To: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>

Adds an ndo_checkpoint() handler for veth devices to checkpoint themselves.
Writes out the pairing information, addresses, and initiates a checkpoint
on the peer if the peer won't be reached from another netns.  Throws an
error of our peer's netns isn't already in the hash (i.e., a tree leak).

Changelog[v21]
 - Unbreak compiling with CONFIG_CHECKPOINT=n or CONFIG_NET_NS=n
 - Clean up the error path in restore_veth()

Changes in v2:
 - Fix check detecting if peer is in the init netns

Cc: netdev@vger.kernel.org
Signed-off-by: Dan Smith <danms@us.ibm.com>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
---
 drivers/net/veth.c   |   76 +++++++++++++++++++++++++++++++++++++++++++
 net/checkpoint_dev.c |   87 +++++++++++++++++--------------------------------
 2 files changed, 106 insertions(+), 57 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f9f0730..d76b5e0 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -285,6 +285,79 @@ static void veth_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
 
+#ifdef CONFIG_NETNS_CHECKPOINT
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
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
@@ -293,6 +366,9 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_change_mtu      = veth_change_mtu,
 	.ndo_get_stats       = veth_get_stats,
 	.ndo_set_mac_address = eth_mac_addr,
+#ifdef CONFIG_NETNS_CHECKPOINT
+	.ndo_checkpoint      = veth_checkpoint,
+#endif
 };
 
 static void veth_setup(struct net_device *dev)
diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
index 5097011..a8e3341 100644
--- a/net/checkpoint_dev.c
+++ b/net/checkpoint_dev.c
@@ -20,11 +20,6 @@
 #include <net/net_namespace.h>
 #include <net/sch_generic.h>
 
-struct dq_netdev {
-	struct net_device *dev;
-	struct ckpt_ctx *ctx;
-};
-
 struct veth_newlink {
 	char *peer;
 };
@@ -587,25 +582,6 @@ static int rtnl_dellink(char *name)
 	return ret;
 }
 
-static int netdev_noop(void *data)
-{
-	return 0;
-}
-
-static int netdev_cleanup(void *data)
-{
-	struct dq_netdev *dq = data;
-
-	dev_put(dq->dev);
-
-	if (dq->ctx->errno) {
-		ckpt_debug("Unregistering netdev %s\n", dq->dev->name);
-		unregister_netdev(dq->dev);
-	}
-
-	return 0;
-}
-
 static struct net_device *restore_veth(struct ckpt_ctx *ctx,
 				       struct ckpt_hdr_netdev *h,
 				       struct net *net)
@@ -616,9 +592,6 @@ static struct net_device *restore_veth(struct ckpt_ctx *ctx,
 	struct net_device *dev;
 	struct net_device *peer;
 	struct ifreq req;
-	struct dq_netdev dq;
-
-	dq.ctx = ctx;
 
 	ret = _ckpt_read_buffer(ctx, this_name, IFNAMSIZ);
 	if (ret < 0)
@@ -640,37 +613,31 @@ static struct net_device *restore_veth(struct ckpt_ctx *ctx,
 		if (IS_ERR(dev))
 			return dev;
 
+		ret = ckpt_obj_insert(ctx, dev, h->veth.this_ref,
+				      CKPT_OBJ_NETDEV);
+		dev_put(dev);
+		if (ret < 0)
+			goto err;
+
 		peer = dev_get_by_name(current->nsproxy->net_ns, peer_name);
 		if (!peer) {
 			ret = -EINVAL;
-			goto err_dev;
+			goto err;
 		}
 
-		dq.dev = peer;
-		ret = deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
-				     netdev_noop, netdev_cleanup);
-		if (ret)
-			goto err_peer;
-
 		ret = ckpt_obj_insert(ctx, peer, h->veth.peer_ref,
 				      CKPT_OBJ_NETDEV);
-		if (ret < 0)
-			/* Can't recall peer dq, so let it cleanup peer */
-			goto err_dev;
 		dev_put(peer);
-
-		dq.dev = dev;
-		ret = deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
-				     netdev_noop, netdev_cleanup);
-		if (ret)
-			/* Can't recall peer dq, so let it cleanup peer */
-			goto err_dev;
+		if (ret < 0)
+			goto err;
 
 	} else {
 		/* We're second: get our dev from the hash */
 		dev = ckpt_obj_fetch(ctx, h->veth.this_ref, CKPT_OBJ_NETDEV);
-		if (IS_ERR(dev))
-			return dev;
+		if (IS_ERR(dev)) {
+			ret = PTR_ERR(dev);
+			goto err;
+		}
 	}
 
 	/* Move to our new netns */
@@ -678,25 +645,31 @@ static struct net_device *restore_veth(struct ckpt_ctx *ctx,
 	ret = dev_change_net_namespace(dev, net, dev->name);
 	rtnl_unlock();
 	if (ret < 0)
-		goto out;
+		goto err;
 
 	/* Restore MAC address */
 	memcpy(req.ifr_name, dev->name, IFNAMSIZ);
 	memcpy(req.ifr_hwaddr.sa_data, h->hwaddr, sizeof(h->hwaddr));
 	req.ifr_hwaddr.sa_family = ARPHRD_ETHER;
 	ret = __kern_dev_ioctl(net, SIOCSIFHWADDR, &req);
- out:
-	if (ret)
-		dev = ERR_PTR(ret);
+	if (ret < 0)
+		goto err;
 
 	return dev;
-
- err_peer:
-	dev_put(peer);
-	unregister_netdev(peer);
- err_dev:
-	dev_put(dev);
-	unregister_netdev(dev);
+ err:
+	/* Delete from hash to drop reference */
+	ckpt_obj_delete(ctx, h->veth.this_ref, CKPT_OBJ_NETDEV);
+	ckpt_obj_delete(ctx, h->veth.peer_ref, CKPT_OBJ_NETDEV);
+
+	/* This will fail to delete the interface if we get here
+	 * because of a failed attempt at setting the hardware
+	 * address, since the device has been moved to another netns.
+	 * This is not a problem, however, because the death of that
+	 * netns will take the device (and its peer) down with it
+	 * cleanly.
+	 */
+	if (rtnl_dellink(this_name) < 0)
+		ckpt_debug("failed to delete interfaces on error\n");
 
 	return ERR_PTR(ret);
 }
-- 
1.6.3.3


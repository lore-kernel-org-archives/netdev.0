From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 4/5] Add loopback checkpoint support
Date: Tue, 16 Feb 2010 08:03:06 -0800
Message-ID: <1266336187-19105-5-git-send-email-danms@us.ibm.com>
References: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
To: containers@lists.osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stein.danplanet.com ([71.245.107.83]:60639 "EHLO
	stein.danplanet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932756Ab0BPQFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 11:05:07 -0500
In-Reply-To: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds a small ndo_checkpoint() handler for loopback devices to write the
name and addresses like other interfaces.

Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 drivers/net/loopback.c |   41 ++++++++++++++++++++++++++++++++++++++---
 1 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index b9fcc98..816a527 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -57,6 +57,8 @@
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/percpu.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
 #include <net/net_namespace.h>
 
 struct pcpu_lstats {
@@ -153,10 +155,43 @@ static void loopback_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
 
+static int loopback_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev)
+{
+	struct ckpt_hdr_netdev *h;
+	struct ckpt_netdev_addr *addrs;
+	int ret;
+
+	h = ckpt_netdev_base(ctx, dev, &addrs);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	h->type = CKPT_NETDEV_LO;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *)h);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_buffer(ctx, dev->name, IFNAMSIZ);
+	if (ret < 0)
+		goto out;
+
+	if (h->inet_addrs > 0) {
+		int len = (sizeof(struct ckpt_netdev_addr) * h->inet_addrs);
+		ret = ckpt_write_buffer(ctx, addrs, len);
+	}
+
+ out:
+	ckpt_hdr_put(ctx, h);
+	kfree(addrs);
+
+	return ret;
+}
+
 static const struct net_device_ops loopback_ops = {
-	.ndo_init      = loopback_dev_init,
-	.ndo_start_xmit= loopback_xmit,
-	.ndo_get_stats = loopback_get_stats,
+	.ndo_init       = loopback_dev_init,
+	.ndo_start_xmit = loopback_xmit,
+	.ndo_get_stats  = loopback_get_stats,
+	.ndo_checkpoint = loopback_checkpoint,
 };
 
 /*
-- 
1.6.2.5


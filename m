From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 4/6] C/R: Add loopback checkpoint support (v2)
Date: Thu, 25 Feb 2010 12:43:13 -0800
Message-ID: <1267130595-23637-5-git-send-email-danms@us.ibm.com>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
Cc: benjamin.thery@bull.net, den@openvz.org, ebiederm@xmission.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stein.danplanet.com ([71.245.107.83]:38780 "EHLO
	stein.danplanet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933660Ab0BYUpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 15:45:31 -0500
In-Reply-To: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds a small ndo_checkpoint() handler for loopback devices to write the
name and addresses like other interfaces.

Changes in v2:
 - Add CONFIG_CHECKPOINT around the handler

Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 drivers/net/loopback.c |   44 +++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index b9fcc98..77023a7 100644
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
@@ -153,10 +155,46 @@ static void loopback_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
 
+#ifdef CONFIG_CHECKPOINT
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
+#endif
 static const struct net_device_ops loopback_ops = {
-	.ndo_init      = loopback_dev_init,
-	.ndo_start_xmit= loopback_xmit,
-	.ndo_get_stats = loopback_get_stats,
+	.ndo_init       = loopback_dev_init,
+	.ndo_start_xmit = loopback_xmit,
+	.ndo_get_stats  = loopback_get_stats,
+#ifdef CONFIG_CHECKPOINT
+	.ndo_checkpoint = loopback_checkpoint,
+#endif
 };
 
 /*
-- 
1.6.2.5


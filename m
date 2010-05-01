From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [PATCH v21 097/100] c/r: Add loopback checkpoint support (v2)
Date: Sat,  1 May 2010 10:16:19 -0400
Message-ID: <1272723382-19470-98-git-send-email-orenl@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Dan Smith <danms@us.ibm.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tarap.cc.columbia.edu ([128.59.29.7]:64438 "EHLO
	tarap.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933036Ab0EAOiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 10:38:51 -0400
In-Reply-To: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>

Adds a small ndo_checkpoint() handler for loopback devices to write the
name and addresses like other interfaces.

Changelog[v21]:
 - Unbreak compiling with CONFIG_CHECKPOINT=n or CONFIG_NET_NS=n

Changes in v2:
 - Add CONFIG_CHECKPOINT around the handler

Cc: netdev@vger.kernel.org
Signed-off-by: Dan Smith <danms@us.ibm.com>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
---
 drivers/net/loopback.c |   45 ++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 42 insertions(+), 3 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 72b7949..9a958a8 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -155,10 +155,49 @@ static void loopback_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
 
+#ifdef CONFIG_NETNS_CHECKPOINT
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
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
+#ifdef CONFIG_NETNS_CHECKPOINT
+	.ndo_checkpoint = loopback_checkpoint,
+#endif
 };
 
 /*
-- 
1.6.3.3


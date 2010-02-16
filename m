From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 4/5] Add loopback checkpoint support
Date: Tue, 16 Feb 2010 08:13:56 -0800
Message-ID: <87d40588fv.fsf@caffeine.danplanet.com>
References: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
	<1266336187-19105-5-git-send-email-danms@us.ibm.com>
	<1266336555.3045.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:33513 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756468Ab0BPQN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 11:13:58 -0500
In-Reply-To: <1266336555.3045.57.camel@edumazet-laptop> (Eric Dumazet's message of "Tue\, 16 Feb 2010 17\:09\:15 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ED> Dont you have a #ifdef CONFIG_CHECKPOINT or something to avoid
ED> this for small machines ?

Yes, and the veth patch used it appropriately.  It should look like
this:

Add loopback checkpoint support (v2)

Adds a small ndo_checkpoint() handler for loopback devices to write the
name and addresses like other interfaces.

Changes in v2:
 - Add CONFIG_CHECKPOINT around the handler

Signed-off-by: Dan Smith <danms@us.ibm.com>

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
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com

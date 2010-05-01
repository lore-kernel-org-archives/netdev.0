From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [PATCH v21 098/100] c/r: Add a checkpoint handler to the 'sit' device
Date: Sat,  1 May 2010 10:16:20 -0400
Message-ID: <1272723382-19470-99-git-send-email-orenl@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Dan Smith <danms@us.ibm.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tarap.cc.columbia.edu ([128.59.29.7]:64450 "EHLO
	tarap.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933046Ab0EAOi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 10:38:56 -0400
In-Reply-To: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>

This handler doesn't really do much to checkpoint the device, other
than the minimum required to support the restart process.  When we
add IPv6 support to this, then we can fill this out.

This allows us to avoid skipping unsupported interfaces on a normal
system.

Changelog[v21]:
  - Do not include checkpoint_hdr.h explicitly
  - Unbreak compiling with CONFIG_CHECKPOINT=n or CONFIG_NET_NS=n

Cc: netdev@vger.kernel.org
Signed-off-by: Dan Smith <danms@us.ibm.com>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
---
 net/ipv6/sit.c |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 5abae10..5ecbe56 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1084,11 +1084,45 @@ static int ipip6_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+#include <linux/checkpoint.h>
+
+#ifdef CONFIG_NETNS_CHECKPOINT
+static int ipip6_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev)
+{
+	struct ckpt_hdr_netdev *h;
+	struct ckpt_netdev_addr *addrs;
+	int ret;
+
+	h = ckpt_netdev_base(ctx, dev, &addrs);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	h->type = CKPT_NETDEV_SIT;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
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
 static const struct net_device_ops ipip6_netdev_ops = {
 	.ndo_uninit	= ipip6_tunnel_uninit,
 	.ndo_start_xmit	= ipip6_tunnel_xmit,
 	.ndo_do_ioctl	= ipip6_tunnel_ioctl,
 	.ndo_change_mtu	= ipip6_tunnel_change_mtu,
+#ifdef CONFIG_NETNS_CHECKPOINT
+	.ndo_checkpoint	= ipip6_checkpoint,
+#endif
 };
 
 static void ipip6_tunnel_setup(struct net_device *dev)
-- 
1.6.3.3


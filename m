From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 5/5] Add a checkpoint handler to the 'sit' device
Date: Tue, 16 Feb 2010 08:03:07 -0800
Message-ID: <1266336187-19105-6-git-send-email-danms@us.ibm.com>
References: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
To: containers@lists.osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stein.danplanet.com ([71.245.107.83]:60645 "EHLO
	stein.danplanet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932771Ab0BPQFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 11:05:08 -0500
In-Reply-To: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This handler doesn't really do much to checkpoint the device, other
than the minimum required to support the restart process.  When we
add IPv6 support to this, then we can fill this out.

This allows us to avoid skipping unsupported interfaces on a normal
system.

Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 net/ipv6/sit.c |   30 ++++++++++++++++++++++++++++++
 1 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 976e682..a9fc331 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -32,6 +32,8 @@
 #include <linux/init.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/if_ether.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -1085,11 +1087,39 @@ static int ipip6_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
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
+
 static const struct net_device_ops ipip6_netdev_ops = {
 	.ndo_uninit	= ipip6_tunnel_uninit,
 	.ndo_start_xmit	= ipip6_tunnel_xmit,
 	.ndo_do_ioctl	= ipip6_tunnel_ioctl,
 	.ndo_change_mtu	= ipip6_tunnel_change_mtu,
+	.ndo_checkpoint	= ipip6_checkpoint,
 };
 
 static void ipip6_tunnel_setup(struct net_device *dev)
-- 
1.6.2.5


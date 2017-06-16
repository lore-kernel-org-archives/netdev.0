From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC net-next 2/8] xdp: add HW offload mode flag for installing programs
Date: Fri, 16 Jun 2017 16:57:40 -0700
Message-ID: <20170616235746.16337-3-jakub.kicinski@netronome.com>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, kafai@fb.com, daniel@iogearbox.net,
        netoptimizer@brouer.com, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:34883 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750967AbdFPX6Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 19:58:25 -0400
Received: by mail-pg0-f50.google.com with SMTP id k71so26290788pgd.2
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 16:58:25 -0700 (PDT)
In-Reply-To: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an installation-time flag for requesting that the program
be installed only if it can be offloaded to HW.

Internally new command for ndo_xdp is added, this way we avoid
putting checks into drivers since they all return -EINVAL on
an unknown command.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/netdevice.h    | 1 +
 include/uapi/linux/if_link.h | 7 +++++--
 net/core/dev.c               | 7 +++++--
 net/core/rtnetlink.c         | 4 ++--
 4 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b194817631de..a838591aad28 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -807,6 +807,7 @@ enum xdp_netdev_command {
 	 * when it is no longer used.
 	 */
 	XDP_SETUP_PROG,
+	XDP_SETUP_PROG_HW,
 	/* Check if a bpf program is set on the device.  The callee should
 	 * return true if a program is currently attached and running.
 	 */
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index dd88375a6580..ce777ec88e1e 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -891,9 +891,12 @@ enum {
 #define XDP_FLAGS_UPDATE_IF_NOEXIST	(1U << 0)
 #define XDP_FLAGS_SKB_MODE		(1U << 1)
 #define XDP_FLAGS_DRV_MODE		(1U << 2)
+#define XDP_FLAGS_HW_MODE		(1U << 3)
+#define XDP_FLAGS_MODES			(XDP_FLAGS_SKB_MODE | \
+					 XDP_FLAGS_DRV_MODE | \
+					 XDP_FLAGS_HW_MODE)
 #define XDP_FLAGS_MASK			(XDP_FLAGS_UPDATE_IF_NOEXIST | \
-					 XDP_FLAGS_SKB_MODE | \
-					 XDP_FLAGS_DRV_MODE)
+					 XDP_FLAGS_MODES)
 
 /* These are stored into IFLA_XDP_ATTACHED on dump. */
 enum {
diff --git a/net/core/dev.c b/net/core/dev.c
index a04db264aa1c..05cec8e2cd82 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6959,7 +6959,10 @@ static int dev_xdp_install(struct net_device *dev, xdp_op_t xdp_op,
 	struct netdev_xdp xdp;
 
 	memset(&xdp, 0, sizeof(xdp));
-	xdp.command = XDP_SETUP_PROG;
+	if (flags & XDP_FLAGS_HW_MODE)
+		xdp.command = XDP_SETUP_PROG_HW;
+	else
+		xdp.command = XDP_SETUP_PROG;
 	xdp.extack = extack;
 	xdp.flags = flags;
 	xdp.prog = prog;
@@ -6987,7 +6990,7 @@ int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 	ASSERT_RTNL();
 
 	xdp_op = xdp_chk = ops->ndo_xdp;
-	if (!xdp_op && (flags & XDP_FLAGS_DRV_MODE))
+	if (!xdp_op && (flags & (XDP_FLAGS_DRV_MODE | XDP_FLAGS_HW_MODE)))
 		return -EOPNOTSUPP;
 	if (!xdp_op || (flags & XDP_FLAGS_SKB_MODE))
 		xdp_op = generic_xdp_install;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 3aa57848a895..daf3b39be649 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -16,6 +16,7 @@
  *	Vitaly E. Lavrov		RTA_OK arithmetics was wrong.
  */
 
+#include <linux/bitops.h>
 #include <linux/errno.h>
 #include <linux/module.h>
 #include <linux/types.h>
@@ -2251,8 +2252,7 @@ static int do_setlink(const struct sk_buff *skb,
 				err = -EINVAL;
 				goto errout;
 			}
-			if ((xdp_flags & XDP_FLAGS_SKB_MODE) &&
-			    (xdp_flags & XDP_FLAGS_DRV_MODE)) {
+			if (hweight32(xdp_flags & XDP_FLAGS_MODES) > 1) {
 				err = -EINVAL;
 				goto errout;
 			}
-- 
2.11.0

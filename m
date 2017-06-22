From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 7/8] xdp: add reporting of offload mode
Date: Wed, 21 Jun 2017 18:25:09 -0700
Message-ID: <20170622012510.5286-8-jakub.kicinski@netronome.com>
References: <20170622012510.5286-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kafai@fb.com, daniel@iogearbox.net,
        davem@davemloft.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33327 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752132AbdFVB0D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 21:26:03 -0400
Received: by mail-pg0-f42.google.com with SMTP id f127so1226805pgc.0
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 18:26:03 -0700 (PDT)
In-Reply-To: <20170622012510.5286-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the XDP_ATTACHED_* values to include offloaded mode.
Let drivers report whether program is installed in the driver
or the HW by changing the prog_attached field from bool to
u8 (type of the netlink attribute).

Exploit the fact that the value of XDP_ATTACHED_DRV is 1,
therefore since all drivers currently assign the mode with
double negation:
       mode = !!xdp_prog;
no drivers have to be modified.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/netdevice.h    | 7 ++++---
 include/uapi/linux/if_link.h | 1 +
 net/core/dev.c               | 3 +--
 net/core/rtnetlink.c         | 6 +++---
 4 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a838591aad28..68f5d899d1e6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -809,7 +809,8 @@ enum xdp_netdev_command {
 	XDP_SETUP_PROG,
 	XDP_SETUP_PROG_HW,
 	/* Check if a bpf program is set on the device.  The callee should
-	 * return true if a program is currently attached and running.
+	 * set @prog_attached to one of XDP_ATTACHED_* values, note that "true"
+	 * is equivalent to XDP_ATTACHED_DRV.
 	 */
 	XDP_QUERY_PROG,
 };
@@ -827,7 +828,7 @@ struct netdev_xdp {
 		};
 		/* XDP_QUERY_PROG */
 		struct {
-			bool prog_attached;
+			u8 prog_attached;
 			u32 prog_id;
 		};
 	};
@@ -3307,7 +3308,7 @@ struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 typedef int (*xdp_op_t)(struct net_device *dev, struct netdev_xdp *xdp);
 int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 		      int fd, u32 flags);
-bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op, u32 *prog_id);
+u8 __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op, u32 *prog_id);
 
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index ce777ec88e1e..8d062c58d5cb 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -903,6 +903,7 @@ enum {
 	XDP_ATTACHED_NONE = 0,
 	XDP_ATTACHED_DRV,
 	XDP_ATTACHED_SKB,
+	XDP_ATTACHED_HW,
 };
 
 enum {
diff --git a/net/core/dev.c b/net/core/dev.c
index cd885e9e3363..a91572aa73d5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6934,8 +6934,7 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 }
 EXPORT_SYMBOL(dev_change_proto_down);
 
-bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op,
-			u32 *prog_id)
+u8 __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op, u32 *prog_id)
 {
 	struct netdev_xdp xdp;
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a5bedd03a63e..9a1bd510c812 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1265,10 +1265,10 @@ static u8 rtnl_xdp_attached_mode(struct net_device *dev, u32 *prog_id)
 		*prog_id = generic_xdp_prog->aux->id;
 		return XDP_ATTACHED_SKB;
 	}
-	if (ops->ndo_xdp && __dev_xdp_attached(dev, ops->ndo_xdp, prog_id))
-		return XDP_ATTACHED_DRV;
+	if (!ops->ndo_xdp)
+		return XDP_ATTACHED_NONE;
 
-	return XDP_ATTACHED_NONE;
+	return __dev_xdp_attached(dev, ops->ndo_xdp, prog_id);
 }
 
 static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
-- 
2.11.0

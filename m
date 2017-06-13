From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 00/10] bpf: xdp: Report bpf_prog ID in IFLA_XDP
Date: Mon, 12 Jun 2017 18:26:02 -0700
Message-ID: <20170612182452.61b8a0a3@cakuba.netronome.com>
References: <20170613010025.2983342-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:25293 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752508AbdFMB0L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Jun 2017 21:26:11 -0400
In-Reply-To: <20170613010025.2983342-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Jun 2017 18:00:15 -0700, Martin KaFai Lau wrote:
> This is the first usage of the new bpf_prog ID.  It is for
> reporting the ID of a xdp_prog through netlink.
> 
> It rides on the existing IFLA_XDP.  This patch adds IFLA_XDP_PROG_ID
> for the bpf_prog ID reporting.
> 
> It starts with changing the generic_xdp first.  After that,
> the hardware driver is changed one by one.  The final patch
> removes the prog_attached from 'struct netdev_xdp' because
> prog_id > 0 implies the presence of xdp_prog.

Daniel made the XDP_ATTACHED an enum to be able to extend it with other
modes.  I would appreciate if you didn't remove the member since I have
this waiting in my tree:

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon, 5 Jun 2017 22:52:01 -0700
Subject: [PATCH net-next] xdp: add reporting of offload mode

Extend the XDP_ATTACHED_* values to include offloaded mode.
Let drivers report whether program is installed in the driver
or the HW by changing the prog_attached field from bool to
u8 (type of the netlink attribute).

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/netdevice.h    | 7 ++++---
 include/uapi/linux/if_link.h | 1 +
 net/core/dev.c               | 2 +-
 net/core/rtnetlink.c         | 6 +++---
 4 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 524c7776ce96..76165dfd2a1e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -808,7 +808,8 @@ enum xdp_netdev_command {
 	 */
 	XDP_SETUP_PROG,
 	/* Check if a bpf program is set on the device.  The callee should
-	 * return true if a program is currently attached and running.
+	 * set @prog_attached to one of XDP_ATTACHED_* values, note that "true"
+	 * is equivalent to XDP_ATTACHED_DRV.
 	 */
 	XDP_QUERY_PROG,
 };
@@ -824,7 +825,7 @@ struct netdev_xdp {
 			struct netlink_ext_ack *extack;
 		};
 		/* XDP_QUERY_PROG */
-		bool prog_attached;
+		u8 prog_attached;
 	};
 };
 
@@ -3302,7 +3303,7 @@ struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 typedef int (*xdp_op_t)(struct net_device *dev, struct netdev_xdp *xdp);
 int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 		      int fd, u32 flags);
-bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op);
+u8 __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op);
 
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8ed679fe603f..4dd59b7463a9 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -900,6 +900,7 @@ enum {
 	XDP_ATTACHED_NONE = 0,
 	XDP_ATTACHED_DRV,
 	XDP_ATTACHED_SKB,
+	XDP_ATTACHED_HW,
 };
 
 enum {
diff --git a/net/core/dev.c b/net/core/dev.c
index 8f72f4a9c6ac..8f29b6ba99ac 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6930,7 +6930,7 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 }
 EXPORT_SYMBOL(dev_change_proto_down);
 
-bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op)
+u8 __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op)
 {
 	struct netdev_xdp xdp;
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 7084f1db2446..5b16e479ea68 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1255,10 +1255,10 @@ static u8 rtnl_xdp_attached_mode(struct net_device *dev)
 
 	if (rcu_access_pointer(dev->xdp_prog))
 		return XDP_ATTACHED_SKB;
-	if (ops->ndo_xdp && __dev_xdp_attached(dev, ops->ndo_xdp))
-		return XDP_ATTACHED_DRV;
+	if (!ops->ndo_xdp)
+		return XDP_ATTACHED_NONE;
 
-	return XDP_ATTACHED_NONE;
+	return __dev_xdp_attached(dev, ops->ndo_xdp);
 }
 
 static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
-- 
2.11.0

From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 1/9] net: Add IFLA_XDP_PROG_ID
Date: Thu, 15 Jun 2017 17:29:09 -0700
Message-ID: <20170616002917.2976329-2-kafai@fb.com>
References: <20170616002917.2976329-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46431 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751893AbdFPA3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 20:29:21 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5G0LZ9a031839
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:20 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2b3vst1jqa-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:20 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 d5a8e6c6522a11e780980002c991e86a-55b3d8f0 for <netdev@vger.kernel.org>;        Thu,
 15 Jun 2017 17:29:18 -0700
In-Reply-To: <20170616002917.2976329-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expose prog_id through IFLA_XDP_PROG_ID.  This patch
makes modification to generic_xdp.  The later patches will
modify other xdp-supported drivers.

prog_id is added to struct net_dev_xdp.

iproute2 patch will be followed. Here is how the 'ip link'
will look like:
> ip link show eth0
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 xdp(prog_id:1) qdisc fq_codel state UP mode DEFAULT group default qlen 1000

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/netdevice.h    |  7 +++++--
 include/uapi/linux/if_link.h |  1 +
 net/core/dev.c               | 19 +++++++++++--------
 net/core/rtnetlink.c         | 27 +++++++++++++++++++++------
 4 files changed, 38 insertions(+), 16 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ad98a83f1332..7c7118b3bd69 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -824,7 +824,10 @@ struct netdev_xdp {
 			struct netlink_ext_ack *extack;
 		};
 		/* XDP_QUERY_PROG */
-		bool prog_attached;
+		struct {
+			bool prog_attached;
+			u32 prog_id;
+		};
 	};
 };
 
@@ -3302,7 +3305,7 @@ struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 typedef int (*xdp_op_t)(struct net_device *dev, struct netdev_xdp *xdp);
 int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 		      int fd, u32 flags);
-bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op);
+bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op, u32 *prog_id);
 
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8ed679fe603f..dd88375a6580 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -907,6 +907,7 @@ enum {
 	IFLA_XDP_FD,
 	IFLA_XDP_ATTACHED,
 	IFLA_XDP_FLAGS,
+	IFLA_XDP_PROG_ID,
 	__IFLA_XDP_MAX,
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 8658074ecad6..b8d6dd9e8b5c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4342,13 +4342,12 @@ static struct static_key generic_xdp_needed __read_mostly;
 
 static int generic_xdp_install(struct net_device *dev, struct netdev_xdp *xdp)
 {
+	struct bpf_prog *old = rtnl_dereference(dev->xdp_prog);
 	struct bpf_prog *new = xdp->prog;
 	int ret = 0;
 
 	switch (xdp->command) {
-	case XDP_SETUP_PROG: {
-		struct bpf_prog *old = rtnl_dereference(dev->xdp_prog);
-
+	case XDP_SETUP_PROG:
 		rcu_assign_pointer(dev->xdp_prog, new);
 		if (old)
 			bpf_prog_put(old);
@@ -4360,10 +4359,10 @@ static int generic_xdp_install(struct net_device *dev, struct netdev_xdp *xdp)
 			dev_disable_lro(dev);
 		}
 		break;
-	}
 
 	case XDP_QUERY_PROG:
-		xdp->prog_attached = !!rcu_access_pointer(dev->xdp_prog);
+		xdp->prog_attached = !!old;
+		xdp->prog_id = old ? old->aux->id : 0;
 		break;
 
 	default:
@@ -6937,7 +6936,8 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 }
 EXPORT_SYMBOL(dev_change_proto_down);
 
-bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op)
+bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op,
+			u32 *prog_id)
 {
 	struct netdev_xdp xdp;
 
@@ -6946,6 +6946,9 @@ bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op)
 
 	/* Query must always succeed. */
 	WARN_ON(xdp_op(dev, &xdp) < 0);
+	if (prog_id)
+		*prog_id = xdp.prog_id;
+
 	return xdp.prog_attached;
 }
 
@@ -6991,10 +6994,10 @@ int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 		xdp_chk = generic_xdp_install;
 
 	if (fd >= 0) {
-		if (xdp_chk && __dev_xdp_attached(dev, xdp_chk))
+		if (xdp_chk && __dev_xdp_attached(dev, xdp_chk, NULL))
 			return -EEXIST;
 		if ((flags & XDP_FLAGS_UPDATE_IF_NOEXIST) &&
-		    __dev_xdp_attached(dev, xdp_op))
+		    __dev_xdp_attached(dev, xdp_op, NULL))
 			return -EBUSY;
 
 		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2769ad9834d1..3aa57848a895 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -39,6 +39,7 @@
 #include <linux/if_vlan.h>
 #include <linux/pci.h>
 #include <linux/etherdevice.h>
+#include <linux/bpf.h>
 
 #include <linux/uaccess.h>
 
@@ -899,7 +900,8 @@ static size_t rtnl_port_size(const struct net_device *dev,
 static size_t rtnl_xdp_size(void)
 {
 	size_t xdp_size = nla_total_size(0) +	/* nest IFLA_XDP */
-			  nla_total_size(1);	/* XDP_ATTACHED */
+			  nla_total_size(1) +	/* XDP_ATTACHED */
+			  nla_total_size(4);	/* XDP_PROG_ID */
 
 	return xdp_size;
 }
@@ -1248,15 +1250,20 @@ static int rtnl_fill_link_ifmap(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static u8 rtnl_xdp_attached_mode(struct net_device *dev)
+static u8 rtnl_xdp_attached_mode(struct net_device *dev, u32 *prog_id)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+	const struct bpf_prog *generic_xdp_prog;
 
 	ASSERT_RTNL();
 
-	if (rcu_access_pointer(dev->xdp_prog))
+	*prog_id = 0;
+	generic_xdp_prog = rtnl_dereference(dev->xdp_prog);
+	if (generic_xdp_prog) {
+		*prog_id = generic_xdp_prog->aux->id;
 		return XDP_ATTACHED_SKB;
-	if (ops->ndo_xdp && __dev_xdp_attached(dev, ops->ndo_xdp))
+	}
+	if (ops->ndo_xdp && __dev_xdp_attached(dev, ops->ndo_xdp, prog_id))
 		return XDP_ATTACHED_DRV;
 
 	return XDP_ATTACHED_NONE;
@@ -1265,6 +1272,7 @@ static u8 rtnl_xdp_attached_mode(struct net_device *dev)
 static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
 {
 	struct nlattr *xdp;
+	u32 prog_id;
 	int err;
 
 	xdp = nla_nest_start(skb, IFLA_XDP);
@@ -1272,10 +1280,16 @@ static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
 		return -EMSGSIZE;
 
 	err = nla_put_u8(skb, IFLA_XDP_ATTACHED,
-			 rtnl_xdp_attached_mode(dev));
+			 rtnl_xdp_attached_mode(dev, &prog_id));
 	if (err)
 		goto err_cancel;
 
+	if (prog_id) {
+		err = nla_put_u32(skb, IFLA_XDP_PROG_ID, prog_id);
+		if (err)
+			goto err_cancel;
+	}
+
 	nla_nest_end(skb, xdp);
 	return 0;
 
@@ -1553,6 +1567,7 @@ static const struct nla_policy ifla_xdp_policy[IFLA_XDP_MAX + 1] = {
 	[IFLA_XDP_FD]		= { .type = NLA_S32 },
 	[IFLA_XDP_ATTACHED]	= { .type = NLA_U8 },
 	[IFLA_XDP_FLAGS]	= { .type = NLA_U32 },
+	[IFLA_XDP_PROG_ID]	= { .type = NLA_U32 },
 };
 
 static const struct rtnl_link_ops *linkinfo_to_kind_ops(const struct nlattr *nla)
@@ -2225,7 +2240,7 @@ static int do_setlink(const struct sk_buff *skb,
 		if (err < 0)
 			goto errout;
 
-		if (xdp[IFLA_XDP_ATTACHED]) {
+		if (xdp[IFLA_XDP_ATTACHED] || xdp[IFLA_XDP_PROG_ID]) {
 			err = -EINVAL;
 			goto errout;
 		}
-- 
2.9.3

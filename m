From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 01/10] net: Add IFLA_XDP_PROG_ID
Date: Mon, 12 Jun 2017 18:00:16 -0700
Message-ID: <20170613010025.2983342-2-kafai@fb.com>
References: <20170613010025.2983342-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:52088 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753206AbdFMBA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 21:00:29 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5D0xmZZ001880
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:29 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b1wwd1yqm-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:29 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 afdaede44fd311e7a31777a337fa907c-77b3e8f0 for <netdev@vger.kernel.org>;        Mon,
 12 Jun 2017 18:00:26 -0700
In-Reply-To: <20170613010025.2983342-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expose prog_id through IFLA_XDP_PROG_ID.  This patch
makes modification to generic_xdp.  The later patches will
modify other xdp-supported drivers.

prog_id is added to struct net_dev_xdp.  It is redundant
to prog_attached because prog_id > 0 implies prog_attached.
Hence, prog_attached will be removed after other xdp-supported
drivers can report prog_id during XDP_QUERY_PROG.

iproute2 patch will be followed. Here is how the 'ip link'
will look like:
> ip link show eth0
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 xdp(prog_id:1) qdisc fq_codel state UP mode DEFAULT group default qlen 1000

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/netdevice.h    |  3 ++-
 include/uapi/linux/if_link.h |  1 +
 net/core/dev.c               | 23 +++++++++++++++--------
 net/core/rtnetlink.c         | 27 +++++++++++++++++++++------
 4 files changed, 39 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 524c7776ce96..dec4a2f25c2e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -826,6 +826,7 @@ struct netdev_xdp {
 		/* XDP_QUERY_PROG */
 		bool prog_attached;
 	};
+	u32 prog_id;
 };
 
 #ifdef CONFIG_XFRM_OFFLOAD
@@ -3302,7 +3303,7 @@ struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
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
index 8f72f4a9c6ac..aa7c6eba5af6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4341,13 +4341,12 @@ static struct static_key generic_xdp_needed __read_mostly;
 
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
@@ -4359,10 +4358,12 @@ static int generic_xdp_install(struct net_device *dev, struct netdev_xdp *xdp)
 			dev_disable_lro(dev);
 		}
 		break;
-	}
 
 	case XDP_QUERY_PROG:
-		xdp->prog_attached = !!rcu_access_pointer(dev->xdp_prog);
+		if (old)
+			xdp->prog_id = old->aux->id;
+		else
+			xdp->prog_id = 0;
 		break;
 
 	default:
@@ -6930,7 +6931,8 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 }
 EXPORT_SYMBOL(dev_change_proto_down);
 
-bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op)
+bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op,
+			u32 *prog_id)
 {
 	struct netdev_xdp xdp;
 
@@ -6939,6 +6941,11 @@ bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op)
 
 	/* Query must always succeed. */
 	WARN_ON(xdp_op(dev, &xdp) < 0);
+	if (xdp.prog_id)
+		xdp.prog_attached = true;
+	if (prog_id)
+		*prog_id = xdp.prog_id;
+
 	return xdp.prog_attached;
 }
 
@@ -6984,10 +6991,10 @@ int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
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
index 7084f1db2446..f25a53b1fb92 100644
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
@@ -1247,15 +1249,20 @@ static int rtnl_fill_link_ifmap(struct sk_buff *skb, struct net_device *dev)
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
@@ -1264,6 +1271,7 @@ static u8 rtnl_xdp_attached_mode(struct net_device *dev)
 static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
 {
 	struct nlattr *xdp;
+	u32 prog_id;
 	int err;
 
 	xdp = nla_nest_start(skb, IFLA_XDP);
@@ -1271,10 +1279,16 @@ static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
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
 
@@ -1552,6 +1566,7 @@ static const struct nla_policy ifla_xdp_policy[IFLA_XDP_MAX + 1] = {
 	[IFLA_XDP_FD]		= { .type = NLA_S32 },
 	[IFLA_XDP_ATTACHED]	= { .type = NLA_U8 },
 	[IFLA_XDP_FLAGS]	= { .type = NLA_U32 },
+	[IFLA_XDP_PROG_ID]	= { .type = NLA_U32 },
 };
 
 static const struct rtnl_link_ops *linkinfo_to_kind_ops(const struct nlattr *nla)
@@ -2224,7 +2239,7 @@ static int do_setlink(const struct sk_buff *skb,
 		if (err < 0)
 			goto errout;
 
-		if (xdp[IFLA_XDP_ATTACHED]) {
+		if (xdp[IFLA_XDP_ATTACHED] || xdp[IFLA_XDP_PROG_ID]) {
 			err = -EINVAL;
 			goto errout;
 		}
-- 
2.9.3

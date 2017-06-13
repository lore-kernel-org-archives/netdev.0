From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 10/10] net: Remove prog_attached from struct netdev_xdp
Date: Mon, 12 Jun 2017 18:00:25 -0700
Message-ID: <20170613010025.2983342-11-kafai@fb.com>
References: <20170613010025.2983342-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45633 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753217AbdFMBAa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 21:00:30 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v5D0x5C8003743
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:29 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2b22rt8gxu-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:29 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 b0cbe6364fd311e7bd720002c991e86a-81f3b8f0 for <netdev@vger.kernel.org>;        Mon,
 12 Jun 2017 18:00:28 -0700
In-Reply-To: <20170613010025.2983342-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

prog_attached can be implied by prog_id (!!prog_id) and
all drivers supporting xdp has been stopped setting prog_attached.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/netdevice.h |  5 ++---
 net/core/dev.c            | 14 ++++----------
 net/core/rtnetlink.c      |  7 +++++--
 3 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index dec4a2f25c2e..a4ac0821b903 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -824,9 +824,8 @@ struct netdev_xdp {
 			struct netlink_ext_ack *extack;
 		};
 		/* XDP_QUERY_PROG */
-		bool prog_attached;
+		u32 prog_id;
 	};
-	u32 prog_id;
 };
 
 #ifdef CONFIG_XFRM_OFFLOAD
@@ -3303,7 +3302,7 @@ struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 typedef int (*xdp_op_t)(struct net_device *dev, struct netdev_xdp *xdp);
 int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 		      int fd, u32 flags);
-bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op, u32 *prog_id);
+u32 __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op);
 
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index aa7c6eba5af6..a484f946267c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6931,8 +6931,7 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 }
 EXPORT_SYMBOL(dev_change_proto_down);
 
-bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op,
-			u32 *prog_id)
+u32 __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op)
 {
 	struct netdev_xdp xdp;
 
@@ -6941,12 +6940,7 @@ bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op,
 
 	/* Query must always succeed. */
 	WARN_ON(xdp_op(dev, &xdp) < 0);
-	if (xdp.prog_id)
-		xdp.prog_attached = true;
-	if (prog_id)
-		*prog_id = xdp.prog_id;
-
-	return xdp.prog_attached;
+	return xdp.prog_id;
 }
 
 static int dev_xdp_install(struct net_device *dev, xdp_op_t xdp_op,
@@ -6991,10 +6985,10 @@ int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 		xdp_chk = generic_xdp_install;
 
 	if (fd >= 0) {
-		if (xdp_chk && __dev_xdp_attached(dev, xdp_chk, NULL))
+		if (xdp_chk && __dev_xdp_attached(dev, xdp_chk))
 			return -EEXIST;
 		if ((flags & XDP_FLAGS_UPDATE_IF_NOEXIST) &&
-		    __dev_xdp_attached(dev, xdp_op, NULL))
+		    __dev_xdp_attached(dev, xdp_op))
 			return -EBUSY;
 
 		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index f25a53b1fb92..feba0ec757c4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1262,8 +1262,11 @@ static u8 rtnl_xdp_attached_mode(struct net_device *dev, u32 *prog_id)
 		*prog_id = generic_xdp_prog->aux->id;
 		return XDP_ATTACHED_SKB;
 	}
-	if (ops->ndo_xdp && __dev_xdp_attached(dev, ops->ndo_xdp, prog_id))
-		return XDP_ATTACHED_DRV;
+	if (ops->ndo_xdp) {
+		*prog_id = __dev_xdp_attached(dev, ops->ndo_xdp);
+		if (*prog_id)
+			return XDP_ATTACHED_DRV;
+	}
 
 	return XDP_ATTACHED_NONE;
 }
-- 
2.9.3

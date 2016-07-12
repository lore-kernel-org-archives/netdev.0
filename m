From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v8 03/11] rtnl: add option for setting link xdp prog
Date: Tue, 12 Jul 2016 00:51:26 -0700
Message-ID: <1468309894-26258-4-git-send-email-bblanco@plumgrid.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36089 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbcGLHwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 03:52:35 -0400
Received: by mail-pa0-f48.google.com with SMTP id hu1so4075879pad.3
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 00:52:35 -0700 (PDT)
In-Reply-To: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sets the bpf program represented by fd as an early filter in the rx path
of the netdev. The fd must have been created as BPF_PROG_TYPE_XDP.
Providing a negative value as fd clears the program. Getting the fd back
via rtnl is not possible, therefore reading of this value merely
provides a bool whether the program is valid on the link or not.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 include/uapi/linux/if_link.h | 12 +++++++++
 net/core/rtnetlink.c         | 64 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 76 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 4285ac3..a1b5202 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -156,6 +156,7 @@ enum {
 	IFLA_GSO_MAX_SEGS,
 	IFLA_GSO_MAX_SIZE,
 	IFLA_PAD,
+	IFLA_XDP,
 	__IFLA_MAX
 };
 
@@ -843,4 +844,15 @@ enum {
 };
 #define LINK_XSTATS_TYPE_MAX (__LINK_XSTATS_TYPE_MAX - 1)
 
+/* XDP section */
+
+enum {
+	IFLA_XDP_UNSPEC,
+	IFLA_XDP_FD,
+	IFLA_XDP_ATTACHED,
+	__IFLA_XDP_MAX,
+};
+
+#define IFLA_XDP_MAX (__IFLA_XDP_MAX - 1)
+
 #endif /* _UAPI_LINUX_IF_LINK_H */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a9e3805..eba2b82 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -891,6 +891,16 @@ static size_t rtnl_port_size(const struct net_device *dev,
 		return port_self_size;
 }
 
+static size_t rtnl_xdp_size(const struct net_device *dev)
+{
+	size_t xdp_size = nla_total_size(1);	/* XDP_ATTACHED */
+
+	if (!dev->netdev_ops->ndo_xdp)
+		return 0;
+	else
+		return xdp_size;
+}
+
 static noinline size_t if_nlmsg_size(const struct net_device *dev,
 				     u32 ext_filter_mask)
 {
@@ -927,6 +937,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
 	       + nla_total_size(IFNAMSIZ) /* IFLA_PHYS_PORT_NAME */
+	       + rtnl_xdp_size(dev) /* IFLA_XDP */
 	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
 
 }
@@ -1211,6 +1222,33 @@ static int rtnl_fill_link_ifmap(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
+{
+	struct netdev_xdp xdp_op = {};
+	struct nlattr *xdp;
+	int err;
+
+	if (!dev->netdev_ops->ndo_xdp)
+		return 0;
+	xdp = nla_nest_start(skb, IFLA_XDP);
+	if (!xdp)
+		return -EMSGSIZE;
+	xdp_op.command = XDP_QUERY_PROG;
+	err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
+	if (err)
+		goto err_cancel;
+	err = nla_put_u8(skb, IFLA_XDP_ATTACHED, xdp_op.prog_attached);
+	if (err)
+		goto err_cancel;
+
+	nla_nest_end(skb, xdp);
+	return 0;
+
+err_cancel:
+	nla_nest_cancel(skb, xdp);
+	return err;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask)
@@ -1307,6 +1345,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (rtnl_port_fill(skb, dev, ext_filter_mask))
 		goto nla_put_failure;
 
+	if (rtnl_xdp_fill(skb, dev))
+		goto nla_put_failure;
+
 	if (dev->rtnl_link_ops || rtnl_have_link_slave_info(dev)) {
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;
@@ -1392,6 +1433,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
 	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
 	[IFLA_PROTO_DOWN]	= { .type = NLA_U8 },
+	[IFLA_XDP]		= { .type = NLA_NESTED },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -1429,6 +1471,11 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
 };
 
+static const struct nla_policy ifla_xdp_policy[IFLA_XDP_MAX + 1] = {
+	[IFLA_XDP_FD]		= { .type = NLA_S32 },
+	[IFLA_XDP_ATTACHED]	= { .type = NLA_U8 },
+};
+
 static const struct rtnl_link_ops *linkinfo_to_kind_ops(const struct nlattr *nla)
 {
 	const struct rtnl_link_ops *ops = NULL;
@@ -2054,6 +2101,23 @@ static int do_setlink(const struct sk_buff *skb,
 		status |= DO_SETLINK_NOTIFY;
 	}
 
+	if (tb[IFLA_XDP]) {
+		struct nlattr *xdp[IFLA_XDP_MAX + 1];
+
+		err = nla_parse_nested(xdp, IFLA_XDP_MAX, tb[IFLA_XDP],
+				       ifla_xdp_policy);
+		if (err < 0)
+			goto errout;
+
+		if (xdp[IFLA_XDP_FD]) {
+			err = dev_change_xdp_fd(dev,
+						nla_get_s32(xdp[IFLA_XDP_FD]));
+			if (err)
+				goto errout;
+			status |= DO_SETLINK_NOTIFY;
+		}
+	}
+
 errout:
 	if (status & DO_SETLINK_MODIFIED) {
 		if (status & DO_SETLINK_NOTIFY)
-- 
2.8.2

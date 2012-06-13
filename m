From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/8] dcbnl: Prepare framework to shorten handling functions
Date: Wed, 13 Jun 2012 14:54:54 +0200
Message-ID: <825b16279efe603ea2fb3356a524604efa51050e.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, lucy.liu@intel.com,
	john.r.fastabend@intel.com, alexander.h.duyck@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19854 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752951Ab2FMMzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 08:55:05 -0400
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to allocate and send the reply message in each
handling function separately. Instead, the reply skb can be allocated
and sent in dcb_doit() directly.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/dcb/dcbnl.c |   71 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 656c7c7..5520e43 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -196,6 +196,34 @@ static const struct nla_policy dcbnl_featcfg_nest[DCB_FEATCFG_ATTR_MAX + 1] = {
 static LIST_HEAD(dcb_app_list);
 static DEFINE_SPINLOCK(dcb_lock);
 
+static struct sk_buff *dcbnl_newmsg(int type, u8 cmd, u32 port, u32 seq,
+				    u32 flags, struct nlmsghdr **nlhp)
+{
+	struct sk_buff *skb;
+	struct dcbmsg *dcb;
+	struct nlmsghdr *nlh;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return NULL;
+
+	nlh = nlmsg_put(skb, port, seq, type, sizeof(*dcb), flags);
+	if (!nlh) {
+		/* header should always fit, allocation must be buggy */
+		BUG();
+	}
+
+	dcb = nlmsg_data(nlh);
+	dcb->dcb_family = AF_UNSPEC;
+	dcb->cmd = cmd;
+	dcb->dcb_pad = 0;
+
+	if (nlhp)
+		*nlhp = nlh;
+
+	return skb;
+}
+
 /* standard netlink reply call */
 static int dcbnl_reply(u8 value, u8 event, u8 cmd, u8 attr, u32 pid,
                        u32 seq, u16 flags)
@@ -1922,6 +1950,19 @@ static int dcbnl_cee_get(struct net_device *netdev, struct nlattr **tb,
 	return err;
 }
 
+struct reply_func {
+	/* reply netlink message type */
+	int	type;
+
+	/* function to fill message contents */
+	int   (*cb)(struct net_device *, struct nlmsghdr *, u32,
+		    struct nlattr **, struct sk_buff *);
+};
+
+static const struct reply_func reply_funcs[DCB_CMD_MAX+1] = {
+	/* FIXME: add reply defs */
+};
+
 static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -1930,6 +1971,9 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct nlattr *tb[DCB_ATTR_MAX + 1];
 	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
 	int ret = -EINVAL;
+	struct sk_buff *reply_skb;
+	struct nlmsghdr *reply_nlh;
+	const struct reply_func *fn;
 
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
@@ -1939,6 +1983,14 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	if (ret < 0)
 		return ret;
 
+	if (dcb->cmd > DCB_CMD_MAX)
+		return -EINVAL;
+
+	/* check if a reply function has been defined for the command */
+	fn = &reply_funcs[dcb->cmd];
+	if (!fn->cb)
+		return -EOPNOTSUPP;
+
 	if (!tb[DCB_ATTR_IFNAME])
 		return -EINVAL;
 
@@ -1949,6 +2001,25 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	if (!netdev->dcbnl_ops)
 		goto errout;
 
+	reply_skb = dcbnl_newmsg(fn->type, dcb->cmd, pid, nlh->nlmsg_seq,
+				 nlh->nlmsg_flags, &reply_nlh);
+	if (!reply_skb) {
+		ret = -ENOBUFS;
+		goto out;
+	}
+
+	ret = fn->cb(netdev, nlh, nlh->nlmsg_seq, tb, reply_skb);
+	if (ret < 0) {
+		nlmsg_free(reply_skb);
+		goto out;
+	}
+
+	nlmsg_end(reply_skb, reply_nlh);
+
+	ret = rtnl_unicast(reply_skb, &init_net, pid);
+	if (ret)
+		goto out;
+
 	switch (dcb->cmd) {
 	case DCB_CMD_GSTATE:
 		ret = dcbnl_getstate(netdev, tb, pid, nlh->nlmsg_seq,
-- 
1.7.7.6

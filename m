From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v6 net-next 3/4] netlink: add a start callback for starting a netlink dump
Date: Tue, 15 Dec 2015 15:41:37 -0800
Message-ID: <1450222898-284030-4-git-send-email-tom@herbertland.com>
References: <1450222898-284030-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50037 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965570AbbLOXmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 18:42:04 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tBFNL3qI006504
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 15:41:57 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1ytset8um2-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 15:41:56 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 6cb9502ea38511e5833a0002c99331b0-bc1f9210 for <netdev@vger.kernel.org>;	Tue,
 15 Dec 2015 15:41:55 -0800
In-Reply-To: <1450222898-284030-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The start callback allows the caller to set up a context for the
dump callbacks. Presumably, the context can then be destroyed in
the done callback.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/netlink.h  |  2 ++
 include/net/genetlink.h  |  2 ++
 net/netlink/af_netlink.c |  4 ++++
 net/netlink/genetlink.c  | 16 ++++++++++++++++
 4 files changed, 24 insertions(+)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 639e9b8..0b41959 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -131,6 +131,7 @@ netlink_skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 struct netlink_callback {
 	struct sk_buff		*skb;
 	const struct nlmsghdr	*nlh;
+	int			(*start)(struct netlink_callback *);
 	int			(*dump)(struct sk_buff * skb,
 					struct netlink_callback *cb);
 	int			(*done)(struct netlink_callback *cb);
@@ -153,6 +154,7 @@ struct nlmsghdr *
 __nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq, int type, int len, int flags);
 
 struct netlink_dump_control {
+	int (*start)(struct netlink_callback *);
 	int (*dump)(struct sk_buff *skb, struct netlink_callback *);
 	int (*done)(struct netlink_callback *);
 	void *data;
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 1b6b6dc..43c0e77 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -114,6 +114,7 @@ static inline void genl_info_net_set(struct genl_info *info, struct net *net)
  * @flags: flags
  * @policy: attribute validation policy
  * @doit: standard command callback
+ * @start: start callback for dumps
  * @dumpit: callback for dumpers
  * @done: completion callback for dumps
  * @ops_list: operations list
@@ -122,6 +123,7 @@ struct genl_ops {
 	const struct nla_policy	*policy;
 	int		       (*doit)(struct sk_buff *skb,
 				       struct genl_info *info);
+	int		       (*start)(struct netlink_callback *cb);
 	int		       (*dumpit)(struct sk_buff *skb,
 					 struct netlink_callback *cb);
 	int		       (*done)(struct netlink_callback *cb);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 59651af..81dc1bb 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2915,6 +2915,7 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 
 	cb = &nlk->cb;
 	memset(cb, 0, sizeof(*cb));
+	cb->start = control->start;
 	cb->dump = control->dump;
 	cb->done = control->done;
 	cb->nlh = nlh;
@@ -2927,6 +2928,9 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 
 	mutex_unlock(nlk->cb_mutex);
 
+	if (cb->start)
+		cb->start(cb);
+
 	ret = netlink_dump(sk);
 	sock_put(sk);
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index bc0e504..8e63662 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -513,6 +513,20 @@ void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
 }
 EXPORT_SYMBOL(genlmsg_put);
 
+static int genl_lock_start(struct netlink_callback *cb)
+{
+	/* our ops are always const - netlink API doesn't propagate that */
+	const struct genl_ops *ops = cb->data;
+	int rc = 0;
+
+	if (ops->start) {
+		genl_lock();
+		rc = ops->start(cb);
+		genl_unlock();
+	}
+	return rc;
+}
+
 static int genl_lock_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	/* our ops are always const - netlink API doesn't propagate that */
@@ -577,6 +591,7 @@ static int genl_family_rcv_msg(struct genl_family *family,
 				.module = family->module,
 				/* we have const, but the netlink API doesn't */
 				.data = (void *)ops,
+				.start = genl_lock_start,
 				.dump = genl_lock_dumpit,
 				.done = genl_lock_done,
 			};
@@ -588,6 +603,7 @@ static int genl_family_rcv_msg(struct genl_family *family,
 		} else {
 			struct netlink_dump_control c = {
 				.module = family->module,
+				.start = ops->start,
 				.dump = ops->dumpit,
 				.done = ops->done,
 			};
-- 
2.4.6

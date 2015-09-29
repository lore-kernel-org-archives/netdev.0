From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 3/6] netlink: add a start callback for starting a netlink dump
Date: Tue, 29 Sep 2015 15:17:20 -0700
Message-ID: <1443565043-1287886-4-git-send-email-tom@herbertland.com>
References: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:20671 "EHLO
	m0041696.ppops.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755167AbbI2WR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:17:59 -0400
Received: from pps.filterd (m0041696 [127.0.0.1])
	by m0041696.ppops.net (8.14.5/8.14.5) with SMTP id t8TMGTg6023719
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:17:55 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0041696.ppops.net with ESMTP id 1x82m9g5m6-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:17:55 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 edf0543266f711e59cdb0002c9dfb610-517f4240 for <netdev@vger.kernel.org>;	Tue,
 29 Sep 2015 15:17:53 -0700
In-Reply-To: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
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
index 8f060d7..c8c43ac 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2905,6 +2905,7 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 
 	cb = &nlk->cb;
 	memset(cb, 0, sizeof(*cb));
+	cb->start = control->start;
 	cb->dump = control->dump;
 	cb->done = control->done;
 	cb->nlh = nlh;
@@ -2917,6 +2918,9 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 
 	mutex_unlock(nlk->cb_mutex);
 
+	if (cb->start)
+		cb->start(cb);
+
 	ret = netlink_dump(sk);
 	sock_put(sk);
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 75724a9..5fd08c0 100644
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

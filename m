From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 1/3] netlink: extended error reporting
Date: Fri,  7 Apr 2017 20:26:18 +0200
Message-ID: <20170407182620.6438-2-johannes@sipsolutions.net>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
Cc: pablo@netfilter.org, Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51212 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756042AbdDGS02 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 14:26:28 -0400
In-Reply-To: <20170407182620.6438-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 crypto/crypto_user.c              |  3 +-
 drivers/infiniband/core/netlink.c |  3 +-
 drivers/scsi/scsi_netlink.c       |  2 +-
 include/linux/netlink.h           | 10 ++++++-
 include/net/netlink.h             |  3 +-
 include/uapi/linux/netlink.h      | 26 +++++++++++++++++
 kernel/audit.c                    |  2 +-
 net/core/rtnetlink.c              |  3 +-
 net/core/sock_diag.c              |  3 +-
 net/hsr/hsr_netlink.c             |  4 +--
 net/netfilter/ipset/ip_set_core.c |  2 +-
 net/netfilter/nfnetlink.c         | 18 ++++++------
 net/netlink/af_netlink.c          | 60 ++++++++++++++++++++++++++++++++++-----
 net/netlink/genetlink.c           |  3 +-
 net/xfrm/xfrm_user.c              |  3 +-
 15 files changed, 117 insertions(+), 28 deletions(-)

diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
index a90404a0c5ff..4d4433e80866 100644
--- a/crypto/crypto_user.c
+++ b/crypto/crypto_user.c
@@ -483,7 +483,8 @@ static const struct crypto_link {
 	[CRYPTO_MSG_DELRNG	- CRYPTO_MSG_BASE] = { .doit = crypto_del_rng },
 };
 
-static int crypto_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int crypto_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			       struct netlink_ext_err *exterr)
 {
 	struct nlattr *attrs[CRYPTOCFGA_MAX+1];
 	const struct crypto_link *link;
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 10469b0088b5..679d65430113 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -146,7 +146,8 @@ int ibnl_put_attr(struct sk_buff *skb, struct nlmsghdr *nlh,
 }
 EXPORT_SYMBOL(ibnl_put_attr);
 
-static int ibnl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int ibnl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			struct netlink_ext_err *exterr)
 {
 	struct ibnl_client *client;
 	int type = nlh->nlmsg_type;
diff --git a/drivers/scsi/scsi_netlink.c b/drivers/scsi/scsi_netlink.c
index 109802f776ed..50e624fb8307 100644
--- a/drivers/scsi/scsi_netlink.c
+++ b/drivers/scsi/scsi_netlink.c
@@ -111,7 +111,7 @@ scsi_nl_rcv_msg(struct sk_buff *skb)
 
 next_msg:
 		if ((err) || (nlh->nlmsg_flags & NLM_F_ACK))
-			netlink_ack(skb, nlh, err);
+			netlink_ack(skb, nlh, err, NULL);
 
 		skb_pull(skb, rlen);
 	}
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index da14ab61f363..662f343dc68b 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -62,11 +62,19 @@ netlink_kernel_create(struct net *net, int unit, struct netlink_kernel_cfg *cfg)
 	return __netlink_kernel_create(net, unit, THIS_MODULE, cfg);
 }
 
+struct netlink_ext_err {
+	const char *msg;
+	u32 ext_code;
+	u32 msg_offset;
+	u16 attr;
+};
+
 extern void netlink_kernel_release(struct sock *sk);
 extern int __netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern int netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern void __netlink_clear_multicast_users(struct sock *sk, unsigned int group);
-extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
+extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
+			const struct netlink_ext_err *exterr);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 portid, int nonblock);
diff --git a/include/net/netlink.h b/include/net/netlink.h
index b239fcd33d80..f06c2e00ebc3 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -233,7 +233,8 @@ struct nl_info {
 };
 
 int netlink_rcv_skb(struct sk_buff *skb,
-		    int (*cb)(struct sk_buff *, struct nlmsghdr *));
+		    int (*cb)(struct sk_buff *, struct nlmsghdr *,
+			      struct netlink_ext_err *));
 int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 portid,
 		 unsigned int group, int report, gfp_t flags);
 
diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index b2c9c26ea30f..0ef970e6f9f5 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -101,6 +101,31 @@ struct nlmsghdr {
 struct nlmsgerr {
 	int		error;
 	struct nlmsghdr msg;
+	/*
+	 * followed by the message contents unless NETLINK_CAP_ACK was set,
+	 * message length is aligned with NLMSG_ALIGN()
+	 */
+	/*
+	 * followed by TLVs defined in enum nlmsgerr_attrs
+	 * if NETLINK_EXT_ACK was set
+	 */
+};
+
+/**
+ * enum nlmsgerr_attrs - netlink error message attributes
+ * @NLMSGERR_ATTR_UNUSED: unused
+ * @NLMSGERR_ATTR_MSG: error message string (string)
+ * @NLMSGERR_ATTR_OFFS: error offset in the original message (u32)
+ * @NLMSGERR_ATTR_CODE: extended per-subsystem error code (u32)
+ * @NLMSGERR_ATTR_ATTR: top-level attribute that caused the error
+ *	(or is missing, u16)
+ */
+enum nlmsgerr_attrs {
+	NLMSGERR_ATTR_UNUSED,
+	NLMSGERR_ATTR_MSG,
+	NLMSGERR_ATTR_OFFS,
+	NLMSGERR_ATTR_CODE,
+	NLMSGERR_ATTR_ATTR,
 };
 
 #define NETLINK_ADD_MEMBERSHIP		1
@@ -115,6 +140,7 @@ struct nlmsgerr {
 #define NETLINK_LISTEN_ALL_NSID		8
 #define NETLINK_LIST_MEMBERSHIPS	9
 #define NETLINK_CAP_ACK			10
+#define NETLINK_EXT_ACK			11
 
 struct nl_pktinfo {
 	__u32	group;
diff --git a/kernel/audit.c b/kernel/audit.c
index e794544f5e63..d5f0e1d92ea2 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1264,7 +1264,7 @@ static void audit_receive_skb(struct sk_buff *skb)
 		err = audit_receive_msg(skb, nlh);
 		/* if err or if this message says it wants a response */
 		if (err || (nlh->nlmsg_flags & NLM_F_ACK))
-			netlink_ack(skb, nlh, err);
+			netlink_ack(skb, nlh, err, NULL);
 
 		nlh = nlmsg_next(nlh, &len);
 	}
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index c4e84c558240..e3e693831e43 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4046,7 +4046,8 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 /* Process one rtnetlink message. */
 
-static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_err *exterr)
 {
 	struct net *net = sock_net(skb->sk);
 	rtnl_doit_func doit;
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 6b10573cc9fa..3348a7b976ce 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -246,7 +246,8 @@ static int __sock_diag_cmd(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return err;
 }
 
-static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_err *exterr)
 {
 	int ret;
 
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 1ab30e7d3f99..81dac16933fc 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -350,7 +350,7 @@ static int hsr_get_node_status(struct sk_buff *skb_in, struct genl_info *info)
 	return 0;
 
 invalid:
-	netlink_ack(skb_in, nlmsg_hdr(skb_in), -EINVAL);
+	netlink_ack(skb_in, nlmsg_hdr(skb_in), -EINVAL, NULL);
 	return 0;
 
 nla_put_failure:
@@ -432,7 +432,7 @@ static int hsr_get_node_list(struct sk_buff *skb_in, struct genl_info *info)
 	return 0;
 
 invalid:
-	netlink_ack(skb_in, nlmsg_hdr(skb_in), -EINVAL);
+	netlink_ack(skb_in, nlmsg_hdr(skb_in), -EINVAL, NULL);
 	return 0;
 
 nla_put_failure:
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index c296f9b606d4..26356bf8cebf 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1305,7 +1305,7 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 			 * manually :-(
 			 */
 			if (nlh->nlmsg_flags & NLM_F_ACK)
-				netlink_ack(cb->skb, nlh, ret);
+				netlink_ack(cb->skb, nlh, ret, NULL);
 			return ret;
 		}
 	}
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 68eda920160e..50f1ef27baab 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -148,7 +148,8 @@ int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u32 portid,
 EXPORT_SYMBOL_GPL(nfnetlink_unicast);
 
 /* Process one complete nfnetlink message. */
-static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_err *exterr)
 {
 	struct net *net = sock_net(skb->sk);
 	const struct nfnl_callback *nc;
@@ -261,7 +262,7 @@ static void nfnl_err_deliver(struct list_head *err_list, struct sk_buff *skb)
 	struct nfnl_err *nfnl_err, *next;
 
 	list_for_each_entry_safe(nfnl_err, next, err_list, head) {
-		netlink_ack(skb, nfnl_err->nlh, nfnl_err->err);
+		netlink_ack(skb, nfnl_err->nlh, nfnl_err->err, NULL);
 		nfnl_err_del(nfnl_err);
 	}
 }
@@ -304,20 +305,20 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 #endif
 		{
 			nfnl_unlock(subsys_id);
-			netlink_ack(oskb, nlh, -EOPNOTSUPP);
+			netlink_ack(oskb, nlh, -EOPNOTSUPP, NULL);
 			return kfree_skb(skb);
 		}
 	}
 
 	if (!ss->commit || !ss->abort) {
 		nfnl_unlock(subsys_id);
-		netlink_ack(oskb, nlh, -EOPNOTSUPP);
+		netlink_ack(oskb, nlh, -EOPNOTSUPP, NULL);
 		return kfree_skb(skb);
 	}
 
 	if (genid && ss->valid_genid && !ss->valid_genid(net, genid)) {
 		nfnl_unlock(subsys_id);
-		netlink_ack(oskb, nlh, -ERESTART);
+		netlink_ack(oskb, nlh, -ERESTART, NULL);
 		return kfree_skb(skb);
 	}
 
@@ -407,7 +408,8 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 				 * pointing to the batch header.
 				 */
 				nfnl_err_reset(&err_list);
-				netlink_ack(oskb, nlmsg_hdr(oskb), -ENOMEM);
+				netlink_ack(oskb, nlmsg_hdr(oskb), -ENOMEM,
+					    NULL);
 				status |= NFNL_BATCH_FAILURE;
 				goto done;
 			}
@@ -467,7 +469,7 @@ static void nfnetlink_rcv_skb_batch(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	err = nla_parse(cda, NFNL_BATCH_MAX, attr, attrlen, nfnl_batch_policy);
 	if (err < 0) {
-		netlink_ack(skb, nlh, err);
+		netlink_ack(skb, nlh, err, NULL);
 		return;
 	}
 	if (cda[NFNL_BATCH_GENID])
@@ -493,7 +495,7 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 		return;
 
 	if (!netlink_net_capable(skb, CAP_NET_ADMIN)) {
-		netlink_ack(skb, nlh, -EPERM);
+		netlink_ack(skb, nlh, -EPERM, NULL);
 		return;
 	}
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7b73c7c161a9..532d906af3be 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -85,6 +85,7 @@ struct listeners {
 #define NETLINK_F_RECV_NO_ENOBUFS	0x8
 #define NETLINK_F_LISTEN_ALL_NSID	0x10
 #define NETLINK_F_CAP_ACK		0x20
+#define NETLINK_F_EXT_ACK		0x40
 
 static inline int netlink_is_kernel(struct sock *sk)
 {
@@ -1619,6 +1620,13 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 			nlk->flags &= ~NETLINK_F_CAP_ACK;
 		err = 0;
 		break;
+	case NETLINK_EXT_ACK:
+		if (val)
+			nlk->flags |= NETLINK_F_EXT_ACK;
+		else
+			nlk->flags &= ~NETLINK_F_EXT_ACK;
+		err = 0;
+		break;
 	default:
 		err = -ENOPROTOOPT;
 	}
@@ -1703,6 +1711,16 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
 			return -EFAULT;
 		err = 0;
 		break;
+	case NETLINK_EXT_ACK:
+		if (len < sizeof(int))
+			return -EINVAL;
+		len = sizeof(int);
+		val = nlk->flags & NETLINK_F_EXT_ACK ? 1 : 0;
+		if (put_user(len, optlen) ||
+		    put_user(val, optval))
+			return -EFAULT;
+		err = 0;
+		break;
 	default:
 		err = -ENOPROTOOPT;
 	}
@@ -2234,7 +2252,8 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(__netlink_dump_start);
 
-void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
+void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
+		 const struct netlink_ext_err *exterr)
 {
 	struct sk_buff *skb;
 	struct nlmsghdr *rep;
@@ -2243,10 +2262,22 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	struct netlink_sock *nlk = nlk_sk(NETLINK_CB(in_skb).sk);
 
 	/* Error messages get the original request appened, unless the user
-	 * requests to cap the error message.
+	 * requests to cap the error message, and get extra error data if
+	 * requested.
 	 */
-	if (!(nlk->flags & NETLINK_F_CAP_ACK) && err)
-		payload += nlmsg_len(nlh);
+	if (err) {
+		if (!(nlk->flags & NETLINK_F_CAP_ACK))
+			payload += nlmsg_len(nlh);
+		if (nlk->flags & NETLINK_F_EXT_ACK) {
+			if (exterr && exterr->msg)
+				payload +=
+					nla_total_size(strlen(exterr->msg) + 1);
+			if (exterr && exterr->msg_offset)
+				payload += nla_total_size(sizeof(u32));
+			if (exterr && exterr->attr)
+				payload += nla_total_size(sizeof(u16));
+		}
+	}
 
 	skb = nlmsg_new(payload, GFP_KERNEL);
 	if (!skb) {
@@ -2268,13 +2299,28 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	errmsg = nlmsg_data(rep);
 	errmsg->error = err;
 	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh->nlmsg_len : sizeof(*nlh));
+
+	if (nlk->flags & NETLINK_F_EXT_ACK) {
+		if (exterr && exterr->msg)
+			WARN_ON(nla_put_string(skb, NLMSGERR_ATTR_MSG,
+					       exterr->msg));
+		if (exterr && exterr->msg_offset)
+			WARN_ON(nla_put_u32(skb, NLMSGERR_ATTR_OFFS,
+					    exterr->msg_offset));
+		if (exterr && exterr->attr)
+			WARN_ON(nla_put_u16(skb, NLMSGERR_ATTR_ATTR,
+					    exterr->attr));
+	}
+
 	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).portid, MSG_DONTWAIT);
 }
 EXPORT_SYMBOL(netlink_ack);
 
 int netlink_rcv_skb(struct sk_buff *skb, int (*cb)(struct sk_buff *,
-						     struct nlmsghdr *))
+						   struct nlmsghdr *,
+						   struct netlink_ext_err *))
 {
+	struct netlink_ext_err exterr = {};
 	struct nlmsghdr *nlh;
 	int err;
 
@@ -2295,13 +2341,13 @@ int netlink_rcv_skb(struct sk_buff *skb, int (*cb)(struct sk_buff *,
 		if (nlh->nlmsg_type < NLMSG_MIN_TYPE)
 			goto ack;
 
-		err = cb(skb, nlh);
+		err = cb(skb, nlh, &exterr);
 		if (err == -EINTR)
 			goto skip;
 
 ack:
 		if (nlh->nlmsg_flags & NLM_F_ACK || err)
-			netlink_ack(skb, nlh, err);
+			netlink_ack(skb, nlh, err, &exterr);
 
 skip:
 		msglen = NLMSG_ALIGN(nlh->nlmsg_len);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index fb6e10fdb217..48f21dc467a7 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -605,7 +605,8 @@ static int genl_family_rcv_msg(const struct genl_family *family,
 	return err;
 }
 
-static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			struct netlink_ext_err *exterr)
 {
 	const struct genl_family *family;
 	int err;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 9705c279494b..de0c672c771b 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2441,7 +2441,8 @@ static const struct xfrm_link {
 	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_spdinfo   },
 };
 
-static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_err *exterr)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *attrs[XFRMA_MAX+1];
-- 
2.11.0

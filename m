From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH net-next v4 1/5] netlink: extended ACK reporting
Date: Tue, 11 Apr 2017 08:56:56 +0200
Message-ID: <20170411065700.2623-2-johannes@sipsolutions.net>
References: <20170411065700.2623-1-johannes@sipsolutions.net>
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>, jiri@resnulli.us,
        Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:47282 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752359AbdDKG5I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 02:57:08 -0400
In-Reply-To: <20170411065700.2623-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Add the base infrastructure and UAPI for netlink
extended ACK reporting. All "manual" calls to
netlink_ack() pass NULL for now and thus don't
get extended ACK reporting.

Big thanks goes to Pablo Neira Ayuso for not only
bringing up the whole topic at netconf (again) but
also coming up with the nlattr passing trick and
various other ideads.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 crypto/crypto_user.c              |  3 +-
 drivers/infiniband/core/netlink.c |  5 +--
 drivers/scsi/scsi_netlink.c       |  2 +-
 include/linux/netlink.h           | 26 +++++++++++++-
 include/net/netlink.h             |  3 +-
 include/uapi/linux/netlink.h      | 32 ++++++++++++++++++
 kernel/audit.c                    |  2 +-
 net/core/rtnetlink.c              |  3 +-
 net/core/sock_diag.c              |  3 +-
 net/decnet/netfilter/dn_rtmsg.c   |  2 +-
 net/hsr/hsr_netlink.c             |  4 +--
 net/netfilter/ipset/ip_set_core.c |  2 +-
 net/netfilter/nfnetlink.c         | 22 ++++++------
 net/netlink/af_netlink.c          | 71 ++++++++++++++++++++++++++++++++++-----
 net/netlink/af_netlink.h          |  1 +
 net/netlink/genetlink.c           |  3 +-
 net/xfrm/xfrm_user.c              |  3 +-
 17 files changed, 153 insertions(+), 34 deletions(-)

diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
index a90404a0c5ff..4a44830741c1 100644
--- a/crypto/crypto_user.c
+++ b/crypto/crypto_user.c
@@ -483,7 +483,8 @@ static const struct crypto_link {
 	[CRYPTO_MSG_DELRNG	- CRYPTO_MSG_BASE] = { .doit = crypto_del_rng },
 };
 
-static int crypto_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int crypto_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			       struct netlink_ext_ack *extack)
 {
 	struct nlattr *attrs[CRYPTOCFGA_MAX+1];
 	const struct crypto_link *link;
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 10469b0088b5..b784055423c8 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -146,7 +146,8 @@ int ibnl_put_attr(struct sk_buff *skb, struct nlmsghdr *nlh,
 }
 EXPORT_SYMBOL(ibnl_put_attr);
 
-static int ibnl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int ibnl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			struct netlink_ext_ack *extack)
 {
 	struct ibnl_client *client;
 	int type = nlh->nlmsg_type;
@@ -209,7 +210,7 @@ static void ibnl_rcv_reply_skb(struct sk_buff *skb)
 		if (nlh->nlmsg_flags & NLM_F_REQUEST)
 			return;
 
-		ibnl_rcv_msg(skb, nlh);
+		ibnl_rcv_msg(skb, nlh, NULL);
 
 		msglen = NLMSG_ALIGN(nlh->nlmsg_len);
 		if (msglen > skb->len)
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
index da14ab61f363..60e7137f840d 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -62,11 +62,35 @@ netlink_kernel_create(struct net *net, int unit, struct netlink_kernel_cfg *cfg)
 	return __netlink_kernel_create(net, unit, THIS_MODULE, cfg);
 }
 
+/**
+ * struct netlink_ext_ack - netlink extended ACK report struct
+ * @_msg: message string to report - don't access directly, use
+ *	%NL_SET_ERR_MSG
+ * @bad_attr: attribute with error
+ */
+struct netlink_ext_ack {
+	const char *_msg;
+	const struct nlattr *bad_attr;
+};
+
+/* Always use this macro, this allows later putting the
+ * message into a separate section or such for things
+ * like translation or listing all possible messages.
+ * Currently string formatting is not supported (due
+ * to the lack of an output buffer.)
+ */
+#define NL_SET_ERR_MSG(extack, msg) do {	\
+	static const char _msg[] = (msg);	\
+						\
+	(extack)->_msg = _msg;			\
+} while (0)
+
 extern void netlink_kernel_release(struct sock *sk);
 extern int __netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern int netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern void __netlink_clear_multicast_users(struct sock *sk, unsigned int group);
-extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
+extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
+			const struct netlink_ext_ack *extack);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 portid, int nonblock);
diff --git a/include/net/netlink.h b/include/net/netlink.h
index b239fcd33d80..a064ec3e2ee1 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -233,7 +233,8 @@ struct nl_info {
 };
 
 int netlink_rcv_skb(struct sk_buff *skb,
-		    int (*cb)(struct sk_buff *, struct nlmsghdr *));
+		    int (*cb)(struct sk_buff *, struct nlmsghdr *,
+			      struct netlink_ext_ack *));
 int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 portid,
 		 unsigned int group, int report, gfp_t flags);
 
diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index b2c9c26ea30f..96e613db68cb 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -69,6 +69,10 @@ struct nlmsghdr {
 #define NLM_F_CREATE	0x400	/* Create, if it does not exist	*/
 #define NLM_F_APPEND	0x800	/* Add to end of list		*/
 
+/* Flags for ACK message */
+#define NLM_F_CAPPED	0x100	/* request was capped */
+#define NLM_F_ACK_TLVS	0x200	/* extended ACK TVLs were included */
+
 /*
    4.4BSD ADD		NLM_F_CREATE|NLM_F_EXCL
    4.4BSD CHANGE	NLM_F_REPLACE
@@ -101,6 +105,33 @@ struct nlmsghdr {
 struct nlmsgerr {
 	int		error;
 	struct nlmsghdr msg;
+	/*
+	 * followed by the message contents unless NETLINK_CAP_ACK was set
+	 * or the ACK indicates success (error == 0)
+	 * message length is aligned with NLMSG_ALIGN()
+	 */
+	/*
+	 * followed by TLVs defined in enum nlmsgerr_attrs
+	 * if NETLINK_EXT_ACK was set
+	 */
+};
+
+/**
+ * enum nlmsgerr_attrs - nlmsgerr attributes
+ * @NLMSGERR_ATTR_UNUSED: unused
+ * @NLMSGERR_ATTR_MSG: error message string (string)
+ * @NLMSGERR_ATTR_OFFS: offset of the invalid attribute in the original
+ *	 message, counting from the beginning of the header (u32)
+ * @NUM_NLMSGERR_ATTRS: number of attributes
+ * @NLMSGERR_ATTR_MAX: highest attribute number
+ */
+enum nlmsgerr_attrs {
+	NLMSGERR_ATTR_UNUSED,
+	NLMSGERR_ATTR_MSG,
+	NLMSGERR_ATTR_OFFS,
+
+	NUM_NLMSGERR_ATTRS,
+	NLMSGERR_ATTR_MAX = NUM_NLMSGERR_ATTRS - 1
 };
 
 #define NETLINK_ADD_MEMBERSHIP		1
@@ -115,6 +146,7 @@ struct nlmsgerr {
 #define NETLINK_LISTEN_ALL_NSID		8
 #define NETLINK_LIST_MEMBERSHIPS	9
 #define NETLINK_CAP_ACK			10
+#define NETLINK_EXT_ACK			11
 
 struct nl_pktinfo {
 	__u32	group;
diff --git a/kernel/audit.c b/kernel/audit.c
index 2f4964cfde0b..d54bf5932374 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1402,7 +1402,7 @@ static void audit_receive_skb(struct sk_buff *skb)
 		err = audit_receive_msg(skb, nlh);
 		/* if err or if this message says it wants a response */
 		if (err || (nlh->nlmsg_flags & NLM_F_ACK))
-			netlink_ack(skb, nlh, err);
+			netlink_ack(skb, nlh, err, NULL);
 
 		nlh = nlmsg_next(nlh, &len);
 	}
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 58419da7961b..09a2e86f7b92 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4046,7 +4046,8 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 /* Process one rtnetlink message. */
 
-static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	rtnl_doit_func doit;
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index fb9d0e2fd148..217f4e3b82f6 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -238,7 +238,8 @@ static int __sock_diag_cmd(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return err;
 }
 
-static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
 {
 	int ret;
 
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 85f2fdc360c2..c8bf5136a72b 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -96,7 +96,7 @@ static unsigned int dnrmg_hook(void *priv,
 }
 
 
-#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } while (0)
+#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err), NULL); return; } while (0)
 
 static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
 {
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
index 68eda920160e..181d3bb800e6 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -148,7 +148,8 @@ int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u32 portid,
 EXPORT_SYMBOL_GPL(nfnetlink_unicast);
 
 /* Process one complete nfnetlink message. */
-static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
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
@@ -284,13 +285,13 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 	int err;
 
 	if (subsys_id >= NFNL_SUBSYS_COUNT)
-		return netlink_ack(skb, nlh, -EINVAL);
+		return netlink_ack(skb, nlh, -EINVAL, NULL);
 replay:
 	status = 0;
 
 	skb = netlink_skb_clone(oskb, GFP_KERNEL);
 	if (!skb)
-		return netlink_ack(oskb, nlh, -ENOMEM);
+		return netlink_ack(oskb, nlh, -ENOMEM, NULL);
 
 	nfnl_lock(subsys_id);
 	ss = nfnl_dereference_protected(subsys_id);
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
index fc232441cf23..c1564768000e 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1652,6 +1652,13 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
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
@@ -1736,6 +1743,15 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
 			return -EFAULT;
 		err = 0;
 		break;
+	case NETLINK_EXT_ACK:
+		if (len < sizeof(int))
+			return -EINVAL;
+		len = sizeof(int);
+		val = nlk->flags & NETLINK_F_EXT_ACK ? 1 : 0;
+		if (put_user(len, optlen) || put_user(val, optval))
+			return -EFAULT;
+		err = 0;
+		break;
 	default:
 		err = -ENOPROTOOPT;
 	}
@@ -2267,21 +2283,40 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(__netlink_dump_start);
 
-void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
+void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
+		 const struct netlink_ext_ack *extack)
 {
 	struct sk_buff *skb;
 	struct nlmsghdr *rep;
 	struct nlmsgerr *errmsg;
 	size_t payload = sizeof(*errmsg);
+	size_t tlvlen = 0;
 	struct netlink_sock *nlk = nlk_sk(NETLINK_CB(in_skb).sk);
+	unsigned int flags = 0;
 
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
+		else
+			flags |= NLM_F_CAPPED;
+		if (nlk->flags & NETLINK_F_EXT_ACK && extack) {
+			if (extack->_msg)
+				tlvlen += nla_total_size(strlen(extack->_msg) + 1);
+			if (extack->bad_attr)
+				tlvlen += nla_total_size(sizeof(u32));
+		}
+	} else {
+		flags |= NLM_F_CAPPED;
+	}
 
-	skb = nlmsg_new(payload, GFP_KERNEL);
+	if (tlvlen)
+		flags |= NLM_F_ACK_TLVS;
+
+	skb = nlmsg_new(payload + tlvlen, GFP_KERNEL);
 	if (!skb) {
 		struct sock *sk;
 
@@ -2297,17 +2332,35 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	}
 
 	rep = __nlmsg_put(skb, NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
-			  NLMSG_ERROR, payload, 0);
+			  NLMSG_ERROR, payload, flags);
 	errmsg = nlmsg_data(rep);
 	errmsg->error = err;
 	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh->nlmsg_len : sizeof(*nlh));
+
+	if (err && nlk->flags & NETLINK_F_EXT_ACK && extack) {
+		if (extack->_msg)
+			WARN_ON(nla_put_string(skb, NLMSGERR_ATTR_MSG,
+					       extack->_msg));
+		if (extack->bad_attr &&
+		    !WARN_ON((u8 *)extack->bad_attr < in_skb->data ||
+			     (u8 *)extack->bad_attr >= in_skb->data +
+						       in_skb->len))
+			WARN_ON(nla_put_u32(skb, NLMSGERR_ATTR_OFFS,
+					    (u8 *)extack->bad_attr -
+					    in_skb->data));
+	}
+
+	nlmsg_end(skb, rep);
+
 	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).portid, MSG_DONTWAIT);
 }
 EXPORT_SYMBOL(netlink_ack);
 
 int netlink_rcv_skb(struct sk_buff *skb, int (*cb)(struct sk_buff *,
-						     struct nlmsghdr *))
+						   struct nlmsghdr *,
+						   struct netlink_ext_ack *))
 {
+	struct netlink_ext_ack extack = {};
 	struct nlmsghdr *nlh;
 	int err;
 
@@ -2328,13 +2381,13 @@ int netlink_rcv_skb(struct sk_buff *skb, int (*cb)(struct sk_buff *,
 		if (nlh->nlmsg_type < NLMSG_MIN_TYPE)
 			goto ack;
 
-		err = cb(skb, nlh);
+		err = cb(skb, nlh, &extack);
 		if (err == -EINTR)
 			goto skip;
 
 ack:
 		if (nlh->nlmsg_flags & NLM_F_ACK || err)
-			netlink_ack(skb, nlh, err);
+			netlink_ack(skb, nlh, err, &extack);
 
 skip:
 		msglen = NLMSG_ALIGN(nlh->nlmsg_len);
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index f792f8d7f982..3490f2430532 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -13,6 +13,7 @@
 #define NETLINK_F_RECV_NO_ENOBUFS	0x8
 #define NETLINK_F_LISTEN_ALL_NSID	0x10
 #define NETLINK_F_CAP_ACK		0x20
+#define NETLINK_F_EXT_ACK		0x40
 
 #define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
 #define NLGRPLONGS(x)	(NLGRPSZ(x)/sizeof(unsigned long))
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 92e0981f7404..57b2e3648bc0 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -605,7 +605,8 @@ static int genl_family_rcv_msg(const struct genl_family *family,
 	return err;
 }
 
-static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			struct netlink_ext_ack *extack)
 {
 	const struct genl_family *family;
 	int err;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 40a8aa39220d..1ba8c115a993 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2448,7 +2448,8 @@ static const struct xfrm_link {
 	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_spdinfo   },
 };
 
-static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *attrs[XFRMA_MAX+1];
-- 
2.11.0

From: Jiri Benc <jbenc@redhat.com>
Subject: [RFC PATCH net-next 1/9] netlink: add NLM_F_STRICT for strict attribute checking
Date: Thu, 15 Oct 2015 18:39:06 +0200
Message-ID: <7631c32889e520fcc0da8c7898978b20e8453884.1444926905.git.jbenc@redhat.com>
References: <cover.1444926905.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44282 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751815AbbJOQjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 12:39:36 -0400
In-Reply-To: <cover.1444926905.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When NLM_F_STRICT flag is set in a request, the message should undergo
stricter check for compatibility with the current kernel, or EPROTO should
be returned if such check could not be performed. In addition, NLM_F_STRICT
is set in error/ack reply to a request with this flag set.

For now, always return EPROTO.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 crypto/crypto_user.c              |  2 +-
 drivers/infiniband/core/netlink.c |  2 +-
 include/net/netlink.h             |  2 +-
 include/uapi/linux/netlink.h      |  1 +
 net/core/rtnetlink.c              |  2 +-
 net/core/sock_diag.c              |  2 +-
 net/netfilter/nfnetlink.c         |  6 +++++-
 net/netlink/af_netlink.c          | 14 +++++++++++---
 net/netlink/genetlink.c           |  2 +-
 net/xfrm/xfrm_user.c              |  2 +-
 10 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
index d94d99ffe8b9..8d46d3b69bee 100644
--- a/crypto/crypto_user.c
+++ b/crypto/crypto_user.c
@@ -526,7 +526,7 @@ static int crypto_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 static void crypto_netlink_rcv(struct sk_buff *skb)
 {
 	mutex_lock(&crypto_cfg_mutex);
-	netlink_rcv_skb(skb, &crypto_user_rcv_msg);
+	netlink_rcv_skb(skb, false, &crypto_user_rcv_msg);
 	mutex_unlock(&crypto_cfg_mutex);
 }
 
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index d47df9356779..1429c0cf583b 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -223,7 +223,7 @@ static void ibnl_rcv(struct sk_buff *skb)
 {
 	mutex_lock(&ibnl_mutex);
 	ibnl_rcv_reply_skb(skb);
-	netlink_rcv_skb(skb, &ibnl_rcv_msg);
+	netlink_rcv_skb(skb, false, &ibnl_rcv_msg);
 	mutex_unlock(&ibnl_mutex);
 }
 
diff --git a/include/net/netlink.h b/include/net/netlink.h
index 0e3172751755..160e98cea304 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -228,7 +228,7 @@ struct nl_info {
 	u32			portid;
 };
 
-int netlink_rcv_skb(struct sk_buff *skb,
+int netlink_rcv_skb(struct sk_buff *skb, bool strict_supported,
 		    int (*cb)(struct sk_buff *, struct nlmsghdr *));
 int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 portid,
 		 unsigned int group, int report, gfp_t flags);
diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index f095155d8749..c001551fcedd 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -55,6 +55,7 @@ struct nlmsghdr {
 #define NLM_F_ECHO		8	/* Echo this request 		*/
 #define NLM_F_DUMP_INTR		16	/* Dump was inconsistent due to sequence change */
 #define NLM_F_DUMP_FILTERED	32	/* Dump was filtered as requested */
+#define NLM_F_STRICT		64	/* Fail if an attr is unsupported */
 
 /* Modifiers to GET request */
 #define NLM_F_ROOT	0x100	/* specify tree	root	*/
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 24775953fa68..afb41c7492b4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3356,7 +3356,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 static void rtnetlink_rcv(struct sk_buff *skb)
 {
 	rtnl_lock();
-	netlink_rcv_skb(skb, &rtnetlink_rcv_msg);
+	netlink_rcv_skb(skb, false, &rtnetlink_rcv_msg);
 	rtnl_unlock();
 }
 
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 0c1d58d43f67..3aac827d1d67 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -272,7 +272,7 @@ static DEFINE_MUTEX(sock_diag_mutex);
 static void sock_diag_rcv(struct sk_buff *skb)
 {
 	mutex_lock(&sock_diag_mutex);
-	netlink_rcv_skb(skb, &sock_diag_rcv_msg);
+	netlink_rcv_skb(skb, false, &sock_diag_rcv_msg);
 	mutex_unlock(&sock_diag_mutex);
 }
 
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index f1d9e887f5b1..f7588dec4d23 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -339,6 +339,10 @@ replay:
 			err = -EINVAL;
 			goto ack;
 		}
+		if (nlh->nlmsg_flags & NLM_F_STRICT) {
+			err = -EPROTO;
+			goto ack;
+		}
 
 		type = nlh->nlmsg_type;
 		if (type == NFNL_MSG_BATCH_BEGIN) {
@@ -476,7 +480,7 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 			res_id = ntohs(nfgenmsg->res_id);
 		nfnetlink_rcv_batch(skb, nlh, res_id);
 	} else {
-		netlink_rcv_skb(skb, &nfnetlink_rcv_msg);
+		netlink_rcv_skb(skb, false, &nfnetlink_rcv_msg);
 	}
 }
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8f060d7f9a0e..d59d02038128 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2944,6 +2944,7 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	struct nlmsgerr *errmsg;
 	size_t payload = sizeof(*errmsg);
 	struct netlink_sock *nlk = nlk_sk(NETLINK_CB(in_skb).sk);
+	unsigned int flags = 0;
 
 	/* Error messages get the original request appened, unless the user
 	 * requests to cap the error message.
@@ -2967,8 +2968,10 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 		return;
 	}
 
+	if (nlh->nlmsg_flags & NLM_F_STRICT)
+		flags |= NLM_F_STRICT;
 	rep = __nlmsg_put(skb, NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
-			  NLMSG_ERROR, payload, 0);
+			  NLMSG_ERROR, payload, flags);
 	errmsg = nlmsg_data(rep);
 	errmsg->error = err;
 	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh->nlmsg_len : sizeof(*nlh));
@@ -2976,8 +2979,8 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 }
 EXPORT_SYMBOL(netlink_ack);
 
-int netlink_rcv_skb(struct sk_buff *skb, int (*cb)(struct sk_buff *,
-						     struct nlmsghdr *))
+int netlink_rcv_skb(struct sk_buff *skb, bool strict_supported,
+		    int (*cb)(struct sk_buff *, struct nlmsghdr *))
 {
 	struct nlmsghdr *nlh;
 	int err;
@@ -2995,6 +2998,11 @@ int netlink_rcv_skb(struct sk_buff *skb, int (*cb)(struct sk_buff *,
 		if (!(nlh->nlmsg_flags & NLM_F_REQUEST))
 			goto ack;
 
+		if (!strict_supported && (nlh->nlmsg_flags & NLM_F_STRICT)) {
+			err = -EPROTO;
+			goto ack;
+		}
+
 		/* Skip control messages */
 		if (nlh->nlmsg_type < NLMSG_MIN_TYPE)
 			goto ack;
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index bc0e504f33a6..d7bf14420c9e 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -667,7 +667,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 static void genl_rcv(struct sk_buff *skb)
 {
 	down_read(&cb_lock);
-	netlink_rcv_skb(skb, &genl_rcv_msg);
+	netlink_rcv_skb(skb, false, &genl_rcv_msg);
 	up_read(&cb_lock);
 }
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index a8de9e300200..bcde073f59db 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2491,7 +2491,7 @@ static void xfrm_netlink_rcv(struct sk_buff *skb)
 	struct net *net = sock_net(skb->sk);
 
 	mutex_lock(&net->xfrm.xfrm_cfg_mutex);
-	netlink_rcv_skb(skb, &xfrm_user_rcv_msg);
+	netlink_rcv_skb(skb, false, &xfrm_user_rcv_msg);
 	mutex_unlock(&net->xfrm.xfrm_cfg_mutex);
 }
 
-- 
1.8.3.1

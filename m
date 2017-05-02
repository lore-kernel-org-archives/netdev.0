From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next iproute2 2/3] netlink: Add support for extended ack to rtnl_talk
Date: Mon,  1 May 2017 20:18:24 -0700
Message-ID: <1493695105-9418-3-git-send-email-dsa@cumulusnetworks.com>
References: <1493695105-9418-1-git-send-email-dsa@cumulusnetworks.com>
Cc: jakub.kicinski@netronome.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35106 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751152AbdEBDSc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 23:18:32 -0400
Received: by mail-pf0-f170.google.com with SMTP id v14so82507447pfd.2
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 20:18:31 -0700 (PDT)
In-Reply-To: <1493695105-9418-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for extended ack error reporting.

Add a new function rtnl_talk_extack that takes a callback as an input
arg. If a netlink response contains extack attributes, the callback is
is invoked with the the err string, offset in the message and a pointer
to the message returned by the kernel.

Adding a new function allows commands to be moved over to the
extended error reporting over time.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/libnetlink.h |  6 ++++
 lib/libnetlink.c     | 92 ++++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 91 insertions(+), 7 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index e7c46f1870aa..6b031454ce2b 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -71,6 +71,9 @@ typedef int (*rtnl_listen_filter_t)(const struct sockaddr_nl *,
 				    struct rtnl_ctrl_data *,
 				    struct nlmsghdr *n, void *);
 
+typedef int (*nl_ext_ack_fn_t)(const char *errmsg, __u32 off,
+			       struct nlmsghdr *inner_nlh);
+
 struct rtnl_dump_filter_arg {
 	rtnl_filter_t filter;
 	void *arg1;
@@ -87,6 +90,9 @@ int rtnl_dump_filter_nc(struct rtnl_handle *rth,
 int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 	      struct nlmsghdr *answer, size_t len)
 	__attribute__((warn_unused_result));
+int rtnl_talk_extack(struct rtnl_handle *rtnl, struct nlmsghdr *n,
+	      struct nlmsghdr *answer, size_t len, nl_ext_ack_fn_t errfn)
+	__attribute__((warn_unused_result));
 int rtnl_talk_suppress_rtnl_errmsg(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 				   struct nlmsghdr *answer, size_t len)
 	__attribute__((warn_unused_result));
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index b5ee751c6b86..f6451dec1332 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -32,6 +32,61 @@
 
 int rcvbuf = 1024 * 1024;
 
+/* dump netlink extended ack error message */
+static int nl_dump_ext_err(struct nlmsghdr *nlh, nl_ext_ack_fn_t errfn)
+{
+	const struct nla_policy extack_policy[NLMSGERR_ATTR_MAX + 1] = {
+		[NLMSGERR_ATTR_MSG]	= { .type = NLA_STRING },
+		[NLMSGERR_ATTR_OFFS]	= { .type = NLA_U32 },
+	};
+	struct nlattr *tb[NLMSGERR_ATTR_MAX + 1], *attr;
+	struct nlmsghdr *err_nlh = NULL;
+	struct nlmsgerr *err;
+	char *errmsg = NULL;
+	int hlen, alen;
+	__u32 off = 0;
+
+	if (!errfn)
+		return 0;
+
+	/* no TLVs, nothing to do here */
+	if (!(nlh->nlmsg_flags & NLM_F_ACK_TLVS))
+		return 0;
+
+	err = (struct nlmsgerr *)NLMSG_DATA(nlh);
+	hlen = sizeof(*err);
+
+	/* if NLM_F_CAPPED is set then the inner err msg was capped */
+	if (!(nlh->nlmsg_flags & NLM_F_CAPPED))
+		hlen += nlmsg_len(&err->msg);
+
+	attr = (struct nlattr *) ((void *) err + hlen);
+	alen = nlh->nlmsg_len - hlen;
+
+	if (nla_parse(tb, NLMSGERR_ATTR_MAX, attr, alen, extack_policy) != 0) {
+		fprintf(stderr,
+			"Failed to parse extended error attributes\n");
+		return 0;
+	}
+
+
+	if (tb[NLMSGERR_ATTR_MSG])
+		errmsg = (char *) nla_data(tb[NLMSGERR_ATTR_MSG]);
+
+	if (tb[NLMSGERR_ATTR_OFFS]) {
+		off = nla_get_u32(tb[NLMSGERR_ATTR_OFFS]);
+
+		if (off > nlh->nlmsg_len) {
+			fprintf(stderr,
+				"Invalid offset for NLMSGERR_ATTR_OFFS\n");
+			off = 0;
+		} else if (!(nlh->nlmsg_flags & NLM_F_CAPPED))
+			err_nlh = &err->msg;
+	}
+
+	return errfn(errmsg, off, err_nlh);
+}
+
 void rtnl_close(struct rtnl_handle *rth)
 {
 	if (rth->fd >= 0) {
@@ -45,6 +100,7 @@ int rtnl_open_byproto(struct rtnl_handle *rth, unsigned int subscriptions,
 {
 	socklen_t addr_len;
 	int sndbuf = 32768;
+	int one = 1;
 
 	memset(rth, 0, sizeof(*rth));
 
@@ -67,6 +123,11 @@ int rtnl_open_byproto(struct rtnl_handle *rth, unsigned int subscriptions,
 		return -1;
 	}
 
+	if (setsockopt(rth->fd, SOL_NETLINK, NETLINK_EXT_ACK,
+		       &one, sizeof(one)) < 0) {
+		/* debug/verbose message that it is not supported */
+	}
+
 	memset(&rth->local, 0, sizeof(rth->local));
 	rth->local.nl_family = AF_NETLINK;
 	rth->local.nl_groups = subscriptions;
@@ -413,9 +474,19 @@ int rtnl_dump_filter_nc(struct rtnl_handle *rth,
 	return rtnl_dump_filter_l(rth, a);
 }
 
+static void rtnl_talk_error(struct nlmsghdr *h, struct nlmsgerr *err,
+			    nl_ext_ack_fn_t errfn)
+{
+	if (nl_dump_ext_err(h, errfn))
+		return;
+
+	fprintf(stderr, "RTNETLINK answers: %s\n",
+		strerror(-err->error));
+}
+
 static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 		       struct nlmsghdr *answer, size_t maxlen,
-		       bool show_rtnl_err)
+		       bool show_rtnl_err, nl_ext_ack_fn_t errfn)
 {
 	int status;
 	unsigned int seq;
@@ -502,10 +573,10 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 					return 0;
 				}
 
-				if (rtnl->proto != NETLINK_SOCK_DIAG && show_rtnl_err)
-					fprintf(stderr,
-						"RTNETLINK answers: %s\n",
-						strerror(-err->error));
+				if (rtnl->proto != NETLINK_SOCK_DIAG &&
+				    show_rtnl_err)
+					rtnl_talk_error(h, err, errfn);
+
 				errno = -err->error;
 				return -1;
 			}
@@ -537,13 +608,20 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 	      struct nlmsghdr *answer, size_t maxlen)
 {
-	return __rtnl_talk(rtnl, n, answer, maxlen, true);
+	return __rtnl_talk(rtnl, n, answer, maxlen, true, NULL);
+}
+
+int rtnl_talk_extack(struct rtnl_handle *rtnl, struct nlmsghdr *n,
+		     struct nlmsghdr *answer, size_t maxlen,
+		     nl_ext_ack_fn_t errfn)
+{
+	return __rtnl_talk(rtnl, n, answer, maxlen, true, errfn);
 }
 
 int rtnl_talk_suppress_rtnl_errmsg(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 				   struct nlmsghdr *answer, size_t maxlen)
 {
-	return __rtnl_talk(rtnl, n, answer, maxlen, false);
+	return __rtnl_talk(rtnl, n, answer, maxlen, false, NULL);
 }
 
 int rtnl_listen_all_nsid(struct rtnl_handle *rth)
-- 
2.1.4

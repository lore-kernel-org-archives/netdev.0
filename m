From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Wed,  3 May 2017 16:56:38 -0700
Message-ID: <20170503235638.31116-1-stephen@networkplumber.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36363 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751233AbdECX4r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:56:47 -0400
Received: by mail-pf0-f181.google.com with SMTP id q66so2199192pfi.3
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:56:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for extended ack error reporting via libmnl. This
is a better alternative to use existing library and not copy/paste
code from the kernel. Also make arguments const where possible.

Add a new function rtnl_talk_extack that takes a callback as an input
arg. If a netlink response contains extack attributes, the callback is
is invoked with the the err string, offset in the message and a pointer
to the message returned by the kernel.

Adding a new function allows commands to be moved over to the
extended error reporting over time.

For feedback, compile tested only.

---
 include/libnetlink.h |   6 +++
 lib/Makefile         |   7 ++++
 lib/libnetlink.c     | 110 +++++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 116 insertions(+), 7 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index c43ab0a2d9d9..32d5177cd1ab 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -66,6 +66,9 @@ typedef int (*rtnl_listen_filter_t)(const struct sockaddr_nl *,
 				    struct rtnl_ctrl_data *,
 				    struct nlmsghdr *n, void *);
 
+typedef int (*nl_ext_ack_fn_t)(const char *errmsg, uint32_t off,
+			       const struct nlmsghdr *inner_nlh);
+
 struct rtnl_dump_filter_arg {
 	rtnl_filter_t filter;
 	void *arg1;
@@ -82,6 +85,9 @@ int rtnl_dump_filter_nc(struct rtnl_handle *rth,
 int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 	      struct nlmsghdr *answer, size_t len)
 	__attribute__((warn_unused_result));
+int rtnl_talk_extack(struct rtnl_handle *rtnl, struct nlmsghdr *n,
+	      struct nlmsghdr *answer, size_t len, nl_ext_ack_fn_t errfn)
+	__attribute__((warn_unused_result));
 int rtnl_talk_suppress_rtnl_errmsg(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 				   struct nlmsghdr *answer, size_t len)
 	__attribute__((warn_unused_result));
diff --git a/lib/Makefile b/lib/Makefile
index 1d24ca24b9a3..f81888cca974 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -4,6 +4,13 @@ ifeq ($(IP_CONFIG_SETNS),y)
 	CFLAGS += -DHAVE_SETNS
 endif
 
+ifeq ($(HAVE_MNL),y)
+	CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
+	LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
+else
+@warn "libmnl required for error support"
+endif
+
 CFLAGS += -fPIC
 
 UTILOBJ = utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o \
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 5b75b2db4e0b..20ec7fe20d7c 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -36,6 +36,79 @@
 
 int rcvbuf = 1024 * 1024;
 
+#ifdef HAVE_LIBMNL
+#include <libmnl/libmnl.h>
+
+static const enum mnl_attr_data_type extack_policy[NLMSGERR_ATTR_MAX + 1] = {
+	[NLMSGERR_ATTR_MSG]	= MNL_TYPE_NUL_STRING,
+	[NLMSGERR_ATTR_OFFS]	= MNL_TYPE_U32,
+};
+
+static int err_attr_cb(const struct nlattr *attr, void *data)
+{
+	const struct nlattr **tb = data;
+	uint16_t type;
+
+	if (mnl_attr_type_valid(attr, NLMSGERR_ATTR_MAX) < 0)
+		return MNL_CB_ERROR;
+
+	type = mnl_attr_get_type(attr);
+	if (mnl_attr_validate(attr, extack_policy[type]) < 0)
+		return MNL_CB_ERROR;
+
+
+	tb[type] = attr;
+	return MNL_CB_OK;
+}
+
+
+/* dump netlink extended ack error message */
+static int nl_dump_ext_err(const struct nlmsghdr *nlh, nl_ext_ack_fn_t errfn)
+{
+	struct nlattr *tb[NLMSGERR_ATTR_MAX + 1];
+	const struct nlmsgerr *err = mnl_nlmsg_get_payload(nlh);
+	const struct nlmsghdr *err_nlh = NULL;
+	unsigned int hlen = sizeof(*err);
+	const char *errmsg = NULL;
+	uint32_t off = 0;
+
+	if (!errfn)
+		return 0;
+
+	/* no TLVs, nothing to do here */
+	if (!(nlh->nlmsg_flags & NLM_F_ACK_TLVS))
+		return 0;
+
+	/* if NLM_F_CAPPED is set then the inner err msg was capped */
+	if (!(nlh->nlmsg_flags & NLM_F_CAPPED))
+		hlen += mnl_nlmsg_get_payload_len(&err->msg);
+
+	mnl_attr_parse(nlh, hlen, err_attr_cb, tb);
+
+	if (tb[NLMSGERR_ATTR_MSG])
+		errmsg = mnl_attr_get_str(tb[NLMSGERR_ATTR_MSG]);
+
+	if (tb[NLMSGERR_ATTR_OFFS]) {
+		off = mnl_attr_get_u32(tb[NLMSGERR_ATTR_OFFS]);
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
+#else
+/* No extended error ack without libmnl */
+static int nl_dump_ext_err(const struct nlmsghdr *nlh, nl_ext_ack_fn_t errfn)
+{
+	return 0;
+}
+#endif
+
 void rtnl_close(struct rtnl_handle *rth)
 {
 	if (rth->fd >= 0) {
@@ -49,6 +122,7 @@ int rtnl_open_byproto(struct rtnl_handle *rth, unsigned int subscriptions,
 {
 	socklen_t addr_len;
 	int sndbuf = 32768;
+	int one = 1;
 
 	memset(rth, 0, sizeof(*rth));
 
@@ -71,6 +145,11 @@ int rtnl_open_byproto(struct rtnl_handle *rth, unsigned int subscriptions,
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
@@ -417,9 +496,19 @@ int rtnl_dump_filter_nc(struct rtnl_handle *rth,
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
@@ -506,10 +595,10 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
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
@@ -541,13 +630,20 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
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
2.11.0

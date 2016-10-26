From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC net-next iproute2 2/2] ss: Add inet raw sockets information gathering via netlink diag interface
Date: Wed, 26 Oct 2016 22:30:08 +0300
Message-ID: <1477510208-20292-3-git-send-email-gorcunov@gmail.com>
References: <1477510208-20292-1-git-send-email-gorcunov@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Andrey Vagin <avagin@openvz.org>,
        Cyrill Gorcunov <gorcunov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34057 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752427AbcJZTaZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 15:30:25 -0400
Received: by mail-lf0-f66.google.com with SMTP id i187so52951lfe.1
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 12:30:24 -0700 (PDT)
In-Reply-To: <1477510208-20292-1-git-send-email-gorcunov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

unix, tcp, udp[lite], packet, netlink sockets already support diag
interface for their collection and killing. Now with commit XXX
this facility is implemented for raw sockets.

Signed-off-by: Cyrill Gorcunov <gorcunov@gmail.com>
---
 include/linux/inet_diag.h | 15 +++++++++++++++
 misc/ss.c                 | 20 ++++++++++++++++++--
 2 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index f5f5c1b..ac66148 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -43,6 +43,21 @@ struct inet_diag_req_v2 {
 	struct inet_diag_sockid id;
 };
 
+/*
+ * An alias for struct inet_diag_req_v2,
+ * @sdiag_raw_protocol member shadows
+ * @pad explicitly, it is done this way
+ * for backward compatibility sake.
+ */
+struct inet_diag_req_raw {
+	__u8	sdiag_family;
+	__u8	sdiag_protocol;
+	__u8	idiag_ext;
+	__u8	sdiag_raw_protocol;
+	__u32	idiag_states;
+	struct inet_diag_sockid id;
+};
+
 enum {
 	INET_DIAG_REQ_NONE,
 	INET_DIAG_REQ_BYTECODE,
diff --git a/misc/ss.c b/misc/ss.c
index dd77b81..e8c4010 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -724,6 +724,7 @@ struct sockstat {
 	struct sockstat	   *next;
 	unsigned int	    type;
 	uint16_t	    prot;
+	uint16_t	    raw_prot;
 	inet_prefix	    local;
 	inet_prefix	    remote;
 	int		    lport;
@@ -2190,6 +2191,10 @@ static void parse_diag_msg(struct nlmsghdr *nlh, struct sockstat *s)
 	s->mark = 0;
 	if (tb[INET_DIAG_MARK])
 		s->mark = *(__u32 *) RTA_DATA(tb[INET_DIAG_MARK]);
+	if (tb[INET_DIAG_PROTOCOL])
+		s->raw_prot = *(__u8 *)RTA_DATA(tb[INET_DIAG_PROTOCOL]);
+	else
+		s->raw_prot = 0;
 
 	if (s->local.family == AF_INET)
 		s->local.bytelen = s->remote.bytelen = 4;
@@ -2384,7 +2389,7 @@ struct inet_diag_arg {
 	struct rtnl_handle *rth;
 };
 
-static int kill_inet_sock(struct nlmsghdr *h, void *arg)
+static int kill_inet_sock(struct nlmsghdr *h, void *arg, struct sockstat *s)
 {
 	struct inet_diag_msg *d = NLMSG_DATA(h);
 	struct inet_diag_arg *diag_arg = arg;
@@ -2399,6 +2404,13 @@ static int kill_inet_sock(struct nlmsghdr *h, void *arg)
 	req.r.sdiag_protocol = diag_arg->protocol;
 	req.r.id = d->id;
 
+	if (diag_arg->protocol == IPPROTO_RAW) {
+		struct inet_diag_req_raw *raw = (void *)&req.r;
+
+		BUILD_BUG_ON(sizeof(req.r) != sizeof(*raw));
+		raw->sdiag_raw_protocol = s->raw_prot;
+	}
+
 	return rtnl_talk(rth, &req.nlh, NULL, 0);
 }
 
@@ -2418,7 +2430,7 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
 	if (diag_arg->f->f && run_ssfilter(diag_arg->f->f, &s) == 0)
 		return 0;
 
-	if (diag_arg->f->kill && kill_inet_sock(h, arg) != 0) {
+	if (diag_arg->f->kill && kill_inet_sock(h, arg, &s) != 0) {
 		if (errno == EOPNOTSUPP || errno == ENOENT) {
 			/* Socket can't be closed, or is already closed. */
 			return 0;
@@ -2715,6 +2727,10 @@ static int raw_show(struct filter *f)
 
 	dg_proto = RAW_PROTO;
 
+	if (!getenv("PROC_NET_RAW") && !getenv("PROC_ROOT") &&
+	    inet_show_netlink(f, NULL, IPPROTO_RAW) == 0)
+		return 0;
+
 	if (f->families&(1<<AF_INET)) {
 		if ((fp = net_raw_open()) == NULL)
 			goto outerr;
-- 
2.7.4

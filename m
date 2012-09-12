From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] iproute2: GENL: merge GENL_REQUEST and GENL_INITIALIZER
Date: Wed, 12 Sep 2012 09:15:19 +0300
Message-ID: <1347430519-2216-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:36011 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751029Ab2ILGMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2012 02:12:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Both macros are used together, so better to have
single define. Update all requests in ipl2tp.c to use the
new macro.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/libgenl.h |   27 +++++++++-----------
 ip/ipl2tp.c       |   72 +++++++++++-----------------------------------------
 lib/libgenl.c     |    7 ++---
 3 files changed, 31 insertions(+), 75 deletions(-)

diff --git a/include/libgenl.h b/include/libgenl.h
index 0b11a89..9db4baf 100644
--- a/include/libgenl.h
+++ b/include/libgenl.h
@@ -3,25 +3,22 @@
 
 #include "libnetlink.h"
 
-#define GENL_REQUEST(_req, _hdrsiz, _bufsiz)				\
+#define GENL_REQUEST(_req, _bufsiz, _family, _hdrsiz, _ver, _cmd, _flags) \
 struct {								\
 	struct nlmsghdr		n;					\
 	struct genlmsghdr	g;					\
 	char			buf[NLMSG_ALIGN(_hdrsiz) + (_bufsiz)];	\
-} _req
-
-#define GENL_INITIALIZER(_family, _hdrsiz, _ver, _cmd, _flags)		\
-	{								\
-		.n = {							\
-			.nlmsg_type = (_family),			\
-			.nlmsg_flags = (_flags),			\
-			.nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN + (_hdrsiz)), \
-		},							\
-		.g = {							\
-			.cmd = (_cmd),					\
-			.version = (_ver),				\
-		},							\
-	}
+} _req = {								\
+	.n = {								\
+		.nlmsg_type = (_family),				\
+		.nlmsg_flags = (_flags),				\
+		.nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN + (_hdrsiz)),	\
+	},								\
+	.g = {								\
+		.cmd = (_cmd),						\
+		.version = (_ver),					\
+	},								\
+}
 
 extern int genl_resolve_family(struct rtnl_handle *grth, const char *family);
 
diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index aaa3d31..f6e264a 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -96,9 +96,8 @@ static int create_tunnel(struct l2tp_parm *p)
 	uint32_t local_attr = L2TP_ATTR_IP_SADDR;
 	uint32_t peer_attr = L2TP_ATTR_IP_DADDR;
 
-	GENL_REQUEST(req, 0, 1024)
-		= GENL_INITIALIZER(genl_family, NLM_F_REQUEST | NLM_F_ACK, 0,
-				   L2TP_CMD_TUNNEL_CREATE, L2TP_GENL_VERSION);
+	GENL_REQUEST(req, 1024, genl_family, 0, L2TP_GENL_VERSION,
+		     L2TP_CMD_TUNNEL_CREATE, NLM_F_REQUEST | NLM_F_ACK);
 
 	addattr32(&req.n, 1024, L2TP_ATTR_CONN_ID, p->tunnel_id);
 	addattr32(&req.n, 1024, L2TP_ATTR_PEER_CONN_ID, p->peer_tunnel_id);
@@ -126,9 +125,8 @@ static int create_tunnel(struct l2tp_parm *p)
 
 static int delete_tunnel(struct l2tp_parm *p)
 {
-	GENL_REQUEST(req, 0, 1024)
-		= GENL_INITIALIZER(genl_family, NLM_F_REQUEST | NLM_F_ACK, 0,
-				   L2TP_CMD_TUNNEL_DELETE, L2TP_GENL_VERSION);
+	GENL_REQUEST(req, 128, genl_family, 0, L2TP_GENL_VERSION,
+		     L2TP_CMD_TUNNEL_DELETE, NLM_F_REQUEST | NLM_F_ACK);
 
 	addattr32(&req.n, 128, L2TP_ATTR_CONN_ID, p->tunnel_id);
 
@@ -140,18 +138,8 @@ static int delete_tunnel(struct l2tp_parm *p)
 
 static int create_session(struct l2tp_parm *p)
 {
-	struct {
-		struct nlmsghdr 	n;
-		struct genlmsghdr	g;
-		char   			buf[1024];
-	} req;
-
-	memset(&req, 0, sizeof(req));
-	req.n.nlmsg_type = genl_family;
-	req.n.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
-	req.n.nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN);
-	req.g.cmd = L2TP_CMD_SESSION_CREATE;
-	req.g.version = L2TP_GENL_VERSION;
+	GENL_REQUEST(req, 1024, genl_family, 0, L2TP_GENL_VERSION,
+		     L2TP_CMD_SESSION_CREATE, NLM_F_REQUEST | NLM_F_ACK);
 
 	addattr32(&req.n, 1024, L2TP_ATTR_CONN_ID, p->tunnel_id);
 	addattr32(&req.n, 1024, L2TP_ATTR_PEER_CONN_ID, p->peer_tunnel_id);
@@ -182,18 +170,8 @@ static int create_session(struct l2tp_parm *p)
 
 static int delete_session(struct l2tp_parm *p)
 {
-	struct {
-		struct nlmsghdr 	n;
-		struct genlmsghdr	g;
-		char   			buf[128];
-	} req;
-
-	memset(&req, 0, sizeof(req));
-	req.n.nlmsg_type = genl_family;
-	req.n.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
-	req.n.nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN);
-	req.g.cmd = L2TP_CMD_SESSION_DELETE;
-	req.g.version = L2TP_GENL_VERSION;
+	GENL_REQUEST(req, 1024, genl_family, 0, L2TP_GENL_VERSION,
+		     L2TP_CMD_SESSION_DELETE, NLM_F_REQUEST | NLM_F_ACK);
 
 	addattr32(&req.n, 1024, L2TP_ATTR_CONN_ID, p->tunnel_id);
 	addattr32(&req.n, 1024, L2TP_ATTR_SESSION_ID, p->session_id);
@@ -380,20 +358,11 @@ static int session_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n, void
 
 static int get_session(struct l2tp_data *p)
 {
-	struct {
-		struct nlmsghdr 	n;
-		struct genlmsghdr	g;
-		char buf[128];
-	} req;
-
-	memset(&req, 0, sizeof(req));
-	req.n.nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN);
-	req.n.nlmsg_type = genl_family;
-	req.n.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
-	req.n.nlmsg_seq = genl_rth.dump = ++genl_rth.seq;
+	GENL_REQUEST(req, 128, genl_family, 0, L2TP_GENL_VERSION,
+		     L2TP_CMD_SESSION_GET,
+		     NLM_F_ROOT | NLM_F_MATCH | NLM_F_REQUEST);
 
-	req.g.cmd = L2TP_CMD_SESSION_GET;
-	req.g.version = L2TP_GENL_VERSION;
+	req.n.nlmsg_seq = genl_rth.dump = ++genl_rth.seq;
 
 	if (p->config.tunnel_id && p->config.session_id) {
 		addattr32(&req.n, 128, L2TP_ATTR_CONN_ID, p->config.tunnel_id);
@@ -423,20 +392,11 @@ static int tunnel_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n, void
 
 static int get_tunnel(struct l2tp_data *p)
 {
-	struct {
-		struct nlmsghdr 	n;
-		struct genlmsghdr	g;
-		char buf[1024];
-	} req;
-
-	memset(&req, 0, sizeof(req));
-	req.n.nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN);
-	req.n.nlmsg_type = genl_family;
-	req.n.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
-	req.n.nlmsg_seq = genl_rth.dump = ++genl_rth.seq;
+	GENL_REQUEST(req, 1024, genl_family, 0, L2TP_GENL_VERSION,
+		     L2TP_CMD_TUNNEL_GET,
+		     NLM_F_ROOT | NLM_F_MATCH | NLM_F_REQUEST);
 
-	req.g.cmd = L2TP_CMD_TUNNEL_GET;
-	req.g.version = L2TP_GENL_VERSION;
+	req.n.nlmsg_seq = genl_rth.dump = ++genl_rth.seq;
 
 	if (p->config.tunnel_id)
 		addattr32(&req.n, 1024, L2TP_ATTR_CONN_ID, p->config.tunnel_id);
diff --git a/lib/libgenl.c b/lib/libgenl.c
index d68e58e..ef3e5db 100644
--- a/lib/libgenl.c
+++ b/lib/libgenl.c
@@ -47,11 +47,10 @@ static int genl_parse_getfamily(struct nlmsghdr *nlh)
 
 int genl_resolve_family(struct rtnl_handle *grth, const char *family)
 {
-	GENL_REQUEST(req, 0, 1024)
-		= GENL_INITIALIZER(GENL_ID_CTRL, 0,
-				   0, CTRL_CMD_GETFAMILY, NLM_F_REQUEST);
+	GENL_REQUEST(req, 1024, GENL_ID_CTRL, 0, 0, CTRL_CMD_GETFAMILY,
+		     NLM_F_REQUEST);
 
-	addattr_l(&req.n, 1024, CTRL_ATTR_FAMILY_NAME,
+	addattr_l(&req.n, sizeof(req), CTRL_ATTR_FAMILY_NAME,
 		  family, strlen(family) + 1);
 
 	if (rtnl_talk(grth, &req.n, 0, 0, &req.n) < 0) {
-- 
1.7.3.4

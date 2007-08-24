From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 3/3] [IPROUTE2] ip: xfrm: Fix flush message.
Date: Fri, 24 Aug 2007 11:05:24 +0900
Message-ID: <11879211243893-git-send-email-nakam@linux-ipv6.org>
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>
To: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:44740 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1765756AbXHXC0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 22:26:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix xfrm state or policy flush message.
And minor updates are included:
o Use static buffer to show unknown value as string.
o Show policy type (ptype) only when kernel specified it.
o Clean-up xfrm_monitor.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 ip/ipxfrm.c       |   48 +++++++++++++--------
 ip/xfrm.h         |    1 +
 ip/xfrm_monitor.c |  122 +++++++++++++++++++++++++++++++++++++---------------
 ip/xfrm_state.c   |    1 -
 4 files changed, 117 insertions(+), 55 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 359a2d2..80dbb52 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -114,6 +114,7 @@ struct typeent {
 static const struct typeent xfrmproto_types[]= {
 	{ "esp", IPPROTO_ESP }, { "ah", IPPROTO_AH }, { "comp", IPPROTO_COMP },
 	{ "route2", IPPROTO_ROUTING }, { "hao", IPPROTO_DSTOPTS },
+	{ "ipsec-any", IPSEC_PROTO_ANY },
 	{ NULL, -1 }
 };
 
@@ -135,6 +136,7 @@ int xfrm_xfrmproto_getbyname(char *name)
 
 const char *strxf_xfrmproto(__u8 proto)
 {
+	static char str[16];
 	int i;
 
 	for (i = 0; ; i++) {
@@ -146,7 +148,8 @@ const char *strxf_xfrmproto(__u8 proto)
 			return t->t_name;
 	}
 
-	return NULL;
+	sprintf(str, "%u", proto);
+	return str;
 }
 
 static const struct typeent algo_types[]= {
@@ -172,6 +175,7 @@ int xfrm_algotype_getbyname(char *name)
 
 const char *strxf_algotype(int type)
 {
+	static char str[32];
 	int i;
 
 	for (i = 0; ; i++) {
@@ -183,7 +187,8 @@ const char *strxf_algotype(int type)
 			return t->t_name;
 	}
 
-	return NULL;
+	sprintf(str, "%d", type);
+	return str;
 }
 
 const char *strxf_mask8(__u8 mask)
@@ -251,6 +256,25 @@ const char *strxf_proto(__u8 proto)
 	return p;
 }
 
+const char *strxf_ptype(__u8 ptype)
+{
+	static char str[16];
+
+	switch (ptype) {
+	case XFRM_POLICY_TYPE_MAIN:
+		strcpy(str, "main");
+		break;
+	case XFRM_POLICY_TYPE_SUB:
+		strcpy(str, "sub");
+		break;
+	default:
+		sprintf(str, "%u", ptype);
+		break;
+	}
+
+	return str;
+}
+
 void xfrm_id_info_print(xfrm_address_t *saddr, struct xfrm_id *id,
 			__u8 mode, __u32 reqid, __u16 family, int force_spi,
 			FILE *fp, const char *prefix, const char *title)
@@ -776,7 +800,6 @@ void xfrm_policy_info_print(struct xfrm_userpolicy_info *xpinfo,
 			    const char *title)
 {
 	char buf[STRBUF_SIZE];
-	__u8 ptype = XFRM_POLICY_TYPE_MAIN;
 
 	memset(buf, '\0', sizeof(buf));
 
@@ -821,31 +844,18 @@ void xfrm_policy_info_print(struct xfrm_userpolicy_info *xpinfo,
 		fprintf(fp, "index %u ", xpinfo->index);
 	fprintf(fp, "priority %u ", xpinfo->priority);
 
-	fprintf(fp, "ptype ");
-
 	if (tb[XFRMA_POLICY_TYPE]) {
 		struct xfrm_userpolicy_type *upt;
 
+		fprintf(fp, "ptype ");
+
 		if (RTA_PAYLOAD(tb[XFRMA_POLICY_TYPE]) < sizeof(*upt))
 			fprintf(fp, "(ERROR truncated)");
 
 		upt = (struct xfrm_userpolicy_type *)RTA_DATA(tb[XFRMA_POLICY_TYPE]);
-		ptype = upt->type;
+		fprintf(fp, "%s ", strxf_ptype(upt->type));
 	}
 
-	switch (ptype) {
-	case XFRM_POLICY_TYPE_MAIN:
-		fprintf(fp, "main");
-		break;
-	case XFRM_POLICY_TYPE_SUB:
-		fprintf(fp, "sub");
-		break;
-	default:
-		fprintf(fp, "%u", ptype);
-		break;
-	}
-	fprintf(fp, " ");
-
 	if (show_stats > 0)
 		fprintf(fp, "share %s ", strxf_share(xpinfo->share));
 
diff --git a/ip/xfrm.h b/ip/xfrm.h
index 335c2a5..930bb3f 100644
--- a/ip/xfrm.h
+++ b/ip/xfrm.h
@@ -127,6 +127,7 @@ const char *strxf_mask8(__u8 mask);
 const char *strxf_mask32(__u32 mask);
 const char *strxf_share(__u8 share);
 const char *strxf_proto(__u8 proto);
+const char *strxf_ptype(__u8 ptype);
 void xfrm_id_info_print(xfrm_address_t *saddr, struct xfrm_id *id,
 			__u8 mode, __u32 reqid, __u16 family, int force_spi,
 			FILE *fp, const char *prefix, const char *title);
diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index bdbf4a6..dc12fca 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -50,12 +50,6 @@ static int xfrm_acquire_print(const struct sockaddr_nl *who,
 	struct rtattr * tb[XFRMA_MAX+1];
 	__u16 family;
 
-	if (n->nlmsg_type != XFRM_MSG_ACQUIRE) {
-		fprintf(stderr, "Not an acquire: %08x %08x %08x\n",
-			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
-		return 0;
-	}
-
 	len -= NLMSG_LENGTH(sizeof(*xacq));
 	if (len < 0) {
 		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
@@ -108,6 +102,74 @@ static int xfrm_acquire_print(const struct sockaddr_nl *who,
 	return 0;
 }
 
+static int xfrm_state_flush_print(const struct sockaddr_nl *who,
+				  struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+	struct xfrm_usersa_flush *xsf = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	const char *str;
+
+	len -= NLMSG_SPACE(sizeof(*xsf));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	fprintf(fp, "Flushed state ");
+
+	str = strxf_xfrmproto(xsf->proto);
+	if (str)
+		fprintf(fp, "proto %s", str);
+	else
+		fprintf(fp, "proto %u", xsf->proto);
+	fprintf(fp, "%s", _SL_);
+
+	if (oneline)
+		fprintf(fp, "\n");
+	fflush(fp);
+
+	return 0;
+}
+
+static int xfrm_policy_flush_print(const struct sockaddr_nl *who,
+				   struct nlmsghdr *n, void *arg)
+{
+	struct rtattr * tb[XFRMA_MAX+1];
+	FILE *fp = (FILE*)arg;
+	int len = n->nlmsg_len;
+
+	len -= NLMSG_SPACE(0);
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	fprintf(fp, "Flushed policy ");
+
+	parse_rtattr(tb, XFRMA_MAX, NLMSG_DATA(n), len);
+
+	if (tb[XFRMA_POLICY_TYPE]) {
+		struct xfrm_userpolicy_type *upt;
+
+		fprintf(fp, "ptype ");
+
+		if (RTA_PAYLOAD(tb[XFRMA_POLICY_TYPE]) < sizeof(*upt))
+			fprintf(fp, "(ERROR truncated)");
+
+		upt = (struct xfrm_userpolicy_type *)RTA_DATA(tb[XFRMA_POLICY_TYPE]);
+		fprintf(fp, "%s ", strxf_ptype(upt->type));
+	}
+
+	fprintf(fp, "%s", _SL_);
+
+	if (oneline)
+		fprintf(fp, "\n");
+	fflush(fp);
+
+	return 0;
+}
+
 static int xfrm_report_print(const struct sockaddr_nl *who,
 			     struct nlmsghdr *n, void *arg)
 {
@@ -117,12 +179,6 @@ static int xfrm_report_print(const struct sockaddr_nl *who,
 	struct rtattr * tb[XFRMA_MAX+1];
 	__u16 family;
 
-	if (n->nlmsg_type != XFRM_MSG_REPORT) {
-		fprintf(stderr, "Not a report: %08x %08x %08x\n",
-			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
-		return 0;
-	}
-
 	len -= NLMSG_LENGTH(sizeof(*xrep));
 	if (len < 0) {
 		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
@@ -201,42 +257,38 @@ static int xfrm_accept_msg(const struct sockaddr_nl *who,
 	if (timestamp)
 		print_timestamp(fp);
 
-	if (n->nlmsg_type == XFRM_MSG_NEWSA ||
-	    n->nlmsg_type == XFRM_MSG_DELSA ||
-	    n->nlmsg_type == XFRM_MSG_UPDSA ||
-	    n->nlmsg_type == XFRM_MSG_EXPIRE) {
+	switch (n->nlmsg_type) {
+	case XFRM_MSG_NEWSA:
+	case XFRM_MSG_DELSA:
+	case XFRM_MSG_UPDSA:
+	case XFRM_MSG_EXPIRE:
 		xfrm_state_print(who, n, arg);
 		return 0;
-	}
-	if (n->nlmsg_type == XFRM_MSG_NEWPOLICY ||
-	    n->nlmsg_type == XFRM_MSG_DELPOLICY ||
-	    n->nlmsg_type == XFRM_MSG_UPDPOLICY ||
-	    n->nlmsg_type == XFRM_MSG_POLEXPIRE) {
+	case XFRM_MSG_NEWPOLICY:
+	case XFRM_MSG_DELPOLICY:
+	case XFRM_MSG_UPDPOLICY:
+	case XFRM_MSG_POLEXPIRE:
 		xfrm_policy_print(who, n, arg);
 		return 0;
-	}
-
-	if (n->nlmsg_type == XFRM_MSG_ACQUIRE) {
+	case XFRM_MSG_ACQUIRE:
 		xfrm_acquire_print(who, n, arg);
 		return 0;
-	}
-	if (n->nlmsg_type == XFRM_MSG_FLUSHSA) {
-		/* XXX: Todo: show proto in xfrm_usersa_flush */
-		fprintf(fp, "Flushed state\n");
+	case XFRM_MSG_FLUSHSA:
+		xfrm_state_flush_print(who, n, arg);
 		return 0;
-	}
-	if (n->nlmsg_type == XFRM_MSG_FLUSHPOLICY) {
-		fprintf(fp, "Flushed policy\n");
+	case XFRM_MSG_FLUSHPOLICY:
+		xfrm_policy_flush_print(who, n, arg);
 		return 0;
-	}
-	if (n->nlmsg_type == XFRM_MSG_REPORT) {
+	case XFRM_MSG_REPORT:
 		xfrm_report_print(who, n, arg);
 		return 0;
-	}
-	if (n->nlmsg_type == XFRM_MSG_NEWAE) {
+	case XFRM_MSG_NEWAE:
 		xfrm_ae_print(who, n, arg);
 		return 0;
+	default:
+		break;
 	}
+
 	if (n->nlmsg_type != NLMSG_ERROR && n->nlmsg_type != NLMSG_NOOP &&
 	    n->nlmsg_type != NLMSG_DONE) {
 		fprintf(fp, "Unknown message: %08d 0x%08x 0x%08x\n",
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 29604a5..f51e8b6 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -1053,7 +1053,6 @@ static int xfrm_state_flush(int argc, char **argv)
 
 	if (show_stats > 1)
 		fprintf(stderr, "Flush state proto=%s\n",
-			(req.xsf.proto == IPSEC_PROTO_ANY) ? "any" :
 			strxf_xfrmproto(req.xsf.proto));
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
-- 
1.4.4.2


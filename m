From: Masahide Nakamura <nakam@linux-ipv6.org>
Subject: [PATCH] [iproute2] XFRM: using flush message type
Date: Mon, 6 Sep 2004 16:46:40 +0900
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040906164640.19710b12@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, nakam@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
List-Id: netdev.vger.kernel.org

Kernel has flush message types for XFRM's policy/state so
I've fixed to use it in which case no argument are specified after
"flush" in the command line. Please apply a patch below.

The ChangeSet is also available at:
<bk://bk.skbuff.net:38000/iproute2-FIX-flush>


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/02 22:58:16+09:00 nakam@linux-ipv6.org 
#   use flush message types.
# 
# ip/xfrm_state.c
#   2004/09/02 22:58:11+09:00 nakam@linux-ipv6.org +37 -3
#   use XFRM_MSG_FLUSHSA message type in flushing without any other
#   arguments.
# 
# ip/xfrm_policy.c
#   2004/09/02 22:58:11+09:00 nakam@linux-ipv6.org +33 -2
#   use XFRM_MSG_FLUSHPOLICY message type in flushing without any other
#   arguments.
# 
# include/utils.h
#   2004/09/02 22:58:10+09:00 nakam@linux-ipv6.org +3 -0
#   add IPSEC_PROTO_ANY in kernel's include/linux/ipsec.h.
# 
diff -Nru a/include/utils.h b/include/utils.h
--- a/include/utils.h	2004-09-02 23:05:20 +09:00
+++ b/include/utils.h	2004-09-02 23:05:20 +09:00
@@ -25,6 +25,9 @@
 #ifndef IPPROTO_COMP
 #define IPPROTO_COMP	108
 #endif
+#ifndef IPSEC_PROTO_ANY
+#define IPSEC_PROTO_ANY	255
+#endif
 
 #define SPRINT_BSIZE 64
 #define SPRINT_BUF(x)	char x[SPRINT_BSIZE]
diff -Nru a/ip/xfrm_policy.c b/ip/xfrm_policy.c
--- a/ip/xfrm_policy.c	2004-09-02 23:05:20 +09:00
+++ b/ip/xfrm_policy.c	2004-09-02 23:05:20 +09:00
@@ -680,6 +680,33 @@
 	exit(0);
 }
 
+static int xfrm_policy_flush_all(void)
+{
+	struct rtnl_handle rth;
+	struct {
+		struct nlmsghdr	n;
+	} req;
+
+	memset(&req, 0, sizeof(req));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(0); /* nlmsg data is nothing */
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.n.nlmsg_type = XFRM_MSG_FLUSHPOLICY;
+
+	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
+		exit(1);
+
+	if (show_stats > 1)
+		fprintf(stderr, "Flush all\n");
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
+		exit(2);
+
+	rtnl_close(&rth);
+
+	return 0;
+}
+
 int do_xfrm_policy(int argc, char **argv)
 {
 	if (argc < 1)
@@ -698,8 +725,12 @@
 		return xfrm_policy_list_or_flush(argc-1, argv+1, 0);
 	if (matches(*argv, "get") == 0)
 		return xfrm_policy_get(argc-1, argv+1);
-	if (matches(*argv, "flush") == 0)
-		return xfrm_policy_list_or_flush(argc-1, argv+1, 1);
+	if (matches(*argv, "flush") == 0) {
+		if (argc-1 < 1)
+			return xfrm_policy_flush_all();
+		else
+			return xfrm_policy_list_or_flush(argc-1, argv+1, 1);
+	}
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip xfrm policy help\".\n", *argv);
diff -Nru a/ip/xfrm_state.c b/ip/xfrm_state.c
--- a/ip/xfrm_state.c	2004-09-02 23:05:20 +09:00
+++ b/ip/xfrm_state.c	2004-09-02 23:05:20 +09:00
@@ -563,7 +563,8 @@
 	char *idp = NULL;
 	struct rtnl_handle rth;
 
-	filter.use = 1;
+	if(argc > 0)
+		filter.use = 1;
 	filter.xsinfo.family = preferred_family;
 
 	while (argc > 0) {
@@ -661,6 +662,35 @@
 	exit(0);
 }
 
+static int xfrm_state_flush_all(void)
+{
+	struct rtnl_handle rth;
+	struct {
+		struct nlmsghdr			n;
+		struct xfrm_usersa_flush	xsf;
+	} req;
+
+	memset(&req, 0, sizeof(req));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsf));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.n.nlmsg_type = XFRM_MSG_FLUSHSA;
+	req.xsf.proto = IPSEC_PROTO_ANY;
+
+	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
+		exit(1);
+
+	if (show_stats > 1)
+		fprintf(stderr, "Flush all\n");
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
+		exit(2);
+
+	rtnl_close(&rth);
+
+	return 0;
+}
+
 int do_xfrm_state(int argc, char **argv)
 {
 	if (argc < 1)
@@ -679,8 +709,12 @@
 		return xfrm_state_list_or_flush(argc-1, argv+1, 0);
 	if (matches(*argv, "get") == 0)
 		return xfrm_state_get_or_delete(argc-1, argv+1, 0);
-	if (matches(*argv, "flush") == 0)
-		return xfrm_state_list_or_flush(argc-1, argv+1, 1);
+	if (matches(*argv, "flush") == 0) {
+		if (argc-1 < 1)
+			return xfrm_state_flush_all();
+		else
+			return xfrm_state_list_or_flush(argc-1, argv+1, 1);
+	}
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip xfrm state help\".\n", *argv);






-- 
Masahide NAKAMURA

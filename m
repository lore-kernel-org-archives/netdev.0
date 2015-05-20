From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2-next 3/6] libnetlink: introduce rtnl_listen_filter_t
Date: Wed, 20 May 2015 16:19:58 +0200
Message-ID: <1432131601-4641-4-git-send-email-nicolas.dichtel@6wind.com>
References: <20150509.221554.38834063932093195.davem@davemloft.net>
 <1432131601-4641-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:44033 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753943AbbETOUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 10:20:09 -0400
In-Reply-To: <1432131601-4641-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no functional change with this commit. It only prepares the next one.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 bridge/monitor.c      |  1 +
 genl/ctrl.c           | 17 ++++++++++++-----
 include/libnetlink.h  | 11 +++++++++--
 ip/ip_common.h        |  1 +
 ip/ipaddress.c        |  8 ++++++--
 ip/iplink.c           |  1 +
 ip/ipmonitor.c        |  3 ++-
 ip/ipnetconf.c        | 11 +++++++++--
 ip/ipnetns.c          |  1 +
 ip/iproute.c          |  9 ++++++---
 ip/rtmon.c            | 12 +++++++++---
 ip/xfrm_monitor.c     |  1 +
 lib/libnetlink.c      |  8 ++++----
 man/man3/libnetlink.3 |  7 ++++---
 tc/tc_monitor.c       |  1 +
 15 files changed, 67 insertions(+), 25 deletions(-)

diff --git a/bridge/monitor.c b/bridge/monitor.c
index 9e1ed48c5141..d8341ec5fbf1 100644
--- a/bridge/monitor.c
+++ b/bridge/monitor.c
@@ -36,6 +36,7 @@ static void usage(void)
 }
 
 static int accept_msg(const struct sockaddr_nl *who,
+		      struct rtnl_ctrl_data *ctrl,
 		      struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = arg;
diff --git a/genl/ctrl.c b/genl/ctrl.c
index 3546129087ec..87d2334a084c 100644
--- a/genl/ctrl.c
+++ b/genl/ctrl.c
@@ -177,8 +177,9 @@ static int print_ctrl_grp(FILE *fp, struct rtattr *arg, __u32 ctrl_ver)
 /*
  * The controller sends one nlmsg per family
 */
-static int print_ctrl(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		      void *arg)
+static int print_ctrl(const struct sockaddr_nl *who,
+		      struct rtnl_ctrl_data *ctrl,
+		      struct nlmsghdr *n, void *arg)
 {
 	struct rtattr *tb[CTRL_ATTR_MAX + 1];
 	struct genlmsghdr *ghdr = NLMSG_DATA(n);
@@ -281,6 +282,12 @@ static int print_ctrl(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	return 0;
 }
 
+static int print_ctrl2(const struct sockaddr_nl *who,
+		      struct nlmsghdr *n, void *arg)
+{
+	return print_ctrl(who, NULL, n, arg);
+}
+
 static int ctrl_list(int cmd, int argc, char **argv)
 {
 	struct rtnl_handle rth;
@@ -339,7 +346,7 @@ static int ctrl_list(int cmd, int argc, char **argv)
 			goto ctrl_done;
 		}
 
-		if (print_ctrl(NULL, nlh, (void *) stdout) < 0) {
+		if (print_ctrl2(NULL, nlh, (void *) stdout) < 0) {
 			fprintf(stderr, "Dump terminated\n");
 			goto ctrl_done;
 		}
@@ -355,7 +362,7 @@ static int ctrl_list(int cmd, int argc, char **argv)
 			goto ctrl_done;
 		}
 
-		rtnl_dump_filter(&rth, print_ctrl, stdout);
+		rtnl_dump_filter(&rth, print_ctrl2, stdout);
 
         }
 
@@ -408,5 +415,5 @@ static int parse_ctrl(struct genl_util *a, int argc, char **argv)
 struct genl_util ctrl_genl_util = {
 	.name = "ctrl",
 	.parse_genlopt = parse_ctrl,
-	.print_genlopt = print_ctrl,
+	.print_genlopt = print_ctrl2,
 };
diff --git a/include/libnetlink.h b/include/libnetlink.h
index 898275b824d4..1b9c9255ce1d 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -41,9 +41,16 @@ extern int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req,
 			     int len)
 	__attribute__((warn_unused_result));
 
+struct rtnl_ctrl_data {
+};
+
 typedef int (*rtnl_filter_t)(const struct sockaddr_nl *,
 			     struct nlmsghdr *n, void *);
 
+typedef int (*rtnl_listen_filter_t)(const struct sockaddr_nl *,
+				    struct rtnl_ctrl_data *,
+				    struct nlmsghdr *n, void *);
+
 struct rtnl_dump_filter_arg
 {
 	rtnl_filter_t filter;
@@ -118,9 +125,9 @@ static inline const char *rta_getattr_str(const struct rtattr *rta)
 	return (const char *)RTA_DATA(rta);
 }
 
-extern int rtnl_listen(struct rtnl_handle *, rtnl_filter_t handler,
+extern int rtnl_listen(struct rtnl_handle *, rtnl_listen_filter_t handler,
 		       void *jarg);
-extern int rtnl_from_file(FILE *, rtnl_filter_t handler,
+extern int rtnl_from_file(FILE *, rtnl_listen_filter_t handler,
 		       void *jarg);
 
 #define NLMSG_TAIL(nmsg) \
diff --git a/ip/ip_common.h b/ip/ip_common.h
index b082734d9e0c..f120f5b97143 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -33,6 +33,7 @@ extern int print_prefix(const struct sockaddr_nl *who,
 extern int print_rule(const struct sockaddr_nl *who,
 		      struct nlmsghdr *n, void *arg);
 extern int print_netconf(const struct sockaddr_nl *who,
+			 struct rtnl_ctrl_data *ctrl,
 			 struct nlmsghdr *n, void *arg);
 extern void netns_map_init(void);
 extern int print_nsid(const struct sockaddr_nl *who,
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 92afa4904917..f36ccfb0d0fa 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1111,7 +1111,9 @@ static int save_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	return ret == n->nlmsg_len ? 0 : ret;
 }
 
-static int show_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n, void *arg)
+static int show_handler(const struct sockaddr_nl *nl,
+			struct rtnl_ctrl_data *ctrl,
+			struct nlmsghdr *n, void *arg)
 {
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 
@@ -1128,7 +1130,9 @@ static int ipaddr_showdump(void)
 	exit(rtnl_from_file(stdin, &show_handler, NULL));
 }
 
-static int restore_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n, void *arg)
+static int restore_handler(const struct sockaddr_nl *nl,
+			   struct rtnl_ctrl_data *ctrl,
+			   struct nlmsghdr *n, void *arg)
 {
 	int ret;
 
diff --git a/ip/iplink.c b/ip/iplink.c
index bb437b96239a..79a86011eb2c 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -180,6 +180,7 @@ static int get_addr_gen_mode(const char *mode)
 static int have_rtnl_newlink = -1;
 
 static int accept_msg(const struct sockaddr_nl *who,
+		      struct rtnl_ctrl_data *ctrl,
 		      struct nlmsghdr *n, void *arg)
 {
 	struct nlmsgerr *err = (struct nlmsgerr *)NLMSG_DATA(n);
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 1205ee1c7039..27bbe4410644 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -38,6 +38,7 @@ static void usage(void)
 }
 
 static int accept_msg(const struct sockaddr_nl *who,
+		      struct rtnl_ctrl_data *ctrl,
 		      struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE*)arg;
@@ -122,7 +123,7 @@ static int accept_msg(const struct sockaddr_nl *who,
 	if (n->nlmsg_type == RTM_NEWNETCONF) {
 		if (prefix_banner)
 			fprintf(fp, "[NETCONF]");
-		print_netconf(who, n, arg);
+		print_netconf(who, ctrl, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == NLMSG_TSTAMP) {
diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
index aa31ead06863..eca6eeee834d 100644
--- a/ip/ipnetconf.c
+++ b/ip/ipnetconf.c
@@ -40,7 +40,8 @@ static void usage(void)
 
 #define NETCONF_RTA(r)	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct netconfmsg))))
 
-int print_netconf(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
+		  struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE*)arg;
 	struct netconfmsg *ncm = NLMSG_DATA(n);
@@ -123,6 +124,12 @@ int print_netconf(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	return 0;
 }
 
+static int print_netconf2(const struct sockaddr_nl *who,
+			  struct nlmsghdr *n, void *arg)
+{
+	return print_netconf(who, NULL, n, arg);
+}
+
 void ipnetconf_reset_filter(int ifindex)
 {
 	memset(&filter, 0, sizeof(filter));
@@ -177,7 +184,7 @@ dump:
 			perror("Cannot send dump request");
 			exit(1);
 		}
-		if (rtnl_dump_filter(&rth, print_netconf, stdout) < 0) {
+		if (rtnl_dump_filter(&rth, print_netconf2, stdout) < 0) {
 			fprintf(stderr, "Dump terminated\n");
 			exit(1);
 		}
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 438d59bc222e..019f954cc6f2 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -43,6 +43,7 @@ static struct rtnl_handle rtnsh = { .fd = -1 };
 static int have_rtnl_getnsid = -1;
 
 static int ipnetns_accept_msg(const struct sockaddr_nl *who,
+			      struct rtnl_ctrl_data *ctrl,
 			      struct nlmsghdr *n, void *arg)
 {
 	struct nlmsgerr *err = (struct nlmsgerr *)NLMSG_DATA(n);
diff --git a/ip/iproute.c b/ip/iproute.c
index 670a4c64d235..8bca11a8132a 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1681,8 +1681,9 @@ static int iproute_get(int argc, char **argv)
 	exit(0);
 }
 
-static int restore_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n,
-			   void *arg)
+static int restore_handler(const struct sockaddr_nl *nl,
+			   struct rtnl_ctrl_data *ctrl,
+			   struct nlmsghdr *n, void *arg)
 {
 	int ret;
 
@@ -1724,7 +1725,9 @@ static int iproute_restore(void)
 	exit(rtnl_from_file(stdin, &restore_handler, NULL));
 }
 
-static int show_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n, void *arg)
+static int show_handler(const struct sockaddr_nl *nl,
+			struct rtnl_ctrl_data *ctrl,
+			struct nlmsghdr *n, void *arg)
 {
 	print_route(nl, n, stdout);
 	return 0;
diff --git a/ip/rtmon.c b/ip/rtmon.c
index ff685e530d95..42b24fb5fd38 100644
--- a/ip/rtmon.c
+++ b/ip/rtmon.c
@@ -45,8 +45,8 @@ static void write_stamp(FILE *fp)
 	fwrite((void*)n1, 1, NLMSG_ALIGN(n1->nlmsg_len), fp);
 }
 
-static int dump_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		    void *arg)
+static int dump_msg(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
+		    struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE*)arg;
 	if (!init_phase)
@@ -56,6 +56,12 @@ static int dump_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	return 0;
 }
 
+static int dump_msg2(const struct sockaddr_nl *who,
+		     struct nlmsghdr *n, void *arg)
+{
+	return dump_msg(who, NULL, n, arg);
+}
+
 static void usage(void)
 {
 	fprintf(stderr, "Usage: rtmon file FILE [ all | LISTofOBJECTS]\n");
@@ -163,7 +169,7 @@ main(int argc, char **argv)
 
 	write_stamp(fp);
 
-	if (rtnl_dump_filter(&rth, dump_msg, fp) < 0) {
+	if (rtnl_dump_filter(&rth, dump_msg2, fp) < 0) {
 		fprintf(stderr, "Dump terminated\n");
 		return 1;
 	}
diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index 58c7d7f46b44..2119c51d92ac 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -290,6 +290,7 @@ static int xfrm_mapping_print(const struct sockaddr_nl *who,
 }
 
 static int xfrm_accept_msg(const struct sockaddr_nl *who,
+			   struct rtnl_ctrl_data *ctrl,
 			   struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE*)arg;
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 77e07ef7cf60..01b65cf806c0 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -419,7 +419,7 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 }
 
 int rtnl_listen(struct rtnl_handle *rtnl,
-		rtnl_filter_t handler,
+		rtnl_listen_filter_t handler,
 		void *jarg)
 {
 	int status;
@@ -475,7 +475,7 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 				exit(1);
 			}
 
-			err = handler(&nladdr, h, jarg);
+			err = handler(&nladdr, NULL, h, jarg);
 			if (err < 0)
 				return err;
 
@@ -493,7 +493,7 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 	}
 }
 
-int rtnl_from_file(FILE *rtnl, rtnl_filter_t handler,
+int rtnl_from_file(FILE *rtnl, rtnl_listen_filter_t handler,
 		   void *jarg)
 {
 	int status;
@@ -541,7 +541,7 @@ int rtnl_from_file(FILE *rtnl, rtnl_filter_t handler,
 			return -1;
 		}
 
-		err = handler(&nladdr, h, jarg);
+		err = handler(&nladdr, NULL, h, jarg);
 		if (err < 0)
 			return err;
 	}
diff --git a/man/man3/libnetlink.3 b/man/man3/libnetlink.3
index e999bd68237a..99be9cc9f533 100644
--- a/man/man3/libnetlink.3
+++ b/man/man3/libnetlink.3
@@ -33,7 +33,8 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 	      void *jarg)
 .sp
 int rtnl_listen(struct rtnl_handle *rtnl, 
-	      int (*handler)(struct sockaddr_nl *,struct nlmsghdr *n, void *),
+	      int (*handler)(struct sockaddr_nl *, struct rtnl_ctrl_data *,
+			     struct nlmsghdr *n, void *),
 	      void *jarg)
 .sp
 int rtnl_from_file(FILE *rtnl, 
@@ -108,8 +109,8 @@ rtnl_listen
 Receive netlink data after a request and pass it to 
 .I handler.
 .B handler
-is a callback that gets the message source address, the message itself,
-and the
+is a callback that gets the message source address, anscillary data, the message
+itself, and the
 .B jarg
 cookie as arguments. It will get called for all received messages.
 Only one message bundle is received. If there is a message
diff --git a/tc/tc_monitor.c b/tc/tc_monitor.c
index 0efe0343db0b..cae3616145c8 100644
--- a/tc/tc_monitor.c
+++ b/tc/tc_monitor.c
@@ -36,6 +36,7 @@ static void usage(void)
 
 
 static int accept_tcmsg(const struct sockaddr_nl *who,
+			struct rtnl_ctrl_data *ctrl,
 			struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE*)arg;
-- 
2.2.2

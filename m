From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH] iproute2: Refactor: using new nl_msg struct for the all Netlink handlers
Date: Wed,  3 Sep 2014 23:47:04 +0300
Message-ID: <1409777224-7813-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:41975 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbaICUzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 16:55:04 -0400
Received: by mail-la0-f53.google.com with SMTP id q1so1988977lam.26
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 13:55:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will easy to extend with new parameters in future.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 bridge/br_common.h   | 10 +++------
 bridge/fdb.c         |  5 +++--
 bridge/link.c        |  6 +++---
 bridge/mdb.c         |  5 +++--
 bridge/monitor.c     | 12 +++++------
 bridge/vlan.c        |  7 +++---
 genl/ctrl.c          | 11 ++++++----
 genl/genl.c          |  5 ++---
 genl/genl_utils.h    |  2 +-
 include/libnetlink.h | 10 +++++++--
 include/ll_map.h     |  3 +--
 ip/ip_common.h       | 32 +++++++++-------------------
 ip/ipaddress.c       | 57 ++++++++++++++++++++++++++-----------------------
 ip/ipaddrlabel.c     |  8 ++++---
 ip/ipl2tp.c          | 12 +++++------
 ip/iplink.c          |  9 +++++---
 ip/ipmonitor.c       | 26 +++++++++++------------
 ip/ipmroute.c        |  5 +++--
 ip/ipneigh.c         |  5 +++--
 ip/ipnetconf.c       |  5 +++--
 ip/ipntable.c        |  5 +++--
 ip/ipprefix.c        |  5 +++--
 ip/iproute.c         | 31 ++++++++++++++++++---------
 ip/iprule.c          |  8 ++++---
 ip/iptoken.c         |  5 +++--
 ip/rtmon.c           |  6 +++---
 ip/tcp_metrics.c     | 11 ++++++----
 ip/xfrm.h            |  6 ++----
 ip/xfrm_monitor.c    | 60 ++++++++++++++++++++++++++--------------------------
 ip/xfrm_policy.c     | 18 +++++++++-------
 ip/xfrm_state.c      | 23 ++++++++++++--------
 lib/libnetlink.c     | 19 ++++++++++++++---
 lib/ll_map.c         |  4 ++--
 misc/ifstat.c        |  4 ++--
 tc/m_action.c        | 18 ++++++++++------
 tc/tc_class.c        |  6 +++---
 tc/tc_common.h       |  8 +++----
 tc/tc_filter.c       |  7 +++---
 tc/tc_monitor.c      | 14 ++++++------
 tc/tc_qdisc.c        |  7 +++---
 40 files changed, 272 insertions(+), 228 deletions(-)

diff --git a/bridge/br_common.h b/bridge/br_common.h
index 12fce3e..2fd2af8 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -1,10 +1,6 @@
-extern int print_linkinfo(const struct sockaddr_nl *who,
-			  struct nlmsghdr *n,
-			  void *arg);
-extern int print_fdb(const struct sockaddr_nl *who,
-		     struct nlmsghdr *n, void *arg);
-extern int print_mdb(const struct sockaddr_nl *who,
-		     struct nlmsghdr *n, void *arg);
+extern int print_linkinfo(struct nl_msg *msg);
+extern int print_fdb(struct nl_msg *msg);
+extern int print_mdb(struct nl_msg *msg);
 
 extern int do_fdb(int argc, char **argv);
 extern int do_mdb(int argc, char **argv);
diff --git a/bridge/fdb.c b/bridge/fdb.c
index a55fac1..46b46ef 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -58,9 +58,10 @@ static const char *state_n2a(unsigned s)
 	return buf;
 }
 
-int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+int print_fdb(struct nl_msg *msg)
 {
-	FILE *fp = arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct ndmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[NDA_MAX+1];
diff --git a/bridge/link.c b/bridge/link.c
index 90d9e7f..5f5f8ab 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -96,10 +96,10 @@ static void print_hwmode(FILE *f, __u16 mode)
 		fprintf(f, "hwmode %s ", hw_mode[mode]);
 }
 
-int print_linkinfo(const struct sockaddr_nl *who,
-		   struct nlmsghdr *n, void *arg)
+int print_linkinfo(struct nl_msg *msg)
 {
-	FILE *fp = arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	int len = n->nlmsg_len;
 	struct ifinfomsg *ifi = NLMSG_DATA(n);
 	struct rtattr * tb[IFLA_MAX+1];
diff --git a/bridge/mdb.c b/bridge/mdb.c
index 6c1c938..6dfe7e8 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -77,9 +77,10 @@ static void br_print_mdb_entry(FILE *f, int ifindex, struct rtattr *attr)
 	}
 }
 
-int print_mdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+int print_mdb(struct nl_msg *msg)
 {
-	FILE *fp = arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct br_port_msg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[MDBA_MAX+1];
diff --git a/bridge/monitor.c b/bridge/monitor.c
index 76e7d47..816cb32 100644
--- a/bridge/monitor.c
+++ b/bridge/monitor.c
@@ -46,10 +46,10 @@ static int show_mark(FILE *fp, const struct nlmsghdr *n)
 	return 0;
 }
 
-static int accept_msg(const struct sockaddr_nl *who,
-		      struct nlmsghdr *n, void *arg)
+static int accept_msg(struct nl_msg *msg)
 {
-	FILE *fp = arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 
 	if (timestamp)
 		print_timestamp(fp);
@@ -60,19 +60,19 @@ static int accept_msg(const struct sockaddr_nl *who,
 		if (prefix_banner)
 			fprintf(fp, "[LINK]");
 
-		return print_linkinfo(who, n, arg);
+		return print_linkinfo(msg);
 
 	case RTM_NEWNEIGH:
 	case RTM_DELNEIGH:
 		if (prefix_banner)
 			fprintf(fp, "[NEIGH]");
-		return print_fdb(who, n, arg);
+		return print_fdb(msg);
 
 	case RTM_NEWMDB:
 	case RTM_DELMDB:
 		if (prefix_banner)
 			fprintf(fp, "[MDB]");
-		return print_mdb(who, n, arg);
+		return print_mdb(msg);
 
 	case 15:
 		return show_mark(fp, n);
diff --git a/bridge/vlan.c b/bridge/vlan.c
index 3bd7b0d..4282b59 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -101,11 +101,10 @@ static int vlan_modify(int cmd, int argc, char **argv)
 	return 0;
 }
 
-static int print_vlan(const struct sockaddr_nl *who,
-		      struct nlmsghdr *n,
-		      void *arg)
+static int print_vlan(struct nl_msg *msg)
 {
-	FILE *fp = arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct ifinfomsg *ifm = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[IFLA_MAX+1];
diff --git a/genl/ctrl.c b/genl/ctrl.c
index 3546129..0832739 100644
--- a/genl/ctrl.c
+++ b/genl/ctrl.c
@@ -177,14 +177,14 @@ static int print_ctrl_grp(FILE *fp, struct rtattr *arg, __u32 ctrl_ver)
 /*
  * The controller sends one nlmsg per family
 */
-static int print_ctrl(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		      void *arg)
+static int print_ctrl(struct nl_msg *msg)
 {
+	struct nlmsghdr *n = msg->n;
 	struct rtattr *tb[CTRL_ATTR_MAX + 1];
 	struct genlmsghdr *ghdr = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *attrs;
-	FILE *fp = (FILE *) arg;
+	FILE *fp = (FILE *)(msg->arg);
 	__u32 ctrl_v = 0x1;
 
 	if (n->nlmsg_type !=  GENL_ID_CTRL) {
@@ -292,6 +292,7 @@ static int ctrl_list(int cmd, int argc, char **argv)
 		struct nlmsghdr         n;
 		char                    buf[4096];
 	} req;
+	struct nl_msg msg = {};
 
 	memset(&req, 0, sizeof(req));
 
@@ -339,7 +340,9 @@ static int ctrl_list(int cmd, int argc, char **argv)
 			goto ctrl_done;
 		}
 
-		if (print_ctrl(NULL, nlh, (void *) stdout) < 0) {
+		msg.n = nlh;
+		msg.arg = (void *)stdout;
+		if (print_ctrl(&msg) < 0) {
 			fprintf(stderr, "Dump terminated\n");
 			goto ctrl_done;
 		}
diff --git a/genl/genl.c b/genl/genl.c
index 49b6596..ab4afc8 100644
--- a/genl/genl.c
+++ b/genl/genl.c
@@ -36,10 +36,9 @@ static void *BODY;
 static struct genl_util * genl_list;
 
 
-static int print_nofopt(const struct sockaddr_nl *who, struct nlmsghdr *n,
-			void *arg)
+static int print_nofopt(struct nl_msg *msg)
 {
-	fprintf((FILE *) arg, "unknown genl type ..\n");
+	fprintf((FILE *)(msg->arg), "unknown genl type ..\n");
 	return 0;
 }
 
diff --git a/genl/genl_utils.h b/genl/genl_utils.h
index 85b5183..b70b641 100644
--- a/genl/genl_utils.h
+++ b/genl/genl_utils.h
@@ -9,7 +9,7 @@ struct genl_util
 	struct  genl_util *next;
 	char	name[16];
 	int	(*parse_genlopt)(struct genl_util *fu, int argc, char **argv);
-	int	(*print_genlopt)(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
+	int	(*print_genlopt)(struct nl_msg *msg);
 };
 
 extern int genl_ctrl_resolve_family(const char *family);
diff --git a/include/libnetlink.h b/include/libnetlink.h
index fe7d5d3..aa47161 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -39,8 +39,14 @@ extern int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req,
 			     int len)
 	__attribute__((warn_unused_result));
 
-typedef int (*rtnl_filter_t)(const struct sockaddr_nl *,
-			     struct nlmsghdr *n, void *);
+struct nl_msg
+{
+	struct sockaddr_nl *who;
+	struct nlmsghdr *n;
+	void *arg;
+};
+
+typedef int (*rtnl_filter_t)(struct nl_msg *msg);
 
 struct rtnl_dump_filter_arg
 {
diff --git a/include/ll_map.h b/include/ll_map.h
index 4c78498..d3eb0ba 100644
--- a/include/ll_map.h
+++ b/include/ll_map.h
@@ -1,8 +1,7 @@
 #ifndef __LL_MAP_H__
 #define __LL_MAP_H__ 1
 
-extern int ll_remember_index(const struct sockaddr_nl *who,
-			     struct nlmsghdr *n, void *arg);
+extern int ll_remember_index(struct nl_msg *msg);
 
 extern void ll_init_map(struct rtnl_handle *rth);
 extern unsigned ll_name_to_index(const char *name);
diff --git a/ip/ip_common.h b/ip/ip_common.h
index e56d1ac..6a6065e 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -1,16 +1,9 @@
 extern int get_operstate(const char *name);
-extern int print_linkinfo(const struct sockaddr_nl *who,
-			  struct nlmsghdr *n,
-			  void *arg);
-extern int print_addrinfo(const struct sockaddr_nl *who,
-			  struct nlmsghdr *n,
-			  void *arg);
-extern int print_addrlabel(const struct sockaddr_nl *who,
-			   struct nlmsghdr *n, void *arg);
-extern int print_neigh(const struct sockaddr_nl *who,
-		       struct nlmsghdr *n, void *arg);
-extern int print_ntable(const struct sockaddr_nl *who,
-			struct nlmsghdr *n, void *arg);
+extern int print_linkinfo(struct nl_msg *msg);
+extern int print_addrinfo(struct nl_msg *msg);
+extern int print_addrlabel(struct nl_msg *msg);
+extern int print_neigh(struct nl_msg *msg);
+extern int print_ntable(struct nl_msg *msg);
 extern int ipaddr_list(int argc, char **argv);
 extern int ipaddr_list_link(int argc, char **argv);
 extern int iproute_monitor(int argc, char **argv);
@@ -21,16 +14,11 @@ void ipaddr_get_vf_rate(int, int *, int *, int);
 extern void ipaddr_reset_filter(int);
 extern void ipneigh_reset_filter(void);
 extern void ipntable_reset_filter(void);
-extern int print_route(const struct sockaddr_nl *who,
-		       struct nlmsghdr *n, void *arg);
-extern int print_mroute(const struct sockaddr_nl *who,
-			struct nlmsghdr *n, void *arg);
-extern int print_prefix(const struct sockaddr_nl *who,
-			struct nlmsghdr *n, void *arg);
-extern int print_rule(const struct sockaddr_nl *who,
-		      struct nlmsghdr *n, void *arg);
-extern int print_netconf(const struct sockaddr_nl *who,
-			 struct nlmsghdr *n, void *arg);
+extern int print_route(struct nl_msg *msg);
+extern int print_mroute(struct nl_msg *msg);
+extern int print_prefix(struct nl_msg *msg);
+extern int print_rule(struct nl_msg *msg);
+extern int print_netconf(struct nl_msg *msg);
 extern int do_ipaddr(int argc, char **argv);
 extern int do_ipaddrlabel(int argc, char **argv);
 extern int do_iproute(int argc, char **argv);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 245df39..97a5d20 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -425,10 +425,10 @@ static void print_link_stats(FILE *fp, const struct rtnl_link_stats *s,
 	}
 }
 
-int print_linkinfo(const struct sockaddr_nl *who,
-		   struct nlmsghdr *n, void *arg)
+int print_linkinfo(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE*)(msg->arg);
 	struct ifinfomsg *ifi = NLMSG_DATA(n);
 	struct rtattr * tb[IFLA_MAX+1];
 	int len = n->nlmsg_len;
@@ -597,10 +597,10 @@ static unsigned int get_ifa_flags(struct ifaddrmsg *ifa,
 				ifa->ifa_flags;
 }
 
-int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		   void *arg)
+int print_addrinfo(struct nl_msg *msg)
 {
-	FILE *fp = arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	int deprecated = 0;
@@ -796,26 +796,24 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	return 0;
 }
 
-static int print_addrinfo_primary(const struct sockaddr_nl *who,
-				  struct nlmsghdr *n, void *arg)
+static int print_addrinfo_primary(struct nl_msg *msg)
 {
-	struct ifaddrmsg *ifa = NLMSG_DATA(n);
+	struct ifaddrmsg *ifa = NLMSG_DATA(msg->n);
 
 	if (ifa->ifa_flags & IFA_F_SECONDARY)
 		return 0;
 
-	return print_addrinfo(who, n, arg);
+	return print_addrinfo(msg);
 }
 
-static int print_addrinfo_secondary(const struct sockaddr_nl *who,
-				    struct nlmsghdr *n, void *arg)
+static int print_addrinfo_secondary(struct nl_msg *msg)
 {
-	struct ifaddrmsg *ifa = NLMSG_DATA(n);
+	struct ifaddrmsg *ifa = NLMSG_DATA(msg->n);
 
 	if (!(ifa->ifa_flags & IFA_F_SECONDARY))
 		return 0;
 
-	return print_addrinfo(who, n, arg);
+	return print_addrinfo(msg);
 }
 
 struct nlmsg_list
@@ -835,6 +833,7 @@ static int print_selected_addrinfo(int ifindex, struct nlmsg_list *ainfo, FILE *
 	for ( ;ainfo ;  ainfo = ainfo->next) {
 		struct nlmsghdr *n = &ainfo->h;
 		struct ifaddrmsg *ifa = NLMSG_DATA(n);
+		struct nl_msg msg = {};
 
 		if (n->nlmsg_type != RTM_NEWADDR)
 			continue;
@@ -846,16 +845,18 @@ static int print_selected_addrinfo(int ifindex, struct nlmsg_list *ainfo, FILE *
 		    (filter.family && filter.family != ifa->ifa_family))
 			continue;
 
-		print_addrinfo(NULL, n, fp);
+		msg.n = n;
+		msg.arg = fp;
+		print_addrinfo(&msg);
 	}
 	return 0;
 }
 
 
-static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		       void *arg)
+static int store_nlmsg(struct nl_msg *msg)
 {
-	struct nlmsg_chain *lchain = (struct nlmsg_chain *)arg;
+	struct nlmsghdr *n = msg->n;
+	struct nlmsg_chain *lchain = (struct nlmsg_chain *)(msg->arg);
 	struct nlmsg_list *h;
 
 	h = malloc(n->nlmsg_len+sizeof(void*));
@@ -871,7 +872,7 @@ static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		lchain->head = h;
 	lchain->tail = h;
 
-	ll_remember_index(who, n, NULL);
+	ll_remember_index(msg);
 	return 0;
 }
 
@@ -914,9 +915,9 @@ static int ipadd_dump_check_magic(void)
 	return 0;
 }
 
-static int save_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		       void *arg)
+static int save_nlmsg(struct nl_msg *msg)
 {
+	struct nlmsghdr *n = msg->n;
 	int ret;
 
 	ret = write(STDOUT_FILENO, n, n->nlmsg_len);
@@ -928,12 +929,13 @@ static int save_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	return ret == n->nlmsg_len ? 0 : ret;
 }
 
-static int show_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n, void *arg)
+static int show_handler(struct nl_msg *msg)
 {
-	struct ifaddrmsg *ifa = NLMSG_DATA(n);
+	struct nl_msg nl_addr = {.n = msg->n, .arg = stdout };
+	struct ifaddrmsg *ifa = NLMSG_DATA(msg->n);
 
 	printf("if%d:\n", ifa->ifa_index);
-	print_addrinfo(NULL, n, stdout);
+	print_addrinfo(&nl_addr);
 	return 0;
 }
 
@@ -945,8 +947,9 @@ static int ipaddr_showdump(void)
 	exit(rtnl_from_file(stdin, &show_handler, NULL));
 }
 
-static int restore_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n, void *arg)
+static int restore_handler(struct nl_msg *msg)
 {
+	struct nlmsghdr *n = msg->n;
 	int ret;
 
 	n->nlmsg_flags |= NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
@@ -1282,7 +1285,9 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 	}
 
 	for (l = linfo.head; l; l = l->next) {
-		if (no_link || print_linkinfo(NULL, &l->h, stdout) == 0) {
+		struct nl_msg msg = { .n = &l->h, .arg = stdout };
+
+		if (no_link || print_linkinfo(&msg) == 0) {
 			struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
 			if (filter.family != AF_PACKET)
 				print_selected_addrinfo(ifi->ifi_index,
diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index b34dd8b..1ecf0cb 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -53,9 +53,10 @@ static void usage(void)
 	exit(-1);
 }
 
-int print_addrlabel(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+int print_addrlabel(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE*)(msg->arg);
 	struct ifaddrlblmsg *ifal = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *tb[IFAL_MAX+1];
@@ -189,8 +190,9 @@ static int ipaddrlabel_modify(int cmd, int argc, char **argv)
 }
 
 
-static int flush_addrlabel(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+static int flush_addrlabel(struct nl_msg *msg)
 {
+	struct nlmsghdr *n = msg->n;
 	struct rtnl_handle rth2;
 	struct rtmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 5cd8632..23c23e1 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -354,12 +354,12 @@ static int get_response(struct nlmsghdr *n, void *arg)
 	return 0;
 }
 
-static int session_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+static int session_nlmsg(struct nl_msg *msg)
 {
-	int ret = get_response(n, arg);
+	int ret = get_response(msg->n, msg->arg);
 
 	if (ret == 0)
-		print_session(arg);
+		print_session(msg->arg);
 
 	return ret;
 }
@@ -388,12 +388,12 @@ static int get_session(struct l2tp_data *p)
 	return 0;
 }
 
-static int tunnel_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+static int tunnel_nlmsg(struct nl_msg *msg)
 {
-	int ret = get_response(n, arg);
+	int ret = get_response(msg->n, msg->arg);
 
 	if (ret == 0)
-		print_tunnel(arg);
+		print_tunnel(msg->arg);
 
 	return ret;
 }
diff --git a/ip/iplink.c b/ip/iplink.c
index 1a907d9..eb516ba 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -174,9 +174,9 @@ static int get_addr_gen_mode(const char *mode)
 #if IPLINK_IOCTL_COMPAT
 static int have_rtnl_newlink = -1;
 
-static int accept_msg(const struct sockaddr_nl *who,
-		      struct nlmsghdr *n, void *arg)
+static int accept_msg(struct nl_msg *msg)
 {
+	struct nlmsghdr *n = msg->n;
 	struct nlmsgerr *err = (struct nlmsgerr *)NLMSG_DATA(n);
 
 	if (n->nlmsg_type == NLMSG_ERROR &&
@@ -736,6 +736,7 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 	int len;
 	struct iplink_req req;
 	char answer[16384];
+	struct nl_msg msg = {};
 
 	memset(&req, 0, sizeof(req));
 
@@ -758,7 +759,9 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 	if (rtnl_talk(&rth, &req.n, 0, 0, (struct nlmsghdr *)answer) < 0)
 		return -2;
 
-	print_linkinfo(NULL, (struct nlmsghdr *)answer, stdout);
+	msg.n = (struct nlmsghdr *)answer;
+	msg.arg = (void *)stdout;
+	print_linkinfo(&msg);
 
 	return 0;
 }
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 70f2a7a..ad9b2d8 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -36,10 +36,10 @@ static void usage(void)
 	exit(-1);
 }
 
-static int accept_msg(const struct sockaddr_nl *who,
-		      struct nlmsghdr *n, void *arg)
+static int accept_msg(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 
 	if (timestamp)
 		print_timestamp(fp);
@@ -57,32 +57,32 @@ static int accept_msg(const struct sockaddr_nl *who,
 		    r->rtm_family == RTNL_FAMILY_IP6MR) {
 			if (prefix_banner)
 				fprintf(fp, "[MROUTE]");
-			print_mroute(who, n, arg);
+			print_mroute(msg);
 			return 0;
 		} else {
 			if (prefix_banner)
 				fprintf(fp, "[ROUTE]");
-			print_route(who, n, arg);
+			print_route(msg);
 			return 0;
 		}
 	}
 	if (n->nlmsg_type == RTM_NEWLINK || n->nlmsg_type == RTM_DELLINK) {
-		ll_remember_index(who, n, NULL);
+		ll_remember_index(msg);
 		if (prefix_banner)
 			fprintf(fp, "[LINK]");
-		print_linkinfo(who, n, arg);
+		print_linkinfo(msg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWADDR || n->nlmsg_type == RTM_DELADDR) {
 		if (prefix_banner)
 			fprintf(fp, "[ADDR]");
-		print_addrinfo(who, n, arg);
+		print_addrinfo(msg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWADDRLABEL || n->nlmsg_type == RTM_DELADDRLABEL) {
 		if (prefix_banner)
 			fprintf(fp, "[ADDRLABEL]");
-		print_addrlabel(who, n, arg);
+		print_addrlabel(msg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWNEIGH || n->nlmsg_type == RTM_DELNEIGH ||
@@ -96,25 +96,25 @@ static int accept_msg(const struct sockaddr_nl *who,
 
 		if (prefix_banner)
 			fprintf(fp, "[NEIGH]");
-		print_neigh(who, n, arg);
+		print_neigh(msg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWPREFIX) {
 		if (prefix_banner)
 			fprintf(fp, "[PREFIX]");
-		print_prefix(who, n, arg);
+		print_prefix(msg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWRULE || n->nlmsg_type == RTM_DELRULE) {
 		if (prefix_banner)
 			fprintf(fp, "[RULE]");
-		print_rule(who, n, arg);
+		print_rule(msg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWNETCONF) {
 		if (prefix_banner)
 			fprintf(fp, "[NETCONF]");
-		print_netconf(who, n, arg);
+		print_netconf(msg);
 		return 0;
 	}
 	if (n->nlmsg_type == 15) {
diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index be93a98..4880661 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -53,9 +53,10 @@ struct rtfilter
 	inet_prefix msrc;
 } filter;
 
-int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+int print_mroute(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE*)(msg->arg);
 	struct rtmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[RTA_MAX+1];
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 71a4100..95d6cce 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -181,9 +181,10 @@ static int ipneigh_modify(int cmd, int flags, int argc, char **argv)
 }
 
 
-int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+int print_neigh(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE*)(msg->arg);
 	struct ndmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[NDA_MAX+1];
diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
index 0e44cc8..396f8e6 100644
--- a/ip/ipnetconf.c
+++ b/ip/ipnetconf.c
@@ -40,9 +40,10 @@ static void usage(void)
 
 #define NETCONF_RTA(r)	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct netconfmsg))))
 
-int print_netconf(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+int print_netconf(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE*)(msg->arg);
 	struct netconfmsg *ncm = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *tb[NETCONFA_MAX+1];
diff --git a/ip/ipntable.c b/ip/ipntable.c
index ea7ca2d..acbb883 100644
--- a/ip/ipntable.c
+++ b/ip/ipntable.c
@@ -349,9 +349,10 @@ static const char *ntable_strtime_delta(__u32 msec)
 	return str;
 }
 
-int print_ntable(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+int print_ntable(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct ndtmsg *ndtm = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *tb[NDTA_MAX+1];
diff --git a/ip/ipprefix.c b/ip/ipprefix.c
index 02c0efc..1288f90 100644
--- a/ip/ipprefix.c
+++ b/ip/ipprefix.c
@@ -35,9 +35,10 @@
 #define IF_PREFIX_ONLINK	0x01
 #define IF_PREFIX_AUTOCONF	0x02
 
-int print_prefix(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+int print_prefix(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct prefixmsg *prefix = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[RTA_MAX+1];
diff --git a/ip/iproute.c b/ip/iproute.c
index d77b1e3..2aaed91 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -280,9 +280,10 @@ static int calc_host_len(const struct rtmsg *r)
 		return -1;
 }
 
-int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+int print_route(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct rtmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[RTA_MAX+1];
@@ -1078,9 +1079,9 @@ static int iproute_flush_cache(void)
 
 static __u32 route_dump_magic = 0x45311224;
 
-static int save_route(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		      void *arg)
+static int save_route(struct nl_msg *p)
 {
+	struct nlmsghdr *n = p->n;
 	int ret;
 	int len = n->nlmsg_len;
 	struct rtmsg *r = NLMSG_DATA(n);
@@ -1382,6 +1383,7 @@ static int iproute_get(int argc, char **argv)
 	int connected = 0;
 	int from_ok = 0;
 	unsigned int mark = 0;
+	struct nl_msg p = {};
 
 	memset(&req, 0, sizeof(req));
 
@@ -1483,12 +1485,15 @@ static int iproute_get(int argc, char **argv)
 	if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0)
 		exit(2);
 
+	p.n = &req.n;
+	p.arg = (void *)stdout;
+
 	if (connected && !from_ok) {
 		struct rtmsg *r = NLMSG_DATA(&req.n);
 		int len = req.n.nlmsg_len;
 		struct rtattr * tb[RTA_MAX+1];
 
-		if (print_route(NULL, &req.n, (void*)stdout) < 0) {
+		if (print_route(&p) < 0) {
 			fprintf(stderr, "An error :-)\n");
 			exit(1);
 		}
@@ -1525,7 +1530,7 @@ static int iproute_get(int argc, char **argv)
 			exit(2);
 	}
 
-	if (print_route(NULL, &req.n, (void*)stdout) < 0) {
+	if (print_route(&p) < 0) {
 		fprintf(stderr, "An error :-)\n");
 		exit(1);
 	}
@@ -1533,9 +1538,9 @@ static int iproute_get(int argc, char **argv)
 	exit(0);
 }
 
-static int restore_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n,
-			   void *arg)
+static int restore_handler(struct nl_msg *p)
 {
+	struct nlmsghdr *n = p->n;
 	int ret;
 
 	n->nlmsg_flags |= NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
@@ -1576,9 +1581,15 @@ static int iproute_restore(void)
 	exit(rtnl_from_file(stdin, &restore_handler, NULL));
 }
 
-static int show_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n, void *arg)
+static int show_handler(struct nl_msg *p)
 {
-	print_route(nl, n, stdout);
+	struct nl_msg rt_param = {};
+
+	rt_param.n = p->n;
+       	rt_param.who = p->who;
+       	rt_param.arg = (void *)stdout;
+
+	print_route(&rt_param);
 	return 0;
 }
 
diff --git a/ip/iprule.c b/ip/iprule.c
index 366878e..2d7f0f8 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -46,9 +46,10 @@ static void usage(void)
 	exit(-1);
 }
 
-int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+int print_rule(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct rtmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	int host_len = -1;
@@ -392,8 +393,9 @@ static int iprule_modify(int cmd, int argc, char **argv)
 }
 
 
-static int flush_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+static int flush_rule(struct nl_msg *msg)
 {
+	struct nlmsghdr *n = msg->n;
 	struct rtnl_handle rth2;
 	struct rtmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
diff --git a/ip/iptoken.c b/ip/iptoken.c
index 5689c2e..99bdb19 100644
--- a/ip/iptoken.c
+++ b/ip/iptoken.c
@@ -42,9 +42,10 @@ static void usage(void)
 	exit(-1);
 }
 
-static int print_token(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+static int print_token(struct nl_msg *msg)
 {
-	struct rtnl_dump_args *args = arg;
+	struct nlmsghdr *n = msg->n;
+	struct rtnl_dump_args *args = msg->arg;
 	FILE *fp = args->fp;
 	int ifindex = args->ifindex;
 	struct ifinfomsg *ifi = NLMSG_DATA(n);
diff --git a/ip/rtmon.c b/ip/rtmon.c
index 9227eac..3b3cbd8 100644
--- a/ip/rtmon.c
+++ b/ip/rtmon.c
@@ -45,10 +45,10 @@ static void write_stamp(FILE *fp)
 	fwrite((void*)n1, 1, NLMSG_ALIGN(n1->nlmsg_len), fp);
 }
 
-static int dump_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		    void *arg)
+static int dump_msg(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	if (!init_phase)
 		write_stamp(fp);
 	fwrite((void*)n, 1, NLMSG_ALIGN(n->nlmsg_len), fp);
diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
index e0f0344..7ba78c1 100644
--- a/ip/tcp_metrics.c
+++ b/ip/tcp_metrics.c
@@ -88,10 +88,10 @@ static int flush_update(void)
 	return 0;
 }
 
-static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		       void *arg)
+static int process_msg(struct nl_msg *msg)
 {
-	FILE *fp = (FILE *) arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct genlmsghdr *ghdr;
 	struct rtattr *attrs[TCP_METRICS_ATTR_MAX + 1], *a;
 	int len = n->nlmsg_len;
@@ -295,6 +295,7 @@ static int tcpm_do_cmd(int cmd, int argc, char **argv)
 	TCPM_REQUEST(req, 1024, TCP_METRICS_CMD_GET, NLM_F_REQUEST);
 	int atype = -1, stype = -1;
 	int ack;
+	struct nl_msg msg = {};
 
 	memset(&f, 0, sizeof(f));
 	f.daddr.bitlen = -1;
@@ -455,7 +456,9 @@ static int tcpm_do_cmd(int cmd, int argc, char **argv)
 	} else if (atype >= 0) {
 		if (rtnl_talk(&grth, &req.n, 0, 0, &req.n) < 0)
 			return -2;
-		if (process_msg(NULL, &req.n, stdout) < 0) {
+		msg.n = &req.n;
+		msg.arg = (void *)stdout;
+		if (process_msg(&msg) < 0) {
 			fprintf(stderr, "Dump terminated\n");
 			exit(1);
 		}
diff --git a/ip/xfrm.h b/ip/xfrm.h
index 773c92e..fabbe4a 100644
--- a/ip/xfrm.h
+++ b/ip/xfrm.h
@@ -107,10 +107,8 @@ struct xfrm_filter {
 
 extern struct xfrm_filter filter;
 
-int xfrm_state_print(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		     void *arg);
-int xfrm_policy_print(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		      void *arg);
+int xfrm_state_print(struct nl_msg *msg);
+int xfrm_policy_print(struct nl_msg *msg);
 int do_xfrm_state(int argc, char **argv);
 int do_xfrm_policy(int argc, char **argv);
 int do_xfrm_monitor(int argc, char **argv);
diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index 79453e4..14d34c1 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -40,10 +40,10 @@ static void usage(void)
 	exit(-1);
 }
 
-static int xfrm_acquire_print(const struct sockaddr_nl *who,
-			      struct nlmsghdr *n, void *arg)
+static int xfrm_acquire_print(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct xfrm_user_acquire *xacq = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[XFRMA_MAX+1];
@@ -101,10 +101,10 @@ static int xfrm_acquire_print(const struct sockaddr_nl *who,
 	return 0;
 }
 
-static int xfrm_state_flush_print(const struct sockaddr_nl *who,
-				  struct nlmsghdr *n, void *arg)
+static int xfrm_state_flush_print(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct xfrm_usersa_flush *xsf = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	const char *str;
@@ -131,11 +131,11 @@ static int xfrm_state_flush_print(const struct sockaddr_nl *who,
 	return 0;
 }
 
-static int xfrm_policy_flush_print(const struct sockaddr_nl *who,
-				   struct nlmsghdr *n, void *arg)
+static int xfrm_policy_flush_print(struct nl_msg *msg)
 {
+	struct nlmsghdr *n = msg->n;
 	struct rtattr * tb[XFRMA_MAX+1];
-	FILE *fp = (FILE*)arg;
+	FILE *fp = (FILE *)(msg->arg);
 	int len = n->nlmsg_len;
 
 	len -= NLMSG_SPACE(0);
@@ -169,10 +169,10 @@ static int xfrm_policy_flush_print(const struct sockaddr_nl *who,
 	return 0;
 }
 
-static int xfrm_report_print(const struct sockaddr_nl *who,
-			     struct nlmsghdr *n, void *arg)
+static int xfrm_report_print(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct xfrm_user_report *xrep = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[XFRMA_MAX+1];
@@ -234,15 +234,15 @@ static void xfrm_usersa_print(const struct xfrm_usersa_id *sa_id, __u32 reqid, F
 	fprintf(fp, " SPI 0x%x", ntohl(sa_id->spi));
 }
 
-static int xfrm_ae_print(const struct sockaddr_nl *who,
-			     struct nlmsghdr *n, void *arg)
+static int xfrm_ae_print(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct xfrm_aevent_id *id = NLMSG_DATA(n);
 	char abuf[256];
 
 	fprintf(fp, "Async event ");
-	xfrm_ae_flags_print(id->flags, arg);
+	xfrm_ae_flags_print(id->flags, msg->arg);
 	fprintf(fp,"\n\t");
 	memset(abuf, '\0', sizeof(abuf));
 	fprintf(fp, "src %s ", rt_addr_n2a(id->sa_id.family, &id->saddr,
@@ -264,10 +264,10 @@ static void xfrm_print_addr(FILE *fp, int family, xfrm_address_t *a)
 	fprintf(fp, "%s", rt_addr_n2a(family, a, buf, sizeof(buf)));
 }
 
-static int xfrm_mapping_print(const struct sockaddr_nl *who,
-			     struct nlmsghdr *n, void *arg)
+static int xfrm_mapping_print(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct xfrm_user_mapping *map = NLMSG_DATA(n);
 
 	fprintf(fp, "Mapping change ");
@@ -284,10 +284,10 @@ static int xfrm_mapping_print(const struct sockaddr_nl *who,
 	return 0;
 }
 
-static int xfrm_accept_msg(const struct sockaddr_nl *who,
-			   struct nlmsghdr *n, void *arg)
+static int xfrm_accept_msg(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 
 	if (timestamp)
 		print_timestamp(fp);
@@ -297,31 +297,31 @@ static int xfrm_accept_msg(const struct sockaddr_nl *who,
 	case XFRM_MSG_DELSA:
 	case XFRM_MSG_UPDSA:
 	case XFRM_MSG_EXPIRE:
-		xfrm_state_print(who, n, arg);
+		xfrm_state_print(msg);
 		return 0;
 	case XFRM_MSG_NEWPOLICY:
 	case XFRM_MSG_DELPOLICY:
 	case XFRM_MSG_UPDPOLICY:
 	case XFRM_MSG_POLEXPIRE:
-		xfrm_policy_print(who, n, arg);
+		xfrm_policy_print(msg);
 		return 0;
 	case XFRM_MSG_ACQUIRE:
-		xfrm_acquire_print(who, n, arg);
+		xfrm_acquire_print(msg);
 		return 0;
 	case XFRM_MSG_FLUSHSA:
-		xfrm_state_flush_print(who, n, arg);
+		xfrm_state_flush_print(msg);
 		return 0;
 	case XFRM_MSG_FLUSHPOLICY:
-		xfrm_policy_flush_print(who, n, arg);
+		xfrm_policy_flush_print(msg);
 		return 0;
 	case XFRM_MSG_REPORT:
-		xfrm_report_print(who, n, arg);
+		xfrm_report_print(msg);
 		return 0;
 	case XFRM_MSG_NEWAE:
-		xfrm_ae_print(who, n, arg);
+		xfrm_ae_print(msg);
 		return 0;
 	case XFRM_MSG_MAPPING:
-		xfrm_mapping_print(who, n, arg);
+		xfrm_mapping_print(msg);
 		return 0;
 	default:
 		break;
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 2337d35..f70c6b2 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -456,16 +456,16 @@ static int xfrm_policy_filter_match(struct xfrm_userpolicy_info *xpinfo,
 	return 1;
 }
 
-int xfrm_policy_print(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		      void *arg)
+int xfrm_policy_print(struct nl_msg *msg)
 {
+	struct nlmsghdr *n = msg->n;
 	struct rtattr * tb[XFRMA_MAX+1];
 	struct rtattr * rta;
 	struct xfrm_userpolicy_info *xpinfo = NULL;
 	struct xfrm_user_polexpire *xpexp = NULL;
 	struct xfrm_userpolicy_id *xpid = NULL;
 	__u8 ptype = XFRM_POLICY_TYPE_MAIN;
-	FILE *fp = (FILE*)arg;
+	FILE *fp = (FILE *)(msg->arg);
 	int len = n->nlmsg_len;
 
 	if (n->nlmsg_type != XFRM_MSG_NEWPOLICY &&
@@ -686,12 +686,15 @@ static int xfrm_policy_get(int argc, char **argv)
 {
 	char buf[NLMSG_BUF_SIZE];
 	struct nlmsghdr *n = (struct nlmsghdr *)buf;
+	struct nl_msg msg = {};
 
 	memset(buf, 0, sizeof(buf));
 
 	xfrm_policy_get_or_delete(argc, argv, 0, n);
 
-	if (xfrm_policy_print(NULL, n, (void*)stdout) < 0) {
+	msg.n = n;
+	msg.arg = (void *)stdout;
+	if (xfrm_policy_print(&msg) < 0) {
 		fprintf(stderr, "An error :-)\n");
 		exit(1);
 	}
@@ -703,11 +706,10 @@ static int xfrm_policy_get(int argc, char **argv)
  * With an existing policy of nlmsg, make new nlmsg for deleting the policy
  * and store it to buffer.
  */
-static int xfrm_policy_keep(const struct sockaddr_nl *who,
-			    struct nlmsghdr *n,
-			    void *arg)
+static int xfrm_policy_keep(struct nl_msg *msg)
 {
-	struct xfrm_buffer *xb = (struct xfrm_buffer *)arg;
+	struct nlmsghdr *n = msg->n;
+	struct xfrm_buffer *xb = (struct xfrm_buffer *)(msg->arg);
 	struct rtnl_handle *rth = xb->rth;
 	struct xfrm_userpolicy_info *xpinfo = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index fe7708e..ef4c258 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -665,6 +665,7 @@ static int xfrm_state_allocspi(int argc, char **argv)
 	struct xfrm_mark mark = {0, 0};
 	char res_buf[NLMSG_BUF_SIZE];
 	struct nlmsghdr *res_n = (struct nlmsghdr *)res_buf;
+	struct nl_msg msg = {};
 
 	memset(res_buf, 0, sizeof(res_buf));
 
@@ -783,7 +784,9 @@ static int xfrm_state_allocspi(int argc, char **argv)
 	if (rtnl_talk(&rth, &req.n, 0, 0, res_n) < 0)
 		exit(2);
 
-	if (xfrm_state_print(NULL, res_n, (void*)stdout) < 0) {
+	msg.n = res_n;
+	msg.arg = (void *)stdout;
+	if (xfrm_state_print(&msg) < 0) {
 		fprintf(stderr, "An error :-)\n");
 		exit(1);
 	}
@@ -821,10 +824,10 @@ static int xfrm_state_filter_match(struct xfrm_usersa_info *xsinfo)
 	return 1;
 }
 
-int xfrm_state_print(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		     void *arg)
+int xfrm_state_print(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct rtattr * tb[XFRMA_MAX+1];
 	struct rtattr * rta;
 	struct xfrm_usersa_info *xsinfo = NULL;
@@ -975,13 +978,16 @@ static int xfrm_state_get_or_delete(int argc, char **argv, int delete)
 	} else {
 		char buf[NLMSG_BUF_SIZE];
 		struct nlmsghdr *res_n = (struct nlmsghdr *)buf;
+		struct nl_msg msg = {};
 
 		memset(buf, 0, sizeof(buf));
 
 		if (rtnl_talk(&rth, &req.n, 0, 0, res_n) < 0)
 			exit(2);
 
-		if (xfrm_state_print(NULL, res_n, (void*)stdout) < 0) {
+		msg.n = res_n;
+		msg.arg = (void *)stdout;
+		if (xfrm_state_print(&msg) < 0) {
 			fprintf(stderr, "An error :-)\n");
 			exit(1);
 		}
@@ -996,11 +1002,10 @@ static int xfrm_state_get_or_delete(int argc, char **argv, int delete)
  * With an existing state of nlmsg, make new nlmsg for deleting the state
  * and store it to buffer.
  */
-static int xfrm_state_keep(const struct sockaddr_nl *who,
-			   struct nlmsghdr *n,
-			   void *arg)
+static int xfrm_state_keep(struct nl_msg *msg)
 {
-	struct xfrm_buffer *xb = (struct xfrm_buffer *)arg;
+	struct nlmsghdr *n = msg->n;
+	struct xfrm_buffer *xb = (struct xfrm_buffer *)(msg->arg);
 	struct rtnl_handle *rth = xb->rth;
 	struct xfrm_usersa_info *xsinfo = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 9e2a795..a156a59 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -220,6 +220,7 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 		}
 
 		for (a = arg; a->filter; a++) {
+			struct nl_msg msg = {};
 			struct nlmsghdr *h = (struct nlmsghdr*)buf;
 			msglen = status;
 
@@ -249,7 +250,11 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 					}
 					return -1;
 				}
-				err = a->filter(&nladdr, h, a->arg1);
+
+				msg.who = &nladdr;
+				msg.n = h;
+				msg.arg = a->arg1;
+				err = a->filter(&msg);
 				if (err < 0)
 					return err;
 
@@ -450,6 +455,7 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 			exit(1);
 		}
 		for (h = (struct nlmsghdr*)buf; status >= sizeof(*h); ) {
+			struct nl_msg m = {};
 			int err;
 			int len = h->nlmsg_len;
 			int l = len - sizeof(*h);
@@ -463,7 +469,10 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 				exit(1);
 			}
 
-			err = handler(&nladdr, h, jarg);
+			m.who = &nladdr;
+			m.n = h;
+			m.arg = jarg;
+			err = handler(&m);
 			if (err < 0)
 				return err;
 
@@ -495,6 +504,7 @@ int rtnl_from_file(FILE *rtnl, rtnl_filter_t handler,
 	nladdr.nl_groups = 0;
 
 	while (1) {
+		struct nl_msg msg = {};
 		int err, len;
 		int l;
 
@@ -529,7 +539,10 @@ int rtnl_from_file(FILE *rtnl, rtnl_filter_t handler,
 			return -1;
 		}
 
-		err = handler(&nladdr, h, jarg);
+		msg.who = &nladdr;
+		msg.n = h;
+		msg.arg = jarg;
+		err = handler(&msg);
 		if (err < 0)
 			return err;
 	}
diff --git a/lib/ll_map.c b/lib/ll_map.c
index db34a2a..5a64219 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -78,9 +78,9 @@ static struct ll_cache *ll_get_by_name(const char *name)
 	return NULL;
 }
 
-int ll_remember_index(const struct sockaddr_nl *who,
-		      struct nlmsghdr *n, void *arg)
+int ll_remember_index(struct nl_msg *msg)
 {
+	struct nlmsghdr *n = msg->n;
 	unsigned int h;
 	const char *ifname;
 	struct ifinfomsg *ifi = NLMSG_DATA(n);
diff --git a/misc/ifstat.c b/misc/ifstat.c
index a47c046..1eb29d6 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -105,9 +105,9 @@ static int match(const char *id)
 	return 0;
 }
 
-static int get_nlmsg(const struct sockaddr_nl *who,
-		     struct nlmsghdr *m, void *arg)
+static int get_nlmsg(struct nl_msg *msg)
 {
+	struct nlmsghdr *m = msg->n;
 	struct ifinfomsg *ifi = NLMSG_DATA(m);
 	struct rtattr * tb[IFLA_MAX+1];
 	int len = m->nlmsg_len;
diff --git a/tc/m_action.c b/tc/m_action.c
index 7dbcf5b..94ce569 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -319,11 +319,10 @@ tc_print_action(FILE * f, const struct rtattr *arg)
 	return 0;
 }
 
-int print_action(const struct sockaddr_nl *who,
-			   struct nlmsghdr *n,
-			   void *arg)
+int print_action(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct tcamsg *t = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[TCAA_MAX+1];
@@ -460,9 +459,14 @@ static int tc_action_gd(int cmd, unsigned flags, int *argc_p, char ***argv_p)
 		return 1;
 	}
 
-	if (ans && print_action(NULL, &req.n, (void*)stdout) < 0) {
-		fprintf(stderr, "Dump terminated\n");
-		return 1;
+	if (ans) {
+		struct nl_msg msg = {};
+		msg.n = &req.n;
+		msg.arg = (void *)stdout;
+		if (print_action(&msg) < 0) {
+			fprintf(stderr, "Dump terminated\n");
+			return 1;
+		}
 	}
 
 	*argc_p = argc;
diff --git a/tc/tc_class.c b/tc/tc_class.c
index e56bf07..19a8367 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -148,10 +148,10 @@ int filter_ifindex;
 __u32 filter_qdisc;
 __u32 filter_classid;
 
-int print_class(const struct sockaddr_nl *who,
-		       struct nlmsghdr *n, void *arg)
+int print_class(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct tcmsg *t = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[TCA_MAX+1];
diff --git a/tc/tc_common.h b/tc/tc_common.h
index 4f88856..3d75fb6 100644
--- a/tc/tc_common.h
+++ b/tc/tc_common.h
@@ -7,10 +7,10 @@ extern int do_class(int argc, char **argv);
 extern int do_filter(int argc, char **argv);
 extern int do_action(int argc, char **argv);
 extern int do_tcmonitor(int argc, char **argv);
-extern int print_action(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
-extern int print_filter(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
-extern int print_qdisc(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
-extern int print_class(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
+extern int print_action(struct nl_msg *msg);
+extern int print_filter(struct nl_msg *msg);
+extern int print_qdisc(struct nl_msg *msg);
+extern int print_class(struct nl_msg *msg);
 extern void print_size_table(FILE *fp, const char *prefix, struct rtattr *rta);
 
 struct tc_estimator;
diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index c3f2d5f..3f0cda8 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -181,11 +181,10 @@ static __u32 filter_prio;
 static __u32 filter_protocol;
 __u16 f_proto = 0;
 
-int print_filter(const struct sockaddr_nl *who,
-			struct nlmsghdr *n,
-			void *arg)
+int print_filter(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct tcmsg *t = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[TCA_MAX+1];
diff --git a/tc/tc_monitor.c b/tc/tc_monitor.c
index 0efe034..cdf3d6b 100644
--- a/tc/tc_monitor.c
+++ b/tc/tc_monitor.c
@@ -35,26 +35,26 @@ static void usage(void)
 }
 
 
-static int accept_tcmsg(const struct sockaddr_nl *who,
-			struct nlmsghdr *n, void *arg)
+static int accept_tcmsg(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 
 	if (n->nlmsg_type == RTM_NEWTFILTER || n->nlmsg_type == RTM_DELTFILTER) {
-		print_filter(who, n, arg);
+		print_filter(msg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWTCLASS || n->nlmsg_type == RTM_DELTCLASS) {
-		print_class(who, n, arg);
+		print_class(msg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWQDISC || n->nlmsg_type == RTM_DELQDISC) {
-		print_qdisc(who, n, arg);
+		print_qdisc(msg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_GETACTION || n->nlmsg_type == RTM_NEWACTION ||
 	    n->nlmsg_type == RTM_DELACTION) {
-		print_action(who, n, arg);
+		print_action(msg);
 		return 0;
 	}
 	if (n->nlmsg_type != NLMSG_ERROR && n->nlmsg_type != NLMSG_NOOP &&
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index e304858..3754819 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -195,11 +195,10 @@ static int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
 
 static int filter_ifindex;
 
-int print_qdisc(const struct sockaddr_nl *who,
-		       struct nlmsghdr *n,
-		       void *arg)
+int print_qdisc(struct nl_msg *msg)
 {
-	FILE *fp = (FILE*)arg;
+	struct nlmsghdr *n = msg->n;
+	FILE *fp = (FILE *)(msg->arg);
 	struct tcmsg *t = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[TCA_MAX+1];
-- 
2.1.0

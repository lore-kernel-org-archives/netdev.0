From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 2/2] lib/libnetlink: update rtnl_talk to support malloc buff at run time
Date: Fri,  8 Sep 2017 18:14:57 +0800
Message-ID: <1504865697-27274-3-git-send-email-liuhangbin@gmail.com>
References: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>, Phil Sutter <phil@nwl.cc>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33518 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752372AbdIHKPi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 06:15:38 -0400
Received: by mail-pg0-f68.google.com with SMTP id m9so1135657pgd.0
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 03:15:38 -0700 (PDT)
In-Reply-To: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an update for 460c03f3f3cc ("iplink: double the buffer size also in
iplink_get()"). After update, we will not need to double the buffer size
every time when VFs number increased.

With call like rtnl_talk(&rth, &req.n, NULL, 0), we can simply remove the
length parameter.

With call like rtnl_talk(&rth, nlh, nlh, sizeof(req), I add a new variable
answer to avoid overwrite data in nlh, because it may has more info after
nlh. also this will avoid nlh buffer not enough issue.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 bridge/fdb.c         |  2 +-
 bridge/link.c        |  2 +-
 bridge/mdb.c         |  2 +-
 bridge/vlan.c        |  2 +-
 genl/ctrl.c          | 14 ++++++++------
 include/libnetlink.h |  6 +++---
 ip/ipaddress.c       |  5 +++--
 ip/ipaddrlabel.c     |  4 ++--
 ip/ipfou.c           |  4 ++--
 ip/ipila.c           |  4 ++--
 ip/ipl2tp.c          |  8 ++++----
 ip/iplink.c          | 28 +++++++++++-----------------
 ip/iplink_vrf.c      | 24 ++++++++----------------
 ip/ipmacsec.c        |  2 +-
 ip/ipneigh.c         |  2 +-
 ip/ipnetns.c         | 13 +++++++------
 ip/ipntable.c        |  2 +-
 ip/iproute.c         | 20 +++++++++++---------
 ip/iprule.c          |  7 ++++---
 ip/ipseg6.c          |  7 ++++---
 ip/iptoken.c         |  2 +-
 ip/link_gre.c        |  7 ++++---
 ip/link_gre6.c       |  7 ++++---
 ip/link_ip6tnl.c     |  7 ++++---
 ip/link_iptnl.c      |  7 ++++---
 ip/link_vti.c        |  7 ++++---
 ip/link_vti6.c       |  7 ++++---
 ip/tcp_metrics.c     |  7 ++++---
 ip/xfrm_policy.c     | 22 +++++++++++-----------
 ip/xfrm_state.c      | 25 ++++++++++++-------------
 lib/libgenl.c        |  5 +++--
 lib/libnetlink.c     | 20 +++++++++-----------
 misc/ss.c            |  2 +-
 tc/m_action.c        |  9 ++++-----
 tc/tc_class.c        |  2 +-
 tc/tc_filter.c       |  7 ++++---
 tc/tc_qdisc.c        |  2 +-
 37 files changed, 151 insertions(+), 152 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index e5cebf9..807914f 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -535,7 +535,7 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 		return -1;
 	}
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		return -1;
 
 	return 0;
diff --git a/bridge/link.c b/bridge/link.c
index 93472ad..cc29a2a 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -426,7 +426,7 @@ static int brlink_modify(int argc, char **argv)
 		addattr_nest_end(&req.n, nest);
 	}
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		return -1;
 
 	return 0;
diff --git a/bridge/mdb.c b/bridge/mdb.c
index e60ff3e..fbd8184 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -298,7 +298,7 @@ static int mdb_modify(int cmd, int flags, int argc, char **argv)
 	entry.vid = vid;
 	addattr_l(&req.n, sizeof(req), MDBA_SET_ENTRY, &entry, sizeof(entry));
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		return -1;
 
 	return 0;
diff --git a/bridge/vlan.c b/bridge/vlan.c
index ebcdace..5d68359 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -133,7 +133,7 @@ static int vlan_modify(int cmd, int argc, char **argv)
 
 	addattr_nest_end(&req.n, afspec);
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		return -1;
 
 	return 0;
diff --git a/genl/ctrl.c b/genl/ctrl.c
index 448988e..699657b 100644
--- a/genl/ctrl.c
+++ b/genl/ctrl.c
@@ -55,6 +55,7 @@ int genl_ctrl_resolve_family(const char *family)
 	};
 	struct nlmsghdr *nlh = &req.n;
 	struct genlmsghdr *ghdr = &req.g;
+	struct nlmsghdr *answer = NULL;
 
 	if (rtnl_open_byproto(&rth, 0, NETLINK_GENERIC) < 0) {
 		fprintf(stderr, "Cannot open generic netlink socket\n");
@@ -63,19 +64,19 @@ int genl_ctrl_resolve_family(const char *family)
 
 	addattr_l(nlh, 128, CTRL_ATTR_FAMILY_NAME, family, strlen(family) + 1);
 
-	if (rtnl_talk(&rth, nlh, nlh, sizeof(req)) < 0) {
+	if (rtnl_talk(&rth, nlh, &answer) < 0) {
 		fprintf(stderr, "Error talking to the kernel\n");
 		goto errout;
 	}
 
 	{
 		struct rtattr *tb[CTRL_ATTR_MAX + 1];
-		int len = nlh->nlmsg_len;
+		int len = answer->nlmsg_len;
 		struct rtattr *attrs;
 
-		if (nlh->nlmsg_type !=  GENL_ID_CTRL) {
+		if (answer->nlmsg_type !=  GENL_ID_CTRL) {
 			fprintf(stderr, "Not a controller message, nlmsg_len=%d "
-				"nlmsg_type=0x%x\n", nlh->nlmsg_len, nlh->nlmsg_type);
+				"nlmsg_type=0x%x\n", answer->nlmsg_len, answer->nlmsg_type);
 			goto errout;
 		}
 
@@ -299,6 +300,7 @@ static int ctrl_list(int cmd, int argc, char **argv)
 		.g.cmd = CTRL_CMD_GETFAMILY,
 	};
 	struct nlmsghdr *nlh = &req.n;
+	struct nlmsghdr *answer = NULL;
 
 	if (rtnl_open_byproto(&rth, 0, NETLINK_GENERIC) < 0) {
 		fprintf(stderr, "Cannot open generic netlink socket\n");
@@ -331,12 +333,12 @@ static int ctrl_list(int cmd, int argc, char **argv)
 			goto ctrl_done;
 		}
 
-		if (rtnl_talk(&rth, nlh, nlh, sizeof(req)) < 0) {
+		if (rtnl_talk(&rth, nlh, &answer) < 0) {
 			fprintf(stderr, "Error talking to the kernel\n");
 			goto ctrl_done;
 		}
 
-		if (print_ctrl2(NULL, nlh, (void *) stdout) < 0) {
+		if (print_ctrl2(NULL, answer, (void *) stdout) < 0) {
 			fprintf(stderr, "Dump terminated\n");
 			goto ctrl_done;
 		}
diff --git a/include/libnetlink.h b/include/libnetlink.h
index 69257f0..77b6260 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -93,13 +93,13 @@ int rtnl_dump_filter_nc(struct rtnl_handle *rth,
 #define rtnl_dump_filter(rth, filter, arg) \
 	rtnl_dump_filter_nc(rth, filter, arg, 0)
 int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
-	      struct nlmsghdr *answer, size_t len)
+	      struct nlmsghdr **answer)
 	__attribute__((warn_unused_result));
 int rtnl_talk_extack(struct rtnl_handle *rtnl, struct nlmsghdr *n,
-	      struct nlmsghdr *answer, size_t len, nl_ext_ack_fn_t errfn)
+	      struct nlmsghdr **answer, nl_ext_ack_fn_t errfn)
 	__attribute__((warn_unused_result));
 int rtnl_talk_suppress_rtnl_errmsg(struct rtnl_handle *rtnl, struct nlmsghdr *n,
-				   struct nlmsghdr *answer, size_t len)
+				   struct nlmsghdr **answer)
 	__attribute__((warn_unused_result));
 int rtnl_send(struct rtnl_handle *rth, const void *buf, int)
 	__attribute__((warn_unused_result));
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index c9312f0..f84e591 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1385,12 +1385,13 @@ static int restore_handler(const struct sockaddr_nl *nl,
 			   struct nlmsghdr *n, void *arg)
 {
 	int ret;
+	struct nlmsghdr *answer = NULL;
 
 	n->nlmsg_flags |= NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
 
 	ll_init_map(&rth);
 
-	ret = rtnl_talk(&rth, n, n, sizeof(*n));
+	ret = rtnl_talk(&rth, n, &answer);
 	if ((ret < 0) && (errno == EEXIST))
 		ret = 0;
 
@@ -2076,7 +2077,7 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 		return -1;
 	}
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index 1d324da..6ea9bff 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -176,7 +176,7 @@ static int ipaddrlabel_modify(int cmd, int argc, char **argv)
 	if (req.ifal.ifal_family == AF_UNSPEC)
 		req.ifal.ifal_family = AF_INET6;
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
@@ -203,7 +203,7 @@ static int flush_addrlabel(const struct sockaddr_nl *who, struct nlmsghdr *n, vo
 		if (rtnl_open(&rth2, 0) < 0)
 			return -1;
 
-		if (rtnl_talk(&rth2, n, NULL, 0) < 0)
+		if (rtnl_talk(&rth2, n, NULL) < 0)
 			return -2;
 
 		rtnl_close(&rth2);
diff --git a/ip/ipfou.c b/ip/ipfou.c
index 00dbe15..23000dc 100644
--- a/ip/ipfou.c
+++ b/ip/ipfou.c
@@ -116,7 +116,7 @@ static int do_add(int argc, char **argv)
 
 	fou_parse_opt(argc, argv, &req.n, true);
 
-	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
@@ -128,7 +128,7 @@ static int do_del(int argc, char **argv)
 
 	fou_parse_opt(argc, argv, &req.n, false);
 
-	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
diff --git a/ip/ipila.c b/ip/ipila.c
index 843cc16..0403fc4 100644
--- a/ip/ipila.c
+++ b/ip/ipila.c
@@ -220,7 +220,7 @@ static int do_add(int argc, char **argv)
 
 	ila_parse_opt(argc, argv, &req.n, true);
 
-	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
@@ -232,7 +232,7 @@ static int do_del(int argc, char **argv)
 
 	ila_parse_opt(argc, argv, &req.n, false);
 
-	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 88664c9..742adbe 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -129,7 +129,7 @@ static int create_tunnel(struct l2tp_parm *p)
 			addattr(&req.n, 1024, L2TP_ATTR_UDP_ZERO_CSUM6_RX);
 	}
 
-	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
@@ -142,7 +142,7 @@ static int delete_tunnel(struct l2tp_parm *p)
 
 	addattr32(&req.n, 128, L2TP_ATTR_CONN_ID, p->tunnel_id);
 
-	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
@@ -185,7 +185,7 @@ static int create_session(struct l2tp_parm *p)
 	if (p->ifname && p->ifname[0])
 		addattrstrz(&req.n, 1024, L2TP_ATTR_IFNAME, p->ifname);
 
-	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
@@ -198,7 +198,7 @@ static int delete_session(struct l2tp_parm *p)
 
 	addattr32(&req.n, 1024, L2TP_ATTR_CONN_ID, p->tunnel_id);
 	addattr32(&req.n, 1024, L2TP_ATTR_SESSION_ID, p->session_id);
-	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
diff --git a/ip/iplink.c b/ip/iplink.c
index 72c3479..e078d2a 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -248,16 +248,18 @@ static int nl_get_ll_addr_len(unsigned int dev_index)
 			.ifi_index = dev_index,
 		}
 	};
+	struct nlmsghdr *answer = NULL;
 	struct rtattr *tb[IFLA_MAX+1];
 
-	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
+	if (rtnl_talk(&rth, &req.n, &answer) < 0)
 		return -1;
 
-	len = req.n.nlmsg_len - NLMSG_LENGTH(sizeof(req.i));
+	len = answer->nlmsg_len - NLMSG_LENGTH(sizeof(struct ifinfomsg));
 	if (len < 0)
 		return -1;
 
-	parse_rtattr_flags(tb, IFLA_MAX, IFLA_RTA(&req.i), len, NLA_F_NESTED);
+	parse_rtattr_flags(tb, IFLA_MAX, IFLA_RTA(NLMSG_DATA(answer)),
+			   len, NLA_F_NESTED);
 	if (!tb[IFLA_ADDRESS])
 		return -1;
 
@@ -912,7 +914,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 			req.i.ifi_index = 0;
 			addattr32(&req.n, sizeof(req), IFLA_GROUP, group);
-			if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+			if (rtnl_talk(&rth, &req.n, NULL) < 0)
 				return -2;
 			return 0;
 		}
@@ -1007,7 +1009,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 		return -1;
 	}
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
@@ -1022,10 +1024,7 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 		.n.nlmsg_type = RTM_GETLINK,
 		.i.ifi_family = preferred_family,
 	};
-	struct {
-		struct nlmsghdr n;
-		char buf[32768];
-	} answer;
+	struct nlmsghdr *answer = NULL;
 
 	if (name) {
 		len = strlen(name) + 1;
@@ -1038,18 +1037,13 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 	}
 	addattr32(&req.n, sizeof(req), IFLA_EXT_MASK, filt_mask);
 
-	if (rtnl_talk(&rth, &req.n, &answer.n, sizeof(answer)) < 0)
-		return -2;
-	if (answer.n.nlmsg_len > sizeof(answer.buf)) {
-		fprintf(stderr, "Message truncated from %u to %lu\n",
-			answer.n.nlmsg_len, sizeof(answer.buf));
+	if (rtnl_talk(&rth, &req.n, &answer) < 0)
 		return -2;
-	}
 
 	if (brief)
-		print_linkinfo_brief(NULL, &answer.n, stdout, NULL);
+		print_linkinfo_brief(NULL, answer, stdout, NULL);
 	else
-		print_linkinfo(NULL, &answer.n, stdout);
+		print_linkinfo(NULL, answer, stdout);
 
 	return 0;
 }
diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
index 2b85a3a..6dbc8b4 100644
--- a/ip/iplink_vrf.c
+++ b/ip/iplink_vrf.c
@@ -114,10 +114,7 @@ __u32 ipvrf_get_table(const char *name)
 			.ifi_family  = preferred_family,
 		},
 	};
-	struct {
-		struct nlmsghdr n;
-		char buf[8192];
-	} answer;
+	struct nlmsghdr *answer = NULL;
 	struct rtattr *tb[IFLA_MAX+1];
 	struct rtattr *li[IFLA_INFO_MAX+1];
 	struct rtattr *vrf_attr[IFLA_VRF_MAX + 1];
@@ -127,8 +124,7 @@ __u32 ipvrf_get_table(const char *name)
 
 	addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, strlen(name) + 1);
 
-	if (rtnl_talk_suppress_rtnl_errmsg(&rth, &req.n,
-					   &answer.n, sizeof(answer)) < 0) {
+	if (rtnl_talk_suppress_rtnl_errmsg(&rth, &req.n, &answer) < 0) {
 		/* special case "default" vrf to be the main table */
 		if (errno == ENODEV && !strcmp(name, "default"))
 			if (rtnl_rttable_a2n(&tb_id, "main"))
@@ -138,8 +134,8 @@ __u32 ipvrf_get_table(const char *name)
 		return tb_id;
 	}
 
-	ifi = NLMSG_DATA(&answer.n);
-	len = answer.n.nlmsg_len - NLMSG_LENGTH(sizeof(*ifi));
+	ifi = NLMSG_DATA(answer);
+	len = answer->nlmsg_len - NLMSG_LENGTH(sizeof(*ifi));
 	if (len < 0) {
 		fprintf(stderr, "BUG: Invalid response to link query.\n");
 		return 0;
@@ -184,10 +180,7 @@ int name_is_vrf(const char *name)
 			.ifi_family  = preferred_family,
 		},
 	};
-	struct {
-		struct nlmsghdr n;
-		char buf[8192];
-	} answer;
+	struct nlmsghdr *answer = NULL;
 	struct rtattr *tb[IFLA_MAX+1];
 	struct rtattr *li[IFLA_INFO_MAX+1];
 	struct ifinfomsg *ifi;
@@ -195,12 +188,11 @@ int name_is_vrf(const char *name)
 
 	addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, strlen(name) + 1);
 
-	if (rtnl_talk_suppress_rtnl_errmsg(&rth, &req.n,
-					   &answer.n, sizeof(answer)) < 0)
+	if (rtnl_talk_suppress_rtnl_errmsg(&rth, &req.n, &answer) < 0)
 		return 0;
 
-	ifi = NLMSG_DATA(&answer.n);
-	len = answer.n.nlmsg_len - NLMSG_LENGTH(sizeof(*ifi));
+	ifi = NLMSG_DATA(answer);
+	len = answer->nlmsg_len - NLMSG_LENGTH(sizeof(*ifi));
 	if (len < 0) {
 		fprintf(stderr, "BUG: Invalid response to link query.\n");
 		return 0;
diff --git a/ip/ipmacsec.c b/ip/ipmacsec.c
index aa89a00..9a2d0eb 100644
--- a/ip/ipmacsec.c
+++ b/ip/ipmacsec.c
@@ -421,7 +421,7 @@ static int do_modify_nl(enum cmd c, enum macsec_nl_commands cmd, int ifindex,
 	addattr_nest_end(&req.n, attr_sa);
 
 talk:
-	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 9c38a60..32f2d55 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -184,7 +184,7 @@ static int ipneigh_modify(int cmd, int flags, int argc, char **argv)
 		return -1;
 	}
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		exit(2);
 
 	return 0;
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index afb4978..628dfb1 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -95,12 +95,13 @@ static int get_netnsid_from_name(const char *name)
 		struct nlmsghdr n;
 		struct rtgenmsg g;
 		char            buf[1024];
-	} answer, req = {
+	} req = {
 		.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
 		.n.nlmsg_flags = NLM_F_REQUEST,
 		.n.nlmsg_type = RTM_GETNSID,
 		.g.rtgen_family = AF_UNSPEC,
 	};
+	struct nlmsghdr *answer = NULL;
 	struct rtattr *tb[NETNSA_MAX + 1];
 	struct rtgenmsg *rthdr;
 	int len, fd;
@@ -110,18 +111,18 @@ static int get_netnsid_from_name(const char *name)
 		return fd;
 
 	addattr32(&req.n, 1024, NETNSA_FD, fd);
-	if (rtnl_talk(&rtnsh, &req.n, &answer.n, sizeof(answer)) < 0) {
+	if (rtnl_talk(&rtnsh, &req.n, &answer) < 0) {
 		close(fd);
 		return -2;
 	}
 	close(fd);
 
 	/* Validate message and parse attributes */
-	if (answer.n.nlmsg_type == NLMSG_ERROR)
+	if (answer->nlmsg_type == NLMSG_ERROR)
 		return -1;
 
-	rthdr = NLMSG_DATA(&answer.n);
-	len = answer.n.nlmsg_len - NLMSG_SPACE(sizeof(*rthdr));
+	rthdr = NLMSG_DATA(answer);
+	len = answer->nlmsg_len - NLMSG_SPACE(sizeof(*rthdr));
 	if (len < 0)
 		return -1;
 
@@ -689,7 +690,7 @@ static int set_netnsid_from_name(const char *name, int nsid)
 
 	addattr32(&req.n, 1024, NETNSA_FD, fd);
 	addattr32(&req.n, 1024, NETNSA_NSID, nsid);
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		err = -2;
 
 	close(fd);
diff --git a/ip/ipntable.c b/ip/ipntable.c
index 88236ce..2f72c98 100644
--- a/ip/ipntable.c
+++ b/ip/ipntable.c
@@ -304,7 +304,7 @@ static int ipntable_modify(int cmd, int flags, int argc, char **argv)
 			  RTA_PAYLOAD(parms_rta));
 	}
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		exit(2);
 
 	return 0;
diff --git a/ip/iproute.c b/ip/iproute.c
index 83fd70c..aa929d9 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1298,7 +1298,7 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
 	if (!type_ok && req.r.rtm_family == AF_MPLS)
 		req.r.rtm_type = RTN_UNICAST;
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
@@ -1678,6 +1678,7 @@ static int iproute_get(int argc, char **argv)
 	};
 	char  *idev = NULL;
 	char  *odev = NULL;
+	struct nlmsghdr *answer = NULL;
 	int connected = 0;
 	int fib_match = 0;
 	int from_ok = 0;
@@ -1798,20 +1799,20 @@ static int iproute_get(int argc, char **argv)
 	if (fib_match)
 		req.r.rtm_flags |= RTM_F_FIB_MATCH;
 
-	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
+	if (rtnl_talk(&rth, &req.n, &answer) < 0)
 		return -2;
 
 	if (connected && !from_ok) {
-		struct rtmsg *r = NLMSG_DATA(&req.n);
-		int len = req.n.nlmsg_len;
+		struct rtmsg *r = NLMSG_DATA(answer);
+		int len = answer->nlmsg_len;
 		struct rtattr *tb[RTA_MAX+1];
 
-		if (print_route(NULL, &req.n, (void *)stdout) < 0) {
+		if (print_route(NULL, answer, (void *)stdout) < 0) {
 			fprintf(stderr, "An error :-)\n");
 			return -1;
 		}
 
-		if (req.n.nlmsg_type != RTM_NEWROUTE) {
+		if (answer->nlmsg_type != RTM_NEWROUTE) {
 			fprintf(stderr, "Not a route?\n");
 			return -1;
 		}
@@ -1841,11 +1842,11 @@ static int iproute_get(int argc, char **argv)
 		req.n.nlmsg_flags = NLM_F_REQUEST;
 		req.n.nlmsg_type = RTM_GETROUTE;
 
-		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
+		if (rtnl_talk(&rth, &req.n, &answer) < 0)
 			return -2;
 	}
 
-	if (print_route(NULL, &req.n, (void *)stdout) < 0) {
+	if (print_route(NULL, answer, (void *)stdout) < 0) {
 		fprintf(stderr, "An error :-)\n");
 		return -1;
 	}
@@ -1869,6 +1870,7 @@ static int restore_handler(const struct sockaddr_nl *nl,
 	struct rtattr *tb[RTA_MAX+1];
 	int len = n->nlmsg_len - NLMSG_LENGTH(sizeof(*r));
 	int ret, prio = *(int *)arg;
+	struct nlmsghdr *answer = NULL;
 
 	parse_rtattr(tb, RTA_MAX, RTM_RTA(r), len);
 
@@ -1893,7 +1895,7 @@ restore:
 
 	ll_init_map(&rth);
 
-	ret = rtnl_talk(&rth, n, n, sizeof(*n));
+	ret = rtnl_talk(&rth, n, &answer);
 	if ((ret < 0) && (errno == EEXIST))
 		ret = 0;
 
diff --git a/ip/iprule.c b/ip/iprule.c
index 8313138..872cfd2 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -393,7 +393,7 @@ static int flush_rule(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		if (rtnl_open(&rth2, 0) < 0)
 			return -1;
 
-		if (rtnl_talk(&rth2, n, NULL, 0) < 0)
+		if (rtnl_talk(&rth2, n, NULL) < 0)
 			return -2;
 
 		rtnl_close(&rth2);
@@ -548,12 +548,13 @@ static int restore_handler(const struct sockaddr_nl *nl,
 			   struct nlmsghdr *n, void *arg)
 {
 	int ret;
+	struct nlmsghdr *answer = NULL;
 
 	n->nlmsg_flags |= NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
 
 	ll_init_map(&rth);
 
-	ret = rtnl_talk(&rth, n, n, sizeof(*n));
+	ret = rtnl_talk(&rth, n, &answer);
 	if ((ret < 0) && (errno == EEXIST))
 		ret = 0;
 
@@ -760,7 +761,7 @@ static int iprule_modify(int cmd, int argc, char **argv)
 	if (!table_ok && cmd == RTM_NEWRULE)
 		req.r.rtm_table = RT_TABLE_MAIN;
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
diff --git a/ip/ipseg6.c b/ip/ipseg6.c
index a8f5c69..6d7b1d0 100644
--- a/ip/ipseg6.c
+++ b/ip/ipseg6.c
@@ -125,6 +125,7 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 static int seg6_do_cmd(void)
 {
 	SEG6_REQUEST(req, 1024, opts.cmd, NLM_F_REQUEST);
+	struct nlmsghdr *answer = NULL;
 	int repl = 0, dump = 0;
 
 	if (genl_family < 0) {
@@ -163,12 +164,12 @@ static int seg6_do_cmd(void)
 	}
 
 	if (!repl && !dump) {
-		if (rtnl_talk(&grth, &req.n, NULL, 0) < 0)
+		if (rtnl_talk(&grth, &req.n, NULL) < 0)
 			return -1;
 	} else if (repl) {
-		if (rtnl_talk(&grth, &req.n, &req.n, sizeof(req)) < 0)
+		if (rtnl_talk(&grth, &req.n, &answer) < 0)
 			return -2;
-		if (process_msg(NULL, &req.n, stdout) < 0) {
+		if (process_msg(NULL, answer, stdout) < 0) {
 			fprintf(stderr, "Error parsing reply\n");
 			exit(1);
 		}
diff --git a/ip/iptoken.c b/ip/iptoken.c
index 1869f76..0528bad 100644
--- a/ip/iptoken.c
+++ b/ip/iptoken.c
@@ -166,7 +166,7 @@ static int iptoken_set(int argc, char **argv, bool delete)
 	addattr_nest_end(&req.n, afs6);
 	addattr_nest_end(&req.n, afs);
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		return -2;
 
 	return 0;
diff --git a/ip/link_gre.c b/ip/link_gre.c
index c2ec5f2..21131ab 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -75,6 +75,7 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 		.i.ifi_family = preferred_family,
 		.i.ifi_index = ifi->ifi_index,
 	};
+	struct nlmsghdr *answer = NULL;
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct rtattr *greinfo[IFLA_GRE_MAX + 1];
@@ -98,19 +99,19 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 fwmark = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
-		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
+		if (rtnl_talk(&rth, &req.n, &answer) < 0) {
 get_failed:
 			fprintf(stderr,
 				"Failed to get existing tunnel info.\n");
 			return -1;
 		}
 
-		len = req.n.nlmsg_len;
+		len = answer->nlmsg_len;
 		len -= NLMSG_LENGTH(sizeof(*ifi));
 		if (len < 0)
 			goto get_failed;
 
-		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(&req.i), len);
+		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(answer + sizeof(struct nlmsghdr)), len);
 
 		if (!tb[IFLA_LINKINFO])
 			goto get_failed;
diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index 78b5215..98e689e 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -86,6 +86,7 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 		.i.ifi_family = preferred_family,
 		.i.ifi_index = ifi->ifi_index,
 	};
+	struct nlmsghdr *answer = NULL;
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct rtattr *greinfo[IFLA_GRE_MAX + 1];
@@ -108,19 +109,19 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 fwmark = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
-		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
+		if (rtnl_talk(&rth, &req.n, &answer) < 0) {
 get_failed:
 			fprintf(stderr,
 				"Failed to get existing tunnel info.\n");
 			return -1;
 		}
 
-		len = req.n.nlmsg_len;
+		len = answer->nlmsg_len;
 		len -= NLMSG_LENGTH(sizeof(*ifi));
 		if (len < 0)
 			goto get_failed;
 
-		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(&req.i), len);
+		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(NLMSG_DATA(answer)), len);
 
 		if (!tb[IFLA_LINKINFO])
 			goto get_failed;
diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index 505fb47..19e0ca6 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -83,6 +83,7 @@ static int ip6tunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 		.i.ifi_family = preferred_family,
 		.i.ifi_index = ifi->ifi_index,
 	};
+	struct nlmsghdr *answer = NULL;
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct rtattr *iptuninfo[IFLA_IPTUN_MAX + 1];
@@ -103,19 +104,19 @@ static int ip6tunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 fwmark = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
-		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
+		if (rtnl_talk(&rth, &req.n, &answer) < 0) {
 get_failed:
 			fprintf(stderr,
 				"Failed to get existing tunnel info.\n");
 			return -1;
 		}
 
-		len = req.n.nlmsg_len;
+		len = answer->nlmsg_len;
 		len -= NLMSG_LENGTH(sizeof(*ifi));
 		if (len < 0)
 			goto get_failed;
 
-		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(&req.i), len);
+		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(NLMSG_DATA(answer)), len);
 
 		if (!tb[IFLA_LINKINFO])
 			goto get_failed;
diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index d24e737..0ea957b 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -84,6 +84,7 @@ static int iptunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 		.i.ifi_family = preferred_family,
 		.i.ifi_index = ifi->ifi_index,
 	};
+	struct nlmsghdr *answer = NULL;
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct rtattr *iptuninfo[IFLA_IPTUN_MAX + 1];
@@ -108,19 +109,19 @@ static int iptunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 fwmark = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
-		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
+		if (rtnl_talk(&rth, &req.n, &answer) < 0) {
 get_failed:
 			fprintf(stderr,
 				"Failed to get existing tunnel info.\n");
 			return -1;
 		}
 
-		len = req.n.nlmsg_len;
+		len = answer->nlmsg_len;
 		len -= NLMSG_LENGTH(sizeof(*ifi));
 		if (len < 0)
 			goto get_failed;
 
-		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(&req.i), len);
+		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(NLMSG_DATA(answer)), len);
 
 		if (!tb[IFLA_LINKINFO])
 			goto get_failed;
diff --git a/ip/link_vti.c b/ip/link_vti.c
index 3ffecfa..de15b4a 100644
--- a/ip/link_vti.c
+++ b/ip/link_vti.c
@@ -61,6 +61,7 @@ static int vti_parse_opt(struct link_util *lu, int argc, char **argv,
 		.i.ifi_family = preferred_family,
 		.i.ifi_index = ifi->ifi_index,
 	};
+	struct nlmsghdr *answer = NULL;
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct rtattr *vtiinfo[IFLA_VTI_MAX + 1];
@@ -73,19 +74,19 @@ static int vti_parse_opt(struct link_util *lu, int argc, char **argv,
 	int len;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
-		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
+		if (rtnl_talk(&rth, &req.n, &answer) < 0) {
 get_failed:
 			fprintf(stderr,
 				"Failed to get existing tunnel info.\n");
 			return -1;
 		}
 
-		len = req.n.nlmsg_len;
+		len = answer->nlmsg_len;
 		len -= NLMSG_LENGTH(sizeof(*ifi));
 		if (len < 0)
 			goto get_failed;
 
-		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(&req.i), len);
+		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(NLMSG_DATA(answer)), len);
 
 		if (!tb[IFLA_LINKINFO])
 			goto get_failed;
diff --git a/ip/link_vti6.c b/ip/link_vti6.c
index 6ea1fc2..663ee03 100644
--- a/ip/link_vti6.c
+++ b/ip/link_vti6.c
@@ -56,6 +56,7 @@ static int vti6_parse_opt(struct link_util *lu, int argc, char **argv,
 		.i.ifi_family = preferred_family,
 		.i.ifi_index = ifi->ifi_index,
 	};
+	struct nlmsghdr *answer = NULL;
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct rtattr *vtiinfo[IFLA_VTI_MAX + 1];
@@ -68,19 +69,19 @@ static int vti6_parse_opt(struct link_util *lu, int argc, char **argv,
 	int len;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
-		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
+		if (rtnl_talk(&rth, &req.n, &answer) < 0) {
 get_failed:
 			fprintf(stderr,
 				"Failed to get existing tunnel info.\n");
 			return -1;
 		}
 
-		len = req.n.nlmsg_len;
+		len = answer->nlmsg_len;
 		len -= NLMSG_LENGTH(sizeof(*ifi));
 		if (len < 0)
 			goto get_failed;
 
-		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(&req.i), len);
+		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(NLMSG_DATA(answer)), len);
 
 		if (!tb[IFLA_LINKINFO])
 			goto get_failed;
diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
index 8972acd..547d791 100644
--- a/ip/tcp_metrics.c
+++ b/ip/tcp_metrics.c
@@ -306,6 +306,7 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 static int tcpm_do_cmd(int cmd, int argc, char **argv)
 {
 	TCPM_REQUEST(req, 1024, TCP_METRICS_CMD_GET, NLM_F_REQUEST);
+	struct nlmsghdr *answer = NULL;
 	int atype = -1, stype = -1;
 	int ack;
 
@@ -457,12 +458,12 @@ static int tcpm_do_cmd(int cmd, int argc, char **argv)
 	}
 
 	if (ack) {
-		if (rtnl_talk(&grth, &req.n, NULL, 0) < 0)
+		if (rtnl_talk(&grth, &req.n, NULL) < 0)
 			return -2;
 	} else if (atype >= 0) {
-		if (rtnl_talk(&grth, &req.n, &req.n, sizeof(req)) < 0)
+		if (rtnl_talk(&grth, &req.n, &answer) < 0)
 			return -2;
-		if (process_msg(NULL, &req.n, stdout) < 0) {
+		if (process_msg(NULL, answer, stdout) < 0) {
 			fprintf(stderr, "Dump terminated\n");
 			exit(1);
 		}
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index de689c4..c794779 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -386,7 +386,7 @@ static int xfrm_policy_modify(int cmd, unsigned int flags, int argc, char **argv
 	if (req.xpinfo.sel.family == AF_UNSPEC)
 		req.xpinfo.sel.family = AF_INET;
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		exit(2);
 
 	rtnl_close(&rth);
@@ -548,7 +548,7 @@ int xfrm_policy_print(const struct sockaddr_nl *who, struct nlmsghdr *n,
 }
 
 static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
-				     void *res_nlbuf, size_t res_size)
+				     struct nlmsghdr **answer)
 {
 	struct rtnl_handle rth;
 	struct {
@@ -659,7 +659,7 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 			  (void *)&ctx, ctx.sctx.len);
 	}
 
-	if (rtnl_talk(&rth, &req.n, res_nlbuf, res_size) < 0)
+	if (rtnl_talk(&rth, &req.n, answer) < 0)
 		exit(2);
 
 	rtnl_close(&rth);
@@ -669,15 +669,14 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 
 static int xfrm_policy_delete(int argc, char **argv)
 {
-	return xfrm_policy_get_or_delete(argc, argv, 1, NULL, 0);
+	return xfrm_policy_get_or_delete(argc, argv, 1, NULL);
 }
 
 static int xfrm_policy_get(int argc, char **argv)
 {
-	char buf[NLMSG_BUF_SIZE] = {};
-	struct nlmsghdr *n = (struct nlmsghdr *)buf;
+	struct nlmsghdr *n = NULL;
 
-	xfrm_policy_get_or_delete(argc, argv, 0, n, sizeof(buf));
+	xfrm_policy_get_or_delete(argc, argv, 0, &n);
 
 	if (xfrm_policy_print(NULL, n, (void *)stdout) < 0) {
 		fprintf(stderr, "An error :-)\n");
@@ -1049,7 +1048,7 @@ static int xfrm_spd_setinfo(int argc, char **argv)
 	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
 		exit(1);
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		exit(2);
 
 	rtnl_close(&rth);
@@ -1070,14 +1069,15 @@ static int xfrm_spd_getinfo(int argc, char **argv)
 		.n.nlmsg_type = XFRM_MSG_GETSPDINFO,
 		.flags = 0XFFFFFFFF,
 	};
+	struct nlmsghdr *answer = NULL;
 
 	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
 		exit(1);
 
-	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
+	if (rtnl_talk(&rth, &req.n, &answer) < 0)
 		exit(2);
 
-	print_spdinfo(&req.n, (void *)stdout);
+	print_spdinfo(answer, (void *)stdout);
 
 	rtnl_close(&rth);
 
@@ -1123,7 +1123,7 @@ static int xfrm_policy_flush(int argc, char **argv)
 	if (show_stats > 1)
 		fprintf(stderr, "Flush policy\n");
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		exit(2);
 
 	rtnl_close(&rth);
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 4483fb8..02d3efa 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -726,7 +726,7 @@ static int xfrm_state_modify(int cmd, unsigned int flags, int argc, char **argv)
 	if (req.xsinfo.family == AF_UNSPEC)
 		req.xsinfo.family = AF_INET;
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		exit(2);
 
 	rtnl_close(&rth);
@@ -757,8 +757,7 @@ static int xfrm_state_allocspi(int argc, char **argv)
 	char *minp = NULL;
 	char *maxp = NULL;
 	struct xfrm_mark mark = {0, 0};
-	char res_buf[NLMSG_BUF_SIZE] = {};
-	struct nlmsghdr *res_n = (struct nlmsghdr *)res_buf;
+	struct nlmsghdr *answer = NULL;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "mode") == 0) {
@@ -858,10 +857,10 @@ static int xfrm_state_allocspi(int argc, char **argv)
 		req.xspi.info.family = AF_INET;
 
 
-	if (rtnl_talk(&rth, &req.n, res_n, sizeof(res_buf)) < 0)
+	if (rtnl_talk(&rth, &req.n, &answer) < 0)
 		exit(2);
 
-	if (xfrm_state_print(NULL, res_n, (void *)stdout) < 0) {
+	if (xfrm_state_print(NULL, answer, (void *)stdout) < 0) {
 		fprintf(stderr, "An error :-)\n");
 		exit(1);
 	}
@@ -1046,16 +1045,15 @@ static int xfrm_state_get_or_delete(int argc, char **argv, int delete)
 		req.xsid.family = AF_INET;
 
 	if (delete) {
-		if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+		if (rtnl_talk(&rth, &req.n, NULL) < 0)
 			exit(2);
 	} else {
-		char buf[NLMSG_BUF_SIZE] = {};
-		struct nlmsghdr *res_n = (struct nlmsghdr *)buf;
+		struct nlmsghdr *answer = NULL;
 
-		if (rtnl_talk(&rth, &req.n, res_n, sizeof(req)) < 0)
+		if (rtnl_talk(&rth, &req.n, &answer) < 0)
 			exit(2);
 
-		if (xfrm_state_print(NULL, res_n, (void *)stdout) < 0) {
+		if (xfrm_state_print(NULL, answer, (void *)stdout) < 0) {
 			fprintf(stderr, "An error :-)\n");
 			exit(1);
 		}
@@ -1321,14 +1319,15 @@ static int xfrm_sad_getinfo(int argc, char **argv)
 		.n.nlmsg_type = XFRM_MSG_GETSADINFO,
 		.flags = 0XFFFFFFFF,
 	};
+	struct nlmsghdr *answer = NULL;
 
 	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
 		exit(1);
 
-	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
+	if (rtnl_talk(&rth, &req.n, &answer) < 0)
 		exit(2);
 
-	print_sadinfo(&req.n, (void *)stdout);
+	print_sadinfo(answer, (void *)stdout);
 
 	rtnl_close(&rth);
 
@@ -1376,7 +1375,7 @@ static int xfrm_state_flush(int argc, char **argv)
 		fprintf(stderr, "Flush state with XFRM-PROTO value \"%s\"\n",
 			strxf_xfrmproto(req.xsf.proto));
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		exit(2);
 
 	rtnl_close(&rth);
diff --git a/lib/libgenl.c b/lib/libgenl.c
index 50d2d92..9994469 100644
--- a/lib/libgenl.c
+++ b/lib/libgenl.c
@@ -49,16 +49,17 @@ int genl_resolve_family(struct rtnl_handle *grth, const char *family)
 {
 	GENL_REQUEST(req, 1024, GENL_ID_CTRL, 0, 0, CTRL_CMD_GETFAMILY,
 		     NLM_F_REQUEST);
+	struct nlmsghdr *answer = NULL;
 
 	addattr_l(&req.n, sizeof(req), CTRL_ATTR_FAMILY_NAME,
 		  family, strlen(family) + 1);
 
-	if (rtnl_talk(grth, &req.n, &req.n, sizeof(req)) < 0) {
+	if (rtnl_talk(grth, &req.n, &answer) < 0) {
 		fprintf(stderr, "Error talking to the kernel\n");
 		return -2;
 	}
 
-	return genl_parse_getfamily(&req.n);
+	return genl_parse_getfamily(answer);
 }
 
 int genl_init_handle(struct rtnl_handle *grth, const char *family,
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 37cfb5a..ff986d4 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -568,7 +568,7 @@ static void rtnl_talk_error(struct nlmsghdr *h, struct nlmsgerr *err,
 }
 
 static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
-		       struct nlmsghdr *answer, size_t maxlen,
+		       struct nlmsghdr **answer,
 		       bool show_rtnl_err, nl_ext_ack_fn_t errfn)
 {
 	int status;
@@ -643,8 +643,7 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 					fprintf(stderr, "ERROR truncated\n");
 				} else if (!err->error) {
 					if (answer)
-						memcpy(answer, h,
-						       MIN(maxlen, h->nlmsg_len));
+						*answer= h;
 					return 0;
 				}
 
@@ -657,8 +656,7 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 			}
 
 			if (answer) {
-				memcpy(answer, h,
-				       MIN(maxlen, h->nlmsg_len));
+				*answer= h;
 				return 0;
 			}
 
@@ -681,22 +679,22 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 }
 
 int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
-	      struct nlmsghdr *answer, size_t maxlen)
+	      struct nlmsghdr **answer)
 {
-	return __rtnl_talk(rtnl, n, answer, maxlen, true, NULL);
+	return __rtnl_talk(rtnl, n, answer, true, NULL);
 }
 
 int rtnl_talk_extack(struct rtnl_handle *rtnl, struct nlmsghdr *n,
-		     struct nlmsghdr *answer, size_t maxlen,
+		     struct nlmsghdr **answer,
 		     nl_ext_ack_fn_t errfn)
 {
-	return __rtnl_talk(rtnl, n, answer, maxlen, true, errfn);
+	return __rtnl_talk(rtnl, n, answer, true, errfn);
 }
 
 int rtnl_talk_suppress_rtnl_errmsg(struct rtnl_handle *rtnl, struct nlmsghdr *n,
-				   struct nlmsghdr *answer, size_t maxlen)
+				   struct nlmsghdr **answer)
 {
-	return __rtnl_talk(rtnl, n, answer, maxlen, false, NULL);
+	return __rtnl_talk(rtnl, n, answer, false, NULL);
 }
 
 int rtnl_listen_all_nsid(struct rtnl_handle *rth)
diff --git a/misc/ss.c b/misc/ss.c
index dd8dfaa..bf21d80 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2597,7 +2597,7 @@ static int kill_inet_sock(struct nlmsghdr *h, void *arg, struct sockstat *s)
 		raw->sdiag_raw_protocol = s->raw_prot;
 	}
 
-	return rtnl_talk(rth, &req.nlh, NULL, 0);
+	return rtnl_talk(rth, &req.nlh, NULL);
 }
 
 static int show_one_inet_sock(const struct sockaddr_nl *addr,
diff --git a/tc/m_action.c b/tc/m_action.c
index 6ebe85e..12e033b 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -507,14 +507,13 @@ static int tc_action_gd(int cmd, unsigned int flags, int *argc_p, char ***argv_p
 
 	req.n.nlmsg_seq = rth.dump = ++rth.seq;
 	if (cmd == RTM_GETACTION)
-		ans = &req.n;
 
-	if (rtnl_talk(&rth, &req.n, ans, MAX_MSG) < 0) {
+	if (rtnl_talk(&rth, &req.n, &ans) < 0) {
 		fprintf(stderr, "We have an error talking to the kernel\n");
 		return 1;
 	}
 
-	if (ans && print_action(NULL, &req.n, (void *)stdout) < 0) {
+	if (ans && print_action(NULL, ans, (void *)stdout) < 0) {
 		fprintf(stderr, "Dump terminated\n");
 		return 1;
 	}
@@ -550,7 +549,7 @@ static int tc_action_modify(int cmd, unsigned int flags, int *argc_p, char ***ar
 	}
 	tail->rta_len = (void *) NLMSG_TAIL(&req.n) - (void *) tail;
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0) {
+	if (rtnl_talk(&rth, &req.n, NULL) < 0) {
 		fprintf(stderr, "We have an error talking to the kernel\n");
 		ret = -1;
 	}
@@ -617,7 +616,7 @@ static int tc_act_list_or_flush(int argc, char **argv, int event)
 		req.n.nlmsg_type = RTM_DELACTION;
 		req.n.nlmsg_flags |= NLM_F_ROOT;
 		req.n.nlmsg_flags |= NLM_F_REQUEST;
-		if (rtnl_talk(&rth, &req.n, NULL, 0) < 0) {
+		if (rtnl_talk(&rth, &req.n, NULL) < 0) {
 			fprintf(stderr, "We have an error flushing\n");
 			return 1;
 		}
diff --git a/tc/tc_class.c b/tc/tc_class.c
index 1a1f1fa..0214775 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -149,7 +149,7 @@ static int tc_class_modify(int cmd, unsigned int flags, int argc, char **argv)
 		}
 	}
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		return 2;
 
 	return 0;
diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index cf290ae..c43d1b2 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -194,7 +194,7 @@ static int tc_filter_modify(int cmd, unsigned int flags, int argc, char **argv)
 		}
 	}
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0) {
+	if (rtnl_talk(&rth, &req.n, NULL) < 0) {
 		fprintf(stderr, "We have an error talking to the kernel\n");
 		return 2;
 	}
@@ -331,6 +331,7 @@ static int tc_filter_get(int cmd, unsigned int flags, int argc, char **argv)
 		.t.tcm_parent = TC_H_UNSPEC,
 		.t.tcm_family = AF_UNSPEC,
 	};
+	struct nlmsghdr *answer = NULL;
 	struct filter_util *q = NULL;
 	__u32 prio = 0;
 	__u32 protocol = 0;
@@ -484,12 +485,12 @@ static int tc_filter_get(int cmd, unsigned int flags, int argc, char **argv)
 		return -1;
 	}
 
-	if (rtnl_talk(&rth, &req.n, &req.n, MAX_MSG) < 0) {
+	if (rtnl_talk(&rth, &req.n, &answer) < 0) {
 		fprintf(stderr, "We have an error talking to the kernel\n");
 		return 2;
 	}
 
-	print_filter(NULL, &req.n, (void *)stdout);
+	print_filter(NULL, answer, (void *)stdout);
 
 	return 0;
 }
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index 1e9d909..c52114a 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -190,7 +190,7 @@ static int tc_qdisc_modify(int cmd, unsigned int flags, int argc, char **argv)
 		req.t.tcm_ifindex = idx;
 	}
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL) < 0)
 		return 2;
 
 	return 0;
-- 
2.5.5

From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: stack smashing in iproute/ip
Date: Wed, 27 May 2015 18:33:54 -0700
Message-ID: <20150527183354.7f0f3c3a@urahara>
References: <555AF73C.7050405@nokia.com>
	<1432041939.621.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jetchko Jekov <jetchko.jekov@nokia.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:32902 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbbE1Bdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 21:33:53 -0400
Received: by pdbqa5 with SMTP id qa5so29714578pdb.0
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 18:33:52 -0700 (PDT)
In-Reply-To: <1432041939.621.52.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Yes, this is a long standing problem in rtnl_talk() api has no max
> length given for the answer.

I changed rtnl_talk API as well. It probably will break some people
who extract libnetlink as a user available library, but compatibility
with internal API's was never guaranteed by iproute2.

From: Stephen Hemminger <shemming@brocade.com>
Subject: libnetlink: add size argument to rtnl_talk

There have been several instances where response from kernel
has overrun the stack buffer from the caller. Avoid future problems
by passing a size argument.

Also drop the unused peer and group arguments to rtnl_talk.
---
 bridge/fdb.c         |  2 +-
 bridge/link.c        |  2 +-
 bridge/mdb.c         |  2 +-
 bridge/vlan.c        |  2 +-
 genl/ctrl.c          |  4 ++--
 include/libnetlink.h |  4 ++--
 ip/ipaddress.c       |  4 ++--
 ip/ipaddrlabel.c     |  4 ++--
 ip/ipfou.c           |  4 ++--
 ip/ipl2tp.c          |  8 ++++----
 ip/iplink.c          | 13 ++++++++-----
 ip/ipneigh.c         |  2 +-
 ip/ipnetns.c         |  4 ++--
 ip/ipntable.c        |  2 +-
 ip/iproute.c         |  8 ++++----
 ip/iprule.c          |  4 ++--
 ip/iptoken.c         |  2 +-
 ip/link_gre.c        |  2 +-
 ip/link_gre6.c       |  2 +-
 ip/link_ip6tnl.c     |  2 +-
 ip/link_iptnl.c      |  2 +-
 ip/link_vti.c        |  2 +-
 ip/link_vti6.c       |  2 +-
 ip/tcp_metrics.c     |  4 ++--
 ip/xfrm_policy.c     | 16 ++++++++--------
 ip/xfrm_state.c      | 12 ++++++------
 lib/libgenl.c        |  2 +-
 lib/libnetlink.c     | 40 ++++++++++++++++++++++------------------
 tc/m_action.c        |  6 +++---
 tc/tc_class.c        |  2 +-
 tc/tc_filter.c       |  2 +-
 tc/tc_qdisc.c        |  2 +-
 32 files changed, 88 insertions(+), 81 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index e34933b..278e55f 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -362,7 +362,7 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 		return -1;
 	}
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return -1;
 
 	return 0;
diff --git a/bridge/link.c b/bridge/link.c
index 1af1cf3..a9b1262 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -415,7 +415,7 @@ static int brlink_modify(int argc, char **argv)
 		addattr_nest_end(&req.n, nest);
 	}
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return -1;
 
 	return 0;
diff --git a/bridge/mdb.c b/bridge/mdb.c
index a6b2882..9a8ed54 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -224,7 +224,7 @@ static int mdb_modify(int cmd, int flags, int argc, char **argv)
 
 	addattr_l(&req.n, sizeof(req), MDBA_SET_ENTRY, &entry, sizeof(entry));
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return -1;
 
 	return 0;
diff --git a/bridge/vlan.c b/bridge/vlan.c
index 2ae739c..ac2f523 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -131,7 +131,7 @@ static int vlan_modify(int cmd, int argc, char **argv)
 
 	addattr_nest_end(&req.n, afspec);
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return -1;
 
 	return 0;
diff --git a/genl/ctrl.c b/genl/ctrl.c
index 3546129..0bf4dc1 100644
--- a/genl/ctrl.c
+++ b/genl/ctrl.c
@@ -67,7 +67,7 @@ int genl_ctrl_resolve_family(const char *family)
 
 	addattr_l(nlh, 128, CTRL_ATTR_FAMILY_NAME, family, strlen(family) + 1);
 
-	if (rtnl_talk(&rth, nlh, 0, 0, nlh) < 0) {
+	if (rtnl_talk(&rth, nlh, nlh, sizeof(req)) < 0) {
 		fprintf(stderr, "Error talking to the kernel\n");
 		goto errout;
 	}
@@ -334,7 +334,7 @@ static int ctrl_list(int cmd, int argc, char **argv)
 			goto ctrl_done;
 		}
 
-		if (rtnl_talk(&rth, nlh, 0, 0, nlh) < 0) {
+		if (rtnl_talk(&rth, nlh, nlh, sizeof(req)) < 0) {
 			fprintf(stderr, "Error talking to the kernel\n");
 			goto ctrl_done;
 		}
diff --git a/include/libnetlink.h b/include/libnetlink.h
index 898275b..bc1ab75 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -54,8 +54,8 @@ extern int rtnl_dump_filter_l(struct rtnl_handle *rth,
 			      const struct rtnl_dump_filter_arg *arg);
 extern int rtnl_dump_filter(struct rtnl_handle *rth, rtnl_filter_t filter,
 			    void *arg);
-extern int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
-		     unsigned groups, struct nlmsghdr *answer)
+extern int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
+		     struct nlmsghdr *answer, size_t len)
 	__attribute__((warn_unused_result));
 extern int rtnl_send(struct rtnl_handle *rth, const void *buf, int)
 	__attribute__((warn_unused_result));
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 92afa49..340e1c9 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1136,7 +1136,7 @@ static int restore_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n, voi
 
 	ll_init_map(&rth);
 
-	ret = rtnl_talk(&rth, n, 0, 0, n);
+	ret = rtnl_talk(&rth, n, n, sizeof(*n));
 	if ((ret < 0) && (errno == EEXIST))
 		ret = 0;
 
@@ -1800,7 +1800,7 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 		return -1;
 	}
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return -2;
 
 	return 0;
diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index 19a9308..a738ded 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -182,7 +182,7 @@ static int ipaddrlabel_modify(int cmd, int argc, char **argv)
 	if (req.ifal.ifal_family == AF_UNSPEC)
 		req.ifal.ifal_family = AF_INET6;
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return -2;
 
 	return 0;
@@ -209,7 +209,7 @@ static int flush_addrlabel(const struct sockaddr_nl *who, struct nlmsghdr *n, vo
 		if (rtnl_open(&rth2, 0) < 0)
 			return -1;
 
-		if (rtnl_talk(&rth2, n, 0, 0, NULL) < 0)
+		if (rtnl_talk(&rth2, n, NULL, 0) < 0)
 			return -2;
 
 		rtnl_close(&rth2);
diff --git a/ip/ipfou.c b/ip/ipfou.c
index 2676045..0b83c27 100644
--- a/ip/ipfou.c
+++ b/ip/ipfou.c
@@ -112,7 +112,7 @@ static int do_add(int argc, char **argv)
 
 	fou_parse_opt(argc, argv, &req.n, true);
 
-	if (rtnl_talk(&genl_rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
 		return -2;
 
 	return 0;
@@ -124,7 +124,7 @@ static int do_del(int argc, char **argv)
 
 	fou_parse_opt(argc, argv, &req.n, false);
 
-	if (rtnl_talk(&genl_rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
 		return -2;
 
 	return 0;
diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 5cd8632..2f7c9bf 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -119,7 +119,7 @@ static int create_tunnel(struct l2tp_parm *p)
 		addattr16(&req.n, 1024, L2TP_ATTR_UDP_DPORT, p->peer_udp_port);
 	}
 
-	if (rtnl_talk(&genl_rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
 		return -2;
 
 	return 0;
@@ -132,7 +132,7 @@ static int delete_tunnel(struct l2tp_parm *p)
 
 	addattr32(&req.n, 128, L2TP_ATTR_CONN_ID, p->tunnel_id);
 
-	if (rtnl_talk(&genl_rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
 		return -2;
 
 	return 0;
@@ -166,7 +166,7 @@ static int create_session(struct l2tp_parm *p)
 	if (p->ifname && p->ifname[0])
 		addattrstrz(&req.n, 1024, L2TP_ATTR_IFNAME, p->ifname);
 
-	if (rtnl_talk(&genl_rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
 		return -2;
 
 	return 0;
@@ -179,7 +179,7 @@ static int delete_session(struct l2tp_parm *p)
 
 	addattr32(&req.n, 1024, L2TP_ATTR_CONN_ID, p->tunnel_id);
 	addattr32(&req.n, 1024, L2TP_ATTR_SESSION_ID, p->session_id);
-	if (rtnl_talk(&genl_rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
 		return -2;
 
 	return 0;
diff --git a/ip/iplink.c b/ip/iplink.c
index bb437b9..a4a4980 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -674,7 +674,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 			req.i.ifi_index = 0;
 			addattr32(&req.n, sizeof(req), IFLA_GROUP, group);
-			if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+			if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 				exit(2);
 			return 0;
 		}
@@ -773,7 +773,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 		return -1;
 	}
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		exit(2);
 
 	return 0;
@@ -783,7 +783,10 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 {
 	int len;
 	struct iplink_req req;
-	char answer[16384];
+	struct {
+		struct nlmsghdr n;
+		char buf[16384];
+	} answer;
 
 	memset(&req, 0, sizeof(req));
 
@@ -803,10 +806,10 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 	}
 	addattr32(&req.n, sizeof(req), IFLA_EXT_MASK, filt_mask);
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, (struct nlmsghdr *)answer) < 0)
+	if (rtnl_talk(&rth, &req.n, &answer.n, sizeof(answer)) < 0)
 		return -2;
 
-	print_linkinfo(NULL, (struct nlmsghdr *)answer, stdout);
+	print_linkinfo(NULL, &answer.n, stdout);
 
 	return 0;
 }
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index eeec7bd..a9e23f4 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -179,7 +179,7 @@ static int ipneigh_modify(int cmd, int flags, int argc, char **argv)
 		return -1;
 	}
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		exit(2);
 
 	return 0;
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 438d59b..be0c473 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -112,7 +112,7 @@ static int get_netnsid_from_name(const char *name)
 		return fd;
 
 	addattr32(&req.n, 1024, NETNSA_FD, fd);
-	if (rtnl_talk(&rtnsh, &req.n, 0, 0, &answer.n) < 0) {
+	if (rtnl_talk(&rtnsh, &req.n, &answer.n, sizeof(answer)) < 0) {
 		close(fd);
 		return -2;
 	}
@@ -697,7 +697,7 @@ static int set_netnsid_from_name(const char *name, int nsid)
 
 	addattr32(&req.n, 1024, NETNSA_FD, fd);
 	addattr32(&req.n, 1024, NETNSA_NSID, nsid);
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		err = -2;
 
 	close(fd);
diff --git a/ip/ipntable.c b/ip/ipntable.c
index ea7ca2d..5e84b95 100644
--- a/ip/ipntable.c
+++ b/ip/ipntable.c
@@ -313,7 +313,7 @@ static int ipntable_modify(int cmd, int flags, int argc, char **argv)
 			  RTA_PAYLOAD(parms_rta));
 	}
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		exit(2);
 
 	return 0;
diff --git a/ip/iproute.c b/ip/iproute.c
index 670a4c6..64bc4c3 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1163,7 +1163,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 	if (req.r.rtm_family == AF_UNSPEC)
 		req.r.rtm_family = AF_INET;
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return -2;
 
 	return 0;
@@ -1626,7 +1626,7 @@ static int iproute_get(int argc, char **argv)
 	if (req.r.rtm_family == AF_UNSPEC)
 		req.r.rtm_family = AF_INET;
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0)
+	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
 		exit(2);
 
 	if (connected && !from_ok) {
@@ -1669,7 +1669,7 @@ static int iproute_get(int argc, char **argv)
 		req.n.nlmsg_flags = NLM_F_REQUEST;
 		req.n.nlmsg_type = RTM_GETROUTE;
 
-		if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0)
+		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
 			exit(2);
 	}
 
@@ -1690,7 +1690,7 @@ static int restore_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n,
 
 	ll_init_map(&rth);
 
-	ret = rtnl_talk(&rth, n, 0, 0, n);
+	ret = rtnl_talk(&rth, n, n, sizeof(*n));
 	if ((ret < 0) && (errno == EEXIST))
 		ret = 0;
 
diff --git a/ip/iprule.c b/ip/iprule.c
index 986a5bc..714278a 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -380,7 +380,7 @@ static int iprule_modify(int cmd, int argc, char **argv)
 	if (!table_ok && cmd == RTM_NEWRULE)
 		req.r.rtm_table = RT_TABLE_MAIN;
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return -2;
 
 	return 0;
@@ -407,7 +407,7 @@ static int flush_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *a
 		if (rtnl_open(&rth2, 0) < 0)
 			return -1;
 
-		if (rtnl_talk(&rth2, n, 0, 0, NULL) < 0)
+		if (rtnl_talk(&rth2, n, NULL, 0) < 0)
 			return -2;
 
 		rtnl_close(&rth2);
diff --git a/ip/iptoken.c b/ip/iptoken.c
index 655f160..a38194c 100644
--- a/ip/iptoken.c
+++ b/ip/iptoken.c
@@ -182,7 +182,7 @@ static int iptoken_set(int argc, char **argv)
 		return -1;
 	}
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return -2;
 
 	return 0;
diff --git a/ip/link_gre.c b/ip/link_gre.c
index 1937261..58f416c 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -84,7 +84,7 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 		req.i.ifi_family = preferred_family;
 		req.i.ifi_index = ifi->ifi_index;
 
-		if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0) {
+		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
 get_failed:
 			fprintf(stderr,
 				"Failed to get existing tunnel info.\n");
diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index f18919c..e00ea09 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -91,7 +91,7 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 		req.i.ifi_family = preferred_family;
 		req.i.ifi_index = ifi->ifi_index;
 
-		if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0) {
+		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
 get_failed:
 			fprintf(stderr,
 				"Failed to get existing tunnel info.\n");
diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index cf59a93..f771c75 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -89,7 +89,7 @@ static int ip6tunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 		req.i.ifi_family = preferred_family;
 		req.i.ifi_index = ifi->ifi_index;
 
-		if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0) {
+		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
 get_failed:
 			fprintf(stderr,
 				"Failed to get existing tunnel info.\n");
diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index cab174f..9d6bc98 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -91,7 +91,7 @@ static int iptunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 		req.i.ifi_family = preferred_family;
 		req.i.ifi_index = ifi->ifi_index;
 
-		if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0) {
+		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
 get_failed:
 			fprintf(stderr,
 				"Failed to get existing tunnel info.\n");
diff --git a/ip/link_vti.c b/ip/link_vti.c
index 59ac4c4..f3fea33 100644
--- a/ip/link_vti.c
+++ b/ip/link_vti.c
@@ -71,7 +71,7 @@ static int vti_parse_opt(struct link_util *lu, int argc, char **argv,
 		req.i.ifi_family = preferred_family;
 		req.i.ifi_index = ifi->ifi_index;
 
-		if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0) {
+		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
 get_failed:
 			fprintf(stderr,
 				"Failed to get existing tunnel info.\n");
diff --git a/ip/link_vti6.c b/ip/link_vti6.c
index 282896d..c146f79 100644
--- a/ip/link_vti6.c
+++ b/ip/link_vti6.c
@@ -67,7 +67,7 @@ static int vti6_parse_opt(struct link_util *lu, int argc, char **argv,
 		req.i.ifi_family = preferred_family;
 		req.i.ifi_index = ifi->ifi_index;
 
-		if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0) {
+		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
 get_failed:
 			fprintf(stderr,
 				"Failed to get existing tunnel info.\n");
diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
index bbbb4cc..bdc503e 100644
--- a/ip/tcp_metrics.c
+++ b/ip/tcp_metrics.c
@@ -467,10 +467,10 @@ static int tcpm_do_cmd(int cmd, int argc, char **argv)
 	}
 
 	if (ack) {
-		if (rtnl_talk(&grth, &req.n, 0, 0, NULL) < 0)
+		if (rtnl_talk(&grth, &req.n, NULL, 0) < 0)
 			return -2;
 	} else if (atype >= 0) {
-		if (rtnl_talk(&grth, &req.n, 0, 0, &req.n) < 0)
+		if (rtnl_talk(&grth, &req.n, &req.n, sizeof(req)) < 0)
 			return -2;
 		if (process_msg(NULL, &req.n, stdout) < 0) {
 			fprintf(stderr, "Dump terminated\n");
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 9429923..8f4d1a0 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -393,7 +393,7 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 	if (req.xpinfo.sel.family == AF_UNSPEC)
 		req.xpinfo.sel.family = AF_INET;
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		exit(2);
 
 	rtnl_close(&rth);
@@ -555,7 +555,7 @@ int xfrm_policy_print(const struct sockaddr_nl *who, struct nlmsghdr *n,
 }
 
 static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
-				     void *res_nlbuf)
+				     void *res_nlbuf, size_t res_size)
 {
 	struct rtnl_handle rth;
 	struct {
@@ -670,7 +670,7 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 			  (void *)&ctx, ctx.sctx.len);
 	}
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, res_nlbuf) < 0)
+	if (rtnl_talk(&rth, &req.n, res_nlbuf, res_size) < 0)
 		exit(2);
 
 	rtnl_close(&rth);
@@ -680,7 +680,7 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 
 static int xfrm_policy_delete(int argc, char **argv)
 {
-	return xfrm_policy_get_or_delete(argc, argv, 1, NULL);
+	return xfrm_policy_get_or_delete(argc, argv, 1, NULL, 0);
 }
 
 static int xfrm_policy_get(int argc, char **argv)
@@ -690,7 +690,7 @@ static int xfrm_policy_get(int argc, char **argv)
 
 	memset(buf, 0, sizeof(buf));
 
-	xfrm_policy_get_or_delete(argc, argv, 0, n);
+	xfrm_policy_get_or_delete(argc, argv, 0, n, sizeof(buf));
 
 	if (xfrm_policy_print(NULL, n, (void*)stdout) < 0) {
 		fprintf(stderr, "An error :-)\n");
@@ -1064,7 +1064,7 @@ static int xfrm_spd_setinfo(int argc, char **argv)
 	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
 		exit(1);
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		exit(2);
 
 	rtnl_close(&rth);
@@ -1091,7 +1091,7 @@ static int xfrm_spd_getinfo(int argc, char **argv)
 	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
 		exit(1);
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0)
+	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
 		exit(2);
 
 	print_spdinfo(&req.n, (void*)stdout);
@@ -1143,7 +1143,7 @@ static int xfrm_policy_flush(int argc, char **argv)
 	if (show_stats > 1)
 		fprintf(stderr, "Flush policy\n");
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		exit(2);
 
 	rtnl_close(&rth);
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 04af50b..d2831d0 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -688,7 +688,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 	if (req.xsinfo.family == AF_UNSPEC)
 		req.xsinfo.family = AF_INET;
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		exit(2);
 
 	rtnl_close(&rth);
@@ -825,7 +825,7 @@ static int xfrm_state_allocspi(int argc, char **argv)
 		req.xspi.info.family = AF_INET;
 
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, res_n) < 0)
+	if (rtnl_talk(&rth, &req.n, res_n, sizeof(res_buf)) < 0)
 		exit(2);
 
 	if (xfrm_state_print(NULL, res_n, (void*)stdout) < 0) {
@@ -1015,7 +1015,7 @@ static int xfrm_state_get_or_delete(int argc, char **argv, int delete)
 		req.xsid.family = AF_INET;
 
 	if (delete) {
-		if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+		if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 			exit(2);
 	} else {
 		char buf[NLMSG_BUF_SIZE];
@@ -1023,7 +1023,7 @@ static int xfrm_state_get_or_delete(int argc, char **argv, int delete)
 
 		memset(buf, 0, sizeof(buf));
 
-		if (rtnl_talk(&rth, &req.n, 0, 0, res_n) < 0)
+		if (rtnl_talk(&rth, &req.n, res_n, sizeof(req)) < 0)
 			exit(2);
 
 		if (xfrm_state_print(NULL, res_n, (void*)stdout) < 0) {
@@ -1297,7 +1297,7 @@ static int xfrm_sad_getinfo(int argc, char **argv)
 	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
 		exit(1);
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0)
+	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
 		exit(2);
 
 	print_sadinfo(&req.n, (void*)stdout);
@@ -1351,7 +1351,7 @@ static int xfrm_state_flush(int argc, char **argv)
 		fprintf(stderr, "Flush state with XFRM-PROTO value \"%s\"\n",
 			strxf_xfrmproto(req.xsf.proto));
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		exit(2);
 
 	rtnl_close(&rth);
diff --git a/lib/libgenl.c b/lib/libgenl.c
index ef3e5db..acb1478 100644
--- a/lib/libgenl.c
+++ b/lib/libgenl.c
@@ -53,7 +53,7 @@ int genl_resolve_family(struct rtnl_handle *grth, const char *family)
 	addattr_l(&req.n, sizeof(req), CTRL_ATTR_FAMILY_NAME,
 		  family, strlen(family) + 1);
 
-	if (rtnl_talk(grth, &req.n, 0, 0, &req.n) < 0) {
+	if (rtnl_talk(grth, &req.n, &req.n, sizeof(req)) < 0) {
 		fprintf(stderr, "Error talking to the kernel\n");
 		return -2;
 	}
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 77e07ef..901236e 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -25,6 +25,10 @@
 
 #include "libnetlink.h"
 
+#ifndef MIN
+#define MIN(a, b) ((a) < (b) ? (a) : (b))
+#endif
+
 int rcvbuf = 1024 * 1024;
 
 void rtnl_close(struct rtnl_handle *rth)
@@ -300,8 +304,8 @@ int rtnl_dump_filter(struct rtnl_handle *rth,
 	return rtnl_dump_filter_l(rth, a);
 }
 
-int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
-	      unsigned groups, struct nlmsghdr *answer)
+int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
+	      struct nlmsghdr *answer, size_t len)
 {
 	int status;
 	unsigned seq;
@@ -317,12 +321,10 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char   buf[16384];
+	char   buf[32768];
 
 	memset(&nladdr, 0, sizeof(nladdr));
 	nladdr.nl_family = AF_NETLINK;
-	nladdr.nl_pid = peer;
-	nladdr.nl_groups = groups;
 
 	n->nlmsg_seq = seq = ++rtnl->seq;
 
@@ -330,7 +332,6 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 		n->nlmsg_flags |= NLM_F_ACK;
 
 	status = sendmsg(rtnl->fd, &msg, 0);
-
 	if (status < 0) {
 		perror("Cannot talk to rtnetlink");
 		return -1;
@@ -339,7 +340,6 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 	memset(buf,0,sizeof(buf));
 
 	iov.iov_base = buf;
-
 	while (1) {
 		iov.iov_len = sizeof(buf);
 		status = recvmsg(rtnl->fd, &msg, 0);
@@ -372,7 +372,7 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 				exit(1);
 			}
 
-			if (nladdr.nl_pid != peer ||
+			if (nladdr.nl_pid != 0 ||
 			    h->nlmsg_pid != rtnl->local.nl_pid ||
 			    h->nlmsg_seq != seq) {
 				/* Don't forget to skip that message. */
@@ -385,20 +385,22 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 				struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
 				if (l < sizeof(struct nlmsgerr)) {
 					fprintf(stderr, "ERROR truncated\n");
-				} else {
-					if (!err->error) {
-						if (answer)
-							memcpy(answer, h, h->nlmsg_len);
-						return 0;
-					}
-
-					fprintf(stderr, "RTNETLINK answers: %s\n", strerror(-err->error));
-					errno = -err->error;
+				} else if (!err->error) {
+					if (answer)
+						memcpy(answer, h,
+						       MIN(len, h->nlmsg_len));
+					return 0;
 				}
+
+				fprintf(stderr, "RTNETLINK answers: %s\n",
+					strerror(-err->error));
+				errno = -err->error;
 				return -1;
 			}
+
 			if (answer) {
-				memcpy(answer, h, h->nlmsg_len);
+				memcpy(answer, h,
+				       MIN(len, h->nlmsg_len));
 				return 0;
 			}
 
@@ -407,10 +409,12 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 			status -= NLMSG_ALIGN(len);
 			h = (struct nlmsghdr*)((char*)h + NLMSG_ALIGN(len));
 		}
+
 		if (msg.msg_flags & MSG_TRUNC) {
 			fprintf(stderr, "Message truncated\n");
 			continue;
 		}
+
 		if (status) {
 			fprintf(stderr, "!!!Remnant of size %d\n", status);
 			exit(1);
diff --git a/tc/m_action.c b/tc/m_action.c
index 7a83f0d..d363d27 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -472,7 +472,7 @@ static int tc_action_gd(int cmd, unsigned flags, int *argc_p, char ***argv_p)
 	if (cmd == RTM_GETACTION)
 		ans = &req.n;
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, ans) < 0) {
+	if (rtnl_talk(&rth, &req.n, ans, MAX_MSG) < 0) {
 		fprintf(stderr, "We have an error talking to the kernel\n");
 		return 1;
 	}
@@ -517,7 +517,7 @@ static int tc_action_modify(int cmd, unsigned flags, int *argc_p, char ***argv_p
 	}
 	tail->rta_len = (void *) NLMSG_TAIL(&req.n) - (void *) tail;
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0) {
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0) {
 		fprintf(stderr, "We have an error talking to the kernel\n");
 		ret = -1;
 	}
@@ -587,7 +587,7 @@ static int tc_act_list_or_flush(int argc, char **argv, int event)
 		req.n.nlmsg_type = RTM_DELACTION;
 		req.n.nlmsg_flags |= NLM_F_ROOT;
 		req.n.nlmsg_flags |= NLM_F_REQUEST;
-		if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0) {
+		if (rtnl_talk(&rth, &req.n, NULL, 0) < 0) {
 			fprintf(stderr, "We have an error flushing\n");
 			return 1;
 		}
diff --git a/tc/tc_class.c b/tc/tc_class.c
index 877048a..3acd030 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -153,7 +153,7 @@ static int tc_class_modify(int cmd, unsigned flags, int argc, char **argv)
 		}
 	}
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return 2;
 
 	return 0;
diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index c1038a4..9e41600 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -167,7 +167,7 @@ static int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 		}
 	}
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0) {
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0) {
 		fprintf(stderr, "We have an error talking to the kernel\n");
 		return 2;
 	}
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index c71937d..c31ae8d 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -187,7 +187,7 @@ static int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
 		req.t.tcm_ifindex = idx;
 	}
 
-	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return 2;
 
 	return 0;
-- 
2.1.4

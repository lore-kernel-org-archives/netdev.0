From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v2 repost 1/3] tc_filter: add support for chain index
Date: Tue, 16 May 2017 19:29:35 +0200
Message-ID: <20170516172937.1391-1-jiri@resnulli.us>
References: <20170516172802.1317-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36848 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751730AbdEPR3k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:29:40 -0400
Received: by mail-wm0-f65.google.com with SMTP id u65so38919726wmu.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:29:39 -0700 (PDT)
In-Reply-To: <20170516172802.1317-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Allow user to put filter to a specific chain identified by index.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/rtnetlink.h |  1 +
 tc/tc_filter.c            | 87 +++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 73 insertions(+), 15 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index a96db83..70c5750 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -549,6 +549,7 @@ enum {
 	TCA_STAB,
 	TCA_PAD,
 	TCA_DUMP_INVISIBLE,
+	TCA_CHAIN,
 	__TCA_MAX
 };
 
diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index ff8713b..b13fb91 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -31,7 +31,7 @@ static void usage(void)
 	fprintf(stderr,
 		"Usage: tc filter [ add | del | change | replace | show ] dev STRING\n"
 		"Usage: tc filter get dev STRING parent CLASSID protocol PROTO handle FILTERID pref PRIO FILTER_TYPE\n"
-		"       [ pref PRIO ] protocol PROTO\n"
+		"       [ pref PRIO ] protocol PROTO [ chain CHAIN_INDEX ]\n"
 		"       [ estimator INTERVAL TIME_CONSTANT ]\n"
 		"       [ root | ingress | egress | parent CLASSID ]\n"
 		"       [ handle FILTERID ] [ [ FILTER_TYPE ] [ help | OPTIONS ] ]\n"
@@ -59,6 +59,8 @@ static int tc_filter_modify(int cmd, unsigned int flags, int argc, char **argv)
 	__u32 prio = 0;
 	__u32 protocol = 0;
 	int protocol_set = 0;
+	__u32 chain_index;
+	int chain_index_set = 0;
 	char *fhandle = NULL;
 	char  d[16] = {};
 	char  k[16] = {};
@@ -127,6 +129,13 @@ static int tc_filter_modify(int cmd, unsigned int flags, int argc, char **argv)
 				invarg("invalid protocol", *argv);
 			protocol = id;
 			protocol_set = 1;
+		} else if (matches(*argv, "chain") == 0) {
+			NEXT_ARG();
+			if (chain_index_set)
+				duparg("chain", *argv);
+			if (get_u32(&chain_index, *argv, 0))
+				invarg("invalid chain index value", *argv);
+			chain_index_set = 1;
 		} else if (matches(*argv, "estimator") == 0) {
 			if (parse_estimator(&argc, &argv, &est) < 0)
 				return -1;
@@ -146,6 +155,9 @@ static int tc_filter_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 	req.t.tcm_info = TC_H_MAKE(prio<<16, protocol);
 
+	if (chain_index_set)
+		addattr32(&req.n, sizeof(req), TCA_CHAIN, chain_index);
+
 	if (k[0])
 		addattr_l(&req.n, sizeof(req), TCA_KIND, k, strlen(k)+1);
 
@@ -167,6 +179,7 @@ static int tc_filter_modify(int cmd, unsigned int flags, int argc, char **argv)
 			return -1;
 		}
 	}
+
 	if (est.ewma_log)
 		addattr_l(&req.n, sizeof(req), TCA_RATE, &est, sizeof(est));
 
@@ -193,6 +206,8 @@ static __u32 filter_parent;
 static int filter_ifindex;
 static __u32 filter_prio;
 static __u32 filter_protocol;
+static __u32 filter_chain_index;
+static int filter_chain_index_set;
 __u16 f_proto;
 
 int print_filter(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
@@ -270,6 +285,15 @@ int print_filter(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		}
 	}
 	fprintf(fp, "%s ", rta_getattr_str(tb[TCA_KIND]));
+
+	if (tb[TCA_CHAIN]) {
+		__u32 chain_index = rta_getattr_u32(tb[TCA_CHAIN]);
+
+		if (!filter_chain_index_set ||
+		    filter_chain_index != chain_index)
+			fprintf(fp, "chain %u ", chain_index);
+	}
+
 	q = get_filter_kind(RTA_DATA(tb[TCA_KIND]));
 	if (tb[TCA_OPTIONS]) {
 		if (q)
@@ -311,6 +335,8 @@ static int tc_filter_get(int cmd, unsigned int flags, int argc, char **argv)
 	__u32 prio = 0;
 	__u32 protocol = 0;
 	int protocol_set = 0;
+	__u32 chain_index;
+	int chain_index_set = 0;
 	__u32 parent_handle = 0;
 	char *fhandle = NULL;
 	char  d[16] = {};
@@ -375,6 +401,13 @@ static int tc_filter_get(int cmd, unsigned int flags, int argc, char **argv)
 				invarg("invalid protocol", *argv);
 			protocol = id;
 			protocol_set = 1;
+		} else if (matches(*argv, "chain") == 0) {
+			NEXT_ARG();
+			if (chain_index_set)
+				duparg("chain", *argv);
+			if (get_u32(&chain_index, *argv, 0))
+				invarg("invalid chain index value", *argv);
+			chain_index_set = 1;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 			return 0;
@@ -401,6 +434,9 @@ static int tc_filter_get(int cmd, unsigned int flags, int argc, char **argv)
 
 	req.t.tcm_info = TC_H_MAKE(prio<<16, protocol);
 
+	if (chain_index_set)
+		addattr32(&req.n, sizeof(req), TCA_CHAIN, chain_index);
+
 	if (req.t.tcm_parent == TC_H_UNSPEC) {
 		fprintf(stderr, "Must specify filter parent\n");
 		return -1;
@@ -457,10 +493,20 @@ static int tc_filter_get(int cmd, unsigned int flags, int argc, char **argv)
 
 static int tc_filter_list(int argc, char **argv)
 {
-	struct tcmsg t = { .tcm_family = AF_UNSPEC };
+	struct {
+		struct nlmsghdr n;
+		struct tcmsg t;
+		char buf[MAX_MSG];
+	} req = {
+		.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcmsg)),
+		.n.nlmsg_type = RTM_GETTFILTER,
+		.t.tcm_parent = TC_H_UNSPEC,
+		.t.tcm_family = AF_UNSPEC,
+	};
 	char d[16] = {};
 	__u32 prio = 0;
 	__u32 protocol = 0;
+	__u32 chain_index;
 	char *fhandle = NULL;
 
 	while (argc > 0) {
@@ -470,39 +516,39 @@ static int tc_filter_list(int argc, char **argv)
 				duparg("dev", *argv);
 			strncpy(d, *argv, sizeof(d)-1);
 		} else if (strcmp(*argv, "root") == 0) {
-			if (t.tcm_parent) {
+			if (req.t.tcm_parent) {
 				fprintf(stderr,
 					"Error: \"root\" is duplicate parent ID\n");
 				return -1;
 			}
-			filter_parent = t.tcm_parent = TC_H_ROOT;
+			filter_parent = req.t.tcm_parent = TC_H_ROOT;
 		} else if (strcmp(*argv, "ingress") == 0) {
-			if (t.tcm_parent) {
+			if (req.t.tcm_parent) {
 				fprintf(stderr,
 					"Error: \"ingress\" is duplicate parent ID\n");
 				return -1;
 			}
 			filter_parent = TC_H_MAKE(TC_H_CLSACT,
 						  TC_H_MIN_INGRESS);
-			t.tcm_parent = filter_parent;
+			req.t.tcm_parent = filter_parent;
 		} else if (strcmp(*argv, "egress") == 0) {
-			if (t.tcm_parent) {
+			if (req.t.tcm_parent) {
 				fprintf(stderr,
 					"Error: \"egress\" is duplicate parent ID\n");
 				return -1;
 			}
 			filter_parent = TC_H_MAKE(TC_H_CLSACT,
 						  TC_H_MIN_EGRESS);
-			t.tcm_parent = filter_parent;
+			req.t.tcm_parent = filter_parent;
 		} else if (strcmp(*argv, "parent") == 0) {
 			__u32 handle;
 
 			NEXT_ARG();
-			if (t.tcm_parent)
+			if (req.t.tcm_parent)
 				duparg("parent", *argv);
 			if (get_tc_classid(&handle, *argv))
 				invarg("invalid parent ID", *argv);
-			filter_parent = t.tcm_parent = handle;
+			filter_parent = req.t.tcm_parent = handle;
 		} else if (strcmp(*argv, "handle") == 0) {
 			NEXT_ARG();
 			if (fhandle)
@@ -526,6 +572,14 @@ static int tc_filter_list(int argc, char **argv)
 				invarg("invalid protocol", *argv);
 			protocol = res;
 			filter_protocol = protocol;
+		} else if (matches(*argv, "chain") == 0) {
+			NEXT_ARG();
+			if (filter_chain_index_set)
+				duparg("chain", *argv);
+			if (get_u32(&chain_index, *argv, 0))
+				invarg("invalid chain index value", *argv);
+			filter_chain_index_set = 1;
+			filter_chain_index = chain_index;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
@@ -538,20 +592,23 @@ static int tc_filter_list(int argc, char **argv)
 		argc--; argv++;
 	}
 
-	t.tcm_info = TC_H_MAKE(prio<<16, protocol);
+	req.t.tcm_info = TC_H_MAKE(prio<<16, protocol);
 
 	ll_init_map(&rth);
 
 	if (d[0]) {
-		t.tcm_ifindex = ll_name_to_index(d);
-		if (t.tcm_ifindex == 0) {
+		req.t.tcm_ifindex = ll_name_to_index(d);
+		if (req.t.tcm_ifindex == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", d);
 			return 1;
 		}
-		filter_ifindex = t.tcm_ifindex;
+		filter_ifindex = req.t.tcm_ifindex;
 	}
 
-	if (rtnl_dump_request(&rth, RTM_GETTFILTER, &t, sizeof(t)) < 0) {
+	if (filter_chain_index_set)
+		addattr32(&req.n, sizeof(req), TCA_CHAIN, chain_index);
+
+	if (rtnl_dump_request_n(&rth, &req.n) < 0) {
 		perror("Cannot send dump request");
 		return 1;
 	}
-- 
2.9.3

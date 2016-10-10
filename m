From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc filters: add support to get individual filters by handle
Date: Mon, 10 Oct 2016 12:45:14 -0400
Message-ID: <1476117914-32207-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, edumazet@google.com, mrv@mojatatu.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36152 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752462AbcJJQqV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 12:46:21 -0400
Received: by mail-io0-f193.google.com with SMTP id o141so4848474ioe.3
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 09:45:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

sudo $TC filter add dev $ETH parent ffff: prio 2 protocol ip \
u32 match u32 0 0 flowid 1:1 \
action ok
sudo $TC filter add dev $ETH parent ffff: prio 1 protocol ip \
u32 match ip protocol 1 0xff flowid 1:10 \
action ok

now dump to see all rules..
$TC -s filter ls dev $ETH parent ffff: protocol ip
 ....
filter pref 1 u32
filter pref 1 u32 fh 801: ht divisor 1
filter pref 1 u32 fh 801::800 order 2048 key ht 801 bkt 0 flowid 1:10  (rule hit 0 success 0)
  match 00010000/00ff0000 at 8 (success 0 )
        action order 1: gact action drop
         random type none pass val 0
         index 6 ref 1 bind 1 installed 4 sec used 4 sec
        Action statistics:
        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
        backlog 0b 0p requeues 0

filter pref 2 u32
filter pref 2 u32 fh 800: ht divisor 1
filter pref 2 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1  (rule hit 336 success 336)
  match 00000000/00000000 at 0 (success 336 )
        action order 1: gact action pass
         random type none pass val 0
         index 5 ref 1 bind 1 installed 38 sec used 4 sec
        Action statistics:
        Sent 24864 bytes 336 pkt (dropped 0, overlimits 0 requeues 0)
        backlog 0b 0p requeues 0
 ....

..get filter 801::800
$TC -s filter get dev $ETH parent ffff: protocol ip \
handle 801:0:800 prio 2  u32

 ....
filter parent ffff: protocol ip pref 1 u32 fh 801::800 order 2048 key ht 801 bkt 0 flowid 1:10  (rule hit 260 success 130)
  match 00010000/00ff0000 at 8 (success 130 )
        action order 1: gact action drop
         random type none pass val 0
         index 6 ref 1 bind 1 installed 348 sec used 0 sec
        Action statistics:
        Sent 11440 bytes 130 pkt (dropped 130, overlimits 0 requeues 0)
        backlog 0b 0p requeues 0
 ....

..get other one
$TC -s filter get dev $ETH parent ffff: protocol ip \
handle 800:0:800 prio 2  u32

....
filter parent ffff: protocol ip pref 2 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1  (rule hit 514 success 514)
  match 00000000/00000000 at 0 (success 514 )
        action order 1: gact action pass
         random type none pass val 0
         index 5 ref 1 bind 1 installed 506 sec used 4 sec
        Action statistics:
        Sent 35544 bytes 514 pkt (dropped 0, overlimits 0 requeues 0)
        backlog 0b 0p requeues 0
....

..try something that doesnt exist
$TC -s filter get dev $ETH parent ffff: protocol ip  handle 800:0:803 prio 2  u32

.....
RTNETLINK answers: No such file or directory
We have an error talking to the kernel
.....

Note, added NLM_F_ECHO is for backward compatibility. old kernels never
before Eric's patch will not respond without it and newer kernels (after Erics patch)
will ignore it.
In old kernels there is a side effect:
In addition to a response to the GET you will receive an event (if you do tc mon).
But this is still better than what it was before (not working at all).

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/tc_filter.c | 185 +++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 175 insertions(+), 10 deletions(-)

diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index 7e78e13..2413cef 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -29,6 +29,7 @@
 static void usage(void)
 {
 	fprintf(stderr, "Usage: tc filter [ add | del | change | replace | show ] dev STRING\n");
+	fprintf(stderr, "Usage: tc filter get dev STRING parent CLASSID protocol PROTO handle FILTERID pref PRIO FILTER_TYPE \n");
 	fprintf(stderr, "       [ pref PRIO ] protocol PROTO\n");
 	fprintf(stderr, "       [ estimator INTERVAL TIME_CONSTANT ]\n");
 	fprintf(stderr, "       [ root | ingress | egress | parent CLASSID ]\n");
@@ -186,9 +187,7 @@ static __u32 filter_prio;
 static __u32 filter_protocol;
 __u16 f_proto;
 
-int print_filter(const struct sockaddr_nl *who,
-			struct nlmsghdr *n,
-			void *arg)
+int print_filter(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE *)arg;
 	struct tcmsg *t = NLMSG_DATA(n);
@@ -197,8 +196,10 @@ int print_filter(const struct sockaddr_nl *who,
 	struct filter_util *q;
 	char abuf[256];
 
-	if (n->nlmsg_type != RTM_NEWTFILTER && n->nlmsg_type != RTM_DELTFILTER) {
-		fprintf(stderr, "Not a filter\n");
+	if (n->nlmsg_type != RTM_NEWTFILTER &&
+	    n->nlmsg_type != RTM_GETTFILTER &&
+	    n->nlmsg_type != RTM_DELTFILTER) {
+		fprintf(stderr, "Not a filter(cmd %d)\n", n->nlmsg_type);
 		return 0;
 	}
 	len -= NLMSG_LENGTH(sizeof(*t));
@@ -269,6 +270,169 @@ int print_filter(const struct sockaddr_nl *who,
 	return 0;
 }
 
+static int tc_filter_get(int cmd, unsigned int flags, int argc, char **argv)
+{
+	struct {
+		struct nlmsghdr	n;
+		struct tcmsg		t;
+		char			buf[MAX_MSG];
+	} req = {
+		.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcmsg)),
+		/* NLM_F_ECHO is for backward compatibility. old kernels never
+		 * respond without it and newer kernels will ignore it.
+		 * In old kernels there is a side effect:
+		 * In addition to a response to the GET you will receive an
+		 * event (if you do tc mon).
+		 */
+		.n.nlmsg_flags = NLM_F_REQUEST | NLM_F_ECHO | flags,
+		.n.nlmsg_type = cmd,
+		.t.tcm_parent = TC_H_UNSPEC,
+		.t.tcm_family = AF_UNSPEC,
+	};
+	struct filter_util *q = NULL;
+	__u32 prio = 0;
+	__u32 protocol = 0;
+	int protocol_set = 0;
+	__u32 parent_handle = 0;
+	char *fhandle = NULL;
+	char  d[16] = {};
+	char  k[16] = {};
+
+	while (argc > 0) {
+		if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			if (d[0])
+				duparg("dev", *argv);
+			strncpy(d, *argv, sizeof(d)-1);
+		} else if (strcmp(*argv, "root") == 0) {
+			if (req.t.tcm_parent) {
+				fprintf(stderr, "Error: \"root\" is duplicate parent ID\n");
+				return -1;
+			}
+			req.t.tcm_parent = TC_H_ROOT;
+		} else if (strcmp(*argv, "ingress") == 0) {
+			if (req.t.tcm_parent) {
+				fprintf(stderr, "Error: \"ingress\" is duplicate parent ID\n");
+				return -1;
+			}
+			req.t.tcm_parent = TC_H_MAKE(TC_H_CLSACT,
+						     TC_H_MIN_INGRESS);
+		} else if (strcmp(*argv, "egress") == 0) {
+			if (req.t.tcm_parent) {
+				fprintf(stderr, "Error: \"egress\" is duplicate parent ID\n");
+				return -1;
+			}
+			req.t.tcm_parent = TC_H_MAKE(TC_H_CLSACT,
+						     TC_H_MIN_EGRESS);
+		} else if (strcmp(*argv, "parent") == 0) {
+
+			NEXT_ARG();
+			if (req.t.tcm_parent)
+				duparg("parent", *argv);
+			if (get_tc_classid(&parent_handle, *argv))
+				invarg("Invalid parent ID", *argv);
+			req.t.tcm_parent = parent_handle;
+		} else if (strcmp(*argv, "handle") == 0) {
+			NEXT_ARG();
+			if (fhandle)
+				duparg("handle", *argv);
+			fhandle = *argv;
+		} else if (matches(*argv, "preference") == 0 ||
+			   matches(*argv, "priority") == 0) {
+			NEXT_ARG();
+			if (prio)
+				duparg("priority", *argv);
+			if (get_u32(&prio, *argv, 0) || prio > 0xFFFF)
+				invarg("invalid priority value", *argv);
+		} else if (matches(*argv, "protocol") == 0) {
+			__u16 id;
+
+			NEXT_ARG();
+			if (protocol_set)
+				duparg("protocol", *argv);
+			if (ll_proto_a2n(&id, *argv))
+				invarg("invalid protocol", *argv);
+			protocol = id;
+			protocol_set = 1;
+		} else if (matches(*argv, "help") == 0) {
+			usage();
+			return 0;
+		} else {
+			strncpy(k, *argv, sizeof(k)-1);
+
+			q = get_filter_kind(k);
+			argc--; argv++;
+			break;
+		}
+
+		argc--; argv++;
+	}
+
+	if (!protocol_set) {
+		fprintf(stderr, "Must specify filter protocol\n");
+		return -1;
+	}
+
+	if (!prio) {
+		fprintf(stderr, "Must specify filter priority\n");
+		return -1;
+	}
+
+	req.t.tcm_info = TC_H_MAKE(prio<<16, protocol);
+
+	if (req.t.tcm_parent == TC_H_UNSPEC) {
+		fprintf(stderr, "Must specify filter parent\n");
+		return -1;
+	}
+
+	if (k[0])
+		addattr_l(&req.n, sizeof(req), TCA_KIND, k, strlen(k)+1);
+	else {
+		fprintf(stderr, "Must specify filter type\n");
+		return -1;
+	}
+
+	if (q->parse_fopt(q, fhandle, argc, argv, &req.n))
+		return 1;
+
+
+	if (!fhandle) {
+		fprintf(stderr, "Must specify filter \"handle\"\n");
+		return -1;
+	}
+
+	if (argc) {
+		if (matches(*argv, "help") == 0)
+			usage();
+		fprintf(stderr, "Garbage instead of arguments \"%s ...\". Try \"tc filter help\".\n",
+			*argv);
+		return -1;
+	}
+
+	if (d[0])  {
+		ll_init_map(&rth);
+
+		req.t.tcm_ifindex = ll_name_to_index(d);
+		if (req.t.tcm_ifindex  == 0) {
+			fprintf(stderr, "Cannot find device \"%s\"\n", d);
+			return 1;
+		}
+		filter_ifindex = req.t.tcm_ifindex;
+	} else {
+		fprintf(stderr, "Must specify netdevice \"dev\"\n");
+		return -1;
+	}
+
+	if (rtnl_talk(&rth, &req.n, &req.n, MAX_MSG) < 0) {
+		fprintf(stderr, "We have an error talking to the kernel\n");
+		return 2;
+	}
+
+	print_filter(NULL, &req.n, (void *)stdout);
+
+	return 0;
+}
+
 static int tc_filter_list(int argc, char **argv)
 {
 	struct tcmsg t = { .tcm_family = AF_UNSPEC };
@@ -377,17 +541,17 @@ int do_filter(int argc, char **argv)
 	if (argc < 1)
 		return tc_filter_list(0, NULL);
 	if (matches(*argv, "add") == 0)
-		return tc_filter_modify(RTM_NEWTFILTER, NLM_F_EXCL|NLM_F_CREATE, argc-1, argv+1);
+		return tc_filter_modify(RTM_NEWTFILTER, NLM_F_EXCL|NLM_F_CREATE,
+					argc-1, argv+1);
 	if (matches(*argv, "change") == 0)
 		return tc_filter_modify(RTM_NEWTFILTER, 0, argc-1, argv+1);
 	if (matches(*argv, "replace") == 0)
-		return tc_filter_modify(RTM_NEWTFILTER, NLM_F_CREATE, argc-1, argv+1);
+		return tc_filter_modify(RTM_NEWTFILTER, NLM_F_CREATE, argc-1,
+					argv+1);
 	if (matches(*argv, "delete") == 0)
 		return tc_filter_modify(RTM_DELTFILTER, 0,  argc-1, argv+1);
-#if 0
 	if (matches(*argv, "get") == 0)
 		return tc_filter_get(RTM_GETTFILTER, 0,  argc-1, argv+1);
-#endif
 	if (matches(*argv, "list") == 0 || matches(*argv, "show") == 0
 	    || matches(*argv, "lst") == 0)
 		return tc_filter_list(argc-1, argv+1);
@@ -395,6 +559,7 @@ int do_filter(int argc, char **argv)
 		usage();
 		return 0;
 	}
-	fprintf(stderr, "Command \"%s\" is unknown, try \"tc filter help\".\n", *argv);
+	fprintf(stderr, "Command \"%s\" is unknown, try \"tc filter help\".\n",
+		*argv);
 	return -1;
 }
-- 
1.9.1

From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 1/2] tc actions: Improved batching and time filtered dumping
Date: Wed,  2 Aug 2017 07:46:26 -0400
Message-ID: <1501674387-15001-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, dsahern@gmail.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33086 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753077AbdHBLqo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 07:46:44 -0400
Received: by mail-io0-f195.google.com with SMTP id q64so3550663ioi.0
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 04:46:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

dump more than TCA_ACT_MAX_PRIO actions per batch when the kernel
supports it.

Introduced keyword "since" for time based filtering of actions.
Some example (we have 400 actions bound to 400 filters); at
installation time. Using updated when tc setting the time of
interest to 120 seconds earlier (we see 400 actions):
prompt$ hackedtc actions ls action gact since 120000| grep index | wc -l
400

go get some coffee and wait for > 120 seconds and try again:

prompt$ hackedtc actions ls action gact since 120000 | grep index | wc -l
0

Lets see a filter bound to one of these actions:
....
filter pref 10 u32
filter pref 10 u32 fh 800: ht divisor 1
filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 2 success 1)
  match 7f000002/ffffffff at 12 (success 1 )
    action order 1: gact action pass
     random type none pass val 0
     index 23 ref 2 bind 1 installed 1145 sec used 802 sec
    Action statistics:
    Sent 84 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
    backlog 0b 0p requeues 0
...

that coffee took long, no? It was good.

Now lets ping -c 1 127.0.0.2, then run the actions again:
prompt$ hackedtc actions ls action gact since 120 | grep index | wc -l
1

More details please:
prompt$ hackedtc -s actions ls action gact since 120000

    action order 0: gact action pass
     random type none pass val 0
     index 23 ref 2 bind 1 installed 1270 sec used 30 sec
    Action statistics:
    Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
    backlog 0b 0p requeues 0

And the filter?
filter pref 10 u32
filter pref 10 u32 fh 800: ht divisor 1
filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 4 success 2)
  match 7f000002/ffffffff at 12 (success 2 )
    action order 1: gact action pass
     random type none pass val 0
     index 23 ref 2 bind 1 installed 1324 sec used 84 sec
    Action statistics:
    Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
    backlog 0b 0p requeues 0

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/f_basic.c    |  2 +-
 tc/f_bpf.c      |  2 +-
 tc/f_cgroup.c   |  2 +-
 tc/f_flow.c     |  2 +-
 tc/f_flower.c   |  2 +-
 tc/f_fw.c       |  2 +-
 tc/f_matchall.c |  2 +-
 tc/f_route.c    |  2 +-
 tc/f_rsvp.c     |  2 +-
 tc/f_tcindex.c  |  2 +-
 tc/f_u32.c      |  2 +-
 tc/m_action.c   | 74 ++++++++++++++++++++++++++++++++++++++++++++++-----------
 tc/tc_util.h    |  2 +-
 13 files changed, 72 insertions(+), 26 deletions(-)

diff --git a/tc/f_basic.c b/tc/f_basic.c
index d663668..8370ea6 100644
--- a/tc/f_basic.c
+++ b/tc/f_basic.c
@@ -135,7 +135,7 @@ static int basic_print_opt(struct filter_util *qu, FILE *f,
 	}
 
 	if (tb[TCA_BASIC_ACT]) {
-		tc_print_action(f, tb[TCA_BASIC_ACT]);
+		tc_print_action(f, tb[TCA_BASIC_ACT], 0);
 	}
 
 	return 0;
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index 2f8d12a..c115409 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -239,7 +239,7 @@ static int bpf_print_opt(struct filter_util *qu, FILE *f,
 	}
 
 	if (tb[TCA_BPF_ACT])
-		tc_print_action(f, tb[TCA_BPF_ACT]);
+		tc_print_action(f, tb[TCA_BPF_ACT], 0);
 
 	return 0;
 }
diff --git a/tc/f_cgroup.c b/tc/f_cgroup.c
index ecf9909..633700e 100644
--- a/tc/f_cgroup.c
+++ b/tc/f_cgroup.c
@@ -102,7 +102,7 @@ static int cgroup_print_opt(struct filter_util *qu, FILE *f,
 	}
 
 	if (tb[TCA_CGROUP_ACT])
-		tc_print_action(f, tb[TCA_CGROUP_ACT]);
+		tc_print_action(f, tb[TCA_CGROUP_ACT], 0);
 
 	return 0;
 }
diff --git a/tc/f_flow.c b/tc/f_flow.c
index 09ddcaa..b157104 100644
--- a/tc/f_flow.c
+++ b/tc/f_flow.c
@@ -347,7 +347,7 @@ static int flow_print_opt(struct filter_util *fu, FILE *f, struct rtattr *opt,
 		tc_print_police(f, tb[TCA_FLOW_POLICE]);
 	if (tb[TCA_FLOW_ACT]) {
 		fprintf(f, "\n");
-		tc_print_action(f, tb[TCA_FLOW_ACT]);
+		tc_print_action(f, tb[TCA_FLOW_ACT], 0);
 	}
 	return 0;
 }
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 5be693a..934832e 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -1316,7 +1316,7 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	}
 
 	if (tb[TCA_FLOWER_ACT])
-		tc_print_action(f, tb[TCA_FLOWER_ACT]);
+		tc_print_action(f, tb[TCA_FLOWER_ACT], 0);
 
 	return 0;
 }
diff --git a/tc/f_fw.c b/tc/f_fw.c
index 790bef9..c39789b 100644
--- a/tc/f_fw.c
+++ b/tc/f_fw.c
@@ -160,7 +160,7 @@ static int fw_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt, __u
 
 	if (tb[TCA_FW_ACT]) {
 		fprintf(f, "\n");
-		tc_print_action(f, tb[TCA_FW_ACT]);
+		tc_print_action(f, tb[TCA_FW_ACT], 0);
 	}
 	return 0;
 }
diff --git a/tc/f_matchall.c b/tc/f_matchall.c
index 5a51e75..d78660e 100644
--- a/tc/f_matchall.c
+++ b/tc/f_matchall.c
@@ -145,7 +145,7 @@ static int matchall_print_opt(struct filter_util *qu, FILE *f,
 	}
 
 	if (tb[TCA_MATCHALL_ACT])
-		tc_print_action(f, tb[TCA_MATCHALL_ACT]);
+		tc_print_action(f, tb[TCA_MATCHALL_ACT], 0);
 
 	return 0;
 }
diff --git a/tc/f_route.c b/tc/f_route.c
index 30514c4..e88313f 100644
--- a/tc/f_route.c
+++ b/tc/f_route.c
@@ -168,7 +168,7 @@ static int route_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
 	if (tb[TCA_ROUTE4_POLICE])
 		tc_print_police(f, tb[TCA_ROUTE4_POLICE]);
 	if (tb[TCA_ROUTE4_ACT])
-		tc_print_action(f, tb[TCA_ROUTE4_ACT]);
+		tc_print_action(f, tb[TCA_ROUTE4_ACT], 0);
 	return 0;
 }
 
diff --git a/tc/f_rsvp.c b/tc/f_rsvp.c
index 94bfbef..65caeb4 100644
--- a/tc/f_rsvp.c
+++ b/tc/f_rsvp.c
@@ -402,7 +402,7 @@ static int rsvp_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt, _
 	}
 
 	if (tb[TCA_RSVP_ACT]) {
-		tc_print_action(f, tb[TCA_RSVP_ACT]);
+		tc_print_action(f, tb[TCA_RSVP_ACT], 0);
 	}
 	if (tb[TCA_RSVP_POLICE])
 		tc_print_police(f, tb[TCA_RSVP_POLICE]);
diff --git a/tc/f_tcindex.c b/tc/f_tcindex.c
index 784c890..dd1cb47 100644
--- a/tc/f_tcindex.c
+++ b/tc/f_tcindex.c
@@ -173,7 +173,7 @@ static int tcindex_print_opt(struct filter_util *qu, FILE *f,
 	}
 	if (tb[TCA_TCINDEX_ACT]) {
 		fprintf(f, "\n");
-		tc_print_action(f, tb[TCA_TCINDEX_ACT]);
+		tc_print_action(f, tb[TCA_TCINDEX_ACT], 0);
 	}
 	return 0;
 }
diff --git a/tc/f_u32.c b/tc/f_u32.c
index b272c2c..5815be9 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -1337,7 +1337,7 @@ static int u32_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
 	}
 
 	if (tb[TCA_U32_ACT])
-		tc_print_action(f, tb[TCA_U32_ACT]);
+		tc_print_action(f, tb[TCA_U32_ACT], 0);
 
 	return 0;
 }
diff --git a/tc/m_action.c b/tc/m_action.c
index 6ebe85e..50d16b4 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -346,21 +346,25 @@ tc_print_action_flush(FILE *f, const struct rtattr *arg)
 }
 
 int
-tc_print_action(FILE *f, const struct rtattr *arg)
+tc_print_action(FILE *f, const struct rtattr *arg, unsigned short tot_acts)
 {
 
 	int i;
-	struct rtattr *tb[TCA_ACT_MAX_PRIO + 1];
 
 	if (arg == NULL)
 		return 0;
 
-	parse_rtattr_nested(tb, TCA_ACT_MAX_PRIO, arg);
+	if (!tot_acts)
+		tot_acts = TCA_ACT_MAX_PRIO;
+
+	struct rtattr *tb[tot_acts + 1];
+
+	parse_rtattr_nested(tb, tot_acts, arg);
 
 	if (tab_flush && NULL != tb[0]  && NULL == tb[1])
 		return tc_print_action_flush(f, tb[0]);
 
-	for (i = 0; i < TCA_ACT_MAX_PRIO; i++) {
+	for (i = 0; i < tot_acts; i++) {
 		if (tb[i]) {
 			fprintf(f, "\n\taction order %d: ", i);
 			if (tc_print_one_action(f, tb[i]) < 0) {
@@ -380,7 +384,8 @@ int print_action(const struct sockaddr_nl *who,
 	FILE *fp = (FILE *)arg;
 	struct tcamsg *t = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
-	struct rtattr *tb[TCAA_MAX+1];
+	__u32 *tot_acts = NULL;
+	struct rtattr *tb[TCA_ROOT_MAX+1];
 
 	len -= NLMSG_LENGTH(sizeof(*t));
 
@@ -389,8 +394,12 @@ int print_action(const struct sockaddr_nl *who,
 		return -1;
 	}
 
-	parse_rtattr(tb, TCAA_MAX, TA_RTA(t), len);
+	parse_rtattr(tb, TCA_ROOT_MAX, TA_RTA(t), len);
+
+	if (tb[TCA_ROOT_COUNT])
+		tot_acts = RTA_DATA(tb[TCA_ROOT_COUNT]);
 
+	fprintf(fp, "total acts %d\n", tot_acts ? *tot_acts:0);
 	if (tb[TCA_ACT_TAB] == NULL) {
 		if (n->nlmsg_type != RTM_GETACTION)
 			fprintf(stderr, "print_action: NULL kind\n");
@@ -414,7 +423,9 @@ int print_action(const struct sockaddr_nl *who,
 			fprintf(fp, "Replaced action ");
 		}
 	}
-	tc_print_action(fp, tb[TCA_ACT_TAB]);
+
+
+	tc_print_action(fp, tb[TCA_ACT_TAB], tot_acts ? *tot_acts:0);
 
 	return 0;
 }
@@ -427,7 +438,7 @@ static int tc_action_gd(int cmd, unsigned int flags, int *argc_p, char ***argv_p
 	char **argv = *argv_p;
 	int prio = 0;
 	int ret = 0;
-	__u32 i;
+	__u32 i = 0;
 	struct rtattr *tail;
 	struct rtattr *tail2;
 	struct nlmsghdr *ans = NULL;
@@ -498,7 +509,8 @@ static int tc_action_gd(int cmd, unsigned int flags, int *argc_p, char ***argv_p
 		tail2 = NLMSG_TAIL(&req.n);
 		addattr_l(&req.n, MAX_MSG, ++prio, NULL, 0);
 		addattr_l(&req.n, MAX_MSG, TCA_ACT_KIND, k, strlen(k) + 1);
-		addattr32(&req.n, MAX_MSG, TCA_ACT_INDEX, i);
+		if (i > 0)
+			addattr32(&req.n, MAX_MSG, TCA_ACT_INDEX, i);
 		tail2->rta_len = (void *) NLMSG_TAIL(&req.n) - (void *) tail2;
 
 	}
@@ -561,12 +573,16 @@ static int tc_action_modify(int cmd, unsigned int flags, int *argc_p, char ***ar
 	return ret;
 }
 
-static int tc_act_list_or_flush(int argc, char **argv, int event)
+static int tc_act_list_or_flush(int *argc_p, char ***argv_p, int event)
 {
+	struct rtattr *tail, *tail2, *tail3, *tail4;
 	int ret = 0, prio = 0, msg_size = 0;
-	char k[16];
-	struct rtattr *tail, *tail2;
 	struct action_util *a = NULL;
+	struct nla_bitfield32 flag_select = { 0 };
+	char **argv = *argv_p;
+	__u32 msec_since = 0;
+	int argc = *argc_p;
+	char k[16];
 	struct {
 		struct nlmsghdr         n;
 		struct tcamsg           t;
@@ -597,11 +613,31 @@ static int tc_act_list_or_flush(int argc, char **argv, int event)
 	}
 	strncpy(k, *argv, sizeof(k) - 1);
 
+	argc -= 1;
+	argv += 1;
+
+	if (argc && (strcmp(*argv, "since") == 0)) {
+		NEXT_ARG();
+		if (get_u32(&msec_since, *argv, 0))
+			invarg("dump time \"since\" is invalid", *argv);
+	}
+
 	addattr_l(&req.n, MAX_MSG, ++prio, NULL, 0);
 	addattr_l(&req.n, MAX_MSG, TCA_ACT_KIND, k, strlen(k) + 1);
 	tail2->rta_len = (void *) NLMSG_TAIL(&req.n) - (void *) tail2;
 	tail->rta_len = (void *) NLMSG_TAIL(&req.n) - (void *) tail;
 
+	tail3 = NLMSG_TAIL(&req.n);
+	flag_select.value |= TCA_FLAG_LARGE_DUMP_ON;
+	flag_select.selector |= TCA_FLAG_LARGE_DUMP_ON;
+	addattr_l(&req.n, MAX_MSG, TCA_ROOT_FLAGS, &flag_select,
+		  sizeof(struct nla_bitfield32));
+	tail3->rta_len = (void *) NLMSG_TAIL(&req.n) - (void *) tail3;
+	if (msec_since) {
+		tail4 = NLMSG_TAIL(&req.n);
+		addattr32(&req.n, MAX_MSG, TCA_ROOT_TIME_DELTA, msec_since);
+		tail4->rta_len = (void *) NLMSG_TAIL(&req.n) - (void *) tail4;
+	}
 	msg_size = NLMSG_ALIGN(req.n.nlmsg_len) - NLMSG_ALIGN(sizeof(struct nlmsghdr));
 
 	if (event == RTM_GETACTION) {
@@ -626,6 +662,8 @@ static int tc_act_list_or_flush(int argc, char **argv, int event)
 
 bad_val:
 
+	*argc_p = argc;
+	*argv_p = argv;
 	return ret;
 }
 
@@ -655,13 +693,21 @@ int do_action(int argc, char **argv)
 				act_usage();
 				return -1;
 			}
-			return tc_act_list_or_flush(argc-2, argv+2, RTM_GETACTION);
+
+			argc -= 2;
+			argv += 2;
+			return tc_act_list_or_flush(&argc, &argv,
+						    RTM_GETACTION);
 		} else if (matches(*argv, "flush") == 0) {
 			if (argc <= 2) {
 				act_usage();
 				return -1;
 			}
-			return tc_act_list_or_flush(argc-2, argv+2, RTM_DELACTION);
+
+			argc -= 2;
+			argv += 2;
+			return tc_act_list_or_flush(&argc, &argv,
+						    RTM_DELACTION);
 		} else if (matches(*argv, "help") == 0) {
 			act_usage();
 			return -1;
diff --git a/tc/tc_util.h b/tc/tc_util.h
index 5c54ad3..583a21a 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -113,7 +113,7 @@ int act_parse_police(struct action_util *a, int *argc_p,
 		     char ***argv_p, int tca_id, struct nlmsghdr *n);
 int print_police(struct action_util *a, FILE *f, struct rtattr *tb);
 int police_print_xstats(struct action_util *a, FILE *f, struct rtattr *tb);
-int tc_print_action(FILE *f, const struct rtattr *tb);
+int tc_print_action(FILE *f, const struct rtattr *tb, unsigned short tot_acts);
 int tc_print_ipt(FILE *f, const struct rtattr *tb);
 int parse_action(int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n);
 void print_tm(FILE *f, const struct tcf_t *tm);
-- 
1.9.1

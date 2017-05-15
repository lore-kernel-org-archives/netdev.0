From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v2 2/3] tc: actions: add helpers to parse and print control actions
Date: Mon, 15 May 2017 10:41:45 +0200
Message-ID: <20170515084146.3698-2-jiri@resnulli.us>
References: <20170515083857.3615-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33072 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933122AbdEOIlv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 04:41:51 -0400
Received: by mail-wr0-f194.google.com with SMTP id w50so14117675wrc.0
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 01:41:50 -0700 (PDT)
In-Reply-To: <20170515083857.3615-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Each tc action is terminated by a control action. Each action parses and
prints then intividually. Introduce set of helpers and allow to share
this code.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 tc/m_bpf.c        |   8 ++--
 tc/m_connmark.c   |   4 +-
 tc/m_csum.c       |   9 ++--
 tc/m_gact.c       |  44 +++++-------------
 tc/m_ife.c        |  10 ++--
 tc/m_mirred.c     |  10 ++--
 tc/m_nat.c        |  11 ++---
 tc/m_pedit.c      |   8 ++--
 tc/m_police.c     |  50 ++++++--------------
 tc/m_sample.c     |   4 +-
 tc/m_simple.c     |   3 --
 tc/m_skbedit.c    |   7 ++-
 tc/m_skbmod.c     |  30 ++----------
 tc/m_tunnel_key.c |   8 ++--
 tc/m_vlan.c       |   9 ++--
 tc/tc_util.c      | 137 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 tc/tc_util.h      |  11 ++++-
 17 files changed, 210 insertions(+), 153 deletions(-)

diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index 1ddc334..5728303 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -75,7 +75,7 @@ static int bpf_parse_opt(struct action_util *a, int *ptr_argc, char ***ptr_argv,
 			 int tca_id, struct nlmsghdr *n)
 {
 	const char *bpf_obj = NULL, *bpf_uds_name = NULL;
-	struct tc_act_bpf parm = { .action = TC_ACT_PIPE };
+	struct tc_act_bpf parm = {};
 	struct bpf_cfg_in cfg = {};
 	bool seen_run = false;
 	struct rtattr *tail;
@@ -123,8 +123,8 @@ opt_bpf:
 		NEXT_ARG_FWD();
 	}
 
-	if (argc && !action_a2n(*argv, &parm.action, false))
-		NEXT_ARG_FWD();
+	parse_action_control_dflt(&argc, &argv, &parm.action,
+				  false, TC_ACT_PIPE);
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
@@ -186,7 +186,7 @@ static int bpf_print_opt(struct action_util *au, FILE *f, struct rtattr *arg)
 				      b, sizeof(b)));
 	}
 
-	fprintf(f, "default-action %s\n", action_n2a(parm->action));
+	print_action_control(f, "default-action ", parm->action, "\n");
 	fprintf(f, "\tindex %u ref %d bind %d", parm->index, parm->refcnt,
 		parm->bindcnt);
 
diff --git a/tc/m_connmark.c b/tc/m_connmark.c
index 295f90d..3c2274b 100644
--- a/tc/m_connmark.c
+++ b/tc/m_connmark.c
@@ -80,9 +80,7 @@ parse_connmark(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 		}
 	}
 
-	sel.action = TC_ACT_PIPE;
-	if (argc && !action_a2n(*argv, &sel.action, false))
-		NEXT_ARG_FWD();
+	parse_action_control_dflt(&argc, &argv, &sel.action, false, TC_ACT_PIPE);
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
diff --git a/tc/m_csum.c b/tc/m_csum.c
index 0ee8cad..7b15673 100644
--- a/tc/m_csum.c
+++ b/tc/m_csum.c
@@ -123,8 +123,7 @@ parse_csum(struct action_util *a, int *argc_p,
 		return -1;
 	}
 
-	if (argc && !action_a2n(*argv, &sel.action, false))
-		NEXT_ARG_FWD();
+	parse_action_control_dflt(&argc, &argv, &sel.action, false, TC_ACT_OK);
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
@@ -200,10 +199,10 @@ print_csum(struct action_util *au, FILE *f, struct rtattr *arg)
 		uflag_1 = "?empty";
 	}
 
-	fprintf(f, "csum (%s%s%s%s%s%s%s) action %s\n",
+	fprintf(f, "csum (%s%s%s%s%s%s%s) ",
 		uflag_1, uflag_2, uflag_3,
-		uflag_4, uflag_5, uflag_6, uflag_7,
-		action_n2a(sel->action));
+		uflag_4, uflag_5, uflag_6, uflag_7);
+	print_action_control(f, "action ", sel->action, "\n");
 	fprintf(f, "\tindex %u ref %d bind %d", sel->index, sel->refcnt,
 		sel->bindcnt);
 
diff --git a/tc/m_gact.c b/tc/m_gact.c
index 755a3be..938b6b5 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -69,26 +69,13 @@ usage(void)
 }
 
 static int
-get_act(char ***argv_p)
-{
-	int n;
-
-	if (action_a2n(**argv_p, &n, false)) {
-		fprintf(stderr, "bad action type %s\n", **argv_p);
-		return -10;
-	}
-	return n;
-}
-
-static int
 parse_gact(struct action_util *a, int *argc_p, char ***argv_p,
 	   int tca_id, struct nlmsghdr *n)
 {
 	int argc = *argc_p;
 	char **argv = *argv_p;
 	int ok = 0;
-	int action = TC_POLICE_RECLASSIFY;
-	struct tc_gact p = { .action = TC_POLICE_RECLASSIFY };
+	struct tc_gact p = { 0 };
 #ifdef CONFIG_GACT_PROB
 	int rd = 0;
 	struct tc_gact_p pp;
@@ -102,14 +89,9 @@ parse_gact(struct action_util *a, int *argc_p, char ***argv_p,
 	if (matches(*argv, "gact") == 0) {
 		ok++;
 	} else {
-		action = get_act(&argv);
-		if (action != -10) {
-			p.action = action;
-			ok++;
-		} else {
-			explain();
-			return action;
-		}
+		if (parse_action_control(&argc, &argv, &p.action, false) == -1)
+			usage();
+		ok++;
 	}
 
 	if (ok) {
@@ -133,13 +115,9 @@ parse_gact(struct action_util *a, int *argc_p, char ***argv_p,
 				return -1;
 			}
 
-			action = get_act(&argv);
-			if (action != -10) { /* FIXME */
-				pp.paction = action;
-			} else {
-				explain();
-				return -1;
-			}
+			if (parse_action_control(&argc, &argv,
+						 &pp.paction, false) == -1)
+				usage();
 			argc--;
 			argv++;
 			if (get_u16(&pp.pval, *argv, 10)) {
@@ -212,7 +190,8 @@ print_gact(struct action_util *au, FILE * f, struct rtattr *arg)
 	}
 	p = RTA_DATA(tb[TCA_GACT_PARMS]);
 
-	fprintf(f, "gact action %s", action_n2a(p->action));
+	fprintf(f, "gact ");
+	print_action_control(f, "action ", p->action, "");
 #ifdef CONFIG_GACT_PROB
 	if (tb[TCA_GACT_PROB] != NULL) {
 		pp = RTA_DATA(tb[TCA_GACT_PROB]);
@@ -221,8 +200,9 @@ print_gact(struct action_util *au, FILE * f, struct rtattr *arg)
 		memset(&pp_dummy, 0, sizeof(pp_dummy));
 		pp = &pp_dummy;
 	}
-	fprintf(f, "\n\t random type %s %s val %d",
-		prob_n2a(pp->ptype), action_n2a(pp->paction), pp->pval);
+	fprintf(f, "\n\t random type %s", prob_n2a(pp->ptype));
+	print_action_control(f, " ", pp->paction, " ");
+	fprintf(f, "val %d", pp->pval);
 #endif
 	fprintf(f, "\n\t index %u ref %d bind %d", p->index, p->refcnt,
 		p->bindcnt);
diff --git a/tc/m_ife.c b/tc/m_ife.c
index f6131b1..e3521e6 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -57,7 +57,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 	int argc = *argc_p;
 	char **argv = *argv_p;
 	int ok = 0;
-	struct tc_ife p = { .action = TC_ACT_PIPE };	/* good default */
+	struct tc_ife p = { 0 };
 	struct rtattr *tail;
 	struct rtattr *tail2;
 	char dbuf[ETH_ALEN];
@@ -156,8 +156,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 		argv++;
 	}
 
-	if (argc && !action_a2n(*argv, &p.action, false))
-		NEXT_ARG_FWD();
+	parse_action_control_dflt(&argc, &argv, &p.action, false, TC_ACT_PIPE);
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
@@ -245,9 +244,8 @@ static int print_ife(struct action_util *au, FILE *f, struct rtattr *arg)
 	}
 	p = RTA_DATA(tb[TCA_IFE_PARMS]);
 
-	fprintf(f, "ife %s action %s ",
-		(p->flags & IFE_ENCODE) ? "encode" : "decode",
-		action_n2a(p->action));
+	fprintf(f, "ife %s ", p->flags & IFE_ENCODE ? "encode" : "decode");
+	print_action_control(f, "action ", p->action, " ");
 
 	if (tb[TCA_IFE_TYPE]) {
 		ife_type = rta_getattr_u16(tb[TCA_IFE_TYPE]);
diff --git a/tc/m_mirred.c b/tc/m_mirred.c
index e943890..2384bda 100644
--- a/tc/m_mirred.c
+++ b/tc/m_mirred.c
@@ -170,10 +170,8 @@ parse_direction(struct action_util *a, int *argc_p, char ***argv_p,
 	}
 
 
-	if (argc &&
-	    (p.eaction == TCA_EGRESS_MIRROR || p.eaction == TCA_INGRESS_MIRROR)
-	    && !action_a2n(*argv, &p.action, false))
-		NEXT_ARG();
+	if (p.eaction == TCA_EGRESS_MIRROR || p.eaction == TCA_INGRESS_MIRROR)
+		parse_action_control(&argc, &argv, &p.action, false);
 
 	if (argc) {
 		if (iok && matches(*argv, "index") == 0) {
@@ -272,8 +270,8 @@ print_mirred(struct action_util *au, FILE * f, struct rtattr *arg)
 		return -1;
 	}
 
-	fprintf(f, "mirred (%s to device %s) %s",
-		mirred_n2a(p->eaction), dev, action_n2a(p->action));
+	fprintf(f, "mirred (%s to device %s)", mirred_n2a(p->eaction), dev);
+	print_action_control(f, " ", p->action, "");
 
 	fprintf(f, "\n ");
 	fprintf(f, "\tindex %u ref %d bind %d", p->index, p->refcnt,
diff --git a/tc/m_nat.c b/tc/m_nat.c
index 525f185..31b68fb 100644
--- a/tc/m_nat.c
+++ b/tc/m_nat.c
@@ -115,8 +115,7 @@ parse_nat(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct
 		return -1;
 	}
 
-	if (argc && !action_a2n(*argv, &sel.action, false))
-		NEXT_ARG_FWD();
+	parse_action_control_dflt(&argc, &argv, &sel.action, false, TC_ACT_OK);
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
@@ -164,12 +163,12 @@ print_nat(struct action_util *au, FILE * f, struct rtattr *arg)
 	len = ffs(sel->mask);
 	len = len ? 33 - len : 0;
 
-	fprintf(f, " nat %s %s/%d %s %s", sel->flags & TCA_NAT_FLAG_EGRESS ?
-					  "egress" : "ingress",
+	fprintf(f, " nat %s %s/%d %s", sel->flags & TCA_NAT_FLAG_EGRESS ?
+				       "egress" : "ingress",
 		format_host_r(AF_INET, 4, &sel->old_addr, buf1, sizeof(buf1)),
 		len,
-		format_host_r(AF_INET, 4, &sel->new_addr, buf2, sizeof(buf2)),
-		action_n2a(sel->action));
+		format_host_r(AF_INET, 4, &sel->new_addr, buf2, sizeof(buf2)));
+	print_action_control(f, " ", sel->action, "");
 
 	if (show_stats) {
 		if (tb[TCA_NAT_TM]) {
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 6498dd9..730a434 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -625,8 +625,7 @@ int parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 		return -1;
 	}
 
-	if (argc && !action_a2n(*argv, &sel.sel.action, false))
-		NEXT_ARG();
+	parse_action_control_dflt(&argc, &argv, &sel.sel.action, false, TC_ACT_OK);
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
@@ -731,8 +730,9 @@ int print_pedit(struct action_util *au, FILE *f, struct rtattr *arg)
 		}
 	}
 
-	fprintf(f, " pedit action %s keys %d\n ",
-		action_n2a(sel->action), sel->nkeys);
+	fprintf(f, " pedit ");
+	print_action_control(f, "action ", sel->action, " ");
+	fprintf(f,"keys %d\n ", sel->nkeys);
 	fprintf(f, "\t index %u ref %d bind %d", sel->index, sel->refcnt,
 		sel->bindcnt);
 
diff --git a/tc/m_police.c b/tc/m_police.c
index 226e20e..2b73969 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -50,27 +50,6 @@ static void explain1(char *arg)
 	fprintf(stderr, "Illegal \"%s\"\n", arg);
 }
 
-static int get_police_result(int *action, int *result, char *arg)
-{
-	char *p = strchr(arg, '/');
-
-	if (p)
-		*p = 0;
-
-	if (action_a2n(arg, action, true)) {
-		if (p)
-			*p = '/';
-		return -1;
-	}
-
-	if (p) {
-		*p = '/';
-		if (action_a2n(p+1, result, true))
-			return -1;
-	}
-	return 0;
-}
-
 int act_parse_police(struct action_util *a, int *argc_p, char ***argv_p,
 		     int tca_id, struct nlmsghdr *n)
 {
@@ -166,23 +145,19 @@ int act_parse_police(struct action_util *a, int *argc_p, char ***argv_p,
 				explain1("peakrate");
 				return -1;
 			}
-		} else if (matches(*argv, "reclassify") == 0) {
-			p.action = TC_POLICE_RECLASSIFY;
-		} else if (matches(*argv, "drop") == 0 ||
-			   matches(*argv, "shot") == 0) {
-			p.action = TC_POLICE_SHOT;
-		} else if (matches(*argv, "continue") == 0) {
-			p.action = TC_POLICE_UNSPEC;
-		} else if (matches(*argv, "pass") == 0) {
-			p.action = TC_POLICE_OK;
-		} else if (matches(*argv, "pipe") == 0) {
-			p.action = TC_POLICE_PIPE;
+		} else if (matches(*argv, "reclassify") == 0 ||
+			   matches(*argv, "drop") == 0 ||
+			   matches(*argv, "shot") == 0 ||
+			   matches(*argv, "continue") == 0 ||
+			   matches(*argv, "pass") == 0 ||
+			   matches(*argv, "pipe") == 0) {
+			if (parse_action_control(&argc, &argv, &p.action, false))
+				return -1;
 		} else if (strcmp(*argv, "conform-exceed") == 0) {
 			NEXT_ARG();
-			if (get_police_result(&p.action, &presult, *argv)) {
-				fprintf(stderr, "Illegal \"action\"\n");
+			if (parse_action_control_slash(&argc, &argv, &p.action,
+						       &presult, true))
 				return -1;
-			}
 		} else if (matches(*argv, "overhead") == 0) {
 			NEXT_ARG();
 			if (get_u16(&overhead, *argv, 10)) {
@@ -318,12 +293,13 @@ int print_police(struct action_util *a, FILE *f, struct rtattr *arg)
 		fprintf(f, "avrate %s ",
 			sprint_rate(rta_getattr_u32(tb[TCA_POLICE_AVRATE]),
 				    b1));
-	fprintf(f, "action %s", action_n2a(p->action));
+
+	print_action_control(f, "action ", p->action, "");
 
 	if (tb[TCA_POLICE_RESULT]) {
 		__u32 action = rta_getattr_u32(tb[TCA_POLICE_RESULT]);
 
-		fprintf(f, "/%s ", action_n2a(action));
+		print_action_control(f, "/", action, " ");
 	} else
 		fprintf(f, " ");
 
diff --git a/tc/m_sample.c b/tc/m_sample.c
index 9291109..ff5ee6b 100644
--- a/tc/m_sample.c
+++ b/tc/m_sample.c
@@ -98,9 +98,7 @@ static int parse_sample(struct action_util *a, int *argc_p, char ***argv_p,
 		NEXT_ARG_FWD();
 	}
 
-	p.action = TC_ACT_PIPE;
-	if (argc && !action_a2n(*argv, &p.action, false))
-		NEXT_ARG_FWD();
+	parse_action_control_dflt(&argc, &argv, &p.action, false, TC_ACT_PIPE);
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
diff --git a/tc/m_simple.c b/tc/m_simple.c
index 3a8bd91..a4457c7 100644
--- a/tc/m_simple.c
+++ b/tc/m_simple.c
@@ -120,9 +120,6 @@ parse_simple(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 		}
 	}
 
-	if (argc && !action_a2n(*argv, &sel.action, false))
-		NEXT_ARG_FWD();
-
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
 			NEXT_ARG();
diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index 638715f..aa374fc 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -120,9 +120,8 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 		argv++;
 	}
 
-	sel.action = TC_ACT_PIPE;
-	if (argc && !action_a2n(*argv, &sel.action, false))
-		NEXT_ARG();
+	parse_action_control_dflt(&argc, &argv, &sel.action,
+				  false, TC_ACT_PIPE);
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
@@ -214,7 +213,7 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 			fprintf(f, " ptype %d", *ptype);
 	}
 
-	fprintf(f, " %s", action_n2a(p->action));
+	print_action_control(f, " ", p->action, "");
 
 	fprintf(f, "\n\t index %u ref %d bind %d",
 		p->index, p->refcnt, p->bindcnt);
diff --git a/tc/m_skbmod.c b/tc/m_skbmod.c
index acb7771..1ccd474 100644
--- a/tc/m_skbmod.c
+++ b/tc/m_skbmod.c
@@ -61,7 +61,6 @@ static int parse_skbmod(struct action_util *a, int *argc_p, char ***argv_p,
 	char *saddr = NULL;
 
 	memset(&p, 0, sizeof(p));
-	p.action = TC_ACT_PIPE;	/* good default */
 
 	if (argc <= 0)
 		return -1;
@@ -123,31 +122,7 @@ static int parse_skbmod(struct action_util *a, int *argc_p, char ***argv_p,
 		argv++;
 	}
 
-	if (argc) {
-		if (matches(*argv, "reclassify") == 0) {
-			p.action = TC_ACT_RECLASSIFY;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pipe") == 0) {
-			p.action = TC_ACT_PIPE;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "drop") == 0 ||
-			   matches(*argv, "shot") == 0) {
-			p.action = TC_ACT_SHOT;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "continue") == 0) {
-			p.action = TC_ACT_UNSPEC;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pass") == 0 ||
-			   matches(*argv, "ok") == 0) {
-			p.action = TC_ACT_OK;
-			argc--;
-			argv++;
-		}
-	}
+	parse_action_control_dflt(&argc, &argv, &p.action, false, TC_ACT_PIPE);
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
@@ -206,7 +181,8 @@ static int print_skbmod(struct action_util *au, FILE *f, struct rtattr *arg)
 
 	p = RTA_DATA(tb[TCA_SKBMOD_PARMS]);
 
-	fprintf(f, "skbmod action %s ", action_n2a(p->action));
+	fprintf(f, "skbmod ");
+	print_action_control(f, "", p->action, " ");
 
 	if (tb[TCA_SKBMOD_ETYPE]) {
 		skbmod_etype = rta_getattr_u16(tb[TCA_SKBMOD_ETYPE]);
diff --git a/tc/m_tunnel_key.c b/tc/m_tunnel_key.c
index 3ceec1c..fb418a7 100644
--- a/tc/m_tunnel_key.c
+++ b/tc/m_tunnel_key.c
@@ -77,7 +77,7 @@ static int tunnel_key_parse_dst_port(char *str, int type, struct nlmsghdr *n)
 static int parse_tunnel_key(struct action_util *a, int *argc_p, char ***argv_p,
 			    int tca_id, struct nlmsghdr *n)
 {
-	struct tc_tunnel_key parm = { .action = TC_ACT_PIPE };
+	struct tc_tunnel_key parm = {};
 	char **argv = *argv_p;
 	int argc = *argc_p;
 	struct rtattr *tail;
@@ -158,8 +158,8 @@ static int parse_tunnel_key(struct action_util *a, int *argc_p, char ***argv_p,
 		NEXT_ARG_FWD();
 	}
 
-	if (argc && !action_a2n(*argv, &parm.action, false))
-		NEXT_ARG_FWD();
+	parse_action_control_dflt(&argc, &argv, &parm.action,
+				  false, TC_ACT_PIPE);
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
@@ -265,7 +265,7 @@ static int print_tunnel_key(struct action_util *au, FILE *f, struct rtattr *arg)
 					  tb[TCA_TUNNEL_KEY_ENC_DST_PORT]);
 		break;
 	}
-	fprintf(f, " %s", action_n2a(parm->action));
+	print_action_control(f, " ", parm->action, "");
 
 	fprintf(f, "\n\tindex %d ref %d bind %d", parm->index, parm->refcnt,
 		parm->bindcnt);
diff --git a/tc/m_vlan.c b/tc/m_vlan.c
index 44b9375..2441b06 100644
--- a/tc/m_vlan.c
+++ b/tc/m_vlan.c
@@ -59,7 +59,7 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 	int proto_set = 0;
 	__u8 prio;
 	int prio_set = 0;
-	struct tc_vlan parm = { 0 };
+	struct tc_vlan parm = {};
 
 	if (matches(*argv, "vlan") != 0)
 		return -1;
@@ -133,9 +133,8 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 		argv++;
 	}
 
-	parm.action = TC_ACT_PIPE;
-	if (argc && !action_a2n(*argv, &parm.action, false))
-		NEXT_ARG_FWD();
+	parse_action_control_dflt(&argc, &argv, &parm.action,
+				  false, TC_ACT_PIPE);
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
@@ -224,7 +223,7 @@ static int print_vlan(struct action_util *au, FILE *f, struct rtattr *arg)
 		}
 		break;
 	}
-	fprintf(f, " %s", action_n2a(parm->action));
+	print_action_control(f, " ", parm->action, "");
 
 	fprintf(f, "\n\t index %u ref %d bind %d", parm->index, parm->refcnt,
 		parm->bindcnt);
diff --git a/tc/tc_util.c b/tc/tc_util.c
index 24ca1f1..fd543c5 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -411,7 +411,7 @@ char *sprint_qdisc_handle(__u32 h, char *buf)
 	return buf;
 }
 
-const char *action_n2a(int action)
+static const char *action_n2a(int action)
 {
 	static char buf[64];
 
@@ -444,7 +444,7 @@ const char *action_n2a(int action)
  *
  * In error case, returns -1 and does not touch @result. Otherwise returns 0.
  */
-int action_a2n(char *arg, int *result, bool allow_num)
+static int action_a2n(char *arg, int *result, bool allow_num)
 {
 	int n;
 	char dummy;
@@ -475,6 +475,139 @@ int action_a2n(char *arg, int *result, bool allow_num)
 	return 0;
 }
 
+/* Parse action control including possible options.
+ *
+ * Parameters:
+ * @argc_p - pointer to argc to parse
+ * @argv_p - pointer to argv to parse
+ * @result_p - pointer to output variable
+ * @allow_num - whether action may be in numeric format already
+ *
+ * In error case, returns -1 and does not touch @result_1p. Otherwise returns 0.
+ */
+int parse_action_control(int *argc_p, char ***argv_p,
+			 int *result_p, bool allow_num)
+{
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	int result;
+
+	if (!argc)
+		return -1;
+	if (action_a2n(*argv, &result, allow_num) == -1) {
+		fprintf(stderr, "Bad action type %s\n", *argv);
+		return -1;
+	}
+	NEXT_ARG_FWD();
+	*argc_p = argc;
+	*argv_p = argv;
+	*result_p = result;
+	return 0;
+}
+
+/* Parse action control including possible options.
+ *
+ * Parameters:
+ * @argc_p - pointer to argc to parse
+ * @argv_p - pointer to argv to parse
+ * @result_p - pointer to output variable
+ * @allow_num - whether action may be in numeric format already
+ * @default_result - set as a result in case of parsing error
+ *
+ * In case there is an error during parsing, the default result is used.
+ */
+void parse_action_control_dflt(int *argc_p, char ***argv_p,
+			       int *result_p, bool allow_num,
+			       int default_result)
+{
+	if (parse_action_control(argc_p, argv_p, result_p, allow_num))
+		*result_p = default_result;
+}
+
+static int parse_action_control_slash_spaces(int *argc_p, char ***argv_p,
+					     int *result1_p, int *result2_p,
+					     bool allow_num)
+{
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	int result1, result2;
+	int *result_p = &result1;
+	int ok = 0;
+	int ret;
+
+	while (argc > 0) {
+		switch (ok) {
+		case 1:
+			if (strcmp(*argv, "/") != 0)
+				goto out;
+			result_p = &result2;
+			NEXT_ARG();
+			/* fall-through */
+		case 0: /* fall-through */
+		case 2:
+			ret = parse_action_control(&argc, &argv,
+						   result_p, allow_num);
+			if (ret)
+				return ret;
+			ok++;
+			break;
+		default:
+			goto out;
+		}
+	}
+out:
+	*result1_p = result1;
+	if (ok == 2)
+		*result2_p = result2;
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+}
+
+/* Parse action control with slash including possible options.
+ *
+ * Parameters:
+ * @argc_p - pointer to argc to parse
+ * @argv_p - pointer to argv to parse
+ * @result1_p - pointer to the first (before slash) output variable
+ * @result2_p - pointer to the second (after slash) output variable
+ * @allow_num - whether action may be in numeric format already
+ *
+ * In error case, returns -1 and does not touch @result*. Otherwise returns 0.
+ */
+int parse_action_control_slash(int *argc_p, char ***argv_p,
+			       int *result1_p, int *result2_p, bool allow_num)
+{
+	char **argv = *argv_p;
+	int result1, result2;
+	char *p = strchr(*argv, '/');
+
+	if (!p)
+		return parse_action_control_slash_spaces(argc_p, argv_p,
+							 result1_p, result2_p,
+							 allow_num);
+	*p = 0;
+	if (action_a2n(*argv, &result1, allow_num)) {
+		if (p)
+			*p = '/';
+		return -1;
+	}
+
+	*p = '/';
+	if (action_a2n(p + 1, &result2, allow_num))
+		return -1;
+
+	*result1_p = result1;
+	*result2_p = result2;
+	return 0;
+}
+
+void print_action_control(FILE *f, const char *prefix,
+			  int action, const char *suffix)
+{
+	fprintf(f, "%s%s%s", prefix, action_n2a(action), suffix);
+}
+
 int get_linklayer(unsigned int *val, const char *arg)
 {
 	int res;
diff --git a/tc/tc_util.h b/tc/tc_util.h
index 4db26c6..5c54ad3 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -100,8 +100,15 @@ char *sprint_tc_classid(__u32 h, char *buf);
 int tc_print_police(FILE *f, struct rtattr *tb);
 int parse_police(int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n);
 
-const char *action_n2a(int action);
-int action_a2n(char *arg, int *result, bool allow_num);
+int parse_action_control(int *argc_p, char ***argv_p,
+			 int *result_p, bool allow_num);
+void parse_action_control_dflt(int *argc_p, char ***argv_p,
+			       int *result_p, bool allow_num,
+			       int default_result);
+int parse_action_control_slash(int *argc_p, char ***argv_p,
+			       int *result1_p, int *result2_p, bool allow_num);
+void print_action_control(FILE *f, const char *prefix,
+			  int action, const char *suffix);
 int act_parse_police(struct action_util *a, int *argc_p,
 		     char ***argv_p, int tca_id, struct nlmsghdr *n);
 int print_police(struct action_util *a, FILE *f, struct rtattr *tb);
-- 
2.9.3

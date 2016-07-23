From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 4/4] tc: util: No need for action_n2a() to be reentrant
Date: Sat, 23 Jul 2016 13:28:10 +0200
Message-ID: <1469273290-18539-5-git-send-email-phil@nwl.cc>
References: <1469273290-18539-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:40681 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260AbcGWL2g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:28:36 -0400
In-Reply-To: <1469273290-18539-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows to remove some buffers here and there. While at it, make it
return a const value.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_bpf.c    |  5 +----
 tc/m_csum.c   |  4 +---
 tc/m_gact.c   |  7 +++----
 tc/m_ife.c    |  3 +--
 tc/m_mirred.c |  5 ++---
 tc/m_nat.c    |  3 +--
 tc/m_pedit.c  |  4 +---
 tc/m_police.c | 28 ++--------------------------
 tc/m_vlan.c   |  2 +-
 tc/tc_util.c  | 12 ++++++------
 tc/tc_util.h  |  2 +-
 11 files changed, 20 insertions(+), 55 deletions(-)

diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index 275634e78b093..9bf2a85ea24b8 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -136,8 +136,6 @@ static int bpf_print_opt(struct action_util *au, FILE *f, struct rtattr *arg)
 	struct rtattr *tb[TCA_ACT_BPF_MAX + 1];
 	struct tc_act_bpf *parm;
 
-	SPRINT_BUF(action_buf);
-
 	if (arg == NULL)
 		return -1;
 
@@ -162,8 +160,7 @@ static int bpf_print_opt(struct action_util *au, FILE *f, struct rtattr *arg)
 		fprintf(f, " ");
 	}
 
-	fprintf(f, "default-action %s\n", action_n2a(parm->action, action_buf,
-		sizeof(action_buf)));
+	fprintf(f, "default-action %s\n", action_n2a(parm->action));
 	fprintf(f, "\tindex %d ref %d bind %d", parm->index, parm->refcnt,
 		parm->bindcnt);
 
diff --git a/tc/m_csum.c b/tc/m_csum.c
index db7eed3adfeaf..a6e4c1eb44e5a 100644
--- a/tc/m_csum.c
+++ b/tc/m_csum.c
@@ -161,8 +161,6 @@ print_csum(struct action_util *au, FILE *f, struct rtattr *arg)
 	char *uflag_5 = "";
 	char *uflag_6 = "";
 
-	SPRINT_BUF(action_buf);
-
 	int uflag_count = 0;
 
 	if (arg == NULL)
@@ -200,7 +198,7 @@ print_csum(struct action_util *au, FILE *f, struct rtattr *arg)
 	fprintf(f, "csum (%s%s%s%s%s%s) action %s\n",
 		uflag_1, uflag_2, uflag_3,
 		uflag_4, uflag_5, uflag_6,
-		action_n2a(sel->action, action_buf, sizeof(action_buf)));
+		action_n2a(sel->action));
 	fprintf(f, "\tindex %d ref %d bind %d", sel->index, sel->refcnt, sel->bindcnt);
 
 	if (show_stats) {
diff --git a/tc/m_gact.c b/tc/m_gact.c
index 9f31fdd324fdc..c0a938c716b6a 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -194,9 +194,7 @@ parse_gact(struct action_util *a, int *argc_p, char ***argv_p,
 static int
 print_gact(struct action_util *au, FILE * f, struct rtattr *arg)
 {
-	SPRINT_BUF(b1);
 #ifdef CONFIG_GACT_PROB
-	SPRINT_BUF(b2);
 	struct tc_gact_p *pp = NULL;
 	struct tc_gact_p pp_dummy;
 #endif
@@ -214,7 +212,7 @@ print_gact(struct action_util *au, FILE * f, struct rtattr *arg)
 	}
 	p = RTA_DATA(tb[TCA_GACT_PARMS]);
 
-	fprintf(f, "gact action %s", action_n2a(p->action, b1, sizeof(b1)));
+	fprintf(f, "gact action %s", action_n2a(p->action));
 #ifdef CONFIG_GACT_PROB
 	if (tb[TCA_GACT_PROB] != NULL) {
 		pp = RTA_DATA(tb[TCA_GACT_PROB]);
@@ -223,7 +221,8 @@ print_gact(struct action_util *au, FILE * f, struct rtattr *arg)
 		memset(&pp_dummy, 0, sizeof(pp_dummy));
 		pp = &pp_dummy;
 	}
-	fprintf(f, "\n\t random type %s %s val %d", prob_n2a(pp->ptype), action_n2a(pp->paction, b2, sizeof (b2)), pp->pval);
+	fprintf(f, "\n\t random type %s %s val %d",
+		prob_n2a(pp->ptype), action_n2a(pp->paction), pp->pval);
 #endif
 	fprintf(f, "\n\t index %d ref %d bind %d", p->index, p->refcnt, p->bindcnt);
 	if (show_stats) {
diff --git a/tc/m_ife.c b/tc/m_ife.c
index 5eee544b71b82..0219760aa3631 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -215,7 +215,6 @@ static int print_ife(struct action_util *au, FILE *f, struct rtattr *arg)
 	__u32 mhash = 0;
 	__u32 mprio = 0;
 	int has_optional = 0;
-	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
 
 	if (arg == NULL)
@@ -231,7 +230,7 @@ static int print_ife(struct action_util *au, FILE *f, struct rtattr *arg)
 
 	fprintf(f, "ife %s action %s ",
 		(p->flags & IFE_ENCODE) ? "encode" : "decode",
-		action_n2a(p->action, b1, sizeof(b1)));
+		action_n2a(p->action));
 
 	if (tb[TCA_IFE_TYPE]) {
 		ife_type = rta_getattr_u16(tb[TCA_IFE_TYPE]);
diff --git a/tc/m_mirred.c b/tc/m_mirred.c
index 61a84f575cf12..11f4c9b46fea9 100644
--- a/tc/m_mirred.c
+++ b/tc/m_mirred.c
@@ -235,8 +235,6 @@ print_mirred(struct action_util *au, FILE * f, struct rtattr *arg)
 	struct rtattr *tb[TCA_MIRRED_MAX + 1];
 	const char *dev;
 
-	SPRINT_BUF(b1);
-
 	if (arg == NULL)
 		return -1;
 
@@ -258,7 +256,8 @@ print_mirred(struct action_util *au, FILE * f, struct rtattr *arg)
 		return -1;
 	}
 
-	fprintf(f, "mirred (%s to device %s) %s", mirred_n2a(p->eaction), dev, action_n2a(p->action, b1, sizeof (b1)));
+	fprintf(f, "mirred (%s to device %s) %s",
+		mirred_n2a(p->eaction), dev, action_n2a(p->action));
 
 	fprintf(f, "\n ");
 	fprintf(f, "\tindex %d ref %d bind %d", p->index, p->refcnt, p->bindcnt);
diff --git a/tc/m_nat.c b/tc/m_nat.c
index 52bafa79e1b73..525f185e2c082 100644
--- a/tc/m_nat.c
+++ b/tc/m_nat.c
@@ -148,7 +148,6 @@ print_nat(struct action_util *au, FILE * f, struct rtattr *arg)
 	char buf1[256];
 	char buf2[256];
 
-	SPRINT_BUF(buf3);
 	int len;
 
 	if (arg == NULL)
@@ -170,7 +169,7 @@ print_nat(struct action_util *au, FILE * f, struct rtattr *arg)
 		format_host_r(AF_INET, 4, &sel->old_addr, buf1, sizeof(buf1)),
 		len,
 		format_host_r(AF_INET, 4, &sel->new_addr, buf2, sizeof(buf2)),
-		action_n2a(sel->action, buf3, sizeof(buf3)));
+		action_n2a(sel->action));
 
 	if (show_stats) {
 		if (tb[TCA_NAT_TM]) {
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index c28f2610aa011..891c2ec7b788e 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -514,8 +514,6 @@ int print_pedit(struct action_util *au, FILE *f, struct rtattr *arg)
 	struct tc_pedit_sel *sel;
 	struct rtattr *tb[TCA_PEDIT_MAX + 1];
 
-	SPRINT_BUF(b1);
-
 	if (arg == NULL)
 		return -1;
 
@@ -528,7 +526,7 @@ int print_pedit(struct action_util *au, FILE *f, struct rtattr *arg)
 	sel = RTA_DATA(tb[TCA_PEDIT_PARMS]);
 
 	fprintf(f, " pedit action %s keys %d\n ",
-		action_n2a(sel->action, b1, sizeof(b1)), sel->nkeys);
+		action_n2a(sel->action), sel->nkeys);
 	fprintf(f, "\t index %d ref %d bind %d", sel->index, sel->refcnt,
 		sel->bindcnt);
 
diff --git a/tc/m_police.c b/tc/m_police.c
index 3ba580e4fc225..f0b179fcc1744 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -49,28 +49,6 @@ static void explain1(char *arg)
 	fprintf(stderr, "Illegal \"%s\"\n", arg);
 }
 
-static const char *police_action_n2a(int action, char *buf, int len)
-{
-	switch (action) {
-	case -1:
-		return "continue";
-		break;
-	case TC_POLICE_OK:
-		return "pass";
-		break;
-	case TC_POLICE_SHOT:
-		return "drop";
-		break;
-	case TC_POLICE_RECLASSIFY:
-		return "reclassify";
-	case TC_POLICE_PIPE:
-		return "pipe";
-	default:
-		snprintf(buf, len, "%d", action);
-		return buf;
-	}
-}
-
 static int get_police_result(int *action, int *result, char *arg)
 {
 	char *p = strchr(arg, '/');
@@ -339,14 +317,12 @@ int print_police(struct action_util *a, FILE *f, struct rtattr *arg)
 		fprintf(f, "avrate %s ",
 			sprint_rate(rta_getattr_u32(tb[TCA_POLICE_AVRATE]),
 				    b1));
-	fprintf(f, "action %s",
-		police_action_n2a(p->action, b1, sizeof(b1)));
+	fprintf(f, "action %s", action_n2a(p->action));
 
 	if (tb[TCA_POLICE_RESULT]) {
 		__u32 action = rta_getattr_u32(tb[TCA_POLICE_RESULT]);
 
-		fprintf(f, "/%s",
-			police_action_n2a(action, b1, sizeof(b1)));
+		fprintf(f, "/%s", action_n2a(action));
 	} else
 		fprintf(f, " ");
 
diff --git a/tc/m_vlan.c b/tc/m_vlan.c
index 82311dd692bca..ac63d9ed09aa5 100644
--- a/tc/m_vlan.c
+++ b/tc/m_vlan.c
@@ -182,7 +182,7 @@ static int print_vlan(struct action_util *au, FILE *f, struct rtattr *arg)
 		}
 		break;
 	}
-	fprintf(f, " %s", action_n2a(parm->action, b1, sizeof(b1)));
+	fprintf(f, " %s", action_n2a(parm->action));
 
 	fprintf(f, "\n\t index %d ref %d bind %d", parm->index, parm->refcnt,
 		parm->bindcnt);
diff --git a/tc/tc_util.c b/tc/tc_util.c
index cd7b40b0afe48..15e49b7ba2999 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -411,18 +411,17 @@ char *sprint_qdisc_handle(__u32 h, char *buf)
 	return buf;
 }
 
-char *action_n2a(int action, char *buf, int len)
+const char *action_n2a(int action)
 {
+	static char buf[64];
+
 	switch (action) {
-	case -1:
+	case TC_ACT_UNSPEC:
 		return "continue";
-		break;
 	case TC_ACT_OK:
 		return "pass";
-		break;
 	case TC_ACT_SHOT:
 		return "drop";
-		break;
 	case TC_ACT_RECLASSIFY:
 		return "reclassify";
 	case TC_ACT_PIPE:
@@ -430,7 +429,8 @@ char *action_n2a(int action, char *buf, int len)
 	case TC_ACT_STOLEN:
 		return "stolen";
 	default:
-		snprintf(buf, len, "%d", action);
+		snprintf(buf, 64, "%d", action);
+		buf[63] = '\0';
 		return buf;
 	}
 }
diff --git a/tc/tc_util.h b/tc/tc_util.h
index e7613ab1bd496..f198a4ad55541 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -99,7 +99,7 @@ char *sprint_tc_classid(__u32 h, char *buf);
 int tc_print_police(FILE *f, struct rtattr *tb);
 int parse_police(int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n);
 
-char *action_n2a(int action, char *buf, int len);
+const char *action_n2a(int action);
 int action_a2n(char *arg, int *result, bool allow_num);
 int act_parse_police(struct action_util *a, int *argc_p,
 		     char ***argv_p, int tca_id, struct nlmsghdr *n);
-- 
2.8.2

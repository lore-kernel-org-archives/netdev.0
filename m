From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v4 3/5] Replace malloc && memset by calloc
Date: Wed, 13 Jul 2016 20:47:17 +0200
Message-ID: <1468435639-6892-4-git-send-email-phil@nwl.cc>
References: <1468435639-6892-1-git-send-email-phil@nwl.cc>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58374 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751073AbcGMSr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 14:47:58 -0400
In-Reply-To: <1468435639-6892-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This only replaces occurrences where the newly allocated memory is
cleared completely afterwards, as in other cases it is a theoretical
performance hit although code would be cleaner this way.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v2:
- Fix checkpatch errors.
---
 genl/genl.c        |  3 +--
 lib/names.c        |  7 ++-----
 misc/lnstat.c      |  6 ++----
 misc/lnstat_util.c |  4 +---
 tc/em_canid.c      |  4 ++--
 tc/m_action.c      |  3 +--
 tc/m_ipt.c         | 13 ++++---------
 tc/m_pedit.c       |  3 +--
 tc/tc.c            |  9 +++------
 tc/tc_bpf.c        |  4 +---
 tc/tc_class.c      |  3 +--
 tc/tc_exec.c       |  3 +--
 12 files changed, 20 insertions(+), 42 deletions(-)

diff --git a/genl/genl.c b/genl/genl.c
index e33fafdf2f524..747074b029a7b 100644
--- a/genl/genl.c
+++ b/genl/genl.c
@@ -86,9 +86,8 @@ reg:
 	return f;
 
 noexist:
-	f = malloc(sizeof(*f));
+	f = calloc(1, sizeof(*f));
 	if (f) {
-		memset(f, 0, sizeof(*f));
 		strncpy(f->name, str, 15);
 		f->parse_genlopt = parse_nofopt;
 		f->print_genlopt = print_nofopt;
diff --git a/lib/names.c b/lib/names.c
index 3b5b0b1e1201a..fbd6503f22d42 100644
--- a/lib/names.c
+++ b/lib/names.c
@@ -54,15 +54,12 @@ struct db_names *db_names_alloc(void)
 {
 	struct db_names *db;
 
-	db = malloc(sizeof(*db));
+	db = calloc(1, sizeof(*db));
 	if (!db)
 		return NULL;
 
-	memset(db, 0, sizeof(*db));
-
 	db->size = MAX_ENTRIES;
-	db->hash = malloc(sizeof(struct db_entry *) * db->size);
-	memset(db->hash, 0, sizeof(struct db_entry *) * db->size);
+	db->hash = calloc(db->size, sizeof(struct db_entry *));
 
 	return db;
 }
diff --git a/misc/lnstat.c b/misc/lnstat.c
index 659a01bd69931..863fd4d9f03f2 100644
--- a/misc/lnstat.c
+++ b/misc/lnstat.c
@@ -182,10 +182,8 @@ static struct table_hdr *build_hdr_string(struct lnstat_file *lnstat_files,
 	static struct table_hdr th;
 	int ofs = 0;
 
-	for (i = 0; i < HDR_LINES; i++) {
-		th.hdr[i] = malloc(HDR_LINE_LENGTH);
-		memset(th.hdr[i], 0, HDR_LINE_LENGTH);
-	}
+	for (i = 0; i < HDR_LINES; i++)
+		th.hdr[i] = calloc(1, HDR_LINE_LENGTH);
 
 	for (i = 0; i < fps->num; i++) {
 		char *cname, *fname = fps->params[i].lf->name;
diff --git a/misc/lnstat_util.c b/misc/lnstat_util.c
index d918151282f55..cc54598fe1bef 100644
--- a/misc/lnstat_util.c
+++ b/misc/lnstat_util.c
@@ -173,15 +173,13 @@ static struct lnstat_file *alloc_and_open(const char *path, const char *file)
 	struct lnstat_file *lf;
 
 	/* allocate */
-	lf = malloc(sizeof(*lf));
+	lf = calloc(1, sizeof(*lf));
 	if (!lf) {
 		fprintf(stderr, "out of memory\n");
 		return NULL;
 	}
 
 	/* initialize */
-	memset(lf, 0, sizeof(*lf));
-
 	/* de->d_name is guaranteed to be <= NAME_MAX */
 	strcpy(lf->basename, file);
 	strcpy(lf->path, path);
diff --git a/tc/em_canid.c b/tc/em_canid.c
index 16f6ed5c0b7a4..ceb64cb933f51 100644
--- a/tc/em_canid.c
+++ b/tc/em_canid.c
@@ -106,8 +106,8 @@ static int canid_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 	if (args == NULL)
 		return PARSE_ERR(args, "canid: missing arguments");
 
-	rules.rules_raw = malloc(sizeof(struct can_filter) * rules.rules_capacity);
-	memset(rules.rules_raw, 0, sizeof(struct can_filter) * rules.rules_capacity);
+	rules.rules_raw = calloc(rules.rules_capacity,
+				 sizeof(struct can_filter));
 
 	do {
 		if (!bstrcmp(args, "sff")) {
diff --git a/tc/m_action.c b/tc/m_action.c
index 806fdd197965d..24f8b5d855211 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -126,9 +126,8 @@ noexist:
 		goto restart_s;
 	}
 #endif
-	a = malloc(sizeof(*a));
+	a = calloc(1, sizeof(*a));
 	if (a) {
-		memset(a, 0, sizeof(*a));
 		strncpy(a->id, "noact", 15);
 		a->parse_aopt = parse_noaopt;
 		a->print_aopt = print_noaopt;
diff --git a/tc/m_ipt.c b/tc/m_ipt.c
index 098f610f9439a..d6f62bd6b32c9 100644
--- a/tc/m_ipt.c
+++ b/tc/m_ipt.c
@@ -164,16 +164,11 @@ get_target_name(const char *name)
 	return NULL;
 #endif
 
-	new_name = malloc(strlen(name) + 1);
-	lname = malloc(strlen(name) + 1);
-	if (new_name)
-		memset(new_name, '\0', strlen(name) + 1);
-	else
+	new_name = calloc(1, strlen(name) + 1);
+	lname = calloc(1, strlen(name) + 1);
+	if (!new_name)
 		exit_error(PARAMETER_PROBLEM, "get_target_name");
-
-	if (lname)
-		memset(lname, '\0', strlen(name) + 1);
-	else
+	if (!lname)
 		exit_error(PARAMETER_PROBLEM, "get_target_name");
 
 	strcpy(new_name, name);
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 141c30fb6fabc..35879b7fb72e2 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -107,9 +107,8 @@ reg:
 	return p;
 
 noexist:
-	p = malloc(sizeof(*p));
+	p = calloc(1, sizeof(*p));
 	if (p) {
-		memset(p, 0, sizeof(*p));
 		strncpy(p->id, str, sizeof(p->id) - 1);
 		p->parse_peopt = pedit_parse_nopopt;
 		goto reg;
diff --git a/tc/tc.c b/tc/tc.c
index d0ddb939d4737..8e64a82b4271c 100644
--- a/tc/tc.c
+++ b/tc/tc.c
@@ -133,11 +133,9 @@ reg:
 	return q;
 
 noexist:
-	q = malloc(sizeof(*q));
+	q = calloc(1, sizeof(*q));
 	if (q) {
-
-		memset(q, 0, sizeof(*q));
-		q->id = strcpy(malloc(strlen(str)+1), str);
+		q->id = strdup(str);
 		q->parse_qopt = parse_noqopt;
 		q->print_qopt = print_noqopt;
 		goto reg;
@@ -177,9 +175,8 @@ reg:
 	filter_list = q;
 	return q;
 noexist:
-	q = malloc(sizeof(*q));
+	q = calloc(1, sizeof(*q));
 	if (q) {
-		memset(q, 0, sizeof(*q));
 		strncpy(q->id, str, 15);
 		q->parse_fopt = parse_nofopt;
 		q->print_fopt = print_nofopt;
diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index cdbbba6ab8cc8..d3437364e6ce5 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -108,12 +108,10 @@ static int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
 		FILE *fp;
 
 		tmp_len = sizeof("4096,") + BPF_MAXINSNS * op_len;
-		tmp_string = malloc(tmp_len);
+		tmp_string = calloc(1, tmp_len);
 		if (tmp_string == NULL)
 			return -ENOMEM;
 
-		memset(tmp_string, 0, tmp_len);
-
 		fp = fopen(arg, "r");
 		if (fp == NULL) {
 			perror("Cannot fopen");
diff --git a/tc/tc_class.c b/tc/tc_class.c
index ee9e945acac11..1690ec1bbfad8 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -163,9 +163,8 @@ __u32 filter_classid;
 static void graph_node_add(__u32 parent_id, __u32 id, void *data,
 		int len)
 {
-	struct graph_node *node = malloc(sizeof(struct graph_node));
+	struct graph_node *node = calloc(1, sizeof(struct graph_node));
 
-	memset(node, 0, sizeof(*node));
 	node->id         = id;
 	node->parent_id  = parent_id;
 
diff --git a/tc/tc_exec.c b/tc/tc_exec.c
index f69b6ba9f6b7e..d23a825dbddf9 100644
--- a/tc/tc_exec.c
+++ b/tc/tc_exec.c
@@ -71,9 +71,8 @@ reg:
 
 	return eu;
 noexist:
-	eu = malloc(sizeof(*eu));
+	eu = calloc(1, sizeof(*eu));
 	if (eu) {
-		memset(eu, 0, sizeof(*eu));
 		strncpy(eu->id, name, sizeof(eu->id) - 1);
 		eu->parse_eopt = parse_noeopt;
 		goto reg;
-- 
2.8.2

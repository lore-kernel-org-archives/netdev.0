From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Fix wrong filter behaviour
Date: Thu, 30 Apr 2015 07:30:24 +0300
Message-ID: <1430368224-25147-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:36078 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbbD3Eat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 00:30:49 -0400
Received: by lagv1 with SMTP id v1so35166086lag.3
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 21:30:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Fixed applying family & socket type filters.
It was not possible to select UDP & UNIX sockets together.

Now selected families are ORed.

The problem was that filters were combined by AND.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
Reported-By: Mihai Moldovan <ionic@ionic.de>
---
 misc/ss.c | 91 ++++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 49 insertions(+), 42 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 954a30b..46dbb39 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -233,14 +233,12 @@ static struct filter current_filter;
 static void filter_db_set(struct filter *f, int db)
 {
 	f->states   |= default_dbs[db].states;
-	f->families |= default_dbs[db].families;
 	f->dbs	    |= 1 << db;
 	do_default   = 0;
 }
 
 static void filter_af_set(struct filter *f, int af)
 {
-	f->dbs		   |= default_afs[af].dbs;
 	f->states	   |= default_afs[af].states;
 	f->families	   |= 1 << af;
 	do_default	    = 0;
@@ -266,21 +264,31 @@ static void filter_default_dbs(struct filter *f)
 	filter_db_set(f, NETLINK_DB);
 }
 
-static void filter_merge(struct filter *af, struct filter *dbf, int states)
+static void filter_states_set(struct filter *f, int states)
 {
-	if (af->families)
-		af->families = (af->families | dbf->families) & af->families;
-	else
-		af->families = dbf->families;
+	if (states)
+		f->states = (f->states | states) & states;
+}
 
-	if (dbf->dbs)
-		af->dbs = (af->dbs | dbf->dbs) & dbf->dbs;
+static void filter_merge_defaults(struct filter *f)
+{
+	int db;
+	int af;
 
-	if (dbf->states)
-		af->states = (af->states | dbf->states) & dbf->states;
+	for (db = 0; db < MAX_DB; db++) {
+		if (!(f->dbs & (1 << db)))
+			continue;
 
-	if (states)
-		af->states = (af->states | states) & states;
+		if (!(default_dbs[db].families & f->families))
+			f->families |= default_dbs[db].families;
+	}
+	for (af = 0; af < AF_MAX; af++) {
+		if (!(f->families & (1 << af)))
+			continue;
+
+		if (!(default_afs[af].dbs & f->dbs))
+			f->dbs |= default_afs[af].dbs;
+	}
 }
 
 static FILE *generic_proc_open(const char *env, const char *name)
@@ -1534,7 +1542,7 @@ out:
 	if (fam != AF_UNSPEC) {
 		f->families = 0;
 		filter_af_set(f, fam);
-		filter_merge(f, f, 0);
+		filter_states_set(f, 0);
 	}
 
 	res = malloc(sizeof(*res));
@@ -3416,7 +3424,6 @@ int main(int argc, char *argv[])
 	const char *dump_tcpdiag = NULL;
 	FILE *filter_fp = NULL;
 	int ch;
-	struct filter dbs_filter = {};
 	int state_filter = 0;
 
 	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbf:miA:D:F:vVzZN:",
@@ -3450,16 +3457,16 @@ int main(int argc, char *argv[])
 			show_bpf++;
 			break;
 		case 'd':
-			filter_db_set(&dbs_filter, DCCP_DB);
+			filter_db_set(&current_filter, DCCP_DB);
 			break;
 		case 't':
-			filter_db_set(&dbs_filter, TCP_DB);
+			filter_db_set(&current_filter, TCP_DB);
 			break;
 		case 'u':
-			filter_db_set(&dbs_filter, UDP_DB);
+			filter_db_set(&current_filter, UDP_DB);
 			break;
 		case 'w':
-			filter_db_set(&dbs_filter, RAW_DB);
+			filter_db_set(&current_filter, RAW_DB);
 			break;
 		case 'x':
 			filter_af_set(&current_filter, AF_UNIX);
@@ -3511,44 +3518,44 @@ int main(int argc, char *argv[])
 				if ((p1 = strchr(p, ',')) != NULL)
 					*p1 = 0;
 				if (strcmp(p, "all") == 0) {
-					filter_default_dbs(&dbs_filter);
+					filter_default_dbs(&current_filter);
 				} else if (strcmp(p, "inet") == 0) {
-					filter_db_set(&dbs_filter, UDP_DB);
-					filter_db_set(&dbs_filter, DCCP_DB);
-					filter_db_set(&dbs_filter, TCP_DB);
-					filter_db_set(&dbs_filter, RAW_DB);
+					filter_db_set(&current_filter, UDP_DB);
+					filter_db_set(&current_filter, DCCP_DB);
+					filter_db_set(&current_filter, TCP_DB);
+					filter_db_set(&current_filter, RAW_DB);
 				} else if (strcmp(p, "udp") == 0) {
-					filter_db_set(&dbs_filter, UDP_DB);
+					filter_db_set(&current_filter, UDP_DB);
 				} else if (strcmp(p, "dccp") == 0) {
-					filter_db_set(&dbs_filter, DCCP_DB);
+					filter_db_set(&current_filter, DCCP_DB);
 				} else if (strcmp(p, "tcp") == 0) {
-					filter_db_set(&dbs_filter, TCP_DB);
+					filter_db_set(&current_filter, TCP_DB);
 				} else if (strcmp(p, "raw") == 0) {
-					filter_db_set(&dbs_filter, RAW_DB);
+					filter_db_set(&current_filter, RAW_DB);
 				} else if (strcmp(p, "unix") == 0) {
-					filter_db_set(&dbs_filter, UNIX_ST_DB);
-					filter_db_set(&dbs_filter, UNIX_DG_DB);
-					filter_db_set(&dbs_filter, UNIX_SQ_DB);
+					filter_db_set(&current_filter, UNIX_ST_DB);
+					filter_db_set(&current_filter, UNIX_DG_DB);
+					filter_db_set(&current_filter, UNIX_SQ_DB);
 				} else if (strcasecmp(p, "unix_stream") == 0 ||
 					   strcmp(p, "u_str") == 0) {
-					filter_db_set(&dbs_filter, UNIX_ST_DB);
+					filter_db_set(&current_filter, UNIX_ST_DB);
 				} else if (strcasecmp(p, "unix_dgram") == 0 ||
 					   strcmp(p, "u_dgr") == 0) {
-					filter_db_set(&dbs_filter, UNIX_DG_DB);
+					filter_db_set(&current_filter, UNIX_DG_DB);
 				} else if (strcasecmp(p, "unix_seqpacket") == 0 ||
 					   strcmp(p, "u_seq") == 0) {
-					filter_db_set(&dbs_filter, UNIX_SQ_DB);
+					filter_db_set(&current_filter, UNIX_SQ_DB);
 				} else if (strcmp(p, "packet") == 0) {
-					filter_db_set(&dbs_filter, PACKET_R_DB);
-					filter_db_set(&dbs_filter, PACKET_DG_DB);
+					filter_db_set(&current_filter, PACKET_R_DB);
+					filter_db_set(&current_filter, PACKET_DG_DB);
 				} else if (strcmp(p, "packet_raw") == 0 ||
 					   strcmp(p, "p_raw") == 0) {
-					filter_db_set(&dbs_filter, PACKET_R_DB);
+					filter_db_set(&current_filter, PACKET_R_DB);
 				} else if (strcmp(p, "packet_dgram") == 0 ||
 					   strcmp(p, "p_dgr") == 0) {
-					filter_db_set(&dbs_filter, PACKET_DG_DB);
+					filter_db_set(&current_filter, PACKET_DG_DB);
 				} else if (strcmp(p, "netlink") == 0) {
-					filter_db_set(&dbs_filter, NETLINK_DB);
+					filter_db_set(&current_filter, NETLINK_DB);
 				} else {
 					fprintf(stderr, "ss: \"%s\" is illegal socket table id\n", p);
 					usage();
@@ -3641,11 +3648,11 @@ int main(int argc, char *argv[])
 	if (do_default) {
 		state_filter = state_filter ? state_filter : SS_CONN;
 		filter_default_dbs(&current_filter);
-		filter_merge(&current_filter, &current_filter, state_filter);
-	} else {
-		filter_merge(&current_filter, &dbs_filter, state_filter);
 	}
 
+	filter_states_set(&current_filter, state_filter);
+	filter_merge_defaults(&current_filter);
+
 	if (resolve_services && resolve_hosts &&
 	    (current_filter.dbs&(UNIX_DBM|(1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB))))
 		init_service_resolver();
-- 
2.3.1

From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 1/2] ss: Unify unix stats output from netlink and proc
Date: Tue, 30 Dec 2014 01:56:19 +0200
Message-ID: <1419897380-21012-2-git-send-email-vadim4j@gmail.com>
References: <1419897380-21012-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:57890 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbaL3AGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 19:06:36 -0500
Received: by mail-la0-f48.google.com with SMTP id gf13so11674473lab.7
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 16:06:34 -0800 (PST)
In-Reply-To: <1419897380-21012-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Refactored to use one func for output unix stats info
from both /proc and netlink.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 99 ++++++++++++++++++++++++---------------------------------------
 1 file changed, 37 insertions(+), 62 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index f0c7b34..88b14f8 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2234,6 +2234,7 @@ struct unixstat
 	struct unixstat *next;
 	int ino;
 	int peer;
+	char *peer_name;
 	int rq;
 	int wq;
 	int state;
@@ -2279,7 +2280,18 @@ static const char *unix_netid_name(int type)
 	return netid;
 }
 
-static void unix_list_print(struct unixstat *list, struct filter *f)
+static int unix_type_skip(struct unixstat *s, struct filter *f)
+{
+	if (s->type == SOCK_STREAM && !(f->dbs&(1<<UNIX_ST_DB)))
+		return 1;
+	if (s->type == SOCK_DGRAM && !(f->dbs&(1<<UNIX_DG_DB)))
+		return 1;
+	if (s->type == SOCK_SEQPACKET && !(f->dbs&(1<<UNIX_SQ_DB)))
+		return 1;
+	return 0;
+}
+
+static void unix_stats_print(struct unixstat *list, struct filter *f)
 {
 	struct unixstat *s;
 	char *peer;
@@ -2287,15 +2299,14 @@ static void unix_list_print(struct unixstat *list, struct filter *f)
 	for (s = list; s; s = s->next) {
 		if (!(f->states & (1<<s->state)))
 			continue;
-		if (s->type == SOCK_STREAM && !(f->dbs&(1<<UNIX_ST_DB)))
-			continue;
-		if (s->type == SOCK_DGRAM && !(f->dbs&(1<<UNIX_DG_DB)))
-			continue;
-		if (s->type == SOCK_SEQPACKET && !(f->dbs&(1<<UNIX_SQ_DB)))
+		if (unix_type_skip(s, f))
 			continue;
 
 		peer = "*";
-		if (s->peer) {
+		if (s->peer_name)
+			peer = s->peer_name;
+
+		if (s->peer && !s->peer_name) {
 			struct unixstat *p;
 			for (p = list; p; p = p->next) {
 				if (s->peer == p->ino)
@@ -2356,36 +2367,24 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 	struct unix_diag_msg *r = NLMSG_DATA(nlh);
 	struct rtattr *tb[UNIX_DIAG_MAX+1];
 	char name[128];
-	int peer_ino;
-	__u32 rqlen, wqlen;
+	struct unixstat stat = { .name = "*" , .peer_name = "*" };
 
 	parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr*)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
-	if (r->udiag_type == SOCK_STREAM && !(f->dbs&(1<<UNIX_ST_DB)))
-		return 0;
-	if (r->udiag_type == SOCK_DGRAM && !(f->dbs&(1<<UNIX_DG_DB)))
-		return 0;
-	if (r->udiag_type == SOCK_SEQPACKET && !(f->dbs&(1<<UNIX_SQ_DB)))
-		return 0;
+	f->f = NULL;
+	stat.type  = r->udiag_type;
+	stat.state = r->udiag_state;
+	stat.ino   = r->udiag_ino;
 
-	if (netid_width)
-		printf("%-*s ", netid_width,
-		       unix_netid_name(r->udiag_type));
-	if (state_width)
-		printf("%-*s ", state_width, sstate_name[r->udiag_state]);
+	if (unix_type_skip(&stat, f))
+		return 0;
 
 	if (tb[UNIX_DIAG_RQLEN]) {
 		struct unix_diag_rqlen *rql = RTA_DATA(tb[UNIX_DIAG_RQLEN]);
-		rqlen = rql->udiag_rqueue;
-		wqlen = rql->udiag_wqueue;
-	} else {
-		rqlen = 0;
-		wqlen = 0;
+		stat.rq = rql->udiag_rqueue;
+		stat.wq = rql->udiag_wqueue;
 	}
-
-	printf("%-6u %-6u ", rqlen, wqlen);
-
 	if (tb[UNIX_DIAG_NAME]) {
 		int len = RTA_PAYLOAD(tb[UNIX_DIAG_NAME]);
 
@@ -2393,41 +2392,17 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 		name[len] = '\0';
 		if (name[0] == '\0')
 			name[0] = '@';
-	} else
-		sprintf(name, "*");
-
+		stat.name = &name[0];
+	}
 	if (tb[UNIX_DIAG_PEER])
-		peer_ino = rta_getattr_u32(tb[UNIX_DIAG_PEER]);
-	else
-		peer_ino = 0;
-
-	printf("%*s %-*d %*s %-*d",
-			addr_width, name,
-			serv_width, r->udiag_ino,
-			addr_width, "*", /* FIXME */
-			serv_width, peer_ino);
-
-	char *buf = NULL;
+		stat.peer = rta_getattr_u32(tb[UNIX_DIAG_PEER]);
 
-	if (show_proc_ctx || show_sock_ctx) {
-		if (find_entry(r->udiag_ino, &buf,
-				(show_proc_ctx & show_sock_ctx) ?
-				PROC_SOCK_CTX : PROC_CTX) > 0) {
-			printf(" users:(%s)", buf);
-			free(buf);
-		}
-	} else if (show_users) {
-		if (find_entry(r->udiag_ino, &buf, USERS) > 0) {
-			printf(" users:(%s)", buf);
-			free(buf);
-		}
-	}
+	unix_stats_print(&stat, f);
 
 	if (show_mem) {
-		printf("\n\t");
+		printf("\t");
 		print_skmeminfo(tb, UNIX_DIAG_MEMINFO);
 	}
-
 	if (show_details) {
 		if (tb[UNIX_DIAG_SHUTDOWN]) {
 			unsigned char mask;
@@ -2435,9 +2410,8 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 			printf(" %c-%c", mask & 1 ? '-' : '<', mask & 2 ? '-' : '>');
 		}
 	}
-
-	printf("\n");
-
+	if (show_mem || show_details)
+		printf("\n");
 	return 0;
 }
 
@@ -2505,6 +2479,7 @@ static int unix_show(struct filter *f)
 		if (!(u = malloc(sizeof(*u))))
 			break;
 		u->name = NULL;
+		u->peer_name = NULL;
 
 		if (sscanf(buf, "%x: %x %x %x %x %x %d %s",
 			   &u->peer, &u->rq, &u->wq, &flags, &u->type,
@@ -2544,7 +2519,7 @@ static int unix_show(struct filter *f)
 			strcpy(u->name, name);
 		}
 		if (++cnt > MAX_UNIX_REMEMBER) {
-			unix_list_print(list, f);
+			unix_stats_print(list, f);
 			unix_list_free(list);
 			list = NULL;
 			cnt = 0;
@@ -2552,7 +2527,7 @@ static int unix_show(struct filter *f)
 	}
 	fclose(fp);
 	if (list) {
-		unix_list_print(list, f);
+		unix_stats_print(list, f);
 		unix_list_free(list);
 		list = NULL;
 		cnt = 0;
-- 
2.1.3

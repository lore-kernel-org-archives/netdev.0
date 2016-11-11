From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 06/18] ss: Drop list traversal from unix_stats_print()
Date: Fri, 11 Nov 2016 14:10:02 +0100
Message-ID: <20161111131014.21865-7-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:32774 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756648AbcKKNLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:11:16 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although this complicates the dedicated procfs-based code path in
unix_show() a bit, it's the only sane way to get rid of unix_show_sock()
output diverging from other socket types in that it prints all socket
details in a new line.

As a side effect, it allows to eliminate all procfs specific code in
the same function.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 137 +++++++++++++++++++++++++++++---------------------------------
 1 file changed, 64 insertions(+), 73 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index b3475cc96ae7b..36b18ff2ce3cb 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2788,15 +2788,13 @@ int unix_state_map[] = { SS_CLOSE, SS_SYN_SENT,
 
 #define MAX_UNIX_REMEMBER (1024*1024/sizeof(struct sockstat))
 
-static void unix_list_free(struct sockstat *list)
+static void unix_list_drop_first(struct sockstat **list)
 {
-	while (list) {
-		struct sockstat *s = list;
+	struct sockstat *s = *list;
 
-		list = list->next;
-		free(s->name);
-		free(s);
-	}
+	(*list) = (*list)->next;
+	free(s->name);
+	free(s);
 }
 
 static bool unix_type_skip(struct sockstat *s, struct filter *f)
@@ -2815,61 +2813,18 @@ static bool unix_use_proc(void)
 	return getenv("PROC_NET_UNIX") || getenv("PROC_ROOT");
 }
 
-static void unix_stats_print(struct sockstat *list, struct filter *f)
+static void unix_stats_print(struct sockstat *s, struct filter *f)
 {
-	struct sockstat *s;
-	char *peer;
-	bool use_proc = unix_use_proc();
 	char port_name[30] = {};
 
-	for (s = list; s; s = s->next) {
-		if (!(f->states & (1 << s->state)))
-			continue;
-		if (unix_type_skip(s, f))
-			continue;
-
-		peer = "*";
-		if (s->peer_name)
-			peer = s->peer_name;
-
-		if (s->rport && use_proc) {
-			struct sockstat *p;
-
-			for (p = list; p; p = p->next) {
-				if (s->rport == p->lport)
-					break;
-			}
-
-			if (!p) {
-				peer = "?";
-			} else {
-				peer = p->name ? : "*";
-			}
-		}
-
-		if (use_proc && f->f) {
-			struct sockstat st = {
-				.local.family = AF_UNIX,
-				.remote.family = AF_UNIX,
-			};
-
-			memcpy(st.local.data, &s->name, sizeof(s->name));
-			if (strcmp(peer, "*"))
-				memcpy(st.remote.data, &peer, sizeof(peer));
-			if (run_ssfilter(f->f, &st) == 0)
-				continue;
-		}
-
-		sock_state_print(s);
+	sock_state_print(s);
 
-		sock_addr_print(s->name ?: "*", " ",
-				int_to_str(s->lport, port_name), NULL);
-		sock_addr_print(peer, " ", int_to_str(s->rport, port_name),
-				NULL);
+	sock_addr_print(s->name ?: "*", " ",
+			int_to_str(s->lport, port_name), NULL);
+	sock_addr_print(s->peer_name ?: "*", " ",
+			int_to_str(s->rport, port_name), NULL);
 
-		proc_ctx_print(s);
-		printf("\n");
-	}
+	proc_ctx_print(s);
 }
 
 static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
@@ -2916,8 +2871,6 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 
 	unix_stats_print(&stat, f);
 
-	if (show_mem || show_details)
-		printf("\t");
 	if (show_mem)
 		print_skmeminfo(tb, UNIX_DIAG_MEMINFO);
 	if (show_details) {
@@ -2928,8 +2881,7 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 			printf(" %c-%c", mask & 1 ? '-' : '<', mask & 2 ? '-' : '>');
 		}
 	}
-	if (show_mem || show_details)
-		printf("\n");
+	printf("\n");
 
 	return 0;
 }
@@ -3020,6 +2972,11 @@ static int unix_show(struct filter *f)
 			if (u->type == SOCK_DGRAM && u->state == SS_CLOSE && u->rport)
 				u->state = SS_ESTABLISHED;
 		}
+		if (unix_type_skip(u, f) ||
+		    !(f->states & (1 << u->state))) {
+			free(u);
+			continue;
+		}
 
 		if (!newformat) {
 			u->rport = 0;
@@ -3027,6 +2984,42 @@ static int unix_show(struct filter *f)
 			u->wq = 0;
 		}
 
+		if (name[0]) {
+			u->name = strdup(name);
+			if (!u->name)
+				break;
+		}
+
+		if (u->rport) {
+			struct sockstat *p;
+
+			for (p = list; p; p = p->next) {
+				if (u->rport == p->lport)
+					break;
+			}
+			if (!p)
+				u->peer_name = "?";
+			else
+				u->peer_name = p->name ? : "*";
+		}
+
+		if (f->f) {
+			struct sockstat st = {
+				.local.family = AF_UNIX,
+				.remote.family = AF_UNIX,
+			};
+
+			memcpy(st.local.data, &u->name, sizeof(u->name));
+			if (strcmp(u->peer_name, "*"))
+				memcpy(st.remote.data, &u->peer_name,
+				       sizeof(u->peer_name));
+			if (run_ssfilter(f->f, &st) == 0) {
+				free(u->name);
+				free(u);
+				continue;
+			}
+		}
+
 		insp = &list;
 		while (*insp) {
 			if (u->type < (*insp)->type ||
@@ -3038,24 +3031,22 @@ static int unix_show(struct filter *f)
 		u->next = *insp;
 		*insp = u;
 
-		if (name[0]) {
-			if ((u->name = malloc(strlen(name)+1)) == NULL)
-				break;
-			strcpy(u->name, name);
-		}
 		if (++cnt > MAX_UNIX_REMEMBER) {
-			unix_stats_print(list, f);
-			unix_list_free(list);
-			list = NULL;
+			while (list) {
+				unix_stats_print(list, f);
+				printf("\n");
+
+				unix_list_drop_first(&list);
+			}
 			cnt = 0;
 		}
 	}
 	fclose(fp);
-	if (list) {
+	while (list) {
 		unix_stats_print(list, f);
-		unix_list_free(list);
-		list = NULL;
-		cnt = 0;
+		printf("\n");
+
+		unix_list_drop_first(&list);
 	}
 
 	return 0;
-- 
2.10.0

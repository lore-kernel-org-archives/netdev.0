From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 3/7] ss: Replace unixstat struct by new sockstat struct
Date: Fri, 13 Feb 2015 22:14:00 +0200
Message-ID: <1423858444-10158-4-git-send-email-vadim4j@gmail.com>
References: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:60222 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbbBMUZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 15:25:14 -0500
Received: by mail-lb0-f174.google.com with SMTP id z11so17686981lbi.5
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 12:25:13 -0800 (PST)
In-Reply-To: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 141 +++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 75 insertions(+), 66 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index f033892..54f2e21 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -660,6 +660,18 @@ static int get_slabstat(struct slabstat *s)
 	return 0;
 }
 
+static inline void sock_addr_set_str(inet_prefix *prefix, char **ptr)
+{
+    memcpy(prefix->data, ptr, sizeof(char *));
+}
+
+static inline char *sock_addr_get_str(const inet_prefix *prefix)
+{
+    char *tmp ;
+    memcpy(&tmp, prefix->data, sizeof(char *));
+    return tmp;
+}
+
 static const char *sstate_name[] = {
 	"UNKNOWN",
 	[SS_ESTABLISHED] = "ESTAB",
@@ -692,7 +704,8 @@ static const char *sstate_namel[] = {
 
 struct sockstat
 {
-	uint8_t		    type;
+	struct sockstat	   *next;
+	unsigned int	    type;
 	uint16_t	    prot;
 	inet_prefix	    local;
 	inet_prefix	    remote;
@@ -996,9 +1009,9 @@ static int inet2_addr_match(const inet_prefix *a, const inet_prefix *p,
 
 static int unix_match(const inet_prefix *a, const inet_prefix *p)
 {
-	char *addr, *pattern;
-	memcpy(&addr, a->data, sizeof(addr));
-	memcpy(&pattern, p->data, sizeof(pattern));
+	char *addr = sock_addr_get_str(a);
+	char *pattern = sock_addr_get_str(p);
+
 	if (pattern == NULL)
 		return 1;
 	if (addr == NULL)
@@ -1014,8 +1027,7 @@ static int run_ssfilter(struct ssfilter *f, struct sockstat *s)
                 static int low, high=65535;
 
 		if (s->local.family == AF_UNIX) {
-			char *p;
-			memcpy(&p, s->local.data, sizeof(p));
+			char *p = sock_addr_get_str(&s->local);
 			return p == NULL || (p[0] == '@' && strlen(p) == 6 &&
 					     strspn(p+1, "0123456789abcdef") == 5);
 		}
@@ -1338,7 +1350,7 @@ void *parse_hostcond(char *addr)
 			addr+=5;
 		p = strdup(addr);
 		a.addr.bitlen = 8*strlen(p);
-		memcpy(a.addr.data, &p, sizeof(p));
+		sock_addr_set_str(&a.addr, &p);
 		fam = AF_UNIX;
 		goto out;
 	}
@@ -2415,31 +2427,21 @@ outerr:
 	} while (0);
 }
 
-struct unixstat
-{
-	struct unixstat *next;
-	int ino;
-	int peer;
-	char *peer_name;
-	int rq;
-	int wq;
-	int state;
-	int type;
-	char *name;
-};
-
 int unix_state_map[] = { SS_CLOSE, SS_SYN_SENT,
 			 SS_ESTABLISHED, SS_CLOSING };
 
-#define MAX_UNIX_REMEMBER (1024*1024/sizeof(struct unixstat))
+#define MAX_UNIX_REMEMBER (1024*1024/sizeof(struct sockstat))
 
-static void unix_list_free(struct unixstat *list)
+static void unix_list_free(struct sockstat *list)
 {
 	while (list) {
-		struct unixstat *s = list;
+		struct sockstat *s = list;
+		char *name = sock_addr_get_str(&s->local);
+
 		list = list->next;
-		if (s->name)
-			free(s->name);
+
+		if (name)
+			free(name);
 		free(s);
 	}
 }
@@ -2463,7 +2465,7 @@ static const char *unix_netid_name(int type)
 	return netid;
 }
 
-static bool unix_type_skip(struct unixstat *s, struct filter *f)
+static bool unix_type_skip(struct sockstat *s, struct filter *f)
 {
 	if (s->type == SOCK_STREAM && !(f->dbs&(1<<UNIX_ST_DB)))
 		return true;
@@ -2474,44 +2476,49 @@ static bool unix_type_skip(struct unixstat *s, struct filter *f)
 	return false;
 }
 
-static void unix_stats_print(struct unixstat *list, struct filter *f)
+static bool unix_use_proc(void)
+{
+	return getenv("PROC_NET_UNIX") || getenv("PROC_ROOT");
+}
+
+static void unix_stats_print(struct sockstat *list, struct filter *f)
 {
-	struct unixstat *s;
-	char *peer;
+	struct sockstat *s;
+	char *local, *peer;
+	bool use_proc = unix_use_proc();
 
 	for (s = list; s; s = s->next) {
-		if (!(f->states & (1<<s->state)))
+		if (!(f->states & (1 << s->state)))
 			continue;
 		if (unix_type_skip(s, f))
 			continue;
 
-		peer = "*";
-		if (s->peer_name)
-			peer = s->peer_name;
+		local = sock_addr_get_str(&s->local);
+		peer  = "*";
+
+		if (s->rport && use_proc) {
+			struct sockstat *p;
 
-		if (s->peer && !s->peer_name) {
-			struct unixstat *p;
 			for (p = list; p; p = p->next) {
-				if (s->peer == p->ino)
+				if (s->rport == p->lport)
 					break;
 			}
+
 			if (!p) {
 				peer = "?";
 			} else {
-				peer = p->name ? : "*";
+				peer = sock_addr_get_str(&p->local);
+				peer = peer ? : "*";
 			}
 		}
 
 		if (f->f) {
-			struct sockstat st;
-			st.local.family = AF_UNIX;
-			st.remote.family = AF_UNIX;
-			memcpy(st.local.data, &s->name, sizeof(s->name));
 			if (strcmp(peer, "*") == 0)
-				memset(st.remote.data, 0, sizeof(peer));
+				memset(s->remote.data, 0, sizeof(char *));
 			else
-				memcpy(st.remote.data, &peer, sizeof(peer));
-			if (run_ssfilter(f->f, &st) == 0)
+				sock_addr_set_str(&s->remote, &peer);
+
+			if (run_ssfilter(f->f, s) == 0)
 				continue;
 		}
 
@@ -2522,8 +2529,8 @@ static void unix_stats_print(struct unixstat *list, struct filter *f)
 			printf("%-*s ", state_width, sstate_name[s->state]);
 		printf("%-6d %-6d ", s->rq, s->wq);
 		printf("%*s %-*d %*s %-*d",
-		       addr_width, s->name ? : "*", serv_width, s->ino,
-		       addr_width, peer, serv_width, s->peer);
+		       addr_width, local ? : "*", serv_width,
+		       s->lport, addr_width, peer, serv_width, s->rport);
 		char *buf = NULL;
 
 		if (show_proc_ctx || show_sock_ctx) {
@@ -2549,15 +2556,16 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 	struct filter *f = (struct filter *)arg;
 	struct unix_diag_msg *r = NLMSG_DATA(nlh);
 	struct rtattr *tb[UNIX_DIAG_MAX+1];
-	char name[128];
-	struct unixstat stat = { .name = "*" , .peer_name = "*" };
+	char *name = NULL;
+	struct sockstat stat = {};
 
 	parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr*)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	stat.type  = r->udiag_type;
 	stat.state = r->udiag_state;
-	stat.ino   = r->udiag_ino;
+	stat.ino   = stat.lport = r->udiag_ino;
+	stat.local.family = stat.remote.family = AF_UNIX;
 
 	if (unix_type_skip(&stat, f))
 		return 0;
@@ -2570,14 +2578,15 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 	if (tb[UNIX_DIAG_NAME]) {
 		int len = RTA_PAYLOAD(tb[UNIX_DIAG_NAME]);
 
+		name = malloc(len + 1);
 		memcpy(name, RTA_DATA(tb[UNIX_DIAG_NAME]), len);
 		name[len] = '\0';
 		if (name[0] == '\0')
 			name[0] = '@';
-		stat.name = &name[0];
+		sock_addr_set_str(&stat.local, &name);
 	}
 	if (tb[UNIX_DIAG_PEER])
-		stat.peer = rta_getattr_u32(tb[UNIX_DIAG_PEER]);
+		stat.rport = rta_getattr_u32(tb[UNIX_DIAG_PEER]);
 
 	unix_stats_print(&stat, f);
 
@@ -2594,6 +2603,9 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 	}
 	if (show_mem || show_details)
 		printf("\n");
+
+	if (name)
+		free(name);
 	return 0;
 }
 
@@ -2640,13 +2652,12 @@ static int unix_show(struct filter *f)
 	char name[128];
 	int  newformat = 0;
 	int  cnt;
-	struct unixstat *list = NULL;
+	struct sockstat *list = NULL;
 
 	if (!filter_af_get(f, AF_UNIX))
 		return 0;
 
-	if (!getenv("PROC_NET_UNIX") && !getenv("PROC_ROOT")
-	    && unix_show_netlink(f) == 0)
+	if (!unix_use_proc() && unix_show_netlink(f) == 0)
 		return 0;
 
 	if ((fp = net_unix_open()) == NULL)
@@ -2658,31 +2669,30 @@ static int unix_show(struct filter *f)
 	cnt = 0;
 
 	while (fgets(buf, sizeof(buf)-1, fp)) {
-		struct unixstat *u, **insp;
+		struct sockstat *u, **insp;
 		int flags;
 
 		if (!(u = malloc(sizeof(*u))))
 			break;
-		u->name = NULL;
-		u->peer_name = NULL;
 
 		if (sscanf(buf, "%x: %x %x %x %x %x %d %s",
-			   &u->peer, &u->rq, &u->wq, &flags, &u->type,
+			   &u->rport, &u->rq, &u->wq, &flags, &u->type,
 			   &u->state, &u->ino, name) < 8)
 			name[0] = 0;
 
-		if (flags&(1<<16)) {
+		u->lport = u->ino;
+		u->local.family = u->remote.family = AF_UNIX;
+
+		if (flags & (1 << 16)) {
 			u->state = SS_LISTEN;
 		} else {
 			u->state = unix_state_map[u->state-1];
-			if (u->type == SOCK_DGRAM &&
-			    u->state == SS_CLOSE &&
-			    u->peer)
+			if (u->type == SOCK_DGRAM && u->state == SS_CLOSE && u->rport)
 				u->state = SS_ESTABLISHED;
 		}
 
 		if (!newformat) {
-			u->peer = 0;
+			u->rport = 0;
 			u->rq = 0;
 			u->wq = 0;
 		}
@@ -2699,9 +2709,8 @@ static int unix_show(struct filter *f)
 		*insp = u;
 
 		if (name[0]) {
-			if ((u->name = malloc(strlen(name)+1)) == NULL)
-				break;
-			strcpy(u->name, name);
+			char *tmp = strdup(name);
+			sock_addr_set_str(&u->local, &tmp);
 		}
 		if (++cnt > MAX_UNIX_REMEMBER) {
 			unix_stats_print(list, f);
-- 
2.2.2

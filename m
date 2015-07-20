From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Fix crash when dump stats from /proc with '-p'
Date: Mon, 20 Jul 2015 22:46:23 +0300
Message-ID: <1437421583-20999-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:36677 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044AbbGTTsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 15:48:38 -0400
Received: by lbbqi7 with SMTP id qi7so21402247lbb.3
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 12:48:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

It really partially reverts:

    ec4d0d8a9def35 (ss: Replace unixstat struct by new sockstat struct)

but adds few fields (name & peer_name) from removed unixstat to sockstat struct to easy
return original code.

Fixes: ec4d0d8a9def35 (ss: Replace unixstat struct by new sockstat struct)
Reported-by: Marc Dietrich <marvin24@gmx.de>
Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 73 ++++++++++++++++++++++++++++-----------------------------------
 1 file changed, 32 insertions(+), 41 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 03f92fa..ed7960f 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -676,18 +676,6 @@ static int get_slabstat(struct slabstat *s)
 	return 0;
 }
 
-static inline void sock_addr_set_str(inet_prefix *prefix, char **ptr)
-{
-    memcpy(prefix->data, ptr, sizeof(char *));
-}
-
-static inline char *sock_addr_get_str(const inet_prefix *prefix)
-{
-    char *tmp ;
-    memcpy(&tmp, prefix->data, sizeof(char *));
-    return tmp;
-}
-
 static unsigned long long cookie_sk_get(const uint32_t *cookie)
 {
 	return (((unsigned long long)cookie[1] << 31) << 1) | cookie[0];
@@ -739,6 +727,8 @@ struct sockstat
 	int		    refcnt;
 	unsigned int	    iface;
 	unsigned long long  sk;
+	char *name;
+	char *peer_name;
 };
 
 struct dctcpstat
@@ -1063,9 +1053,9 @@ static int inet2_addr_match(const inet_prefix *a, const inet_prefix *p,
 
 static int unix_match(const inet_prefix *a, const inet_prefix *p)
 {
-	char *addr = sock_addr_get_str(a);
-	char *pattern = sock_addr_get_str(p);
-
+	char *addr, *pattern;
+	memcpy(&addr, a->data, sizeof(addr));
+	memcpy(&pattern, p->data, sizeof(pattern));
 	if (pattern == NULL)
 		return 1;
 	if (addr == NULL)
@@ -1081,7 +1071,8 @@ static int run_ssfilter(struct ssfilter *f, struct sockstat *s)
                 static int low, high=65535;
 
 		if (s->local.family == AF_UNIX) {
-			char *p = sock_addr_get_str(&s->local);
+			char *p;
+			memcpy(&p, s->local.data, sizeof(p));
 			return p == NULL || (p[0] == '@' && strlen(p) == 6 &&
 					     strspn(p+1, "0123456789abcdef") == 5);
 		}
@@ -1401,7 +1392,7 @@ void *parse_hostcond(char *addr, bool is_port)
 			addr+=5;
 		p = strdup(addr);
 		a.addr.bitlen = 8*strlen(p);
-		sock_addr_set_str(&a.addr, &p);
+		memcpy(a.addr.data, &p, sizeof(p));
 		fam = AF_UNIX;
 		goto out;
 	}
@@ -2508,12 +2499,9 @@ static void unix_list_free(struct sockstat *list)
 {
 	while (list) {
 		struct sockstat *s = list;
-		char *name = sock_addr_get_str(&s->local);
-
 		list = list->next;
-
-		if (name)
-			free(name);
+		if (s->name)
+			free(s->name);
 		free(s);
 	}
 }
@@ -2556,7 +2544,7 @@ static bool unix_use_proc(void)
 static void unix_stats_print(struct sockstat *list, struct filter *f)
 {
 	struct sockstat *s;
-	char *local, *peer;
+	char *peer;
 	char *ctx_buf = NULL;
 	bool use_proc = unix_use_proc();
 	char port_name[30] = {};
@@ -2567,8 +2555,9 @@ static void unix_stats_print(struct sockstat *list, struct filter *f)
 		if (unix_type_skip(s, f))
 			continue;
 
-		local = sock_addr_get_str(&s->local);
-		peer  = "*";
+		peer = "*";
+		if (s->peer_name)
+			peer = s->peer_name;
 
 		if (s->rport && use_proc) {
 			struct sockstat *p;
@@ -2581,24 +2570,26 @@ static void unix_stats_print(struct sockstat *list, struct filter *f)
 			if (!p) {
 				peer = "?";
 			} else {
-				peer = sock_addr_get_str(&p->local);
-				peer = peer ? : "*";
+				peer = p->name ? : "*";
 			}
 		}
 
 		if (use_proc && f->f) {
+			struct sockstat st;
+			st.local.family = AF_UNIX;
+			st.remote.family = AF_UNIX;
+			memcpy(st.local.data, &s->name, sizeof(s->name));
 			if (strcmp(peer, "*") == 0)
-				memset(s->remote.data, 0, sizeof(char *));
+				memset(st.remote.data, 0, sizeof(peer));
 			else
-				sock_addr_set_str(&s->remote, &peer);
-
-			if (run_ssfilter(f->f, s) == 0)
+				memcpy(st.remote.data, &peer, sizeof(peer));
+			if (run_ssfilter(f->f, &st) == 0)
 				continue;
 		}
 
 		sock_state_print(s, unix_netid_name(s->type));
 
-		sock_addr_print(local ?: "*", " ",
+		sock_addr_print(s->name ?: "*", " ",
 				int_to_str(s->lport, port_name), NULL);
 		sock_addr_print(peer, " ", int_to_str(s->rport, port_name),
 				NULL);
@@ -2626,8 +2617,8 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 	struct filter *f = (struct filter *)arg;
 	struct unix_diag_msg *r = NLMSG_DATA(nlh);
 	struct rtattr *tb[UNIX_DIAG_MAX+1];
-	char *name = NULL;
-	struct sockstat stat = {};
+	char name[128];
+	struct sockstat stat = { .name = "*", .peer_name = "*" };
 
 	parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr*)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
@@ -2648,12 +2639,12 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 	if (tb[UNIX_DIAG_NAME]) {
 		int len = RTA_PAYLOAD(tb[UNIX_DIAG_NAME]);
 
-		name = malloc(len + 1);
 		memcpy(name, RTA_DATA(tb[UNIX_DIAG_NAME]), len);
 		name[len] = '\0';
 		if (name[0] == '\0')
 			name[0] = '@';
-		sock_addr_set_str(&stat.local, &name);
+		stat.name = &name[0];
+		memcpy(stat.local.data, &stat.name, sizeof(stat.name));
 	}
 	if (tb[UNIX_DIAG_PEER])
 		stat.rport = rta_getattr_u32(tb[UNIX_DIAG_PEER]);
@@ -2676,9 +2667,6 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 	}
 	if (show_mem || show_details)
 		printf("\n");
-
-	if (name)
-		free(name);
 	return 0;
 }
 
@@ -2747,6 +2735,8 @@ static int unix_show(struct filter *f)
 
 		if (!(u = malloc(sizeof(*u))))
 			break;
+		u->name = NULL;
+		u->peer_name = NULL;
 
 		if (sscanf(buf, "%x: %x %x %x %x %x %d %s",
 			   &u->rport, &u->rq, &u->wq, &flags, &u->type,
@@ -2782,8 +2772,9 @@ static int unix_show(struct filter *f)
 		*insp = u;
 
 		if (name[0]) {
-			char *tmp = strdup(name);
-			sock_addr_set_str(&u->local, &tmp);
+			if ((u->name = malloc(strlen(name)+1)) == NULL)
+				break;
+			strcpy(u->name, name);
 		}
 		if (++cnt > MAX_UNIX_REMEMBER) {
 			unix_stats_print(list, f);
-- 
2.4.2

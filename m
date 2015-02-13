From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 6/7] ss: Unify socket address output by one generic func
Date: Fri, 13 Feb 2015 22:14:03 +0200
Message-ID: <1423858444-10158-7-git-send-email-vadim4j@gmail.com>
References: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:33035 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281AbbBMUZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 15:25:18 -0500
Received: by mail-lb0-f182.google.com with SMTP id f15so16817383lbj.13
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 12:25:16 -0800 (PST)
In-Reply-To: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/utils.h |   2 +
 lib/utils.c     |   6 +++
 misc/ss.c       | 124 ++++++++++++++++++++++++++++++++------------------------
 3 files changed, 80 insertions(+), 52 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 3da2283..fec9ef4 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -167,4 +167,6 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 extern int do_each_netns(int (*func)(char *nsname, void *arg), void *arg,
 		bool show_label);
 
+char *int_to_str(int val, char *buf);
+
 #endif /* __UTILS_H__ */
diff --git a/lib/utils.c b/lib/utils.c
index efebe18..e2b05bc 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -906,3 +906,9 @@ int do_each_netns(int (*func)(char *nsname, void *arg), void *arg,
 
 	return netns_foreach(on_netns, &nsf);
 }
+
+char *int_to_str(int val, char *buf)
+{
+	sprintf(buf, "%d", val);
+	return buf;
+}
diff --git a/misc/ss.c b/misc/ss.c
index 905cec9..9cf0055 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -789,6 +789,24 @@ static void sock_details_print(struct sockstat *s)
 	printf(" sk:%llx", s->sk);
 }
 
+static void sock_addr_print_width(int addr_len, const char *addr, char *delim,
+		int port_len, const char *port, const char *ifname)
+{
+	if (ifname) {
+		printf("%*s%%%s%s%-*s ", addr_len, addr, ifname, delim,
+				port_len, port);
+	}
+	else {
+		printf("%*s%s%-*s ", addr_len, addr, delim, port_len, port);
+	}
+}
+
+static void sock_addr_print(const char *addr, char *delim, const char *port,
+		const char *ifname)
+{
+	sock_addr_print_width(addr_width, addr, delim, serv_width, port, ifname);
+}
+
 static const char *tmr_name[] = {
 	"off",
 	"on",
@@ -971,13 +989,12 @@ static const char *resolve_service(int port)
 	return buf;
 }
 
-static void formatted_print(const inet_prefix *a, int port, unsigned int ifindex)
+static void inet_addr_print(const inet_prefix *a, int port, unsigned int ifindex)
 {
 	char buf[1024];
 	const char *ap = buf;
-	int est_len;
-
-	est_len = addr_width;
+	int est_len = addr_width;
+	const char *ifname = NULL;
 
 	if (a->family == AF_INET) {
 		if (a->data[0] == 0) {
@@ -994,14 +1011,14 @@ static void formatted_print(const inet_prefix *a, int port, unsigned int ifindex
 		else
 			est_len = addr_width + ((est_len-addr_width+3)/4)*4;
 	}
+
 	if (ifindex) {
-		const char *ifname = ll_index_to_name(ifindex);
-		const int len = strlen(ifname) + 1;  /* +1 for percent char */
+		ifname   = ll_index_to_name(ifindex);
+		est_len -= strlen(ifname) + 1;  /* +1 for percent char */
+	}
 
-		printf("%*s%%%s:%-*s ", est_len - len, ap, ifname, serv_width,
-		       resolve_service(port));
-	} else
-		printf("%*s:%-*s ", est_len, ap, serv_width, resolve_service(port));
+	sock_addr_print_width(est_len, ap, ":", serv_width, resolve_service(port),
+			ifname);
 }
 
 struct aafilter
@@ -1533,8 +1550,8 @@ static void inet_stats_print(struct sockstat *s, int protocol)
 
 	sock_state_print(s, proto_name(protocol));
 
-	formatted_print(&s->local, s->lport, s->iface);
-	formatted_print(&s->remote, s->rport, 0);
+	inet_addr_print(&s->local, s->lport, s->iface);
+	inet_addr_print(&s->remote, s->rport, 0);
 
 	if (show_proc_ctx || show_sock_ctx) {
 		if (find_entry(s->ino, &buf,
@@ -2490,7 +2507,9 @@ static void unix_stats_print(struct sockstat *list, struct filter *f)
 {
 	struct sockstat *s;
 	char *local, *peer;
+	char *ctx_buf = NULL;
 	bool use_proc = unix_use_proc();
+	char port_name[30] = {};
 
 	for (s = list; s; s = s->next) {
 		if (!(f->states & (1 << s->state)))
@@ -2529,22 +2548,22 @@ static void unix_stats_print(struct sockstat *list, struct filter *f)
 
 		sock_state_print(s, unix_netid_name(s->type));
 
-		printf("%*s %-*d %*s %-*d",
-		       addr_width, local ? : "*", serv_width,
-		       s->lport, addr_width, peer, serv_width, s->rport);
-		char *buf = NULL;
+		sock_addr_print(local ?: "*", " ",
+				int_to_str(s->lport, port_name), NULL);
+		sock_addr_print(peer, " ", int_to_str(s->rport, port_name),
+				NULL);
 
 		if (show_proc_ctx || show_sock_ctx) {
-			if (find_entry(s->ino, &buf,
+			if (find_entry(s->ino, &ctx_buf,
 					(show_proc_ctx & show_sock_ctx) ?
 					PROC_SOCK_CTX : PROC_CTX) > 0) {
-				printf(" users:(%s)", buf);
-				free(buf);
+				printf(" users:(%s)", ctx_buf);
+				free(ctx_buf);
 			}
 		} else if (show_users) {
-			if (find_entry(s->ino, &buf, USERS) > 0) {
-				printf(" users:(%s)", buf);
-				free(buf);
+			if (find_entry(s->ino, &ctx_buf, USERS) > 0) {
+				printf(" users:(%s)", ctx_buf);
+				free(ctx_buf);
 			}
 		}
 		printf("\n");
@@ -2734,6 +2753,8 @@ static int unix_show(struct filter *f)
 static int packet_stats_print(struct sockstat *s, const struct filter *f)
 {
 	char *buf = NULL;
+	const char *addr, *port;
+	char ll_name[16];
 
 	if (f->f) {
 		s->local.family = AF_PACKET;
@@ -2745,20 +2766,18 @@ static int packet_stats_print(struct sockstat *s, const struct filter *f)
 
 	sock_state_print(s, s->type == SOCK_RAW ? "p_raw" : "p_dgr");
 
-	if (s->prot == 3) {
-		printf("%*s:", addr_width, "*");
-	} else {
-		char tb[16];
-		printf("%*s:", addr_width,
-				ll_proto_n2a(htons(s->prot), tb, sizeof(tb)));
-	}
-	if (s->iface == 0) {
-		printf("%-*s ", serv_width, "*");
-	} else {
-		printf("%-*s ", serv_width, xll_index_to_name(s->iface));
-	}
+	if (s->prot == 3)
+		addr = "*";
+	else
+		addr = ll_proto_n2a(htons(s->prot), ll_name, sizeof(ll_name));
+
+	if (s->iface == 0)
+		port = "*";
+	else
+		port = xll_index_to_name(s->iface);
 
-	printf("%*s*%-*s", addr_width, "", serv_width, "");
+	sock_addr_print(addr, ":", port, NULL);
+	sock_addr_print("", "*", "", NULL);
 
 	if (show_proc_ctx || show_sock_ctx) {
 		if (find_entry(s->ino, &buf,
@@ -2903,7 +2922,9 @@ static void netlink_show_one(struct filter *f,
 				unsigned long long sk, unsigned long long cb)
 {
 	struct sockstat st;
-	SPRINT_BUF(prot_name);
+	SPRINT_BUF(prot_buf) = {};
+	const char *prot_name;
+	char procname[64] = {};
 
 	st.state = SS_CLOSE;
 	st.rq	 = rq;
@@ -2921,46 +2942,45 @@ static void netlink_show_one(struct filter *f,
 
 	sock_state_print(&st, "nl");
 
-	if (resolve_services) {
-		printf("%*s:", addr_width, nl_proto_n2a(prot, prot_name,
-					sizeof(prot_name)));
-	} else {
-		printf("%*d:", addr_width, prot);
-	}
+	if (resolve_services)
+		prot_name = nl_proto_n2a(prot, prot_buf, sizeof(prot_buf));
+	else
+		prot_name = int_to_str(prot, prot_buf);
 
 	if (pid == -1) {
-		printf("%-*s ", serv_width, "*");
+		procname[0] = '*';
 	} else if (resolve_services) {
 		int done = 0;
 		if (!pid) {
 			done = 1;
-			printf("%-*s ", serv_width, "kernel");
+			strncpy(procname, "kernel", 6);
 		} else if (pid > 0) {
-			char procname[64];
 			FILE *fp;
 			sprintf(procname, "%s/%d/stat",
 				getenv("PROC_ROOT") ? : "/proc", pid);
 			if ((fp = fopen(procname, "r")) != NULL) {
 				if (fscanf(fp, "%*d (%[^)])", procname) == 1) {
 					sprintf(procname+strlen(procname), "/%d", pid);
-					printf("%-*s ", serv_width, procname);
 					done = 1;
 				}
 				fclose(fp);
 			}
 		}
 		if (!done)
-			printf("%-*d ", serv_width, pid);
+			int_to_str(pid, procname);
 	} else {
-		printf("%-*d ", serv_width, pid);
+		int_to_str(pid, procname);
 	}
 
+	sock_addr_print(prot_name, ":", procname, NULL);
+
 	if (state == NETLINK_CONNECTED) {
-		printf("%*d:%-*d",
-		       addr_width, dst_group, serv_width, dst_pid);
+		char dst_group_buf[30];
+		char dst_pid_buf[30];
+		sock_addr_print(int_to_str(dst_group, dst_group_buf), ":",
+				int_to_str(dst_pid, dst_pid_buf), NULL);
 	} else {
-		printf("%*s*%-*s",
-		       addr_width, "", serv_width, "");
+		sock_addr_print("", "*", "", NULL);
 	}
 
 	char *pid_context = NULL;
-- 
2.2.2

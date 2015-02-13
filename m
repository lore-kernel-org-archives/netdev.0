From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 4/7] ss: Unify state socket output:netid, state, rq, wq
Date: Fri, 13 Feb 2015 22:14:01 +0200
Message-ID: <1423858444-10158-5-git-send-email-vadim4j@gmail.com>
References: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:39040 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbbBMUZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 15:25:15 -0500
Received: by labgq15 with SMTP id gq15so18717701lab.6
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 12:25:14 -0800 (PST)
In-Reply-To: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 61 ++++++++++++++++++++++++++++---------------------------------
 1 file changed, 28 insertions(+), 33 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 54f2e21..305ab38 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -765,6 +765,16 @@ struct tcpstat
 	struct dctcpstat    *dctcp;
 };
 
+static void sock_state_print(struct sockstat *s, const char *sock_name)
+{
+	if (netid_width)
+		printf("%-*s ", netid_width, sock_name);
+	if (state_width)
+		printf("%-*s ", state_width, sstate_name[s->state]);
+
+	printf("%-6d %-6d ", s->rq, s->wq);
+}
+
 static const char *tmr_name[] = {
 	"off",
 	"on",
@@ -1507,12 +1517,7 @@ static void inet_stats_print(struct sockstat *s, int protocol)
 {
 	char *buf = NULL;
 
-	if (netid_width)
-		printf("%-*s ", netid_width, proto_name(protocol));
-	if (state_width)
-		printf("%-*s ", state_width, sstate_name[s->state]);
-
-	printf("%-6d %-6d ", s->rq, s->wq);
+	sock_state_print(s, proto_name(protocol));
 
 	formatted_print(&s->local, s->lport, s->iface);
 	formatted_print(&s->remote, s->rport, 0);
@@ -2522,12 +2527,8 @@ static void unix_stats_print(struct sockstat *list, struct filter *f)
 				continue;
 		}
 
-		if (netid_width)
-			printf("%-*s ", netid_width,
-			       unix_netid_name(s->type));
-		if (state_width)
-			printf("%-*s ", state_width, sstate_name[s->state]);
-		printf("%-6d %-6d ", s->rq, s->wq);
+		sock_state_print(s, unix_netid_name(s->type));
+
 		printf("%*s %-*d %*s %-*d",
 		       addr_width, local ? : "*", serv_width,
 		       s->lport, addr_width, peer, serv_width, s->rport);
@@ -2737,21 +2738,13 @@ static int packet_stats_print(struct sockstat *s, const struct filter *f)
 	if (f->f) {
 		s->local.family = AF_PACKET;
 		s->remote.family = AF_PACKET;
-		s->rport = 0;
-		s->lport = s->iface;
 		s->local.data[0] = s->prot;
-		s->remote.data[0] = 0;
 		if (run_ssfilter(f->f, s) == 0)
 			return 1;
 	}
 
-	if (netid_width)
-		printf("%-*s ", netid_width,
-				s->type == SOCK_RAW ? "p_raw" : "p_dgr");
-	if (state_width)
-		printf("%-*s ", state_width, "UNCONN");
+	sock_state_print(s, s->type == SOCK_RAW ? "p_raw" : "p_dgr");
 
-	printf("%-6d %-6d ", s->rq, 0);
 	if (s->prot == 3) {
 		printf("%*s:", addr_width, "*");
 	} else {
@@ -2799,9 +2792,10 @@ static int packet_show_sock(const struct sockaddr_nl *addr,
 	if (!tb[PACKET_DIAG_MEMINFO])
 		return -1;
 
-	stat.type = r->pdiag_type;
-	stat.prot = r->pdiag_num;
-	stat.ino = r->pdiag_ino;
+	stat.type   = r->pdiag_type;
+	stat.prot   = r->pdiag_num;
+	stat.ino    = r->pdiag_ino;
+	stat.state  = SS_CLOSE;
 
 	if (tb[PACKET_DIAG_MEMINFO]) {
 		__u32 *skmeminfo = RTA_DATA(tb[PACKET_DIAG_MEMINFO]);
@@ -2810,7 +2804,7 @@ static int packet_show_sock(const struct sockaddr_nl *addr,
 
 	if (tb[PACKET_DIAG_INFO]) {
 		struct packet_diag_info *pinfo = RTA_DATA(tb[PACKET_DIAG_INFO]);
-		stat.iface = pinfo->pdi_index;
+		stat.lport = stat.iface = pinfo->pdi_index;
 	}
 
 	if (packet_stats_print(&stat, f))
@@ -2874,11 +2868,13 @@ static int packet_show_line(char *buf, const struct filter *f, int fam)
 
 	stat.type  = type;
 	stat.prot  = prot;
-	stat.iface = iface;
+	stat.lport = stat.iface = iface;
 	stat.state = state;
 	stat.rq    = rq;
 	stat.uid   = uid;
 	stat.ino   = ino;
+	stat.state = SS_CLOSE;
+
 	if (packet_stats_print(&stat, f))
 		return 0;
 
@@ -2914,25 +2910,24 @@ static void netlink_show_one(struct filter *f,
 				int rq, int wq,
 				unsigned long long sk, unsigned long long cb)
 {
+	struct sockstat st;
 	SPRINT_BUF(prot_name);
 
+	st.state = SS_CLOSE;
+	st.rq	 = rq;
+	st.wq	 = wq;
+
 	if (f->f) {
-		struct sockstat st;
 		st.local.family = AF_NETLINK;
 		st.remote.family = AF_NETLINK;
 		st.rport = -1;
 		st.lport = pid;
 		st.local.data[0] = prot;
-		st.remote.data[0] = 0;
 		if (run_ssfilter(f->f, &st) == 0)
 			return;
 	}
 
-	if (netid_width)
-		printf("%-*s ", netid_width, "nl");
-	if (state_width)
-		printf("%-*s ", state_width, "UNCONN");
-	printf("%-6d %-6d ", rq, wq);
+	sock_state_print(&st, "nl");
 
 	if (resolve_services) {
 		printf("%*s:", addr_width, nl_proto_n2a(prot, prot_name,
-- 
2.2.2

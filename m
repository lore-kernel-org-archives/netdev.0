From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 05/18] ss: introduce proc_ctx_print()
Date: Fri,  2 Dec 2016 11:39:49 +0100
Message-ID: <20161202104002.17310-6-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46587 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934231AbcLBKlg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:41:36 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This consolidates identical code in three places. While the function
name is not quite perfect as there is different proc_ctx printing code
in netlink_show_one() as well, I sadly didn't find a more suitable one.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 49 ++++++++++++++-----------------------------------
 1 file changed, 14 insertions(+), 35 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index a953d4b022aed..fcbaecbe25a2f 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1773,14 +1773,9 @@ void *parse_markmask(const char *markmask)
 	return res;
 }
 
-static void inet_stats_print(struct sockstat *s)
+static void proc_ctx_print(struct sockstat *s)
 {
-	char *buf = NULL;
-
-	sock_state_print(s);
-
-	inet_addr_print(&s->local, s->lport, s->iface);
-	inet_addr_print(&s->remote, s->rport, 0);
+	char *buf;
 
 	if (show_proc_ctx || show_sock_ctx) {
 		if (find_entry(s->ino, &buf,
@@ -1797,6 +1792,16 @@ static void inet_stats_print(struct sockstat *s)
 	}
 }
 
+static void inet_stats_print(struct sockstat *s)
+{
+	sock_state_print(s);
+
+	inet_addr_print(&s->local, s->lport, s->iface);
+	inet_addr_print(&s->remote, s->rport, 0);
+
+	proc_ctx_print(s);
+}
+
 static int proc_parse_inet_addr(char *loc, char *rem, int family, struct
 		sockstat * s)
 {
@@ -3001,7 +3006,6 @@ static void unix_stats_print(struct sockstat *list, struct filter *f)
 {
 	struct sockstat *s;
 	char *peer;
-	char *ctx_buf = NULL;
 	bool use_proc = unix_use_proc();
 	char port_name[30] = {};
 
@@ -3050,19 +3054,7 @@ static void unix_stats_print(struct sockstat *list, struct filter *f)
 		sock_addr_print(peer, " ", int_to_str(s->rport, port_name),
 				NULL);
 
-		if (show_proc_ctx || show_sock_ctx) {
-			if (find_entry(s->ino, &ctx_buf,
-					(show_proc_ctx & show_sock_ctx) ?
-					PROC_SOCK_CTX : PROC_CTX) > 0) {
-				printf(" users:(%s)", ctx_buf);
-				free(ctx_buf);
-			}
-		} else if (show_users) {
-			if (find_entry(s->ino, &ctx_buf, USERS) > 0) {
-				printf(" users:(%s)", ctx_buf);
-				free(ctx_buf);
-			}
-		}
+		proc_ctx_print(s);
 		printf("\n");
 	}
 }
@@ -3260,7 +3252,6 @@ static int unix_show(struct filter *f)
 
 static int packet_stats_print(struct sockstat *s, const struct filter *f)
 {
-	char *buf = NULL;
 	const char *addr, *port;
 	char ll_name[16];
 
@@ -3287,19 +3278,7 @@ static int packet_stats_print(struct sockstat *s, const struct filter *f)
 	sock_addr_print(addr, ":", port, NULL);
 	sock_addr_print("", "*", "", NULL);
 
-	if (show_proc_ctx || show_sock_ctx) {
-		if (find_entry(s->ino, &buf,
-					(show_proc_ctx & show_sock_ctx) ?
-					PROC_SOCK_CTX : PROC_CTX) > 0) {
-			printf(" users:(%s)", buf);
-			free(buf);
-		}
-	} else if (show_users) {
-		if (find_entry(s->ino, &buf, USERS) > 0) {
-			printf(" users:(%s)", buf);
-			free(buf);
-		}
-	}
+	proc_ctx_print(s);
 
 	if (show_details)
 		sock_details_print(s);
-- 
2.10.0

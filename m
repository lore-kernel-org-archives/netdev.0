From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Fix filter expression parser
Date: Fri, 13 Feb 2015 13:01:08 +0200
Message-ID: <1423825268-18714-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:42120 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbbBMLMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 06:12:15 -0500
Received: by mail-lb0-f173.google.com with SMTP id n10so14889080lbv.4
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 03:12:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Seems expression parser did not work correctly some
long time and such simple things did not work too:

    # ss -a '( sport = :ssh )'

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 51 ++++++++++++++++++++++++++++++++-------------------
 1 file changed, 32 insertions(+), 19 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 0a6a65e..eb4e0ec 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -240,10 +240,11 @@ static void filter_db_set(struct filter *f, int db)
 
 static void filter_af_set(struct filter *f, int af)
 {
-	f->dbs	    |= default_afs[af].dbs;
-	f->states   |= default_afs[af].states;
-	f->families |= 1 << af;
-	do_default   = 0;
+	f->dbs		   |= default_afs[af].dbs;
+	f->states	   |= default_afs[af].states;
+	f->families	   |= 1 << af;
+	do_default	    = 0;
+	preferred_family    = af;
 }
 
 static int filter_af_get(struct filter *f, int af)
@@ -1316,15 +1317,12 @@ static int xll_name_to_index(const char *dev)
 void *parse_hostcond(char *addr)
 {
 	char *port = NULL;
-	struct aafilter a;
+	struct aafilter a = { .port = -1 };
 	struct aafilter *res;
-	int fam = 0;
+	int fam = preferred_family;
 	struct filter *f = &current_filter;
 
-	memset(&a, 0, sizeof(a));
-	a.port = -1;
-
-	if (filter_af_get(f, AF_UNIX) || strncmp(addr, "unix:", 5) == 0) {
+	if (fam == AF_UNIX || strncmp(addr, "unix:", 5) == 0) {
 		char *p;
 		a.addr.family = AF_UNIX;
 		if (strncmp(addr, "unix:", 5) == 0)
@@ -1336,7 +1334,7 @@ void *parse_hostcond(char *addr)
 		goto out;
 	}
 
-	if (filter_af_get(f, AF_PACKET) || strncmp(addr, "link:", 5) == 0) {
+	if (fam == AF_PACKET || strncmp(addr, "link:", 5) == 0) {
 		a.addr.family = AF_PACKET;
 		a.addr.bitlen = 0;
 		if (strncmp(addr, "link:", 5) == 0)
@@ -1362,7 +1360,7 @@ void *parse_hostcond(char *addr)
 		goto out;
 	}
 
-	if (filter_af_get(f, AF_NETLINK) || strncmp(addr, "netlink:", 8) == 0) {
+	if (fam == AF_NETLINK || strncmp(addr, "netlink:", 8) == 0) {
 		a.addr.family = AF_NETLINK;
 		a.addr.bitlen = 0;
 		if (strncmp(addr, "netlink:", 8) == 0)
@@ -1388,12 +1386,14 @@ void *parse_hostcond(char *addr)
 		goto out;
 	}
 
-	if (filter_af_get(f, AF_INET) || !strncmp(addr, "inet:", 5)) {
-		addr += 5;
+	if (fam == AF_INET || !strncmp(addr, "inet:", 5)) {
 		fam = AF_INET;
-	} else if (filter_af_get(f, AF_INET6) || !strncmp(addr, "inet6:", 6)) {
-		addr += 6;
+		if (!strncmp(addr, "inet:", 5))
+			addr += 5;
+	} else if (fam == AF_INET6 || !strncmp(addr, "inet6:", 6)) {
 		fam = AF_INET6;
+		if (!strncmp(addr, "inet6:", 6))
+			addr += 6;
 	}
 
 	/* URL-like literal [] */
@@ -1461,8 +1461,11 @@ void *parse_hostcond(char *addr)
 	}
 
 out:
-	if (fam)
+	if (fam != AF_UNSPEC) {
+		f->families = 0;
 		filter_af_set(f, fam);
+		filter_merge(f, f, 0);
+	}
 
 	res = malloc(sizeof(*res));
 	if (res)
@@ -2212,6 +2215,9 @@ static int tcp_show(struct filter *f, int socktype)
 	char *buf = NULL;
 	int bufsize = 64*1024;
 
+	if (!filter_af_get(f, AF_INET) && !filter_af_get(f, AF_INET6))
+		return 0;
+
 	dg_proto = TCP_PROTO;
 
 	if (getenv("TCPDIAG_FILE"))
@@ -2331,6 +2337,9 @@ static int udp_show(struct filter *f)
 {
 	FILE *fp = NULL;
 
+	if (!filter_af_get(f, AF_INET) && !filter_af_get(f, AF_INET6))
+		return 0;
+
 	dg_proto = UDP_PROTO;
 
 	if (!getenv("PROC_NET_UDP") && !getenv("PROC_ROOT")
@@ -2367,6 +2376,9 @@ static int raw_show(struct filter *f)
 {
 	FILE *fp = NULL;
 
+	if (!filter_af_get(f, AF_INET) && !filter_af_get(f, AF_INET6))
+		return 0;
+
 	dg_proto = RAW_PROTO;
 
 	if (f->families&(1<<AF_INET)) {
@@ -3579,8 +3591,6 @@ int main(int argc, char *argv[])
 			state_filter &= ~scan_state(*argv);
 			saw_states = 1;
 		} else {
-			if (ssfilter_parse(&current_filter.f, argc, argv, filter_fp))
-				usage();
 			break;
 		}
 		argc--; argv++;
@@ -3630,6 +3640,9 @@ int main(int argc, char *argv[])
 		exit(0);
 	}
 
+	if (ssfilter_parse(&current_filter.f, argc, argv, filter_fp))
+		usage();
+
 	netid_width = 0;
 	if (current_filter.dbs&(current_filter.dbs-1))
 		netid_width = 5;
-- 
2.2.2

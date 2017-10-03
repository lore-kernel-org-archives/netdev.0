From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH iproute2 1/3] ss: allow AF_FAMILY constants >32
Date: Tue,  3 Oct 2017 13:57:42 -0400
Message-ID: <20171003175744.24987-2-stefanha@redhat.com>
References: <20171003175744.24987-1-stefanha@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42832 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751199AbdJCR6B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 13:58:01 -0400
In-Reply-To: <20171003175744.24987-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux has more than 32 address families defined in <bits/socket.h>.  Use
a 64-bit type so all of them can be represented in the filter->families
bitmask.

It's easy to introduce bugs when using (1 << AF_FAMILY) because the
value is 32-bit.  This can produce incorrect results from bitmask
operations so introduce the FAMILY_MASK() macro to eliminate these bugs.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 misc/ss.c | 54 ++++++++++++++++++++++++++++--------------------------
 1 file changed, 28 insertions(+), 26 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index dd8dfaa4..12a31c90 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -170,55 +170,57 @@ enum {
 struct filter {
 	int dbs;
 	int states;
-	int families;
+	__u64 families;
 	struct ssfilter *f;
 	bool kill;
 };
 
+#define FAMILY_MASK(family) ((__u64)1 << (family))
+
 static const struct filter default_dbs[MAX_DB] = {
 	[TCP_DB] = {
 		.states   = SS_CONN,
-		.families = (1 << AF_INET) | (1 << AF_INET6),
+		.families = FAMILY_MASK(AF_INET) | FAMILY_MASK(AF_INET6),
 	},
 	[DCCP_DB] = {
 		.states   = SS_CONN,
-		.families = (1 << AF_INET) | (1 << AF_INET6),
+		.families = FAMILY_MASK(AF_INET) | FAMILY_MASK(AF_INET6),
 	},
 	[UDP_DB] = {
 		.states   = (1 << SS_ESTABLISHED),
-		.families = (1 << AF_INET) | (1 << AF_INET6),
+		.families = FAMILY_MASK(AF_INET) | FAMILY_MASK(AF_INET6),
 	},
 	[RAW_DB] = {
 		.states   = (1 << SS_ESTABLISHED),
-		.families = (1 << AF_INET) | (1 << AF_INET6),
+		.families = FAMILY_MASK(AF_INET) | FAMILY_MASK(AF_INET6),
 	},
 	[UNIX_DG_DB] = {
 		.states   = (1 << SS_CLOSE),
-		.families = (1 << AF_UNIX),
+		.families = FAMILY_MASK(AF_UNIX),
 	},
 	[UNIX_ST_DB] = {
 		.states   = SS_CONN,
-		.families = (1 << AF_UNIX),
+		.families = FAMILY_MASK(AF_UNIX),
 	},
 	[UNIX_SQ_DB] = {
 		.states   = SS_CONN,
-		.families = (1 << AF_UNIX),
+		.families = FAMILY_MASK(AF_UNIX),
 	},
 	[PACKET_DG_DB] = {
 		.states   = (1 << SS_CLOSE),
-		.families = (1 << AF_PACKET),
+		.families = FAMILY_MASK(AF_PACKET),
 	},
 	[PACKET_R_DB] = {
 		.states   = (1 << SS_CLOSE),
-		.families = (1 << AF_PACKET),
+		.families = FAMILY_MASK(AF_PACKET),
 	},
 	[NETLINK_DB] = {
 		.states   = (1 << SS_CLOSE),
-		.families = (1 << AF_NETLINK),
+		.families = FAMILY_MASK(AF_NETLINK),
 	},
 	[SCTP_DB] = {
 		.states   = SS_CONN,
-		.families = (1 << AF_INET) | (1 << AF_INET6),
+		.families = FAMILY_MASK(AF_INET) | FAMILY_MASK(AF_INET6),
 	},
 };
 
@@ -258,14 +260,14 @@ static void filter_db_set(struct filter *f, int db)
 static void filter_af_set(struct filter *f, int af)
 {
 	f->states	   |= default_afs[af].states;
-	f->families	   |= 1 << af;
+	f->families	   |= FAMILY_MASK(af);
 	do_default	    = 0;
 	preferred_family    = af;
 }
 
 static int filter_af_get(struct filter *f, int af)
 {
-	return f->families & (1 << af);
+	return !!(f->families & FAMILY_MASK(af));
 }
 
 static void filter_default_dbs(struct filter *f)
@@ -302,7 +304,7 @@ static void filter_merge_defaults(struct filter *f)
 			f->families |= default_dbs[db].families;
 	}
 	for (af = 0; af < AF_MAX; af++) {
-		if (!(f->families & (1 << af)))
+		if (!(f->families & FAMILY_MASK(af)))
 			continue;
 
 		if (!(default_afs[af].dbs & f->dbs))
@@ -2608,7 +2610,7 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
 	struct inet_diag_msg *r = NLMSG_DATA(h);
 	struct sockstat s = {};
 
-	if (!(diag_arg->f->families & (1 << r->idiag_family)))
+	if (!(diag_arg->f->families & FAMILY_MASK(r->idiag_family)))
 		return 0;
 
 	parse_diag_msg(h, &s);
@@ -2802,7 +2804,7 @@ static int tcp_show(struct filter *f)
 		return -1;
 	}
 
-	if (f->families & (1<<AF_INET)) {
+	if (f->families & FAMILY_MASK(AF_INET)) {
 		if ((fp = net_tcp_open()) == NULL)
 			goto outerr;
 
@@ -2812,7 +2814,7 @@ static int tcp_show(struct filter *f)
 		fclose(fp);
 	}
 
-	if ((f->families & (1<<AF_INET6)) &&
+	if ((f->families & FAMILY_MASK(AF_INET6)) &&
 	    (fp = net_tcp6_open()) != NULL) {
 		setbuffer(fp, buf, bufsize);
 		if (generic_record_read(fp, tcp_show_line, f, AF_INET6))
@@ -2911,7 +2913,7 @@ static int udp_show(struct filter *f)
 	    && inet_show_netlink(f, NULL, IPPROTO_UDP) == 0)
 		return 0;
 
-	if (f->families&(1<<AF_INET)) {
+	if (f->families&FAMILY_MASK(AF_INET)) {
 		if ((fp = net_udp_open()) == NULL)
 			goto outerr;
 		if (generic_record_read(fp, dgram_show_line, f, AF_INET))
@@ -2919,7 +2921,7 @@ static int udp_show(struct filter *f)
 		fclose(fp);
 	}
 
-	if ((f->families&(1<<AF_INET6)) &&
+	if ((f->families&FAMILY_MASK(AF_INET6)) &&
 	    (fp = net_udp6_open()) != NULL) {
 		if (generic_record_read(fp, dgram_show_line, f, AF_INET6))
 			goto outerr;
@@ -2951,7 +2953,7 @@ static int raw_show(struct filter *f)
 	    inet_show_netlink(f, NULL, IPPROTO_RAW) == 0)
 		return 0;
 
-	if (f->families&(1<<AF_INET)) {
+	if (f->families&FAMILY_MASK(AF_INET)) {
 		if ((fp = net_raw_open()) == NULL)
 			goto outerr;
 		if (generic_record_read(fp, dgram_show_line, f, AF_INET))
@@ -2959,7 +2961,7 @@ static int raw_show(struct filter *f)
 		fclose(fp);
 	}
 
-	if ((f->families&(1<<AF_INET6)) &&
+	if ((f->families&FAMILY_MASK(AF_INET6)) &&
 	    (fp = net_raw6_open()) != NULL) {
 		if (generic_record_read(fp, dgram_show_line, f, AF_INET6))
 			goto outerr;
@@ -3703,13 +3705,13 @@ static int handle_follow_request(struct filter *f)
 	int groups = 0;
 	struct rtnl_handle rth;
 
-	if (f->families & (1 << AF_INET) && f->dbs & (1 << TCP_DB))
+	if (f->families & FAMILY_MASK(AF_INET) && f->dbs & (1 << TCP_DB))
 		groups |= 1 << (SKNLGRP_INET_TCP_DESTROY - 1);
-	if (f->families & (1 << AF_INET) && f->dbs & (1 << UDP_DB))
+	if (f->families & FAMILY_MASK(AF_INET) && f->dbs & (1 << UDP_DB))
 		groups |= 1 << (SKNLGRP_INET_UDP_DESTROY - 1);
-	if (f->families & (1 << AF_INET6) && f->dbs & (1 << TCP_DB))
+	if (f->families & FAMILY_MASK(AF_INET6) && f->dbs & (1 << TCP_DB))
 		groups |= 1 << (SKNLGRP_INET6_TCP_DESTROY - 1);
-	if (f->families & (1 << AF_INET6) && f->dbs & (1 << UDP_DB))
+	if (f->families & FAMILY_MASK(AF_INET6) && f->dbs & (1 << UDP_DB))
 		groups |= 1 << (SKNLGRP_INET6_UDP_DESTROY - 1);
 
 	if (groups == 0)
-- 
2.13.6

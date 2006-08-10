From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 03/03]: Add support for larger number of routing tables
Date: Fri, 11 Aug 2006 00:14:51 +0200 (MEST)
Message-ID: <20060810221451.9060.33133.sendpatchset@localhost.localdomain>
References: <20060810221447.9060.5563.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:29156 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751133AbWHJWOx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 18:14:53 -0400
To: shemminger@osdl.org
In-Reply-To: <20060810221447.9060.5563.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Add support for larger number of routing tables

Support support for 2^32 routing tables by using the new RTA_TABLE
attribute for specifying tables > 255 and intepreting it if it is
sent by the kernel.

When tables > 255 are used on a kernel not supporting it an error will
occur because of the unknown netlink attribute.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7980d6ceea890359173344e71c1139b252fd9894
tree 19a33af25df28c002569e85b34a8c90ca517d875
parent ccd621fbb5faa91a98479e9492baee525c6f10c0
author Patrick McHardy <kaber@trash.net> Fri, 11 Aug 2006 00:03:32 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 11 Aug 2006 00:03:32 +0200

 include/linux/rtnetlink.h |    4 ++--
 include/rt_names.h        |    2 +-
 ip/ip_common.h            |    8 ++++++++
 ip/iproute.c              |   21 ++++++++++++++-------
 ip/iprule.c               |   14 +++++++++++---
 lib/rt_names.c            |    4 ++--
 6 files changed, 38 insertions(+), 15 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 5e33a20..d63578c 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -238,9 +238,8 @@ enum rt_class_t
 	RT_TABLE_DEFAULT=253,
 	RT_TABLE_MAIN=254,
 	RT_TABLE_LOCAL=255,
-	__RT_TABLE_MAX
+	RT_TABLE_MAX=0xFFFFFFFF,
 };
-#define RT_TABLE_MAX (__RT_TABLE_MAX - 1)
 
 
 
@@ -263,6 +262,7 @@ enum rtattr_type_t
 	RTA_CACHEINFO,
 	RTA_SESSION,
 	RTA_MP_ALGO,
+	RTA_TABLE,
 	__RTA_MAX
 };
 
diff --git a/include/rt_names.h b/include/rt_names.h
index 2d9ef10..07a10e0 100644
--- a/include/rt_names.h
+++ b/include/rt_names.h
@@ -5,7 +5,7 @@ #include <asm/types.h>
 
 char* rtnl_rtprot_n2a(int id, char *buf, int len);
 char* rtnl_rtscope_n2a(int id, char *buf, int len);
-char* rtnl_rttable_n2a(int id, char *buf, int len);
+char* rtnl_rttable_n2a(__u32 id, char *buf, int len);
 char* rtnl_rtrealm_n2a(int id, char *buf, int len);
 char* rtnl_dsfield_n2a(int id, char *buf, int len);
 int rtnl_rtprot_a2n(__u32 *id, char *arg);
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 1fe4a69..8b286b0 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -32,4 +32,12 @@ extern int do_multiaddr(int argc, char *
 extern int do_multiroute(int argc, char **argv);
 extern int do_xfrm(int argc, char **argv);
 
+static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
+{
+	__u32 table = r->rtm_table;
+	if (tb[RTA_TABLE])
+		table = *(__u32*) RTA_DATA(tb[RTA_TABLE]);
+	return table;
+}
+
 extern struct rtnl_handle rth;
diff --git a/ip/iproute.c b/ip/iproute.c
index cb674d7..24e7a86 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -140,6 +140,7 @@ int print_route(const struct sockaddr_nl
 	inet_prefix via;
 	int host_len = -1;
 	static int ip6_multiple_tables;
+	__u32 table;
 	SPRINT_BUF(b1);
 	
 
@@ -165,7 +166,10 @@ int print_route(const struct sockaddr_nl
 	else if (r->rtm_family == AF_IPX)
 		host_len = 80;
 
-	if (r->rtm_family == AF_INET6 && r->rtm_table != RT_TABLE_MAIN)
+	parse_rtattr(tb, RTA_MAX, RTM_RTA(r), len);
+	table = rtm_get_table(r, tb);
+
+	if (r->rtm_family == AF_INET6 && table != RT_TABLE_MAIN)
 		ip6_multiple_tables = 1;
 
 	if (r->rtm_family == AF_INET6 && !ip6_multiple_tables) {
@@ -187,7 +191,7 @@ int print_route(const struct sockaddr_nl
 			}
 		}
 	} else {
-		if (filter.tb > 0 && filter.tb != r->rtm_table)
+		if (filter.tb > 0 && filter.tb != table)
 			return 0;
 	}
 	if ((filter.protocol^r->rtm_protocol)&filter.protocolmask)
@@ -217,8 +221,6 @@ int print_route(const struct sockaddr_nl
 	if (filter.rprefsrc.family && r->rtm_family != filter.rprefsrc.family)
 		return 0;
 
-	parse_rtattr(tb, RTA_MAX, RTM_RTA(r), len);
-
 	memset(&dst, 0, sizeof(dst));
 	dst.family = r->rtm_family;
 	if (tb[RTA_DST])
@@ -371,8 +373,8 @@ int print_route(const struct sockaddr_nl
 		fprintf(fp, "dev %s ", ll_index_to_name(*(int*)RTA_DATA(tb[RTA_OIF])));
 
 	if (!(r->rtm_flags&RTM_F_CLONED)) {
-		if (r->rtm_table != RT_TABLE_MAIN && !filter.tb)
-			fprintf(fp, " table %s ", rtnl_rttable_n2a(r->rtm_table, b1, sizeof(b1)));
+		if (table != RT_TABLE_MAIN && !filter.tb)
+			fprintf(fp, " table %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
 		if (r->rtm_protocol != RTPROT_BOOT && filter.protocolmask != -1)
 			fprintf(fp, " proto %s ", rtnl_rtprot_n2a(r->rtm_protocol, b1, sizeof(b1)));
 		if (r->rtm_scope != RT_SCOPE_UNIVERSE && filter.scopemask != -1)
@@ -875,7 +877,12 @@ #endif
 			NEXT_ARG();
 			if (rtnl_rttable_a2n(&tid, *argv))
 				invarg("\"table\" value is invalid\n", *argv);
-			req.r.rtm_table = tid;
+			if (tid < 256)
+				req.r.rtm_table = tid;
+			else {
+				req.r.rtm_table = RT_TABLE_UNSPEC;
+				addattr32(&req.n, sizeof(req), RTA_TABLE, tid);
+			}
 			table_ok = 1;
 		} else if (strcmp(*argv, "dev") == 0 ||
 			   strcmp(*argv, "oif") == 0) {
diff --git a/ip/iprule.c b/ip/iprule.c
index ccf699f..6caf573 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -27,6 +27,7 @@ #include <string.h>
 
 #include "rt_names.h"
 #include "utils.h"
+#include "ip_common.h"
 
 extern struct rtnl_handle rth;
 
@@ -51,6 +52,7 @@ static int print_rule(const struct socka
 	struct rtmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	int host_len = -1;
+	__u32 table;
 	struct rtattr * tb[RTA_MAX+1];
 	char abuf[256];
 	SPRINT_BUF(b1);
@@ -129,8 +131,9 @@ static int print_rule(const struct socka
 		fprintf(fp, "iif %s ", (char*)RTA_DATA(tb[RTA_IIF]));
 	}
 
-	if (r->rtm_table)
-		fprintf(fp, "lookup %s ", rtnl_rttable_n2a(r->rtm_table, b1, sizeof(b1)));
+	table = rtm_get_table(r, tb);
+	if (table)
+		fprintf(fp, "lookup %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
 
 	if (tb[RTA_FLOW]) {
 		__u32 to = *(__u32*)RTA_DATA(tb[RTA_FLOW]);
@@ -257,7 +260,12 @@ static int iprule_modify(int cmd, int ar
 			NEXT_ARG();
 			if (rtnl_rttable_a2n(&tid, *argv))
 				invarg("invalid table ID\n", *argv);
-			req.r.rtm_table = tid;
+			if (tid < 256)
+				req.r.rtm_table = tid;
+			else {
+				req.r.rtm_table = RT_TABLE_UNSPEC;
+				addattr32(&req.n, sizeof(req), RTA_TABLE, tid);
+			}
 			table_ok = 1;
 		} else if (strcmp(*argv, "dev") == 0 ||
 			   strcmp(*argv, "iif") == 0) {
diff --git a/lib/rt_names.c b/lib/rt_names.c
index b77ad4a..cb22313 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -329,7 +329,7 @@ static void rtnl_rttable_initialize(void
 			     rtnl_rttable_hash, 256);
 }
 
-char * rtnl_rttable_n2a(int id, char *buf, int len)
+char * rtnl_rttable_n2a(__u32 id, char *buf, int len)
 {
 	struct rtnl_hash_entry *entry;
 
@@ -354,7 +354,7 @@ int rtnl_rttable_a2n(__u32 *id, char *ar
 	static unsigned long res;
 	struct rtnl_hash_entry *entry;
 	char *end;
-	int i;
+	__u32 i;
 
 	if (cache && strcmp(cache, arg) == 0) {
 		*id = res;

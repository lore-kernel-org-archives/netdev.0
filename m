From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 1/3] ifstat: Change interface to get stats
Date: Thu, 24 Nov 2016 16:12:38 +0200
Message-ID: <1479996760-61271-2-git-send-email-nogahf@mellanox.com>
References: <1479996760-61271-1-git-send-email-nogahf@mellanox.com>
Cc: eladr@mellanox.com, yotamg@mellanox.com, jiri@mellanox.com,
        idosch@mellanox.com, ogerlitz@mellanox.com,
        Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43438 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S965564AbcKXOLg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 09:11:36 -0500
In-Reply-To: <1479996760-61271-1-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ifstat used to get it data from the kernel with RTM_GETLINK.
Change the interface to get this data to RTM_GETSTATS that supports more
stats type beside the default one. It also change the default stats to be
64 bits based.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 misc/ifstat.c | 41 ++++++++++++++++++++++-------------------
 1 file changed, 22 insertions(+), 19 deletions(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index d551973..25a8fc1 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -35,6 +35,7 @@
 
 #include <SNAPSHOT.h>
 
+#include "utils.h"
 int dump_zeros;
 int reset_history;
 int ignore_history;
@@ -52,15 +53,15 @@ int npatterns;
 char info_source[128];
 int source_mismatch;
 
-#define MAXS (sizeof(struct rtnl_link_stats)/sizeof(__u32))
+#define MAXS (sizeof(struct rtnl_link_stats64)/sizeof(__u64))
 
 struct ifstat_ent {
 	struct ifstat_ent	*next;
 	char			*name;
 	int			ifindex;
-	unsigned long long	val[MAXS];
+	__u64			val[MAXS];
 	double			rate[MAXS];
-	__u32			ival[MAXS];
+	__u64			ival[MAXS];
 };
 
 static const char *stats[MAXS] = {
@@ -109,32 +110,30 @@ static int match(const char *id)
 static int get_nlmsg(const struct sockaddr_nl *who,
 		     struct nlmsghdr *m, void *arg)
 {
-	struct ifinfomsg *ifi = NLMSG_DATA(m);
-	struct rtattr *tb[IFLA_MAX+1];
+	struct if_stats_msg *ifsm = NLMSG_DATA(m);
+	struct rtattr *tb[IFLA_STATS_MAX+1];
 	int len = m->nlmsg_len;
 	struct ifstat_ent *n;
 	int i;
 
-	if (m->nlmsg_type != RTM_NEWLINK)
+	if (m->nlmsg_type != RTM_NEWSTATS)
 		return 0;
 
-	len -= NLMSG_LENGTH(sizeof(*ifi));
+	len -= NLMSG_LENGTH(sizeof(*ifsm));
 	if (len < 0)
 		return -1;
 
-	if (!(ifi->ifi_flags&IFF_UP))
-		return 0;
-
-	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
-	if (tb[IFLA_IFNAME] == NULL || tb[IFLA_STATS] == NULL)
+	parse_rtattr(tb, IFLA_STATS_MAX, IFLA_STATS_RTA(ifsm), len);
+	if (tb[IFLA_STATS_LINK_64] == NULL)
 		return 0;
 
 	n = malloc(sizeof(*n));
 	if (!n)
 		abort();
-	n->ifindex = ifi->ifi_index;
-	n->name = strdup(RTA_DATA(tb[IFLA_IFNAME]));
-	memcpy(&n->ival, RTA_DATA(tb[IFLA_STATS]), sizeof(n->ival));
+
+	n->ifindex = ifsm->ifindex;
+	n->name = strdup(ll_index_to_name(ifsm->ifindex));
+	memcpy(&n->ival, RTA_DATA(tb[IFLA_STATS_LINK_64]), sizeof(n->ival));
 	memset(&n->rate, 0, sizeof(n->rate));
 	for (i = 0; i < MAXS; i++)
 		n->val[i] = n->ival[i];
@@ -147,11 +146,15 @@ static void load_info(void)
 {
 	struct ifstat_ent *db, *n;
 	struct rtnl_handle rth;
+	__u32 filt_mask;
 
 	if (rtnl_open(&rth, 0) < 0)
 		exit(1);
 
-	if (rtnl_wilddump_request(&rth, AF_INET, RTM_GETLINK) < 0) {
+	ll_init_map(&rth);
+	filt_mask = IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_64);
+	if (rtnl_wilddump_stats_req_filter(&rth, AF_UNSPEC, RTM_GETSTATS,
+					   filt_mask) < 0) {
 		perror("Cannot send dump request");
 		exit(1);
 	}
@@ -216,7 +219,7 @@ static void load_raw_table(FILE *fp)
 			*next++ = 0;
 			if (sscanf(p, "%llu", n->val+i) != 1)
 				abort();
-			n->ival[i] = (__u32)n->val[i];
+			n->ival[i] = (__u64)n->val[i];
 			p = next;
 			if (!(next = strchr(p, ' ')))
 				abort();
@@ -546,14 +549,14 @@ static void update_db(int interval)
 				int i;
 
 				for (i = 0; i < MAXS; i++) {
-					if ((long)(h1->ival[i] - n->ival[i]) < 0) {
+					if ((long long)(h1->ival[i] - n->ival[i]) < 0) {
 						memset(n->ival, 0, sizeof(n->ival));
 						break;
 					}
 				}
 				for (i = 0; i < MAXS; i++) {
 					double sample;
-					unsigned long incr = h1->ival[i] - n->ival[i];
+					unsigned long long incr = h1->ival[i] - n->ival[i];
 
 					n->val[i] += incr;
 					n->ival[i] = h1->ival[i];
-- 
2.4.3

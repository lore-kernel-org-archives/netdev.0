From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next] ifstat: move to new RTM_GETSTATS api
Date: Fri, 29 Apr 2016 23:41:51 -0700
Message-ID: <1461998511-24193-1-git-send-email-roopa@cumulusnetworks.com>
Cc: jhs@mojatatu.com, davem@davemloft.net, edumazet@google.com,
	tgraf@suug.ch, nicolas.dichtel@6wind.com,
	nikolay@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33397 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbcD3Gl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 02:41:56 -0400
Received: by mail-pf0-f174.google.com with SMTP id 206so57413255pfu.0
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 23:41:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch modifies ifstat to use the new RTM_GETSTATS api
to query stats from the kernel. In the process this also
moves ifstat to use 64 bit stats.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/libnetlink.h      |  3 +++
 include/linux/if_link.h   | 22 ++++++++++++++++++++++
 include/linux/rtnetlink.h |  5 +++++
 lib/libnetlink.c          | 25 +++++++++++++++++++++++++
 misc/ifstat.c             | 35 +++++++++++++++++++----------------
 5 files changed, 74 insertions(+), 16 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 491263f..e623a3c 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -44,6 +44,9 @@ int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req,
 int rtnl_dump_request_n(struct rtnl_handle *rth, struct nlmsghdr *n)
 	__attribute__((warn_unused_result));
 
+int rtnl_stats_dump_request(struct rtnl_handle *rth, __u32 filt_mask)
+			    __attribute__((warn_unused_result));
+
 struct rtnl_ctrl_data {
 	int	nsid;
 };
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 6a688e8..68f3270 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -165,6 +165,8 @@ enum {
 #define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
 #define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
 
+#define IFLA_RTA_STATS(r)  ((struct rtattr *)(((char *)(r)) + NLMSG_ALIGN(sizeof(struct if_stats_msg))))
+
 enum {
 	IFLA_INET_UNSPEC,
 	IFLA_INET_CONF,
@@ -777,4 +779,24 @@ enum {
 
 #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
 
+/* STATS section */
+
+struct if_stats_msg {
+	__u8  family;
+	__u8  pad1;
+	__u16 pad2;
+	__u32 ifindex;
+	__u32 filter_mask;
+};
+
+enum {
+	IFLA_STATS_UNSPEC,
+	IFLA_STATS_LINK_64,
+	__IFLA_STATS_MAX,
+};
+
+#define IFLA_STATS_MAX (__IFLA_STATS_MAX - 1)
+
+#define IFLA_STATS_FILTER_BIT(ATTR)  (1 << (ATTR - 1))
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 6aaa2a3..e8cdff5 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -139,6 +139,11 @@ enum {
 	RTM_GETNSID = 90,
 #define RTM_GETNSID RTM_GETNSID
 
+	RTM_NEWSTATS = 92,
+#define RTM_NEWSTATS RTM_NEWSTATS
+	RTM_GETSTATS = 94,
+#define RTM_GETSTATS RTM_GETSTATS
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index a90e52c..95f80fc 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -838,3 +838,28 @@ int __parse_rtattr_nested_compat(struct rtattr *tb[], int max, struct rtattr *rt
 	memset(tb, 0, sizeof(struct rtattr *) * (max + 1));
 	return 0;
 }
+
+int rtnl_stats_dump_request(struct rtnl_handle *rth, __u32 filt_mask)
+{
+	struct {
+		struct nlmsghdr nlh;
+		struct if_stats_msg ifsm;
+	} req = {
+		.nlh.nlmsg_type = RTM_GETSTATS,
+		.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST,
+		.nlh.nlmsg_pid = 0,
+		.ifsm.family = AF_UNSPEC,
+		.ifsm.ifindex = 0,
+		.ifsm.filter_mask = filt_mask,
+	};
+
+	if (!filt_mask) {
+		perror("invalid stats filter mask");
+		return -1;
+	}
+
+	req.nlh.nlmsg_seq = rth->dump = ++rth->seq,
+	req.nlh.nlmsg_len = sizeof(req);
+
+	return send(rth->fd, (void *)&req, sizeof(req), 0);
+}
diff --git a/misc/ifstat.c b/misc/ifstat.c
index abbb4e7..bf9b9fa 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -35,6 +35,8 @@
 
 #include <SNAPSHOT.h>
 
+#include "utils.h"
+
 int dump_zeros;
 int reset_history;
 int ignore_history;
@@ -49,6 +51,8 @@ double W;
 char **patterns;
 int npatterns;
 
+struct rtnl_handle rth;
+
 char info_source[128];
 int source_mismatch;
 
@@ -58,9 +62,9 @@ struct ifstat_ent {
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
@@ -109,32 +113,29 @@ static int match(const char *id)
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
+	parse_rtattr(tb, IFLA_STATS_MAX, IFLA_RTA_STATS(ifsm), len);
+	if (!tb[IFLA_STATS_LINK_64])
 		return 0;
 
 	n = malloc(sizeof(*n));
 	if (!n)
 		abort();
-	n->ifindex = ifi->ifi_index;
-	n->name = strdup(RTA_DATA(tb[IFLA_IFNAME]));
-	memcpy(&n->ival, RTA_DATA(tb[IFLA_STATS]), sizeof(n->ival));
+	n->ifindex = ifsm->ifindex;
+	n->name = strdup(ll_index_to_name(ifsm->ifindex));
+	memcpy(&n->ival, RTA_DATA(tb[IFLA_STATS_LINK_64]), sizeof(n->ival));
 	memset(&n->rate, 0, sizeof(n->rate));
 	for (i = 0; i < MAXS; i++)
 		n->val[i] = n->ival[i];
@@ -151,7 +152,9 @@ static void load_info(void)
 	if (rtnl_open(&rth, 0) < 0)
 		exit(1);
 
-	if (rtnl_wilddump_request(&rth, AF_INET, RTM_GETLINK) < 0) {
+	ll_init_map(&rth);
+
+	if (rtnl_stats_dump_request(&rth, IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_64)) < 0) {
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
-- 
1.9.1

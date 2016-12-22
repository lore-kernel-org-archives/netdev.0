From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 v3 2/4] ifstat: Add extended statistics to ifstat
Date: Thu, 22 Dec 2016 18:23:13 +0200
Message-ID: <1482423795-6531-3-git-send-email-nogahf@mellanox.com>
References: <1482423795-6531-1-git-send-email-nogahf@mellanox.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        roszenrami@gmail.com, ogerlitz@mellanox.com, jiri@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, idosch@mellanox.com,
        Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60667 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S966220AbcLVQVN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 11:21:13 -0500
In-Reply-To: <1482423795-6531-1-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extended stats are part of the RTM_GETSTATS method. This patch adds them
to ifstat.
While extended stats can come in many forms, we support only the
rtnl_link_stats64 struct for them (which is the 64 bits version of struct
rtnl_link_stats).
We support stats in the main nesting level, or one lower.
The extension can be called by its name or any shorten of it. If there is
more than one matched, the first one will be picked.

To get the extended stats the flag -x <stats type> is used.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 misc/ifstat.c | 161 ++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 146 insertions(+), 15 deletions(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index 5bcbcc8..ce666b3 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -34,6 +34,7 @@
 #include "libnetlink.h"
 #include "json_writer.h"
 #include "SNAPSHOT.h"
+#include "utils.h"
 
 int dump_zeros;
 int reset_history;
@@ -48,17 +49,21 @@ int pretty;
 double W;
 char **patterns;
 int npatterns;
+bool is_extended;
+int filter_type;
+int sub_type;
 
 char info_source[128];
 int source_mismatch;
 
 #define MAXS (sizeof(struct rtnl_link_stats)/sizeof(__u32))
+#define NO_SUB_TYPE 0xffff
 
 struct ifstat_ent {
 	struct ifstat_ent	*next;
 	char			*name;
 	int			ifindex;
-	unsigned long long	val[MAXS];
+	__u64			val[MAXS];
 	double			rate[MAXS];
 	__u32			ival[MAXS];
 };
@@ -106,6 +111,48 @@ static int match(const char *id)
 	return 0;
 }
 
+static int get_nlmsg_extended(const struct sockaddr_nl *who,
+			      struct nlmsghdr *m, void *arg)
+{
+	struct if_stats_msg *ifsm = NLMSG_DATA(m);
+	struct rtattr *tb[IFLA_STATS_MAX+1];
+	int len = m->nlmsg_len;
+	struct ifstat_ent *n;
+
+	if (m->nlmsg_type != RTM_NEWSTATS)
+		return 0;
+
+	len -= NLMSG_LENGTH(sizeof(*ifsm));
+	if (len < 0)
+		return -1;
+
+	parse_rtattr(tb, IFLA_STATS_MAX, IFLA_STATS_RTA(ifsm), len);
+	if (tb[filter_type] == NULL)
+		return 0;
+
+	n = malloc(sizeof(*n));
+	if (!n)
+		abort();
+
+	n->ifindex = ifsm->ifindex;
+	n->name = strdup(ll_index_to_name(ifsm->ifindex));
+
+	if (sub_type == NO_SUB_TYPE) {
+		memcpy(&n->val, RTA_DATA(tb[filter_type]), sizeof(n->val));
+	} else {
+		struct rtattr *attr;
+
+		attr = parse_rtattr_one_nested(sub_type, tb[filter_type]);
+		if (attr == NULL)
+			return 0;
+		memcpy(&n->val, RTA_DATA(attr), sizeof(n->val));
+	}
+	memset(&n->rate, 0, sizeof(n->rate));
+	n->next = kern_db;
+	kern_db = n;
+	return 0;
+}
+
 static int get_nlmsg(const struct sockaddr_nl *who,
 		     struct nlmsghdr *m, void *arg)
 {
@@ -147,18 +194,34 @@ static void load_info(void)
 {
 	struct ifstat_ent *db, *n;
 	struct rtnl_handle rth;
+	__u32 filter_mask;
 
 	if (rtnl_open(&rth, 0) < 0)
 		exit(1);
 
-	if (rtnl_wilddump_request(&rth, AF_INET, RTM_GETLINK) < 0) {
-		perror("Cannot send dump request");
-		exit(1);
-	}
+	if (is_extended) {
+		ll_init_map(&rth);
+		filter_mask = IFLA_STATS_FILTER_BIT(filter_type);
+		if (rtnl_wilddump_stats_req_filter(&rth, AF_UNSPEC, RTM_GETSTATS,
+						   filter_mask) < 0) {
+			perror("Cannot send dump request");
+			exit(1);
+		}
 
-	if (rtnl_dump_filter(&rth, get_nlmsg, NULL) < 0) {
-		fprintf(stderr, "Dump terminated\n");
-		exit(1);
+		if (rtnl_dump_filter(&rth, get_nlmsg_extended, NULL) < 0) {
+			fprintf(stderr, "Dump terminated\n");
+			exit(1);
+		}
+	} else {
+		if (rtnl_wilddump_request(&rth, AF_INET, RTM_GETLINK) < 0) {
+			perror("Cannot send dump request");
+			exit(1);
+		}
+
+		if (rtnl_dump_filter(&rth, get_nlmsg, NULL) < 0) {
+			fprintf(stderr, "Dump terminated\n");
+			exit(1);
+		}
 	}
 
 	rtnl_close(&rth);
@@ -553,10 +616,17 @@ static void update_db(int interval)
 				}
 				for (i = 0; i < MAXS; i++) {
 					double sample;
-					unsigned long incr = h1->ival[i] - n->ival[i];
+					__u64 incr;
+
+					if (is_extended) {
+						incr = h1->val[i] - n->val[i];
+						n->val[i] = h1->val[i];
+					} else {
+						incr = (__u32) (h1->ival[i] - n->ival[i]);
+						n->val[i] += incr;
+						n->ival[i] = h1->ival[i];
+					}
 
-					n->val[i] += incr;
-					n->ival[i] = h1->ival[i];
 					sample = (double)(incr*1000)/interval;
 					if (interval >= scan_interval) {
 						n->rate[i] += W*(sample-n->rate[i]);
@@ -656,6 +726,48 @@ static int verify_forging(int fd)
 	return -1;
 }
 
+static void xstat_usage(void)
+{
+	fprintf(stderr,
+"Usage: ifstat supported xstats:\n");
+}
+
+struct extended_stats_options_t {
+	char *name;
+	int id;
+	int sub_type;
+};
+
+/* Note: if one xstat name is subset of another, it should be before it in this
+ * list.
+ * Name length must be under 64 chars.
+ */
+static const struct extended_stats_options_t extended_stats_options[] = {
+};
+
+static bool get_filter_type(char *name)
+{
+	int name_len;
+	int i;
+
+	name_len = strlen(name);
+	for (i = 0; i < ARRAY_SIZE(extended_stats_options); i++) {
+		const struct extended_stats_options_t *xstat;
+
+		xstat = &extended_stats_options[i];
+		if (strncmp(name, xstat->name, name_len) == 0) {
+			filter_type = xstat->id;
+			sub_type = xstat->sub_type;
+			strcpy(name, xstat->name);
+			return true;
+		}
+	}
+
+	fprintf(stderr, "invalid ifstat extension %s\n", name);
+	xstat_usage();
+	return false;
+}
+
 static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
@@ -673,7 +785,8 @@ static void usage(void)
 "   -s, --noupdate       don't update history\n"
 "   -t, --interval=SECS  report average over the last SECS\n"
 "   -V, --version        output version information\n"
-"   -z, --zeros          show entries with zero activity\n");
+"   -z, --zeros          show entries with zero activity\n"
+"   -x, --extended=TYPE  show extended stats of TYPE\n");
 
 	exit(-1);
 }
@@ -691,18 +804,22 @@ static const struct option longopts[] = {
 	{ "interval", 1, 0, 't' },
 	{ "version", 0, 0, 'V' },
 	{ "zeros", 0, 0, 'z' },
+	{ "extended", 1, 0, 'x'},
 	{ 0 }
 };
 
+
 int main(int argc, char *argv[])
 {
 	char hist_name[128];
 	struct sockaddr_un sun;
 	FILE *hist_fp = NULL;
+	char stats_type[64];
 	int ch;
 	int fd;
 
-	while ((ch = getopt_long(argc, argv, "hjpvVzrnasd:t:e",
+	is_extended = false;
+	while ((ch = getopt_long(argc, argv, "hjpvVzrnasd:t:ex:",
 			longopts, NULL)) != EOF) {
 		switch (ch) {
 		case 'z':
@@ -743,6 +860,11 @@ int main(int argc, char *argv[])
 				exit(-1);
 			}
 			break;
+		case 'x':
+			is_extended = true;
+			memset(stats_type, 0, 64);
+			strncpy(stats_type, optarg, 63);
+			break;
 		case 'v':
 		case 'V':
 			printf("ifstat utility, iproute2-ss%s\n", SNAPSHOT);
@@ -757,6 +879,10 @@ int main(int argc, char *argv[])
 	argc -= optind;
 	argv += optind;
 
+	if (is_extended)
+		if (!get_filter_type(stats_type))
+			exit(-1);
+
 	sun.sun_family = AF_UNIX;
 	sun.sun_path[0] = 0;
 	sprintf(sun.sun_path+1, "ifstat%d", getuid());
@@ -795,8 +921,13 @@ int main(int argc, char *argv[])
 		snprintf(hist_name, sizeof(hist_name),
 			 "%s", getenv("IFSTAT_HISTORY"));
 	else
-		snprintf(hist_name, sizeof(hist_name),
-			 "%s/.ifstat.u%d", P_tmpdir, getuid());
+		if (!is_extended)
+			snprintf(hist_name, sizeof(hist_name),
+				 "%s/.ifstat.u%d", P_tmpdir, getuid());
+		else
+			snprintf(hist_name, sizeof(hist_name),
+				 "%s/.%s_ifstat.u%d", P_tmpdir, stats_type,
+				 getuid());
 
 	if (reset_history)
 		unlink(hist_name);
-- 
2.4.3

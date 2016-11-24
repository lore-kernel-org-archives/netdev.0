From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 2/3] ifstat: Add extended statistics to ifstat
Date: Thu, 24 Nov 2016 16:12:39 +0200
Message-ID: <1479996760-61271-3-git-send-email-nogahf@mellanox.com>
References: <1479996760-61271-1-git-send-email-nogahf@mellanox.com>
Cc: eladr@mellanox.com, yotamg@mellanox.com, jiri@mellanox.com,
        idosch@mellanox.com, ogerlitz@mellanox.com,
        Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43437 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S965566AbcKXOLg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 09:11:36 -0500
In-Reply-To: <1479996760-61271-1-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add extended stats option for ifstat. It supports stats that are in the
nesting level as the "normal" stats or one lower, as long as they are in
the same struct type as the "normal" stats.
Every extension is unaware of data from other extension and is being
presented by itself.
The extension can be called by its name or any shorten of it. If there is
more then one matched, the first one will be picked.

To get the extended stats the flag -x <stats type> is used.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 misc/ifstat.c | 88 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 81 insertions(+), 7 deletions(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index 25a8fc1..90aeeaa 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -49,11 +49,14 @@ int pretty;
 double W;
 char **patterns;
 int npatterns;
+int filter_type;
+int sub_type;
 
 char info_source[128];
 int source_mismatch;
 
 #define MAXS (sizeof(struct rtnl_link_stats64)/sizeof(__u64))
+#define NO_SUB_TYPE 0xffff
 
 struct ifstat_ent {
 	struct ifstat_ent	*next;
@@ -124,7 +127,7 @@ static int get_nlmsg(const struct sockaddr_nl *who,
 		return -1;
 
 	parse_rtattr(tb, IFLA_STATS_MAX, IFLA_STATS_RTA(ifsm), len);
-	if (tb[IFLA_STATS_LINK_64] == NULL)
+	if (tb[filter_type] == NULL)
 		return 0;
 
 	n = malloc(sizeof(*n));
@@ -133,7 +136,17 @@ static int get_nlmsg(const struct sockaddr_nl *who,
 
 	n->ifindex = ifsm->ifindex;
 	n->name = strdup(ll_index_to_name(ifsm->ifindex));
-	memcpy(&n->ival, RTA_DATA(tb[IFLA_STATS_LINK_64]), sizeof(n->ival));
+
+	if (sub_type == NO_SUB_TYPE) {
+		memcpy(&n->ival, RTA_DATA(tb[filter_type]), sizeof(n->ival));
+	} else {
+		struct rtattr *attr;
+
+		attr = parse_rtattr_one_nested(sub_type, tb[filter_type]);
+		if (attr == NULL)
+			return 0;
+		memcpy(&n->ival, RTA_DATA(attr), sizeof(n->ival));
+	}
 	memset(&n->rate, 0, sizeof(n->rate));
 	for (i = 0; i < MAXS; i++)
 		n->val[i] = n->ival[i];
@@ -152,7 +165,7 @@ static void load_info(void)
 		exit(1);
 
 	ll_init_map(&rth);
-	filt_mask = IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_64);
+	filt_mask = IFLA_STATS_FILTER_BIT(filter_type);
 	if (rtnl_wilddump_stats_req_filter(&rth, AF_UNSPEC, RTM_GETSTATS,
 					   filt_mask) < 0) {
 		perror("Cannot send dump request");
@@ -659,6 +672,50 @@ static int verify_forging(int fd)
 	return -1;
 }
 
+static void xstat_usage(void)
+{
+	fprintf(stderr,
+"Usage: ifstat supported xstats:\n");
+
+}
+
+struct extended_stats_options_t {
+	char *name;
+	int id;
+	int sub_type;
+};
+
+/* Note: if one xstat name in subset of another, it should be before it in this
+ * list. Therefore the default "" option must always be first.
+ * Name length must be under 64 chars.
+ */
+static const struct extended_stats_options_t extended_stats_options[] = {
+	{"", IFLA_STATS_LINK_64, NO_SUB_TYPE},
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
+	printf("invalid ifstat extension %s\n", name);
+	xstat_usage();
+	return false;
+}
+
 static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
@@ -676,7 +733,8 @@ static void usage(void)
 "   -s, --noupdate	don\'t update history\n"
 "   -t, --interval=SECS	report average over the last SECS\n"
 "   -V, --version	output version information\n"
-"   -z, --zeros		show entries with zero activity\n");
+"   -z, --zeros		show entries with zero activity\n"
+"   -x, --extended=TYPE	show extended stats of TYPE\n");
 
 	exit(-1);
 }
@@ -694,18 +752,22 @@ static const struct option longopts[] = {
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
+	memset(stats_type, 0, 128);
+	while ((ch = getopt_long(argc, argv, "hjpvVzrnasd:t:ex:",
 			longopts, NULL)) != EOF) {
 		switch (ch) {
 		case 'z':
@@ -746,6 +808,9 @@ int main(int argc, char *argv[])
 				exit(-1);
 			}
 			break;
+		case 'x':
+			strncpy(stats_type, optarg, 63);
+			break;
 		case 'v':
 		case 'V':
 			printf("ifstat utility, iproute2-ss%s\n", SNAPSHOT);
@@ -760,6 +825,9 @@ int main(int argc, char *argv[])
 	argc -= optind;
 	argv += optind;
 
+	if (!get_filter_type(stats_type))
+		exit(-1);
+
 	sun.sun_family = AF_UNIX;
 	sun.sun_path[0] = 0;
 	sprintf(sun.sun_path+1, "ifstat%d", getuid());
@@ -798,8 +866,14 @@ int main(int argc, char *argv[])
 		snprintf(hist_name, sizeof(hist_name),
 			 "%s", getenv("IFSTAT_HISTORY"));
 	else
-		snprintf(hist_name, sizeof(hist_name),
-			 "%s/.ifstat.u%d", P_tmpdir, getuid());
+
+		if (strlen(stats_type) == 0)
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

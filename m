From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET 00/04]: Increase number of possible routing tables
Date: Mon, 03 Jul 2006 11:23:29 +0200
Message-ID: <44A8E211.4090005@trash.net>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020609020205010300090805"
Cc: davem@davemloft.net, greearb@candelatech.com,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:27094 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751003AbWGCJXc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 05:23:32 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060703075259.6286.67397.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020609020205010300090805
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> I took on Ben's challenge to increase the number of possible routing tables,
> these are the resulting patches.
> 
> The table IDs are changed to 32 bit values and are contained in a new netlink
> routing attribute. For compatibility rtm_table in struct rtmsg can still be
> used to access the first 255 tables and contains the low 8 bit of the table
> ID in case of dumps. Unfortunately there are no invalid values for rtm_table,
> so the best userspace can do in case of a new iproute version that tries to
> access tables > 255 on an old kernel is to use RTM_UNSPEC (0) for rtm_table,
> which will make the kernel allocate an empty table instead of silently adding
> routes to a more or less random table. The iproute patch will follow shortly.

Actually that last part wasn't entirely true. The last couple of
releases of the kernel include the inet_check_attr function,
which (unwillingly) breaks with the tradition of ignoring
unknown attributes and signals an error on receiving the RTA_TABLE
attribute. So the iproute patch only includes the RTA_TABLE
attribute when the table ID is > 255, in which case rtm_table
is set to RT_TABLE_UNSPEC. Old kernels will still have the
behaviour I described above. The patch has been tested to
behave as expected on both patched and unpatched kernels.


--------------020609020205010300090805
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 5e33a20..7573c62 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -238,9 +238,8 @@ enum rt_class_t
 	RT_TABLE_DEFAULT=253,
 	RT_TABLE_MAIN=254,
 	RT_TABLE_LOCAL=255,
-	__RT_TABLE_MAX
 };
-#define RT_TABLE_MAX (__RT_TABLE_MAX - 1)
+#define RT_TABLE_MAX 0xFFFFFFFF
 
 
 
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
index a43c09e..4ebe617 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -75,7 +75,8 @@ static void usage(void)
 
 static struct
 {
-	int tb;
+	__u32 tb;
+	int cloned;
 	int flushed;
 	char *flushb;
 	int flushp;
@@ -125,6 +126,7 @@ int print_route(const struct sockaddr_nl
 	inet_prefix prefsrc;
 	inet_prefix via;
 	int host_len = -1;
+	__u32 table;
 	SPRINT_BUF(b1);
 	
 
@@ -151,27 +153,23 @@ int print_route(const struct sockaddr_nl
 		host_len = 80;
 
 	if (r->rtm_family == AF_INET6) {
+		if (filter.cloned) {
+			if (!(r->rtm_flags&RTM_F_CLONED))
+				return 0;
+		}
 		if (filter.tb) {
-			if (filter.tb < 0) {
-				if (!(r->rtm_flags&RTM_F_CLONED))
-					return 0;
-			} else {
-				if (r->rtm_flags&RTM_F_CLONED)
+			if (r->rtm_flags&RTM_F_CLONED)
+				return 0;
+			if (filter.tb == RT_TABLE_LOCAL) {
+				if (r->rtm_type != RTN_LOCAL)
 					return 0;
-				if (filter.tb == RT_TABLE_LOCAL) {
-					if (r->rtm_type != RTN_LOCAL)
-						return 0;
-				} else if (filter.tb == RT_TABLE_MAIN) {
-					if (r->rtm_type == RTN_LOCAL)
-						return 0;
-				} else {
+			} else if (filter.tb == RT_TABLE_MAIN) {
+				if (r->rtm_type == RTN_LOCAL)
 					return 0;
-				}
+			} else {
+				return 0;
 			}
 		}
-	} else {
-		if (filter.tb > 0 && filter.tb != r->rtm_table)
-			return 0;
 	}
 	if ((filter.protocol^r->rtm_protocol)&filter.protocolmask)
 		return 0;
@@ -225,6 +223,10 @@ int print_route(const struct sockaddr_nl
 			memcpy(&prefsrc.data, RTA_DATA(tb[RTA_PREFSRC]), host_len/8);
 	}
 
+	table = rtm_get_table(r, tb);
+	if (r->rtm_family == AF_INET && filter.tb > 0 && filter.tb != table)
+		return 0;
+
 	if (filter.rdst.family && inet_addr_match(&dst, &filter.rdst, filter.rdst.bitlen))
 		return 0;
 	if (filter.mdst.family && filter.mdst.bitlen >= 0 &&
@@ -354,8 +356,8 @@ int print_route(const struct sockaddr_nl
 		fprintf(fp, "dev %s ", ll_index_to_name(*(int*)RTA_DATA(tb[RTA_OIF])));
 
 	if (!(r->rtm_flags&RTM_F_CLONED)) {
-		if (r->rtm_table != RT_TABLE_MAIN && !filter.tb)
-			fprintf(fp, " table %s ", rtnl_rttable_n2a(r->rtm_table, b1, sizeof(b1)));
+		if (table != RT_TABLE_MAIN && !filter.tb)
+			fprintf(fp, " table %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
 		if (r->rtm_protocol != RTPROT_BOOT && filter.protocolmask != -1)
 			fprintf(fp, " proto %s ", rtnl_rtprot_n2a(r->rtm_protocol, b1, sizeof(b1)));
 		if (r->rtm_scope != RT_SCOPE_UNIVERSE && filter.scopemask != -1)
@@ -840,7 +842,12 @@ #endif
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
@@ -1022,7 +1029,7 @@ static int iproute_list_or_flush(int arg
 			filter.tb = tid;
 		} else if (matches(*argv, "cached") == 0 ||
 			   matches(*argv, "cloned") == 0) {
-			filter.tb = -1;
+			filter.cloned = 1;
 		} else if (strcmp(*argv, "tos") == 0 ||
 			   matches(*argv, "dsfield") == 0) {
 			__u32 tos;
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
index 05046c2..2ff984a 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -23,6 +23,51 @@ #include <linux/rtnetlink.h>
 
 #include "rt_names.h"
 
+struct rtnl_hash_entry {
+	struct rtnl_hash_entry *next;
+	unsigned int		id;
+	char *			name;
+};
+
+static void
+rtnl_hash_initialize(char *file, struct rtnl_hash_entry **hash, int size)
+{
+	struct rtnl_hash_entry *entry;
+	char buf[512];
+	FILE *fp;
+
+	fp = fopen(file, "r");
+	if (!fp)
+		return;
+	while (fgets(buf, sizeof(buf), fp)) {
+		char *p = buf;
+		int id;
+		char namebuf[512];
+
+		while (*p == ' ' || *p == '\t')
+			p++;
+		if (*p == '#' || *p == '\n' || *p == 0)
+			continue;
+		if (sscanf(p, "0x%x %s\n", &id, namebuf) != 2 &&
+		    sscanf(p, "0x%x %s #", &id, namebuf) != 2 &&
+		    sscanf(p, "%d %s\n", &id, namebuf) != 2 &&
+		    sscanf(p, "%d %s #", &id, namebuf) != 2) {
+			fprintf(stderr, "Database %s is corrupted at %s\n",
+				file, p);
+			return;
+		}
+
+		if (id<0)
+			continue;
+		entry = malloc(sizeof(*entry));
+		entry->id   = id;
+		entry->name = strdup(namebuf);
+		entry->next = hash[id & (size - 1)];
+		hash[id & (size - 1)] = entry;
+	}
+	fclose(fp);
+}
+
 static void rtnl_tab_initialize(char *file, char **tab, int size)
 {
 	char buf[512];
@@ -57,7 +102,6 @@ static void rtnl_tab_initialize(char *fi
 	fclose(fp);
 }
 
-
 static char * rtnl_rtprot_tab[256] = {
 	[RTPROT_UNSPEC] = "none",
 	[RTPROT_REDIRECT] ="redirect",
@@ -266,9 +310,14 @@ int rtnl_rtrealm_a2n(__u32 *id, char *ar
 }
 
 
+static struct rtnl_hash_entry dflt_table_entry  = { .id = 253, .name = "default" };
+static struct rtnl_hash_entry main_table_entry  = { .id = 254, .name = "main" };
+static struct rtnl_hash_entry local_table_entry = { .id = 255, .name = "local" };
 
-static char * rtnl_rttable_tab[256] = {
-	"unspec",
+static struct rtnl_hash_entry * rtnl_rttable_hash[256] = {
+	[253] = &dflt_table_entry,
+	[254] = &main_table_entry,
+	[255] = &local_table_entry,
 };
 
 static int rtnl_rttable_init;
@@ -276,26 +325,26 @@ static int rtnl_rttable_init;
 static void rtnl_rttable_initialize(void)
 {
 	rtnl_rttable_init = 1;
-	rtnl_rttable_tab[255] = "local";
-	rtnl_rttable_tab[254] = "main";
-	rtnl_rttable_tab[253] = "default";
-	rtnl_tab_initialize("/etc/iproute2/rt_tables",
-			    rtnl_rttable_tab, 256);
+	rtnl_hash_initialize("/etc/iproute2/rt_tables",
+			     rtnl_rttable_hash, 256);
 }
 
-char * rtnl_rttable_n2a(int id, char *buf, int len)
+char * rtnl_rttable_n2a(__u32 id, char *buf, int len)
 {
-	if (id<0 || id>=256) {
-		snprintf(buf, len, "%d", id);
+	struct rtnl_hash_entry *entry;
+
+	if (id >= RT_TABLE_MAX) {
+		snprintf(buf, len, "%u", id);
 		return buf;
 	}
-	if (!rtnl_rttable_tab[id]) {
-		if (!rtnl_rttable_init)
-			rtnl_rttable_initialize();
-	}
-	if (rtnl_rttable_tab[id])
-		return rtnl_rttable_tab[id];
-	snprintf(buf, len, "%d", id);
+	if (!rtnl_rttable_init)
+		rtnl_rttable_initialize();
+	entry = rtnl_rttable_hash[id & 255];
+	while (entry && entry->id != id)
+		entry = entry->next;
+	if (entry)
+		return entry->name;
+	snprintf(buf, len, "%u", id);
 	return buf;
 }
 
@@ -303,8 +352,9 @@ int rtnl_rttable_a2n(__u32 *id, char *ar
 {
 	static char *cache = NULL;
 	static unsigned long res;
+	struct rtnl_hash_entry *entry;
 	char *end;
-	int i;
+	__u32 i;
 
 	if (cache && strcmp(cache, arg) == 0) {
 		*id = res;
@@ -315,9 +365,11 @@ int rtnl_rttable_a2n(__u32 *id, char *ar
 		rtnl_rttable_initialize();
 
 	for (i=0; i<256; i++) {
-		if (rtnl_rttable_tab[i] &&
-		    strcmp(rtnl_rttable_tab[i], arg) == 0) {
-			cache = rtnl_rttable_tab[i];
+		entry = rtnl_rttable_hash[i];
+		while (entry && strcmp(entry->name, arg))
+			entry = entry->next;
+		if (entry) {
+			cache = entry->name;
 			res = i;
 			*id = res;
 			return 0;
@@ -325,7 +377,7 @@ int rtnl_rttable_a2n(__u32 *id, char *ar
 	}
 
 	i = strtoul(arg, &end, 0);
-	if (!end || end == arg || *end || i > 255)
+	if (!end || end == arg || *end || i > RT_TABLE_MAX)
 		return -1;
 	*id = i;
 	return 0;

--------------020609020205010300090805--

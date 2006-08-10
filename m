From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 02/03]: Use hash for routing table name cache
Date: Fri, 11 Aug 2006 00:14:50 +0200 (MEST)
Message-ID: <20060810221450.9060.49304.sendpatchset@localhost.localdomain>
References: <20060810221447.9060.5563.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:28388 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751206AbWHJWOw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 18:14:52 -0400
To: shemminger@osdl.org
In-Reply-To: <20060810221447.9060.5563.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Use hash for routing table name cache

Use a hash for routing table name cache instead of the fixed size array.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ccd621fbb5faa91a98479e9492baee525c6f10c0
tree e4e1416406b5ed252b3b1a91efc3d8caadbf1bd0
parent 00d896184c5f8737269ac05264446c58133ec414
author Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 23:27:59 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 23:27:59 +0200

 lib/rt_names.c |   96 +++++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 74 insertions(+), 22 deletions(-)

diff --git a/lib/rt_names.c b/lib/rt_names.c
index 05046c2..b77ad4a 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -23,6 +23,51 @@ #include <linux/rtnetlink.h>
 
 #include "rt_names.h"
 
+struct rtnl_hash_entry {
+	struct rtnl_hash_entry *next;
+	char *			name;
+	unsigned int		id;
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
 
 char * rtnl_rttable_n2a(int id, char *buf, int len)
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
 
@@ -303,6 +352,7 @@ int rtnl_rttable_a2n(__u32 *id, char *ar
 {
 	static char *cache = NULL;
 	static unsigned long res;
+	struct rtnl_hash_entry *entry;
 	char *end;
 	int i;
 
@@ -315,17 +365,19 @@ int rtnl_rttable_a2n(__u32 *id, char *ar
 		rtnl_rttable_initialize();
 
 	for (i=0; i<256; i++) {
-		if (rtnl_rttable_tab[i] &&
-		    strcmp(rtnl_rttable_tab[i], arg) == 0) {
-			cache = rtnl_rttable_tab[i];
-			res = i;
+		entry = rtnl_rttable_hash[i];
+		while (entry && strcmp(entry->name, arg))
+			entry = entry->next;
+		if (entry) {
+			cache = entry->name;
+			res = entry->id;
 			*id = res;
 			return 0;
 		}
 	}
 
 	i = strtoul(arg, &end, 0);
-	if (!end || end == arg || *end || i > 255)
+	if (!end || end == arg || *end || i > RT_TABLE_MAX)
 		return -1;
 	*id = i;
 	return 0;

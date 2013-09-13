From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC] iproute2: add json output to nstat
Date: Fri, 13 Sep 2013 10:35:19 -0700
Message-ID: <20130913103519.3d64e8e3@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:48750 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab3IMRfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 13:35:23 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so2813180pab.15
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 10:35:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New command line flag to output statistics in JSON format.
In our envrionment, we have scripts that parse output of commands.
It is better to use a format supported by existing parsers.

If this is popular, will add similar flags to ip and tc commands.

---
 misc/nstat.c |   46 ++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 40 insertions(+), 6 deletions(-)

diff --git a/misc/nstat.c b/misc/nstat.c
index b685978..5a4cfe9 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -33,6 +33,7 @@ int dump_zeros = 0;
 int reset_history = 0;
 int ignore_history = 0;
 int no_output = 0;
+int json_output = 0;
 int no_update = 0;
 int scan_interval = 0;
 int time_constant = 0;
@@ -255,11 +256,17 @@ static void load_netstat(void)
 	}
 }
 
+
 static void dump_kern_db(FILE *fp, int to_hist)
 {
 	struct nstat_ent *n, *h;
+	const char *eol = "\n";
+
 	h = hist_db;
-	fprintf(fp, "#%s\n", info_source);
+	if (json_output)
+		fprintf(fp, "{ \"%s\": [", info_source);
+	else
+		fprintf(fp, "#%s\n", info_source);
 	for (n=kern_db; n; n=n->next) {
 		unsigned long long val = n->val;
 		if (!dump_zeros && !val && !n->rate)
@@ -276,15 +283,30 @@ static void dump_kern_db(FILE *fp, int to_hist)
 				}
 			}
 		}
-		fprintf(fp, "%-32s%-16llu%6.1f\n", n->id, val, n->rate);
+
+		if (json_output) {
+			fprintf(fp, "%s    { \"id\":\"%s\", \"val\":%llu,"
+				" \"rate\":%.1f }",
+				eol, n->id, val, n->rate);
+			eol = ",\n";
+		} else
+			fprintf(fp, "%-32s%-16llu%6.1f\n", n->id, val, n->rate);
 	}
+	if (json_output)
+		fprintf(fp, "\n] }\n");
 }
 
 static void dump_incr_db(FILE *fp)
 {
 	struct nstat_ent *n, *h;
+	const char *eol = "\n";
+
 	h = hist_db;
-	fprintf(fp, "#%s\n", info_source);
+	if (json_output)
+		fprintf(fp, "{ \"%s\": [", info_source);
+	else
+		fprintf(fp, "#%s\n", info_source);
+
 	for (n=kern_db; n; n=n->next) {
 		int ovfl = 0;
 		unsigned long long val = n->val;
@@ -304,9 +326,18 @@ static void dump_incr_db(FILE *fp)
 			continue;
 		if (!match(n->id))
 			continue;
-		fprintf(fp, "%-32s%-16llu%6.1f%s\n", n->id, val,
-			n->rate, ovfl?" (overflow)":"");
+
+		if (json_output) {
+			fprintf(fp, "%s    { \"id\":\"%s\", \"val\":%llu,"
+				" \"rate\":%.1f, \"overflow\":%d }",
+				eol, n->id, val, n->rate, ovfl);
+			eol = ",\n";
+		} else
+			fprintf(fp, "%-32s%-16llu%6.1f%s\n", n->id, val,
+				n->rate, ovfl?" (overflow)":"");
 	}
+	if (json_output)
+		fprintf(fp, "\n] }\n");
 }
 
 static int children;
@@ -451,7 +482,7 @@ int main(int argc, char *argv[])
 	int ch;
 	int fd;
 
-	while ((ch = getopt(argc, argv, "h?vVzrnasd:t:")) != EOF) {
+	while ((ch = getopt(argc, argv, "h?vVzrnasd:t:j")) != EOF) {
 		switch(ch) {
 		case 'z':
 			dump_zeros = 1;
@@ -478,6 +509,9 @@ int main(int argc, char *argv[])
 				exit(-1);
 			}
 			break;
+		case 'j':
+			json_output = 1;
+			break;
 		case 'v':
 		case 'V':
 			printf("nstat utility, iproute2-ss%s\n", SNAPSHOT);
-- 
1.7.10.4

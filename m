From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 24/51] ifstat, nstat: Check fdopen() return value
Date: Sat, 12 Aug 2017 14:04:43 +0200
Message-ID: <20170812120510.28750-25-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54511 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752092AbdHLMKn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:10:43 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent passing NULL FILE pointer to fgets() later.

Fix both tools in a single patch since the code changes are basically
identical.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ifstat.c | 16 +++++++++++-----
 misc/nstat.c  | 16 +++++++++++-----
 2 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index 8fa354265a9a1..6c8cfa0bd94f5 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -988,12 +988,18 @@ int main(int argc, char *argv[])
 	    && verify_forging(fd) == 0) {
 		FILE *sfp = fdopen(fd, "r");
 
-		load_raw_table(sfp);
-		if (hist_db && source_mismatch) {
-			fprintf(stderr, "ifstat: history is stale, ignoring it.\n");
-			hist_db = NULL;
+		if (!sfp) {
+			fprintf(stderr, "ifstat: fdopen failed: %s\n",
+				strerror(errno));
+			close(fd);
+		} else  {
+			load_raw_table(sfp);
+			if (hist_db && source_mismatch) {
+				fprintf(stderr, "ifstat: history is stale, ignoring it.\n");
+				hist_db = NULL;
+			}
+			fclose(sfp);
 		}
-		fclose(sfp);
 	} else {
 		if (fd >= 0)
 			close(fd);
diff --git a/misc/nstat.c b/misc/nstat.c
index 1212b1f2c8128..a4dd405d43a93 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -706,12 +706,18 @@ int main(int argc, char *argv[])
 	    && verify_forging(fd) == 0) {
 		FILE *sfp = fdopen(fd, "r");
 
-		load_good_table(sfp);
-		if (hist_db && source_mismatch) {
-			fprintf(stderr, "nstat: history is stale, ignoring it.\n");
-			hist_db = NULL;
+		if (!sfp) {
+			fprintf(stderr, "nstat: fdopen failed: %s\n",
+				strerror(errno));
+			close(fd);
+		} else {
+			load_good_table(sfp);
+			if (hist_db && source_mismatch) {
+				fprintf(stderr, "nstat: history is stale, ignoring it.\n");
+				hist_db = NULL;
+			}
+			fclose(sfp);
 		}
-		fclose(sfp);
 	} else {
 		if (fd >= 0)
 			close(fd);
-- 
2.13.1

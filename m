From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v4 1/4] ifstat, nstat: Check fdopen() return value
Date: Thu, 24 Aug 2017 11:46:31 +0200
Message-ID: <20170824094634.4093-2-phil@nwl.cc>
References: <20170824094634.4093-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44813 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752220AbdHXJrM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 05:47:12 -0400
In-Reply-To: <20170824094634.4093-1-phil@nwl.cc>
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
index 1be21703bf14c..ac3eff6b870a9 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -992,12 +992,18 @@ int main(int argc, char *argv[])
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

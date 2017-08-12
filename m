From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 19/51] lib/fs: Fix and simplify make_path()
Date: Sat, 12 Aug 2017 14:04:38 +0200
Message-ID: <20170812120510.28750-20-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:34277 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752018AbdHLMJC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:09:02 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling stat() before mkdir() is racey: The entry might change in
between. Also, the call to stat() seems to exist only to check if the
directory exists already. So simply call mkdir() unconditionally and
catch only errors other than EEXIST.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/fs.c | 20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff --git a/lib/fs.c b/lib/fs.c
index 1ff881ecfcd8c..ebe05cd44e11b 100644
--- a/lib/fs.c
+++ b/lib/fs.c
@@ -102,7 +102,6 @@ out:
 int make_path(const char *path, mode_t mode)
 {
 	char *dir, *delim;
-	struct stat sbuf;
 	int rc = -1;
 
 	delim = dir = strdup(path);
@@ -120,20 +119,11 @@ int make_path(const char *path, mode_t mode)
 		if (delim)
 			*delim = '\0';
 
-		if (stat(dir, &sbuf) != 0) {
-			if (errno != ENOENT) {
-				fprintf(stderr,
-					"stat failed for %s: %s\n",
-					dir, strerror(errno));
-				goto out;
-			}
-
-			if (mkdir(dir, mode) != 0) {
-				fprintf(stderr,
-					"mkdir failed for %s: %s\n",
-					dir, strerror(errno));
-				goto out;
-			}
+		rc = mkdir(dir, mode);
+		if (mkdir(dir, mode) != 0 && errno != EEXIST) {
+			fprintf(stderr, "mkdir failed for %s: %s\n",
+				dir, strerror(errno));
+			goto out;
 		}
 
 		if (delim == NULL)
-- 
2.13.1

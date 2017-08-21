From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 6/7] lib/fs: Fix and simplify make_path()
Date: Mon, 21 Aug 2017 19:08:12 +0200
Message-ID: <20170821170813.29697-7-phil@nwl.cc>
References: <20170821170813.29697-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53353 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753961AbdHURJD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 13:09:03 -0400
In-Reply-To: <20170821170813.29697-1-phil@nwl.cc>
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
index c59ac564581d0..7083bf2e23bb7 100644
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

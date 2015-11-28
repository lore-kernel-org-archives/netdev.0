From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/5] lnstat: review lnstat_update()
Date: Sat, 28 Nov 2015 01:00:01 +0100
Message-ID: <1448668805-28074-2-git-send-email-phil@nwl.cc>
References: <1448668805-28074-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:55107 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038AbbK1AAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Nov 2015 19:00:25 -0500
In-Reply-To: <1448668805-28074-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of calling rewind() and fgets() before every call to
scan_lines(), move them into scan_lines() itself.

This should also fix compat mode, as before the second call to
scan_lines() the first line was skipped unconditionally.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/lnstat_util.c | 18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/misc/lnstat_util.c b/misc/lnstat_util.c
index 6dde7c4943271..433e992976eac 100644
--- a/misc/lnstat_util.c
+++ b/misc/lnstat_util.c
@@ -38,18 +38,22 @@
 /* Read (and summarize for SMP) the different stats vars. */
 static int scan_lines(struct lnstat_file *lf, int i)
 {
+	char buf[FGETS_BUF_SIZE];
 	int j, num_lines = 0;
 
 	for (j = 0; j < lf->num_fields; j++)
 		lf->fields[j].values[i] = 0;
 
-	while(!feof(lf->fp)) {
-		char buf[FGETS_BUF_SIZE];
+	rewind(lf->fp);
+	/* skip first line */
+	if (!lf->compat && !fgets(buf, sizeof(buf)-1, lf->fp))
+		return -1;
+
+	while(!feof(lf->fp) && fgets(buf, sizeof(buf)-1, lf->fp)) {
 		char *ptr = buf;
 
 		num_lines++;
 
-		fgets(buf, sizeof(buf)-1, lf->fp);
 		gettimeofday(&lf->last_read, NULL);
 
 		for (j = 0; j < lf->num_fields; j++) {
@@ -81,7 +85,6 @@ static int time_after(struct timeval *last,
 int lnstat_update(struct lnstat_file *lnstat_files)
 {
 	struct lnstat_file *lf;
-	char buf[FGETS_BUF_SIZE];
 	struct timeval tv;
 
 	gettimeofday(&tv, NULL);
@@ -91,11 +94,6 @@ int lnstat_update(struct lnstat_file *lnstat_files)
 			int i;
 			struct lnstat_field *lfi;
 
-			rewind(lf->fp);
-			if (!lf->compat) {
-				/* skip first line */
-				fgets(buf, sizeof(buf)-1, lf->fp);
-			}
 			scan_lines(lf, 1);
 
 			for (i = 0, lfi = &lf->fields[i];
@@ -107,8 +105,6 @@ int lnstat_update(struct lnstat_file *lnstat_files)
 				    			/ lf->interval.tv_sec;
 			}
 
-			rewind(lf->fp);
-			fgets(buf, sizeof(buf)-1, lf->fp);
 			scan_lines(lf, 0);
 		}
 	}
-- 
2.5.0

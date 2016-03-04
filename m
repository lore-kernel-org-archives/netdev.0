From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v2 03/12] ethtool.c: fix dump_regs heap corruption
Date: Thu,  3 Mar 2016 20:23:16 -0800
Message-ID: <1457065405-19049-4-git-send-email-ddecotig@gmail.com>
References: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35785 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756158AbcCDEXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 23:23:43 -0500
Received: by mail-pf0-f193.google.com with SMTP id x188so339107pfb.2
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 20:23:42 -0800 (PST)
In-Reply-To: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

The 'regs' pointer is owned by do_gregs(), but updated internally inside
dump_regs() without propagating it back to do_gregs(): later free(regs)
in do_gregs() reclaims the wrong area. This commit moves the realloc()
inside do_gregs().


Signed-off-by: David Decotigny <decot@googlers.com>
---
 ethtool.c | 46 +++++++++++++++++++++++++---------------------
 1 file changed, 25 insertions(+), 21 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 8a93dd1..c64b962 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -994,7 +994,6 @@ void dump_hex(FILE *file, const u8 *data, int len, int offset)
 }
 
 static int dump_regs(int gregs_dump_raw, int gregs_dump_hex,
-		     const char *gregs_dump_file,
 		     struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 {
 	int i;
@@ -1004,25 +1003,6 @@ static int dump_regs(int gregs_dump_raw, int gregs_dump_hex,
 		return 0;
 	}
 
-	if (gregs_dump_file) {
-		FILE *f = fopen(gregs_dump_file, "r");
-		struct stat st;
-		size_t nread;
-
-		if (!f || fstat(fileno(f), &st) < 0) {
-			fprintf(stderr, "Can't open '%s': %s\n",
-				gregs_dump_file, strerror(errno));
-			return -1;
-		}
-
-		regs = realloc(regs, sizeof(*regs) + st.st_size);
-		regs->len = st.st_size;
-		nread = fread(regs->data, regs->len, 1, f);
-		fclose(f);
-		if (1 != nread)
-			return -1;
-	}
-
 	if (!gregs_dump_hex)
 		for (i = 0; i < ARRAY_SIZE(driver_list); i++)
 			if (!strncmp(driver_list[i].name, info->driver,
@@ -2711,7 +2691,31 @@ static int do_gregs(struct cmd_context *ctx)
 		free(regs);
 		return 74;
 	}
-	if (dump_regs(gregs_dump_raw, gregs_dump_hex, gregs_dump_file,
+
+	if ((!gregs_dump_raw) && (NULL != gregs_dump_file)) {
+		/* overwrite reg values from file dump */
+		FILE *f = fopen(gregs_dump_file, "r");
+		struct stat st;
+		size_t nread;
+
+		if (!f || fstat(fileno(f), &st) < 0) {
+			fprintf(stderr, "Can't open '%s': %s\n",
+				gregs_dump_file, strerror(errno));
+			free(regs);
+			return 75;
+		}
+
+		regs = realloc(regs, sizeof(*regs) + st.st_size);
+		regs->len = st.st_size;
+		nread = fread(regs->data, regs->len, 1, f);
+		fclose(f);
+		if (1 != nread) {
+			free(regs);
+			return 75;
+		}
+        }
+
+	if (dump_regs(gregs_dump_raw, gregs_dump_hex,
 		      &drvinfo, regs) < 0) {
 		fprintf(stderr, "Cannot dump registers\n");
 		free(regs);
-- 
2.7.0.rc3.207.g0ac5344

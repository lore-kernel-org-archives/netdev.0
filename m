From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool] sfc: Omit zero values in register tables
Date: Wed, 21 Dec 2011 19:48:44 +0000
Message-ID: <1324496924.2764.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:21739 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751118Ab1LUTss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 14:48:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just pushed this change out.

Ben.
---
Some register tables on Solarflare controllers are very large and may
have only a few rows in use.  Make register dumps more readable by
omitting rows where all bits read as zero.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 sfc.c |   29 ++++++++++++++++++++---------
 1 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/sfc.c b/sfc.c
index 46a617b..3ba3da8 100644
--- a/sfc.c
+++ b/sfc.c
@@ -3777,6 +3777,15 @@ print_simple_table(unsigned revision, const struct efx_nic_reg_table *table,
 	return buf;
 }
 
+static int buf_is_zero(const u8 *buf, size_t size)
+{
+	size_t i;
+	for (i = 0; i < size; i++)
+		if (buf[i])
+			return 0;
+	return 1;
+}
+
 static const void *
 print_complex_table(unsigned revision, const struct efx_nic_reg_table *table,
 		    const void *buf)
@@ -3808,16 +3817,18 @@ print_complex_table(unsigned revision, const struct efx_nic_reg_table *table,
 	fputc('\n', stdout);
 
 	for (j = 0; j < table->rows; j++) {
-		printf("%4zu", j);
-		for (i = 0; i < table->field_count; i++) {
-			field = &table->fields[i];
-			if (!(revision >= field->min_revision &&
-			      revision <= field->max_revision))
-				continue;
-			printf(" %*s", (int)column_padding(field), "");
-			print_field_value(field, buf);
+		if (!buf_is_zero(buf, size)) {
+			printf("%4zu", j);
+			for (i = 0; i < table->field_count; i++) {
+				field = &table->fields[i];
+				if (!(revision >= field->min_revision &&
+				      revision <= field->max_revision))
+					continue;
+				printf(" %*s", (int)column_padding(field), "");
+				print_field_value(field, buf);
+			}
+			fputc('\n', stdout);
 		}
-		fputc('\n', stdout);
 		buf = (const u8 *)buf + size;
 	}
 
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v2 04/12] ethtool.c: do_seeprom checks for params & stdin sanity
Date: Thu,  3 Mar 2016 20:23:17 -0800
Message-ID: <1457065405-19049-5-git-send-email-ddecotig@gmail.com>
References: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35094 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757000AbcCDEXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 23:23:44 -0500
Received: by mail-pa0-f67.google.com with SMTP id fl4so2385341pad.2
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 20:23:43 -0800 (PST)
In-Reply-To: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

Tested:
  On qemu e1000:
  $ dd if=/dev/zero bs=2 count=5 | /mnt/ethtool -E eth0 length 9
  too much data from stdin
  $ dd if=/dev/zero bs=2 count=5 | /mnt/ethtool -E eth0 length 11
  not enough data from stdin
  $ dd if=/dev/zero bs=2 count=5 | /mnt/ethtool -E eth0 length 10
  Cannot set EEPROM data: Bad address


Signed-off-by: David Decotigny <decot@googlers.com>
---
 ethtool.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index c64b962..19f479c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2828,8 +2828,14 @@ static int do_seeprom(struct cmd_context *ctx)
 	if (seeprom_length == -1)
 		seeprom_length = drvinfo.eedump_len;
 
-	if (drvinfo.eedump_len < seeprom_offset + seeprom_length)
-		seeprom_length = drvinfo.eedump_len - seeprom_offset;
+	if (drvinfo.eedump_len < seeprom_offset + seeprom_length) {
+		if (drvinfo.eedump_len > seeprom_offset)
+			seeprom_length = drvinfo.eedump_len - seeprom_offset;
+		else {
+			fprintf(stderr, "offset & length out of bounds\n");
+			return 75;
+		}
+	}
 
 	eeprom = calloc(1, sizeof(*eeprom)+seeprom_length);
 	if (!eeprom) {
@@ -2844,8 +2850,18 @@ static int do_seeprom(struct cmd_context *ctx)
 	eeprom->data[0] = seeprom_value;
 
 	/* Multi-byte write: read input from stdin */
-	if (!seeprom_value_seen)
-		eeprom->len = fread(eeprom->data, 1, eeprom->len, stdin);
+	if (!seeprom_value_seen) {
+		if (1 != fread(eeprom->data, eeprom->len, 1, stdin)) {
+			fprintf(stderr, "not enough data from stdin\n");
+			free(eeprom);
+			return 75;
+		}
+		if ((EOF != fgetc(stdin)) || !feof(stdin)) {
+			fprintf(stderr, "too much data from stdin\n");
+			free(eeprom);
+			return 75;
+		}
+	}
 
 	err = send_ioctl(ctx, eeprom);
 	if (err < 0) {
-- 
2.7.0.rc3.207.g0ac5344

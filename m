From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v3 04/12] ethtool.c: do_seeprom checks for params & stdin sanity
Date: Fri,  4 Mar 2016 16:42:05 -0800
Message-ID: <1457138533-2417-5-git-send-email-ddecotig@gmail.com>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32841 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759441AbcCEAma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 19:42:30 -0500
Received: by mail-pf0-f195.google.com with SMTP id 63so3964270pfe.0
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 16:42:30 -0800 (PST)
In-Reply-To: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
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

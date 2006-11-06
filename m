From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3_read_partno(): possible array overrun
Date: Mon, 06 Nov 2006 12:07:31 -0800
Message-ID: <1162843651.3409.5.camel@rh4>
References: <20061106094527.GG5778@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:16147 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1752385AbWKFTOG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 14:14:06 -0500
To: "Adrian Bunk" <bunk@stusta.de>
In-Reply-To: <20061106094527.GG5778@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-11-06 at 10:45 +0100, Adrian Bunk wrote:
> The Coverity checker noted the following in drivers/net/tg3.c:
> 
> <--  snip  -->
> 
> The problem is that vpd_data[i + 2] could be vpd_data[255 + 2].

Thanks.  This should fix it:

[TG3]: Fix array overrun in tg3_read_partno().

Use proper upper limits for the loops and check for all error
conditions.

The problem was noticed by Adrian Bunk.

Signed-off-by: Michael Chan <mchan@broadcom.com> 

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8f059b7..06e4f77 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10212,7 +10212,7 @@ skip_phy_reset:
 static void __devinit tg3_read_partno(struct tg3 *tp)
 {
 	unsigned char vpd_data[256];
-	int i;
+	unsigned int i;
 	u32 magic;
 
 	if (tg3_nvram_read_swab(tp, 0x0, &magic))
@@ -10258,9 +10258,9 @@ static void __devinit tg3_read_partno(st
 	}
 
 	/* Now parse and find the part number. */
-	for (i = 0; i < 256; ) {
+	for (i = 0; i < 254; ) {
 		unsigned char val = vpd_data[i];
-		int block_end;
+		unsigned int block_end;
 
 		if (val == 0x82 || val == 0x91) {
 			i = (i + 3 +
@@ -10276,21 +10276,26 @@ static void __devinit tg3_read_partno(st
 			     (vpd_data[i + 1] +
 			      (vpd_data[i + 2] << 8)));
 		i += 3;
-		while (i < block_end) {
+
+		if (block_end > 256)
+			goto out_not_found;
+
+		while (i < (block_end - 2)) {
 			if (vpd_data[i + 0] == 'P' &&
 			    vpd_data[i + 1] == 'N') {
 				int partno_len = vpd_data[i + 2];
 
-				if (partno_len > 24)
+				i += 3;
+				if (partno_len > 24 || (partno_len + i) > 256)
 					goto out_not_found;
 
 				memcpy(tp->board_part_number,
-				       &vpd_data[i + 3],
-				       partno_len);
+				       &vpd_data[i], partno_len);
 
 				/* Success. */
 				return;
 			}
+			i += 3 + vpd_data[i + 2];
 		}
 
 		/* Part number not found. */




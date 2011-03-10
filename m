From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/7] tg3: Fix NVRAM selftest
Date: Wed, 9 Mar 2011 18:58:20 -0800
Message-ID: <1299725905-8498-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4242 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430Ab1CJC6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 21:58:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tg3 NVRAM selftest actually fails when validating the checksum of
the legacy NVRAM format.  However, the test still reported success
because the last update of the return code was a success from the NVRAM
reads.  This patch fixes the code so that the error return code defaults
to a failure status.  Then the patch fixes the reason why the checsum
validation failed.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6fd5cf0..8f71608 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10487,14 +10487,16 @@ static int tg3_test_nvram(struct tg3 *tp)
 		goto out;
 	}
 
+	err = -EIO;
+
 	/* Bootstrap checksum at offset 0x10 */
 	csum = calc_crc((unsigned char *) buf, 0x10);
-	if (csum != be32_to_cpu(buf[0x10/4]))
+	if (csum != le32_to_cpu(buf[0x10/4]))
 		goto out;
 
 	/* Manufacturing block starts at offset 0x74, checksum at 0xfc */
 	csum = calc_crc((unsigned char *) &buf[0x74/4], 0x88);
-	if (csum != be32_to_cpu(buf[0xfc/4]))
+	if (csum != le32_to_cpu(buf[0xfc/4]))
 		goto out;
 
 	err = 0;
-- 
1.7.3.4



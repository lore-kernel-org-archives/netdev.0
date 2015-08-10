From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 2/2] bnx2x: Free NVRAM lock at end of each page
Date: Mon, 10 Aug 2015 12:49:36 +0300
Message-ID: <1439200176-17662-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1439200176-17662-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:39562 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754821AbbHJJtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 05:49:49 -0400
In-Reply-To: <1439200176-17662-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Writing each 4Kb page into flash might take up-to ~100 miliseconds,
during which time management firmware cannot acces the nvram for its
own uses.

Firmware upgrade utility use the ethtool API to burn new flash images
for the device via the ethtool API, doing so by writing several page-worth
of data on each command. Such action might create problems for the
management firmware, as the nvram might not be accessible for a long time.

This patch changes the write implementation, releasing the nvram lock on
the completion of each page, allowing the management firmware time to
claim it and perform its own required actions.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 76b9052..5907c82 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1718,6 +1718,22 @@ static int bnx2x_nvram_write(struct bnx2x *bp, u32 offset, u8 *data_buf,
 		offset += sizeof(u32);
 		data_buf += sizeof(u32);
 		written_so_far += sizeof(u32);
+
+		/* At end of each 4Kb page, release nvram lock to allow MFW
+		 * chance to take it for its own use.
+		 */
+		if ((cmd_flags & MCPR_NVM_COMMAND_LAST) &&
+		    (written_so_far < buf_size)) {
+			DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
+			   "Releasing NVM lock after offset 0x%x\n",
+			   (u32)(offset - sizeof(u32)));
+			bnx2x_release_nvram_lock(bp);
+			usleep_range(1000, 2000);
+			rc = bnx2x_acquire_nvram_lock(bp);
+			if (rc)
+				return rc;
+		}
+
 		cmd_flags = 0;
 	}
 
-- 
1.9.3

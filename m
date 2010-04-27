From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/3] bnx2: Fix lost MSI-X problem on 5709 NICs.
Date: Tue, 27 Apr 2010 14:28:09 -0700
Message-ID: <1272403691-2934-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, jfeeney@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4071 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753915Ab0D0VRH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 17:17:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It has been reported that under certain heavy traffic conditions in MSI-X
mode, the driver can lose an MSI-X vector causing all packets in the
associated rx/tx ring pair to be dropped.  The problem is caused by
the chip dropping the write to unmask the MSI-X vector by the kernel
(when migrating the IRQ for example).

This can be prevented by increasing the GRC timeout value for these
register read and write operations.

Thanks to Dell for helping us debug this problem.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a257bab..4c1e51e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4759,8 +4759,12 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 		rc = bnx2_alloc_bad_rbuf(bp);
 	}
 
-	if (bp->flags & BNX2_FLAG_USING_MSIX)
+	if (bp->flags & BNX2_FLAG_USING_MSIX) {
 		bnx2_setup_msix_tbl(bp);
+		/* Prevent MSIX table reads and write from timing out */
+		REG_WR(bp, BNX2_MISC_ECO_HW_CTL,
+			BNX2_MISC_ECO_HW_CTL_LARGE_GRC_TMOUT_EN);
+	}
 
 	return rc;
 }
-- 
1.6.4.GIT



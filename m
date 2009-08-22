From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 3/8] bnx2: Close device if MTU change or ring size
 change fails.
Date: Fri, 21 Aug 2009 19:20:45 -0700
Message-ID: <1250907650-24672-3-git-send-email-mchan@broadcom.com>
References: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3672 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933141AbZHVCNm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 22:13:42 -0400
In-Reply-To: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When unable to allocate memory for new MTU or new ring size, we need
to close the device to prevent it from crashing.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 9cfd460..1d502e6 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6992,9 +6992,14 @@ bnx2_change_ring_size(struct bnx2 *bp, u32 rx, u32 tx)
 		int rc;
 
 		rc = bnx2_alloc_mem(bp);
-		if (rc)
+		if (!rc)
+			rc = bnx2_init_nic(bp, 0);
+
+		if (rc) {
+			bnx2_napi_enable(bp);
+			dev_close(bp->dev);
 			return rc;
-		bnx2_init_nic(bp, 0);
+		}
 		bnx2_netif_start(bp);
 	}
 	return 0;
-- 
1.5.6.GIT



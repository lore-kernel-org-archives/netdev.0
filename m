From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/3] bnx2x: don't write dcb/llfc fields in
 STORM memory
Date: Thu, 31 Mar 2011 14:45:32 -0800
Message-ID: <1301611533-9725-2-git-send-email-mchan@broadcom.com>
References: <1301611533-9725-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4363 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751809Ab1CaXjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 19:39:45 -0400
In-Reply-To: <1301611533-9725-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

We could get hardware attention during DCB/FCoE traffic without this
fix.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.h |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index ef37b98..775fef0 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -1041,12 +1041,23 @@ static inline void storm_memset_cmng(struct bnx2x *bp,
 				struct cmng_struct_per_port *cmng,
 				u8 port)
 {
-	size_t size = sizeof(struct cmng_struct_per_port);
+	size_t size =
+		sizeof(struct rate_shaping_vars_per_port) +
+		sizeof(struct fairness_vars_per_port) +
+		sizeof(struct safc_struct_per_port) +
+		sizeof(struct pfc_struct_per_port);
 
 	u32 addr = BAR_XSTRORM_INTMEM +
 			XSTORM_CMNG_PER_PORT_VARS_OFFSET(port);
 
 	__storm_memset_struct(bp, addr, size, (u32 *)cmng);
+
+	addr += size + 4 /* SKIP DCB+LLFC */;
+	size = sizeof(struct cmng_struct_per_port) -
+		size /* written */ - 4 /*skipped*/;
+
+	__storm_memset_struct(bp, addr, size,
+			      (u32 *)(cmng->traffic_type_to_priority_cos));
 }
 
 /* HW Lock for shared dual port PHYs */
-- 
1.6.4.GIT



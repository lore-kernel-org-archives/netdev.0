From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: fix incorrect cim_la output for T6
Date: Wed, 31 May 2017 19:10:21 +0530
Message-ID: <1496238021-23996-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:27901 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751090AbdEaNkc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 09:40:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

take care of UpDbgLaRdPtr[0-3] restriction for T6.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
v2:
- not using loop to increment UPDBGLARDPTR

 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 9160c88..822c560 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -8312,7 +8312,16 @@ int t4_cim_read_la(struct adapter *adap, u32 *la_buf, unsigned int *wrptr)
 		ret = t4_cim_read(adap, UP_UP_DBG_LA_DATA_A, 1, &la_buf[i]);
 		if (ret)
 			break;
-		idx = (idx + 1) & UPDBGLARDPTR_M;
+
+		/* Bits 0-3 of UpDbgLaRdPtr can be between 0000 to 1001 to
+		 * identify the 32-bit portion of the full 312-bit data
+		 */
+		if (is_t6(adap->params.chip) && (idx & 0xf) >= 9)
+			idx = (idx & 0xff0) + 0x10;
+		else
+			idx++;
+		/* address can't exceed 0xfff */
+		idx &= UPDBGLARDPTR_M;
 	}
 restart:
 	if (cfg & UPDBGLAEN_F) {
-- 
2.1.0

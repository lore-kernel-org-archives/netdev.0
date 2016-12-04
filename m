From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 1/2] bnx2x: Correct ringparam estimate when DOWN
Date: Sun, 4 Dec 2016 15:30:17 +0200
Message-ID: <1480858218-13187-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1480858218-13187-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 0016ce01.pphosted.com ([67.231.156.153]:60867 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751372AbcLDNad (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 08:30:33 -0500
In-Reply-To: <1480858218-13187-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until interface is up [and assuming ringparams weren't explicitly
configured] when queried for the size of its rings bnx2x would
claim they're the maximal size by default.
That is incorrect as by default the maximal number of buffers would
be equally divided between the various rx rings.

This prevents the user from actually setting the number of elements
on each rx ring to be of maximal size prior to transitioning the
interface into up state.

To fix this, make a rough estimation about the number of buffers.
It wouldn't always be accurate, but it would be much better than
current estimation and would allow users to increase number of
buffers during early initialization of the interface.

Reported-by: Seymour, Shane <shane.seymour@hpe.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 85a7800..5f19427 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1872,8 +1872,16 @@ static void bnx2x_get_ringparam(struct net_device *dev,
 
 	ering->rx_max_pending = MAX_RX_AVAIL;
 
+	/* If size isn't already set, we give an estimation of the number
+	 * of buffers we'll have. We're neglecting some possible conditions
+	 * [we couldn't know for certain at this point if number of queues
+	 * might shrink] but the number would be correct for the likely
+	 * scenario.
+	 */
 	if (bp->rx_ring_size)
 		ering->rx_pending = bp->rx_ring_size;
+	else if (BNX2X_NUM_RX_QUEUES(bp))
+		ering->rx_pending = MAX_RX_AVAIL / BNX2X_NUM_RX_QUEUES(bp);
 	else
 		ering->rx_pending = MAX_RX_AVAIL;
 
-- 
1.9.3

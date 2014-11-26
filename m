From: Mirko Lindner <mlindner@marvell.com>
Subject: [PATCH net-next] sky2: Fix crash inside sky2_rx_clean
Date: Wed, 26 Nov 2014 15:13:38 +0100
Message-ID: <5475E012.3060607@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:39403 "EHLO
	mx0a-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750828AbaKZONr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 09:13:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If sky2->tx_le = pci_alloc_consistent() or sky2->tx_ring = kcalloc() in
sky2_alloc_buffers() fails, sky2->rx_ring = kcalloc() will never be called.
In this error case handling, sky2_rx_clean() is called from within
sky2_free_buffers().

In sky2_rx_clean() we find the following:

...
   memset(sky2->rx_le, 0, RX_LE_BYTES);
...

This results in a memset using a NULL pointer and will crash the system.

Signed-off-by: Mirko Lindner <mlindner@marvell.com>
---
 drivers/net/ethernet/marvell/sky2.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 53a1cc5..f8ab220 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -1361,7 +1361,9 @@ static void sky2_rx_clean(struct sky2_port *sky2)
 {
 	unsigned i;
 
-	memset(sky2->rx_le, 0, RX_LE_BYTES);
+	if (sky2->rx_le)
+		memset(sky2->rx_le, 0, RX_LE_BYTES);
+
 	for (i = 0; i < sky2->rx_pending; i++) {
 		struct rx_ring_info *re = sky2->rx_ring + i;
 
-- 
2.1.3

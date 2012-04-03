From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: sky2: in free_buffers() do proper checks before call of rx_clean()
Date: Tue, 3 Apr 2012 02:13:27 +0200
Message-ID: <20120403001327.GB10227@Neptun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shemminger@vyatta.com, mlindner@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In sky2_open() free_buffers() is called in case that alloc_buffers() failed.
Here we do the check for sky2->rx_le too late, since we already called
rx_clean() which accessed rx_le. Furthermore we lack a check for sky2->rx_ring
which is also accessed by rx_clean().

With this patch both sky2->rx_le and sky2->rx_ring are checked before
alloc_buffers() is called.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 This applies against 3.3

 drivers/net/ethernet/marvell/sky2.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 760c2b1..3e3eda6 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -1628,9 +1628,10 @@ static void sky2_free_buffers(struct sky2_port *sky2)
 {
 	struct sky2_hw *hw = sky2->hw;
 
-	sky2_rx_clean(sky2);
-
 	if (sky2->rx_le) {
+		if (sky2->rx_ring)
+			sky2_rx_clean(sky2);
+
 		pci_free_consistent(hw->pdev, RX_LE_BYTES,
 				    sky2->rx_le, sky2->rx_le_map);
 		sky2->rx_le = NULL;
-- 
1.7.2.5

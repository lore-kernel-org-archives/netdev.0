From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 02/11] ixgbe: Fix an accounting problem when the Rx
	FIFO is full
Date: Sat, 14 Mar 2009 01:12:48 -0700
Message-ID: <20090314081247.4687.68700.stgit@lost.foo-projects.org>
References: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:41439
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752683AbZCNINK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 04:13:10 -0400
In-Reply-To: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

The rx_no_dma_resources counter reported by ethtool -S ethX is not
counting correctly.  In 82599, the queue mappings for the counters need
to be mapped properly, and accounted for properly.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 8e7a51b..c18d0f3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3629,6 +3629,12 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	u64 total_mpc = 0;
 	u32 i, missed_rx = 0, mpc, bprc, lxon, lxoff, xon_off_tot;
 
+	if (hw->mac.type == ixgbe_mac_82599EB) {
+		for (i = 0; i < 16; i++)
+			adapter->hw_rx_no_dma_resources +=
+			                     IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
+	}
+
 	adapter->stats.crcerrs += IXGBE_READ_REG(hw, IXGBE_CRCERRS);
 	for (i = 0; i < 8; i++) {
 		/* for packet buffers not used, the register should read 0 */
@@ -3648,7 +3654,6 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 			adapter->stats.pxoffrxc[i] += IXGBE_READ_REG(hw,
 			                                   IXGBE_PXOFFRXCNT(i));
 			adapter->stats.qprdc[i] += IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
-			adapter->hw_rx_no_dma_resources += adapter->stats.qprdc[i];
 		} else {
 			adapter->stats.pxonrxc[i] += IXGBE_READ_REG(hw,
 			                                      IXGBE_PXONRXC(i));


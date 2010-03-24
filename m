From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] igb: count Rx FIFO errors correctly
Date: Tue, 23 Mar 2010 21:34:38 -0700
Message-ID: <20100324043437.32036.44229.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:51904 "EHLO
	qmta08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750733Ab0CXEe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 00:34:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Don't aggregate rx_no_buffer_count into rx_fifo_errors. RNBC counts
packets that get queued temporarily in the adapter's FIFO. These
packets are not dropped and are not errors. The correct counter
is rx_missed_errors (MPC).

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 45a0e4f..70dc03b 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3963,7 +3963,7 @@ void igb_update_stats(struct igb_adapter *adapter)
 	struct net_device_stats *net_stats = igb_get_stats(adapter->netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
-	u32 rnbc, reg;
+	u32 reg, mpc;
 	u16 phy_tmp;
 	int i;
 	u64 bytes, packets;
@@ -4021,7 +4021,9 @@ void igb_update_stats(struct igb_adapter *adapter)
 	adapter->stats.symerrs += rd32(E1000_SYMERRS);
 	adapter->stats.sec += rd32(E1000_SEC);
 
-	adapter->stats.mpc += rd32(E1000_MPC);
+	mpc = rd32(E1000_MPC);
+	adapter->stats.mpc += mpc;
+	net_stats->rx_fifo_errors += mpc;
 	adapter->stats.scc += rd32(E1000_SCC);
 	adapter->stats.ecol += rd32(E1000_ECOL);
 	adapter->stats.mcc += rd32(E1000_MCC);
@@ -4036,9 +4038,7 @@ void igb_update_stats(struct igb_adapter *adapter)
 	adapter->stats.gptc += rd32(E1000_GPTC);
 	adapter->stats.gotc += rd32(E1000_GOTCL);
 	rd32(E1000_GOTCH); /* clear GOTCL */
-	rnbc = rd32(E1000_RNBC);
-	adapter->stats.rnbc += rnbc;
-	net_stats->rx_fifo_errors += rnbc;
+	adapter->stats.rnbc += rd32(E1000_RNBC);
 	adapter->stats.ruc += rd32(E1000_RUC);
 	adapter->stats.rfc += rd32(E1000_RFC);
 	adapter->stats.rjc += rd32(E1000_RJC);


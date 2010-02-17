From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 11/18] igb: only read phy specific stats if in
	internal phy mode
Date: Wed, 17 Feb 2010 03:03:58 -0800
Message-ID: <20100217110357.17723.28177.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:33866
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755332Ab0BQLEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:04:16 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

There are a couple statistics registers that are not meant to
be read when in SGMII/serdes mode. This patch adds a check to
verify mode before reading and updating these statistics.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index b989b34..cba0115 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3975,7 +3975,7 @@ void igb_update_stats(struct igb_adapter *adapter)
 	struct net_device_stats *net_stats = igb_get_stats(adapter->netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
-	u32 rnbc;
+	u32 rnbc, reg;
 	u16 phy_tmp;
 	int i;
 	u64 bytes, packets;
@@ -4072,8 +4072,13 @@ void igb_update_stats(struct igb_adapter *adapter)
 	adapter->stats.colc += rd32(E1000_COLC);
 
 	adapter->stats.algnerrc += rd32(E1000_ALGNERRC);
-	adapter->stats.rxerrc += rd32(E1000_RXERRC);
-	adapter->stats.tncrs += rd32(E1000_TNCRS);
+	/* read internal phy specific stats */
+	reg = rd32(E1000_CTRL_EXT);
+	if (!(reg & E1000_CTRL_EXT_LINK_MODE_MASK)) {
+		adapter->stats.rxerrc += rd32(E1000_RXERRC);
+		adapter->stats.tncrs += rd32(E1000_TNCRS);
+	}
+
 	adapter->stats.tsctc += rd32(E1000_TSCTC);
 	adapter->stats.tsctfc += rd32(E1000_TSCTFC);
 


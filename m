From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 09/20] ixgbe: pull PSRTYPE configuration into a
	separate function
Date: Thu, 19 Aug 2010 16:36:27 -0700
Message-ID: <20100819233624.10335.67259.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:42674 "EHLO
	qmta10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751731Ab0HSXgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:36:46 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The configuration of PSRTYPE was being done conditionally on if packet
split is enabled or not.  It can be configured always since it will not
have any effect when packet split is not enabled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   36 +++++++++++++++++++++++++-----------
 1 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ddabe14..88e6936 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2672,6 +2672,29 @@ static void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 	ring->tail = IXGBE_RDT(reg_idx);
 }
 
+static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int p;
+
+	/* PSRTYPE must be initialized in non 82598 adapters */
+	u32 psrtype = IXGBE_PSRTYPE_TCPHDR |
+	              IXGBE_PSRTYPE_UDPHDR |
+	              IXGBE_PSRTYPE_IPV4HDR |
+		      IXGBE_PSRTYPE_L2HDR |
+	              IXGBE_PSRTYPE_IPV6HDR;
+
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		return;
+
+	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED)
+		psrtype |= (adapter->num_rx_queues_per_pool << 29);
+
+	for (p = 0; p < adapter->num_rx_pools; p++)
+		IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(adapter->num_vfs + p),
+				psrtype);
+}
+
 /**
  * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
  * @adapter: board private structure
@@ -2690,6 +2713,8 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	u32 rdrxctl;
 	int rx_buf_len;
 
+	ixgbe_setup_psrtype(adapter);
+
 	/* Decide whether to use packet split mode or not */
 	/* Do not use packet split if we're in SR-IOV Mode */
 	if (!adapter->num_vfs)
@@ -2698,17 +2723,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	/* Set the RX buffer length according to the mode */
 	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
 		rx_buf_len = IXGBE_RX_HDR_SIZE;
-		if (hw->mac.type == ixgbe_mac_82599EB) {
-			/* PSRTYPE must be initialized in 82599 */
-			u32 psrtype = IXGBE_PSRTYPE_TCPHDR |
-			              IXGBE_PSRTYPE_UDPHDR |
-			              IXGBE_PSRTYPE_IPV4HDR |
-			              IXGBE_PSRTYPE_IPV6HDR |
-			              IXGBE_PSRTYPE_L2HDR;
-			IXGBE_WRITE_REG(hw,
-					IXGBE_PSRTYPE(adapter->num_vfs),
-					psrtype);
-		}
 	} else {
 		if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
 		    (netdev->mtu <= ETH_DATA_LEN))


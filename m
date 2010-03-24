From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] ixgbe: filter FIP frames into the FCoE offload
	queues
Date: Wed, 24 Mar 2010 15:45:21 -0700
Message-ID: <20100324224521.6653.17418.stgit@localhost.localdomain>
References: <20100324224500.6653.28216.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Chris Leech <christopher.leech@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:42425 "EHLO
	qmta04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751426Ab0CXWpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 18:45:39 -0400
In-Reply-To: <20100324224500.6653.28216.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Leech <christopher.leech@intel.com>

During FCF solicitation, the switch is supposed to pad the
solicited advertisement out to the endpoints specified
maximum FCoE frame size.  That means that we need to receive
FIP frames that are larger than the standard MTU.  To make
sure the receive queue is configured correctly, we should be
filtering FIP traffic into the FCoE queues.

Signed-off-by: Chris Leech <christopher.leech@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |   15 +++++++++++++++
 drivers/net/ixgbe/ixgbe_type.h |    1 +
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index e1978da..9276d59 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -522,6 +522,9 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 	/* Enable L2 eth type filter for FCoE */
 	IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_FCOE),
 			(ETH_P_FCOE | IXGBE_ETQF_FCOE | IXGBE_ETQF_FILTER_EN));
+	/* Enable L2 eth type filter for FIP */
+	IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_FIP),
+			(ETH_P_FIP | IXGBE_ETQF_FILTER_EN));
 	if (adapter->ring_feature[RING_F_FCOE].indices) {
 		/* Use multiple rx queues for FCoE by redirection table */
 		for (i = 0; i < IXGBE_FCRETA_SIZE; i++) {
@@ -532,6 +535,12 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 		}
 		IXGBE_WRITE_REG(hw, IXGBE_FCRECTL, IXGBE_FCRECTL_ENA);
 		IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FCOE), 0);
+		fcoe_i = f->mask;
+		fcoe_i &= IXGBE_FCRETA_ENTRY_MASK;
+		fcoe_q = adapter->rx_ring[fcoe_i]->reg_idx;
+		IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FIP),
+				IXGBE_ETQS_QUEUE_EN |
+				(fcoe_q << IXGBE_ETQS_RX_QUEUE_SHIFT));
 	} else  {
 		/* Use single rx queue for FCoE */
 		fcoe_i = f->mask;
@@ -541,6 +550,12 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 				IXGBE_ETQS_QUEUE_EN |
 				(fcoe_q << IXGBE_ETQS_RX_QUEUE_SHIFT));
 	}
+	/* send FIP frames to the first FCoE queue */
+	fcoe_i = f->mask;
+	fcoe_q = adapter->rx_ring[fcoe_i]->reg_idx;
+	IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FIP),
+			IXGBE_ETQS_QUEUE_EN |
+			(fcoe_q << IXGBE_ETQS_RX_QUEUE_SHIFT));
 
 	IXGBE_WRITE_REG(hw, IXGBE_FCRXCTRL,
 			IXGBE_FCRXCTRL_FCOELLI |
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index c574d0a..aed4ed6 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1298,6 +1298,7 @@
 #define IXGBE_ETQF_FILTER_BCN            1
 #define IXGBE_ETQF_FILTER_FCOE           2
 #define IXGBE_ETQF_FILTER_1588           3
+#define IXGBE_ETQF_FILTER_FIP            4
 /* VLAN Control Bit Masks */
 #define IXGBE_VLNCTRL_VET       0x0000FFFF  /* bits 0-15 */
 #define IXGBE_VLNCTRL_CFI       0x10000000  /* bit 28 */


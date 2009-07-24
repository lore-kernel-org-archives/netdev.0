From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: fix for 82599 errata marking UDP checksum
	errors
Date: Thu, 23 Jul 2009 21:00:39 -0700
Message-ID: <20090724040031.30202.1531.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:60263
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750760AbZGXEA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 00:00:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

There is an 82599 errata that UDP frames with a zero checksum are
incorrectly marked as checksum invalid by the hardware.  This was
leading to misleading hw_csum_rx_error counts. This patch adds a
test around this counter increase for this condition.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 6887759..200454f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -511,8 +511,11 @@ static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
  * @skb: skb currently being received and modified
  **/
 static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
-                                     u32 status_err, struct sk_buff *skb)
+				     union ixgbe_adv_rx_desc *rx_desc,
+				     struct sk_buff *skb)
 {
+	u32 status_err = le32_to_cpu(rx_desc->wb.upper.status_error);
+
 	skb->ip_summed = CHECKSUM_NONE;
 
 	/* Rx csum disabled */
@@ -530,6 +533,16 @@ static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
 		return;
 
 	if (status_err & IXGBE_RXDADV_ERR_TCPE) {
+		u16 pkt_info = rx_desc->wb.lower.lo_dword.hs_rss.pkt_info;
+
+		/*
+		 * 82599 errata, UDP frames with a 0 checksum can be marked as
+		 * checksum errors.
+		 */
+		if ((pkt_info & IXGBE_RXDADV_PKTTYPE_UDP) &&
+		    (adapter->hw.mac.type == ixgbe_mac_82599EB))
+			return;
+
 		adapter->hw_csum_rx_error++;
 		return;
 	}
@@ -803,7 +816,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			goto next_desc;
 		}
 
-		ixgbe_rx_checksum(adapter, staterr, skb);
+		ixgbe_rx_checksum(adapter, rx_desc, skb);
 
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;


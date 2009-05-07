From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/5] ixgbe: always set header length in SRRCTL
Date: Thu, 07 May 2009 13:38:56 -0700
Message-ID: <20090507203854.19886.54737.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:51795
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753678AbZEGUjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 16:39:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

As per the documentation for 82599 in order to support hardware RSC the
header size must be set.  This is only currently done for packet split
mode.  This patch sets the header buffer length for all modes.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   28 ++++++++++------------------
 1 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 08f4a13..4c38d51 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1754,28 +1754,20 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 	srrctl &= ~IXGBE_SRRCTL_BSIZEHDR_MASK;
 	srrctl &= ~IXGBE_SRRCTL_BSIZEPKT_MASK;
 
+	srrctl |= (IXGBE_RX_HDR_SIZE << IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
+		  IXGBE_SRRCTL_BSIZEHDR_MASK;
+
 	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
-		u16 bufsz = IXGBE_RXBUFFER_2048;
-		/* grow the amount we can receive on large page machines */
-		if (bufsz < (PAGE_SIZE / 2))
-			bufsz = (PAGE_SIZE / 2);
-		/* cap the bufsz at our largest descriptor size */
-		bufsz = min((u16)IXGBE_MAX_RXBUFFER, bufsz);
-
-		srrctl |= bufsz >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+#if (PAGE_SIZE / 2) > IXGBE_MAX_RXBUFFER
+		srrctl |= IXGBE_MAX_RXBUFFER >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+#else
+		srrctl |= (PAGE_SIZE / 2) >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+#endif
 		srrctl |= IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
-		srrctl |= ((IXGBE_RX_HDR_SIZE <<
-		            IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
-		           IXGBE_SRRCTL_BSIZEHDR_MASK);
 	} else {
+		srrctl |= ALIGN(rx_ring->rx_buf_len, 1024) >>
+			  IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 		srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
-
-		if (rx_ring->rx_buf_len == MAXIMUM_ETHERNET_VLAN_SIZE)
-			srrctl |= IXGBE_RXBUFFER_2048 >>
-			          IXGBE_SRRCTL_BSIZEPKT_SHIFT;
-		else
-			srrctl |= rx_ring->rx_buf_len >>
-			          IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 	}
 
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(index), srrctl);


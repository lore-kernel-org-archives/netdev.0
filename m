From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 1/2] igb: update handling of RCTL for smaller buffer
	sizes
Date: Tue, 09 Dec 2008 18:41:57 -0800
Message-ID: <20081210024156.27280.78618.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:52215
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754255AbYLJCmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 21:42:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

As we begin to move into virtualization the use of a global value for
buffer sizes becomes undesirable.  This change makes it so only 256 and 512
byte buffers require use of the RCTL register.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   32 ++++++++++++++------------------
 1 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index c49b8d8..dad742f 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1801,25 +1801,21 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 	 */
 	rctl &= ~(E1000_RCTL_SBP | E1000_RCTL_LPE | E1000_RCTL_SZ_256);
 
-	if (adapter->netdev->mtu <= ETH_DATA_LEN) {
-		/* Setup buffer sizes */
-		switch (adapter->rx_buffer_len) {
-		case IGB_RXBUFFER_256:
-			rctl |= E1000_RCTL_SZ_256;
-			break;
-		case IGB_RXBUFFER_512:
-			rctl |= E1000_RCTL_SZ_512;
-			break;
-		case IGB_RXBUFFER_1024:
-			rctl |= E1000_RCTL_SZ_1024;
-			break;
-		default:
-			rctl |= E1000_RCTL_SZ_2048;
-			break;
-		}
-	} else {
+	if (adapter->netdev->mtu > ETH_DATA_LEN)
 		rctl |= E1000_RCTL_LPE;
-		srrctl = adapter->rx_buffer_len >> E1000_SRRCTL_BSIZEPKT_SHIFT;
+
+	/* Setup buffer sizes */
+	switch (adapter->rx_buffer_len) {
+	case IGB_RXBUFFER_256:
+		rctl |= E1000_RCTL_SZ_256;
+		break;
+	case IGB_RXBUFFER_512:
+		rctl |= E1000_RCTL_SZ_512;
+		break;
+	default:
+		srrctl = ALIGN(adapter->rx_buffer_len, 1024)
+		         >> E1000_SRRCTL_BSIZEPKT_SHIFT;
+		break;
 	}
 
 	/* 82575 and greater support packet-split where the protocol


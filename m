From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 1/2] igb: remove unneeded bit refrence when enabling
	jumbo frames
Date: Mon, 24 Nov 2008 15:48:45 -0800
Message-ID: <20081124234845.24515.6891.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:44895 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753597AbYKXXtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 18:49:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There is a reference to a Buffer Size extention bit that is unneded by
82575/82576 hardware.  Since it is not needed it should be removed from the
code.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_defines.h |    6 ------
 drivers/net/igb/igb_main.c      |   20 ++++++--------------
 2 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index ce70068..c5fe784 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -168,18 +168,12 @@
 #define E1000_RCTL_RDMTS_HALF     0x00000000    /* rx desc min threshold size */
 #define E1000_RCTL_MO_SHIFT       12            /* multicast offset shift */
 #define E1000_RCTL_BAM            0x00008000    /* broadcast enable */
-/* these buffer sizes are valid if E1000_RCTL_BSEX is 0 */
 #define E1000_RCTL_SZ_2048        0x00000000    /* rx buffer size 2048 */
 #define E1000_RCTL_SZ_1024        0x00010000    /* rx buffer size 1024 */
 #define E1000_RCTL_SZ_512         0x00020000    /* rx buffer size 512 */
 #define E1000_RCTL_SZ_256         0x00030000    /* rx buffer size 256 */
-/* these buffer sizes are valid if E1000_RCTL_BSEX is 1 */
-#define E1000_RCTL_SZ_16384       0x00010000    /* rx buffer size 16384 */
-#define E1000_RCTL_SZ_8192        0x00020000    /* rx buffer size 8192 */
-#define E1000_RCTL_SZ_4096        0x00030000    /* rx buffer size 4096 */
 #define E1000_RCTL_VFE            0x00040000    /* vlan filter enable */
 #define E1000_RCTL_CFIEN          0x00080000    /* canonical form enable */
-#define E1000_RCTL_BSEX           0x02000000    /* Buffer size extension */
 #define E1000_RCTL_SECRC          0x04000000    /* Strip Ethernet CRC */
 
 /*
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index b64c41a..ae65fae 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1791,37 +1791,29 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 	*/
 	rctl |= E1000_RCTL_SECRC;
 
-	rctl &= ~E1000_RCTL_SBP;
+	/*
+	 * disable store bad packets, long packet enable, and clear size bits.
+	 */
+	rctl &= ~(E1000_RCTL_SBP | E1000_RCTL_LPE | E1000_RCTL_SZ_256);
 
-	if (adapter->netdev->mtu <= ETH_DATA_LEN)
-		rctl &= ~E1000_RCTL_LPE;
-	else
-		rctl |= E1000_RCTL_LPE;
-	if (adapter->rx_buffer_len <= IGB_RXBUFFER_2048) {
+	if (adapter->netdev->mtu <= ETH_DATA_LEN) {
 		/* Setup buffer sizes */
-		rctl &= ~E1000_RCTL_SZ_4096;
-		rctl |= E1000_RCTL_BSEX;
 		switch (adapter->rx_buffer_len) {
 		case IGB_RXBUFFER_256:
 			rctl |= E1000_RCTL_SZ_256;
-			rctl &= ~E1000_RCTL_BSEX;
 			break;
 		case IGB_RXBUFFER_512:
 			rctl |= E1000_RCTL_SZ_512;
-			rctl &= ~E1000_RCTL_BSEX;
 			break;
 		case IGB_RXBUFFER_1024:
 			rctl |= E1000_RCTL_SZ_1024;
-			rctl &= ~E1000_RCTL_BSEX;
 			break;
-		case IGB_RXBUFFER_2048:
 		default:
 			rctl |= E1000_RCTL_SZ_2048;
-			rctl &= ~E1000_RCTL_BSEX;
 			break;
 		}
 	} else {
-		rctl &= ~E1000_RCTL_BSEX;
+		rctl |= E1000_RCTL_LPE;
 		srrctl = adapter->rx_buffer_len >> E1000_SRRCTL_BSIZEPKT_SHIFT;
 	}
 


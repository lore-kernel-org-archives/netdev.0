From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/7] e1000e: correct flow control thresholds
Date: Tue, 02 Jun 2009 14:28:39 -0700
Message-ID: <20090602212839.24614.70593.stgit@localhost.localdomain>
References: <20090602212800.24614.45798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:35142
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752043AbZFBV2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 17:28:55 -0400
In-Reply-To: <20090602212800.24614.45798.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The flow control thresholds, i.e. high and low watermarks of the Rx
FIFO for when the hardware should transmit PAUSE frames (XON and XOFF,
respectively), need to be tuned for more efficient use of the FIFO.
The logic to set the thresholds for parts that support early-receive
(ERT) was also wrong in that it should check whether jumbo frames are
in use.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/defines.h |    2 ++
 drivers/net/e1000e/netdev.c  |   14 ++++++++------
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 243aa49..9acfecd 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -469,6 +469,8 @@
 #define AUTO_READ_DONE_TIMEOUT      10
 
 /* Flow Control */
+#define E1000_FCRTH_RTH  0x0000FFF8     /* Mask Bits[15:3] for RTH */
+#define E1000_FCRTL_RTL  0x0000FFF8     /* Mask Bits[15:3] for RTL */
 #define E1000_FCRTL_XONE 0x80000000     /* Enable XON frame transmission */
 
 /* Transmit Configuration Word */
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 7e412d1..b7a46c5 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2751,23 +2751,25 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	/*
 	 * flow control settings
 	 *
-	 * The high water mark must be low enough to fit one full frame
+	 * The high water mark must be low enough to fit two full frame
 	 * (or the size used for early receive) above it in the Rx FIFO.
 	 * Set it to the lower of:
 	 * - 90% of the Rx FIFO size, and
 	 * - the full Rx FIFO size minus the early receive size (for parts
 	 *   with ERT support assuming ERT set to E1000_ERT_2048), or
-	 * - the full Rx FIFO size minus one full frame
+	 * - the full Rx FIFO size minus two full frames
 	 */
-	if (adapter->flags & FLAG_HAS_ERT)
+	if ((adapter->flags & FLAG_HAS_ERT) &&
+	    (adapter->netdev->mtu > ETH_DATA_LEN))
 		hwm = min(((pba << 10) * 9 / 10),
 			  ((pba << 10) - (E1000_ERT_2048 << 3)));
 	else
 		hwm = min(((pba << 10) * 9 / 10),
-			  ((pba << 10) - adapter->max_frame_size));
+			  ((pba << 10) - (2 * adapter->max_frame_size)));
 
-	fc->high_water = hwm & 0xFFF8; /* 8-byte granularity */
-	fc->low_water = fc->high_water - 8;
+	fc->high_water = hwm & E1000_FCRTH_RTH; /* 8-byte granularity */
+	fc->low_water = (fc->high_water - (2 * adapter->max_frame_size));
+	fc->low_water &= E1000_FCRTL_RTL; /* 8-byte granularity */
 
 	if (adapter->flags & FLAG_DISABLE_FC_PAUSE_TIME)
 		fc->pause_time = 0xFFFF;


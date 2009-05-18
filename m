From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] ixgbe: set max desc to prevent total RSC
	packet size of 64K
Date: Sun, 17 May 2009 23:57:47 -0700
Message-ID: <20090518065745.14864.86660.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:47292
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755398AbZERG6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 02:58:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The performance of hardware RSC is greatly reduced if the total for max rsc
descriptors multiplied by the buffer size is greater than 65535.  To
prevent this we need to adjust the max rsc descriptors appropriately.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    2 ++
 drivers/net/ixgbe/ixgbe_main.c |   29 ++++++++++++++++++-----------
 2 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index d291d1c..05a2405 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -75,6 +75,8 @@
 #define IXGBE_RXBUFFER_128   128    /* Used for packet split */
 #define IXGBE_RXBUFFER_256   256    /* Used for packet split */
 #define IXGBE_RXBUFFER_2048  2048
+#define IXGBE_RXBUFFER_4096  4096
+#define IXGBE_RXBUFFER_8192  8192
 #define IXGBE_MAX_RXBUFFER   16384  /* largest size for a single descriptor */
 
 #define IXGBE_RX_HDR_SIZE IXGBE_RXBUFFER_256
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b53f265..4ab17ab 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1995,21 +1995,28 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 			rscctrl = IXGBE_READ_REG(hw, IXGBE_RSCCTL(j));
 			rscctrl |= IXGBE_RSCCTL_RSCEN;
 			/*
-			 *  if packet split is enabled we can only support up
-			 *  to max frags + 1 descriptors.
+			 * we must limit the number of descriptors so that the
+			 * total size of max desc * buf_len is not greater
+			 * than 65535
 			 */
-			if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)
-#if (MAX_SKB_FRAGS < 3)
-				rscctrl |= IXGBE_RSCCTL_MAXDESC_1;
-#elif (MAX_SKB_FRAGS < 7)
-				rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
-#elif (MAX_SKB_FRAGS < 15)
+			if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
+#if (MAX_SKB_FRAGS > 16)
+				rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
+#elif (MAX_SKB_FRAGS > 8)
 				rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
+#elif (MAX_SKB_FRAGS > 4)
+				rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
 #else
-				rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
+				rscctrl |= IXGBE_RSCCTL_MAXDESC_1;
 #endif
-			else
-				rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
+			} else {
+				if (rx_buf_len < IXGBE_RXBUFFER_4096)
+					rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
+				else if (rx_buf_len < IXGBE_RXBUFFER_8192)
+					rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
+				else
+					rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
+			}
 			IXGBE_WRITE_REG(hw, IXGBE_RSCCTL(j), rscctrl);
 		}
 		/* Disable RSC for ACK packets */


From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/2] ixbge: fix bug when using large pages and jumbo
	frames
Date: Tue, 24 Feb 2009 15:40:56 -0800
Message-ID: <20090224234056.29312.78842.stgit@lost.foo-projects.org>
References: <20090224234037.29312.54427.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:38907
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757511AbZBXXlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 18:41:18 -0500
In-Reply-To: <20090224234037.29312.54427.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

it was pointed out on the list that ixgbe was failing when using 64kB pages
and large 16kB MTU.

since with a 64kB PAGE_SIZE MAX_SKB_FRAGS = 3, the way the driver was
configuring page usage was assuming 2kB is half a page, and was only
ever dmaing that much data to a half page.

(16kB - header size) / 2048 = 7 or 8 pages, which would far exceed 3

adjust the driver to account for these large pages, the hardware can
support DMA to up to 16kB for each descriptor.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Breno Leitao <leitao@linux.vnet.ibm.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    1 +
 drivers/net/ixgbe/ixgbe_main.c |    9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index c0e56aa..2d877da 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -71,6 +71,7 @@
 #define IXGBE_RXBUFFER_128   128    /* Used for packet split */
 #define IXGBE_RXBUFFER_256   256    /* Used for packet split */
 #define IXGBE_RXBUFFER_2048  2048
+#define IXGBE_MAX_RXBUFFER   16384  /* largest size for a single descriptor */
 
 #define IXGBE_RX_HDR_SIZE IXGBE_RXBUFFER_256
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e0d736c..6564235 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1550,7 +1550,14 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 	srrctl &= ~IXGBE_SRRCTL_BSIZEPKT_MASK;
 
 	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
-		srrctl |= IXGBE_RXBUFFER_2048 >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+		u16 bufsz = IXGBE_RXBUFFER_2048;
+		/* grow the amount we can receive on large page machines */
+		if (bufsz < (PAGE_SIZE / 2))
+			bufsz = (PAGE_SIZE / 2);
+		/* cap the bufsz at our largest descriptor size */
+		bufsz = min((u16)IXGBE_MAX_RXBUFFER, bufsz);
+
+		srrctl |= bufsz >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 		srrctl |= IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
 		srrctl |= ((IXGBE_RX_HDR_SIZE <<
 		            IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &


From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/6] igb: make rxcsum configuration seperate from
	multiqueue
Date: Tue, 28 Apr 2009 01:35:14 -0700
Message-ID: <20090428083513.32417.95815.stgit@localhost.localdomain>
References: <20090428083445.32417.77682.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:46799
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752858AbZD1Ifc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:35:32 -0400
In-Reply-To: <20090428083445.32417.77682.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The igb driver was being incorrectly setup to only allow disabling receive
checksum if multiqueue was disabled.  This change corrects that so that
RXCSUM is configured regardless of queue configuration.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_defines.h |    2 +-
 drivers/net/igb/igb_main.c      |   30 +++++++++++-------------------
 2 files changed, 12 insertions(+), 20 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index ad2d319..65acbba 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -289,8 +289,8 @@
 #define E1000_SCTL_DISABLE_SERDES_LOOPBACK 0x0400
 
 /* Receive Checksum Control */
+#define E1000_RXCSUM_IPOFL     0x00000100   /* IPv4 checksum offload */
 #define E1000_RXCSUM_TUOFL     0x00000200   /* TCP / UDP checksum offload */
-#define E1000_RXCSUM_IPPCSE    0x00001000   /* IP payload checksum enable */
 #define E1000_RXCSUM_PCSD      0x00002000   /* packet checksum disabled */
 
 /* Header split receive */
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ab846ec..4ecf4df 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2236,29 +2236,21 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 		mrqc |= (E1000_MRQC_RSS_FIELD_IPV6_UDP_EX |
 			 E1000_MRQC_RSS_FIELD_IPV6_TCP_EX);
 
-
 		wr32(E1000_MRQC, mrqc);
-
-		/* Multiqueue and raw packet checksumming are mutually
-		 * exclusive.  Note that this not the same as TCP/IP
-		 * checksumming, which works fine. */
-		rxcsum = rd32(E1000_RXCSUM);
-		rxcsum |= E1000_RXCSUM_PCSD;
-		wr32(E1000_RXCSUM, rxcsum);
-	} else {
+	} else if (adapter->vfs_allocated_count) {
 		/* Enable multi-queue for sr-iov */
-		if (adapter->vfs_allocated_count)
-			wr32(E1000_MRQC, E1000_MRQC_ENABLE_VMDQ);
-		/* Enable Receive Checksum Offload for TCP and UDP */
-		rxcsum = rd32(E1000_RXCSUM);
-		if (adapter->rx_csum)
-			rxcsum |= E1000_RXCSUM_TUOFL | E1000_RXCSUM_IPPCSE;
-		else
-			rxcsum &= ~(E1000_RXCSUM_TUOFL | E1000_RXCSUM_IPPCSE);
-
-		wr32(E1000_RXCSUM, rxcsum);
+		wr32(E1000_MRQC, E1000_MRQC_ENABLE_VMDQ);
 	}
 
+	/* Enable Receive Checksum Offload for TCP and UDP */
+	rxcsum = rd32(E1000_RXCSUM);
+	/* Disable raw packet checksumming */
+	rxcsum |= E1000_RXCSUM_PCSD;
+	/* Don't need to set TUOFL or IPOFL, they default to 1 */
+	if (!adapter->rx_csum)
+		rxcsum &= ~(E1000_RXCSUM_TUOFL | E1000_RXCSUM_IPOFL);
+	wr32(E1000_RXCSUM, rxcsum);
+
 	/* Set the default pool for the PF's first queue */
 	igb_configure_vt_default_pool(adapter);
 


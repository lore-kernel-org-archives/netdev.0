From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 03/20] igb: increase minimum rx buffer size to 1K
Date: Tue, 27 Oct 2009 18:50:08 -0700
Message-ID: <20091028015007.12470.6946.stgit@localhost.localdomain>
References: <20091028014858.12470.99520.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:50583
	"EHLO QMTA12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757173AbZJ1Bxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 21:53:52 -0400
In-Reply-To: <20091028014858.12470.99520.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This update increases the minimum rx buffer size to 1K.  The reason for this
change is to support SR-IOV and avoid any conflicts with the rings being able
to set their own MTU sizes.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    2 --
 drivers/net/igb/igb_main.c |   25 +++----------------------
 2 files changed, 3 insertions(+), 24 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index d27dcd1..044ba02 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -96,8 +96,6 @@ struct vf_data_storage {
 
 /* Supported Rx Buffer Sizes */
 #define IGB_RXBUFFER_128   128    /* Used for packet split */
-#define IGB_RXBUFFER_256   256    /* Used for packet split */
-#define IGB_RXBUFFER_512   512
 #define IGB_RXBUFFER_1024  1024
 #define IGB_RXBUFFER_2048  2048
 #define IGB_RXBUFFER_16384 16384
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index e1d1c0c..6146f5d 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2233,18 +2233,8 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 		rctl |= E1000_RCTL_LPE;
 
 	/* Setup buffer sizes */
-	switch (adapter->rx_buffer_len) {
-	case IGB_RXBUFFER_256:
-		rctl |= E1000_RCTL_SZ_256;
-		break;
-	case IGB_RXBUFFER_512:
-		rctl |= E1000_RCTL_SZ_512;
-		break;
-	default:
-		srrctl = ALIGN(adapter->rx_buffer_len, 1024)
-		         >> E1000_SRRCTL_BSIZEPKT_SHIFT;
-		break;
-	}
+	srrctl = ALIGN(adapter->rx_buffer_len, 1024)
+	         >> E1000_SRRCTL_BSIZEPKT_SHIFT;
 
 	/* 82575 and greater support packet-split where the protocol
 	 * header is placed in skb->data and the packet data is
@@ -3755,11 +3745,7 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 	 * i.e. RXBUFFER_2048 --> size-4096 slab
 	 */
 
-	if (max_frame <= IGB_RXBUFFER_256)
-		adapter->rx_buffer_len = IGB_RXBUFFER_256;
-	else if (max_frame <= IGB_RXBUFFER_512)
-		adapter->rx_buffer_len = IGB_RXBUFFER_512;
-	else if (max_frame <= IGB_RXBUFFER_1024)
+	if (max_frame <= IGB_RXBUFFER_1024)
 		adapter->rx_buffer_len = IGB_RXBUFFER_1024;
 	else if (max_frame <= IGB_RXBUFFER_2048)
 		adapter->rx_buffer_len = IGB_RXBUFFER_2048;
@@ -3770,11 +3756,6 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 		adapter->rx_buffer_len = PAGE_SIZE / 2;
 #endif
 
-	/* if sr-iov is enabled we need to force buffer size to 1K or larger */
-	if (adapter->vfs_allocated_count &&
-	    (adapter->rx_buffer_len < IGB_RXBUFFER_1024))
-		adapter->rx_buffer_len = IGB_RXBUFFER_1024;
-
 	/* adjust allocation if LPE protects us, and we aren't using SBP */
 	if ((max_frame == ETH_FRAME_LEN + ETH_FCS_LEN) ||
 	     (max_frame == MAXIMUM_ETHERNET_VLAN_SIZE))


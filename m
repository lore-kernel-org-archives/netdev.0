From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/9] ixgb: allocate only buffersize needed
Date: Fri, 26 May 2006 09:52:02 -0700
Message-ID: <20060526165202.30514.85268.stgit@gitlost.site>
References: <20060526165124.30514.78477.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        "Kok, Auke" <auke-jan.h.kok@intel.com>,
        "Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:31750 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751132AbWEZQq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 12:46:58 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060526165124.30514.78477.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In order to help correct window size growth, use the MFS register
to limit the packet sizes received and allocate only the buffer
size necessary

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

index 0905a82..84a8064 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -574,9 +574,8 @@ ixgb_sw_init(struct ixgb_adapter *adapte
 	hw->subsystem_vendor_id = pdev->subsystem_vendor;
 	hw->subsystem_id = pdev->subsystem_device;

-	adapter->rx_buffer_len = IXGB_RXBUFFER_2048;
-
 	hw->max_frame_size = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
+	adapter->rx_buffer_len = hw->max_frame_size;

 	if((hw->device_id == IXGB_DEVICE_ID_82597EX)
 	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_CX4)
@@ -820,21 +819,14 @@ ixgb_setup_rctl(struct ixgb_adapter *ada

 	rctl |= IXGB_RCTL_SECRC;

-	switch (adapter->rx_buffer_len) {
-	case IXGB_RXBUFFER_2048:
-	default:
+	if (adapter->rx_buffer_len <= IXGB_RXBUFFER_2048)
 		rctl |= IXGB_RCTL_BSIZE_2048;
-		break;
-	case IXGB_RXBUFFER_4096:
+	else if (adapter->rx_buffer_len <= IXGB_RXBUFFER_4096)
 		rctl |= IXGB_RCTL_BSIZE_4096;
-		break;
-	case IXGB_RXBUFFER_8192:
+	else if (adapter->rx_buffer_len <= IXGB_RXBUFFER_8192)
 		rctl |= IXGB_RCTL_BSIZE_8192;
-		break;
-	case IXGB_RXBUFFER_16384:
+	else if (adapter->rx_buffer_len <= IXGB_RXBUFFER_16384)
 		rctl |= IXGB_RCTL_BSIZE_16384;
-		break;
-	}

 	IXGB_WRITE_REG(&adapter->hw, RCTL, rctl);
 }
@@ -1551,25 +1543,12 @@ ixgb_change_mtu(struct net_device *netde
 		DPRINTK(PROBE, ERR, "Invalid MTU setting %d\n", new_mtu);
 		return -EINVAL;
 	}
-
-	if((max_frame <= IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
-	   || (max_frame <= IXGB_RXBUFFER_2048)) {
-		adapter->rx_buffer_len = IXGB_RXBUFFER_2048;
-
-	} else if(max_frame <= IXGB_RXBUFFER_4096) {
-		adapter->rx_buffer_len = IXGB_RXBUFFER_4096;

-	} else if(max_frame <= IXGB_RXBUFFER_8192) {
-		adapter->rx_buffer_len = IXGB_RXBUFFER_8192;
+	adapter->rx_buffer_len = max_frame;

-	} else {
-		adapter->rx_buffer_len = IXGB_RXBUFFER_16384;
-	}
-
 	netdev->mtu = new_mtu;
-
-	if(old_max_frame != max_frame && netif_running(netdev)) {

+	if ((old_max_frame != max_frame) && netif_running(netdev)) {
 		ixgb_down(adapter, TRUE);
 		ixgb_up(adapter);
 	}
---

 drivers/net/ixgb/ixgb_main.c |   35 +++++++----------------------------
 1 files changed, 7 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 5561ab6..b825850 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -576,9 +576,8 @@ ixgb_sw_init(struct ixgb_adapter *adapte
 	hw->subsystem_vendor_id = pdev->subsystem_vendor;
 	hw->subsystem_id = pdev->subsystem_device;
 
-	adapter->rx_buffer_len = IXGB_RXBUFFER_2048;
-
 	hw->max_frame_size = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
+	adapter->rx_buffer_len = hw->max_frame_size;
 
 	if((hw->device_id == IXGB_DEVICE_ID_82597EX)
 	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_CX4)
@@ -822,21 +821,14 @@ ixgb_setup_rctl(struct ixgb_adapter *ada
 
 	rctl |= IXGB_RCTL_SECRC;
 
-	switch (adapter->rx_buffer_len) {
-	case IXGB_RXBUFFER_2048:
-	default:
+	if (adapter->rx_buffer_len <= IXGB_RXBUFFER_2048)
 		rctl |= IXGB_RCTL_BSIZE_2048;
-		break;
-	case IXGB_RXBUFFER_4096:
+	else if (adapter->rx_buffer_len <= IXGB_RXBUFFER_4096)
 		rctl |= IXGB_RCTL_BSIZE_4096;
-		break;
-	case IXGB_RXBUFFER_8192:
+	else if (adapter->rx_buffer_len <= IXGB_RXBUFFER_8192)
 		rctl |= IXGB_RCTL_BSIZE_8192;
-		break;
-	case IXGB_RXBUFFER_16384:
+	else if (adapter->rx_buffer_len <= IXGB_RXBUFFER_16384)
 		rctl |= IXGB_RCTL_BSIZE_16384;
-		break;
-	}
 
 	IXGB_WRITE_REG(&adapter->hw, RCTL, rctl);
 }
@@ -1546,24 +1538,11 @@ ixgb_change_mtu(struct net_device *netde
 		return -EINVAL;
 	}
 
-	if((max_frame <= IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
-	   || (max_frame <= IXGB_RXBUFFER_2048)) {
-		adapter->rx_buffer_len = IXGB_RXBUFFER_2048;
-
-	} else if(max_frame <= IXGB_RXBUFFER_4096) {
-		adapter->rx_buffer_len = IXGB_RXBUFFER_4096;
-
-	} else if(max_frame <= IXGB_RXBUFFER_8192) {
-		adapter->rx_buffer_len = IXGB_RXBUFFER_8192;
-
-	} else {
-		adapter->rx_buffer_len = IXGB_RXBUFFER_16384;
-	}
+	adapter->rx_buffer_len = max_frame;
 
 	netdev->mtu = new_mtu;
 
-	if(old_max_frame != max_frame && netif_running(netdev)) {
-
+	if ((old_max_frame != max_frame) && netif_running(netdev)) {
 		ixgb_down(adapter, TRUE);
 		ixgb_up(adapter);
 	}



--
Auke Kok <auke-jan.h.kok@intel.com>

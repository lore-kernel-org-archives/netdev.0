From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH v2 2/6] ethernet/intel: Use eth_skb_pad and skb_put_padto
 helpers
Date: Wed, 03 Dec 2014 08:17:39 -0800
Message-ID: <20141203161739.9223.52060.stgit@ahduyck-vm-fedora20>
References: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42195 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751576AbaLCQcm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 11:32:42 -0500
In-Reply-To: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the Intel Ethernet drivers to use eth_skb_pad() and skb_put_padto
instead of doing their own implementations of the function.

Also this cleans up two other spots where skb_pad was called but the length
and tail pointers were being manipulated directly instead of just having
the padding length added via __skb_put.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c     |    8 ++------
 drivers/net/ethernet/intel/e1000e/netdev.c        |    8 ++------
 drivers/net/ethernet/intel/fm10k/fm10k_main.c     |   11 +++--------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |    8 ++------
 drivers/net/ethernet/intel/igb/igb_main.c         |   19 +++++--------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   19 +++++--------------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   11 +++--------
 7 files changed, 22 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 24f3986..862d198 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3136,12 +3136,8 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	 * packets may get corrupted during padding by HW.
 	 * To WA this issue, pad all small packets manually.
 	 */
-	if (skb->len < ETH_ZLEN) {
-		if (skb_pad(skb, ETH_ZLEN - skb->len))
-			return NETDEV_TX_OK;
-		skb->len = ETH_ZLEN;
-		skb_set_tail_pointer(skb, ETH_ZLEN);
-	}
+	if (eth_skb_pad(skb))
+		return NETDEV_TX_OK;
 
 	mss = skb_shinfo(skb)->gso_size;
 	/* The controller does a simple calculation to
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 370cfa2..88936aa 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5554,12 +5554,8 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	/* The minimum packet size with TCTL.PSP set is 17 bytes so
 	 * pad skb in order to meet this minimum size requirement
 	 */
-	if (unlikely(skb->len < 17)) {
-		if (skb_pad(skb, 17 - skb->len))
-			return NETDEV_TX_OK;
-		skb->len = 17;
-		skb_set_tail_pointer(skb, 17);
-	}
+	if (skb_put_padto(skb, 17))
+		return NETDEV_TX_OK;
 
 	mss = skb_shinfo(skb)->gso_size;
 	if (mss) {
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 8c8deec..a05d228 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -578,14 +578,9 @@ static bool fm10k_cleanup_headers(struct fm10k_ring *rx_ring,
 	if (skb_is_nonlinear(skb))
 		fm10k_pull_tail(rx_ring, rx_desc, skb);
 
-	/* if skb_pad returns an error the skb was freed */
-	if (unlikely(skb->len < 60)) {
-		int pad_len = 60 - skb->len;
-
-		if (skb_pad(skb, pad_len))
-			return true;
-		__skb_put(skb, pad_len);
-	}
+	/* if eth_skb_pad returns an error the skb was freed */
+	if (eth_skb_pad(skb))
+		return true;
 
 	return false;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 3195d82..04b4414 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2399,12 +2399,8 @@ netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	/* hardware can't handle really short frames, hardware padding works
 	 * beyond this point
 	 */
-	if (unlikely(skb->len < I40E_MIN_TX_LEN)) {
-		if (skb_pad(skb, I40E_MIN_TX_LEN - skb->len))
-			return NETDEV_TX_OK;
-		skb->len = I40E_MIN_TX_LEN;
-		skb_set_tail_pointer(skb, I40E_MIN_TX_LEN);
-	}
+	if (skb_put_padto(skb, I40E_MIN_TX_LEN))
+		return NETDEV_TX_OK;
 
 	return i40e_xmit_frame_ring(skb, tx_ring);
 }
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6261399..36467cf 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5091,12 +5091,8 @@ static netdev_tx_t igb_xmit_frame(struct sk_buff *skb,
 	/* The minimum packet size with TCTL.PSP set is 17 so pad the skb
 	 * in order to meet this minimum size requirement.
 	 */
-	if (unlikely(skb->len < 17)) {
-		if (skb_pad(skb, 17 - skb->len))
-			return NETDEV_TX_OK;
-		skb->len = 17;
-		skb_set_tail_pointer(skb, 17);
-	}
+	if (skb_put_padto(skb, 17))
+		return NETDEV_TX_OK;
 
 	return igb_xmit_frame_ring(skb, igb_tx_queue_mapping(adapter, skb));
 }
@@ -6847,14 +6843,9 @@ static bool igb_cleanup_headers(struct igb_ring *rx_ring,
 	if (skb_is_nonlinear(skb))
 		igb_pull_tail(rx_ring, rx_desc, skb);
 
-	/* if skb_pad returns an error the skb was freed */
-	if (unlikely(skb->len < 60)) {
-		int pad_len = 60 - skb->len;
-
-		if (skb_pad(skb, pad_len))
-			return true;
-		__skb_put(skb, pad_len);
-	}
+	/* if eth_skb_pad returns an error the skb was freed */
+	if (eth_skb_pad(skb))
+		return true;
 
 	return false;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 23d72a2..702cc64 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1755,14 +1755,9 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring *rx_ring,
 		return false;
 
 #endif
-	/* if skb_pad returns an error the skb was freed */
-	if (unlikely(skb->len < 60)) {
-		int pad_len = 60 - skb->len;
-
-		if (skb_pad(skb, pad_len))
-			return true;
-		__skb_put(skb, pad_len);
-	}
+	/* if eth_skb_pad returns an error the skb was freed */
+	if (eth_skb_pad(skb))
+		return true;
 
 	return false;
 }
@@ -7248,12 +7243,8 @@ static netdev_tx_t __ixgbe_xmit_frame(struct sk_buff *skb,
 	 * The minimum packet size for olinfo paylen is 17 so pad the skb
 	 * in order to meet this minimum size requirement.
 	 */
-	if (unlikely(skb->len < 17)) {
-		if (skb_pad(skb, 17 - skb->len))
-			return NETDEV_TX_OK;
-		skb->len = 17;
-		skb_set_tail_pointer(skb, 17);
-	}
+	if (skb_put_padto(skb, 17))
+		return NETDEV_TX_OK;
 
 	tx_ring = ring ? ring : adapter->tx_ring[skb->queue_mapping];
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 755f71f..465d6a8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -612,14 +612,9 @@ static bool ixgbevf_cleanup_headers(struct ixgbevf_ring *rx_ring,
 	if (skb_is_nonlinear(skb))
 		ixgbevf_pull_tail(rx_ring, skb);
 
-	/* if skb_pad returns an error the skb was freed */
-	if (unlikely(skb->len < 60)) {
-		int pad_len = 60 - skb->len;
-
-		if (skb_pad(skb, pad_len))
-			return true;
-		__skb_put(skb, pad_len);
-	}
+	/* if eth_skb_pad returns an error the skb was freed */
+	if (eth_skb_pad(skb))
+		return true;
 
 	return false;
 }

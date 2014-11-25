From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 2/5] ethernet/intel: Use eth_skb_pad helper
Date: Tue, 25 Nov 2014 14:44:06 -0800
Message-ID: <20141125224406.1867.97911.stgit@ahduyck-vm-fedora20>
References: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951AbaKYWoI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2014 17:44:08 -0500
In-Reply-To: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the Intel Ethernet drivers to use eth_skb_pad() instead of doing
their own implementations of the function.

Also this cleans up two other spots where skb_pad was called but the length
and tail pointers were being manipulated directly instead of just having
the padding length added via __skb_put.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c     |    8 ++------
 drivers/net/ethernet/intel/fm10k/fm10k_main.c     |   11 +++--------
 drivers/net/ethernet/intel/igb/igb_main.c         |   11 +++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   11 +++--------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   11 +++--------
 5 files changed, 14 insertions(+), 38 deletions(-)

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
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 73457ed..91516ae 100644
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
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index b0e12e7..3cb54d0 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6843,14 +6843,9 @@ static bool igb_cleanup_headers(struct igb_ring *rx_ring,
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
index 932f779..7d0991a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1766,14 +1766,9 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring *rx_ring,
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

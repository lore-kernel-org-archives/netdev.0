From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] e1000: Small packets may get corrupted during padding by HW
Date: Sat, 15 Sep 2012 13:16:57 -0700
Message-ID: <1347740217-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65171 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244Ab2IOURJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Sep 2012 16:17:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@intel.com>

On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
packets may get corrupted during padding by HW.
To WA this issue, pad all small packets manually.

Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 3bfbb8d..bde337e 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3149,6 +3149,17 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
+	/* On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
+	 * packets may get corrupted during padding by HW.
+	 * To WA this issue, pad all small packets manually.
+	 */
+	if (skb->len < ETH_ZLEN) {
+		if (skb_pad(skb, ETH_ZLEN - skb->len))
+			return NETDEV_TX_OK;
+		skb->len = ETH_ZLEN;
+		skb_set_tail_pointer(skb, ETH_ZLEN);
+	}
+
 	mss = skb_shinfo(skb)->gso_size;
 	/* The controller does a simple calculation to
 	 * make sure there is enough room in the FIFO before
-- 
1.7.11.4

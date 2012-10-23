From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/8] e1000e: Minimum packet size must be 17 bytes
Date: Tue, 23 Oct 2012 03:24:40 -0700
Message-ID: <1350987887-16161-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54686 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903Ab2JWKYv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 06:24:51 -0400
In-Reply-To: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@intel.com>

This is a HW requirement. Although a buffer as short as 1 byte is allowed,
the total length of packet before, padding and CRC insertion, must be at
least 17 bytes.  So pad all small packets manually up to 17 bytes before
delivering them to HW.

Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index f444eb0..dadb13b 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5067,6 +5067,17 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
+	/*
+	 * The minimum packet size with TCTL.PSP set is 17 bytes so
+	 * pad skb in order to meet this minimum size requirement
+	 */
+	if (unlikely(skb->len < 17)) {
+		if (skb_pad(skb, 17 - skb->len))
+			return NETDEV_TX_OK;
+		skb->len = 17;
+		skb_set_tail_pointer(skb, 17);
+	}
+
 	mss = skb_shinfo(skb)->gso_size;
 	if (mss) {
 		u8 hdr_len;
-- 
1.7.11.7

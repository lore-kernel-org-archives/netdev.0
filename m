From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH]: e1000 endianness bugs
Date: Wed, 15 Mar 2006 14:26:28 -0800 (PST)
Message-ID: <20060315.142628.28661597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jeff@garzik.org, cramerj@intel.com,
	john.ronciak@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932066AbWCOW0c@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	return -E_NO_BIG_ENDIAN_TESTING;

[E1000]: Fix 4 missed endianness conversions on RX descriptor fields.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 5b7d0f4..1d91117 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3710,7 +3710,7 @@ e1000_clean_rx_irq(struct e1000_adapter 
 		e1000_rx_checksum(adapter,
 				  (uint32_t)(status) |
 				  ((uint32_t)(rx_desc->errors) << 24),
-				  rx_desc->csum, skb);
+				  le16_to_cpu(rx_desc->csum), skb);
 
 		skb->protocol = eth_type_trans(skb, netdev);
 #ifdef CONFIG_E1000_NAPI
@@ -3854,11 +3854,11 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 		}
 
 		e1000_rx_checksum(adapter, staterr,
-				  rx_desc->wb.lower.hi_dword.csum_ip.csum, skb);
+				  le16_to_cpu(rx_desc->wb.lower.hi_dword.csum_ip.csum), skb);
 		skb->protocol = eth_type_trans(skb, netdev);
 
 		if (likely(rx_desc->wb.upper.header_status &
-			  E1000_RXDPS_HDRSTAT_HDRSP))
+			   cpu_to_le16(E1000_RXDPS_HDRSTAT_HDRSP)))
 			adapter->rx_hdr_split++;
 #ifdef CONFIG_E1000_NAPI
 		if (unlikely(adapter->vlgrp && (staterr & E1000_RXD_STAT_VP))) {
@@ -3884,7 +3884,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 #endif
 
 next_desc:
-		rx_desc->wb.middle.status_error &= ~0xFF;
+		rx_desc->wb.middle.status_error &= cpu_to_le32(~0xFF);
 		buffer_info->skb = NULL;
 
 		/* return some buffers to hardware, one at a time is too slow */

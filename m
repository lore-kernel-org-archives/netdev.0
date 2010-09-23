From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] e1000: use GRO for receive
Date: Wed, 22 Sep 2010 21:23:05 -0700
Message-ID: <20100923042303.11798.50335.stgit@localhost.localdomain>
References: <20100923042126.11798.49675.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:39000
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752771Ab0IWEXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 00:23:25 -0400
In-Reply-To: <20100923042126.11798.49675.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

E1000 can benefit from calling the GRO receive functions.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index c88439d..796523f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3664,13 +3664,14 @@ static void e1000_consume_page(struct e1000_buffer *bi, struct sk_buff *skb,
 static void e1000_receive_skb(struct e1000_adapter *adapter, u8 status,
 			      __le16 vlan, struct sk_buff *skb)
 {
-	if (unlikely(adapter->vlgrp && (status & E1000_RXD_STAT_VP))) {
-		vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-		                         le16_to_cpu(vlan) &
-		                         E1000_RXD_SPC_VLAN_MASK);
-	} else {
-		netif_receive_skb(skb);
-	}
+	skb->protocol = eth_type_trans(skb, adapter->netdev);
+
+	if ((unlikely(adapter->vlgrp && (status & E1000_RXD_STAT_VP))))
+		vlan_gro_receive(&adapter->napi, adapter->vlgrp,
+				 le16_to_cpu(vlan) & E1000_RXD_SPC_VLAN_MASK,
+				 skb);
+	else
+		napi_gro_receive(&adapter->napi, skb);
 }
 
 /**
@@ -3828,8 +3829,6 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 			goto next_desc;
 		}
 
-		skb->protocol = eth_type_trans(skb, netdev);
-
 		e1000_receive_skb(adapter, status, rx_desc->special, skb);
 
 next_desc:
@@ -3992,8 +3991,6 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 				  ((u32)(rx_desc->errors) << 24),
 				  le16_to_cpu(rx_desc->csum), skb);
 
-		skb->protocol = eth_type_trans(skb, netdev);
-
 		e1000_receive_skb(adapter, status, rx_desc->special, skb);
 
 next_desc:


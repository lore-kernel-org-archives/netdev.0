From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 4/6] S2IO: Making LED off during LINK_DOWN notification.
Date: Sat, 24 Feb 2007 02:01:31 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10702240159440.3434-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, sreenivasa.honnur@neterion.com,
	ramkrishna.vepa@neterion.com, santosh.rastapur@neterion.com,
	alicia.pena@neterion.com, sriram.rapuru@neterion.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:45778 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933399AbXBXHBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 02:01:32 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Turning off LED for LINK_DOWN notification
- Return from rxd_owner_bit_reset function if call to set_rxd_buffer_pointer
  fails with ENOMEM

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
---
diff -urpN patch3/drivers/net/s2io.c patch4/drivers/net/s2io.c
--- patch3/drivers/net/s2io.c	2007-02-24 11:42:48.000000000 +0530
+++ patch4/drivers/net/s2io.c	2007-02-21 15:22:13.000000000 +0530
@@ -4127,6 +4127,11 @@ static void s2io_txpic_intr_handle(struc
 			val64 &= ~GPIO_INT_MASK_LINK_UP;
 			val64 |= GPIO_INT_MASK_LINK_DOWN;
 			writeq(val64, &bar0->gpio_int_mask);
+
+			/* turn off LED */
+			val64 = readq(&bar0->adapter_control);
+			val64 = val64 &(~ADAPTER_LED_ON);
+			writeq(val64, &bar0->adapter_control);
 		}
 	}
 	val64 = readq(&bar0->gpio_int_mask);
@@ -6124,10 +6129,13 @@ static  int rxd_owner_bit_reset(struct s
 					rx_blocks[j].rxds[k].virt_addr;
 				if(sp->rxd_mode >= RXD_MODE_3A)
 					ba = &mac_control->rings[i].ba[j][k];
-				set_rxd_buffer_pointer(sp, rxdp, ba,
+				if (set_rxd_buffer_pointer(sp, rxdp, ba,
 						       &skb,(u64 *)&temp0_64,
 						       (u64 *)&temp1_64,
-						       (u64 *)&temp2_64, size);
+						       (u64 *)&temp2_64,
+							size) == ENOMEM) {
+					return 0;
+				}
 
 				set_rxd_buffer_size(sp, rxdp, size);
 				wmb();


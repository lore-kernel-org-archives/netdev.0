From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 netdev-2.6 4/6] 82547 interrupt assert/de-assert re-ordering
Date: Mon, 2 Feb 2004 14:01:49 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402021348160.6288-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* 82547 needs interrupt disable/enable to keep interrupt assertion
  state synced between 82547 and APIC.  82547 will re-order
  assert and de-assert messages if hub link bus is busy (heavy
  traffic).  Disabling interrupt on device works around re-
  order issue.  Note: this is a re-patch.  We backed out the
  patch because of a report on a system with a 8086:1019 device
  would lock up with this patch.  Turns out that system was a
  pre-production sample.

-----------

diff -Naurp netdev-2.6/drivers/net/e1000/e1000_main.c netdev-2.6/drivers/net/e1000.mod/e1000_main.c
--- netdev-2.6/drivers/net/e1000/e1000_main.c	2004-02-02 12:09:08.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_main.c	2004-02-02 12:10:43.000000000 -0800
@@ -2119,10 +2119,26 @@ e1000_intr(int irq, void *data, struct p
 		__netif_rx_schedule(netdev);
 	}
 #else
+        /* Writing IMC and IMS is needed for 82547.
+	   Due to Hub Link bus being occupied, an interrupt 
+	   de-assertion message is not able to be sent. 
+	   When an interrupt assertion message is generated later,
+	   two messages are re-ordered and sent out.
+	   That causes APIC to think 82547 is in de-assertion
+	   state, while 82547 is in assertion state, resulting 
+	   in dead lock. Writing IMC forces 82547 into 
+	   de-assertion state.
+        */
+	if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
+		e1000_irq_disable(adapter);
+
 	for(i = 0; i < E1000_MAX_INTR; i++)
 		if(!e1000_clean_rx_irq(adapter) &
 		   !e1000_clean_tx_irq(adapter))
 			break;
+
+	if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
+		e1000_irq_enable(adapter);
 #endif
 
 	return IRQ_HANDLED;

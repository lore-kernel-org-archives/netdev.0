From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 6/10] e1000: Patch from Peter Kjellstroem --
 fix lockup with 82547
Date: Tue, 15 Feb 2005 13:29:02 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151115490.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

6 Patch from Peter Kjellstroem -- fix lockup with 82547
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2005-02-01 23:10:24.989105880 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c	2005-02-01 23:10:26.709844288 -0800
@@ -2165,10 +2165,28 @@ e1000_intr(int irq, void *data, struct p
 		__netif_rx_schedule(netdev);
 	}
 #else
+	/* Writing IMC and IMS is needed for 82547.
+	   Due to Hub Link bus being occupied, an interrupt
+	   de-assertion message is not able to be sent.
+	   When an interrupt assertion message is generated later,
+	   two messages are re-ordered and sent out.
+	   That causes APIC to think 82547 is in de-assertion
+	   state, while 82547 is in assertion state, resulting
+	   in dead lock. Writing IMC forces 82547 into
+	   de-assertion state.
+	*/
+	if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2){
+		atomic_inc(&adapter->irq_sem);
+		E1000_WRITE_REG(&adapter->hw, IMC, ~0);
+	}
+
 	for(i = 0; i < E1000_MAX_INTR; i++)
 		if(unlikely(!e1000_clean_rx_irq(adapter) &
 		   !e1000_clean_tx_irq(adapter)))
 			break;
+
+	if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
+		e1000_irq_enable(adapter);
 #endif
 
 	return IRQ_HANDLED;	

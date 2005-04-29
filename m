From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.4 7/16] e1000: Dump information on Tx
 ring
Date: Thu, 28 Apr 2005 20:12:43 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504282001360.30085-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dump information on Tx ring when 'NETDEV: Watchdog' condition is reached

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c	2005-04-12 23:00:55.000000000 -0700
@@ -2399,10 +2399,37 @@ e1000_clean_tx_irq(struct e1000_adapter 
 		/* detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
 		adapter->detect_tx_hung = FALSE;
-		if(tx_ring->buffer_info[i].dma &&
-		   time_after(jiffies, tx_ring->buffer_info[i].time_stamp + HZ) &&
-		   !(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_TXOFF))
+		if (tx_ring->buffer_info[i].dma &&
+		    time_after(jiffies, tx_ring->buffer_info[i].time_stamp + HZ)
+		    && !(E1000_READ_REG(&adapter->hw, STATUS) &
+			E1000_STATUS_TXOFF)) {
+
+			/* detected Tx unit hang */
+			i = tx_ring->next_to_clean;
+			eop = tx_ring->buffer_info[i].next_to_watch;
+			eop_desc = E1000_TX_DESC(*tx_ring, eop);
+			DPRINTK(TX_ERR, ERR, "Detected Tx Unit Hang\n"
+					"  TDH                  <%x>\n"
+					"  TDT                  <%x>\n"
+					"  next_to_use          <%x>\n"
+					"  next_to_clean        <%x>\n"
+					"buffer_info[next_to_clean]\n"
+					"  dma                  <%llx>\n"
+					"  time_stamp           <%lx>\n"
+					"  next_to_watch        <%x>\n"
+					"  jiffies              <%lx>\n"
+					"  next_to_watch.status <%x>\n",
+				E1000_READ_REG(&adapter->hw, TDH),
+				E1000_READ_REG(&adapter->hw, TDT),
+				tx_ring->next_to_use,
+				i,
+				tx_ring->buffer_info[i].dma,
+				tx_ring->buffer_info[i].time_stamp,
+				eop,
+				jiffies,
+				eop_desc->upper.fields.status);
 			netif_stop_queue(netdev);
+		}
 	}
 #ifdef NETIF_F_TSO
 

From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 netdev-2.6 1/6] flow control
Date: Sat, 21 Feb 2004 23:08:53 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402212305480.1228-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Bug fix: flow control high/low watermark settings not
  within Rx FIFO range: math error.

-----------

diff -Naurp netdev-2.6/drivers/net/e1000/e1000.h netdev-2.6/drivers/net/e1000.mod/e1000.h
--- netdev-2.6/drivers/net/e1000/e1000.h	2004-02-20 14:04:07.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000.h	2004-02-20 14:04:45.000000000 -0800
@@ -113,7 +113,7 @@ struct e1000_adapter;
 #define E1000_SMARTSPEED_MAX       15
 
 /* Packet Buffer allocations */
-#define E1000_TX_FIFO_SIZE_SHIFT 0xA
+#define E1000_PBA_BYTES_SHIFT 0xA
 #define E1000_TX_HEAD_ADDR_SHIFT 7
 #define E1000_PBA_TX_MASK 0xFFFF0000
 
diff -Naurp netdev-2.6/drivers/net/e1000/e1000_main.c netdev-2.6/drivers/net/e1000.mod/e1000_main.c
--- netdev-2.6/drivers/net/e1000/e1000_main.c	2004-02-20 14:04:07.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_main.c	2004-02-20 14:05:35.000000000 -0800
@@ -328,14 +328,16 @@ e1000_reset(struct e1000_adapter *adapte
 		adapter->tx_fifo_head = 0;
 		adapter->tx_head_addr = pba << E1000_TX_HEAD_ADDR_SHIFT;
 		adapter->tx_fifo_size =
-			(E1000_PBA_40K - pba) << E1000_TX_FIFO_SIZE_SHIFT;
+			(E1000_PBA_40K - pba) << E1000_PBA_BYTES_SHIFT;
 		atomic_set(&adapter->tx_fifo_stall, 0);
 	}
 	E1000_WRITE_REG(&adapter->hw, PBA, pba);
 
 	/* flow control settings */
-	adapter->hw.fc_high_water = pba - E1000_FC_HIGH_DIFF;
-	adapter->hw.fc_low_water = pba - E1000_FC_LOW_DIFF;
+	adapter->hw.fc_high_water =
+		(pba << E1000_PBA_BYTES_SHIFT) - E1000_FC_HIGH_DIFF;
+	adapter->hw.fc_low_water =
+		(pba << E1000_PBA_BYTES_SHIFT) - E1000_FC_LOW_DIFF;
 	adapter->hw.fc_pause_time = E1000_FC_PAUSE_TIME;
 	adapter->hw.fc_send_xon = 1;
 	adapter->hw.fc = adapter->hw.original_fc;

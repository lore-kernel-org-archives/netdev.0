From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 15/16] e1000:Adjust flow control
 watermarks for Jumbo Frames
Date: Thu, 28 Apr 2005 19:44:25 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281934490.29290-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adjust flow control watermarks for Jumbo Frames

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2005-04-11 02:22:27.000000000 -0700
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c	2005-04-11 02:22:29.000000000 -0700
@@ -409,7 +409,10 @@ e1000_down(struct e1000_adapter *adapter
 void
 e1000_reset(struct e1000_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
 	uint32_t pba, manc;
+	uint16_t fc_high_water_mark = E1000_FC_HIGH_DIFF;
+	uint16_t fc_low_water_mark = E1000_FC_LOW_DIFF;
 
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
@@ -428,6 +428,16 @@ 
 		break;
 	}
 
+	if((adapter->hw.mac_type != e1000_82573) &&
+	   (adapter->rx_buffer_len > E1000_RXBUFFER_8192)) {
+		pba -= 8; /* allocate more FIFO for Tx */
+		/* send an XOFF when there is enough space in the
+		 * Rx FIFO to hold one extra full size Rx packet 
+		*/
+		fc_high_water_mark = netdev->mtu + ENET_HEADER_SIZE + 
+					ETHERNET_FCS_SIZE + 1;
+		fc_low_water_mark = fc_high_water_mark + 8;
+	}
 
 
 	if(adapter->hw.mac_type == e1000_82547) {
@@ -442,9 +442,9 @@ 
 
 	/* flow control settings */
 	adapter->hw.fc_high_water = (pba << E1000_PBA_BYTES_SHIFT) -
-				    E1000_FC_HIGH_DIFF;
+				    fc_high_water_mark;
 	adapter->hw.fc_low_water = (pba << E1000_PBA_BYTES_SHIFT) -
-				   E1000_FC_LOW_DIFF;
+				   fc_low_water_mark;
 	adapter->hw.fc_pause_time = E1000_FC_PAUSE_TIME;
 	adapter->hw.fc_send_xon = 1;
 	adapter->hw.fc = adapter->hw.original_fc;

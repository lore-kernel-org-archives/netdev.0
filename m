From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.4 15/16] e1000: Adjust flow control
 watermarks for JumboFrames
Date: Thu, 28 Apr 2005 20:17:41 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504282006130.30085-100000@isotope.jf.intel.com>
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
diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c	2005-04-12 23:00:55.000000000 -0700
@@ -406,7 +406,10 @@ e1000_down(struct e1000_adapter *adapter
 void
 e1000_reset(struct e1000_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
 	uint32_t pba, manc;
+	uint16_t fc_high_water_mark = E1000_FC_HIGH_DIFF;
+	uint16_t fc_low_water_mark = E1000_FC_LOW_DIFF;
 
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
@@ -425,6 +425,16 @@ 
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
@@ -439,9 +439,9 @@ 
 
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

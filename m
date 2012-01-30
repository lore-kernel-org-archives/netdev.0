From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [06/22] Cyclades PC300 driver: use skb_copy_to_linear_data() and skb_reset_mac_header()
Date: Sun, 29 Jan 2012 18:48:39 -0800
Message-ID: <20120130024839.GG10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As with the HDLC code, the skb structure has been changed since the
Cyclades driver version 4.1.0 was written.  This updates it to build
with the current kernel.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index ec1964b..1e59a74 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -1834,17 +1834,17 @@ cpc_trace(struct net_device *dev, struct sk_buff *skb_main, char rx_tx)
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_CUST);
-	skb->mac.raw = skb->data;
+	skb_reset_mac_header(skb);
 	skb->pkt_type = PACKET_HOST;
 	skb->len = 10 + skb_main->len;
 
-	memcpy(skb->data, dev->name, 5);
+	skb_copy_to_linear_data(skb, dev->name, 5);
 	skb->data[5] = '[';
 	skb->data[6] = rx_tx;
 	skb->data[7] = ']';
 	skb->data[8] = ':';
 	skb->data[9] = ' ';
-	memcpy(&skb->data[10], skb_main->data, skb_main->len);
+	skb_copy_from_linear_data(skb_main, &skb->data[10], skb_main->len);
 
 	netif_rx(skb);
 }
@@ -2039,7 +2039,7 @@ static void cpc_net_rx(struct net_device *dev)
 			cpc_trace(dev, skb, 'R');
 		}
 		stats->rx_packets++;
-		skb->mac.raw = skb->data;
+		skb_reset_mac_header(skb);
 		skb->protocol = hdlc_type_trans(skb, dev);
 		netif_rx(skb);
 	}
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index e4610c2..883f747 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -1019,19 +1019,19 @@ static void cpc_tty_trace(pc300dev_t *dev, char* buf, int len, char rxtx)
 	}
 
 	skb_put (skb, 10 + len); 
-	skb->dev = dev->netdev; 
+	skb->dev = dev->netdev;
 	skb->protocol = htons(ETH_P_CUST); 
-	skb->mac.raw = skb->data; 
+	skb_reset_mac_header(skb);
 	skb->pkt_type = PACKET_HOST; 
 	skb->len = 10 + len; 
 
-	memcpy(skb->data,dev->netdev->name,5);
+	skb_copy_to_linear_data(skb, dev->netdev->name, 5);
 	skb->data[5] = '['; 
 	skb->data[6] = rxtx; 
 	skb->data[7] = ']'; 
 	skb->data[8] = ':'; 
 	skb->data[9] = ' '; 
-	memcpy(&skb->data[10], buf, len); 
+	skb_copy_to_linear_data_offset(skb, 10, buf, len);
 	netif_rx(skb); 
 } 	
 

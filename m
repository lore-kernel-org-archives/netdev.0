From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: PATCH: [SKBUFF] make hdlc_type_trans look like eth_type_trans
Date: Sun, 03 Oct 2004 11:09:15 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4160080B.408@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080601000806040705030207"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080601000806040705030207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there are five outstanding changesets in this tree:

ChangeSet@1.2034, 2004-10-03 11:01:01-03:00, acme@amd64.kerneljanitors.org
   [SKBUFF] make hdlc_type_trans look like eth_type_trans
ChangeSet@1.2033, 2004-10-03 00:23:07-03:00, acme@conectiva.com.br
   [SKBUFF] introduce tr_hdr(skb)
ChangeSet@1.2032, 2004-10-02 16:44:12-03:00, acme@amd64.kerneljanitors.org
ChangeSet@1.2031, 2004-10-02 16:27:19-03:00, acme@amd64.kerneljanitors.org
   [BRIDGE] convert __constant_htons(constant) to htons
ChangeSet@1.2030, 2004-10-02 13:42:59-03:00, acme@conectiva.com.br
   [SKBUFF] introduce eth_hdr(skb)

Regards,

- Arnaldo

--------------080601000806040705030207
Content-Type: text/plain;
 name="hdlc_type_trans.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hdlc_type_trans.patch"

===================================================================


ChangeSet@1.2034, 2004-10-03 11:01:01-03:00, acme@amd64.kerneljanitors.org
  [SKBUFF] make hdlc_type_trans look like eth_type_trans
  
  Moving skb->mac.raw and dev setting from the callers to hdlc_type_trans,
  also introduce farsync_type_trans, private to the farsync driver, but
  following the foo_type_trans model.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 drivers/char/pcmcia/synclink_cs.c |    1 
 drivers/char/synclink.c           |    4 ---
 drivers/char/synclinkmp.c         |    4 ---
 drivers/net/wan/dscc4.c           |    2 -
 drivers/net/wan/farsync.c         |   42 ++++++++++++++++++--------------------
 drivers/net/wan/hd6457x.c         |    2 -
 drivers/net/wan/pc300_drv.c       |    1 
 drivers/net/wan/wanxl.c           |    2 -
 include/linux/hdlc.h              |    8 +++++--
 9 files changed, 28 insertions(+), 38 deletions(-)


diff -Nru a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
--- a/drivers/char/pcmcia/synclink_cs.c	2004-10-03 11:02:01 -03:00
+++ b/drivers/char/pcmcia/synclink_cs.c	2004-10-03 11:02:01 -03:00
@@ -4571,7 +4571,6 @@
 	memcpy(skb_put(skb, size),buf,size);
 
 	skb->dev      = info->netdev;
-	skb->mac.raw  = skb->data;
 	skb->protocol = hdlc_type_trans(skb, skb->dev);
 
 	stats->rx_packets++;
diff -Nru a/drivers/char/synclink.c b/drivers/char/synclink.c
--- a/drivers/char/synclink.c	2004-10-03 11:02:01 -03:00
+++ b/drivers/char/synclink.c	2004-10-03 11:02:01 -03:00
@@ -8150,9 +8150,7 @@
 
 	memcpy(skb_put(skb, size),buf,size);
 
-	skb->dev      = info->netdev;
-	skb->mac.raw  = skb->data;
-	skb->protocol = hdlc_type_trans(skb, skb->dev);
+	skb->protocol = hdlc_type_trans(skb, info->netdev);
 
 	stats->rx_packets++;
 	stats->rx_bytes += size;
diff -Nru a/drivers/char/synclinkmp.c b/drivers/char/synclinkmp.c
--- a/drivers/char/synclinkmp.c	2004-10-03 11:02:01 -03:00
+++ b/drivers/char/synclinkmp.c	2004-10-03 11:02:01 -03:00
@@ -1968,9 +1968,7 @@
 
 	memcpy(skb_put(skb, size),buf,size);
 
-	skb->dev      = info->netdev;
-	skb->mac.raw  = skb->data;
-	skb->protocol = hdlc_type_trans(skb, skb->dev);
+	skb->protocol = hdlc_type_trans(skb, info->netdev);
 
 	stats->rx_packets++;
 	stats->rx_bytes += size;
diff -Nru a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
--- a/drivers/net/wan/dscc4.c	2004-10-03 11:02:02 -03:00
+++ b/drivers/net/wan/dscc4.c	2004-10-03 11:02:02 -03:00
@@ -517,9 +517,7 @@
 	skb = dev_alloc_skb(len);
 	dpriv->rx_skbuff[dirty] = skb;
 	if (skb) {
-		skb->dev = dev;
 		skb->protocol = hdlc_type_trans(skb, dev);
-		skb->mac.raw = skb->data;
 		rx_fd->data = pci_map_single(dpriv->pci_priv->pdev, skb->data,
 					     len, PCI_DMA_FROMDEVICE);
 	} else {
diff -Nru a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
--- a/drivers/net/wan/farsync.c	2004-10-03 11:02:01 -03:00
+++ b/drivers/net/wan/farsync.c	2004-10-03 11:02:01 -03:00
@@ -857,6 +857,18 @@
 	dev->trans_start = jiffies;
 }
 
+/*
+ * Mark it for our own raw sockets interface
+ */
+static unsigned short farsync_type_trans(struct sk_buff *skb,
+					 struct net_device *dev)
+{
+	skb->dev = dev;
+	skb->mac.raw = skb->data;
+	skb->pkt_type = PACKET_HOST;
+	return htons(ETH_P_CUST);
+}
+
 /*      Rx dma complete interrupt
  */
 static void
@@ -881,17 +893,10 @@
 
 	/* Push upstream */
 	dbg(DBG_RX, "Pushing the frame up the stack\n");
-	skb->mac.raw = skb->data;
-	skb->dev = dev;
-	if (port->mode == FST_RAW) {
-		/*
-		 * Mark it for our own raw sockets interface
-		 */
-		skb->protocol = htons(ETH_P_CUST);
-		skb->pkt_type = PACKET_HOST;
-	} else {
-		skb->protocol = hdlc_type_trans(skb, skb->dev);
-	}
+	if (port->mode == FST_RAW)
+		skb->protocol = farsync_type_trans(skb, dev);
+	else
+		skb->protocol = hdlc_type_trans(skb, dev);
 	rx_status = netif_rx(skb);
 	fst_process_rx_status(rx_status, port_to_dev(port)->name);
 	if (rx_status == NET_RX_DROP)
@@ -1316,17 +1321,10 @@
 
 		/* Push upstream */
 		dbg(DBG_RX, "Pushing frame up the stack\n");
-		skb->mac.raw = skb->data;
-		skb->dev = dev;
-		if (port->mode == FST_RAW) {
-			/*
-			 * Mark it for our own raw sockets interface
-			 */
-			skb->protocol = htons(ETH_P_CUST);
-			skb->pkt_type = PACKET_HOST;
-		} else {
-			skb->protocol = hdlc_type_trans(skb, skb->dev);
-		}
+		if (port->mode == FST_RAW)
+			skb->protocol = farsync_type_trans(skb, dev);
+		else
+			skb->protocol = hdlc_type_trans(skb, dev);
 		rx_status = netif_rx(skb);
 		fst_process_rx_status(rx_status, port_to_dev(port)->name);
 		if (rx_status == NET_RX_DROP) {
diff -Nru a/drivers/net/wan/hd6457x.c b/drivers/net/wan/hd6457x.c
--- a/drivers/net/wan/hd6457x.c	2004-10-03 11:02:01 -03:00
+++ b/drivers/net/wan/hd6457x.c	2004-10-03 11:02:01 -03:00
@@ -315,8 +315,6 @@
 #endif
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
-	skb->mac.raw = skb->data;
-	skb->dev = dev;
 	skb->dev->last_rx = jiffies;
 	skb->protocol = hdlc_type_trans(skb, dev);
 	netif_rx(skb);
diff -Nru a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
--- a/drivers/net/wan/pc300_drv.c	2004-10-03 11:02:01 -03:00
+++ b/drivers/net/wan/pc300_drv.c	2004-10-03 11:02:02 -03:00
@@ -1959,7 +1959,6 @@
 			cpc_trace(dev, skb, 'R');
 		}
 		stats->rx_packets++;
-		skb->mac.raw = skb->data;
 		skb->protocol = hdlc_type_trans(skb, dev);
 		netif_rx(skb);
 	}
diff -Nru a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
--- a/drivers/net/wan/wanxl.c	2004-10-03 11:02:01 -03:00
+++ b/drivers/net/wan/wanxl.c	2004-10-03 11:02:01 -03:00
@@ -224,8 +224,6 @@
 #endif
 				stats->rx_packets++;
 				stats->rx_bytes += skb->len;
-				skb->mac.raw = skb->data;
-				skb->dev = dev;
 				dev->last_rx = jiffies;
 				skb->protocol = hdlc_type_trans(skb, dev);
 				netif_rx(skb);
diff -Nru a/include/linux/hdlc.h b/include/linux/hdlc.h
--- a/include/linux/hdlc.h	2004-10-03 11:02:02 -03:00
+++ b/include/linux/hdlc.h	2004-10-03 11:02:02 -03:00
@@ -243,11 +243,15 @@
 static __inline__ unsigned short hdlc_type_trans(struct sk_buff *skb,
 						 struct net_device *dev)
 {
-	hdlc_device *hdlc = dev_to_hdlc(skb->dev);
+	hdlc_device *hdlc = dev_to_hdlc(dev);
+
+	skb->mac.raw  = skb->data;
+	skb->dev      = dev;
+
 	if (hdlc->proto.type_trans)
 		return hdlc->proto.type_trans(skb, dev);
 	else
-		return __constant_htons(ETH_P_HDLC);
+		return htons(ETH_P_HDLC);
 }
 
 #endif /* __KERNEL */


--------------080601000806040705030207--

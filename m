From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: PATCH 1/1: [SKBUFF] move common code to hdlc_type_trans
Date: Thu, 07 Oct 2004 23:04:34 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4165F5B2.5040807@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070203040906030808050001"
Cc: Francois Romieu <romieu@cogenit.fr>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070203040906030808050001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	It should be equivalent to the code it was before, the only
thing that seems fishy is the drivers/net/wan/dssc4.c, where
the skb->mac.raw is being set after the call to hdlc_type_trans,
where, in some codepaths there are calls to skb_pull and all the
other hdlc layer drivers set the mac.raw _before_ the skb_pull,
like eth_type_trans (that may well be called thru the hdlc layer
type_trans pointer).

	Francois, is this really what is intended? I left it as
is for now...

- Arnaldo

--------------070203040906030808050001
Content-Type: text/plain;
 name="hdlc_type_trans.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hdlc_type_trans.patch"

===================================================================


ChangeSet@1.2058, 2004-10-07 22:35:15-03:00, acme@conectiva.com.br
  [SKBUFF] move common code to hdlc_type_trans
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 drivers/char/pcmcia/synclink_cs.c |    4 ---
 drivers/char/synclink.c           |    4 ---
 drivers/char/synclinkmp.c         |    4 ---
 drivers/net/wan/dscc4.c           |    1 
 drivers/net/wan/farsync.c         |   42 ++++++++++++++++++--------------------
 drivers/net/wan/hd6457x.c         |    2 -
 drivers/net/wan/pc300_drv.c       |    1 
 drivers/net/wan/wanxl.c           |    2 -
 include/linux/hdlc.h              |    8 +++++--
 9 files changed, 29 insertions(+), 39 deletions(-)


diff -Nru a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
--- a/drivers/char/pcmcia/synclink_cs.c	2004-10-07 23:02:25 -03:00
+++ b/drivers/char/pcmcia/synclink_cs.c	2004-10-07 23:02:25 -03:00
@@ -4570,9 +4570,7 @@
 
 	memcpy(skb_put(skb, size),buf,size);
 
-	skb->dev      = info->netdev;
-	skb->mac.raw  = skb->data;
-	skb->protocol = hdlc_type_trans(skb, skb->dev);
+	skb->protocol = hdlc_type_trans(skb, info->netdev);
 
 	stats->rx_packets++;
 	stats->rx_bytes += size;
diff -Nru a/drivers/char/synclink.c b/drivers/char/synclink.c
--- a/drivers/char/synclink.c	2004-10-07 23:02:25 -03:00
+++ b/drivers/char/synclink.c	2004-10-07 23:02:25 -03:00
@@ -8150,9 +8150,7 @@
 
 	memcpy(skb_put(skb, size),buf,size);
 
-	skb->dev      = info->netdev;
-	skb->mac.raw  = skb->data;
-	skb->protocol = hdlc_type_trans(skb, skb->dev);
+	skb->protocol = hdlc_type_trans(skb, info->netdev);
 
 	stats->rx_packets++;
 	stats->rx_bytes += size;
diff -Nru a/drivers/char/synclinkmp.c b/drivers/char/synclinkmp.c
--- a/drivers/char/synclinkmp.c	2004-10-07 23:02:25 -03:00
+++ b/drivers/char/synclinkmp.c	2004-10-07 23:02:25 -03:00
@@ -1968,9 +1968,7 @@
 
 	memcpy(skb_put(skb, size),buf,size);
 
-	skb->dev      = info->netdev;
-	skb->mac.raw  = skb->data;
-	skb->protocol = hdlc_type_trans(skb, skb->dev);
+	skb->protocol = hdlc_type_trans(skb, info->netdev);
 
 	stats->rx_packets++;
 	stats->rx_bytes += size;
diff -Nru a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
--- a/drivers/net/wan/dscc4.c	2004-10-07 23:02:25 -03:00
+++ b/drivers/net/wan/dscc4.c	2004-10-07 23:02:25 -03:00
@@ -517,7 +517,6 @@
 	skb = dev_alloc_skb(len);
 	dpriv->rx_skbuff[dirty] = skb;
 	if (skb) {
-		skb->dev = dev;
 		skb->protocol = hdlc_type_trans(skb, dev);
 		skb->mac.raw = skb->data;
 		rx_fd->data = pci_map_single(dpriv->pci_priv->pdev, skb->data,
diff -Nru a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
--- a/drivers/net/wan/farsync.c	2004-10-07 23:02:25 -03:00
+++ b/drivers/net/wan/farsync.c	2004-10-07 23:02:25 -03:00
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
--- a/drivers/net/wan/hd6457x.c	2004-10-07 23:02:25 -03:00
+++ b/drivers/net/wan/hd6457x.c	2004-10-07 23:02:25 -03:00
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
--- a/drivers/net/wan/pc300_drv.c	2004-10-07 23:02:25 -03:00
+++ b/drivers/net/wan/pc300_drv.c	2004-10-07 23:02:25 -03:00
@@ -1959,7 +1959,6 @@
 			cpc_trace(dev, skb, 'R');
 		}
 		stats->rx_packets++;
-		skb->mac.raw = skb->data;
 		skb->protocol = hdlc_type_trans(skb, dev);
 		netif_rx(skb);
 	}
diff -Nru a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
--- a/drivers/net/wan/wanxl.c	2004-10-07 23:02:25 -03:00
+++ b/drivers/net/wan/wanxl.c	2004-10-07 23:02:25 -03:00
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
--- a/include/linux/hdlc.h	2004-10-07 23:02:25 -03:00
+++ b/include/linux/hdlc.h	2004-10-07 23:02:25 -03:00
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


--------------070203040906030808050001--

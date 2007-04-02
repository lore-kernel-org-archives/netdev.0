From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 05/15] ieee1394: eth1394: shorter error
	messages
Date: Mon, 2 Apr 2007 02:15:53 +0200 (CEST)
Message-ID: <tkrat.1b1271fa25a4f4df@s5r6.in-berlin.de>
References: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Content-Disposition: INLINE
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux1394-devel-bounces@lists.sourceforge.net
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/ieee1394/eth1394.c |   40 ++++++++++++++-----------------------
 1 file changed, 16 insertions(+), 24 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -196,9 +196,8 @@ static struct hpsb_highlevel eth1394_hig
 	.host_reset =	ether1394_host_reset,
 };
 
-static int ether1394_recv_init(struct net_device *dev)
+static int ether1394_recv_init(struct eth1394_priv *priv)
 {
-	struct eth1394_priv *priv = netdev_priv(dev);
 	unsigned int iso_buf_size;
 
 	/* FIXME: rawiso limits us to PAGE_SIZE */
@@ -212,9 +211,7 @@ static int ether1394_recv_init(struct ne
 				       HPSB_ISO_DMA_PACKET_PER_BUFFER,
 				       1, ether1394_iso);
 	if (priv->iso == NULL) {
-		ETH1394_PRINT(KERN_ERR, dev->name,
-			      "Could not allocate isochronous receive "
-			      "context for the broadcast channel\n");
+		ETH1394_PRINT_G(KERN_ERR, "Failed to allocate IR context\n");
 		priv->bc_state = ETHER1394_BC_ERROR;
 		return -EAGAIN;
 	}
@@ -233,7 +230,7 @@ static int ether1394_open(struct net_dev
 	int ret;
 
 	if (priv->bc_state == ETHER1394_BC_ERROR) {
-		ret = ether1394_recv_init(dev);
+		ret = ether1394_recv_init(priv);
 		if (ret)
 			return ret;
 	}
@@ -560,9 +557,7 @@ static void ether1394_add_host(struct hp
 	dev = alloc_etherdev(sizeof (struct eth1394_priv));
 
 	if (dev == NULL) {
-		ETH1394_PRINT_G (KERN_ERR, "Out of memory trying to allocate "
-				 "etherdevice for IEEE 1394 device %s-%d\n",
-				 host->driver->name, host->id);
+		ETH1394_PRINT_G(KERN_ERR, "Out of memory\n");
 		goto out;
 	}
 
@@ -583,21 +578,19 @@ static void ether1394_add_host(struct hp
 	hi = hpsb_create_hostinfo(&eth1394_highlevel, host, sizeof(*hi));
 
 	if (hi == NULL) {
-		ETH1394_PRINT_G (KERN_ERR, "Out of memory trying to create "
-				 "hostinfo for IEEE 1394 device %s-%d\n",
-				 host->driver->name, host->id);
+		ETH1394_PRINT_G(KERN_ERR, "Out of memory\n");
 		goto out;
 	}
 
 	ether1394_init_dev(dev);
 
-	if (register_netdev (dev)) {
-		ETH1394_PRINT (KERN_ERR, dev->name, "Error registering network driver\n");
+	if (register_netdev(dev)) {
+		ETH1394_PRINT_G(KERN_ERR, "Cannot register the driver\n");
 		goto out;
 	}
 
-	ETH1394_PRINT (KERN_INFO, dev->name, "IEEE-1394 IPv4 over 1394 Ethernet (fw-host%d)\n",
-		       host->id);
+	ETH1394_PRINT(KERN_INFO, dev->name, "IPv4 over IEEE 1394 (fw-host%d)\n",
+		      host->id);
 
 	hi->host = host;
 	hi->dev = dev;
@@ -606,7 +599,7 @@ static void ether1394_add_host(struct hp
 	 * be checked when the eth device is opened. */
 	priv->broadcast_channel = host->csr.broadcast_channel & 0x3f;
 
-	ether1394_recv_init(dev);
+	ether1394_recv_init(priv);
 	return;
 out:
 	if (dev)
@@ -1084,7 +1077,7 @@ static int ether1394_data_handler(struct
 
 		skb = dev_alloc_skb(len + dev->hard_header_len + 15);
 		if (!skb) {
-			HPSB_PRINT (KERN_ERR, "ether1394 rx: low on mem\n");
+			ETH1394_PRINT_G(KERN_ERR, "Out of memory\n");
 			priv->stats.rx_dropped++;
 			return -1;
 		}
@@ -1239,8 +1232,8 @@ static int ether1394_write(struct hpsb_h
 
 	hi = hpsb_get_hostinfo(&eth1394_highlevel, host);
 	if (hi == NULL) {
-		ETH1394_PRINT_G(KERN_ERR, "Could not find net device for host %s\n",
-				host->driver->name);
+		ETH1394_PRINT_G(KERN_ERR, "No net device at fw-host%d\n",
+				host->id);
 		return RCODE_ADDRESS_ERROR;
 	}
 
@@ -1265,8 +1258,8 @@ static void ether1394_iso(struct hpsb_is
 
 	hi = hpsb_get_hostinfo(&eth1394_highlevel, iso->host);
 	if (hi == NULL) {
-		ETH1394_PRINT_G(KERN_ERR, "Could not find net device for host %s\n",
-				iso->host->driver->name);
+		ETH1394_PRINT_G(KERN_ERR, "No net device at fw-host%d\n",
+				iso->host->id);
 		return;
 	}
 
@@ -1426,8 +1419,7 @@ static int ether1394_prep_write_packet(s
 	p->expect_response = 1;
 
 	if (hpsb_get_tlabel(p)) {
-		ETH1394_PRINT_G(KERN_ERR, "No more tlabels left while sending "
-				"to node " NODE_BUS_FMT "\n", NODE_BUS_ARGS(host, node));
+		ETH1394_PRINT_G(KERN_ERR, "Out of tlabels\n");
 		return -1;
 	}
 	p->header[0] =


-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV

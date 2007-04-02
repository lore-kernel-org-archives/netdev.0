From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 14/15] ieee1394: eth1394: correct return
	codes in hard_start_xmit
Date: Mon, 2 Apr 2007 02:24:27 +0200 (CEST)
Message-ID: <tkrat.d31b842d0b99b88a@s5r6.in-berlin.de>
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

This patch actually doesn't change anything because there was always 0
== NETDEV_TX_OK returned before.

TODO: Return NETDEV_TX_BUSY in error case and test in different error
conditions.

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/ieee1394/eth1394.c |   34 ++++++++++++++++------------------
 1 file changed, 16 insertions(+), 18 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -1531,7 +1531,6 @@ static int ether1394_tx(struct sk_buff *
 	unsigned long flags;
 	nodeid_t dest_node;
 	eth1394_tx_type tx_type;
-	int ret = 0;
 	unsigned int tx_len;
 	unsigned int max_payload;
 	u16 dg_size;
@@ -1541,26 +1540,20 @@ static int ether1394_tx(struct sk_buff *
 	struct eth1394_node_info *node_info = NULL;
 
 	ptask = kmem_cache_alloc(packet_task_cache, GFP_ATOMIC);
-	if (ptask == NULL) {
-		ret = -ENOMEM;
+	if (ptask == NULL)
 		goto fail;
-	}
 
 	/* XXX Ignore this for now. Noticed that when MacOSX is the IRM,
 	 * it does not set our validity bit. We need to compensate for
 	 * that somewhere else, but not in eth1394. */
 #if 0
-	if ((priv->host->csr.broadcast_channel & 0xc0000000) != 0xc0000000) {
-		ret = -EAGAIN;
+	if ((priv->host->csr.broadcast_channel & 0xc0000000) != 0xc0000000)
 		goto fail;
-	}
 #endif
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (!skb) {
-		ret = -ENOMEM;
+	if (!skb)
 		goto fail;
-	}
 
 	/* Get rid of the fake eth1394 header, but save a pointer */
 	eth = (struct eth1394hdr *)skb->data;
@@ -1587,16 +1580,13 @@ static int ether1394_tx(struct sk_buff *
 
 		node = eth1394_find_node_guid(&priv->ip_node_list,
 					      be64_to_cpu(guid));
-		if (!node) {
-			ret = -EAGAIN;
+		if (!node)
 			goto fail;
-		}
+
 		node_info =
 		    (struct eth1394_node_info *)node->ud->device.driver_data;
-		if (node_info->fifo == CSR1212_INVALID_ADDR_SPACE) {
-			ret = -EAGAIN;
+		if (node_info->fifo == CSR1212_INVALID_ADDR_SPACE)
 			goto fail;
-		}
 
 		dest_node = node->ud->ne->nodeid;
 		max_payload = node_info->maxpayload;
@@ -1643,7 +1633,7 @@ static int ether1394_tx(struct sk_buff *
 		goto fail;
 
 	netif_wake_queue(dev);
-	return 0;
+	return NETDEV_TX_OK;
 fail:
 	if (ptask)
 		kmem_cache_free(packet_task_cache, ptask);
@@ -1659,7 +1649,15 @@ fail:
 	if (netif_queue_stopped(dev))
 		netif_wake_queue(dev);
 
-	return 0;  /* returning non-zero causes serious problems */
+	/*
+	 * FIXME: According to a patch from 2003-02-26, "returning non-zero
+	 * causes serious problems" here, allegedly.  Before that patch,
+	 * -ERRNO was returned which is not appropriate under Linux 2.6.
+	 * Perhaps more needs to be done?  Stop the queue in serious
+	 * conditions and restart it elsewhere?
+	 */
+	/* return NETDEV_TX_BUSY; */
+	return NETDEV_TX_OK;
 }
 
 static void ether1394_get_drvinfo(struct net_device *dev,

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV

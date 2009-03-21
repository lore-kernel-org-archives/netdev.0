From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 47/77] dlci: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:14 -0700
Message-ID: <20090321053716.106234132@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36650 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760995AbZCUFsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:18 -0400
Content-Disposition: inline; filename=dlci-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/wan/dlci.c	2009-03-20 16:19:40.708965461 -0700
+++ b/drivers/net/wan/dlci.c	2009-03-20 16:20:03.615714775 -0700
@@ -114,7 +114,7 @@ static void dlci_receive(struct sk_buff 
 	if (!pskb_may_pull(skb, sizeof(*hdr))) {
 		printk(KERN_NOTICE "%s: invalid data no header\n",
 		       dev->name);
-		dlp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		kfree_skb(skb);
 		return;
 	}
@@ -127,7 +127,7 @@ static void dlci_receive(struct sk_buff 
 	if (hdr->control != FRAD_I_UI)
 	{
 		printk(KERN_NOTICE "%s: Invalid header flag 0x%02X.\n", dev->name, hdr->control);
-		dlp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 	}
 	else
 		switch(hdr->IP_NLPID)
@@ -136,14 +136,14 @@ static void dlci_receive(struct sk_buff 
 				if (hdr->NLPID != FRAD_P_SNAP)
 				{
 					printk(KERN_NOTICE "%s: Unsupported NLPID 0x%02X.\n", dev->name, hdr->NLPID);
-					dlp->stats.rx_errors++;
+					dev->stats.rx_errors++;
 					break;
 				}
 	 
 				if (hdr->OUI[0] + hdr->OUI[1] + hdr->OUI[2] != 0)
 				{
 					printk(KERN_NOTICE "%s: Unsupported organizationally unique identifier 0x%02X-%02X-%02X.\n", dev->name, hdr->OUI[0], hdr->OUI[1], hdr->OUI[2]);
-					dlp->stats.rx_errors++;
+					dev->stats.rx_errors++;
 					break;
 				}
 
@@ -164,12 +164,12 @@ static void dlci_receive(struct sk_buff 
 			case FRAD_P_Q933:
 			case FRAD_P_CLNP:
 				printk(KERN_NOTICE "%s: Unsupported NLPID 0x%02X.\n", dev->name, hdr->pad);
-				dlp->stats.rx_errors++;
+				dev->stats.rx_errors++;
 				break;
 
 			default:
 				printk(KERN_NOTICE "%s: Invalid pad byte 0x%02X.\n", dev->name, hdr->pad);
-				dlp->stats.rx_errors++;
+				dev->stats.rx_errors++;
 				break;				
 		}
 
@@ -178,9 +178,9 @@ static void dlci_receive(struct sk_buff 
 		/* we've set up the protocol, so discard the header */
 		skb_reset_mac_header(skb);
 		skb_pull(skb, header);
-		dlp->stats.rx_bytes += skb->len;
+		dev->stats.rx_bytes += skb->len;
 		netif_rx(skb);
-		dlp->stats.rx_packets++;
+		dev->stats.rx_packets++;
 	}
 	else
 		dev_kfree_skb(skb);
@@ -204,15 +204,15 @@ static int dlci_transmit(struct sk_buff 
 	switch (ret)
 	{
 		case DLCI_RET_OK:
-			dlp->stats.tx_packets++;
+			dev->stats.tx_packets++;
 			ret = 0;
 			break;
 			case DLCI_RET_ERR:
-			dlp->stats.tx_errors++;
+			dev->stats.tx_errors++;
 			ret = 0;
 			break;
 			case DLCI_RET_DROP:
-			dlp->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 			ret = 1;
 			break;
 	}
@@ -342,15 +342,6 @@ static int dlci_close(struct net_device 
 	return 0;
 }
 
-static struct net_device_stats *dlci_get_stats(struct net_device *dev)
-{
-	struct dlci_local *dlp;
-
-	dlp = netdev_priv(dev);
-
-	return(&dlp->stats);
-}
-
 static int dlci_add(struct dlci_add *dlci)
 {
 	struct net_device	*master, *slave;
@@ -498,7 +489,6 @@ static void dlci_setup(struct net_device
 	dev->do_ioctl		= dlci_dev_ioctl;
 	dev->hard_start_xmit	= dlci_transmit;
 	dev->header_ops		= &dlci_header_ops;
-	dev->get_stats		= dlci_get_stats;
 	dev->change_mtu		= dlci_change_mtu;
 	dev->destructor		= free_netdev;
 

-- 


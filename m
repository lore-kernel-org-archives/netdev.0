From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] wan: dlci/sdla transmit return dehacking
Date: Fri, 4 Sep 2009 08:33:46 -0700
Message-ID: <20090904083346.43885303@nehalam>
References: <20090904143439.c44f61ee.sfr@canb.auug.org.au>
	<20090903.213548.46609322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090903.213548.46609322.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a brute force removal of the wierd slave interface done for DLCI -> SDLA
transmit. Before it was using non-standard return values and freeing skb in caller.
This changes it to using normal return values, and freeing in the callee.
Luckly only one driver pair was doing this. Not tested on real hardware,
in fact I wonder if this driver pair is even being used by any users.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/wan/dlci.c  |   43 +++++--------------------------------------
 drivers/net/wan/sdla.c  |    8 ++++----
 include/linux/if_frad.h |    5 -----
 3 files changed, 9 insertions(+), 47 deletions(-)

--- a/drivers/net/wan/dlci.c	2009-09-04 08:14:38.993377174 -0700
+++ b/drivers/net/wan/dlci.c	2009-09-04 08:25:03.024404089 -0700
@@ -186,46 +186,13 @@ static void dlci_receive(struct sk_buff 
 		dev_kfree_skb(skb);
 }
 
-static netdev_tx_t dlci_transmit(struct sk_buff *skb,
-				       struct net_device *dev)
+static netdev_tx_t dlci_transmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct dlci_local *dlp;
-	netdev_tx_t ret;
-
-	if (!skb || !dev)
-		return NETDEV_TX_OK;
-
-	dlp = netdev_priv(dev);
-
-	netif_stop_queue(dev);
-	
-	/* This is hackish, overloads driver specific return values
-	   on top of normal transmit return! */
-	ret = dlp->slave->netdev_ops->ndo_start_xmit(skb, dlp->slave);
-	switch (ret)
-	{
-		case DLCI_RET_OK:
-			dev->stats.tx_packets++;
-			ret = NETDEV_TX_OK;
-			break;
-		case DLCI_RET_ERR:
-			dev->stats.tx_errors++;
-			ret = NETDEV_TX_OK;
-			break;
-		case DLCI_RET_DROP:
-			dev->stats.tx_dropped++;
-			ret = NETDEV_TX_BUSY;
-			break;
-	}
-	/* Alan Cox recommends always returning 0, and always freeing the packet */
-	/* experience suggest a slightly more conservative approach */
+	struct dlci_local *dlp = netdev_priv(dev);
 
-	if (ret == NETDEV_TX_OK)
-	{
-		dev_kfree_skb(skb);
-		netif_wake_queue(dev);
-	}
-	return(ret);
+	if (skb)
+		dlp->slave->netdev_ops->ndo_start_xmit(skb, dlp->slave);
+	return NETDEV_TX_OK;
 }
 
 static int dlci_config(struct net_device *dev, struct dlci_conf __user *conf, int get)
--- a/drivers/net/wan/sdla.c	2009-09-04 08:18:22.917065991 -0700
+++ b/drivers/net/wan/sdla.c	2009-09-04 08:24:53.587189004 -0700
@@ -652,7 +652,7 @@ static int sdla_dlci_conf(struct net_dev
 
 /* NOTE: the DLCI driver deals with freeing the SKB!! */
 static netdev_tx_t sdla_transmit(struct sk_buff *skb,
-				       struct net_device *dev)
+				 struct net_device *dev)
 {
 	struct frad_local *flp;
 	int               ret, addr, accept, i;
@@ -712,23 +712,21 @@ static netdev_tx_t sdla_transmit(struct 
 				}
 				break;
 		}
+
 		switch (ret)
 		{
 			case SDLA_RET_OK:
 				dev->stats.tx_packets++;
-				ret = DLCI_RET_OK;
 				break;
 
 			case SDLA_RET_CIR_OVERFLOW:
 			case SDLA_RET_BUF_OVERSIZE:
 			case SDLA_RET_NO_BUFS:
 				dev->stats.tx_dropped++;
-				ret = DLCI_RET_DROP;
 				break;
 
 			default:
 				dev->stats.tx_errors++;
-				ret = DLCI_RET_ERR;
 				break;
 		}
 	}
@@ -738,6 +736,8 @@ static netdev_tx_t sdla_transmit(struct 
 		if(flp->master[i]!=NULL)
 			netif_wake_queue(flp->master[i]);
 	}		
+
+	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
 
--- a/include/linux/if_frad.h	2009-09-04 08:19:04.459045748 -0700
+++ b/include/linux/if_frad.h	2009-09-04 08:19:47.487006328 -0700
@@ -69,11 +69,6 @@ struct dlci_conf {
 
 #define DLCI_VALID_FLAGS	0x000B
 
-/* FRAD driver uses these to indicate what it did with packet */
-#define DLCI_RET_OK		0x00
-#define DLCI_RET_ERR		0x01
-#define DLCI_RET_DROP		0x02
-
 /* defines for the actual Frame Relay hardware */
 #define FRAD_GET_CONF	(SIOCDEVPRIVATE)
 #define FRAD_SET_CONF	(SIOCDEVPRIVATE + 1)

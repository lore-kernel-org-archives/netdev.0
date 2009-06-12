From: Patrick McHardy <kaber@trash.net>
Subject: net: fix network drivers ndo_start_xmit() return values (part 8)
Date: Fri, 12 Jun 2009 18:14:36 +0200
Message-ID: <4A327EEC.5020300@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090103000307090505090901"
Cc: Linux Netdev List <netdev@vger.kernel.org>, j.dumon@option.com,
	Greg Kroah-Hartman <gregkh@suse.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48369 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753439AbZFLQOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 12:14:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090103000307090505090901
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------090103000307090505090901
Content-Type: text/x-patch;
 name="08.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="08.diff"

commit 6c6e6eb6ee2b7ab91c73e51a5d7a438d2daa5b94
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jun 12 18:14:16 2009 +0200

    net: fix network drivers ndo_start_xmit() return values (part 8)
    
    Fix up USB drivers that return an errno value (result of usb_submit_urb())
    to qdisc_restart(), causing qdisc_restart() to print a warning and requeue/
    retransmit the skb.
    
    - hso: skb is freed: use after free
    - at76_usb: skb is freed: use after free
    
    Compile tested only.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index e3580f4..f8c6d7e 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -816,7 +816,7 @@ static int hso_net_start_xmit(struct sk_buff *skb, struct net_device *net)
 	}
 	dev_kfree_skb(skb);
 	/* we're done */
-	return result;
+	return NETDEV_TX_OK;
 }
 
 static void hso_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
diff --git a/drivers/staging/at76_usb/at76_usb.c b/drivers/staging/at76_usb/at76_usb.c
index c8af9a8..3f303ae 100644
--- a/drivers/staging/at76_usb/at76_usb.c
+++ b/drivers/staging/at76_usb/at76_usb.c
@@ -3242,12 +3242,11 @@ static int at76_tx(struct sk_buff *skb, struct net_device *netdev)
 			       "%s: -EINVAL: tx urb %p hcpriv %p complete %p\n",
 			       priv->netdev->name, priv->tx_urb,
 			       priv->tx_urb->hcpriv, priv->tx_urb->complete);
-	} else {
+	} else
 		stats->tx_bytes += skb->len;
-		dev_kfree_skb(skb);
-	}
 
-	return ret;
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
 }
 
 static void at76_tx_timeout(struct net_device *netdev)

--------------090103000307090505090901--

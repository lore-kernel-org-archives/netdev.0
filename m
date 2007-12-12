From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT] cpmac: napi fix
Date: Wed, 12 Dec 2007 14:01:50 -0800
Message-ID: <20071212140150.6002bc3b@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eugene Konev <ejka@imfi.kspu.ru>, Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52022 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751657AbXLLWES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 17:04:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NAPI changes for 2.6.24 would break this driver. It doesn't return
correct value and has error if exactly "budget" packets are received.
Don't have ARM so this is by inspection only. Please test.


--- a/drivers/net/cpmac.c	2007-10-26 11:56:12.000000000 -0700
+++ b/drivers/net/cpmac.c	2007-12-12 13:48:40.000000000 -0800
@@ -439,14 +439,14 @@ static int cpmac_poll(struct napi_struct
 	if (unlikely(netif_msg_rx_status(priv)))
 		printk(KERN_DEBUG "%s: poll processed %d packets\n",
 		       priv->dev->name, received);
-	if (desc->dataflags & CPMAC_OWN) {
+
+	if (received < budget) {
 		netif_rx_complete(priv->dev, napi);
 		cpmac_write(priv->regs, CPMAC_RX_PTR(0), (u32)desc->mapping);
 		cpmac_write(priv->regs, CPMAC_RX_INT_ENABLE, 1);
-		return 0;
 	}
 
-	return 1;
+	return received;
 }
 
 static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)

From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [BUG] oops in net_rx_action on 64-bit powerpc
Date: Mon, 27 Oct 2008 18:13:54 -0600
Message-ID: <49065942.4040300@nortel.com>
References: <49025C94.60406@nortel.com> <20081024.164128.113131091.davem@davemloft.net> <4902B1D8.8070800@nortel.com> <20081025.001703.261277154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, romieu@fr.zoreil.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:55697 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbYJ1AON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 20:14:13 -0400
In-Reply-To: <20081025.001703.261277154.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:


 > Probably the simplest fix is to get rid of the rx_not_empty label and
 > protect the entire:
 >
 > 	/* Receive descriptor is empty now */
 > 	spin_lock_irqsave(&lp->lock, flags);
 > 	__netif_rx_complete(dev, napi);
 > 	writel(VAL0|RINTEN0, mmio + INTEN0);
 > 	writel(VAL2 | RDMD0, mmio + CMD0);
 > 	spin_unlock_irqrestore(&lp->lock, flags);
 >
 > code block with a test such as:
 >
 > 	if (rx_pkt_limit > 0)
 >
 > (yes, greater than zero, not >= 0)
 >
 > then replace the rx_not_empty goto with a simple break.


Are you sure about that?  Doing that, if we "--rx_pkt_limit < 0" we'll only 
break out of the inner while loop.  We then check then interrupt status 
register and potentially loop through the do/while loop again (maybe 
decrementing rx_pkt_limit again) even though we've used up our budget.

If I leave the label and jump and just add the "rx_pkt_limit > 0" test, it 
seems to work.

Chris


From: Chris Friesen    <cfriesen@nortel.com>
Subject: [PATCH] fix amd8111e rx return code

The amd8111e rx poll routine currently mishandles the case when we process
exactly the number of packets specified in the budget.

This patch is basically as suggested by David Miller.

Signed-off-by: Chris Friesen <cfriesen@nortel.com>

diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index c54967f..ba1be0b 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -833,12 +833,14 @@ static int amd8111e_rx_poll(struct napi_struct *napi, 
int budget)

  	} while(intr0 & RINT0);

-	/* Receive descriptor is empty now */
-	spin_lock_irqsave(&lp->lock, flags);
-	__netif_rx_complete(dev, napi);
-	writel(VAL0|RINTEN0, mmio + INTEN0);
-	writel(VAL2 | RDMD0, mmio + CMD0);
-	spin_unlock_irqrestore(&lp->lock, flags);
+	if (rx_pkt_limit > 0) {
+		/* Receive descriptor is empty now */
+		spin_lock_irqsave(&lp->lock, flags);
+		__netif_rx_complete(dev, napi);
+		writel(VAL0|RINTEN0, mmio + INTEN0);
+		writel(VAL2 | RDMD0, mmio + CMD0);
+		spin_unlock_irqrestore(&lp->lock, flags);
+	}

  rx_not_empty:
  	return num_rx_pkt;

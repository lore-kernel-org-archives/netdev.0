From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH RFC] netpoll: don't spin forever sending to stopped queues
Date: Mon, 12 Jun 2006 14:20:21 -0700
Message-ID: <448DDA95.90504@goop.org>
References: <44886381.9050506@goop.org> <20060608210702.GD24227@waste.org> <4488D9D6.6070205@goop.org> <20060611200407.GG24227@waste.org> <448DD556.6030705@goop.org> <20060612205310.GU24227@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:24721 "EHLO mail.goop.org")
	by vger.kernel.org with ESMTP id S932276AbWFLVUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 17:20:32 -0400
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20060612205310.GU24227@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> Ahh, right. I forgot that I'd done that. Can you resend?
>   
I just respun it against 2.6.17-rc6-mm2.

    J


--

Subject: netpoll: don't spin forever sending to blocked queues

When transmitting a skb in netpoll_send_skb(), only retry a limited
number of times if the device queue is stopped.

Signed-off-by: Jeremy Fitzhardinge <jeremy@goop.org>

diff -r 0b8d3d4ee182 net/core/netpoll.c
--- a/net/core/netpoll.c	Mon Jun 12 13:46:23 2006 -0700
+++ b/net/core/netpoll.c	Mon Jun 12 13:48:34 2006 -0700
@@ -279,14 +279,10 @@ static void netpoll_send_skb(struct netp
 		 * network drivers do not expect to be called if the queue is
 		 * stopped.
 		 */
-		if (netif_queue_stopped(np->dev)) {
-			netif_tx_unlock(np->dev);
-			netpoll_poll(np);
-			udelay(50);
-			continue;
-		}
-
-		status = np->dev->hard_start_xmit(skb, np->dev);
+		status = NETDEV_TX_BUSY;
+		if (!netif_queue_stopped(np->dev))
+			status = np->dev->hard_start_xmit(skb, np->dev);
+
 		netif_tx_unlock(np->dev);
 
 		/* success */



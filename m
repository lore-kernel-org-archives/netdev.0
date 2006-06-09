From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH RFC] netpoll: don't spin forever sending to stopped queues
Date: Thu, 08 Jun 2006 19:15:50 -0700
Message-ID: <4488D9D6.6070205@goop.org>
References: <44886381.9050506@goop.org> <20060608210702.GD24227@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:8833 "EHLO mail.goop.org")
	by vger.kernel.org with ESMTP id S965142AbWFIEEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 00:04:23 -0400
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20060608210702.GD24227@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> That's odd. Netpoll holds a reference to the device, of course, but so
> does a normal "up" interface. So that shouldn't be the problem.
> Another possibility is that outgoing packets from printks in the
> driver are causing difficulty. Not sure what can be done about that.
>   
Here's a patch.  I haven't tested it beyond compiling it, and I don't 
know if it is actually correct.  In this case, it seems pointless to 
spin waiting for an even which will never happen.  Should 
netif_poll_disable() cause netpoll_send_skb() (or something) to not even 
bother trying to send?  netif_poll_disable seems mysteriously simple to me.

    J

--

Subject: netpoll: don't spin forever sending to stopped queues

When transmitting a skb in netpoll_send_skb(), only retry a limited
number of times if the device queue is stopped.

Signed-off-by: Jeremy Fitzhardinge <jeremy@goop.org>

diff -r aac813f54617 net/core/netpoll.c
--- a/net/core/netpoll.c	Wed Jun 07 14:53:40 2006 -0700
+++ b/net/core/netpoll.c	Thu Jun 08 19:00:29 2006 -0700
@@ -280,15 +280,10 @@ static void netpoll_send_skb(struct netp
 		 * network drivers do not expect to be called if the queue is
 		 * stopped.
 		 */
-		if (netif_queue_stopped(np->dev)) {
-			np->dev->xmit_lock_owner = -1;
-			spin_unlock(&np->dev->xmit_lock);
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
 		np->dev->xmit_lock_owner = -1;
 		spin_unlock(&np->dev->xmit_lock);
 




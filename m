From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bug #14925] sky2 panic under load
Date: Mon, 11 Jan 2010 08:45:04 -0800
Message-ID: <20100111084504.7adb5a1e@nehalam>
References: <wnS54-l8PVO.A.TlF.oMlSLB@chimera>
	<omZ8aBZReyD.A.I-H.eNlSLB@chimera>
	<4B4A729E.9060805@gmail.com>
	<4B4B2FBD.5090007@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Berck E. Nash" <flyboy@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	Jarek Poplawski <jarkao2@gmail.com>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44415 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751050Ab0AKQrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2010 11:47:03 -0500
In-Reply-To: <4B4B2FBD.5090007@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Jan 2010 23:03:41 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> Perhaps only sky2_tx_done should wake the queue?
> Does the patch below fix the problem too?
> 
> thanks,
> 
> Mike

The idea is good, but what if transmit queue was full (stopped),
and TX FIFO gets stuck.  Then Transmit timeout happens and
the reset logic clears the queue.  What will start the queue?

Something like this:
-----------------------------------------------------------



--- a/drivers/net/sky2.c	2010-01-11 08:36:42.617426300 -0800
+++ b/drivers/net/sky2.c	2010-01-11 08:42:51.295237661 -0800
@@ -1843,9 +1843,6 @@ static void sky2_tx_complete(struct sky2
 
 	sky2->tx_cons = idx;
 	smp_mb();
-
-	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
-		netif_wake_queue(dev);
 }
 
 static void sky2_tx_reset(struct sky2_hw *hw, unsigned port)
@@ -2416,8 +2413,12 @@ static inline void sky2_tx_done(struct n
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	if (netif_running(dev))
+	if (netif_running(dev) && netif_device_present(dev)) {
 		sky2_tx_complete(sky2, last);
+
+		if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
+			netif_wake_queue(dev);
+	}
 }
 
 static inline void sky2_skb_rx(const struct sky2_port *sky2,
@@ -3197,6 +3198,7 @@ static int sky2_reattach(struct net_devi
 		} else {
 			netif_device_attach(dev);
 			sky2_set_multicast(dev);
+			netif_start_queue(dev);
 		}
 	}
 

-- 

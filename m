From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning (v4)
Date: Thu, 14 Jan 2010 22:19:39 +0900
Message-ID: <4B4F19EB.5080207@ring3k.org>
References: <20100113194148.139091a3@nehalam> <20100114101445.GA7210@ff.dom.local> <20100114111636.GB7210@ff.dom.local> <20100114.032009.20669539.davem@davemloft.net> <20100114112653.GA8543@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	mbreuer@majjas.com, flyboy@gmail.com, rjw@sisk.pl,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:45962 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756591Ab0ANNXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 08:23:47 -0500
Received: by pzk1 with SMTP id 1so8234832pzk.33
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2010 05:23:46 -0800 (PST)
In-Reply-To: <20100114112653.GA8543@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Thu, Jan 14, 2010 at 03:20:09AM -0800, David Miller wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Thu, 14 Jan 2010 11:16:36 +0000
>>
>>> So, now I really ;-) agree with David: this needs a proper fix.
>> Now Jarek, do you now see my dirty little secret?
>>
>> When people disagree with me, I just silently sit around waiting for
>> them to eventually change their mind.
>>
>> Isn't it brilliant? -)
> 
> If it were that easy... (it never works for me :-()
> 
> Probably, there is something more... ;-)

Here's what was sitting in my tree...


Subject: [PATCH] sky2: Don't detach device when restarting

Block the tx queue from transmitting when restarting
 rather than trying to take the device offline.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index d76d907..061f6f2 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1580,6 +1580,8 @@ static int sky2_up(struct net_device *dev)
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
 
+	netif_start_queue(dev);
+
 	return 0;
 
 err_out:
@@ -1596,6 +1598,8 @@ static inline int tx_inuse(const struct sky2_port *sky2)
 /* Number of list elements available for next tx */
 static inline int tx_avail(const struct sky2_port *sky2)
 {
+	if (unlikely(!sky2->tx_ring))
+		return 0;
 	return sky2->tx_pending - tx_inuse(sky2);
 }
 
@@ -1925,7 +1929,9 @@ static int sky2_down(struct net_device *dev)
 	sky2_read32(hw, B0_IMSK);
 
 	synchronize_irq(hw->pdev->irq);
-	napi_synchronize(&hw->napi);
+	netif_tx_lock_bh(dev);
+	napi_disable(&hw->napi);
+	netif_stop_queue(dev);
 
 	spin_lock_bh(&sky2->phy_lock);
 	sky2_phy_power_down(hw, port);
@@ -1939,6 +1945,8 @@ static int sky2_down(struct net_device *dev)
 	sky2_rx_clean(sky2);
 
 	sky2_free_buffers(sky2);
+	napi_enable(&hw->napi);
+	netif_tx_unlock_bh(dev);
 
 	return 0;
 }
@@ -3177,9 +3185,6 @@ static void sky2_reset(struct sky2_hw *hw)
 static void sky2_detach(struct net_device *dev)
 {
 	if (netif_running(dev)) {
-		netif_tx_lock_bh(dev);
-		netif_device_detach(dev);	/* stop txq */
-		netif_tx_unlock_bh(dev);
 		sky2_down(dev);
 	}
 }
-- 1.5.6.5 

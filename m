From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fwd: Re: Linux r8169 interrupt patch
Date: Wed, 25 Aug 2010 00:07:08 +0200
Message-ID: <20100824220707.GA24183@electric-eye.fr.zoreil.com>
References: <4C6FBF5D.2070409@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, rjw@sisk.pl, davem@davemloft.net,
	adobriyan@gmail.com, jpirko@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alex <alexbtk@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 11.50.140-88.rev.gaoland.net ([88.140.50.11]:47836 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755414Ab0HXW3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 18:29:19 -0400
Content-Disposition: inline
In-Reply-To: <4C6FBF5D.2070409@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex <alexbtk@gmx.de> :
[...]
> I am writing to you, on case of the linux r8169 interrupt bug.
> Sergey gave me your addresses. I assume you can read all the
> neccessary informations below. Please reopen the thread at the
> bugtracker.
> I have several servers running with this chipset and driver. In my
> case, the problem is very critical. Network brokes even every day
> down. I can provide some testing if you would give me some patches
> or solution tips.

Can you send a complete dmesg from boot until problem and give the
patch below a try ?

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 078bbf4..ec706d2 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4327,13 +4327,13 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	tp->cur_tx += frags + 1;
 
-	wmb();
-
 	RTL_W8(TxPoll, NPQ);	/* set polling bit */
 
+	mmiowb();
+
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
-		smp_rmb();
+		smp_mb();
 		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
 			netif_wake_queue(dev);
 	}
@@ -4428,10 +4428,14 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
-		smp_wmb();
-		if (netif_queue_stopped(dev) &&
-		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
-			netif_wake_queue(dev);
+		smp_mb();
+		if (unlikely(netif_queue_stopped(dev) &&
+		    (TX_BUFFS_AVAIL(tp) >= (NUM_TX_DESC / 4)))) {
+			netif_tx_lock(dev);
+			if (netif_queue_stopped(dev) &&
+			    (TX_BUFFS_AVAIL(tp) >= (NUM_TX_DESC / 4)))
+				netif_wake_queue(dev);
+			netif_tx_unlock(dev);
 		}
 		/*
 		 * 8168 hack: TxPoll requests are lost when the Tx packets are

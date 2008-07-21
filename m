From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Tue, 22 Jul 2008 01:24:48 +0400
Message-ID: <20080721212447.GA10107@2ka.mipt.ru>
References: <20080717214222.GA29449@elte.hu> <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI> <20080718091146.GQ6875@elte.hu> <20080721094110.GA16029@elte.hu> <84144f020807210252k68d5cf65i8c7ae3c11cecc046@mail.gmail.com> <20080721100627.GA5953@2ka.mipt.ru> <20080721105051.GA5830@elte.hu> <20080721112515.GA4777@2ka.mipt.ru> <20080721115555.GA24176@elte.hu> <20080721192138.GA27672@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Vegard Nossum <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, cl@linux-foundation.org,
	davem@davemloft.net, Auke Kok <auke-jan.h.kok@intel.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:36414 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836AbYGUVZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 17:25:56 -0400
Content-Disposition: inline
In-Reply-To: <20080721192138.GA27672@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2008 at 09:21:38PM +0200, Ingo Molnar (mingo@elte.hu) wrote:
> So it's now a strong likelyhood that this crash is a combination of 
> e1000e+netconsole.

e1000_clean_tx_irq() call looks particulary suspicious: it is called
without adapter->tx_queue_lock in poll controller (netconsole callback)
and with that lock in NAPI handler.

Can you check kind of this patch:

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 869544b..5f180d8 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4067,7 +4067,9 @@ static void e1000_netpoll(struct net_device *netdev)
 	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev);
 
+	spin_lock(&adapter->tx_queue_lock);
 	e1000_clean_tx_irq(adapter);
+	spin_unlock(&adapter->tx_queue_lock);
 
 	enable_irq(adapter->pdev->irq);
 }


-- 
	Evgeniy Polyakov

From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 08:35:27 -0700 (PDT)
Message-ID: <20080721.083527.199623566.davem@davemloft.net>
References: <20080720.221106.201055562.davem@davemloft.net>
	<a4423d670807210248l1e2e6999ha462edc99002f964@mail.gmail.com>
	<20080721101626.GM10471@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.beregalov@gmail.com, adobriyan@gmail.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754714AbYGUPf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 11:35:27 -0400
In-Reply-To: <20080721101626.GM10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 21 Jul 2008 11:16:27 +0100

> Alexander Beregalov wrote:
> > Hi David!
> > 
> > There is another problem on sparc64 and happymeal ethernet card.
> > 
> > when tring to up interface:
> > 
> > kernel BUG at net/core/dev.c:1328
> [...]
> 
> This is yet another driver calling netif_wake_queue() during dev_open(),
> when there is no real qdisc present.  (And yes, sfc is another of those
> drivers - I will post a patch after internal review.)

Yep, what idiot wrote this driver? ;-)

Alexander please try this patch:

sunhme: Remove stop/wake TX queue calls in set-multicast-list handler.

Based upon a bug report by Alexander Beregalov and commentary
from Ben Hutchings.

These are totally unnecessary, in particular because this
driver's ->hard_start_xmit() handler takes the same driver
spinlock that the set-multicast-list handler uses.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 1aa425b..b79d5f0 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2377,8 +2377,6 @@ static void happy_meal_set_multicast(struct net_device *dev)
 
 	spin_lock_irq(&hp->happy_lock);
 
-	netif_stop_queue(dev);
-
 	if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 64)) {
 		hme_write32(hp, bregs + BMAC_HTABLE0, 0xffff);
 		hme_write32(hp, bregs + BMAC_HTABLE1, 0xffff);
@@ -2410,8 +2408,6 @@ static void happy_meal_set_multicast(struct net_device *dev)
 		hme_write32(hp, bregs + BMAC_HTABLE3, hash_table[3]);
 	}
 
-	netif_wake_queue(dev);
-
 	spin_unlock_irq(&hp->happy_lock);
 }
 

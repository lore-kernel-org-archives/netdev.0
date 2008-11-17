From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: [2.6.26] OOPS in __linkwatch_run_queue (unable to
 handle kernel NULL pointer dereference at 00000235)
Date: Mon, 17 Nov 2008 00:50:25 -0800 (PST)
Message-ID: <20081117.005025.141630310.davem@davemloft.net>
References: <20081030020910.f97ee3fc.akpm@linux-foundation.org>
	<20081117084058.GA6345@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: folkert@vanheusden.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38054
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752606AbYKQIu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 03:50:26 -0500
In-Reply-To: <20081117084058.GA6345@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 17 Nov 2008 08:40:58 +0000

> net: link_watch: Don't add a linkwatch event before register_netdev()
> 
> b44 and some other network drivers run netif_carrier_off() before
> register_netdev(). Then, if register fails, free_netdev() destruction
> is done while dev is still referenced and held on the lweventlist.
> 
> Of course, it would be nice if all drivers could use some common order
> of calling things like register_netdev() vs. netif_carrier_off(), but
> since there is a lot of this I guess there is probably some reason,
> so this patch doesn't change the order but assumes that such an early
> netif_carrier_off() is only to set the __LINK_STATE_NOCARRIER flag,
> and some netif_carrier_on()/_off() will still follow.
> 
> Reported-by: Folkert van Heusden <folkert@vanheusden.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Ugh, drivers should not be fiddling with stuff like this before the
device object is even registered.

I can just imagine all sorts of other operations drivers might find
it "convenient" to do before the sucker is even registered, causing
similar if not even worse problems.

It's pretty simple, make netif_carrier_off() be the first thing
->open() does and make it the last thing ->stop() and ->suspend()
do.  That's how to fix this bug.

I'm going to fix this as follows.  B44 already abided by 2/3 of
this by handling the ->stop() and ->suspend() cases correctly already.

b44: Do not call netif_carrier_off() before device is even registered.

This is illegal.  Instead simply do this first thing in ->open().

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index c3bda5c..2e353b8 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1426,6 +1426,8 @@ static int b44_open(struct net_device *dev)
 	struct b44 *bp = netdev_priv(dev);
 	int err;
 
+	netif_carrier_off(dev);
+
 	err = b44_alloc_consistent(bp, GFP_KERNEL);
 	if (err)
 		goto out;
@@ -2165,8 +2167,6 @@ static int __devinit b44_init_one(struct ssb_device *sdev,
 	dev->irq = sdev->irq;
 	SET_ETHTOOL_OPS(dev, &b44_ethtool_ops);
 
-	netif_carrier_off(dev);
-
 	err = ssb_bus_powerup(sdev->bus, 0);
 	if (err) {
 		dev_err(sdev->dev,

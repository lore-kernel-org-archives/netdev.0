From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Patch for tbench regression.
Date: Mon, 29 Sep 2008 01:15:30 +0400
Message-ID: <20080928211530.GA9341@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:39430 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670AbYI1VRD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Sep 2008 17:17:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Attached patch fixes (at least partially) tbench regressions reported
recently. I ran it on 4-way machine and noticed more than 20%
performance degradation comapred to 2.6.22 kernel. Unfortunately all my
remote machine are now stuck in death at various (apparently unbootable)
bisections, so I switched to the Xen domain, which only has 256 mb of
RAM and is generally very slow.

Because of that I was not able to run 2.6.22 tree (compilation and git
operations take really long time on this 'machine' and it is middle of
the night in Moscow), but I tested it on 2.6.27-rc7 and was able reach
performance higher than 2.6.26. According to my tests there were no
noticeble regressions in 2.6.24-2.6.26, so this patch should at least
fix 2.6.26->2.6.27 one.

Idea is rather trivial: disable TSO and GSO on loopback. The latter was
actually enabled by bisected e5a4a72d4f8 commit, which enables GSO
unconditionally if device supports scatter/gather and checksumming.
Apparently GSO packet construction has bigger overhead and smaller
packet processing. I did not bisect TSO in loopback patch, but concluded
it from above (actually its gain is even bigger than GSO on SG
device).

I will try to bring my tast machines back tomorrow and run it there,
but patch does fix the same regression tested in small Xen domain.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 3b43bfd..a22ae35 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -169,7 +169,6 @@ static void loopback_setup(struct net_device *dev)
 	dev->type		= ARPHRD_LOOPBACK;	/* 0x0001*/
 	dev->flags		= IFF_LOOPBACK;
 	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
-		| NETIF_F_TSO
 		| NETIF_F_NO_CSUM
 		| NETIF_F_HIGHDMA
 		| NETIF_F_LLTX
diff --git a/net/core/dev.c b/net/core/dev.c
index e8eb2b4..dddb5c2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4003,10 +4003,6 @@ int register_netdevice(struct net_device *dev)
 		}
 	}
 
-	/* Enable software GSO if SG is supported. */
-	if (dev->features & NETIF_F_SG)
-		dev->features |= NETIF_F_GSO;
-
 	netdev_initialize_kobject(dev);
 	ret = netdev_register_kobject(dev);
 	if (ret)


-- 
	Evgeniy Polyakov

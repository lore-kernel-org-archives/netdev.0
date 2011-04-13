From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 1/2] net: Disable all TSO features when SG is
 disabled
Date: Wed, 13 Apr 2011 01:38:37 +0100
Message-ID: <1302655117.2880.33.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:16423 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757475Ab1DMAik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 20:38:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The feature flags NETIF_F_TSO and NETIF_F_TSO6 independently enable
TSO for IPv4 and IPv6 respectively.  However, the test in
netdev_fix_features() and its predecessor functions was never updated
to check for NETIF_F_TSO6, possibly because it was originally proposed
that TSO for IPv6 would be dependent on both feature flags.

Now that these feature flags can be changed independently from
user-space and we depend on netdev_fix_features() to fix invalid
feature combinations, it's important to disable them both if
scatter-gather is disabled.  Also disable NETIF_F_TSO_ECN so
user-space sees all TSO features as disabled.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/dev.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 956d3b0..6401fb5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5203,9 +5203,9 @@ u32 netdev_fix_features(struct net_device *dev, u32 features)
 	}
 
 	/* TSO requires that SG is present as well. */
-	if ((features & NETIF_F_TSO) && !(features & NETIF_F_SG)) {
-		netdev_info(dev, "Dropping NETIF_F_TSO since no SG feature.\n");
-		features &= ~NETIF_F_TSO;
+	if ((features & NETIF_F_ALL_TSO) && !(features & NETIF_F_SG)) {
+		netdev_info(dev, "Dropping TSO features since no SG feature.\n");
+		features &= ~NETIF_F_ALL_TSO;
 	}
 
 	/* Software GSO depends on SG. */
-- 
1.7.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


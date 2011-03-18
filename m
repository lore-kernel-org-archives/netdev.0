From: Roger Luethi <rl@hellgate.ch>
Subject: [PATCH] net: drop NETIF_F_GSO from hw_features without NETIF_F_SG
Date: Fri, 18 Mar 2011 20:50:30 +0100
Message-ID: <20110318195030.GA22350@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail11.bluewin.ch ([195.186.18.61]:51802 "EHLO
	mail11.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756770Ab1CRTua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 15:50:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

register_netdevice() removes NETIF_F_GSO from dev->features and
dev->wanted_features for hardware without NETIF_F_SG to "avoid warning from
netdev_fix_features()".

However, as the flag remains set in dev->hw_features, users trying to
enable GSO via ethtool will still end up with NETIF_F_GSO stuck in
wanted_features, resulting in a warning every time they try to change any
feature (until they use ethtool to "disable" GSO):

# ethtool -K eth2 gso on
via-rhine 0000:03:00.0: eth2: Dropping NETIF_F_GSO since no SG feature.
# ethtool -K eth2 rx on
via-rhine 0000:03:00.0: eth2: Dropping NETIF_F_GSO since no SG feature.
via-rhine 0000:03:00.0: eth2: Features changed: 0x00004380 -> 0x20004380
# ethtool -K eth2 rx off
via-rhine 0000:03:00.0: eth2: Dropping NETIF_F_GSO since no SG feature.
via-rhine 0000:03:00.0: eth2: Features changed: 0x20004380 -> 0x00004380
# ethtool -K eth2 gso off
#

With NETIF_F_GSO depending on NETIF_F_SG, it seems we should not
advertise the former as a changeable option if the latter is missing.
---
 net/core/dev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0d39032..122d4ca 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5433,6 +5433,7 @@ int register_netdevice(struct net_device *dev)
 
 	/* Avoid warning from netdev_fix_features() for GSO without SG */
 	if (!(dev->wanted_features & NETIF_F_SG)) {
+		dev->hw_features &= ~NETIF_F_GSO;
 		dev->wanted_features &= ~NETIF_F_GSO;
 		dev->features &= ~NETIF_F_GSO;
 	}
-- 
1.7.3.4


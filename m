From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net v3 2/2] macvlan: disable LRO on lower device instead of
 macvlan
Date: Fri, 15 Nov 2013 06:18:50 +0100 (CET)
Message-ID: <78e25272199f3dfba4ecc0787994706f37caab82.1384492269.git.mkubecek@suse.cz>
References: <cover.1384492269.git.mkubecek@suse.cz>
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52857 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751382Ab3KOFSv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Nov 2013 00:18:51 -0500
In-Reply-To: <cover.1384492269.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A macvlan device has always LRO disabled so that calling
dev_disable_lro() on it does nothing. If we need to disable LRO
e.g. because

  - the macvlan device is inserted into a bridge
  - IPv6 forwarding is enabled for it
  - it is in a different namespace than lowerdev and IPv4
    forwarding is enabled in it

we need to disable LRO on its underlying device instead (as we
do for 802.1q VLAN devices).

v2: use newly introduced netif_is_macvlan()

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/core/dev.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 974143d..7e00a73 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -131,6 +131,7 @@
 #include <linux/static_key.h>
 #include <linux/hashtable.h>
 #include <linux/vmalloc.h>
+#include <linux/if_macvlan.h>
 
 #include "net-sysfs.h"
 
@@ -1424,6 +1425,10 @@ void dev_disable_lro(struct net_device *dev)
 	if (is_vlan_dev(dev))
 		dev = vlan_dev_real_dev(dev);
 
+	/* the same for macvlan devices */
+	if (netif_is_macvlan(dev))
+		dev = macvlan_dev_real_dev(dev);
+
 	dev->wanted_features &= ~NETIF_F_LRO;
 	netdev_update_features(dev);
 
-- 
1.8.1.4

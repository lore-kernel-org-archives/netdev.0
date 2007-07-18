From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH 2/3] [net/core] merge dev_unicast_discard and dev_mc_discard into one
Date: Wed, 18 Jul 2007 10:41:04 +0800
Message-ID: <11847264751175-git-send-email-crquan@gmail.com>
References: <11846606051099-git-send-email-crquan@gmail.com>
 <11847264651509-git-send-email-crquan@gmail.com>
Cc: Pekka Savola <pekkas@netcore.fi>, James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@coreworks.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Denis Cheng <crquan@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Networking Team <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.233]:59690 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933735AbXGRClG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 22:41:06 -0400
Received: by qb-out-0506.google.com with SMTP id e11so42985qbe
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2007 19:41:05 -0700 (PDT)
In-Reply-To: <11847264651509-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this two functions could share the dev->_xmit_lock acquired context.

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 net/core/dev.c |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3ba63aa..17c9cbd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2777,23 +2777,16 @@ int dev_unicast_add(struct net_device *dev, void *addr, int alen)
 }
 EXPORT_SYMBOL(dev_unicast_add);
 
-static void dev_unicast_discard(struct net_device *dev)
+static void dev_addr_discard(struct net_device *dev)
 {
 	netif_tx_lock_bh(dev);
+
 	__dev_addr_discard(&dev->uc_list);
 	dev->uc_count = 0;
-	netif_tx_unlock_bh(dev);
-}
 
-/*
- *	Discard multicast list when a device is downed
- */
-
-static void dev_mc_discard(struct net_device *dev)
-{
-	netif_tx_lock_bh(dev);
 	__dev_addr_discard(&dev->mc_list);
 	dev->mc_count = 0;
+
 	netif_tx_unlock_bh(dev);
 }
 
@@ -3751,8 +3744,7 @@ void unregister_netdevice(struct net_device *dev)
 	/*
 	 *	Flush the unicast and multicast chains
 	 */
-	dev_unicast_discard(dev);
-	dev_mc_discard(dev);
+	dev_addr_discard(dev);
 
 	if (dev->uninit)
 		dev->uninit(dev);
-- 
1.5.2.2


From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] 6lowpan: fix lockdep splats
Date: Mon, 10 Feb 2014 11:42:35 -0800
Message-ID: <1392061355.6615.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140209102047.GA14770@omega>
	 <1391949707.10160.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Alexander Aring <alex.aring@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:38793 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284AbaBJTmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 14:42:38 -0500
Received: by mail-pa0-f51.google.com with SMTP id ld10so6642399pab.38
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 11:42:37 -0800 (PST)
In-Reply-To: <1391949707.10160.130.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When a device ndo_start_xmit() calls again dev_queue_xmit(),
lockdep can complain because dev_queue_xmit() is re-entered and the
spinlocks protecting tx queues share a common lockdep class.

Same issue was fixed for bonding/l2tp/ppp in commits 

0daa2303028a6 ("[PATCH] bonding: lockdep annotation")
49ee49202b4ac ("bonding: set qdisc_tx_busylock to avoid LOCKDEP splat")
23d3b8bfb8eb2 ("net: qdisc busylock needs lockdep annotations ")
303c07db487be ("ppp: set qdisc_tx_busylock to avoid LOCKDEP splat ")

Reported-by: Alexander Aring <alex.aring@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Alexander Aring <alex.aring@gmail.com>
---
 net/ieee802154/6lowpan.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 8bfb40153fe7..8edfea5da572 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -530,7 +530,27 @@ static struct header_ops lowpan_header_ops = {
 	.create	= lowpan_header_create,
 };
 
+static struct lock_class_key lowpan_tx_busylock;
+static struct lock_class_key lowpan_netdev_xmit_lock_key;
+
+static void lowpan_set_lockdep_class_one(struct net_device *dev,
+					 struct netdev_queue *txq,
+					 void *_unused)
+{
+	lockdep_set_class(&txq->_xmit_lock,
+			  &lowpan_netdev_xmit_lock_key);
+}
+
+
+static int lowpan_dev_init(struct net_device *dev)
+{
+	netdev_for_each_tx_queue(dev, lowpan_set_lockdep_class_one, NULL);
+	dev->qdisc_tx_busylock = &lowpan_tx_busylock;
+	return 0;
+}
+
 static const struct net_device_ops lowpan_netdev_ops = {
+	.ndo_init		= lowpan_dev_init,
 	.ndo_start_xmit		= lowpan_xmit,
 	.ndo_set_mac_address	= lowpan_set_address,
 };

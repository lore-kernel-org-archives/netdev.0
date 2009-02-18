From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] net: Simplify skb_tx_hash()
Date: Wed, 18 Feb 2009 11:02:11 +0530
Message-ID: <20090218053211.16619.33544.sendpatchset@localhost.localdomain>
Cc: davem@davemloft.net, Krishna Kumar <krkumar2@in.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:52135 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382AbZBRGnt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2009 01:43:49 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1I6iZ1N004487
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 01:44:35 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1I6hmRk187134
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 01:43:48 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1I6faqJ014295
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 01:42:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

The initialization of skb_tx_hashrnd is moved so that it gets called
after "random" driver is initialized. Random numbers generated at this
point are different across 3 immediate reboots:
	(reboot1) Random number: 0xd52f08b6
	(reboot2) Random number: 0x8beeef46
	(reboot3) Random number: 0x7d60a4b6

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

 net/core/dev.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff -ruNp net-next-2.6.org/net/core/dev.c net-next-2.6.new/net/core/dev.c
--- net-next-2.6.org/net/core/dev.c	2009-02-17 18:57:15.000000000 +0530
+++ net-next-2.6.new/net/core/dev.c	2009-02-17 19:00:23.000000000 +0530
@@ -1745,17 +1745,11 @@ out_kfree_skb:
 }
 
 static u32 skb_tx_hashrnd;
-static int skb_tx_hashrnd_initialized = 0;
 
 static u16 skb_tx_hash(struct net_device *dev, struct sk_buff *skb)
 {
 	u32 hash;
 
-	if (unlikely(!skb_tx_hashrnd_initialized)) {
-		get_random_bytes(&skb_tx_hashrnd, 4);
-		skb_tx_hashrnd_initialized = 1;
-	}
-
 	if (skb_rx_queue_recorded(skb)) {
 		hash = skb_get_rx_queue(skb);
 	} else if (skb->sk && skb->sk->sk_hash) {
@@ -5291,6 +5285,14 @@ out:
 
 subsys_initcall(net_dev_init);
 
+static int __init initialize_hashrnd(void)
+{
+	get_random_bytes(&skb_tx_hashrnd, sizeof(skb_tx_hashrnd));
+	return 0;
+}
+
+late_initcall_sync(initialize_hashrnd);
+
 EXPORT_SYMBOL(__dev_get_by_index);
 EXPORT_SYMBOL(__dev_get_by_name);
 EXPORT_SYMBOL(__dev_remove_pack);

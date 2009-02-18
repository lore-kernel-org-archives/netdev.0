From: Krishna Kumar <krikku@gmail.com>
Subject: [PATCH] net: Optimize skb_tx_hash() by eliminating a comparison
Date: Wed, 18 Feb 2009 14:50:16 +0530
Message-ID: <20090218092016.25153.14234.sendpatchset@localhost.localdomain>
Cc: davem@davemloft.net, Krishna Kumar <krkumar2@in.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.188]:28652 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415AbZBRJUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 04:20:34 -0500
Received: by ti-out-0910.google.com with SMTP id d10so2338946tib.23
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 01:20:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Optimize skb_tx_hash() by eliminating a comparison that executes for
every packet. skb_tx_hashrnd initialization is moved to a later part of
the startup sequence, namely after the "random" driver is initialized.

Rebooted the system three times and verified that the code generates
different random numbers each time.

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

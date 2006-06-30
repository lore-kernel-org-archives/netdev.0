From: Ralf Baechle <ralf@linux-mips.org>
Subject: [ROSE] Fix dereference of skb pointer after free.
Date: Fri, 30 Jun 2006 14:36:14 +0100
Message-ID: <20060630133614.GA11735@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:37546 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S932138AbWF3NgQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 09:36:16 -0400
Received: from localhost.localdomain ([127.0.0.1]:19398 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S3686805AbWF3NgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 14:36:15 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If rose_route_frame return success we'll dereference a stale pointer.
Likely this is only going to result in bad statistics for the ROSE
interface.

This fixes coverity 946.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
 net/rose/rose_dev.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-net/net/rose/rose_dev.c
===================================================================
--- linux-net.orig/net/rose/rose_dev.c	2006-06-23 22:40:27.000000000 +0100
+++ linux-net/net/rose/rose_dev.c	2006-06-23 22:42:56.000000000 +0100
@@ -60,6 +60,7 @@ static int rose_rebuild_header(struct sk
 	struct net_device_stats *stats = netdev_priv(dev);
 	unsigned char *bp = (unsigned char *)skb->data;
 	struct sk_buff *skbn;
+	unsigned int len;
 
 #ifdef CONFIG_INET
 	if (arp_find(bp + 7, skb)) {
@@ -76,6 +77,8 @@ static int rose_rebuild_header(struct sk
 
 	kfree_skb(skb);
 
+	len = skbn->len;
+
 	if (!rose_route_frame(skbn, NULL)) {
 		kfree_skb(skbn);
 		stats->tx_errors++;
@@ -83,7 +86,7 @@ static int rose_rebuild_header(struct sk
 	}
 
 	stats->tx_packets++;
-	stats->tx_bytes += skbn->len;
+	stats->tx_bytes += len;
 #endif
 	return 1;
 }

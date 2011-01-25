From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 1/2] xen: netfront: refactor code for checking validity of incoming skbs
Date: Tue, 25 Jan 2011 17:09:59 +0000
Message-ID: <1295975400-538-1-git-send-email-ian.campbell@citrix.com>
References: <1295975376.14780.6595.camel@zakaz.uk.xensource.com>
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:35120 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571Ab1AYRKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 12:10:05 -0500
In-Reply-To: <1295975376.14780.6595.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makes future additional validation clearer.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: xen-devel@lists.xensource.com
Cc: netdev@vger.kernel.org
---
 drivers/net/xen-netfront.c |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 546de57..4dc347b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -809,6 +809,18 @@ out:
 	return err;
 }
 
+static int validate_incoming_skb(struct sk_buff *skb)
+{
+	/*
+	 * If the SKB is partial then we must be able to setup the
+	 * checksum fields in the skb.
+	 */
+	if (skb->ip_summed == CHECKSUM_PARTIAL && skb_checksum_setup(skb))
+		return 0;
+
+	return 1;
+}
+
 static int handle_incoming_queue(struct net_device *dev,
 				 struct sk_buff_head *rxq)
 {
@@ -829,13 +841,11 @@ static int handle_incoming_queue(struct net_device *dev,
 		/* Ethernet work: Delayed to here as it peeks the header. */
 		skb->protocol = eth_type_trans(skb, dev);
 
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			if (skb_checksum_setup(skb)) {
-				kfree_skb(skb);
-				packets_dropped++;
-				dev->stats.rx_errors++;
-				continue;
-			}
+		if (!validate_incoming_skb(skb)) {
+			kfree_skb(skb);
+			packets_dropped++;
+			dev->stats.rx_errors++;
+			continue;
 		}
 
 		dev->stats.rx_packets++;
-- 
1.5.6.5


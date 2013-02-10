From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next (TAKE 3) 2/6] firewire net: Accept IPv4 and ARP only.
Date: Mon, 11 Feb 2013 02:46:53 +0900
Message-ID: <5117DD0D.2080408@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: stephan.gatzka@gmail.com, davem@davemloft.net,
	stefanr@s5r6.in-berlin.de, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38855 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755664Ab3BJRqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 12:46:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 4382c20..98d3ec7 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -517,6 +517,14 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 	int status;
 	__be64 guid;
 
+	switch (ether_type) {
+	case ETH_P_ARP:
+	case ETH_P_IP:
+		break;
+	default:
+		goto err;
+	}
+
 	dev = netdev_priv(net);
 	/* Write metadata, and then pass to the receive level */
 	skb->dev = net;
@@ -637,6 +645,7 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 	return 0;
 
  no_peer:
+ err:
 	net->stats.rx_errors++;
 	net->stats.rx_dropped++;
 
@@ -1283,9 +1292,17 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
 	 * We might need to rebuild the header on tx failure.
 	 */
 	memcpy(&hdr_buf, skb->data, sizeof(hdr_buf));
-	skb_pull(skb, sizeof(hdr_buf));
-
 	proto = hdr_buf.h_proto;
+
+	switch (proto) {
+	case htons(ETH_P_ARP):
+	case htons(ETH_P_IP):
+		break;
+	default:
+		goto fail;
+	}
+
+	skb_pull(skb, sizeof(hdr_buf));
 	dg_size = skb->len;
 
 	/*
-- 
1.7.9.5

From: Tom Herbert <therbert@google.com>
Subject: [PATCH 4/4] vxlan: Checksum fixes
Date: Thu, 12 Jun 2014 16:04:28 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406121558460.30583@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:61512 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbaFLXE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 19:04:29 -0400
Received: by mail-ig0-f202.google.com with SMTP id r2so210660igi.1
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 16:04:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call skb_pop_rcv_encapsulation and postpull_rcsum for the Ethernet
header to work properly with checksum complete.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1610d51..0016fcc 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1156,15 +1156,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!vs)
 		goto drop;
 
-	/* If the NIC driver gave us an encapsulated packet
-	 * with the encapsulation mark, the device checksummed it
-	 * for us. Otherwise force the upper layers to verify it.
-	 */
-	if ((skb->ip_summed != CHECKSUM_UNNECESSARY && skb->ip_summed != CHECKSUM_PARTIAL) ||
-	    !skb->encapsulation)
-		skb->ip_summed = CHECKSUM_NONE;
-
-	skb->encapsulation = 0;
+	skb_pop_rcv_encapsulation(skb);
 
 	vs->rcv(vs, skb, vxh->vx_vni);
 	return 0;
@@ -1201,6 +1193,7 @@ static void vxlan_rcv(struct vxlan_sock *vs,
 	skb_reset_mac_header(skb);
 	skb_scrub_packet(skb, !net_eq(vxlan->net, dev_net(vxlan->dev)));
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
+	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 
 	/* Ignore packet loops (and multicast echo) */
 	if (ether_addr_equal(eth_hdr(skb)->h_source, vxlan->dev->dev_addr))
-- 
2.0.0.526.g5318336

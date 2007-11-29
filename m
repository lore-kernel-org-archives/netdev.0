From: jamal <hadi@cyberus.ca>
Subject: [PATCH 1/2] [IPSEC]: Reinject v4 packet on input instead of
	calling netfilter
Date: Thu, 29 Nov 2007 15:51:18 -0500
Message-ID: <1196369478.4437.21.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-zmk4Ud01Qbhtqa6Cs0pP"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:38394 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759633AbXK2UvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 15:51:24 -0500
Received: by py-out-1112.google.com with SMTP id u77so3846372pyb
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 12:51:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-zmk4Ud01Qbhtqa6Cs0pP
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


1 of 2.

cheers,
jamal

--=-zmk4Ud01Qbhtqa6Cs0pP
Content-Disposition: attachment; filename*0=0001-IPSEC-Reinject-v4-packet-on-input-instead-of-calling-net; filename*1=filter.txt
Content-Type: application/mbox; name*0=0001-IPSEC-Reinject-v4-packet-on-input-instead-of-calling-netfilt; name*1=er.txt
Content-Transfer-Encoding: 7bit

>From 682cee2131477497a2c8ee9bf4d0c2c8c030956f Mon Sep 17 00:00:00 2001
From: Jamal Hadi Salim <hadi@cyberus.ca>
Date: Thu, 29 Nov 2007 15:37:31 -0500
Subject: [PATCH 1/2] [IPSEC]: Reinject v4 packet on input instead of calling netfilter

Derived from an earlier down-trodden patch from Herbert.
We re-inject a decrypted ipsec back and let it bubble up the network
stack. This improves packet debugability (since sniffers like tcpdump
can see the packet) and ingress tc filters can act on it.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 net/ipv4/xfrm4_input.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 0c377a6..1271668 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -50,20 +50,25 @@ int xfrm4_transport_finish(struct sk_buff *skb, int async)
 
 	iph->protocol = XFRM_MODE_SKB_CB(skb)->protocol;
 
-#ifdef CONFIG_NETFILTER
+	if (async)
+		return xfrm4_rcv_encap_finish(skb);
+
 	__skb_push(skb, skb->data - skb_network_header(skb));
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
 
-	NF_HOOK(PF_INET, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
-		xfrm4_rcv_encap_finish);
-	return 0;
-#else
-	if (async)
-		return xfrm4_rcv_encap_finish(skb);
+	dst_release(skb->dst);
+	skb->dst = NULL;
+	{
+		/* make some packet-sock user (eg tcpdump) happy */
+		const unsigned char *old_mac;
+		old_mac = skb_mac_header(skb);
+		skb_set_mac_header(skb, -skb->mac_len);
+		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	}
 
-	return -iph->protocol;
-#endif
+	netif_rx(skb);
+	return 0;
 }
 
 /* If it's a keepalive packet, then just eat it.
-- 
1.4.4.1.gaed4


--=-zmk4Ud01Qbhtqa6Cs0pP--


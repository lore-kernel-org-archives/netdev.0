From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/2] ethernet: use likely() for common Ethernet
 encap
Date: Fri, 27 Sep 2013 17:21:27 -0700
Message-ID: <20130927172127.566a1a1d@nehalam.linuxnetplumber.net>
References: <20130927171941.0dad4d2a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:49722 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374Ab3I1AVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 20:21:36 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so3433811pab.4
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 17:21:35 -0700 (PDT)
In-Reply-To: <20130927171941.0dad4d2a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark code path's likely/unlikely based on most common usage.
  * Very few devices use dsa tags.
  * Most traffic is Ethernet (not 802.2)
  * No sane person uses trailer type or Novell encapsulation

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/ethernet/eth.c	2013-09-26 17:34:35.363115182 -0700
+++ b/net/ethernet/eth.c	2013-09-26 17:34:38.915070453 -0700
@@ -179,12 +179,13 @@ __be16 eth_type_trans(struct sk_buff *sk
 	 * variants has been configured on the receiving interface,
 	 * and if so, set skb->protocol without looking at the packet.
 	 */
-	if (netdev_uses_dsa_tags(dev))
+	if (unlikely(netdev_uses_dsa_tags(dev)))
 		return htons(ETH_P_DSA);
-	if (netdev_uses_trailer_tags(dev))
+
+	if (unlikely(netdev_uses_trailer_tags(dev)))
 		return htons(ETH_P_TRAILER);
 
-	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
+	if (likely(ntohs(eth->h_proto) >= ETH_P_802_3_MIN))
 		return eth->h_proto;
 
 	/*
@@ -193,7 +194,7 @@ __be16 eth_type_trans(struct sk_buff *sk
 	 *      layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
 	 *      won't work for fault tolerant netware but does for the rest.
 	 */
-	if (skb->len >= 2 && *(unsigned short *)(skb->data) == 0xFFFF)
+	if (unlikely(skb->len >= 2 && *(unsigned short *)(skb->data) == 0xFFFF))
 		return htons(ETH_P_802_3);
 
 	/*

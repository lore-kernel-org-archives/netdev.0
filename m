From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,RFC] skb->network_header and __vlan_put_tag()
Date: Tue, 17 Jun 2008 00:15:25 +0200
Message-ID: <20080616221525.GG27971@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:49379 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757042AbYFPWQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 18:16:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__vlan_put_tag() is not only substracting 4 from the skb's
->mac_header pointer (which kind of makes sense[*]), but it is
substracting 4 from the ->network_header pointer as well.

Conceptually, sure, VLAN is another layer of encapsulation between
ethernet and IP, but doesn't it make more sense to just consider the
VLAN tag part of the MAC header?  What good does it do to point
->network_header to the _middle_ of the VLAN tag when a VLAN tag is
inserted?

I'm adding VLAN support to mv643xx_eth (which does not support HW
insertion of a VLAN tag, but it does support HW checksumming when
a VLAN tag is present, you just have to tell the HW how many bytes
there are between the start of the packet and the IP header), and
I'm ending up with code like this:

	if (skb->protocol == htons(ETH_P_8021Q))
		ip_header = ip_hdr(skb) + 4;
	else
		ip_header = ip_hdr(skb);

whereas it'd be nicer if you could just have the same code for the
VLAN and non-VLAN case:

	ip_header = ip_hdr(skb);


[*] But skb->mac_header seems to be mostly NULL when this function
    is called, causing it to end up being 0xfffffffc by the time the
    packet is given to the device's ->hard_start_xmit().


Index: linux-2.6.26-rc5/include/linux/if_vlan.h
===================================================================
--- linux-2.6.26-rc5.orig/include/linux/if_vlan.h
+++ linux-2.6.26-rc5/include/linux/if_vlan.h
@@ -280,7 +280,6 @@ static inline struct sk_buff *__vlan_put
 
 	skb->protocol = htons(ETH_P_8021Q);
 	skb->mac_header -= VLAN_HLEN;
-	skb->network_header -= VLAN_HLEN;
 
 	return skb;
 }

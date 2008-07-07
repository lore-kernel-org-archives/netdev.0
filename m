From: Patrick McHardy <kaber@trash.net>
Subject: vlan 01/07: fix network_header/mac_header adjustments
Date: Mon,  7 Jul 2008 14:35:59 +0200 (MEST)
Message-ID: <20080707123558.23947.97974.sendpatchset@localhost.localdomain>
References: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59266 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbYGGMgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 08:36:01 -0400
In-Reply-To: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: fix network_header/mac_header adjustments

Lennert Buytenhek points out that the VLAN code incorrectly adjusts
skb->network_header to point in the middle of the VLAN header and
additionally tries to adjust skb->mac_header without checking for
validity.

The network_header should not be touched at all since we're only
adding headers in front of it, mac_header adjustments are not
necessary at all.

Based on patch by Lennert Buytenhek <buytenh@wantstofly.org>.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 12680f9e7c4d8c1d4dd89569e63f4f74d57243b0
tree 1ea90c61f99c3fba4ca3cac1729dd550ee98274a
parent 768cea593522d816b374149f3bf35e7c246fc8d0
author Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 14:26:42 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 14:26:42 +0200

 include/linux/if_vlan.h |    2 --
 net/8021q/vlan_dev.c    |    1 -
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 5190452..8f5bf9b 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -279,8 +279,6 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, unsigned short
 	veth->h_vlan_TCI = htons(tag);
 
 	skb->protocol = htons(ETH_P_8021Q);
-	skb->mac_header -= VLAN_HLEN;
-	skb->network_header -= VLAN_HLEN;
 
 	return skb;
 }
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index a0617bf..4a85259 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -308,7 +308,6 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 			vhdr->h_vlan_encapsulated_proto = htons(len);
 
 		skb->protocol = htons(ETH_P_8021Q);
-		skb_reset_network_header(skb);
 	}
 
 	/* Before delegating work to the lower layer, enter our MAC-address */

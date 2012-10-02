From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH net] 8021q: fix mac_len recomputation in vlan_untag()
Date: Tue,  2 Oct 2012 18:14:17 +0200
Message-ID: <1349194457-31623-1-git-send-email-ordex@autistici.org>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Antonio Quartulli <ordex@autistici.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:61553 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858Ab2JBQPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 12:15:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_reset_mac_len() relies on the value of the skb->network_header pointer,
therefore we must wait for such pointer to be recalculated before computing
the new mac_len value.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---

* such bug has been found because in the batman-adv module we do check the value
of mac_len to drop bad packets and we realised that all packets coming from the
untagging procedure (so coming from any eth0.x) were being dropped.

* I'd consider this patch to be submitted to stable

Thanks,


 net/8021q/vlan_core.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 8ca533c..830059d 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -105,7 +105,6 @@ static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
 		return NULL;
 	memmove(skb->data - ETH_HLEN, skb->data - VLAN_ETH_HLEN, 2 * ETH_ALEN);
 	skb->mac_header += VLAN_HLEN;
-	skb_reset_mac_len(skb);
 	return skb;
 }
 
@@ -139,6 +138,8 @@ struct sk_buff *vlan_untag(struct sk_buff *skb)
 
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
+	skb_reset_mac_len(skb);
+
 	return skb;
 
 err_free:
-- 
1.7.12

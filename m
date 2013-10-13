From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 05/16] batman-adv: h_vlan_encapsulated_proto access refactoring
Date: Sun, 13 Oct 2013 13:22:50 +0200
Message-ID: <1381663381-626-6-git-send-email-antonio@meshcoding.com>
References: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:13242 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754380Ab3JMLYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 07:24:21 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

In case of a VLAN tagged frame the ethhdr pointer is
moved forward by 4 bytes so that the offset of h_proto
in struct ethhdr matches the real
h_vlan_encapsulated_proto address in the skb. While this
trickery is correct it makes the code harder to understand
and may lead to bugs in case of re-use of ethhdr for other
purposes.

This patch introduces a proto variable to make things
cleaner and easier to understand.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/gateway_client.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 1bce63a..ac97ca7 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -655,24 +655,29 @@ bool batadv_gw_is_dhcp_target(struct sk_buff *skb, unsigned int *header_len)
 	struct iphdr *iphdr;
 	struct ipv6hdr *ipv6hdr;
 	struct udphdr *udphdr;
+	struct vlan_ethhdr *vhdr;
+	__be16 proto;
 
 	/* check for ethernet header */
 	if (!pskb_may_pull(skb, *header_len + ETH_HLEN))
 		return false;
 	ethhdr = (struct ethhdr *)skb->data;
+	proto = ethhdr->h_proto;
 	*header_len += ETH_HLEN;
 
 	/* check for initial vlan header */
-	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q) {
+	if (proto == htons(ETH_P_8021Q)) {
 		if (!pskb_may_pull(skb, *header_len + VLAN_HLEN))
 			return false;
-		ethhdr = (struct ethhdr *)(skb->data + VLAN_HLEN);
+
+		vhdr = (struct vlan_ethhdr *)skb->data;
+		proto = vhdr->h_vlan_encapsulated_proto;
 		*header_len += VLAN_HLEN;
 	}
 
 	/* check for ip header */
-	switch (ntohs(ethhdr->h_proto)) {
-	case ETH_P_IP:
+	switch (proto) {
+	case htons(ETH_P_IP):
 		if (!pskb_may_pull(skb, *header_len + sizeof(*iphdr)))
 			return false;
 		iphdr = (struct iphdr *)(skb->data + *header_len);
@@ -683,7 +688,7 @@ bool batadv_gw_is_dhcp_target(struct sk_buff *skb, unsigned int *header_len)
 			return false;
 
 		break;
-	case ETH_P_IPV6:
+	case htons(ETH_P_IPV6):
 		if (!pskb_may_pull(skb, *header_len + sizeof(*ipv6hdr)))
 			return false;
 		ipv6hdr = (struct ipv6hdr *)(skb->data + *header_len);
@@ -710,11 +715,11 @@ bool batadv_gw_is_dhcp_target(struct sk_buff *skb, unsigned int *header_len)
 	*header_len += sizeof(*udphdr);
 
 	/* check for bootp port */
-	if ((ntohs(ethhdr->h_proto) == ETH_P_IP) &&
+	if ((proto == htons(ETH_P_IP)) &&
 	    (ntohs(udphdr->dest) != 67))
 		return false;
 
-	if ((ntohs(ethhdr->h_proto) == ETH_P_IPV6) &&
+	if ((proto == htons(ETH_P_IPV6)) &&
 	    (ntohs(udphdr->dest) != 547))
 		return false;
 
-- 
1.8.3.2

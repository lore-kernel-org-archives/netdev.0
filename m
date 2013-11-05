From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH net] vti: fix spd lookup: match plaintext pkt, not ipsec pkt
Date: Tue,  5 Nov 2013 11:16:52 +0100
Message-ID: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>,
	netdev@vger.kernel.org,
	Christophe Gouault <christophe.gouault@6wind.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54743 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab3KEKR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 05:17:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vti interface inbound and outbound SPD lookups are based on the
ipsec packet instead of the plaintext packet.

Not only is it counterintuitive, it also restricts vti interfaces
to a single policy (whose selector must match the tunnel local and
remote addresses).

The policy selector is supposed to match the plaintext packet, before
encryption or after decryption.

This patch performs the SPD lookup based on the plaintext packet. It
enables to create several polices bound to the vti interface (via a
mark equal to the vti interface okey).

It remains possible to apply the same policy to all packets entering
the vti interface, by setting an any-to-any selector (src 0.0.0.0/0
dst 0.0.0.0/0 proto any mark OKEY).

Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
---
 net/ipv4/ip_vti.c |   28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 6e87f85..a7e03c0 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -126,6 +126,7 @@ static int vti_rcv(struct sk_buff *skb)
 	if (tunnel != NULL) {
 		struct pcpu_tstats *tstats;
 		u32 oldmark = skb->mark;
+		u16 netoff = skb_network_header(skb) - skb->data;
 		int ret;
 
 
@@ -133,7 +134,12 @@ static int vti_rcv(struct sk_buff *skb)
 		 * only match policies with this mark.
 		 */
 		skb->mark = be32_to_cpu(tunnel->parms.o_key);
+		/* the packet is decrypted, but not yet decapsulated.
+		 * Temporarily make network_header point to the inner header
+		 * for policy check */
+		skb_reset_network_header(skb);
 		ret = xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb);
+		skb_set_network_header(skb, netoff);
 		skb->mark = oldmark;
 		if (!ret)
 			return -1;
@@ -166,6 +172,8 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct iphdr  *old_iph = ip_hdr(skb);
 	__be32 dst = tiph->daddr;
 	struct flowi4 fl4;
+	struct flowi fl;
+	u32 oldmark = skb->mark;
 	int err;
 
 	if (skb->protocol != htons(ETH_P_IP))
@@ -173,17 +181,35 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tos = old_iph->tos;
 
+	/* SPD lookup: we must provide a dst_entry to xfrm_lookup, normally the
+	 * route to the final destination. However this route is a route via
+	 * the vti interface. Now vti interfaces typically have the NOXFRM
+	 * flag, hence xfrm_lookup would bypass IPsec.
+	 *
+	 * Therefore, we feed xfrm_lookup with a route to the vti tunnel remote
+	 * endpoint instead.
+	 */
 	memset(&fl4, 0, sizeof(fl4));
 	flowi4_init_output(&fl4, tunnel->parms.link,
 			   be32_to_cpu(tunnel->parms.o_key), RT_TOS(tos),
 			   RT_SCOPE_UNIVERSE,
 			   IPPROTO_IPIP, 0,
 			   dst, tiph->saddr, 0, 0);
-	rt = ip_route_output_key(dev_net(dev), &fl4);
+	rt = __ip_route_output_key(tunnel->net, &fl4);
 	if (IS_ERR(rt)) {
 		dev->stats.tx_carrier_errors++;
 		goto tx_error_icmp;
 	}
+
+	memset(&fl, 0, sizeof(fl));
+	/* temporarily mark the skb with the tunnel o_key, to look up
+	 * for a policy with this mark, matching the plaintext traffic.
+	 */
+	skb->mark = be32_to_cpu(tunnel->parms.o_key);
+	__xfrm_decode_session(skb, &fl, AF_INET, 0);
+	skb->mark = oldmark;
+	rt = (struct rtable *)xfrm_lookup(tunnel->net, &rt->dst, &fl, NULL, 0);
+
 	/* if there is no transform then this tunnel is not functional.
 	 * Or if the xfrm is not mode tunnel.
 	 */
-- 
1.7.10.4

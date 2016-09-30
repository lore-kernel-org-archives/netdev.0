From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 1/3] openvswitch: mpls: set network header correctly on key extract
Date: Fri, 30 Sep 2016 19:08:05 +0200
Message-ID: <285643e5d3ce0c2fed8c0aa5478795d8a5c892db.1475255100.git.jbenc@redhat.com>
References: <cover.1475255100.git.jbenc@redhat.com>
Cc: David Ahern <dsa@cumulusnetworks.com>,
        pravin shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34056 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932539AbcI3RJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 13:09:09 -0400
In-Reply-To: <cover.1475255100.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the 48d2ab609b6b ("net: mpls: Fixups for GSO"), MPLS handling in
openvswitch was changed to have network header pointing to the start of the
MPLS headers and inner_network_header pointing after the MPLS headers.

However, key_extract was missed by the mentioned commit, causing incorrect
headers to be set when a MPLS packet just enters the bridge or after it is
recirculated.

Fixes: 48d2ab609b6b ("net: mpls: Fixups for GSO")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
---
v2: no changes
---
 net/openvswitch/flow.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 634cc10d6dee..c8c82e109c68 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -633,12 +633,7 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 	} else if (eth_p_mpls(key->eth.type)) {
 		size_t stack_len = MPLS_HLEN;
 
-		/* In the presence of an MPLS label stack the end of the L2
-		 * header and the beginning of the L3 header differ.
-		 *
-		 * Advance network_header to the beginning of the L3
-		 * header. mac_len corresponds to the end of the L2 header.
-		 */
+		skb_set_inner_network_header(skb, skb->mac_len);
 		while (1) {
 			__be32 lse;
 
@@ -646,12 +641,12 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 			if (unlikely(error))
 				return 0;
 
-			memcpy(&lse, skb_network_header(skb), MPLS_HLEN);
+			memcpy(&lse, skb_inner_network_header(skb), MPLS_HLEN);
 
 			if (stack_len == MPLS_HLEN)
 				memcpy(&key->mpls.top_lse, &lse, MPLS_HLEN);
 
-			skb_set_network_header(skb, skb->mac_len + stack_len);
+			skb_set_inner_network_header(skb, skb->mac_len + stack_len);
 			if (lse & htonl(MPLS_LS_S_MASK))
 				break;
 
-- 
1.8.3.1

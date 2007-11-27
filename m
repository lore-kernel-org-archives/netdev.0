From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH (resubmit)][BRIDGE] Properly dereference the br_should_route_hook
Date: Tue, 27 Nov 2007 19:21:08 +0300
Message-ID: <474C43F4.5080704@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, bridge@lists.osdl.org,
	devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:49170 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756582AbXK0QV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 11:21:29 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This hook is protected with the RCU, so simple

	if (br_should_route_hook)
		br_should_route_hook(...)

is not enough on some architectures.

Use the rcu_dereference/rcu_assign_pointer in this case.

Fixed Stephen's comment concerning using the typeof().

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 3cedd4e..0ee79a7 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -122,6 +122,7 @@ static inline int is_link_local(const unsigned char *dest)
 struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
 {
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
+	int (*rhook)(struct sk_buff *skb);
 
 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
 		goto drop;
@@ -147,9 +148,9 @@ struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
 
 	switch (p->state) {
 	case BR_STATE_FORWARDING:
-
-		if (br_should_route_hook) {
-			if (br_should_route_hook(skb))
+		rhook = rcu_dereference(br_should_route_hook);
+		if (rhook != NULL) {
+			if (rhook(skb))
 				return skb;
 			dest = eth_hdr(skb)->h_dest;
 		}
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index e44519e..be6f186 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -70,13 +70,13 @@ static int __init ebtable_broute_init(void)
 	if (ret < 0)
 		return ret;
 	/* see br_input.c */
-	br_should_route_hook = ebt_broute;
+	rcu_assign_pointer(br_should_route_hook, ebt_broute);
 	return ret;
 }
 
 static void __exit ebtable_broute_fini(void)
 {
-	br_should_route_hook = NULL;
+	rcu_assign_pointer(br_should_route_hook, NULL);
 	synchronize_net();
 	ebt_unregister_table(&broute_table);
 }

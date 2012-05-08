From: pablo@netfilter.org
Subject: [PATCH 14/25] ipvs: fix ip_vs_try_bind_dest to rebind app and transmitter
Date: Tue,  8 May 2012 09:49:43 +0200
Message-ID: <1336463394-3119-15-git-send-email-pablo@netfilter.org>
References: <1336463394-3119-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41208 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756754Ab2EHHud (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 03:50:33 -0400
In-Reply-To: <1336463394-3119-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

	Initially, when the synced connection is created we
use the forwarding method provided by master but once we
bind to destination it can be changed. As result, we must
update the application and the transmitter.

	As ip_vs_try_bind_dest is called always for connections
that require dest binding, there is no need to validate the
cp and dest pointers.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |   33 ++++++++++++++++++++++++++-------
 1 file changed, 26 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 1c1bb30..fd74f88 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -613,14 +613,33 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 {
 	struct ip_vs_dest *dest;
 
-	if ((cp) && (!cp->dest)) {
-		dest = ip_vs_find_dest(ip_vs_conn_net(cp), cp->af, &cp->daddr,
-				       cp->dport, &cp->vaddr, cp->vport,
-				       cp->protocol, cp->fwmark, cp->flags);
+	dest = ip_vs_find_dest(ip_vs_conn_net(cp), cp->af, &cp->daddr,
+			       cp->dport, &cp->vaddr, cp->vport,
+			       cp->protocol, cp->fwmark, cp->flags);
+	if (dest) {
+		struct ip_vs_proto_data *pd;
+
+		/* Applications work depending on the forwarding method
+		 * but better to reassign them always when binding dest */
+		if (cp->app)
+			ip_vs_unbind_app(cp);
+
 		ip_vs_bind_dest(cp, dest);
-		return dest;
-	} else
-		return NULL;
+
+		/* Update its packet transmitter */
+		cp->packet_xmit = NULL;
+#ifdef CONFIG_IP_VS_IPV6
+		if (cp->af == AF_INET6)
+			ip_vs_bind_xmit_v6(cp);
+		else
+#endif
+			ip_vs_bind_xmit(cp);
+
+		pd = ip_vs_proto_data_get(ip_vs_conn_net(cp), cp->protocol);
+		if (pd && atomic_read(&pd->appcnt))
+			ip_vs_bind_app(cp, pd->pp);
+	}
+	return dest;
 }
 
 
-- 
1.7.9.5

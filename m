From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 27/34] ipvs: Allow heterogeneous pools now that we support them
Date: Mon, 29 Sep 2014 14:39:16 +0200
Message-ID: <1411994363-8451-28-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alex Gartrell <agartrell@fb.com>

Remove the temporary consistency check and add a case statement to only
allow ipip mixed dests.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |   24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 462760e..ac7ba68 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -854,10 +854,6 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 
 	EnterFunction(2);
 
-	/* Temporary for consistency */
-	if (udest->af != svc->af)
-		return -EINVAL;
-
 #ifdef CONFIG_IP_VS_IPV6
 	if (udest->af == AF_INET6) {
 		atype = ipv6_addr_type(&udest->addr.in6);
@@ -3403,6 +3399,26 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		 */
 		if (udest.af == 0)
 			udest.af = svc->af;
+
+		if (udest.af != svc->af) {
+			/* The synchronization protocol is incompatible
+			 * with mixed family services
+			 */
+			if (net_ipvs(net)->sync_state) {
+				ret = -EINVAL;
+				goto out;
+			}
+
+			/* Which connection types do we support? */
+			switch (udest.conn_flags) {
+			case IP_VS_CONN_F_TUNNEL:
+				/* We are able to forward this */
+				break;
+			default:
+				ret = -EINVAL;
+				goto out;
+			}
+		}
 	}
 
 	switch (cmd) {
-- 
1.7.10.4


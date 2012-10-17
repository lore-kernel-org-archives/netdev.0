From: pablo@netfilter.org
Subject: [PATCH 4/4] netfilter: xt_TEE: don't use destination address found in header
Date: Wed, 17 Oct 2012 12:40:11 +0200
Message-ID: <1350470411-5793-4-git-send-email-pablo@netfilter.org>
References: <1350470411-5793-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1350470411-5793-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

Torsten Luettgert bisected TEE regression starting with commit
f8126f1d5136be1 (ipv4: Adjust semantics of rt->rt_gateway.)

The problem is that it tries to ARP-lookup the original destination
address of the forwarded packet, not the address of the gateway.

Fix this using FLOWI_FLAG_KNOWN_NH Julian added in commit
c92b96553a80c1 (ipv4: Add FLOWI_FLAG_KNOWN_NH), so that known
nexthop (info->gw.ip) has preference on resolving.

Reported-by: Torsten Luettgert <ml-netfilter@enda.eu>
Bisected-by: Torsten Luettgert <ml-netfilter@enda.eu>
Tested-by: Torsten Luettgert <ml-netfilter@enda.eu>
Cc: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TEE.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index ee2e5bc..bd93e51 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -70,6 +70,7 @@ tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 	fl4.daddr = info->gw.ip;
 	fl4.flowi4_tos = RT_TOS(iph->tos);
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4.flowi4_flags = FLOWI_FLAG_KNOWN_NH;
 	rt = ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
 		return false;
-- 
1.7.10.4


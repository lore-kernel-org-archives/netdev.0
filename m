From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: xt_TEE: dont use destination address found in
 header
Date: Wed, 17 Oct 2012 10:33:29 +0200
Message-ID: <1350462809.26103.124.camel@edumazet-glaptop>
References: <20121016211319.3f07a7e3@goldlack.enda.eu>
	 <1350417618.3954.1494.camel@edumazet-glaptop>
	 <20121017094543.2ddb0397@goldlack.enda.eu>
	 <1350460131.26103.68.camel@edumazet-glaptop>  <20121017081551.GA12998@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Torsten Luettgert <ml-netfilter@enda.eu>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20121017081551.GA12998@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From-off-by: Eric Dumazet <edumazet@google.com>

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



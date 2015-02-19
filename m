From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/4] ipvs: fix inability to remove a mixed-family RS
Date: Thu, 19 Feb 2015 19:19:17 +0100
Message-ID: <1424369960-10988-2-git-send-email-pablo@netfilter.org>
References: <1424369960-10988-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1424369960-10988-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Andriyanov <alan@al-an.info>

The current code prevents any operation with a mixed-family dest
unless IP_VS_CONN_F_TUNNEL flag is set. The problem is that it's impossible
for the client to follow this rule, because ip_vs_genl_parse_dest does
not even read the destination conn_flags when cmd = IPVS_CMD_DEL_DEST
(need_full_dest = 0).

Also, not every client can pass this flag when removing a dest. ipvsadm,
for example, does not support the "-i" command line option together with
the "-d" option.

This change disables any checks for mixed-family on IPVS_CMD_DEL_DEST command.

Signed-off-by: Alexey Andriyanov <alan@al-an.info>
Fixes: bc18d37f676f ("ipvs: Allow heterogeneous pools now that we support them")
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b8295a4..fdcda8b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3399,7 +3399,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		if (udest.af == 0)
 			udest.af = svc->af;
 
-		if (udest.af != svc->af) {
+		if (udest.af != svc->af && cmd != IPVS_CMD_DEL_DEST) {
 			/* The synchronization protocol is incompatible
 			 * with mixed family services
 			 */
-- 
1.7.10.4


From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 23/24] IPVS: Activate IPv6 Netfilter hooks
Date: Tue,  2 Sep 2008 15:55:54 +0200
Message-ID: <1220363755-9854-24-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com,
	Julius Volz <juliusv@google.com>
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Register the previously defined or adapted netfilter hook functions for
IPv6 as PF_INET6 hooks.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 5a7a817..7d3de9d 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -1413,6 +1413,43 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.hooknum        = NF_INET_POST_ROUTING,
 		.priority       = NF_IP_PRI_NAT_SRC-1,
 	},
+#ifdef CONFIG_IP_VS_IPV6
+	/* After packet filtering, forward packet through VS/DR, VS/TUN,
+	 * or VS/NAT(change destination), so that filtering rules can be
+	 * applied to IPVS. */
+	{
+		.hook		= ip_vs_in,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_LOCAL_IN,
+		.priority       = 100,
+	},
+	/* After packet filtering, change source only for VS/NAT */
+	{
+		.hook		= ip_vs_out,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_FORWARD,
+		.priority       = 100,
+	},
+	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
+	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
+	{
+		.hook		= ip_vs_forward_icmp_v6,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_FORWARD,
+		.priority       = 99,
+	},
+	/* Before the netfilter connection tracking, exit from POST_ROUTING */
+	{
+		.hook		= ip_vs_post_routing,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_POST_ROUTING,
+		.priority       = NF_IP6_PRI_NAT_SRC-1,
+	},
+#endif
 };
 
 
-- 
1.5.4.5


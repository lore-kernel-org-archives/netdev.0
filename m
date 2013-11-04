From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/20] netfilter: ip6t_REJECT: skip checksum verification for outgoing ipv6 packets
Date: Mon,  4 Nov 2013 22:50:35 +0100
Message-ID: <1383601842-4570-14-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stanislav Fomichev <stfomichev@yandex-team.ru>

Don't verify checksum for outgoing packets because checksum calculation
may be done by the device.

Without this patch:
$ ip6tables -I OUTPUT -p tcp --dport 80 -j REJECT --reject-with tcp-reset
$ time telnet ipv6.google.com 80
Trying 2a00:1450:4010:c03::67...
telnet: Unable to connect to remote host: Connection timed out

real    0m7.201s
user    0m0.000s
sys     0m0.000s

With the patch applied:
$ ip6tables -I OUTPUT -p tcp --dport 80 -j REJECT --reject-with tcp-reset
$ time telnet ipv6.google.com 80
Trying 2a00:1450:4010:c03::67...
telnet: Unable to connect to remote host: Connection refused

real    0m0.085s
user    0m0.000s
sys     0m0.000s

Signed-off-by: Stanislav Fomichev <stfomichev@yandex-team.ru>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6t_REJECT.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 56eef30..da00a2e 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -39,7 +39,7 @@ MODULE_DESCRIPTION("Xtables: packet \"rejection\" target for IPv6");
 MODULE_LICENSE("GPL");
 
 /* Send RST reply */
-static void send_reset(struct net *net, struct sk_buff *oldskb)
+static void send_reset(struct net *net, struct sk_buff *oldskb, int hook)
 {
 	struct sk_buff *nskb;
 	struct tcphdr otcph, *tcph;
@@ -88,8 +88,7 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 	}
 
 	/* Check checksum. */
-	if (csum_ipv6_magic(&oip6h->saddr, &oip6h->daddr, otcplen, IPPROTO_TCP,
-			    skb_checksum(oldskb, tcphoff, otcplen, 0))) {
+	if (nf_ip6_checksum(oldskb, hook, tcphoff, IPPROTO_TCP)) {
 		pr_debug("TCP checksum is invalid\n");
 		return;
 	}
@@ -227,7 +226,7 @@ reject_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 		/* Do nothing */
 		break;
 	case IP6T_TCP_RESET:
-		send_reset(net, skb);
+		send_reset(net, skb, par->hooknum);
 		break;
 	default:
 		net_info_ratelimited("case %u not handled yet\n", reject->with);
-- 
1.7.10.4


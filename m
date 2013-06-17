From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/3] netfilter: xt_TCPMSS: Fix IPv6 default MSS too
Date: Mon, 17 Jun 2013 21:34:38 +0200
Message-ID: <1371497679-14314-3-git-send-email-pablo@netfilter.org>
References: <1371497679-14314-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51626 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752915Ab3FQTew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 15:34:52 -0400
In-Reply-To: <1371497679-14314-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Oester <kernel@linuxace.com>

As a followup to commit 409b545a ("netfilter: xt_TCPMSS: Fix violation
of RFC879 in absence of MSS option"), John Heffner points out that IPv6
has a higher MTU than IPv4, and thus a higher minimum MSS. Update TCPMSS
target to account for this, and update RFC comment.

While at it, point to more recent reference RFC1122 instead of RFC879.

Signed-off-by: Phil Oester <kernel@linuxace.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TCPMSS.c |   21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index afaebc7..6640a22 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -45,11 +45,12 @@ optlen(const u_int8_t *opt, unsigned int offset)
 
 static int
 tcpmss_mangle_packet(struct sk_buff *skb,
-		     const struct xt_tcpmss_info *info,
+		     const struct xt_action_param *par,
 		     unsigned int in_mtu,
 		     unsigned int tcphoff,
 		     unsigned int minlen)
 {
+	const struct xt_tcpmss_info *info = par->targinfo;
 	struct tcphdr *tcph;
 	unsigned int tcplen, i;
 	__be16 oldval;
@@ -125,11 +126,17 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 
 	skb_put(skb, TCPOLEN_MSS);
 
-	/* RFC 879 states that the default MSS is 536 without specific
-	 * knowledge that the destination host is prepared to accept larger.
-	 * Since no MSS was provided, we MUST NOT set a value > 536.
+	/*
+	 * IPv4: RFC 1122 states "If an MSS option is not received at
+	 * connection setup, TCP MUST assume a default send MSS of 536".
+	 * IPv6: RFC 2460 states IPv6 has a minimum MTU of 1280 and a minimum
+	 * length IPv6 header of 60, ergo the default MSS value is 1220
+	 * Since no MSS was provided, we must use the default values
 	 */
-	newmss = min(newmss, (u16)536);
+	if (par->family == NFPROTO_IPV4)
+		newmss = min(newmss, (u16)536);
+	else
+		newmss = min(newmss, (u16)1220);
 
 	opt = (u_int8_t *)tcph + sizeof(struct tcphdr);
 	memmove(opt + TCPOLEN_MSS, opt, tcplen - sizeof(struct tcphdr));
@@ -188,7 +195,7 @@ tcpmss_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 	__be16 newlen;
 	int ret;
 
-	ret = tcpmss_mangle_packet(skb, par->targinfo,
+	ret = tcpmss_mangle_packet(skb, par,
 				   tcpmss_reverse_mtu(skb, PF_INET),
 				   iph->ihl * 4,
 				   sizeof(*iph) + sizeof(struct tcphdr));
@@ -217,7 +224,7 @@ tcpmss_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	tcphoff = ipv6_skip_exthdr(skb, sizeof(*ipv6h), &nexthdr, &frag_off);
 	if (tcphoff < 0)
 		return NF_DROP;
-	ret = tcpmss_mangle_packet(skb, par->targinfo,
+	ret = tcpmss_mangle_packet(skb, par,
 				   tcpmss_reverse_mtu(skb, PF_INET6),
 				   tcphoff,
 				   sizeof(*ipv6h) + sizeof(struct tcphdr));
-- 
1.7.10.4

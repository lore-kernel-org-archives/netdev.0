From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/4] netfilter: xt_TCPOPTSTRIP: fix possible mangling beyond packet boundary
Date: Thu, 16 May 2013 17:55:21 +0200
Message-ID: <1368719721-7470-5-git-send-email-pablo@netfilter.org>
References: <1368719721-7470-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1368719721-7470-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This target assumes that tcph->doff is well-formed, that may be well
not the case. Add extra sanity checkings to avoid possible crash due
to read/write out of the real packet boundary. After this patch, the
default action on malformed TCP packets is to drop them. Moreover,
fragments are skipped.

Reported-by: Rafal Kupka <rkupka@telemetry.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TCPOPTSTRIP.c |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/xt_TCPOPTSTRIP.c b/net/netfilter/xt_TCPOPTSTRIP.c
index 25fd1c4..1eb1a44 100644
--- a/net/netfilter/xt_TCPOPTSTRIP.c
+++ b/net/netfilter/xt_TCPOPTSTRIP.c
@@ -30,17 +30,28 @@ static inline unsigned int optlen(const u_int8_t *opt, unsigned int offset)
 
 static unsigned int
 tcpoptstrip_mangle_packet(struct sk_buff *skb,
-			  const struct xt_tcpoptstrip_target_info *info,
+			  const struct xt_action_param *par,
 			  unsigned int tcphoff, unsigned int minlen)
 {
+	const struct xt_tcpoptstrip_target_info *info = par->targinfo;
 	unsigned int optl, i, j;
 	struct tcphdr *tcph;
 	u_int16_t n, o;
 	u_int8_t *opt;
+	int len;
+
+	/* This is a fragment, no TCP header is available */
+	if (par->fragoff != 0)
+		return XT_CONTINUE;
 
 	if (!skb_make_writable(skb, skb->len))
 		return NF_DROP;
 
+	len = skb->len - tcphoff;
+	if (len < (int)sizeof(struct tcphdr) ||
+	    tcp_hdr(skb)->doff * 4 > len)
+		return NF_DROP;
+
 	tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
 	opt  = (u_int8_t *)tcph;
 
@@ -76,7 +87,7 @@ tcpoptstrip_mangle_packet(struct sk_buff *skb,
 static unsigned int
 tcpoptstrip_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	return tcpoptstrip_mangle_packet(skb, par->targinfo, ip_hdrlen(skb),
+	return tcpoptstrip_mangle_packet(skb, par, ip_hdrlen(skb),
 	       sizeof(struct iphdr) + sizeof(struct tcphdr));
 }
 
@@ -94,7 +105,7 @@ tcpoptstrip_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	if (tcphoff < 0)
 		return NF_DROP;
 
-	return tcpoptstrip_mangle_packet(skb, par->targinfo, tcphoff,
+	return tcpoptstrip_mangle_packet(skb, par, tcphoff,
 	       sizeof(*ipv6h) + sizeof(struct tcphdr));
 }
 #endif
-- 
1.7.10.4


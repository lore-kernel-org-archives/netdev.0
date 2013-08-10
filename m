From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/4] netfilter: xt_TCPMSS: fix handling of malformed TCP header and options
Date: Sat, 10 Aug 2013 18:58:50 +0200
Message-ID: <1376153933-5747-2-git-send-email-pablo@netfilter.org>
References: <1376153933-5747-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376153933-5747-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure the packet has enough room for the TCP header and
that it is not malformed.

While at it, store tcph->doff*4 in a variable, as it is used
several times.

This patch also fixes a possible off by one in case of malformed
TCP options.

Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TCPMSS.c |   28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 7011c71..6113cc7 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -52,7 +52,8 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 {
 	const struct xt_tcpmss_info *info = par->targinfo;
 	struct tcphdr *tcph;
-	unsigned int tcplen, i;
+	int len, tcp_hdrlen;
+	unsigned int i;
 	__be16 oldval;
 	u16 newmss;
 	u8 *opt;
@@ -64,11 +65,14 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	if (!skb_make_writable(skb, skb->len))
 		return -1;
 
-	tcplen = skb->len - tcphoff;
+	len = skb->len - tcphoff;
+	if (len < (int)sizeof(struct tcphdr))
+		return -1;
+
 	tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
+	tcp_hdrlen = tcph->doff * 4;
 
-	/* Header cannot be larger than the packet */
-	if (tcplen < tcph->doff*4)
+	if (len < tcp_hdrlen)
 		return -1;
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
@@ -87,9 +91,8 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 		newmss = info->mss;
 
 	opt = (u_int8_t *)tcph;
-	for (i = sizeof(struct tcphdr); i < tcph->doff*4; i += optlen(opt, i)) {
-		if (opt[i] == TCPOPT_MSS && tcph->doff*4 - i >= TCPOLEN_MSS &&
-		    opt[i+1] == TCPOLEN_MSS) {
+	for (i = sizeof(struct tcphdr); i <= tcp_hdrlen - TCPOLEN_MSS; i += optlen(opt, i)) {
+		if (opt[i] == TCPOPT_MSS && opt[i+1] == TCPOLEN_MSS) {
 			u_int16_t oldmss;
 
 			oldmss = (opt[i+2] << 8) | opt[i+3];
@@ -112,9 +115,10 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	}
 
 	/* There is data after the header so the option can't be added
-	   without moving it, and doing so may make the SYN packet
-	   itself too large. Accept the packet unmodified instead. */
-	if (tcplen > tcph->doff*4)
+	 * without moving it, and doing so may make the SYN packet
+	 * itself too large. Accept the packet unmodified instead.
+	 */
+	if (len > tcp_hdrlen)
 		return 0;
 
 	/*
@@ -143,10 +147,10 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 		newmss = min(newmss, (u16)1220);
 
 	opt = (u_int8_t *)tcph + sizeof(struct tcphdr);
-	memmove(opt + TCPOLEN_MSS, opt, tcplen - sizeof(struct tcphdr));
+	memmove(opt + TCPOLEN_MSS, opt, len - sizeof(struct tcphdr));
 
 	inet_proto_csum_replace2(&tcph->check, skb,
-				 htons(tcplen), htons(tcplen + TCPOLEN_MSS), 1);
+				 htons(len), htons(len + TCPOLEN_MSS), 1);
 	opt[0] = TCPOPT_MSS;
 	opt[1] = TCPOLEN_MSS;
 	opt[2] = (newmss & 0xff00) >> 8;
-- 
1.7.10.4


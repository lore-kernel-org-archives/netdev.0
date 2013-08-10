From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/4] netfilter: xt_TCPOPTSTRIP: fix possible off by one access
Date: Sat, 10 Aug 2013 18:58:51 +0200
Message-ID: <1376153933-5747-3-git-send-email-pablo@netfilter.org>
References: <1376153933-5747-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44420 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757949Ab3HJQ7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Aug 2013 12:59:32 -0400
In-Reply-To: <1376153933-5747-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a possible off by one access since optlen()
touches opt[offset+1] unsafely when i == tcp_hdrlen(skb) - 1.

This patch replaces tcp_hdrlen() by the local variable tcp_hdrlen
that stores the TCP header length, to save some cycles.

Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TCPOPTSTRIP.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_TCPOPTSTRIP.c b/net/netfilter/xt_TCPOPTSTRIP.c
index b68fa19..625fa1d 100644
--- a/net/netfilter/xt_TCPOPTSTRIP.c
+++ b/net/netfilter/xt_TCPOPTSTRIP.c
@@ -38,7 +38,7 @@ tcpoptstrip_mangle_packet(struct sk_buff *skb,
 	struct tcphdr *tcph;
 	u_int16_t n, o;
 	u_int8_t *opt;
-	int len;
+	int len, tcp_hdrlen;
 
 	/* This is a fragment, no TCP header is available */
 	if (par->fragoff != 0)
@@ -52,7 +52,9 @@ tcpoptstrip_mangle_packet(struct sk_buff *skb,
 		return NF_DROP;
 
 	tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
-	if (tcph->doff * 4 > len)
+	tcp_hdrlen = tcph->doff * 4;
+
+	if (len < tcp_hdrlen)
 		return NF_DROP;
 
 	opt  = (u_int8_t *)tcph;
@@ -61,10 +63,10 @@ tcpoptstrip_mangle_packet(struct sk_buff *skb,
 	 * Walk through all TCP options - if we find some option to remove,
 	 * set all octets to %TCPOPT_NOP and adjust checksum.
 	 */
-	for (i = sizeof(struct tcphdr); i < tcp_hdrlen(skb); i += optl) {
+	for (i = sizeof(struct tcphdr); i < tcp_hdrlen - 1; i += optl) {
 		optl = optlen(opt, i);
 
-		if (i + optl > tcp_hdrlen(skb))
+		if (i + optl > tcp_hdrlen)
 			break;
 
 		if (!tcpoptstrip_test_bit(info->strip_bmap, opt[i]))
-- 
1.7.10.4

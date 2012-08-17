From: pablo@netfilter.org
Subject: [PATCH 3/5] netfilter: nf_nat_sip: fix via header translation with multiple parameters
Date: Fri, 17 Aug 2012 16:09:31 +0200
Message-ID: <1345212573-3076-4-git-send-email-pablo@netfilter.org>
References: <1345212573-3076-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345212573-3076-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Via-headers are parsed beginning at the first character after the Via-address.
When the address is translated first and its length decreases, the offset to
start parsing at is incorrect and header parameters might be missed.

Update the offset after translating the Via-address to fix this.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_nat_sip.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index eef8f29..4ad9cf1 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -148,7 +148,7 @@ static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int dataoff,
 	if (ct_sip_parse_header_uri(ct, *dptr, NULL, *datalen,
 				    hdr, NULL, &matchoff, &matchlen,
 				    &addr, &port) > 0) {
-		unsigned int matchend, poff, plen, buflen, n;
+		unsigned int olen, matchend, poff, plen, buflen, n;
 		char buffer[sizeof("nnn.nnn.nnn.nnn:nnnnn")];
 
 		/* We're only interested in headers related to this
@@ -163,11 +163,12 @@ static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int dataoff,
 				goto next;
 		}
 
+		olen = *datalen;
 		if (!map_addr(skb, dataoff, dptr, datalen, matchoff, matchlen,
 			      &addr, port))
 			return NF_DROP;
 
-		matchend = matchoff + matchlen;
+		matchend = matchoff + matchlen + *datalen - olen;
 
 		/* The maddr= parameter (RFC 2361) specifies where to send
 		 * the reply. */
-- 
1.7.10.4


From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] netfilter: xt_TCPMSS: add more sanity tests on
 tcph->doff
Date: Mon, 03 Apr 2017 10:55:11 -0700
Message-ID: <1491242111.10124.32.camel@edumazet-glaptop3.roam.corp.google.com>
References: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
         <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33435 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751883AbdDCRzN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 13:55:13 -0400
In-Reply-To: <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Denys provided an awesome KASAN report pointing to an use
after free in xt_TCPMSS

I have provided three patches to fix this issue, either in xt_TCPMSS or
in xt_tcpudp.c. It seems xt_TCPMSS patch has the smallest possible
impact.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
---
 net/netfilter/xt_TCPMSS.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 27241a767f17b4b27d24095a31e5e9a2d3e29ce4..c64aca611ac5c5f81ad7c925652bbb90554763ac 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -104,7 +104,7 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
 	tcp_hdrlen = tcph->doff * 4;
 
-	if (len < tcp_hdrlen)
+	if (len < tcp_hdrlen || tcp_hdrlen < sizeof(struct tcphdr))
 		return -1;
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
@@ -152,6 +152,10 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	if (len > tcp_hdrlen)
 		return 0;
 
+	/* tcph->doff has 4 bits, do not wrap it to 0 */
+	if (tcp_hdrlen >= 15 * 4)
+		return 0;
+
 	/*
 	 * MSS Option not found ?! add it..
 	 */

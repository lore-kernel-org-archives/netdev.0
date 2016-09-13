From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/4] netfilter: nft_chain_route: re-route before skb is queued to userspace
Date: Tue, 13 Sep 2016 11:05:15 +0200
Message-ID: <1473757517-3764-3-git-send-email-pablo@netfilter.org>
References: <1473757517-3764-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59248 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757195AbcIMJF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 05:05:29 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id D104015C11C
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 11:05:27 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 797EA16E3F4
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 11:05:27 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8833F16E3F4
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 11:05:24 +0200 (CEST)
In-Reply-To: <1473757517-3764-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

Imagine such situation, user add the following nft rules, and queue
the packets to userspace for further check:
  # ip rule add fwmark 0x0/0x1 lookup eth0
  # ip rule add fwmark 0x1/0x1 lookup eth1
  # nft add table filter
  # nft add chain filter output {type route hook output priority 0 \;}
  # nft add rule filter output mark set 0x1
  # nft add rule filter output queue num 0

But after we reinject the skbuff, the packet will be sent via the
wrong route, i.e. in this case, the packet will be routed via eth0
table, not eth1 table. Because we skip to do re-route when verdict
is NF_QUEUE, even if the mark was changed.

Acctually, we should not touch sk_buff if verdict is NF_DROP or
NF_STOLEN, and when re-route fails, return NF_DROP with error code.
This is consistent with the mangle table in iptables.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nft_chain_route_ipv4.c | 11 +++++++----
 net/ipv6/netfilter/nft_chain_route_ipv6.c | 10 +++++++---
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/netfilter/nft_chain_route_ipv4.c b/net/ipv4/netfilter/nft_chain_route_ipv4.c
index 2375b0a..30493be 100644
--- a/net/ipv4/netfilter/nft_chain_route_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_route_ipv4.c
@@ -31,6 +31,7 @@ static unsigned int nf_route_table_hook(void *priv,
 	__be32 saddr, daddr;
 	u_int8_t tos;
 	const struct iphdr *iph;
+	int err;
 
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct iphdr) ||
@@ -46,15 +47,17 @@ static unsigned int nf_route_table_hook(void *priv,
 	tos = iph->tos;
 
 	ret = nft_do_chain(&pkt, priv);
-	if (ret != NF_DROP && ret != NF_QUEUE) {
+	if (ret != NF_DROP && ret != NF_STOLEN) {
 		iph = ip_hdr(skb);
 
 		if (iph->saddr != saddr ||
 		    iph->daddr != daddr ||
 		    skb->mark != mark ||
-		    iph->tos != tos)
-			if (ip_route_me_harder(state->net, skb, RTN_UNSPEC))
-				ret = NF_DROP;
+		    iph->tos != tos) {
+			err = ip_route_me_harder(state->net, skb, RTN_UNSPEC);
+			if (err < 0)
+				ret = NF_DROP_ERR(err);
+		}
 	}
 	return ret;
 }
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index 71d995f..2535223 100644
--- a/net/ipv6/netfilter/nft_chain_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -31,6 +31,7 @@ static unsigned int nf_route_table_hook(void *priv,
 	struct in6_addr saddr, daddr;
 	u_int8_t hop_limit;
 	u32 mark, flowlabel;
+	int err;
 
 	/* malformed packet, drop it */
 	if (nft_set_pktinfo_ipv6(&pkt, skb, state) < 0)
@@ -46,13 +47,16 @@ static unsigned int nf_route_table_hook(void *priv,
 	flowlabel = *((u32 *)ipv6_hdr(skb));
 
 	ret = nft_do_chain(&pkt, priv);
-	if (ret != NF_DROP && ret != NF_QUEUE &&
+	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (memcmp(&ipv6_hdr(skb)->saddr, &saddr, sizeof(saddr)) ||
 	     memcmp(&ipv6_hdr(skb)->daddr, &daddr, sizeof(daddr)) ||
 	     skb->mark != mark ||
 	     ipv6_hdr(skb)->hop_limit != hop_limit ||
-	     flowlabel != *((u_int32_t *)ipv6_hdr(skb))))
-		return ip6_route_me_harder(state->net, skb) == 0 ? ret : NF_DROP;
+	     flowlabel != *((u_int32_t *)ipv6_hdr(skb)))) {
+		err = ip6_route_me_harder(state->net, skb);
+		if (err < 0)
+			ret = NF_DROP_ERR(err);
+	}
 
 	return ret;
 }
-- 
2.1.4

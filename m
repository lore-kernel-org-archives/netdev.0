From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/10] netfilter: nf_tables: set pktinfo->thoff at AH header if found
Date: Wed, 15 Mar 2017 18:01:05 +0100
Message-ID: <1489597272-30347-4-git-send-email-pablo@netfilter.org>
References: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37610 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752596AbdCORBm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 13:01:42 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 149A41324D1
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:01:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 02993DA874
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:01:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 31C84DA87C
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:01:19 +0100 (CET)
In-Reply-To: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Sutter reports that IPv6 AH header matching is broken. From
userspace, nft generates bytecode that expects to find the AH header at
NFT_PAYLOAD_TRANSPORT_HEADER both for IPv4 and IPv6. However,
pktinfo->thoff is set to the inner header after the AH header in IPv6,
while in IPv4 pktinfo->thoff points to the AH header indeed. This
behaviour is inconsistent. This patch fixes this problem by updating
ipv6_find_hdr() to get the IP6_FH_F_AUTH flag so this function stops at
the AH header, so both IPv4 and IPv6 pktinfo->thoff point to the AH
header.

This is also inconsistent when trying to match encapsulated headers:

1) A packet that looks like IPv4 + AH + TCP dport 22 will *not* match.
2) A packet that looks like IPv6 + AH + TCP dport 22 will match.

Reported-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_ipv6.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_tables_ipv6.h b/include/net/netfilter/nf_tables_ipv6.h
index d150b5066201..97983d1c05e4 100644
--- a/include/net/netfilter/nf_tables_ipv6.h
+++ b/include/net/netfilter/nf_tables_ipv6.h
@@ -9,12 +9,13 @@ nft_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 		     struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
+	unsigned int flags = IP6_FH_F_AUTH;
 	int protohdr, thoff = 0;
 	unsigned short frag_off;
 
 	nft_set_pktinfo(pkt, skb, state);
 
-	protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, NULL);
+	protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, &flags);
 	if (protohdr < 0) {
 		nft_set_pktinfo_proto_unspec(pkt, skb);
 		return;
@@ -32,6 +33,7 @@ __nft_set_pktinfo_ipv6_validate(struct nft_pktinfo *pkt,
 				const struct nf_hook_state *state)
 {
 #if IS_ENABLED(CONFIG_IPV6)
+	unsigned int flags = IP6_FH_F_AUTH;
 	struct ipv6hdr *ip6h, _ip6h;
 	unsigned int thoff = 0;
 	unsigned short frag_off;
@@ -50,7 +52,7 @@ __nft_set_pktinfo_ipv6_validate(struct nft_pktinfo *pkt,
 	if (pkt_len + sizeof(*ip6h) > skb->len)
 		return -1;
 
-	protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, NULL);
+	protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, &flags);
 	if (protohdr < 0)
 		return -1;
 
-- 
2.1.4

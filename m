From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/26] netfilter: nf_reject_ipv4: don't send tcp RST if the packet is non-TCP
Date: Wed,  6 Jul 2016 16:23:53 +0200
Message-ID: <1467815048-2240-12-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34241 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754725AbcGFO0p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 10:26:45 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id D692217DB70
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:43 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C6289FF148
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:43 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C5BADFAB50
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:39 +0200 (CEST)
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

In iptables, if the user add a rule to send tcp RST and specify the
non-TCP protocol, such as UDP, kernel will reject this request. But
in nftables, this validity check only occurs in nft tool, i.e. only
in userspace.

This means that user can add such a rule like follows via nfnetlink:
  "nft add rule filter forward ip protocol udp reject with tcp reset"

This will generate some confusing tcp RST packets. So we should send
tcp RST only when it is TCP packet.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_reject_ipv4.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index b6ea57e..fd82202 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -24,6 +24,9 @@ const struct tcphdr *nf_reject_ip_tcphdr_get(struct sk_buff *oldskb,
 	if (ip_hdr(oldskb)->frag_off & htons(IP_OFFSET))
 		return NULL;
 
+	if (ip_hdr(oldskb)->protocol != IPPROTO_TCP)
+		return NULL;
+
 	oth = skb_header_pointer(oldskb, ip_hdrlen(oldskb),
 				 sizeof(struct tcphdr), _oth);
 	if (oth == NULL)
-- 
2.1.4

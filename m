From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6] netfilter: xt_TCPMSS: handle CHECKSUM_COMPLETE in tcpmss_tg6()
Date: Wed, 20 Jan 2016 18:04:02 +0100
Message-ID: <1453309444-2297-5-git-send-email-pablo@netfilter.org>
References: <1453309444-2297-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45484 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934912AbcATREX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 12:04:23 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 69D16A7E27
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:04:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 56A10DA7E0
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:04:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 7071CDA803
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:04:20 +0100 (CET)
In-Reply-To: <1453309444-2297-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In case MSS option is added in TCP options, skb length increases by 4.
IPv6 needs to update skb->csum if skb has CHECKSUM_COMPLETE,
otherwise kernel complains loudly in netdev_rx_csum_fault() with a
stack dump.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TCPMSS.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index b7c43de..e118397 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -228,7 +228,7 @@ tcpmss_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	u8 nexthdr;
-	__be16 frag_off;
+	__be16 frag_off, oldlen, newlen;
 	int tcphoff;
 	int ret;
 
@@ -244,7 +244,12 @@ tcpmss_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 		return NF_DROP;
 	if (ret > 0) {
 		ipv6h = ipv6_hdr(skb);
-		ipv6h->payload_len = htons(ntohs(ipv6h->payload_len) + ret);
+		oldlen = ipv6h->payload_len;
+		newlen = htons(ntohs(oldlen) + ret);
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->csum = csum_add(csum_sub(skb->csum, oldlen),
+					     newlen);
+		ipv6h->payload_len = newlen;
 	}
 	return XT_CONTINUE;
 }
-- 
2.1.4

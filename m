From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/12] netfilter: ipvs: full-functionality option for ECN encapsulation in tunnel
Date: Mon,  9 Oct 2017 18:25:35 +0200
Message-ID: <1507566346-32553-2-git-send-email-pablo@netfilter.org>
References: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57780 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755197AbdJIQ0A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 12:26:00 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BB610C0B4D
        for <netdev@vger.kernel.org>; Mon,  9 Oct 2017 18:25:58 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id ABF2CDA87F
        for <netdev@vger.kernel.org>; Mon,  9 Oct 2017 18:25:58 +0200 (CEST)
In-Reply-To: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Fedorenko <vfedorenko@yandex-team.ru>

IPVS tunnel mode works as simple tunnel (see RFC 3168) copying ECN field
to outer header. That's result in packet drops on egress tunnels in case
the egress tunnel operates as ECN-capable with Full-functionality option
(like ip_tunnel and ip6_tunnel kernel modules), according to RFC 3168
section 9.1.1 recommendation.

This patch implements ECN full-functionality option into ipvs xmit code.

Cc: netdev@vger.kernel.org
Cc: lvs-devel@vger.kernel.org
Signed-off-by: Vadim Fedorenko <vfedorenko@yandex-team.ru>
Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 90d396814798..4527921b1c3a 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -921,6 +921,7 @@ ip_vs_prepare_tunneled_skb(struct sk_buff *skb, int skb_af,
 {
 	struct sk_buff *new_skb = NULL;
 	struct iphdr *old_iph = NULL;
+	__u8 old_dsfield;
 #ifdef CONFIG_IP_VS_IPV6
 	struct ipv6hdr *old_ipv6h = NULL;
 #endif
@@ -945,7 +946,7 @@ ip_vs_prepare_tunneled_skb(struct sk_buff *skb, int skb_af,
 			*payload_len =
 				ntohs(old_ipv6h->payload_len) +
 				sizeof(*old_ipv6h);
-		*dsfield = ipv6_get_dsfield(old_ipv6h);
+		old_dsfield = ipv6_get_dsfield(old_ipv6h);
 		*ttl = old_ipv6h->hop_limit;
 		if (df)
 			*df = 0;
@@ -960,12 +961,15 @@ ip_vs_prepare_tunneled_skb(struct sk_buff *skb, int skb_af,
 
 		/* fix old IP header checksum */
 		ip_send_check(old_iph);
-		*dsfield = ipv4_get_dsfield(old_iph);
+		old_dsfield = ipv4_get_dsfield(old_iph);
 		*ttl = old_iph->ttl;
 		if (payload_len)
 			*payload_len = ntohs(old_iph->tot_len);
 	}
 
+	/* Implement full-functionality option for ECN encapsulation */
+	*dsfield = INET_ECN_encapsulate(old_dsfield, old_dsfield);
+
 	return skb;
 error:
 	kfree_skb(skb);
-- 
2.1.4

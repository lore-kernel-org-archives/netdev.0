From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] ip6_gre: fix endianness errors in ip6gre_err
Date: Wed,  4 Feb 2015 15:25:09 +0100
Message-ID: <1423059909-15606-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:55313 "EHLO
	smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296AbbBDOZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 09:25:53 -0500
Received: from smtp4-g21.free.fr (smtp4-g21.free.fr [212.27.42.4])
	by smtpfb2-g21.free.fr (Postfix) with ESMTP id 7FA32CA9201
	for <netdev@vger.kernel.org>; Wed,  4 Feb 2015 15:25:44 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

info is in network byte order, change it back to host byte order
before use. In particular, the current code sets the MTU of the tunnel
to a wrong (too big) value.

Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/ipv6/ip6_gre.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 13cda4c6313b..01ccc28a686f 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -417,7 +417,7 @@ static void ip6gre_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		if (code == ICMPV6_HDR_FIELD)
 			teli = ip6_tnl_parse_tlv_enc_lim(skb, skb->data);
 
-		if (teli && teli == info - 2) {
+		if (teli && teli == be32_to_cpu(info) - 2) {
 			tel = (struct ipv6_tlv_tnl_enc_lim *) &skb->data[teli];
 			if (tel->encap_limit == 0) {
 				net_warn_ratelimited("%s: Too small encapsulation limit or routing loop in tunnel!\n",
@@ -429,7 +429,7 @@ static void ip6gre_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		}
 		break;
 	case ICMPV6_PKT_TOOBIG:
-		mtu = info - offset;
+		mtu = be32_to_cpu(info) - offset;
 		if (mtu < IPV6_MIN_MTU)
 			mtu = IPV6_MIN_MTU;
 		t->dev->mtu = mtu;
-- 
2.2.2

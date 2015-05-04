From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 5/5] net: set DF bit on fragment list skbs if DF was set earlier
Date: Mon,  4 May 2015 22:54:48 +0200
Message-ID: <1430772888-5682-6-git-send-email-fw@strlen.de>
References: <1430772888-5682-1-git-send-email-fw@strlen.de>
Cc: hannes@stressinduktion.org, jesse@nicira.com,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47187 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752691AbbEDUzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:55:22 -0400
In-Reply-To: <1430772888-5682-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This extends the previous change to also set the DF bit in the
fragment list skb, i.e. if the original fragments had DF set,
then also set it when 'replaying' the fraglist skbs.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/ip_output.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 26847e4..3a41844 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -543,6 +543,7 @@ int ip_fragment(struct sock *sk, struct sk_buff *skb,
 	if (skb_has_frag_list(skb)) {
 		struct sk_buff *frag, *frag2;
 		int first_len = skb_pagelen(skb);
+		bool is_df_skb;
 
 		if (first_len - hlen > mtu ||
 		    ((first_len - hlen) & 7) ||
@@ -579,6 +580,9 @@ int ip_fragment(struct sock *sk, struct sk_buff *skb,
 		skb->len = first_len;
 		iph->tot_len = htons(first_len);
 		iph->frag_off = htons(IP_MF);
+		is_df_skb = IPCB(skb)->flags & IPSKB_FRAG_PMTU;
+		if (is_df_skb)
+			iph->frag_off |= htons(IP_DF);
 		ip_send_check(iph);
 
 		for (;;) {
@@ -599,6 +603,8 @@ int ip_fragment(struct sock *sk, struct sk_buff *skb,
 				iph->frag_off = htons(offset>>3);
 				if (frag->next)
 					iph->frag_off |= htons(IP_MF);
+				if (is_df_skb)
+					iph->frag_off |= htons(IP_DF);
 				/* Ready, complete checksum */
 				ip_send_check(iph);
 			}
-- 
2.0.5

From: roy.qing.li@gmail.com
Subject: [PATCH] ipv4: fix a potential use after free
Date: Fri, 17 Oct 2014 16:53:23 +0800
Message-ID: <1413536003-15646-1-git-send-email-roy.qing.li@gmail.com>
Cc: pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:53610 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaJQIx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 04:53:29 -0400
Received: by mail-pd0-f180.google.com with SMTP id fp1so421130pdb.25
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 01:53:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

pskb_may_pull() maybe change skb->data and make eth pointer oboslete,
so set eth after pskb_may_pull()

Fixes:3d7b46cd("ip_tunnel: push generic protocol handling to ip_tunnel module")
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/ip_tunnel_core.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index f4c987b..88c386c 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -91,11 +91,12 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto)
 	skb_pull_rcsum(skb, hdr_len);
 
 	if (inner_proto == htons(ETH_P_TEB)) {
-		struct ethhdr *eh = (struct ethhdr *)skb->data;
+		struct ethhdr *eh;
 
 		if (unlikely(!pskb_may_pull(skb, ETH_HLEN)))
 			return -ENOMEM;
 
+		eh = (struct ethhdr *)skb->data;
 		if (likely(ntohs(eh->h_proto) >= ETH_P_802_3_MIN))
 			skb->protocol = eh->h_proto;
 		else
-- 
1.7.10.4

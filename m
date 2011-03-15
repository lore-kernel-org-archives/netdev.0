From: kaber@trash.net
Subject: [PATCH 25/37] IPVS: Minimise ip_vs_leave when CONFIG_SYSCTL is undefined
Date: Tue, 15 Mar 2011 20:44:05 +0100
Message-ID: <1300218257-26953-26-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49428 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758444Ab1COToc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:32 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

Much of ip_vs_leave() is unnecessary if CONFIG_SYSCTL is undefined.

I tried an approach of breaking the now #ifdef'ed portions out
into a separate function. However this appeared to grow the
compiled code on x86_64 by about 200 bytes in the case where
CONFIG_SYSCTL is defined. So I have gone with the simpler though
less elegant #ifdef'ed solution for now.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d418bc6..07accf6 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -499,11 +499,13 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_proto_data *pd)
 {
-	struct net *net;
-	struct netns_ipvs *ipvs;
 	__be16 _ports[2], *pptr;
 	struct ip_vs_iphdr iph;
+#ifdef CONFIG_SYSCTL
+	struct net *net;
+	struct netns_ipvs *ipvs;
 	int unicast;
+#endif
 
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
@@ -512,6 +514,8 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_service_put(svc);
 		return NF_DROP;
 	}
+
+#ifdef CONFIG_SYSCTL
 	net = skb_net(skb);
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -563,6 +567,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_conn_put(cp);
 		return ret;
 	}
+#endif
 
 	/*
 	 * When the virtual ftp service is presented, packets destined
-- 
1.7.2.3


From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 15/26] IPVS: Modify IP_VS_XMIT() to support IPv6.
Date: Wed, 11 Jun 2008 19:11:58 +0200
Message-ID: <1213204329-10973-16-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com,
	"Julius R. Volz" <juliusv@google.com>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:14473 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbYFKRMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 13:12:34 -0400
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modify IP_VS_XMIT() to call PF_INET6 local output hook instead of PF_INET
one when sending IPv6 packets. This is indicated by specifying an
additional first pf argument.

Existing uses are converted to call IP_VS_XMIT(PF_INET, ...).

Signed-off-by: Julius R. Volz <juliusv@google.com>

 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 94b8fcb..029d9ec 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -199,11 +199,11 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 	dst_release(old_dst);
 }
 
-#define IP_VS_XMIT(skb, rt)				\
+#define IP_VS_XMIT(pf, skb, rt)				\
 do {							\
 	(skb)->ipvs_property = 1;			\
 	skb_forward_csum(skb);				\
-	NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, (skb), NULL,	\
+	NF_HOOK(pf, NF_INET_LOCAL_OUT, (skb), NULL,	\
 		(rt)->u.dst.dev, dst_output);		\
 } while (0)
 
@@ -276,7 +276,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(PF_INET, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -352,7 +352,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(PF_INET, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -543,7 +543,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(PF_INET, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -616,7 +616,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(PF_INET, skb, rt);
 
 	rc = NF_STOLEN;
 	goto out;
-- 
1.5.3.6


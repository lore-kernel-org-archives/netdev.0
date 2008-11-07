From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [RFC-PATCH] netfilter: payload_len is be16, add size of struct
 rather than size of pointer
Date: Fri, 07 Nov 2008 09:13:43 -0800
Message-ID: <1226078023.11596.17.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Wensong Zhang <wensong@linuxvirtualserver.org>,
	Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:33854 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbYKGROs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 12:14:48 -0500
Received: by yx-out-2324.google.com with SMTP id 8so532211yxm.1
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2008 09:14:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

payload_len is a be16 value, not cpu_endian, also the size of a ponter
to a struct ipv6hdr was being added, not the size of the struct itself.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
I'm quite supicious of the following code in net/netfilter/ipvs/ip_vs_xmit.c

Line 714:
	iph->payload_len	=	old_iph->payload_len + sizeof(old_iph);

I believe that the payload_len is a big-endian value and this is treating it as
cpu-ordered.  In addition, it is adding the size of a pointer to a struct ipv6hdr
and not the size of the struct itself.

If I'm correct, I'd suggest the following is what _may_ have been intended.

 net/netfilter/ipvs/ip_vs_xmit.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 2f36721..425ab14 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -711,7 +711,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	iph			=	ipv6_hdr(skb);
 	iph->version		=	6;
 	iph->nexthdr		=	IPPROTO_IPV6;
-	iph->payload_len	=	old_iph->payload_len + sizeof(old_iph);
+	iph->payload_len	=	old_iph->payload_len;
+	be16_add_cpu(&iph->payload_len, sizeof(*old_iph));
 	iph->priority		=	old_iph->priority;
 	memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));
 	iph->daddr		=	rt->rt6i_dst.addr;
-- 
1.6.0.3.756.gb776d




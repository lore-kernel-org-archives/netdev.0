From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 10/20] [PATCH] [IPV6] MIP6: Revert address to send ICMPv6 error.
Date: Sat, 29 Jul 2006 18:38:41 +0900
Message-ID: <11541659211448-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:44675 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422716AbWG2Jin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:38:43 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPv6 header addresses are replaced in receiving packet
with Mobile IPv6 extension headers.
To send ICMPv6 error back, original address which is received ones on wire
should be used. This function checks such header is included
and reverts them.

Based on MIPL2 kernel patch.
---
 net/ipv6/icmp.c |   63 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 63 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 1044b6f..0812585 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -273,6 +273,67 @@ static int icmpv6_getfrag(void *from, ch
 	return 0;
 }
 
+#ifdef CONFIG_IPV6_MIP6
+static void mip6_addr_swap(struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = skb->nh.ipv6h;
+	struct inet6_skb_parm *opt = (struct inet6_skb_parm *)skb->cb;
+	struct in6_addr tmp;
+	struct ipv6_rt_hdr *rth = NULL;
+	struct rt2_hdr *rt2h = NULL;
+	struct destopt_hao *hao = NULL;
+	unsigned int off;
+
+	if (opt->srcrt) {
+		rth = (struct ipv6_rt_hdr *)(skb->nh.raw + opt->srcrt);
+		if (rth->type == IPV6_SRCRT_TYPE_2)
+			rt2h = (struct rt2_hdr *)rth;
+		else {
+			u8 nexthdr = skb->nh.ipv6h->nexthdr;
+			off = sizeof(struct ipv6hdr);
+			while (rt2h == NULL && off <= opt->srcrt) {
+				unsigned len = 0;
+				u8 *ptr = skb->nh.raw + off;
+
+				switch(nexthdr) {
+				case IPPROTO_AH:
+					nexthdr = ptr[0];
+					len = (ptr[1] + 2) << 2;
+					break;
+				case IPPROTO_ROUTING:
+					rth = (struct ipv6_rt_hdr *)(skb->nh.raw + off);
+					if (rth->type == IPV6_SRCRT_TYPE_2)
+						rt2h = (struct rt2_hdr *)(skb->nh.raw + opt->srcrt);
+				default:
+					nexthdr = ptr[0];
+					len = (ptr[1] + 1) << 3;
+					break;
+				}
+				off += len;
+			}
+		} 
+		if (rt2h != NULL) {
+			rt2h->rt_hdr.segments_left++;
+			ipv6_addr_copy(&tmp, &iph->daddr);
+			ipv6_addr_copy(&iph->daddr, &rt2h->addr);
+			ipv6_addr_copy(&rt2h->addr, &tmp);
+		}
+	}
+	if (opt->dsthao) {
+		off = ipv6_find_tlv(skb, opt->dsthao, IPV6_TLV_HAO);
+		if (likely(off >= 0)) {
+			hao = (struct destopt_hao *)(skb->nh.raw + off);
+			ipv6_addr_copy(&tmp, &iph->saddr);
+			ipv6_addr_copy(&iph->saddr, &hao->addr);
+			ipv6_addr_copy(&hao->addr, &tmp);
+		}
+	}
+}
+#else
+static inline void mip6_addr_swap(struct sk_buff *skb) {}
+#endif
+
+
 /*
  *	Send an ICMP message in response to a packet in error
  */
@@ -350,6 +411,8 @@ void icmpv6_send(struct sk_buff *skb, in
 		return;
 	}
 
+	mip6_addr_swap(skb);
+
 	memset(&fl, 0, sizeof(fl));
 	fl.proto = IPPROTO_ICMPV6;
 	ipv6_addr_copy(&fl.fl6_dst, &hdr->saddr);
-- 
1.4.1


From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 26/44] [IPV6] MIP6: Revert address to send ICMPv6 error.
Date: Thu, 24 Aug 2006 00:02:27 +0900
Message-ID: <11563453663275-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:5769 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964939AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453661764-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

IPv6 source address is replaced in receiving packet
with home address option carried by destination options header.
To send ICMPv6 error back, original address which is received one on wire
should be used. This function checks such header is included
and reverts them.
Based on MIPL2 kernel patch.

This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/icmp.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 4a6e911..37364a7 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -273,6 +273,29 @@ static int icmpv6_getfrag(void *from, ch
 	return 0;
 }
 
+#ifdef CONFIG_IPV6_MIP6
+static void mip6_addr_swap(struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = skb->nh.ipv6h;
+	struct inet6_skb_parm *opt = IP6CB(skb);
+	struct ipv6_destopt_hao *hao;
+	struct in6_addr tmp;
+	int off;
+
+	if (opt->dsthao) {
+		off = ipv6_find_tlv(skb, opt->dsthao, IPV6_TLV_HAO);
+		if (likely(off >= 0)) {
+			hao = (struct ipv6_destopt_hao *)(skb->nh.raw + off);
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
 /*
  *	Send an ICMP message in response to a packet in error
  */
@@ -350,6 +373,8 @@ void icmpv6_send(struct sk_buff *skb, in
 		return;
 	}
 
+	mip6_addr_swap(skb);
+
 	memset(&fl, 0, sizeof(fl));
 	fl.proto = IPPROTO_ICMPV6;
 	ipv6_addr_copy(&fl.fl6_dst, &hdr->saddr);
-- 
1.4.0


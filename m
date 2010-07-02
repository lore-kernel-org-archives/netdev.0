From: Peter Kosyh <p.kosyh@gmail.com>
Subject: [PATCHv2] xfrm: fix xfrm by MARK logic
Date: Fri, 2 Jul 2010 21:47:55 +0400
Message-ID: <20100702174755.GA12509@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53970 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757448Ab0GBRsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 13:48:05 -0400
Received: by bwz1 with SMTP id 1so1728637bwz.19
        for <netdev@vger.kernel.org>; Fri, 02 Jul 2010 10:48:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Kosyh <p.kosyh@gmail.com>

While using xfrm by MARK feature in
2.6.34 - 2.6.35 kernels, the mark 
is always cleared in flowi structure via memset in 
_decode_session4 (net/ipv4/xfrm4_policy.c), so
the policy lookup fails.
IPv6 code is affected by this bug too.

Signed-off-by: Peter Kosyh <p.kosyh@gmail.com>
---

diff -uprN linux-2.6.35-rc3.orig/net/ipv4/xfrm4_policy.c linux-2.6.35-rc3/net/ipv4/xfrm4_policy.c
--- linux-2.6.35-rc3.orig/net/ipv4/xfrm4_policy.c	2010-06-12 06:14:04.000000000 +0400
+++ linux-2.6.35-rc3/net/ipv4/xfrm4_policy.c	2010-07-02 20:20:49.000000000 +0400
@@ -108,6 +108,8 @@ _decode_session4(struct sk_buff *skb, st
 	u8 *xprth = skb_network_header(skb) + iph->ihl * 4;
 
 	memset(fl, 0, sizeof(struct flowi));
+	fl->mark = skb->mark;
+
 	if (!(iph->frag_off & htons(IP_MF | IP_OFFSET))) {
 		switch (iph->protocol) {
 		case IPPROTO_UDP:
diff -uprN linux-2.6.35-rc3.orig/net/ipv6/xfrm6_policy.c linux-2.6.35-rc3/net/ipv6/xfrm6_policy.c
--- linux-2.6.35-rc3.orig/net/ipv6/xfrm6_policy.c	2010-06-12 06:14:04.000000000 +0400
+++ linux-2.6.35-rc3/net/ipv6/xfrm6_policy.c	2010-07-02 20:20:22.000000000 +0400
@@ -124,6 +124,8 @@ _decode_session6(struct sk_buff *skb, st
 	u8 nexthdr = nh[IP6CB(skb)->nhoff];
 
 	memset(fl, 0, sizeof(struct flowi));
+	fl->mark = skb->mark;
+
 	ipv6_addr_copy(&fl->fl6_dst, reverse ? &hdr->saddr : &hdr->daddr);
 	ipv6_addr_copy(&fl->fl6_src, reverse ? &hdr->daddr : &hdr->saddr);
 

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH] ipsec: fix IPv4 AH alignment on 32 bits
Date: Thu, 13 Jan 2011 18:20:19 +0100
Message-ID: <4D2F3453.9020203@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050502080709010608080605"
Cc: Christophe Gouault <christophe.gouault@6wind.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42950 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757291Ab1AMRWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 12:22:33 -0500
Received: by wyb28 with SMTP id 28so1927509wyb.19
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 09:22:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050502080709010608080605
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

here is a patch to fix alignment of IPv4 AH. Note that this break compatiblity 
for some algorithms (like SHA256) with old kernels ... but upstream cannot use 
SHA256 on IPv4, for example, with a target that is RFC compliant.

I don't know what is the best way to fix this.


Regards,
Nicolas

--------------050502080709010608080605
Content-Type: text/x-patch;
 name="0001-ipsec-fix-IPv4-AH-alignment-on-32-bits.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-ipsec-fix-IPv4-AH-alignment-on-32-bits.patch"

>From 14bbe173eed25cf59e3e54222eb7de1a5578e54e Mon Sep 17 00:00:00 2001
From: Dang Hongwu <hongwu.dang@6wind.com>
Date: Wed, 22 Dec 2010 11:38:47 -0500
Subject: [PATCH] ipsec: fix IPv4 AH alignment on 32 bits

The Linux IPv4 AH stack aligns the AH header on a 64 bit boundary
(like in IPv6). This is not RFC compliant (see RFC4302, Section
3.3.3.2.1), it should be aligned on 32 bits.

For most of the authentication algorithms, the ICV size is 96 bits.
The AH header alignment on 32 or 64 bits gives the same results.

However for SHA-256-128 for instance, the wrong 64 bit alignment results
in adding useless padding in IPv4 AH, which is forbidden by the RFC.

Signed-off-by: Dang Hongwu <hongwu.dang@6wind.com>
Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/xfrm.h |    1 +
 net/ipv4/ah4.c     |    8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bcfb6b2..525d882 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -36,6 +36,7 @@
 #define XFRM_PROTO_ROUTING	IPPROTO_ROUTING
 #define XFRM_PROTO_DSTOPTS	IPPROTO_DSTOPTS
 
+#define XFRM_ALIGN4(len)	(((len) + 3) & ~3)
 #define XFRM_ALIGN8(len)	(((len) + 7) & ~7)
 #define MODULE_ALIAS_XFRM_MODE(family, encap) \
 	MODULE_ALIAS("xfrm-mode-" __stringify(family) "-" __stringify(encap))
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 86961be..95561d6 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -201,7 +201,7 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 	top_iph->ttl = 0;
 	top_iph->check = 0;
 
-	ah->hdrlen  = (XFRM_ALIGN8(sizeof(*ah) + ahp->icv_trunc_len) >> 2) - 2;
+	ah->hdrlen  = (XFRM_ALIGN4(sizeof(*ah) + ahp->icv_trunc_len) >> 2) - 2;
 
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
@@ -299,8 +299,8 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 	nexthdr = ah->nexthdr;
 	ah_hlen = (ah->hdrlen + 2) << 2;
 
-	if (ah_hlen != XFRM_ALIGN8(sizeof(*ah) + ahp->icv_full_len) &&
-	    ah_hlen != XFRM_ALIGN8(sizeof(*ah) + ahp->icv_trunc_len))
+	if (ah_hlen != XFRM_ALIGN4(sizeof(*ah) + ahp->icv_full_len) &&
+	    ah_hlen != XFRM_ALIGN4(sizeof(*ah) + ahp->icv_trunc_len))
 		goto out;
 
 	if (!pskb_may_pull(skb, ah_hlen))
@@ -450,7 +450,7 @@ static int ah_init_state(struct xfrm_state *x)
 
 	BUG_ON(ahp->icv_trunc_len > MAX_AH_AUTH_LEN);
 
-	x->props.header_len = XFRM_ALIGN8(sizeof(struct ip_auth_hdr) +
+	x->props.header_len = XFRM_ALIGN4(sizeof(struct ip_auth_hdr) +
 					  ahp->icv_trunc_len);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct iphdr);
-- 
1.5.6.5


--------------050502080709010608080605--

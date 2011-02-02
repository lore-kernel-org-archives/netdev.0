From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] ipsec: allow to align IPv4 AH on 32 bits
Date: Wed, 02 Feb 2011 17:29:02 +0100
Message-ID: <4D49864E.8020002@6wind.com>
References: <20110128045108.GA8351@gondor.apana.org.au>	<4D42839C.3050401@6wind.com> <20110128.114610.193716130.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070300010200040405050105"
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	christophe.gouault@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:39543 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396Ab1BBQ3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 11:29:07 -0500
Received: by ewy5 with SMTP id 5so108916ewy.19
        for <netdev@vger.kernel.org>; Wed, 02 Feb 2011 08:29:05 -0800 (PST)
In-Reply-To: <20110128.114610.193716130.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070300010200040405050105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 28/01/2011 20:46, David Miller wrote:
> From: Nicolas Dichtel<nicolas.dichtel@6wind.com>
> Date: Fri, 28 Jan 2011 09:51:40 +0100
>
>> On 28/01/2011 05:51, Herbert Xu wrote:
>>> So perhaps an SA configuration flag is needed?
>> I agree. If David is ok, I will update the patch.
>
> Sounds good to me.

Here is the new patch.

The patch for iproute2 in the next email.

Regards,
Nicolas

--------------070300010200040405050105
Content-Type: text/x-patch;
 name="0001-ipsec-allow-to-align-IPv4-AH-on-32-bits.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-ipsec-allow-to-align-IPv4-AH-on-32-bits.patch"

>From 1772aa5401b24f4cb4cc10b038becdeb2c687531 Mon Sep 17 00:00:00 2001
From: Dang Hongwu <hongwu.dang@6wind.com>
Date: Wed, 22 Dec 2010 11:38:47 -0500
Subject: [PATCH] ipsec: allow to align IPv4 AH on 32 bits

The Linux IPv4 AH stack aligns the AH header on a 64 bit boundary
(like in IPv6). This is not RFC compliant (see RFC4302, Section
3.3.3.2.1), it should be aligned on 32 bits.

For most of the authentication algorithms, the ICV size is 96 bits.
The AH header alignment on 32 or 64 bits gives the same results.

However for SHA-256-128 for instance, the wrong 64 bit alignment results
in adding useless padding in IPv4 AH, which is forbidden by the RFC.

To avoid breaking backward compatibility, we use a new flag
(XFRM_STATE_ALIGN4) do change original behavior.

Initial patch from Dang Hongwu <hongwu.dang@6wind.com> and
Christophe Gouault <christophe.gouault@6wind.com>.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/xfrm.h |    1 +
 include/net/xfrm.h   |    1 +
 net/ipv4/ah4.c       |   25 +++++++++++++++++++------
 3 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 930fdd2..b93d6f5 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -350,6 +350,7 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_WILDRECV	8
 #define XFRM_STATE_ICMP		16
 #define XFRM_STATE_AF_UNSPEC	32
+#define XFRM_STATE_ALIGN4	64
 };
 
 struct xfrm_usersa_id {
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index b9f385d..1f6e8a0 100644
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
index 86961be..325053d 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -201,7 +201,10 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 	top_iph->ttl = 0;
 	top_iph->check = 0;
 
-	ah->hdrlen  = (XFRM_ALIGN8(sizeof(*ah) + ahp->icv_trunc_len) >> 2) - 2;
+	if (x->props.flags & XFRM_STATE_ALIGN4)
+		ah->hdrlen  = (XFRM_ALIGN4(sizeof(*ah) + ahp->icv_trunc_len) >> 2) - 2;
+	else
+		ah->hdrlen  = (XFRM_ALIGN8(sizeof(*ah) + ahp->icv_trunc_len) >> 2) - 2;
 
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
@@ -299,9 +302,15 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 	nexthdr = ah->nexthdr;
 	ah_hlen = (ah->hdrlen + 2) << 2;
 
-	if (ah_hlen != XFRM_ALIGN8(sizeof(*ah) + ahp->icv_full_len) &&
-	    ah_hlen != XFRM_ALIGN8(sizeof(*ah) + ahp->icv_trunc_len))
-		goto out;
+	if (x->props.flags & XFRM_STATE_ALIGN4) {
+		if (ah_hlen != XFRM_ALIGN4(sizeof(*ah) + ahp->icv_full_len) &&
+		    ah_hlen != XFRM_ALIGN4(sizeof(*ah) + ahp->icv_trunc_len))
+			goto out;
+	} else {
+		if (ah_hlen != XFRM_ALIGN8(sizeof(*ah) + ahp->icv_full_len) &&
+		    ah_hlen != XFRM_ALIGN8(sizeof(*ah) + ahp->icv_trunc_len))
+			goto out;
+	}
 
 	if (!pskb_may_pull(skb, ah_hlen))
 		goto out;
@@ -450,8 +459,12 @@ static int ah_init_state(struct xfrm_state *x)
 
 	BUG_ON(ahp->icv_trunc_len > MAX_AH_AUTH_LEN);
 
-	x->props.header_len = XFRM_ALIGN8(sizeof(struct ip_auth_hdr) +
-					  ahp->icv_trunc_len);
+	if (x->props.flags & XFRM_STATE_ALIGN4)
+		x->props.header_len = XFRM_ALIGN4(sizeof(struct ip_auth_hdr) +
+						  ahp->icv_trunc_len);
+	else
+		x->props.header_len = XFRM_ALIGN8(sizeof(struct ip_auth_hdr) +
+						  ahp->icv_trunc_len);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct iphdr);
 	x->data = ahp;
-- 
1.5.6.5


--------------070300010200040405050105--

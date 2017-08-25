From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v2 2/5] ipv6: sr: add support for encapsulation of L2 frames
Date: Fri, 25 Aug 2017 09:56:45 +0200
Message-ID: <20170825075648.5061-3-david.lebrun@uclouvain.be>
References: <20170825075648.5061-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:39344 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754564AbdHYH4X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 03:56:23 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp2.sgsi.ucl.ac.be (Postfix) with ESMTPS id C4E5A67DDE7
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 09:56:13 +0200 (CEST)
In-Reply-To: <20170825075648.5061-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the L2 frame encapsulation mechanism, referred to
as T.Encaps.L2 in the SRv6 specifications [1].

A new type of SRv6 tunnel mode is added (SEG6_IPTUN_MODE_L2ENCAP). It only
accepts packets with an existing MAC header (i.e., it will not work for
locally generated packets). The resulting packet looks like IPv6 -> SRH ->
Ethernet -> original L3 payload. The next header field of the SRH is set to
NEXTHDR_NONE.

[1] https://tools.ietf.org/html/draft-filsfils-spring-srv6-network-programming-01

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/uapi/linux/seg6_iptunnel.h | 18 ++++++++++++++----
 net/ipv6/seg6_iptunnel.c           | 25 +++++++++++++++++++++++--
 2 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/seg6_iptunnel.h b/include/uapi/linux/seg6_iptunnel.h
index b6e5a0a..b23df9f 100644
--- a/include/uapi/linux/seg6_iptunnel.h
+++ b/include/uapi/linux/seg6_iptunnel.h
@@ -33,16 +33,26 @@ struct seg6_iptunnel_encap {
 enum {
 	SEG6_IPTUN_MODE_INLINE,
 	SEG6_IPTUN_MODE_ENCAP,
+	SEG6_IPTUN_MODE_L2ENCAP,
 };
 
 #ifdef __KERNEL__
 
 static inline size_t seg6_lwt_headroom(struct seg6_iptunnel_encap *tuninfo)
 {
-	int encap = (tuninfo->mode == SEG6_IPTUN_MODE_ENCAP);
-
-	return ((tuninfo->srh->hdrlen + 1) << 3) +
-	       (encap * sizeof(struct ipv6hdr));
+	int head = 0;
+
+	switch (tuninfo->mode) {
+	case SEG6_IPTUN_MODE_INLINE:
+		break;
+	case SEG6_IPTUN_MODE_ENCAP:
+		head = sizeof(struct ipv6hdr);
+		break;
+	case SEG6_IPTUN_MODE_L2ENCAP:
+		return 0;
+	}
+
+	return ((tuninfo->srh->hdrlen + 1) << 3) + head;
 }
 
 #endif
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index 5bec781..bd6cc68 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -240,6 +240,22 @@ static int seg6_do_srh(struct sk_buff *skb)
 
 		skb->protocol = htons(ETH_P_IPV6);
 		break;
+	case SEG6_IPTUN_MODE_L2ENCAP:
+		if (!skb_mac_header_was_set(skb))
+			return -EINVAL;
+
+		if (pskb_expand_head(skb, skb->mac_len, 0, GFP_ATOMIC) < 0)
+			return -ENOMEM;
+
+		skb_mac_header_rebuild(skb);
+		skb_push(skb, skb->mac_len);
+
+		err = seg6_do_srh_encap(skb, tinfo->srh, NEXTHDR_NONE);
+		if (err)
+			return err;
+
+		skb->protocol = htons(ETH_P_IPV6);
+		break;
 	}
 
 	ipv6_hdr(skb)->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
@@ -386,6 +402,8 @@ static int seg6_build_state(struct nlattr *nla,
 		break;
 	case SEG6_IPTUN_MODE_ENCAP:
 		break;
+	case SEG6_IPTUN_MODE_L2ENCAP:
+		break;
 	default:
 		return -EINVAL;
 	}
@@ -409,8 +427,11 @@ static int seg6_build_state(struct nlattr *nla,
 	memcpy(&slwt->tuninfo, tuninfo, tuninfo_len);
 
 	newts->type = LWTUNNEL_ENCAP_SEG6;
-	newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT |
-			LWTUNNEL_STATE_INPUT_REDIRECT;
+	newts->flags |= LWTUNNEL_STATE_INPUT_REDIRECT;
+
+	if (tuninfo->mode != SEG6_IPTUN_MODE_L2ENCAP)
+		newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT;
+
 	newts->headroom = seg6_lwt_headroom(tuninfo);
 
 	*ts = newts;
-- 
2.10.2

From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next 2/5] ipv6: sr: add support for encapsulation of L2 frames
Date: Wed, 23 Aug 2017 17:32:00 +0200
Message-ID: <20170823153203.11951-3-david.lebrun@uclouvain.be>
References: <20170823153203.11951-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:35638 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754152AbdHWPbx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 11:31:53 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp6.sgsi.ucl.ac.be (Postfix) with ESMTPS id 519D667DA36
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 17:31:43 +0200 (CEST)
In-Reply-To: <20170823153203.11951-1-david.lebrun@uclouvain.be>
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
 include/uapi/linux/seg6_iptunnel.h | 19 +++++++++++++++----
 net/ipv6/seg6_iptunnel.c           | 18 ++++++++++++++++++
 2 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/seg6_iptunnel.h b/include/uapi/linux/seg6_iptunnel.h
index b6e5a0a..63f0fe4 100644
--- a/include/uapi/linux/seg6_iptunnel.h
+++ b/include/uapi/linux/seg6_iptunnel.h
@@ -33,16 +33,27 @@ struct seg6_iptunnel_encap {
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
+		head = sizeof(struct ipv6hdr) + 14;
+		break;
+	}
+
+	return ((tuninfo->srh->hdrlen + 1) << 3) + head;
 }
 
 #endif
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index 5bec781..93aa322 100644
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
-- 
2.10.2

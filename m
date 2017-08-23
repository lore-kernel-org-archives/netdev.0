From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next 1/5] ipv6: sr: add support for ip4ip6 encapsulation
Date: Wed, 23 Aug 2017 17:31:59 +0200
Message-ID: <20170823153203.11951-2-david.lebrun@uclouvain.be>
References: <20170823153203.11951-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:57585 "EHLO
        smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754140AbdHWPbx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 11:31:53 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp3.sgsi.ucl.ac.be (Postfix) with ESMTPS id 271C667D9E6
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 17:31:43 +0200 (CEST)
In-Reply-To: <20170823153203.11951-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the SRv6 encapsulation mode to carry an IPv4 payload.
All the infrastructure was already present, I just had to add a parameter
to seg6_do_srh_encap() to specify the inner packet protocol, and perform
some additional checks.

Usage example:
ip route add 1.2.3.4 encap seg6 mode encap segs fc00::1,fc00::2 dev eth0

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/net/seg6.h       |  3 ++-
 net/ipv6/seg6_iptunnel.c | 47 +++++++++++++++++++++++++++++++++++++----------
 net/ipv6/seg6_local.c    |  2 +-
 3 files changed, 40 insertions(+), 12 deletions(-)

diff --git a/include/net/seg6.h b/include/net/seg6.h
index 5379f55..099bad5 100644
--- a/include/net/seg6.h
+++ b/include/net/seg6.h
@@ -60,7 +60,8 @@ extern int seg6_local_init(void);
 extern void seg6_local_exit(void);
 
 extern bool seg6_validate_srh(struct ipv6_sr_hdr *srh, int len);
-extern int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh);
+extern int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh,
+			     int proto);
 extern int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh);
 
 #endif
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index 5012330..5bec781 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -91,7 +91,7 @@ static void set_tun_src(struct net *net, struct net_device *dev,
 }
 
 /* encapsulate an IPv6 packet within an outer IPv6 header with a given SRH */
-int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
+int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh, int proto)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct ipv6hdr *hdr, *inner_hdr;
@@ -116,15 +116,22 @@ int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 	 * hlim will be decremented in ip6_forward() afterwards and
 	 * decapsulation will overwrite inner hlim with outer hlim
 	 */
-	ip6_flow_hdr(hdr, ip6_tclass(ip6_flowinfo(inner_hdr)),
-		     ip6_flowlabel(inner_hdr));
-	hdr->hop_limit = inner_hdr->hop_limit;
+
+	if (skb->protocol == htons(ETH_P_IPV6)) {
+		ip6_flow_hdr(hdr, ip6_tclass(ip6_flowinfo(inner_hdr)),
+			     ip6_flowlabel(inner_hdr));
+		hdr->hop_limit = inner_hdr->hop_limit;
+	} else {
+		ip6_flow_hdr(hdr, 0, 0);
+		hdr->hop_limit = ip6_dst_hoplimit(skb_dst(skb));
+	}
+
 	hdr->nexthdr = NEXTHDR_ROUTING;
 
 	isrh = (void *)hdr + sizeof(*hdr);
 	memcpy(isrh, osrh, hdrlen);
 
-	isrh->nexthdr = NEXTHDR_IPV6;
+	isrh->nexthdr = proto;
 
 	hdr->daddr = isrh->segments[isrh->first_segment];
 	set_tun_src(net, skb->dev, &hdr->daddr, &hdr->saddr);
@@ -199,7 +206,7 @@ static int seg6_do_srh(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct seg6_iptunnel_encap *tinfo;
-	int err = 0;
+	int proto, err = 0;
 
 	tinfo = seg6_encap_lwtunnel(dst->lwtstate);
 
@@ -210,17 +217,31 @@ static int seg6_do_srh(struct sk_buff *skb)
 
 	switch (tinfo->mode) {
 	case SEG6_IPTUN_MODE_INLINE:
+		if (skb->protocol != htons(ETH_P_IPV6))
+			return -EINVAL;
+
 		err = seg6_do_srh_inline(skb, tinfo->srh);
+		if (err)
+			return err;
+
 		skb_reset_inner_headers(skb);
 		break;
 	case SEG6_IPTUN_MODE_ENCAP:
-		err = seg6_do_srh_encap(skb, tinfo->srh);
+		if (skb->protocol == htons(ETH_P_IPV6))
+			proto = IPPROTO_IPV6;
+		else if (skb->protocol == htons(ETH_P_IP))
+			proto = IPPROTO_IPIP;
+		else
+			return -EINVAL;
+
+		err = seg6_do_srh_encap(skb, tinfo->srh, proto);
+		if (err)
+			return err;
+
+		skb->protocol = htons(ETH_P_IPV6);
 		break;
 	}
 
-	if (err)
-		return err;
-
 	ipv6_hdr(skb)->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
 
@@ -334,6 +355,9 @@ static int seg6_build_state(struct nlattr *nla,
 	struct seg6_lwt *slwt;
 	int err;
 
+	if (family != AF_INET && family != AF_INET6)
+		return -EINVAL;
+
 	err = nla_parse_nested(tb, SEG6_IPTUNNEL_MAX, nla,
 			       seg6_iptunnel_policy, extack);
 
@@ -356,6 +380,9 @@ static int seg6_build_state(struct nlattr *nla,
 
 	switch (tuninfo->mode) {
 	case SEG6_IPTUN_MODE_INLINE:
+		if (family != AF_INET6)
+			return -EINVAL;
+
 		break;
 	case SEG6_IPTUN_MODE_ENCAP:
 		break;
diff --git a/net/ipv6/seg6_local.c b/net/ipv6/seg6_local.c
index 147680e..609b94e 100644
--- a/net/ipv6/seg6_local.c
+++ b/net/ipv6/seg6_local.c
@@ -290,7 +290,7 @@ static int input_action_end_b6_encap(struct sk_buff *skb,
 	skb_reset_inner_headers(skb);
 	skb->encapsulation = 1;
 
-	err = seg6_do_srh_encap(skb, slwt->srh);
+	err = seg6_do_srh_encap(skb, slwt->srh, IPPROTO_IPV6);
 	if (err)
 		goto drop;
 
-- 
2.10.2

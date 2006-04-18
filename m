From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/4] [IPV6]: Ensure to have hop-by-hop options in our
 header of &sk_buff.
Date: Wed, 19 Apr 2006 00:20:56 +0900 (JST)
Message-ID: <20060419.002056.131001125.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:1299 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932271AbWDRPSP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 11:18:15 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6]: Ensure to have hop-by-hop options in our header of &sk_buff.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---

 net/ipv6/exthdrs.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

7bcedcc73a45a5577103422c33e01f1633173984
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 2a1e7e4..d88cab7 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -489,6 +489,18 @@ int ipv6_parse_hopopts(struct sk_buff *s
 {
 	struct inet6_skb_parm *opt = IP6CB(skb);
 
+	/*
+	 * skb->nh.raw is equal to skb->data, and
+	 * skb->h.raw - skb->nh.raw is always equal to
+	 * sizeof(struct ipv6hdr) by definition of
+	 * hop-by-hop options.
+	 */
+	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr) + 8) ||
+	    !pskb_may_pull(skb, sizeof(struct ipv6hdr) + ((skb->h.raw[1] + 1) << 3))) {
+		kfree_skb(skb);
+		return -1;
+	}
+
 	opt->hop = sizeof(struct ipv6hdr);
 	if (ip6_parse_tlv(tlvprochopopt_lst, skb)) {
 		skb->h.raw += (skb->h.raw[1]+1)<<3;
-- 
1.0.8

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

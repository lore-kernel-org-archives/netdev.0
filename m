From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [PATCH] [XFRM] Beet: Fix output for ipv6
Date: Fri, 8 Feb 2008 18:12:18 +0200
Message-ID: <200802081812.18985.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:48793 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760540AbYBHQe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 11:34:27 -0500
Received: from localhost (localhost [127.0.0.1])
	by creon.otaverkko.fi (Postfix) with ESMTP id 90CFF21AFA5
	for <netdev@vger.kernel.org>; Fri,  8 Feb 2008 18:12:29 +0200 (EET)
Received: from argo.otaverkko.fi (argo.otaverkko.fi [212.68.0.2])
	by creon.otaverkko.fi (Postfix) with ESMTP id 9F84021AF4C
	for <netdev@vger.kernel.org>; Fri,  8 Feb 2008 18:12:23 +0200 (EET)
Received: from [10.0.0.48] (dsl-hkibrasgw1-ff1ac100-249.dhcp.inet.fi [88.193.26.249])
	by argo.otaverkko.fi (Postfix) with ESMTP id 96E8025ED06
	for <netdev@vger.kernel.org>; Fri,  8 Feb 2008 18:12:23 +0200 (EET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch fixes the ipv6 mode of ipsec beet. It has been using logic
similar to tunnel mode, making it crash during esp packaging.

Signed-off-by: Joakim Koskela <jookos@gmail.com>
---
 net/ipv6/xfrm6_mode_beet.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index 0527d11..0395800 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -40,11 +40,14 @@ static void xfrm6_beet_make_header(struct sk_buff *skb)
 static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *top_iph;
+	u8 *prevhdr;
+	int hdr_len;
 
+	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
+	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
 	skb_set_network_header(skb, -x->props.header_len);
-	skb->mac_header = skb->network_header +
-			  offsetof(struct ipv6hdr, nexthdr);
-	skb->transport_header = skb->network_header + sizeof(*top_iph);
+	skb->transport_header = skb->network_header + hdr_len;
+	__skb_pull(skb, hdr_len);
 
 	xfrm6_beet_make_header(skb);
 

From: Travis Brown <travisb@aristanetworks.com>
Subject: [Patch v2] ipv6: mld: Prevent skb_over_panic with large MTUs
Date: Mon, 23 Dec 2013 15:16:21 -0800
Message-ID: <1387840581-10995-1-git-send-email-travisb@aristanetworks.com>
References: <1387586456-25892-1-git-send-email-travisb@aristanetworks.com>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	travisb@aristanetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34030 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752817Ab3LWXQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 18:16:41 -0500
Received: by mail-pa0-f54.google.com with SMTP id rd3so5876889pab.27
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 15:16:41 -0800 (PST)
In-Reply-To: <1387586456-25892-1-git-send-email-travisb@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MLD limits the maximum skb size to fit within a single page. Later
code uses the device MTU, if available, to determine whether the skb
has sufficient room for another field. On interfaces with MTUs larger
than the page size, less the skb overhead, this can result in the skb
being overrun and a skb_over_panic being generated.

Use skb_availroom() instead of MTU check.

Signed-off-by: Travis Brown <travisb@aristanetworks.com>
Fixes: 72e09ad107e78 ("ipv6: avoid high order allocations")
---
 net/ipv6/mcast.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index d18f9f9..e16e9cb 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1533,22 +1533,24 @@ static struct sk_buff *mld_newpack(struct inet6_dev *idev, int size)
 	const struct in6_addr *saddr;
 	int hlen = LL_RESERVED_SPACE(dev);
 	int tlen = dev->needed_tailroom;
+	int skb_size;
 	int err;
 	u8 ra[8] = { IPPROTO_ICMPV6, 0,
 		     IPV6_TLV_ROUTERALERT, 2, 0, 0,
 		     IPV6_TLV_PADN, 0 };
 
 	/* we assume size > sizeof(ra) here */
-	size += hlen + tlen;
+	skb_size = size + hlen + tlen;
 	/* limit our allocations to order-0 page */
-	size = min_t(int, size, SKB_MAX_ORDER(0, 0));
-	skb = sock_alloc_send_skb(sk, size, 1, &err);
+	skb_size = min_t(int, skb_size, SKB_MAX_ORDER(0, 0));
+	skb = sock_alloc_send_skb(sk, skb_size, 1, &err);
 
 	if (!skb)
 		return NULL;
 
 	skb->priority = TC_PRIO_CONTROL;
 	skb_reserve(skb, hlen);
+	skb->reserved_tailroom = skb->end - skb->tail - size;
 
 	if (__ipv6_get_lladdr(idev, &addr_buf, IFA_F_TENTATIVE)) {
 		/* <draft-ietf-magma-mld-source-05.txt>:
@@ -1661,8 +1663,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 	return skb;
 }
 
-#define AVAILABLE(skb) ((skb) ? ((skb)->dev ? (skb)->dev->mtu - (skb)->len : \
-	skb_tailroom(skb)) : 0)
+#define AVAILABLE(skb) ((skb) ? skb_availroom(skb) : 0)
 
 static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 	int type, int gdeleted, int sdeleted)
-- 
1.7.4.4

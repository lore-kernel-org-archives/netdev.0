From: Hideo AOKI <haoki@redhat.com>
Subject: [RFC PATCH] [NET] [2/2] pskb_expand_head() updates truesize
Date: Tue, 25 Mar 2008 14:41:51 -0400
Message-ID: <47E9476F.9000502@redhat.com>
References: <47E946C8.6020006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759472AbYCYSqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 14:46:05 -0400
In-Reply-To: <47E946C8.6020006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch revises pskb_expand_head() to update truesize.

Applying this change, caller functions don't have to update truesize
by themselves. Moreover, skb can keep correct truesize even if
allocation size is aligned in pskb_expand_head().  

This patch also removes updating truesize in callers since the update
doesn't need anymore.

[Note: Updating truesize in audit_expand() is fixed by anther patch.]

Signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 core/skbuff.c        |    6 ++++++
 ipv4/ipcomp.c        |    1 -
 ipv6/ipcomp6.c       |    1 -
 netlink/af_netlink.c |    3 +--
 4 files changed, 7 insertions(+), 4 deletions(-)

diff -pruN net-2.6-mod-p1/net/core/skbuff.c net-2.6-mod-p2/net/core/skbuff.c
--- net-2.6-mod-p1/net/core/skbuff.c	2008-02-25 09:05:46.000000000 -0500
+++ net-2.6-mod-p2/net/core/skbuff.c	2008-03-24 14:22:55.000000000 -0400
@@ -701,6 +701,12 @@ int pskb_expand_head(struct sk_buff *skb
 
 	skb_release_data(skb);
 
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	skb->truesize += (size - skb->end);
+#else
+	skb->truesize += (size - (skb->end - skb->head));
+#endif
+
 	off = (data + nhead) - skb->head;
 
 	skb->head     = data;
diff -pruN net-2.6-mod-p1/net/ipv4/ipcomp.c net-2.6-mod-p2/net/ipv4/ipcomp.c
--- net-2.6-mod-p1/net/ipv4/ipcomp.c	2008-03-05 05:12:30.000000000 -0500
+++ net-2.6-mod-p2/net/ipv4/ipcomp.c	2008-03-24 14:25:47.000000000 -0400
@@ -64,7 +64,6 @@ static int ipcomp_decompress(struct xfrm
 	if (err)
 		goto out;
 
-	skb->truesize += dlen - plen;
 	__skb_put(skb, dlen - plen);
 	skb_copy_to_linear_data(skb, scratch, dlen);
 out:
diff -pruN net-2.6-mod-p1/net/ipv6/ipcomp6.c net-2.6-mod-p2/net/ipv6/ipcomp6.c
--- net-2.6-mod-p1/net/ipv6/ipcomp6.c	2008-03-05 05:12:30.000000000 -0500
+++ net-2.6-mod-p2/net/ipv6/ipcomp6.c	2008-03-24 14:22:55.000000000 -0400
@@ -108,7 +108,6 @@ static int ipcomp6_input(struct xfrm_sta
 		goto out_put_cpu;
 	}
 
-	skb->truesize += dlen - plen;
 	__skb_put(skb, dlen - plen);
 	skb_copy_to_linear_data(skb, scratch, dlen);
 	err = nexthdr;
diff -pruN net-2.6-mod-p1/net/netlink/af_netlink.c net-2.6-mod-p2/net/netlink/af_netlink.c
--- net-2.6-mod-p1/net/netlink/af_netlink.c	2008-02-05 12:00:28.000000000 -0500
+++ net-2.6-mod-p2/net/netlink/af_netlink.c	2008-03-24 14:22:55.000000000 -0400
@@ -835,8 +835,7 @@ static inline struct sk_buff *netlink_tr
 		skb = nskb;
 	}
 
-	if (!pskb_expand_head(skb, 0, -delta, allocation))
-		skb->truesize -= delta;
+	pskb_expand_head(skb, 0, -delta, allocation);
 
 	return skb;
 }
-- 
Hitachi Computer Products (America) Inc.



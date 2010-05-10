From: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Subject: [patch] use alloc_page instead of alloc_pages (0)
Date: Mon, 10 May 2010 10:44:33 +0200
Message-ID: <1273481073.6676.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-7XKcBlZIYxNNSOHrzAE6"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:11893
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755540Ab0EJIof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 04:44:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7XKcBlZIYxNNSOHrzAE6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

The attached patch is pretty obvious and should apply on top of
net-next-2.6. I resisted the temptation to define alloc_page_node in
include/linux/gfp.h to get rid of the call to alloc_pages_node in
net/core/skbuff.c for symmetry but I would be happy to submit another
patch with this if others want it.

Mathieu
-- 
Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Tel: +33 4 9238 5056

--=-7XKcBlZIYxNNSOHrzAE6
Content-Disposition: attachment; filename="alloc.patch"
Content-Type: text/x-patch; name="alloc.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit 24559b5892690655f1223ca8600eeaad02c5327d
Author: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Date:   Mon May 10 10:31:00 2010 +0200

    use alloc_page instead of alloc_pages (0)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2ad68da..610ed0c 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2712,7 +2712,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 
 		i = 0;
 		while (datalen > 0) {
-			struct page *page = alloc_pages(GFP_KERNEL | __GFP_ZERO, 0);
+			struct page *page = alloc_page(GFP_KERNEL | __GFP_ZERO);
 			skb_shinfo(skb)->frags[i].page = page;
 			skb_shinfo(skb)->frags[i].page_offset = 0;
 			skb_shinfo(skb)->frags[i].size =
@@ -3062,7 +3062,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 
 		i = 0;
 		while (datalen > 0) {
-			struct page *page = alloc_pages(GFP_KERNEL, 0);
+			struct page *page = alloc_page(GFP_KERNEL);
 			skb_shinfo(skb)->frags[i].page = page;
 			skb_shinfo(skb)->frags[i].page_offset = 0;
 			skb_shinfo(skb)->frags[i].size =
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8b9c109..974a748 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1387,7 +1387,7 @@ static inline struct page *linear_to_page(struct page *page, unsigned int *len,
 
 	if (!p) {
 new_page:
-		p = sk->sk_sndmsg_page = alloc_pages(sk->sk_allocation, 0);
+		p = sk->sk_sndmsg_page = alloc_page(sk->sk_allocation);
 		if (!p)
 			return NULL;
 
@@ -2428,7 +2428,7 @@ int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 			return -EFAULT;
 
 		/* allocate a new page for next frag */
-		page = alloc_pages(sk->sk_allocation, 0);
+		page = alloc_page(sk->sk_allocation);
 
 		/* If alloc_page fails just return failure and caller will
 		 * free previous allocated pages by doing kfree_skb()
diff --git a/net/core/sock.c b/net/core/sock.c
index 94c4aff..eb1c1c7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1457,7 +1457,7 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 					struct page *page;
 					skb_frag_t *frag;
 
-					page = alloc_pages(sk->sk_allocation, 0);
+					page = alloc_page(sk->sk_allocation);
 					if (!page) {
 						err = -ENOBUFS;
 						skb_shinfo(skb)->nr_frags = i;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index f039219..501ac6a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1031,7 +1031,7 @@ alloc_new_skb:
 			} else if (i < MAX_SKB_FRAGS) {
 				if (copy > PAGE_SIZE)
 					copy = PAGE_SIZE;
-				page = alloc_pages(sk->sk_allocation, 0);
+				page = alloc_page(sk->sk_allocation);
 				if (page == NULL)  {
 					err = -ENOMEM;
 					goto error;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e7a5f17..84edb23 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1392,7 +1392,7 @@ alloc_new_skb:
 			} else if(i < MAX_SKB_FRAGS) {
 				if (copy > PAGE_SIZE)
 					copy = PAGE_SIZE;
-				page = alloc_pages(sk->sk_allocation, 0);
+				page = alloc_page(sk->sk_allocation);
 				if (page == NULL) {
 					err = -ENOMEM;
 					goto error;


--=-7XKcBlZIYxNNSOHrzAE6--


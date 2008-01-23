From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [INET]: Fix truesize setting in ip_append_data
Date: Wed, 23 Jan 2008 14:39:42 +1100
Message-ID: <20080123033942.GA698@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49059 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752479AbYAWDjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 22:39:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

[INET]: Fix truesize setting in ip_append_data

As it is ip_append_data only counts page fragments to the skb that
allocated it.  As such it means that the first skb gets hit with a
4K charge even though it might have only used a fraction of it while
all subsequent skb's that use the same page gets away with no charge
at all.

This bug was exposed by the UDP accounting patch.

This patch also fixes a similar bug in ip_append_page spotted by you :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index fd99fbd..df1eff1 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1016,7 +1016,6 @@ alloc_new_skb:
 
 				skb_fill_page_desc(skb, i, page, 0, 0);
 				frag = &skb_shinfo(skb)->frags[i];
-				skb->truesize += PAGE_SIZE;
 				atomic_add(PAGE_SIZE, &sk->sk_wmem_alloc);
 			} else {
 				err = -EMSGSIZE;
@@ -1030,6 +1029,7 @@ alloc_new_skb:
 			frag->size += copy;
 			skb->len += copy;
 			skb->data_len += copy;
+			skb->truesize += copy;
 		}
 		offset += copy;
 		length -= copy;
@@ -1172,6 +1172,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 
 		skb->len += len;
 		skb->data_len += len;
+		skb->truesize += len;
 		offset += len;
 		size -= len;
 	}
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6338a9c..bb6ba1e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1316,7 +1316,6 @@ alloc_new_skb:
 
 				skb_fill_page_desc(skb, i, page, 0, 0);
 				frag = &skb_shinfo(skb)->frags[i];
-				skb->truesize += PAGE_SIZE;
 				atomic_add(PAGE_SIZE, &sk->sk_wmem_alloc);
 			} else {
 				err = -EMSGSIZE;
@@ -1330,6 +1329,7 @@ alloc_new_skb:
 			frag->size += copy;
 			skb->len += copy;
 			skb->data_len += copy;
+			skb->truesize += copy;
 		}
 		offset += copy;
 		length -= copy;

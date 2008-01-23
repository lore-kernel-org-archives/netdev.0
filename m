From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [INET]: Fix truesize setting in ip_append_data
Date: Wed, 23 Jan 2008 17:41:31 +1100
Message-ID: <20080123064131.GA2509@gondor.apana.org.au>
References: <20080123033942.GA698@gondor.apana.org.au> <20080122.214719.168781298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39991 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753571AbYAWGld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 01:41:33 -0500
Content-Disposition: inline
In-Reply-To: <20080122.214719.168781298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 22, 2008 at 09:47:19PM -0800, David Miller wrote:
> 
> I already checked in the ip_append_page() fix to net-2.6 so
> I simply removed that hunk when adding your fix.
> 
> Thanks again!

Thank you!

I just received a message from Takahiro Yasui that my bug fix is buggy
too :) So here is a fix on top of that.

[INET]: Change sk_wmem_alloc together with truesize

Whenever truesize gets updated on output we need to update sk_wmem_alloc
too because when the packet gets freed the truesize will be subtracted
from it.  This patch fixes the out-of-place sk_wmem_alloc in ip_append_data
and ip_append_page.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index df1eff1..bc9e575 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1016,7 +1016,6 @@ alloc_new_skb:
 
 				skb_fill_page_desc(skb, i, page, 0, 0);
 				frag = &skb_shinfo(skb)->frags[i];
-				atomic_add(PAGE_SIZE, &sk->sk_wmem_alloc);
 			} else {
 				err = -EMSGSIZE;
 				goto error;
@@ -1030,6 +1029,7 @@ alloc_new_skb:
 			skb->len += copy;
 			skb->data_len += copy;
 			skb->truesize += copy;
+			atomic_add(copy, &sk->sk_wmem_alloc);
 		}
 		offset += copy;
 		length -= copy;
@@ -1173,6 +1173,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 		skb->len += len;
 		skb->data_len += len;
 		skb->truesize += len;
+		atomic_add(len, &sk->sk_wmem_alloc);
 		offset += len;
 		size -= len;
 	}
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index bb6ba1e..3bef30e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1316,7 +1316,6 @@ alloc_new_skb:
 
 				skb_fill_page_desc(skb, i, page, 0, 0);
 				frag = &skb_shinfo(skb)->frags[i];
-				atomic_add(PAGE_SIZE, &sk->sk_wmem_alloc);
 			} else {
 				err = -EMSGSIZE;
 				goto error;
@@ -1330,6 +1329,7 @@ alloc_new_skb:
 			skb->len += copy;
 			skb->data_len += copy;
 			skb->truesize += copy;
+			atomic_add(copy, &sk->sk_wmem_alloc);
 		}
 		offset += copy;
 		length -= copy;

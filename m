From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.9-rc4 tcp_transmit_skb: BUG_ON(!tcp_skb_pcount(skb))
Date: Fri, 15 Oct 2004 16:47:34 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CILsE-0005cJ-00@gondolin.me.apana.org.au>
References: <20041013231006.GA14742@m.safari.iki.fi>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: 7atbggg02@sneakemail.com (Sami Farin), davem@davemloft.net
In-Reply-To: <20041013231006.GA14742@m.safari.iki.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sami Farin <7atbggg02@sneakemail.com> wrote:
> 
> tcp_output.c:277
> Invalid operand 0
> tcp_transmit_skb
> tcp_send_synack
> tcp_rcv_synsent_state_process

OK, this patch should fix it.

We weren't copying the TSO fields in skb_copy().

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/core/skbuff.c 1.38 vs edited =====
--- 1.38/net/core/skbuff.c	2004-09-24 07:39:26 +10:00
+++ edited/net/core/skbuff.c	2004-10-15 16:31:49 +10:00
@@ -394,6 +394,8 @@
 	new->tc_index	= old->tc_index;
 #endif
 	atomic_set(&new->users, 1);
+	skb_shinfo(new)->tso_size = skb_shinfo(old)->tso_size;
+	skb_shinfo(new)->tso_segs = skb_shinfo(old)->tso_segs;
 }
 
 /**
@@ -483,8 +485,6 @@
 		}
 		skb_shinfo(n)->nr_frags = i;
 	}
-	skb_shinfo(n)->tso_size = skb_shinfo(skb)->tso_size;
-	skb_shinfo(n)->tso_segs = skb_shinfo(skb)->tso_segs;
 
 	if (skb_shinfo(skb)->frag_list) {
 		skb_shinfo(n)->frag_list = skb_shinfo(skb)->frag_list;
@@ -631,8 +631,6 @@
 		BUG();
 
 	copy_skb_header(n, skb);
-	skb_shinfo(n)->tso_size = skb_shinfo(skb)->tso_size;
-	skb_shinfo(n)->tso_segs = skb_shinfo(skb)->tso_segs;
 
 	return n;
 }

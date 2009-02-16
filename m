From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Mon, 16 Feb 2009 11:36:44 +0800
Message-ID: <20090216033644.GA14431@gondor.apana.org.au>
References: <20090120101418.13898.57172.stgit@speedy5> <20090121082937.GA1116@gondor.apana.org.au> <49783F7E.6000202@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52019 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755546AbZBPDgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 22:36:52 -0500
Content-Disposition: inline
In-Reply-To: <49783F7E.6000202@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2009 at 01:42:22AM -0800, Divy Le Ray wrote:
>
> I'm now getting about an average 5.7Gbs, oprofile typically showing:
> 
>       37.294500  copy_user_generic_unrolled          vmlinux
>        8.733800  process_responses                  cxgb3.ko
>        6.123700  refill_fl                          cxgb3.ko
>        5.006900  put_page                            vmlinux
>        3.400700  napi_fraginfo_skb                   vmlinux
>        2.484600  tcp_gro_receive                     vmlinux
>        2.308900  inet_gro_receive                    vmlinux
>        2.196000  free_hot_cold_page                  vmlinux
>        2.032900  skb_gro_header                      vmlinux
>        1.970100  get_page_from_freelist              vmlinux
>        1.869700  skb_copy_datagram_iovec             vmlinux
>        1.380300  dev_gro_receive                     vmlinux
>        1.242300  tcp_recvmsg                         vmlinux
>        1.079200  irq_entries_start                   vmlinux
>        1.003900  get_pageblock_flags_group           vmlinux
>        0.991300  skb_gro_receive                     vmlinux
>        0.878400  _raw_spin_lock                      vmlinux
>        0.878400  memcpy                              vmlinux

When you can get a chance can you see if this patch makes any
difference at all?

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d7efaf9..6a542fa 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2586,8 +2586,10 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
 	struct sk_buff *p = *head;
 	struct sk_buff *nskb;
+	skb_frag_t *frag;
 	unsigned int headroom;
 	unsigned int len = skb_gro_len(skb);
+	int i;
 
 	if (p->len + len >= 65536)
 		return -E2BIG;
@@ -2604,9 +2606,9 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		skb_shinfo(skb)->frags[0].size -=
 			skb_gro_offset(skb) - skb_headlen(skb);
 
-		memcpy(skb_shinfo(p)->frags + skb_shinfo(p)->nr_frags,
-		       skb_shinfo(skb)->frags,
-		       skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
+		frag = skb_shinfo(p)->frags + skb_shinfo(p)->nr_frags;
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
+			*frag++ = skb_shinfo(skb)->frags[i];
 
 		skb_shinfo(p)->nr_frags += skb_shinfo(skb)->nr_frags;
 		skb_shinfo(skb)->nr_frags = 0;

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] net: take care of cloned skbs in
 tcp_try_coalesce()
Date: Wed, 02 May 2012 19:55:58 +0200
Message-ID: <1335981358.22133.605.camel@edumazet-glaptop>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	 <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>
	 <1335835677.11396.5.camel@edumazet-glaptop>
	 <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>
	 <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>
	 <1335891892.22133.23.camel@edumazet-glaptop> <4FA06A94.8050704@intel.com>
	 <4FA06D7A.6090800@intel.com>  <1335926862.22133.42.camel@edumazet-glaptop>
	 <1335946384.22133.119.camel@edumazet-glaptop> <4FA15830.6080600@intel.com>
	 <1335975168.22133.578.camel@edumazet-glaptop> <4FA1606A.6040607@intel.com>
	 <1335977179.22133.599.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50225 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755590Ab2EBR4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 13:56:07 -0400
Received: by bkcji2 with SMTP id ji2so697066bkc.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 10:56:04 -0700 (PDT)
In-Reply-To: <1335977179.22133.599.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Before stealing fragments or skb head, we must make sure skbs are not
cloned.

Alexander was worried about destination skb being cloned : In bridge
setups, a driver could be fooled if skb->data_len would not match skb
nr_frags.

If source skb is cloned, we must take references on pages instead.

Bug happened using tcpdump (if not using mmap())

Introduce kfree_skb_partial() helper to cleanup code.

Reported-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c |   42 +++++++++++++++++++++++++++--------------
 1 file changed, 28 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 96a631d..f891a5e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4455,6 +4455,7 @@ static inline int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
  * @sk: socket
  * @to: prior buffer
  * @from: buffer to add in queue
+ * @fragstolen: pointer to boolean
  *
  * Before queueing skb @from after @to, try to merge them
  * to reduce overall memory use and queue lengths, if cost is small.
@@ -4467,10 +4468,10 @@ static bool tcp_try_coalesce(struct sock *sk,
 			     struct sk_buff *from,
 			     bool *fragstolen)
 {
-	int delta, len = from->len;
+	int i, delta, len = from->len;
 
 	*fragstolen = false;
-	if (tcp_hdr(from)->fin)
+	if (tcp_hdr(from)->fin || skb_cloned(to))
 		return false;
 	if (len <= skb_tailroom(to)) {
 		BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
@@ -4497,7 +4498,13 @@ copyfrags:
 		       skb_shinfo(from)->frags,
 		       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
 		skb_shinfo(to)->nr_frags += skb_shinfo(from)->nr_frags;
-		skb_shinfo(from)->nr_frags = 0;
+
+		if (skb_cloned(from))
+			for (i = 0; i < skb_shinfo(from)->nr_frags; i++)
+				skb_frag_ref(from, i);
+		else
+			skb_shinfo(from)->nr_frags = 0;
+
 		to->truesize += delta;
 		atomic_add(delta, &sk->sk_rmem_alloc);
 		sk_mem_charge(sk, delta);
@@ -4515,13 +4522,26 @@ copyfrags:
 		offset = from->data - (unsigned char *)page_address(page);
 		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
 				   page, offset, skb_headlen(from));
-		*fragstolen = true;
+
+		if (skb_cloned(from))
+			get_page(page);
+		else
+			*fragstolen = true;
+
 		delta = len; /* we dont know real truesize... */
 		goto copyfrags;
 	}
 	return false;
 }
 
+static void kfree_skb_partial(struct sk_buff *skb, bool head_stolen)
+{
+	if (head_stolen)
+		kmem_cache_free(skbuff_head_cache, skb);
+	else
+		__kfree_skb(skb);
+}
+
 static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -4565,10 +4585,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 		if (!tcp_try_coalesce(sk, skb1, skb, &fragstolen)) {
 			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
 		} else {
-			if (fragstolen)
-				kmem_cache_free(skbuff_head_cache, skb);
-			else
-				__kfree_skb(skb);
+			kfree_skb_partial(skb, fragstolen);
 			skb = NULL;
 		}
 
@@ -4727,12 +4744,9 @@ queue_and_out:
 
 		tcp_fast_path_check(sk);
 
-		if (eaten > 0) {
-			if (fragstolen)
-				kmem_cache_free(skbuff_head_cache, skb);
-			else
-				__kfree_skb(skb);
-		} else if (!sock_flag(sk, SOCK_DEAD))
+		if (eaten > 0)
+			kfree_skb_partial(skb, fragstolen);
+		else if (!sock_flag(sk, SOCK_DEAD))
 			sk->sk_data_ready(sk, 0);
 		return;
 	}

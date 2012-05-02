From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: take care of cloned skbs in
 tcp_try_coalesce()
Date: Wed, 02 May 2012 10:13:04 +0200
Message-ID: <1335946384.22133.119.camel@edumazet-glaptop>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	 <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>
	 <1335835677.11396.5.camel@edumazet-glaptop>
	 <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>
	 <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>
	 <1335891892.22133.23.camel@edumazet-glaptop> <4FA06A94.8050704@intel.com>
	 <4FA06D7A.6090800@intel.com>  <1335926862.22133.42.camel@edumazet-glaptop>
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
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57958 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492Ab2EBINK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 04:13:10 -0400
Received: by eekc41 with SMTP id c41so78320eek.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 01:13:08 -0700 (PDT)
In-Reply-To: <1335926862.22133.42.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Before stealing fragments or skb head, we must make sure skb is not
cloned.

If skb is cloned, we must take references on pages instead.

Bug happened using tcpdump (if not using mmap())

Reported-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 96a631d..7686d7f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4467,7 +4467,7 @@ static bool tcp_try_coalesce(struct sock *sk,
 			     struct sk_buff *from,
 			     bool *fragstolen)
 {
-	int delta, len = from->len;
+	int i, delta, len = from->len;
 
 	*fragstolen = false;
 	if (tcp_hdr(from)->fin)
@@ -4497,7 +4497,13 @@ copyfrags:
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
@@ -4515,7 +4521,12 @@ copyfrags:
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

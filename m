From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Wed, 02 May 2012 05:54:09 +0200
Message-ID: <1335930849.22133.45.camel@edumazet-glaptop>
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
Received: from mail-wi0-f172.google.com ([209.85.212.172]:47599 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039Ab2EBDyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 23:54:15 -0400
Received: by wibhj6 with SMTP id hj6so4245268wib.1
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 20:54:14 -0700 (PDT)
In-Reply-To: <1335926862.22133.42.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 04:47 +0200, Eric Dumazet wrote:

> Thanks Alex, I'll take a look.
> 
> It seems my tcpdump is different than yours.
> 
> 

I'll test following patch in a couple of hours :

Thanks !

 net/ipv4/tcp_input.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 96a631d..910a794 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4467,7 +4467,8 @@ static bool tcp_try_coalesce(struct sock *sk,
 			     struct sk_buff *from,
 			     bool *fragstolen)
 {
-	int delta, len = from->len;
+	int i, delta, len = from->len;
+	bool fastpath;
 
 	*fragstolen = false;
 	if (tcp_hdr(from)->fin)
@@ -4484,6 +4485,7 @@ merge:
 	if (skb_has_frag_list(to) || skb_has_frag_list(from))
 		return false;
 
+	fastpath = !from->cloned || atomic_read(&skb_shinfo(from)->dataref) == 1;
 	if (skb_headlen(from) == 0 &&
 	    (skb_shinfo(to)->nr_frags +
 	     skb_shinfo(from)->nr_frags <= MAX_SKB_FRAGS)) {
@@ -4497,7 +4499,13 @@ copyfrags:
 		       skb_shinfo(from)->frags,
 		       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
 		skb_shinfo(to)->nr_frags += skb_shinfo(from)->nr_frags;
-		skb_shinfo(from)->nr_frags = 0;
+
+		if (fastpath)
+			skb_shinfo(from)->nr_frags = 0;
+		else
+			for (i = 0; i < skb_shinfo(from)->nr_frags; i++)
+				skb_frag_ref(from, i);
+
 		to->truesize += delta;
 		atomic_add(delta, &sk->sk_rmem_alloc);
 		sk_mem_charge(sk, delta);
@@ -4515,7 +4523,9 @@ copyfrags:
 		offset = from->data - (unsigned char *)page_address(page);
 		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
 				   page, offset, skb_headlen(from));
-		*fragstolen = true;
+		*fragstolen = fastpath;
+		if (!fastpath)
+			get_page(page);
 		delta = len; /* we dont know real truesize... */
 		goto copyfrags;
 	}

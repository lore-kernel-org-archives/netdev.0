From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/3] [NEIGH] Fix add_timer race in neigh_add_timer
Date: Sun, 23 Oct 2005 17:32:15 +1000
Message-ID: <20051023073215.GB17626@gondor.apana.org.au>
References: <43534273.2050106@reub.net> <E1ETaJB-0004a0-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+g7M9IMkV8truYOl"
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, acme@conectiva.com.br, davem@davemloft.net,
	greearb@candelatech.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751428AbVJWHcY@vger.kernel.org>
To: Reuben Farrelly <reuben-lkml@reub.net>
Content-Disposition: inline
In-Reply-To: <E1ETaJB-0004a0-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+g7M9IMkV8truYOl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

[NEIGH] Fix add_timer race in neigh_add_timer

neigh_add_timer cannot use add_timer unconditionally.  The reason is that
by the time it has obtained the write lock someone else (e.g., neigh_update)
could have already added a new timer.

So it should only use mod_timer and deal with its return value accordingly.

This bug would have led to rare neighbour cache entry leaks.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--+g7M9IMkV8truYOl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p2.patch"

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -816,10 +816,10 @@ static void neigh_timer_handler(unsigned
 	}
 
 	if (neigh->nud_state & NUD_IN_TIMER) {
-		neigh_hold(neigh);
 		if (time_before(next, jiffies + HZ/2))
 			next = jiffies + HZ/2;
-		neigh_add_timer(neigh, next);
+		if (!mod_timer(&neigh->timer, next))
+			neigh_hold(neigh);
 	}
 	if (neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) {
 		struct sk_buff *skb = skb_peek(&neigh->arp_queue);

--+g7M9IMkV8truYOl--

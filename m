From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: neigh: guard against NULL solicit() method
Date: Thu, 23 Mar 2017 12:39:21 -0700
Message-ID: <1490297961.9687.6.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+Yb9BvzcRT84EriUCqx6hnz_kciYNHjHNX56y1jDb70vw@mail.gmail.com>
         <CANn89i+_+da3PBYjk-KwcUpa6qr0MdqVXOmrsQUM7_VzgBurnA@mail.gmail.com>
         <1490284858.16816.205.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170323.120035.1924712018254677829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dvyukov@google.com, xiyou.wangcong@gmail.com,
        herbert@gondor.apana.org.au, ast@kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        syzkaller@googlegroups.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34334 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755966AbdCWTjY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 15:39:24 -0400
In-Reply-To: <20170323.120035.1924712018254677829.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Dmitry posted a nice reproducer of a bug triggering in neigh_probe()
when dereferencing a NULL neigh->ops->solicit method.

This can happen for arp_direct_ops/ndisc_direct_ops and similar,
which can be used for NUD_NOARP neighbours (created when dev->header_ops
is NULL). Admin can then force changing nud_state to some other state
that would fire neigh timer.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
---
 net/core/neighbour.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index e7c12caa20c88acc9a5dd86f07d11644fb58341d..4526cbd7e28a1fcdecfc06a41985fd4d19634457 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -860,7 +860,8 @@ static void neigh_probe(struct neighbour *neigh)
 	if (skb)
 		skb = skb_clone(skb, GFP_ATOMIC);
 	write_unlock(&neigh->lock);
-	neigh->ops->solicit(neigh, skb);
+	if (neigh->ops->solicit)
+		neigh->ops->solicit(neigh, skb);
 	atomic_inc(&neigh->probes);
 	kfree_skb(skb);
 }

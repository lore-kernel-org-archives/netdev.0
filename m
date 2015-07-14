From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] net: stop endless flood about dst entry refcount underflow
 or overflow
Date: Tue, 14 Jul 2015 14:43:05 +0300
Message-ID: <20150714114305.17434.53731.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1g.mail.yandex.net ([95.108.253.251]:50189 "EHLO
	forward-corp1g.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751519AbbGNLnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 07:43:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel generates a lot of warnings when dst entry reference counter
overflows and becomes negative. This patch prints address of dst entry,
its refcount and then resets reference counter to INT_MAX/2.

That bug was seen several times at machines with outdated 3.10.y kernels.
Most like it's already fixed in upstream. Anyway flood of that warnings
completely kills machine and makes further debugging impossible.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 net/core/dst.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index e956ce6d1378..2ed91082b3cf 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -284,7 +284,8 @@ void dst_release(struct dst_entry *dst)
 		int newrefcnt;
 
 		newrefcnt = atomic_dec_return(&dst->__refcnt);
-		WARN_ON(newrefcnt < 0);
+		if (WARN(newrefcnt < 0, "dst: %p refcnt: %d\n", dst, newrefcnt))
+			atomic_set(&dst->__refcnt, INT_MAX / 2);
 		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt)
 			call_rcu(&dst->rcu_head, dst_destroy_rcu);
 	}

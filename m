From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH v2] net: ratelimit warnings about dst entry refcount
 underflow or overflow
Date: Fri, 17 Jul 2015 14:01:11 +0300
Message-ID: <20150717110111.16718.77665.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1m.cmail.yandex.net ([5.255.216.100]:42359 "EHLO
	forward-corp1m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757746AbbGQLBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 07:01:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel generates a lot of warnings when dst entry reference counter
overflows and becomes negative. That bug was seen several times at
machines with outdated 3.10.y kernels. Most like it's already fixed
in upstream. Anyway that flood completely kills machine and makes
further debugging impossible.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 net/core/dst.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index e956ce6d1378..002144bea935 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -284,7 +284,9 @@ void dst_release(struct dst_entry *dst)
 		int newrefcnt;
 
 		newrefcnt = atomic_dec_return(&dst->__refcnt);
-		WARN_ON(newrefcnt < 0);
+		if (unlikely(newrefcnt < 0))
+			net_warn_ratelimited("%s: dst:%p refcnt:%d\n",
+					     __func__, dst, newrefcnt);
 		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt)
 			call_rcu(&dst->rcu_head, dst_destroy_rcu);
 	}

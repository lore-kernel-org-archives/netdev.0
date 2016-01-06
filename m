From: fruggeri@aristanetworks.com (Francesco Ruggeri)
Subject: [PATCH 1/1] net: possible use after free in dst_release
Date: Wed, 06 Jan 2016 00:18:48 -0800
Message-ID: <20160106081848.4532F6340189@us105.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: fruggeri@arista.com, edumazet@google.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:2817 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752043AbcAFI2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 03:28:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


dst_release should not access dst->flags after decrementing
__refcnt to 0. The dst_entry may be in dst_busy_list and
dst_gc_task may dst_destroy it before dst_release gets a chance
to access dst->flags.

Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
---
 net/core/dst.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index e6dc772..a1656e3 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -301,12 +301,13 @@ void dst_release(struct dst_entry *dst)
 {
 	if (dst) {
 		int newrefcnt;
+		unsigned short nocache = dst->flags & DST_NOCACHE;
 
 		newrefcnt = atomic_dec_return(&dst->__refcnt);
 		if (unlikely(newrefcnt < 0))
 			net_warn_ratelimited("%s: dst:%p refcnt:%d\n",
 					     __func__, dst, newrefcnt);
-		if (!newrefcnt && unlikely(dst->flags & DST_NOCACHE))
+		if (!newrefcnt && unlikely(nocache))
 			call_rcu(&dst->rcu_head, dst_destroy_rcu);
 	}
 }
-- 
1.8.1.4

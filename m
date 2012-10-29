From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: avoid a test in ip_rt_put()
Date: Mon, 29 Oct 2012 09:33:23 +0100
Message-ID: <1351499603.7394.199.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Cong Wang <amwang@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36673 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756665Ab2J2Id1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 04:33:27 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1941028eek.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 01:33:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We can save a test in ip_rt_put(), considering dst_release() accepts
a NULL parameter, and dst is first element in rtable.

Add a BUILD_BUG_ON() to catch any change that could break this
assertion.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Cong Wang <amwang@redhat.com>
---
 include/net/route.h |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index bc40b63..2ea40c1 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -198,10 +198,13 @@ struct in_ifaddr;
 extern void fib_add_ifaddr(struct in_ifaddr *);
 extern void fib_del_ifaddr(struct in_ifaddr *, struct in_ifaddr *);
 
-static inline void ip_rt_put(struct rtable * rt)
+static inline void ip_rt_put(struct rtable *rt)
 {
-	if (rt)
-		dst_release(&rt->dst);
+	/* dst_release() accepts a NULL parameter.
+	 * We rely on dst being first structure in struct rtable
+	 */
+	BUILD_BUG_ON(offsetof(struct rtable, dst) != 0);
+	dst_release(&rt->dst);
 }
 
 #define IPTOS_RT_MASK	(IPTOS_TOS_MASK & ~3)

From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 9/9] netns: selective flush of rt_cache
Date: Fri,  4 Jul 2008 17:17:12 +0400
Message-ID: <1215177432-25934-9-git-send-email-den@openvz.org>
References: <1215177360.27873.50.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:23272 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754275AbYGDNQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 09:16:52 -0400
In-Reply-To: <1215177360.27873.50.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dst cache is marked as expired on the per/namespace basis by previous
path. Right now we have to implement selective cache shrinking. This
procedure has been ported from older OpenVz codebase.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/route.c |   31 ++++++++++++++++++++++++++++++-
 1 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 67c3ed7..113cd25 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -699,6 +699,7 @@ static void rt_do_flush(int process_context)
 {
 	unsigned int i;
 	struct rtable *rth, *next;
+	struct rtable * tail;
 
 	for (i = 0; i <= rt_hash_mask; i++) {
 		if (process_context && need_resched())
@@ -708,11 +709,39 @@ static void rt_do_flush(int process_context)
 			continue;
 
 		spin_lock_bh(rt_hash_lock_addr(i));
+#ifdef CONFIG_NET_NS
+		{
+		struct rtable ** prev, * p;
+
+		rth = rt_hash_table[i].chain;
+
+		/* defer releasing the head of the list after spin_unlock */
+		for (tail = rth; tail; tail = tail->u.dst.rt_next)
+			if (!rt_is_expired(tail))
+				break;
+		if (rth != tail)
+			rt_hash_table[i].chain = tail;
+
+		/* call rt_free on entries after the tail requiring flush */
+		prev = &rt_hash_table[i].chain;
+		for (p = *prev; p; p = next) {
+			next = p->u.dst.rt_next;
+			if (!rt_is_expired(p)) {
+				prev = &p->u.dst.rt_next;
+			} else {
+				*prev = next;
+				rt_free(p);
+			}
+		}
+		}
+#else
 		rth = rt_hash_table[i].chain;
 		rt_hash_table[i].chain = NULL;
+		tail = NULL;
+#endif
 		spin_unlock_bh(rt_hash_lock_addr(i));
 
-		for (; rth; rth = next) {
+		for (; rth != tail; rth = next) {
 			next = rth->u.dst.rt_next;
 			rt_free(rth);
 		}
-- 
1.5.3.rc5


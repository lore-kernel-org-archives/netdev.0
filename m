From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH v2] net: fix a double free issue for neighbour entry
Date: Wed, 20 May 2015 09:25:13 +0800
Message-ID: <1432085113-25063-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<alexei@purestorage.com>, <joern@purestorage.com>, <ja@ssi.bg>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40281 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbbETBZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 21:25:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling __ipv4_neigh_lookup_noref() inside rcu_read_lock_bh() can
guarantee that its searched neighbour entry is not freed before RCU
grace period, but it cannot ensure that its obtained neighbour will
be freed shortly. Exactly saying, it cannot prevent neigh_destroy()
from being executed on another context at the same time. For example,
if ip_finish_output2() continues to deliver a SKB with a neighbour
entry whose refcount is zero, neigh_add_timer() may be called in
neigh_resolve_output() subsequently. As a result, neigh_add_timer()
takes refcount on the neighbour that already had a refcount of zero.
When the neighbour refcount is put before the timer's handler is
exited, neigh_destroy() will be called again, meaning crash happens
at the moment.

To prevent the issue from occurring, we must check whether the refcount
of a neighbour searched by __ipv4_neigh_lookup_noref() is decremented
to zero or not. If it's zero, we should create a new one.

However, as reading neigh's refcount is unsafe through atomic_read()
like it doesn't imply any memory barrier and the cost is too expensive
if we enforce a proper implicit or explicit memory barrier on it,
another checking of identifying whether neigh's dead flag is set or not
is involved into __neigh_event_send() to further prevent neigh_add_timer()
from holding a neigh's refcount that already hit zero, thereby avoiding
what the issue cannot absolutely happen.

Reported-by: Joern Engel <joern@logfs.org>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 v2:
  - As Eric pointed that identifying whether neigh's refcnt is zero
    through atomic_read() is unsafe, another condition checking of
    verifying neigh's dead flag is set is involved into
    __neigh_event_send() to further prevent neigh_add_timer() from
    holding a neigh's refcnt that already hit zero.
  - Now the patch is created based on "net" tree considering it's
    a very fatal issue.

 net/core/neighbour.c |    3 +++
 net/ipv4/ip_output.c |    2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 3de6542..c7a675c 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -958,6 +958,9 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 	if (neigh->nud_state & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
 		goto out_unlock_bh;
 
+	if (neigh->dead)
+		goto out_unlock_bh;
+
 	if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
 		if (NEIGH_VAR(neigh->parms, MCAST_PROBES) +
 		    NEIGH_VAR(neigh->parms, APP_PROBES)) {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c65b93a..5889774 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -200,7 +200,7 @@ static inline int ip_finish_output2(struct sock *sk, struct sk_buff *skb)
 	rcu_read_lock_bh();
 	nexthop = (__force u32) rt_nexthop(rt, ip_hdr(skb)->daddr);
 	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
-	if (unlikely(!neigh))
+	if (unlikely(!neigh || !atomic_read(&neigh->refcnt)))
 		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
 	if (!IS_ERR(neigh)) {
 		int res = dst_neigh_output(dst, neigh, skb);
-- 
1.7.9.5

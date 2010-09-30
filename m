From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: introduce DST_NOCACHE flag
Date: Thu, 30 Sep 2010 19:44:47 +0200
Message-ID: <1285868687.2615.900.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35280 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755918Ab0I3Row (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 13:44:52 -0400
Received: by fxm14 with SMTP id 14so63443fxm.19
        for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 10:44:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While doing stress tests with IP route cache disabled, and multi queue
devices, I noticed a very high contention on one rwlock used in
neighbour code.

When many cpus are trying to send frames (possibly using a high
performance multiqueue device) to the same neighbour, they fight for the
neigh->lock rwlock in order to call neigh_hh_init(), and fight on
hh->hh_refcnt (a pair of atomic_inc/atomic_dec_and_test())

But we dont need to call neigh_hh_init() for dst that are used only
once. It costs four atomic operations at least, on two contended cache
lines, plus the high contention on neigh->lock rwlock.

Introduce a new dst flag, DST_NOCACHE, that is set when dst was not
inserted in route cache.

With the stress test bench, sending 160000000 frames on one neighbour,
results are :

Before patch:

real	2m28.406s
user	0m11.781s
sys	36m17.964s


After patch:

real	1m26.532s
user	0m12.185s
sys	20m3.903s

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/dst.h    |    9 +++++----
 net/core/neighbour.c |    4 +++-
 net/ipv4/route.c     |    1 +
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index aa53fbc..a217c83 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -43,10 +43,11 @@ struct dst_entry {
 	short			error;
 	short			obsolete;
 	int			flags;
-#define DST_HOST		1
-#define DST_NOXFRM		2
-#define DST_NOPOLICY		4
-#define DST_NOHASH		8
+#define DST_HOST		0x0001
+#define DST_NOXFRM		0x0002
+#define DST_NOPOLICY		0x0004
+#define DST_NOHASH		0x0008
+#define DST_NOCACHE		0x0010
 	unsigned long		expires;
 
 	unsigned short		header_len;	/* more space at head required */
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 96b1a74..b142a0d 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1210,7 +1210,9 @@ int neigh_resolve_output(struct sk_buff *skb)
 	if (!neigh_event_send(neigh, skb)) {
 		int err;
 		struct net_device *dev = neigh->dev;
-		if (dev->header_ops->cache && !dst->hh) {
+		if (dev->header_ops->cache &&
+		    !dst->hh &&
+		    !(dst->flags & DST_NOCACHE)) {
 			write_lock_bh(&neigh->lock);
 			if (!dst->hh)
 				neigh_hh_init(neigh, dst, dst->ops->protocol);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 98beda4..b0c7a87 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1107,6 +1107,7 @@ restart:
 		 * on the route gc list.
 		 */
 
+		rt->dst.flags |= DST_NOCACHE;
 		if (rt->rt_type == RTN_UNICAST || rt->fl.iif == 0) {
 			int err = arp_bind_neighbour(&rt->dst);
 			if (err) {



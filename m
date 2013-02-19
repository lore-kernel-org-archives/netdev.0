From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH] ipv6: Split from and expires field in dst_entry out of union [net-next]
Date: Tue, 19 Feb 2013 15:28:14 -0500
Message-ID: <1361305694-8303-1-git-send-email-nhorman@tuxdriver.com>
References: <1361231718.19353.117.camel@edumazet-glaptop>
Cc: Neil Horman <nhorman@tuxdriver.com>, eric.dumazet@gmail.com,
	David Miller <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>, Jiri Bohac <jbohac@suse.cz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34196 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932279Ab3BSU2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 15:28:39 -0500
In-Reply-To: <1361231718.19353.117.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been looking into some random ipv6 crashes lately that occur around
ip6_link_failure.  This and simmilar partial stack traces:
ip6_link_failure+0xbe/0xd0
ipip6_tunnel_xmit+0x7e7/0x860 [sit]
dev_hard_start_xmit+0x3e3/0x690
dev_queue_xmit+0x38f/0x610
neigh_direct_output+0x11/0x20
ip6_finish_output2+0x90/0x340
? ac6_proc_exit+0x20/0x20
ip6_finish_output+0x98/0xc0
ip6_output
? __ip6_local_out
ip6_local_out
ip6_push_pending
? ip6_append_data
udp_v6_push_pending_frames
udpv6_sendmsg

were all I had.  Eric D. Made this click with me this morning however, noting a
possible/likely race condition in the ipv6 code.  It appears that, if a dst
entry is accessed by multiple cpus (and it appears that certainly can happen, as
routes created via ip6_rt_copy are hashed back into the fib, for future
lookups), then the use of the rt6i_flags field can race, leading to multiple
conflicting uses of the aforementioned union (jiffies being interpreted as the
from pointer and vice versa).

Eric suggested that this be fixed in rt6_update_expires, but looking at the
other uses of this union I don't think thats a complete fix.  All the accessors
for the expired|from union in the dst entry seem to rely on the RTF_EXPIRES flag
being accessed and updated atomically, and thats just not the case.

I think the only fix here, that doesn't involve additional locking, is to
separate the expires and from fields into their own storage, so as not to
trample one another.

This is currently untested, but I've given it to several people who can
reproduce this problem and are testing it now.  I'll post again when I have
results from them.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: eric.dumazet@gmail.com
CC: David Miller <davem@davemloft.net>
CC: Gao feng <gaofeng@cn.fujitsu.com>
CC: Jiri Bohac <jbohac@suse.cz>
---
 include/net/dst.h     |  9 +++------
 include/net/ip6_fib.h | 13 ++++++++-----
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 3da47e0..6b7ebcf 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -36,13 +36,10 @@ struct dst_entry {
 	struct net_device       *dev;
 	struct  dst_ops	        *ops;
 	unsigned long		_metrics;
-	union {
-		unsigned long           expires;
-		/* point to where the dst_entry copied from */
-		struct dst_entry        *from;
-	};
+	unsigned long           expires;
+	/* point to where the dst_entry copied from */
+	struct dst_entry        *from;
 	struct dst_entry	*path;
-	void			*__pad0;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
 #else
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 6919a50..a285e37 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -164,31 +164,33 @@ static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
 
 static inline void rt6_clean_expires(struct rt6_info *rt)
 {
-	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from)
+	if (!rt->rt6i_flags & RTF_EXPIRES)
 		dst_release(rt->dst.from);
 
 	rt->rt6i_flags &= ~RTF_EXPIRES;
 	rt->dst.from = NULL;
+	rt->dst.expires = 0;
 }
 
 static inline void rt6_set_expires(struct rt6_info *rt, unsigned long expires)
 {
-	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from)
+	if (!rt->rt6i_flags & RTF_EXPIRES)
 		dst_release(rt->dst.from);
 
 	rt->rt6i_flags |= RTF_EXPIRES;
+	rt->dst.from = NULL;
 	rt->dst.expires = expires;
 }
 
 static inline void rt6_update_expires(struct rt6_info *rt, int timeout)
 {
 	if (!(rt->rt6i_flags & RTF_EXPIRES)) {
-		if (rt->dst.from)
-			dst_release(rt->dst.from);
+		dst_release(rt->dst.from);
 		/* dst_set_expires relies on expires == 0 
 		 * if it has not been set previously.
 		 */
 		rt->dst.expires = 0;
+		rt6->dst.from = NULL;
 	}
 
 	dst_set_expires(&rt->dst, timeout);
@@ -199,7 +201,7 @@ static inline void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
 {
 	struct dst_entry *new = (struct dst_entry *) from;
 
-	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from) {
+	if (!rt->rt6i_flags & RTF_EXPIRES) {
 		if (new == rt->dst.from)
 			return;
 		dst_release(rt->dst.from);
@@ -207,6 +209,7 @@ static inline void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
 
 	rt->rt6i_flags &= ~RTF_EXPIRES;
 	rt->dst.from = new;
+	rt->dst.expires = 0;
 	dst_hold(new);
 }
 
-- 
1.7.11.7

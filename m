From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: shrink tcp6_timewait_sock by one cache line
Date: Wed, 02 Oct 2013 04:00:04 -0700
Message-ID: <1380711604.19002.78.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:59642 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515Ab3JBLAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 07:00:06 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so715454pbc.21
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 04:00:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While working on tcp listener refactoring, I found that it
would really make things easier if sock_common could include
the IPv6 addresses needed in the lookups, instead of doing
very complex games to get their values (depending on sock
being SYN_RECV, ESTABLISHED, TIME_WAIT)

For this to happen, I need to be sure that tcp6_timewait_sock
and tcp_timewait_sock consume same number of cache lines.

This is possible if we only use 32bits for tw_ttd, as we remove
one 32bit hole in inet_timewait_sock

Before patch : sizeof(struct tcp6_timewait_sock) = 0xc8

After patch : sizeof(struct tcp6_timewait_sock) = 0xc0

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_timewait_sock.h |    2 +-
 net/ipv4/inet_diag.c             |    6 +++---
 net/ipv4/inet_timewait_sock.c    |    4 ++--
 net/ipv4/tcp_ipv4.c              |    2 +-
 net/ipv6/tcp_ipv6.c              |    2 +-
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 828200a..9120f5b 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -132,7 +132,7 @@ struct inet_timewait_sock {
 				tw_tos		: 8,
 				tw_ipv6_offset  : 16;
 	kmemcheck_bitfield_end(flags);
-	unsigned long		tw_ttd;
+	u32			tw_ttd;
 	struct inet_bind_bucket	*tw_tb;
 	struct hlist_node	tw_death_node;
 };
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 5f64875..d17353f 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -222,7 +222,7 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 			       u32 portid, u32 seq, u16 nlmsg_flags,
 			       const struct nlmsghdr *unlh)
 {
-	long tmo;
+	s32 tmo;
 	struct inet_diag_msg *r;
 	struct nlmsghdr *nlh;
 
@@ -234,7 +234,7 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 	r = nlmsg_data(nlh);
 	BUG_ON(tw->tw_state != TCP_TIME_WAIT);
 
-	tmo = tw->tw_ttd - jiffies;
+	tmo = tw->tw_ttd - (u32)jiffies;
 	if (tmo < 0)
 		tmo = 0;
 
@@ -248,7 +248,7 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 	r->id.idiag_dst[0]    = tw->tw_daddr;
 	r->idiag_state	      = tw->tw_substate;
 	r->idiag_timer	      = 3;
-	r->idiag_expires      = DIV_ROUND_UP(tmo * 1000, HZ);
+	r->idiag_expires      = jiffies_to_msecs(tmo);
 	r->idiag_rqueue	      = 0;
 	r->idiag_wqueue	      = 0;
 	r->idiag_uid	      = 0;
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 1f27c9f..2c766b9 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -387,11 +387,11 @@ void inet_twsk_schedule(struct inet_timewait_sock *tw,
 			if (slot >= INET_TWDR_TWKILL_SLOTS)
 				slot = INET_TWDR_TWKILL_SLOTS - 1;
 		}
-		tw->tw_ttd = jiffies + timeo;
+		tw->tw_ttd = (u32)(jiffies + timeo);
 		slot = (twdr->slot + slot) & (INET_TWDR_TWKILL_SLOTS - 1);
 		list = &twdr->cells[slot];
 	} else {
-		tw->tw_ttd = jiffies + (slot << INET_TWDR_RECYCLE_TICK);
+		tw->tw_ttd = (u32)(jiffies + (slot << INET_TWDR_RECYCLE_TICK));
 
 		if (twdr->twcal_hand < 0) {
 			twdr->twcal_hand = 0;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b14266b..959d36f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2688,7 +2688,7 @@ static void get_timewait4_sock(const struct inet_timewait_sock *tw,
 {
 	__be32 dest, src;
 	__u16 destp, srcp;
-	long delta = tw->tw_ttd - jiffies;
+	s32 delta = tw->tw_ttd - (u32)jiffies;
 
 	dest  = tw->tw_daddr;
 	src   = tw->tw_rcv_saddr;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5c71501..845a69e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1811,7 +1811,7 @@ static void get_timewait6_sock(struct seq_file *seq,
 	const struct in6_addr *dest, *src;
 	__u16 destp, srcp;
 	const struct inet6_timewait_sock *tw6 = inet6_twsk((struct sock *)tw);
-	long delta = tw->tw_ttd - jiffies;
+	s32 delta = tw->tw_ttd - (u32)jiffies;
 
 	dest = &tw6->tw_v6_daddr;
 	src  = &tw6->tw_v6_rcv_saddr;

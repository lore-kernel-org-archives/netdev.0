From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] tcp: shrink tcp6_timewait_sock by one cache line
Date: Thu, 03 Oct 2013 14:27:25 -0700
Message-ID: <1380835645.19002.236.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380711604.19002.78.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131003.153158.1558578931500427624.davem@davemloft.net>
	 <1380829642.19002.225.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131003.160252.2071364130742864278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35384 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755212Ab3JCV12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 17:27:28 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so3195440pad.37
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 14:27:27 -0700 (PDT)
In-Reply-To: <20131003.160252.2071364130742864278.davem@davemloft.net>
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

inet_tw_time_stamp() is defined and used, even if its current
implementation looks like tcp_time_stamp : We might need finer
resolution for tcp_time_stamp in the future.

Before patch : sizeof(struct tcp6_timewait_sock) = 0xc8

After patch : sizeof(struct tcp6_timewait_sock) = 0xc0

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: add a inet_tw_time_stamp() helper, per David request.

 include/net/inet_timewait_sock.h |    7 ++++++-
 net/ipv4/inet_diag.c             |    6 +++---
 net/ipv4/inet_timewait_sock.c    |    4 ++--
 net/ipv6/tcp_ipv6.c              |    2 +-
 4 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 48fd356..f528d1b 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -58,6 +58,11 @@ struct inet_hashinfo;
 # define INET_TWDR_RECYCLE_TICK (12 + 2 - INET_TWDR_RECYCLE_SLOTS_LOG)
 #endif
 
+static inline u32 inet_tw_time_stamp(void)
+{
+	return jiffies;
+}
+
 /* TIME_WAIT reaping mechanism. */
 #define INET_TWDR_TWKILL_SLOTS	8 /* Please keep this a power of 2. */
 
@@ -130,7 +135,7 @@ struct inet_timewait_sock {
 				tw_tos		: 8,
 				tw_ipv6_offset  : 16;
 	kmemcheck_bitfield_end(flags);
-	unsigned long		tw_ttd;
+	u32			tw_ttd;
 	struct inet_bind_bucket	*tw_tb;
 	struct hlist_node	tw_death_node;
 };
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 5f64875..2200027 100644
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
+	tmo = tw->tw_ttd - inet_tw_time_stamp();
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
index 1f27c9f..9bcd8f7 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -387,11 +387,11 @@ void inet_twsk_schedule(struct inet_timewait_sock *tw,
 			if (slot >= INET_TWDR_TWKILL_SLOTS)
 				slot = INET_TWDR_TWKILL_SLOTS - 1;
 		}
-		tw->tw_ttd = jiffies + timeo;
+		tw->tw_ttd = inet_tw_time_stamp() + timeo;
 		slot = (twdr->slot + slot) & (INET_TWDR_TWKILL_SLOTS - 1);
 		list = &twdr->cells[slot];
 	} else {
-		tw->tw_ttd = jiffies + (slot << INET_TWDR_RECYCLE_TICK);
+		tw->tw_ttd = inet_tw_time_stamp() + (slot << INET_TWDR_RECYCLE_TICK);
 
 		if (twdr->twcal_hand < 0) {
 			twdr->twcal_hand = 0;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5c71501..dde8bad 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1811,7 +1811,7 @@ static void get_timewait6_sock(struct seq_file *seq,
 	const struct in6_addr *dest, *src;
 	__u16 destp, srcp;
 	const struct inet6_timewait_sock *tw6 = inet6_twsk((struct sock *)tw);
-	long delta = tw->tw_ttd - jiffies;
+	s32 delta = tw->tw_ttd - inet_tw_time_stamp();
 
 	dest = &tw6->tw_v6_daddr;
 	src  = &tw6->tw_v6_rcv_saddr;

From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] Fix build errors on 32bit platforms with new ktime
Date: Tue, 24 Apr 2007 10:04:20 -0700
Message-ID: <20070424100420.2860db68@dxpl.pdx.osdl.net>
References: <20070425.001743.19811068.yoshfuji@linux-ipv6.org>
	<20070424155324.GL3468@stusta.de>
	<20070425.005845.113682267.yoshfuji@linux-ipv6.org>
	<20070425.011028.113320997.yoshfuji@linux-ipv6.org>
	<20070424183827.adb60ae0.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki / ____________ <yoshfuji@linux-ipv6.org>,
	bunk@stusta.de, davem@davemloft.net, netdev@vger.kernel.org,
	tglx@linutronix.de
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:46106 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754301AbXDXRcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 13:32:32 -0400
In-Reply-To: <20070424183827.adb60ae0.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yoshifuji-san had the right idea, but ktime_to_us needs to be defined
in a way that works on both 64 and 32bit platforms.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 include/linux/ktime.h   |   13 +++++++++++++
 net/ipv4/tcp_illinois.c |    2 +-
 net/ipv4/tcp_lp.c       |    2 +-
 net/ipv4/tcp_vegas.c    |    2 +-
 net/ipv4/tcp_veno.c     |    2 +-
 5 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index 248305b..c58683a 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -121,6 +121,8 @@ static inline ktime_t timeval_to_ktime(struct timeval tv)
 /* Convert ktime_t to nanoseconds - NOP in the scalar storage format: */
 #define ktime_to_ns(kt)			((kt).tv64)
 
+#define ktime_to_us(kt)			((kt).tv64 / NSEC_PER_SEC)
+
 #else
 
 /*
@@ -257,6 +259,17 @@ static inline s64 ktime_to_ns(const ktime_t kt)
 	return (s64) kt.tv.sec * NSEC_PER_SEC + kt.tv.nsec;
 }
 
+/**
+ * ktime_to_us - convert a ktime_t variable to scalar microseconds
+ * @kt:		the ktime_t variable to convert
+ *
+ * Returns the scalar nanoseconds representation of @kt
+ */
+static inline s64 ktime_to_us(const ktime_t kt)
+{
+	return (s64) kt.tv_sec * USEC_PER_SEC + kt.tv_nsec / NSEC_PER_USEC;
+}
+
 #endif
 
 /*
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 8e31659..4adc47c 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -90,7 +90,7 @@ static void tcp_illinois_acked(struct sock *sk, u32 pkts_acked, ktime_t last)
 
 	ca->acked = pkts_acked;
 
-	rtt = ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC;
+	rtt = ktime_to_us(net_timedelta(last));
 
 	/* ignore bogus values, this prevents wraparound in alpha math */
 	if (rtt > RTT_MAX)
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index b4e062a..43294ad 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -266,7 +266,7 @@ static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked, ktime_t last)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct lp *lp = inet_csk_ca(sk);
 
-	tcp_lp_rtt_sample(sk,  ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC);
+	tcp_lp_rtt_sample(sk,  ktime_to_us(net_timedelta(last)));
 
 	/* calc inference */
 	if (tcp_time_stamp > tp->rx_opt.rcv_tsecr)
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 0f0ee7f..73e19cf 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -118,7 +118,7 @@ void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
 	u32 vrtt;
 
 	/* Never allow zero rtt or baseRTT */
-	vrtt = (ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC) + 1;
+	vrtt = ktime_to_us(net_timedelta(last)) + 1;
 
 	/* Filter to find propagation delay: */
 	if (vrtt < vegas->baseRTT)
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 0b50d06..9edb340 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -75,7 +75,7 @@ static void tcp_veno_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
 	u32 vrtt;
 
 	/* Never allow zero rtt or baseRTT */
-	vrtt = (ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC) + 1;
+	vrtt = ktime_to_us(net_timedelta(last)) + 1;
 
 	/* Filter to find propagation delay: */
 	if (vrtt < veno->basertt)
-- 
1.5.0.6


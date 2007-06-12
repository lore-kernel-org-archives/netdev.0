From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH net-2.6] [TCP]: Congestion control API RTT sampling fix
Date: Tue, 12 Jun 2007 15:06:57 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0706121500530.15358@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2105245779-1181650017=:15358"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51729 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478AbXFLMHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 08:07:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2105245779-1181650017=:15358
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

I was thinking something like this to fix the cc module breakage 
introduced by the API change (haven't tested it besides compile):


[RFC PATCH net-2.6] [TCP]: Congestion control API RTT sampling fix


Commit 164891aadf1721fca4dce473bb0e0998181537c6 broke RTT
sampling of congestion control modules. Inaccurate timestamps
could be fed to them without providing any way for them to
identify such cases. Previously RTT sampler was called only if
FLAG_RETRANS_DATA_ACKED was not set filtering inaccurate
timestamps nicely. In addition, the new behavior could give an
invalid timestamp (zero) to RTT sampler if only skbs with
TCPCB_RETRANS were ACKed. This solves both problems.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/ktime.h   |   18 ++++++++++++++++++
 include/linux/skbuff.h  |    4 ++++
 net/ipv4/tcp_illinois.c |    3 +++
 net/ipv4/tcp_input.c    |    6 +++++-
 net/ipv4/tcp_lp.c       |    3 ++-
 net/ipv4/tcp_vegas.c    |    3 +++
 net/ipv4/tcp_veno.c     |    3 +++
 7 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index c762954..9f7fa3e 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -102,6 +102,12 @@ static inline ktime_t ktime_set(const long secs, const unsigned long nsecs)
 #define ktime_add_ns(kt, nsval) \
 		({ (ktime_t){ .tv64 = (kt).tv64 + (nsval) }; })
 
+/* Compare two ktime_t variables, returns 1 if equal */
+static inline int ktime_equal(const ktime_t cmp1, const ktime_t cmp2)
+{
+	return cmp1.tv64 == cmp2.tv64;
+}
+
 /* convert a timespec to ktime_t format: */
 static inline ktime_t timespec_to_ktime(struct timespec ts)
 {
@@ -200,6 +206,18 @@ static inline ktime_t ktime_add(const ktime_t add1, const ktime_t add2)
 extern ktime_t ktime_add_ns(const ktime_t kt, u64 nsec);
 
 /**
+ * ktime_equal - Compares two ktime_t variables to see if they are equal
+ * @cmp1:	comparable1
+ * @cmp2:	comparable2
+ *
+ * Compare two ktime_t variables, returns 1 if equal
+ */
+static inline int ktime_equal(const ktime_t cmp1, const ktime_t cmp2)
+{
+	return !((cmp1.tv.sec ^ cmp2.tv.sec) | (cmp1.tv.usec ^ cmp2.tv.usec));
+}
+
+/**
  * timespec_to_ktime - convert a timespec to ktime_t format
  * @ts:		the timespec variable to convert
  *
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e7367c7..6f0b2f7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1579,6 +1579,10 @@ static inline ktime_t net_timedelta(ktime_t t)
 	return ktime_sub(ktime_get_real(), t);
 }
 
+static inline ktime_t net_invalid_timestamp(void)
+{
+	return ktime_set(0, 0);
+}
 
 extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
 extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 4adc47c..5f8d01b 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -90,6 +90,9 @@ static void tcp_illinois_acked(struct sock *sk, u32 pkts_acked, ktime_t last)
 
 	ca->acked = pkts_acked;
 
+	if (ktime_equal(last, net_invalid_timestamp())
+	 	return;
+
 	rtt = ktime_to_us(net_timedelta(last));
 
 	/* ignore bogus values, this prevents wraparound in alpha math */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ed4a1bd..d506bdc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2409,7 +2409,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 	int acked = 0;
 	int prior_packets = tp->packets_out;
 	__s32 seq_rtt = -1;
-	ktime_t last_ackt = ktime_set(0,0);
+	ktime_t last_ackt = net_invalid_timestamp();
 
 	while ((skb = tcp_write_queue_head(sk)) &&
 	       skb != tcp_send_head(sk)) {
@@ -2487,6 +2487,10 @@ static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 		tcp_ack_update_rtt(sk, acked, seq_rtt);
 		tcp_ack_packets_out(sk);
 
+		/* Is the ACK triggering packet unambiguous? */
+		if (acked & FLAG_RETRANS_DATA_ACKED)
+			last_ackt = net_invalid_timestamp();
+
 		if (ca_ops->pkts_acked)
 			ca_ops->pkts_acked(sk, pkts_acked, last_ackt);
 	}
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index 43294ad..efa358b 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -266,7 +266,8 @@ static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked, ktime_t last)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct lp *lp = inet_csk_ca(sk);
 
-	tcp_lp_rtt_sample(sk,  ktime_to_us(net_timedelta(last)));
+	if (!ktime_equal(last, net_invalid_timestamp())
+		tcp_lp_rtt_sample(sk,  ktime_to_us(net_timedelta(last)));
 
 	/* calc inference */
 	if (tcp_time_stamp > tp->rx_opt.rcv_tsecr)
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 73e19cf..bd7a08f 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -117,6 +117,9 @@ void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
 	struct vegas *vegas = inet_csk_ca(sk);
 	u32 vrtt;
 
+	if (ktime_equal(last, net_invalid_timestamp())
+		return;
+
 	/* Never allow zero rtt or baseRTT */
 	vrtt = ktime_to_us(net_timedelta(last)) + 1;
 
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 9edb340..a91c547 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -74,6 +74,9 @@ static void tcp_veno_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
 	struct veno *veno = inet_csk_ca(sk);
 	u32 vrtt;
 
+	if (ktime_equal(last, net_invalid_timestamp())
+		return;
+
 	/* Never allow zero rtt or baseRTT */
 	vrtt = ktime_to_us(net_timedelta(last)) + 1;
 
-- 
1.5.0.6

---696243703-2105245779-1181650017=:15358--

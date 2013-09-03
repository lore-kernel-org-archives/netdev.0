From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/8] net: ipv6: mld: fix v1/v2 switchback timeout to rfc3810, 9.12.
Date: Tue,  3 Sep 2013 09:59:31 +0200
Message-ID: <1378195178-21002-2-git-send-email-dborkman@redhat.com>
References: <1378195178-21002-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932372Ab3ICH7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 03:59:46 -0400
In-Reply-To: <1378195178-21002-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i) RFC3810, 9.2. Query Interval [QI] says:

   The Query Interval variable denotes the interval between General
   Queries sent by the Querier. Default value: 125 seconds. [...]

ii) RFC3810, 9.3. Query Response Interval [QRI] says:

  The Maximum Response Delay used to calculate the Maximum Response
  Code inserted into the periodic General Queries. Default value:
  10000 (10 seconds) [...] The number of seconds represented by the
  [Query Response Interval] must be less than the [Query Interval].

iii) RFC3810, 9.12. Older Version Querier Present Timeout [OVQPT] says:

  The Older Version Querier Present Timeout is the time-out for
  transitioning a host back to MLDv2 Host Compatibility Mode. When an
  MLDv1 query is received, MLDv2 hosts set their Older Version Querier
  Present Timer to [Older Version Querier Present Timeout].

  This value MUST be ([Robustness Variable] times (the [Query Interval]
  in the last Query received)) plus ([Query Response Interval]).

Hence, on *default* the timeout results in:

  [RV] = 2, [QI] = 125sec, [QRI] = 10sec
  [OVQPT] = [RV] * [QI] + [QRI] = 260sec

Having that said, we currently calculate [OVQPT] (here given as 'switchback'
variable) as ...

  switchback = (idev->mc_qrv + 1) * max_delay

RFC3810, 9.12. says "the [Query Interval] in the last Query received". In
section "9.14. Configuring timers", it is said:

  This section is meant to provide advice to network administrators on
  how to tune these settings to their network. Ambitious router
  implementations might tune these settings dynamically based upon
  changing characteristics of the network. [...]

iv) RFC38010, 9.14.2. Query Interval:

  The overall level of periodic MLD traffic is inversely proportional
  to the Query Interval. A longer Query Interval results in a lower
  overall level of MLD traffic. The value of the Query Interval MUST
  be equal to or greater than the Maximum Response Delay used to
  calculate the Maximum Response Code inserted in General Query
  messages.

I assume that was why switchback is calculated as is (3 * max_delay), although
this setting seems to be meant for routers only to configure their [QI]
interval for non-default intervals. So usage here like this is clearly wrong.

Concluding, the current behaviour in IPv6's multicast code is not conform
to the RFC as switch back is calculated wrongly. That is, it has a too small
value, so MLDv2 hosts switch back again to MLDv2 way too early, i.e. ~30secs
instead of ~260secs on default.

Hence, introduce necessary helper functions and fix this up properly as it
should be.

Introduced in 06da92283 ("[IPV6]: Add MLDv2 support."). Credits to Hannes
Frederic Sowa who also had a hand in this as well. Also thanks to Hangbin Liu
who did initial testing.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: David Stevens <dlstevens@us.ibm.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 06da92283 is linux-history tree.

 include/net/if_inet6.h |   9 +++-
 include/net/mld.h      |  27 +++++++++++-
 net/ipv6/mcast.c       | 116 ++++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 143 insertions(+), 9 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 736b5fb..02ef772 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -171,12 +171,17 @@ struct inet6_dev {
 	struct ifmcaddr6	*mc_list;
 	struct ifmcaddr6	*mc_tomb;
 	spinlock_t		mc_lock;
-	unsigned char		mc_qrv;
+
+	unsigned char		mc_qrv;		/* Query Robustness Variable */
 	unsigned char		mc_gq_running;
 	unsigned char		mc_ifc_count;
 	unsigned char		mc_dad_count;
-	unsigned long		mc_v1_seen;
+
+	unsigned long		mc_v1_seen;	/* Max time we stay in MLDv1 mode */
+	unsigned long		mc_qi;		/* Query Interval */
+	unsigned long		mc_qri;		/* Query Response Interval */
 	unsigned long		mc_maxdelay;
+
 	struct timer_list	mc_gq_timer;	/* general query timer */
 	struct timer_list	mc_ifc_timer;	/* interface change timer */
 	struct timer_list	mc_dad_timer;	/* dad complete mc timer */
diff --git a/include/net/mld.h b/include/net/mld.h
index 467143c..2b5421f 100644
--- a/include/net/mld.h
+++ b/include/net/mld.h
@@ -63,7 +63,7 @@ struct mld2_query {
 #define mld2q_mrc		mld2q_hdr.icmp6_maxdelay
 #define mld2q_resv1		mld2q_hdr.icmp6_dataun.un_data16[1]
 
-/* Max Response Code */
+/* Max Response Code, TODO: transform this to use the below */
 #define MLDV2_MASK(value, nb) ((nb)>=32 ? (value) : ((1<<(nb))-1) & (value))
 #define MLDV2_EXP(thresh, nbmant, nbexp, value) \
 	((value) < (thresh) ? (value) : \
@@ -72,4 +72,29 @@ struct mld2_query {
 
 #define MLDV2_MRC(value) MLDV2_EXP(0x8000, 12, 3, value)
 
+/* RFC3810, 5.1.3. Maximum Response Code:
+ *
+ * If Maximum Response Code >= 32768, Maximum Response Code represents a
+ * floating-point value as follows:
+ *
+ *  0 1 2 3 4 5 6 7 8 9 A B C D E F
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |1| exp |          mant         |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ */
+#define MLDV2_MRC_EXP(value)	(((value) >> 12) & 0x0007)
+#define MLDV2_MRC_MAN(value)	((value) & 0x0fff)
+
+/* RFC3810, 5.1.9. QQIC (Querier's Query Interval Code):
+ *
+ * If QQIC >= 128, QQIC represents a floating-point value as follows:
+ *
+ *  0 1 2 3 4 5 6 7
+ * +-+-+-+-+-+-+-+-+
+ * |1| exp | mant  |
+ * +-+-+-+-+-+-+-+-+
+ */
+#define MLDV2_QQIC_EXP(value)	(((value) >> 4) & 0x07)
+#define MLDV2_QQIC_MAN(value)	((value) & 0x0f)
+
 #endif
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 98ead2b..8992ff2 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -108,6 +108,10 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 			    struct inet6_dev *idev);
 
 #define MLD_QRV_DEFAULT		2
+/* RFC3810, 9.2. Query Interval */
+#define MLD_QI_DEFAULT		(125 * HZ)
+/* RFC3810, 9.3. Query Response Interval */
+#define MLD_QRI_DEFAULT		(10 * HZ)
 
 /* RFC3810, 8.1 Query Version Distinctions */
 #define MLD_V1_QUERY_LEN	24
@@ -1112,6 +1116,93 @@ static bool mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
 	return true;
 }
 
+static void mld_set_v1_mode(struct inet6_dev *idev)
+{
+	/* RFC3810, relevant sections:
+	 *  - 9.1. Robustness Variable
+	 *  - 9.2. Query Interval
+	 *  - 9.3. Query Response Interval
+	 *  - 9.12. Older Version Querier Present Timeout
+	 */
+	unsigned long switchback;
+
+	switchback = (idev->mc_qrv * idev->mc_qi) + idev->mc_qri;
+
+	idev->mc_v1_seen = jiffies + switchback;
+}
+
+static void mld_update_qrv(struct inet6_dev *idev,
+			   const struct mld2_query *mlh2)
+{
+	/* RFC3810, relevant sections:
+	 *  - 5.1.8. QRV (Querier's Robustness Variable)
+	 *  - 9.1. Robustness Variable
+	 */
+
+	/* The value of the Robustness Variable MUST NOT be zero,
+	 * and SHOULD NOT be one. Catch this here if we ever run
+	 * into such a case in future.
+	 */
+	WARN_ON(idev->mc_qrv == 0);
+
+	if (mlh2->mld2q_qrv > 0)
+		idev->mc_qrv = mlh2->mld2q_qrv;
+
+	if (unlikely(idev->mc_qrv < 2)) {
+		net_warn_ratelimited("IPv6: MLD: clamping QRV from %u to %u!\n",
+				     idev->mc_qrv, MLD_QRV_DEFAULT);
+		idev->mc_qrv = MLD_QRV_DEFAULT;
+	}
+}
+
+static void mld_update_qi(struct inet6_dev *idev,
+			  const struct mld2_query *mlh2)
+{
+	/* RFC3810, relevant sections:
+	 *  - 5.1.9. QQIC (Querier's Query Interval Code)
+	 *  - 9.2. Query Interval
+	 *  - 9.12. Older Version Querier Present Timeout
+	 *    (the [Query Interval] in the last Query received)
+	 */
+	unsigned long mc_qqi;
+
+	if (mlh2->mld2q_qqic < 128) {
+		mc_qqi = mlh2->mld2q_qqic;
+	} else {
+		unsigned long mc_man, mc_exp;
+
+		mc_exp = MLDV2_QQIC_EXP(mlh2->mld2q_qqic);
+		mc_man = MLDV2_QQIC_MAN(mlh2->mld2q_qqic);
+
+		mc_qqi = (mc_man | 0x10) << (mc_exp + 3);
+	}
+
+	idev->mc_qi = mc_qqi * HZ;
+}
+
+static void mld_update_qri(struct inet6_dev *idev,
+			   const struct mld2_query *mlh2)
+{
+	/* RFC3810, relevant sections:
+	 *  - 5.1.3. Maximum Response Code
+	 *  - 9.3. Query Response Interval
+	 */
+	unsigned long mc_qri, mc_mrc = ntohs(mlh2->mld2q_mrc);
+
+	if (mc_mrc < 32768) {
+		mc_qri = mc_mrc;
+	} else {
+		unsigned long mc_man, mc_exp;
+
+		mc_exp = MLDV2_MRC_EXP(mc_mrc);
+		mc_man = MLDV2_MRC_MAN(mc_mrc);
+
+		mc_qri = (mc_man | 0x1000) << (mc_exp + 3);
+	}
+
+	idev->mc_qri = msecs_to_jiffies(mc_qri);
+}
+
 /* called with rcu_read_lock() */
 int igmp6_event_query(struct sk_buff *skb)
 {
@@ -1150,12 +1241,15 @@ int igmp6_event_query(struct sk_buff *skb)
 		return -EINVAL;
 
 	if (len == MLD_V1_QUERY_LEN) {
-		int switchback;
 		/* MLDv1 router present */
-
 		max_delay = msecs_to_jiffies(ntohs(mld->mld_maxdelay));
-		switchback = (idev->mc_qrv + 1) * max_delay;
-		idev->mc_v1_seen = jiffies + switchback;
+
+		mld_set_v1_mode(idev);
+
+		/* cancel MLDv2 report timer */
+		idev->mc_gq_running = 0;
+		if (del_timer(&idev->mc_gq_timer))
+			__in6_dev_put(idev);
 
 		/* cancel the interface change timer */
 		idev->mc_ifc_count = 0;
@@ -1166,6 +1260,10 @@ int igmp6_event_query(struct sk_buff *skb)
 	} else if (len >= MLD_V2_QUERY_LEN_MIN) {
 		int srcs_offset = sizeof(struct mld2_query) -
 				  sizeof(struct icmp6hdr);
+
+		/* hosts need to stay in MLDv1 mode, discard MLDv2 queries */
+		if (MLD_V1_SEEN(idev))
+			return 0;
 		if (!pskb_may_pull(skb, srcs_offset))
 			return -EINVAL;
 
@@ -1175,8 +1273,10 @@ int igmp6_event_query(struct sk_buff *skb)
 
 		idev->mc_maxdelay = max_delay;
 
-		if (mlh2->mld2q_qrv)
-			idev->mc_qrv = mlh2->mld2q_qrv;
+		mld_update_qrv(idev, mlh2);
+		mld_update_qi(idev, mlh2);
+		mld_update_qri(idev, mlh2);
+
 		if (group_type == IPV6_ADDR_ANY) { /* general query */
 			if (mlh2->mld2q_nsrcs)
 				return -EINVAL; /* no sources allowed */
@@ -2337,7 +2437,11 @@ void ipv6_mc_init_dev(struct inet6_dev *idev)
 			(unsigned long)idev);
 	setup_timer(&idev->mc_dad_timer, mld_dad_timer_expire,
 		    (unsigned long)idev);
+
 	idev->mc_qrv = MLD_QRV_DEFAULT;
+	idev->mc_qi = MLD_QI_DEFAULT;
+	idev->mc_qri = MLD_QRI_DEFAULT;
+
 	idev->mc_maxdelay = unsolicited_report_interval(idev);
 	idev->mc_v1_seen = 0;
 	write_unlock_bh(&idev->lock);
-- 
1.7.11.7

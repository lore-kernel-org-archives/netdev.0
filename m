From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH net-next-2.6 v4 1/2] net_sched: add size table functions
Date: Thu, 10 Jul 2008 22:34:35 +0300
Message-ID: <20080710193434.19525.83454.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:43474 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144AbYGJTeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 15:34:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch adds size table that is similiar to rate table, with difference that
size table stores link layer packet size. It's needed for HFSC link
layer adaption patch as it converts skb->len to link layer packet size
directly, unlike HTB/CFQ/etc that convert packet length to link layer
transfer time using rate tables.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/linux/pkt_sched.h |   10 ++++++++++
 include/net/pkt_sched.h   |   11 +++++++++++
 include/net/sch_generic.h |   23 ++++++++++++++++++++++
 net/sched/sch_api.c       |   47 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbb7ac3..5bf1444 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -85,6 +85,16 @@ struct tc_ratespec
 
 #define TC_RTAB_SIZE	1024
 
+struct tc_sizespec {
+	unsigned char	cell_log;
+	unsigned char	size_log;
+	short		overhead;
+	short		cell_align;
+	unsigned short	mpu;
+};
+
+#define TC_STAB_SIZE	1024
+
 /* FIFO section */
 
 struct tc_fifo_qopt
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index d58c1a5..90e1826 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -82,7 +82,18 @@ extern struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
 extern struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
 extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
 		struct nlattr *tab);
+extern struct qdisc_size_table *__qdisc_get_stab(struct tc_sizespec *s,
+		void *tab, unsigned int tablen);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
+extern void qdisc_put_stab(struct qdisc_size_table *tab);
+
+static inline struct qdisc_size_table *qdisc_get_stab(struct tc_sizespec *s,
+						      struct nlattr *tab)
+{
+	if (tab == NULL)
+		return NULL;
+	return __qdisc_get_stab(s, nla_data(tab), nla_len(tab));
+}
 
 extern void __qdisc_run(struct netdev_queue *txq);
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 5ba66b5..db54abe 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -23,6 +23,13 @@ struct qdisc_rate_table
 	int		refcnt;
 };
 
+struct qdisc_size_table {
+	struct tc_sizespec szopts;
+	u16		data[512];
+	struct qdisc_size_table *next;
+	int		refcnt;
+};
+
 struct Qdisc
 {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
@@ -394,6 +401,22 @@ static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned int pktlen)
 	return rtab->data[slot];
 }
 
+/* Length to link layer size lookup in a qdisc_size_table, to determine how
+   what size packet takes on link layer.
+ */
+static inline u32 qdisc_linklayer_sz(struct qdisc_size_table *stab, u32 pktlen)
+{
+	int slot = pktlen + stab->szopts.cell_align + stab->szopts.overhead;
+	unsigned char size_log = stab->szopts.size_log;
+	if (unlikely(slot < 0))
+		slot = 0;
+	slot >>= stab->szopts.cell_log;
+	if (unlikely(slot > 511))
+		return ((u32)stab->data[511] << size_log) * (slot >> 9) +
+			((u32)stab->data[slot & 0x1FF] << size_log);
+	return (u32)stab->data[slot] << size_log;
+}
+
 #ifdef CONFIG_NET_CLS_ACT
 static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask)
 {
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 95873f8..aea3473 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -278,6 +278,53 @@ void qdisc_put_rtab(struct qdisc_rate_table *tab)
 }
 EXPORT_SYMBOL(qdisc_put_rtab);
 
+static struct qdisc_size_table *qdisc_stab_list;
+
+struct qdisc_size_table *__qdisc_get_stab(struct tc_sizespec *s,
+					void *tab, unsigned int tablen)
+{
+	struct qdisc_size_table *stab;
+
+	for (stab = qdisc_stab_list; stab; stab = stab->next) {
+		if (memcmp(&stab->szopts, s, sizeof(struct tc_sizespec)) == 0) {
+			stab->refcnt++;
+			return stab;
+		}
+	}
+
+	if (tab == NULL || tablen != TC_STAB_SIZE)
+		return NULL;
+
+	stab = kmalloc(sizeof(*stab), GFP_KERNEL);
+	if (stab) {
+		stab->szopts = *s;
+		stab->refcnt = 1;
+		memcpy(stab->data, tab, TC_STAB_SIZE);
+		stab->next = qdisc_stab_list;
+		qdisc_stab_list = stab;
+	}
+	return stab;
+}
+EXPORT_SYMBOL(__qdisc_get_stab);
+
+void qdisc_put_stab(struct qdisc_size_table *tab)
+{
+	struct qdisc_size_table *stab, **stabp;
+
+	if (!tab || --tab->refcnt)
+		return;
+
+	for (stabp = &qdisc_stab_list; (stab = *stabp) != NULL;
+							stabp = &stab->next) {
+		if (stab == tab) {
+			*stabp = stab->next;
+			kfree(stab);
+			return;
+		}
+	}
+}
+EXPORT_SYMBOL(qdisc_put_stab);
+
 static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 {
 	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,


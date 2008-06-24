From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH v2 1/2] net_sched: add size table functions
Date: Tue, 24 Jun 2008 11:54:59 +0300
Message-ID: <20080624085459.22411.51103.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:36360 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756158AbYFXIzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 04:55:03 -0400
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
 include/net/pkt_sched.h   |    3 +++
 include/net/sch_generic.h |   23 ++++++++++++++++++++++
 net/sched/sch_api.c       |   47 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 83 insertions(+), 0 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbb7ac3..b8366fb 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -85,6 +85,16 @@ struct tc_ratespec
 
 #define TC_RTAB_SIZE	1024
 
+struct tc_sizespec {
+	unsigned char	cell_log;
+	unsigned char	size_log;
+	unsigned short	overhead;
+	short		cell_align;
+	unsigned short	mpu;
+};
+
+#define TC_STAB_SIZE	1024
+
 /* FIFO section */
 
 struct tc_fifo_qopt
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 46fb4d8..b032488 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -78,7 +78,10 @@ extern struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
 extern struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
 extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
 		struct nlattr *tab);
+extern struct qdisc_size_table *qdisc_get_stab(struct tc_sizespec *s,
+		struct nlattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
+extern void qdisc_put_stab(struct qdisc_size_table *tab);
 
 extern void __qdisc_run(struct net_device *dev);
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index ab502ec..32b6865 100644
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
@@ -316,6 +323,22 @@ static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned int pktlen)
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
index c40773c..de25928 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -277,6 +277,53 @@ void qdisc_put_rtab(struct qdisc_rate_table *tab)
 }
 EXPORT_SYMBOL(qdisc_put_rtab);
 
+static struct qdisc_size_table *qdisc_stab_list;
+
+struct qdisc_size_table *qdisc_get_stab(struct tc_sizespec *s,
+					struct nlattr *tab)
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
+	if (tab == NULL || s->cell_log == 0 || nla_len(tab) != TC_STAB_SIZE)
+		return NULL;
+
+	stab = kmalloc(sizeof(*stab), GFP_KERNEL);
+	if (stab) {
+		stab->szopts = *s;
+		stab->refcnt = 1;
+		memcpy(stab->data, nla_data(tab), TC_STAB_SIZE);
+		stab->next = qdisc_stab_list;
+		qdisc_stab_list = stab;
+	}
+	return stab;
+}
+EXPORT_SYMBOL(qdisc_get_stab);
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


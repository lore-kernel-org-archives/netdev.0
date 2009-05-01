From: Robert Love <robert.w.love@intel.com>
Subject: [RFC PATCH] qos: Limit a filter's priority to a 16 bit value
Date: Fri, 01 May 2009 11:42:42 -0700
Message-ID: <20090501184242.12714.2663.stgit@fritz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, robert.w.love@intel.com,
	jeffrey.t.kirsher@intel.com
To: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11244 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753395AbZEASmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2009 14:42:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the kernel is storing the priority value for
a filter as a 32 bit value. However, the netlink messages
between the kernel and userspace are passing only 16 bits
for the priority. This means that the kernel will always
try to compare the passed down filter's priority using the
correct upper 16 bits, but all 0s for the lower 16 bits.

Most comparisons will fail when checking against the filter
chain unless the actual filter has a priority with all 0s
for the last 16 bits.

The fallout is that users cannot modify or delete most
filters that are added.

This patch makes it so the kernel only uses 16 bits for
a filter's priority. It has no impact on the kernel/user
interaction, but does reduce the number of potential filters.

I sent this as an RFC becuase I'm not sure if the correct
fix is to switch the kernel's priority value to 32 bits or
to change the netlink messages to pass 32bit priorities.

I implemented the change to 16bit approach becuase I didn't
want to change kernel/user messages, I think that changing
this API may be undesirable. Also 16 bits still allows 65535
filter priorities, which to me seems like enough, but I may
not understand all usages of the filters.

Signed-off-by: Robert Love <robert.w.love@intel.com>
---

 include/net/sch_generic.h |    2 +-
 net/sched/cls_api.c       |   16 ++++++++--------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 964ffa0..2a03027 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -170,7 +170,7 @@ struct tcf_proto
 	__be16			protocol;
 
 	/* All the rest */
-	u32			prio;
+	u16			prio;
 	u32			classid;
 	struct Qdisc		*q;
 	void			*data;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 173fcc4..b754c22 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -104,9 +104,9 @@ static int tfilter_notify(struct sk_buff *oskb, struct nlmsghdr *n,
 
 /* Select new prio value from the range, managed by kernel. */
 
-static inline u32 tcf_auto_prio(struct tcf_proto *tp)
+static inline u16 tcf_auto_prio(struct tcf_proto *tp)
 {
-	u32 first = TC_H_MAKE(0xC0000000U, 0U);
+	u16 first = 0xC000U;
 
 	if (tp)
 		first = tp->prio-1;
@@ -123,8 +123,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	spinlock_t *root_lock;
 	struct tcmsg *t;
 	u32 protocol;
-	u32 prio;
-	u32 nprio;
+	u16 prio;
+	u16 nprio;
 	u32 parent;
 	struct net_device *dev;
 	struct Qdisc  *q;
@@ -142,7 +142,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 replay:
 	t = NLMSG_DATA(n);
 	protocol = TC_H_MIN(t->tcm_info);
-	prio = TC_H_MAJ(t->tcm_info);
+	prio = TC_H_MAJ(t->tcm_info) >> 16;
 	nprio = prio;
 	parent = t->tcm_parent;
 	cl = 0;
@@ -151,7 +151,7 @@ replay:
 		/* If no priority is given, user wants we allocated it. */
 		if (n->nlmsg_type != RTM_NEWTFILTER || !(n->nlmsg_flags&NLM_F_CREATE))
 			return -ENOENT;
-		prio = TC_H_MAKE(0x80000000U, 0U);
+		prio = 0x8000U;
 	}
 
 	/* Find head of filter chain. */
@@ -340,7 +340,7 @@ static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
 	tcm->tcm__pad1 = 0;
 	tcm->tcm_ifindex = qdisc_dev(tp->q)->ifindex;
 	tcm->tcm_parent = tp->classid;
-	tcm->tcm_info = TC_H_MAKE(tp->prio, tp->protocol);
+	tcm->tcm_info = TC_H_MAKE((u32)tp->prio << 16, tp->protocol);
 	NLA_PUT_STRING(skb, TCA_KIND, tp->ops->kind);
 	tcm->tcm_handle = fh;
 	if (RTM_DELTFILTER != event) {
@@ -436,7 +436,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	for (tp=*chain, t=0; tp; tp = tp->next, t++) {
 		if (t < s_t) continue;
 		if (TC_H_MAJ(tcm->tcm_info) &&
-		    TC_H_MAJ(tcm->tcm_info) != tp->prio)
+		    (TC_H_MAJ(tcm->tcm_info) >> 16) != tp->prio)
 			continue;
 		if (TC_H_MIN(tcm->tcm_info) &&
 		    TC_H_MIN(tcm->tcm_info) != tp->protocol)


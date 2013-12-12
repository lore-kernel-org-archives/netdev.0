From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net-next 3/6] mirred: remove action when the target device is gone
Date: Wed, 11 Dec 2013 22:30:30 -0800
Message-ID: <1386829833-4219-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1386829833-4219-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:57161 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452Ab3LLGau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 01:30:50 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so10935099pdi.24
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 22:30:49 -0800 (PST)
In-Reply-To: <1386829833-4219-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the target device is removed, the mirred action is
still there but with the pointer setting to NULL.
This will get ugly output from 'tc filter'. There is no
reason to keep it.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/tc_act/tc_mirred.h |  4 +++-
 net/sched/act_mirred.c         | 15 +++++++--------
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index cfe2943..2026cf6 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -7,9 +7,11 @@ struct tcf_mirred {
 	struct tcf_common	common;
 	int			tcfm_eaction;
 	int			tcfm_ifindex;
-	int			tcfm_ok_push;
+	unsigned int		tcfm_ok_push:1;
+	unsigned int		tcfm_bind:1;
 	struct net_device	*tcfm_dev;
 	struct list_head	tcfm_list;
+	struct tc_action	*tcfm_act;
 };
 #define to_mirred(pc) \
 	container_of(pc, struct tcf_mirred, common)
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 2523781..c26bfe5 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -136,6 +136,8 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		dev_hold(dev);
 		m->tcfm_dev = dev;
 		m->tcfm_ok_push = ok_push;
+		m->tcfm_bind = bind;
+		m->tcfm_act = a;
 	}
 	spin_unlock_bh(&m->tcf_lock);
 	if (ret == ACT_P_CREATED) {
@@ -169,10 +171,6 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	bstats_update(&m->tcf_bstats, skb);
 
 	dev = m->tcfm_dev;
-	if (!dev) {
-		printk_once(KERN_NOTICE "tc mirred: target device is gone\n");
-		goto out;
-	}
 
 	if (!(dev->flags & IFF_UP)) {
 		net_notice_ratelimited("tc mirred to Houston: device %s is down\n",
@@ -244,13 +242,14 @@ static int mirred_device_event(struct notifier_block *unused,
 			       unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct tcf_mirred *m;
+	struct tcf_mirred *m, *tmp;
 
 	if (event == NETDEV_UNREGISTER)
-		list_for_each_entry(m, &mirred_list, tcfm_list) {
+		list_for_each_entry_safe(m, tmp, &mirred_list, tcfm_list) {
 			if (m->tcfm_dev == dev) {
-				dev_put(dev);
-				m->tcfm_dev = NULL;
+				list_del(&m->tcfm_act->list);
+				tcf_mirred_cleanup(m->tcfm_act, m->tcfm_bind);
+				kfree(m->tcfm_act);
 			}
 		}
 
-- 
1.8.1.4

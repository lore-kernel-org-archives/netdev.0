From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Add BH protection for qdisc_stab_lock.
Date: Mon, 11 Aug 2008 23:42:39 +0200
Message-ID: <20080811214239.GB15293@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:19326 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316AbYHKVlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 17:41:53 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1136475fgg.17
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 14:41:50 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pkt_sched: Add BH protection for qdisc_stab_lock.

Since qdisc_stab_lock is used in qdisc_put_stab(), which is called in
BH context from __qdisc_destroy() RCU callback, softirq safe locking
is needed.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_api.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index bbf149d..c25465e 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -331,7 +331,7 @@ static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt)
 	if (!s || tsize != s->tsize || (!tab && tsize > 0))
 		return ERR_PTR(-EINVAL);
 
-	spin_lock(&qdisc_stab_lock);
+	spin_lock_bh(&qdisc_stab_lock);
 
 	list_for_each_entry(stab, &qdisc_stab_list, list) {
 		if (memcmp(&stab->szopts, s, sizeof(*s)))
@@ -339,11 +339,11 @@ static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt)
 		if (tsize > 0 && memcmp(stab->data, tab, tsize * sizeof(u16)))
 			continue;
 		stab->refcnt++;
-		spin_unlock(&qdisc_stab_lock);
+		spin_unlock_bh(&qdisc_stab_lock);
 		return stab;
 	}
 
-	spin_unlock(&qdisc_stab_lock);
+	spin_unlock_bh(&qdisc_stab_lock);
 
 	stab = kmalloc(sizeof(*stab) + tsize * sizeof(u16), GFP_KERNEL);
 	if (!stab)
@@ -354,9 +354,9 @@ static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt)
 	if (tsize > 0)
 		memcpy(stab->data, tab, tsize * sizeof(u16));
 
-	spin_lock(&qdisc_stab_lock);
+	spin_lock_bh(&qdisc_stab_lock);
 	list_add_tail(&stab->list, &qdisc_stab_list);
-	spin_unlock(&qdisc_stab_lock);
+	spin_unlock_bh(&qdisc_stab_lock);
 
 	return stab;
 }
@@ -366,14 +366,14 @@ void qdisc_put_stab(struct qdisc_size_table *tab)
 	if (!tab)
 		return;
 
-	spin_lock(&qdisc_stab_lock);
+	spin_lock_bh(&qdisc_stab_lock);
 
 	if (--tab->refcnt == 0) {
 		list_del(&tab->list);
 		kfree(tab);
 	}
 
-	spin_unlock(&qdisc_stab_lock);
+	spin_unlock_bh(&qdisc_stab_lock);
 }
 EXPORT_SYMBOL(qdisc_put_stab);
 

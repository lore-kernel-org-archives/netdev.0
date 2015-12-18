From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 14/14] net: pktgen: use list_for_each_entry_safe
Date: Fri, 18 Dec 2015 23:33:38 +0800
Message-ID: <7ed820c5b80db617d6f29aa8fe5ae00e899a83b2.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use list_for_each_entry_safe() instead of list_for_each_safe() to
simplify the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/core/pktgen.c | 26 ++++++++------------------
 1 file changed, 8 insertions(+), 18 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2be1444..1d8cffb 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3293,14 +3293,11 @@ static void pktgen_stop(struct pktgen_thread *t)
  */
 static void pktgen_rem_one_if(struct pktgen_thread *t)
 {
-	struct list_head *q, *n;
-	struct pktgen_dev *cur;
+	struct pktgen_dev *cur, *n;
 
 	func_enter();
 
-	list_for_each_safe(q, n, &t->if_list) {
-		cur = list_entry(q, struct pktgen_dev, list);
-
+	list_for_each_entry_safe(cur, n, &t->if_list, list) {
 		if (!cur->removal_mark)
 			continue;
 
@@ -3315,16 +3312,13 @@ static void pktgen_rem_one_if(struct pktgen_thread *t)
 
 static void pktgen_rem_all_ifs(struct pktgen_thread *t)
 {
-	struct list_head *q, *n;
-	struct pktgen_dev *cur;
+	struct pktgen_dev *cur, *n;
 
 	func_enter();
 
 	/* Remove all devices, free mem */
 
-	list_for_each_safe(q, n, &t->if_list) {
-		cur = list_entry(q, struct pktgen_dev, list);
-
+	list_for_each_entry_safe(cur, n, &t->if_list, list) {
 		kfree_skb(cur->skb);
 		cur->skb = NULL;
 
@@ -3771,12 +3765,10 @@ static int __net_init pktgen_create_thread(int cpu, struct pktgen_net *pn)
 static void _rem_dev_from_if_list(struct pktgen_thread *t,
 				  struct pktgen_dev *pkt_dev)
 {
-	struct list_head *q, *n;
-	struct pktgen_dev *p;
+	struct pktgen_dev *p, *n;
 
 	if_lock(t);
-	list_for_each_safe(q, n, &t->if_list) {
-		p = list_entry(q, struct pktgen_dev, list);
+	list_for_each_entry_safe(p, n, &t->if_list, list) {
 		if (p == pkt_dev)
 			list_del_rcu(&p->list);
 	}
@@ -3866,8 +3858,7 @@ remove:
 static void __net_exit pg_net_exit(struct net *net)
 {
 	struct pktgen_net *pn = net_generic(net, pg_net_id);
-	struct pktgen_thread *t;
-	struct list_head *q, *n;
+	struct pktgen_thread *t, *n;
 	LIST_HEAD(list);
 
 	/* Stop all interfaces & threads */
@@ -3877,8 +3868,7 @@ static void __net_exit pg_net_exit(struct net *net)
 	list_splice_init(&pn->pktgen_threads, &list);
 	mutex_unlock(&pktgen_thread_lock);
 
-	list_for_each_safe(q, n, &list) {
-		t = list_entry(q, struct pktgen_thread, th_list);
+	list_for_each_entry_safe(t, n, &list, th_list) {
 		list_del(&t->th_list);
 		kthread_stop(t->tsk);
 		put_task_struct(t->tsk);
-- 
2.5.0

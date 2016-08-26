From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: batch calls to flush_all_backlogs()
Date: Fri, 26 Aug 2016 12:50:39 -0700
Message-ID: <1472241039.14381.202.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36615 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752226AbcHZTum (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 15:50:42 -0400
Received: by mail-pf0-f195.google.com with SMTP id y134so5360776pfg.3
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 12:50:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After commit 145dd5f9c88f ("net: flush the softnet backlog in process
context"), we can easily batch calls to flush_all_backlogs() for all
devices processed in rollback_registered_many()

Tested:

Before patch, on an idle host.

modprobe dummy numdummies=10000
perf stat -e context-switches -a rmmod dummy

 Performance counter stats for 'system wide':

         1,211,798      context-switches

       1.302137465 seconds time elapsed

After patch:

perf stat -e context-switches -a rmmod dummy

 Performance counter stats for 'system wide':

           225,523      context-switches

       0.721623566 seconds time elapsed


Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |   32 ++++++++++++--------------------
 1 file changed, 12 insertions(+), 20 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7feae74ca928..996107f041a3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4292,18 +4292,11 @@ int netif_receive_skb(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(netif_receive_skb);
 
-struct flush_work {
-	struct net_device *dev;
-	struct work_struct work;
-};
-
-DEFINE_PER_CPU(struct flush_work, flush_works);
+DEFINE_PER_CPU(struct work_struct, flush_works);
 
 /* Network device is going away, flush any packets still pending */
 static void flush_backlog(struct work_struct *work)
 {
-	struct flush_work *flush = container_of(work, typeof(*flush), work);
-	struct net_device *dev = flush->dev;
 	struct sk_buff *skb, *tmp;
 	struct softnet_data *sd;
 
@@ -4313,7 +4306,7 @@ static void flush_backlog(struct work_struct *work)
 	local_irq_disable();
 	rps_lock(sd);
 	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp) {
-		if (skb->dev == dev) {
+		if (skb->dev->reg_state == NETREG_UNREGISTERING) {
 			__skb_unlink(skb, &sd->input_pkt_queue);
 			kfree_skb(skb);
 			input_queue_head_incr(sd);
@@ -4323,7 +4316,7 @@ static void flush_backlog(struct work_struct *work)
 	local_irq_enable();
 
 	skb_queue_walk_safe(&sd->process_queue, skb, tmp) {
-		if (skb->dev == dev) {
+		if (skb->dev->reg_state == NETREG_UNREGISTERING) {
 			__skb_unlink(skb, &sd->process_queue);
 			kfree_skb(skb);
 			input_queue_head_incr(sd);
@@ -4332,22 +4325,18 @@ static void flush_backlog(struct work_struct *work)
 	local_bh_enable();
 }
 
-static void flush_all_backlogs(struct net_device *dev)
+static void flush_all_backlogs(void)
 {
 	unsigned int cpu;
 
 	get_online_cpus();
 
-	for_each_online_cpu(cpu) {
-		struct flush_work *flush = per_cpu_ptr(&flush_works, cpu);
-
-		INIT_WORK(&flush->work, flush_backlog);
-		flush->dev = dev;
-		queue_work_on(cpu, system_highpri_wq, &flush->work);
-	}
+	for_each_online_cpu(cpu)
+		queue_work_on(cpu, system_highpri_wq,
+			      per_cpu_ptr(&flush_works, cpu));
 
 	for_each_online_cpu(cpu)
-		flush_work(&per_cpu_ptr(&flush_works, cpu)->work);
+		flush_work(per_cpu_ptr(&flush_works, cpu));
 
 	put_online_cpus();
 }
@@ -6735,8 +6724,8 @@ static void rollback_registered_many(struct list_head *head)
 		unlist_netdevice(dev);
 
 		dev->reg_state = NETREG_UNREGISTERING;
-		flush_all_backlogs(dev);
 	}
+	flush_all_backlogs();
 
 	synchronize_net();
 
@@ -8301,8 +8290,11 @@ static int __init net_dev_init(void)
 	 */
 
 	for_each_possible_cpu(i) {
+		struct work_struct *flush = per_cpu_ptr(&flush_works, i);
 		struct softnet_data *sd = &per_cpu(softnet_data, i);
 
+		INIT_WORK(flush, flush_backlog);
+
 		skb_queue_head_init(&sd->input_pkt_queue);
 		skb_queue_head_init(&sd->process_queue);
 		INIT_LIST_HEAD(&sd->poll_list);

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: flush the softnet backlog in process
 context
Date: Thu, 25 Aug 2016 09:25:33 -0700
Message-ID: <1472142333.14381.145.camel@edumazet-glaptop3.roam.corp.google.com>
References: <528006070d2951617c55b94c60c5d690ff0e4fc3.1472130597.git.pabeni@redhat.com>
         <1472135557.14381.130.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472136456.14381.133.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472137118.4769.38.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34652 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760071AbcHYQZg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:25:36 -0400
Received: by mail-pf0-f194.google.com with SMTP id g202so3489739pfb.1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:25:35 -0700 (PDT)
In-Reply-To: <1472137118.4769.38.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-25 at 16:58 +0200, Paolo Abeni wrote:
> On Thu, 2016-08-25 at 07:47 -0700, Eric Dumazet wrote:
> > On Thu, 2016-08-25 at 07:32 -0700, Eric Dumazet wrote:
> > 
> > > In a future patch, we could change this so that we kick
> > > flush_all_backlogs() once for all devices, instead of one device at a
> > > time.
> > > 
> > > We would not pass @dev anymore as a parameter and simply look at
> > > skb->dev->reg_state to decide to remove packets from queues in
> > > flush_backlog()
> > 
> > This would be something like :
> 
> This is actually a nice cleanup. I hope to test it later.
> 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 7feae74ca928..793ace2c600f 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -4293,7 +4293,6 @@ int netif_receive_skb(struct sk_buff *skb)
> >  EXPORT_SYMBOL(netif_receive_skb);
> >  
> >  struct flush_work {
> > -	struct net_device *dev;
> >  	struct work_struct work;
> >  };
> 
> With 'dev' removal, I think we can use directly 'work_struct'  and avoid
> 'container_of' usage in flush_backlog().

Sure. Here is the patch I will propose :

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

From: Andreas Mohr <andi@lisas.de>
Subject: [RFC patch] bridge GARP: prevent 20 wakeups/s when sitting idle
Date: Tue, 11 Aug 2009 16:38:19 +0200
Message-ID: <20090811143819.GA1348@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, power@bughost.org,
	linux-kernel@vger.kernel.org, andi@lisas.de
To: bridge@lists.linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754946AbZHKOiW@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all,

this is an RFC patch to avoid having the GARP timer remain in full speed
_forever_ (a full 20 superfluous wakeups per second as seen in powertop
on my server) as soon as one GARP applicant managed to show up.

The old behaviour was to simply initially arm the timer as soon as an applicant
showed up, then _unconditionally_ rearm the timer with a random
garp_join_time-based delay in the timer handler _itself_.

New behaviour is to arm the timer when a request comes in _and_ zero
previous requests exist (managed atomically, via locked operation
of list splicing). Then for further incoming requests,
as long as the random garp_join_time-based delay isn't expired
the producer queue fills up, and once the timer fires
this list is moved over into the dequeueing list, to be sent off
(with minimal locking in that case).

Unfortunately the patch hasn't really been tested since the affected box
(at a remote location) for some reason didn't activate GARP last time
despite manually enabling the bridge.

I'm sufficiently confident that it's working as expected, though, since it's
a pretty developed iteration with pretty robust behaviour code-wise,
with lots of communicative assistance by the GARP author, Patrick McHardy.

So, any comments about this? Any users of GARP bridging out there who
can confirm that it helps properly?

Thanks,

Andreas Mohr

--- linux-2.6.30.4/net/802/garp.c.org	2009-06-27 20:04:46.000000000 +0200
+++ linux-2.6.30.4/net/802/garp.c	2009-08-06 00:53:50.000000000 +0200
@@ -135,6 +135,10 @@ static const struct garp_state_trans {
 	},
 };
 
+static void garp_join_timer_arm(struct garp_applicant *app);
+
+
+
 static int garp_attr_cmp(const struct garp_attr *attr,
 			 const void *data, u8 len, u8 type)
 {
@@ -238,6 +242,7 @@ static int garp_pdu_append_end_mark(stru
 
 static void garp_pdu_queue(struct garp_applicant *app)
 {
+	bool need_arm_timer;
 	if (!app->pdu)
 		return;
 
@@ -250,15 +255,37 @@ static void garp_pdu_queue(struct garp_a
 	llc_mac_hdr_init(app->pdu, app->dev->dev_addr,
 			 app->app->proto.group_address);
 
-	skb_queue_tail(&app->queue, app->pdu);
+	printk(KERN_INFO "garp_pdu_queue app %p\n", app);
+	/*
+	 * [this function always to be called under app lock under
+	 * normal operation]
+	 * Make sure to arm the timer upon encountering our first packet;
+	 * further packets queued by us will then be allowed to accumulate
+	 * until timer ultimately fires.
+	 */
+	need_arm_timer = skb_queue_empty(&app->queue);
+	__skb_queue_tail(&app->queue, app->pdu);
 	app->pdu = NULL;
+	if (need_arm_timer)
+		garp_join_timer_arm(app);
 }
 
 static void garp_queue_xmit(struct garp_applicant *app)
 {
 	struct sk_buff *skb;
+	struct sk_buff_head	dequeue; /* accumul. requests to be handled */
+
+	printk(KERN_INFO "garp_queue_xmit app %p\n", app);
+
+	/* Atomically move over all incoming pdus into our processing queue.
+	   This is needed to provide some reliable criteria whether our timer
+	   should be rearmed or not. */
+	spin_lock_bh(&app->lock);
+	__skb_queue_head_init(&dequeue);
+	skb_queue_splice_init(&app->queue, &dequeue);
+	spin_unlock_bh(&app->lock);
 
-	while ((skb = skb_dequeue(&app->queue)))
+	while ((skb = skb_dequeue(&dequeue)))
 		dev_queue_xmit(skb);
 }
 
@@ -398,6 +425,7 @@ static void garp_join_timer_arm(struct g
 	unsigned long delay;
 
 	delay = (u64)msecs_to_jiffies(garp_join_time) * net_random() >> 32;
+	printk(KERN_INFO "garp_join_timer_arm app %p jiffies %lu delay %lu\n", app, jiffies, delay);
 	mod_timer(&app->join_timer, jiffies + delay);
 }
 
@@ -411,7 +439,6 @@ static void garp_join_timer(unsigned lon
 	spin_unlock(&app->lock);
 
 	garp_queue_xmit(app);
-	garp_join_timer_arm(app);
 }
 
 static int garp_pdu_parse_end_mark(struct sk_buff *skb)
@@ -586,7 +613,6 @@ int garp_init_applicant(struct net_devic
 	skb_queue_head_init(&app->queue);
 	rcu_assign_pointer(dev->garp_port->applicants[appl->type], app);
 	setup_timer(&app->join_timer, garp_join_timer, (unsigned long)app);
-	garp_join_timer_arm(app);
 	return 0;
 
 err3:

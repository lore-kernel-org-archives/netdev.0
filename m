From: Noel Burton-Krahn <noel@burton-krahn.com>
Subject: Re: [PATCH RFC 0/2] Multiple VLAN Registration Protocol (IEEE 802.1Q-2011)
Date: Wed, 11 Sep 2013 00:22:51 +0000 (UTC)
Message-ID: <loom.20130911T015852-549@post.gmane.org>
References: <1348520855-8810-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:41851 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751284Ab3IKAZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 20:25:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VJYEx-0000Bt-Cm
	for netdev@vger.kernel.org; Wed, 11 Sep 2013 02:25:04 +0200
Received: from 192.251.30.171 ([192.251.30.171])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 02:25:03 +0200
Received: from noel by 192.251.30.171 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 02:25:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ward <david.ward <at> ll.mit.edu> writes:

> The following patches add support for MVRP to 
> the Linux kernel and iproute2 utility. They are based largely off of 
> the existing implementation of GVRP, but have been modified for the 
> new PDU structure and state machine.
> 
> Please let me know if you have any comments. This implementation was 
> tested with two Juniper EX4200 switches and found to work as expected. 
> If you have access to other switches that implement MVRP, I would of 
> course welcome additional testing.
> 
> Signed-off-by: David Ward <david.ward <at> ll.mit.edu>
> 



David,

Thanks for your MVRP implementation.  I ran into a problem with MVRP where
it would fail to register if MVRP started too soon after the network
interface came up.  There's a few seconds from when an interface is up until
it can actually send packets, even after it reports it's up, so the first
few MVRP JoinIn packets would get lost.  The Linux MRP implementation that
sends JoinIn packets was missing the periodic timer required by
[802.1Q-2011], so after the JoinIn's were lost, the MVRP registration would
never retry, and MVRP would fail to register:

  10.7.4.4 periodictimer
  The Periodic Transmission timer, periodictimer, controls the
  frequency with which the PeriodicTransmission state machine
  generates periodic!  events. The timer is required on a per-Port
  basis. The Periodic Transmission timer is set to one second when it
  is started.

The weird thing about the periodictimer is that it fires every second
forever, and the MRP Applicant state machine bounces from QA to AA states
and back every second, sending a MRP request every time.  There's no state
to be quiet after the applicant receives a rJoinIn acknowledgement.  See
Section 10.7.7 (Applicant state machine) in [802.1Q-2011].  The result is
that the MRP application sends JoinIn every second, which seems a little
noisy.  Am I missing something?


[802.1Q-2011]
http://standards.ieee.org/findstds/standard/802.1Q-2011.html


Here's a patch for net/mrp.c that adds the periodic timer.  My working fork
is at https://github.com/noelbk/linux.

Cheers,
--
Noel




diff --git a/include/net/mrp.h b/include/net/mrp.h
index 4fbf02a..0f7558b 100644
--- a/include/net/mrp.h
+++ b/include/net/mrp.h
@@ -112,6 +112,7 @@ struct mrp_applicant {
 	struct mrp_application	*app;
 	struct net_device	*dev;
 	struct timer_list	join_timer;
+	struct timer_list	periodic_timer;
 
 	spinlock_t		lock;
 	struct sk_buff_head	queue;
diff --git a/net/802/mrp.c b/net/802/mrp.c
index 1eb05d8..8f1fa4f 100644
--- a/net/802/mrp.c
+++ b/net/802/mrp.c
@@ -1,3 +1,5 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": %s: " fmt, __func__
+
 /*
  *	IEEE 802.1Q Multiple Registration Protocol (MRP)
  *
@@ -24,6 +26,12 @@
 static unsigned int mrp_join_time __read_mostly = 200;
 module_param(mrp_join_time, uint, 0644);
 MODULE_PARM_DESC(mrp_join_time, "Join time in ms (default 200ms)");
+
+static unsigned int mrp_periodic_time __read_mostly = 1000;
+module_param(mrp_periodic_time, uint, 0644);
+MODULE_PARM_DESC(mrp_periodic_time, "Periodic time in ms (default 1s)");
+
+
 MODULE_LICENSE("GPL");
 
 static const u8
@@ -210,6 +218,52 @@ mrp_tx_action_table[MRP_APPLICANT_MAX + 1] = {
 	[MRP_APPLICANT_QP] = MRP_TX_ACTION_S_IN_OPTIONAL,
 };
 
+
+// debug
+static char *
+mrp_event_str(enum mrp_event event) {
+    char *s = "unknown";
+    switch(event) {
+    case MRP_EVENT_NEW:        s = "NEW"; break;
+    case MRP_EVENT_JOIN:       s = "JOIN"; break;
+    case MRP_EVENT_LV:	       s = "LV"; break;
+    case MRP_EVENT_TX:	       s = "TX"; break;
+    case MRP_EVENT_R_NEW:      s = "R_NEW"; break;
+    case MRP_EVENT_R_JOIN_IN:  s = "R_JOIN_IN"; break;
+    case MRP_EVENT_R_IN:       s = "R_IN"; break;
+    case MRP_EVENT_R_JOIN_MT:  s = "R_JOIN_MT"; break;
+    case MRP_EVENT_R_MT:       s = "R_MT"; break;
+    case MRP_EVENT_R_LV:       s = "R_LV"; break;
+    case MRP_EVENT_R_LA:       s = "R_LA"; break;
+    case MRP_EVENT_REDECLARE:  s = "REDECLARE"; break;
+    case MRP_EVENT_PERIODIC:   s = "PERIODIC"; break;
+    case __MRP_EVENT_MAX:      break;
+    }
+    return s;
+}
+
+// debug
+static char *
+mrp_applicant_state_str(enum mrp_applicant_state state) {
+    char *s = "unknown";
+    switch(state) {
+    case MRP_APPLICANT_INVALID:  s = "INVALID"; break;
+    case MRP_APPLICANT_VO:       s = "VO"; break;
+    case MRP_APPLICANT_VP:       s = "VP"; break;
+    case MRP_APPLICANT_VN:       s = "VN"; break;
+    case MRP_APPLICANT_AN:       s = "AN"; break;
+    case MRP_APPLICANT_AA:       s = "AA"; break;
+    case MRP_APPLICANT_QA:       s = "QA"; break;
+    case MRP_APPLICANT_LA:       s = "LA"; break;
+    case MRP_APPLICANT_AO:       s = "AO"; break;
+    case MRP_APPLICANT_QO:       s = "QO"; break;
+    case MRP_APPLICANT_AP:       s = "AP"; break;
+    case MRP_APPLICANT_QP:       s = "QP"; break;
+    case __MRP_APPLICANT_MAX:    break;
+    }
+    return s;
+}
+
 static void mrp_attrvalue_inc(void *value, u8 len)
 {
 	u8 *v = (u8 *)value;
@@ -345,8 +399,15 @@ static void mrp_queue_xmit(struct mrp_applicant *app)
 {
 	struct sk_buff *skb;
 
-	while ((skb = skb_dequeue(&app->queue)))
-		dev_queue_xmit(skb);
+	while ((skb = skb_dequeue(&app->queue))) {
+	    int xmit_err = dev_queue_xmit(skb);
+	    pr_debug("dev=%s len=%d dev_queue_xmit=%d carrier_ok=%d dormant=%d\n"
+		     ,skb->dev->name, (int)skb->len
+		     ,(int)xmit_err
+		     ,(int)netif_carrier_ok(skb->dev)
+		     ,(int)netif_dormant(skb->dev)
+		     );
+	}
 }
 
 static int mrp_pdu_append_msg_hdr(struct mrp_applicant *app,
@@ -474,6 +535,13 @@ static void mrp_attr_event(struct mrp_applicant *app,
 		return;
 	}
 
+	pr_debug("attr_type=%d event=%s attr->state=%s new state=%s\n"
+		 ,(int)attr->type
+		 ,mrp_event_str(event)
+		 ,mrp_applicant_state_str(attr->state)
+		 ,mrp_applicant_state_str(state));
+
+
 	if (event == MRP_EVENT_TX) {
 		/* When appending the attribute fails, don't update its state
 		 * in order to retry at the next TX event.
@@ -521,6 +589,8 @@ int mrp_request_join(const struct net_device *dev,
 		port->applicants[appl->type]);
 	struct mrp_attr *attr;
 
+	pr_debug("dev->name=%s attr_type=%d\n", dev->name, (int)type);
+
 	if (sizeof(struct mrp_skb_cb) + len >
 	    FIELD_SIZEOF(struct sk_buff, cb))
 		return -ENOMEM;
@@ -546,6 +616,8 @@ void mrp_request_leave(const struct net_device *dev,
 		port->applicants[appl->type]);
 	struct mrp_attr *attr;
 
+	pr_debug("dev->name=%s attr_type=%d\n", dev->name, (int)type);
+
 	if (sizeof(struct mrp_skb_cb) + len >
 	    FIELD_SIZEOF(struct sk_buff, cb))
 		return;
@@ -595,6 +667,52 @@ static void mrp_join_timer(unsigned long data)
 	mrp_join_timer_arm(app);
 }
 
+static void mrp_periodic_timer_arm(struct mrp_applicant *app)
+{
+	unsigned long delay;
+
+	delay = (u64)msecs_to_jiffies(mrp_periodic_time);
+	mod_timer(&app->periodic_timer, jiffies + delay);
+}
+
+
+/*
+
+from [802.1Q-2011]
+http://standards.ieee.org/findstds/standard/802.1Q-2011.html
+
+
+10.7.4.4 periodictimer
+
+The Periodic Transmission timer, periodictimer, controls the frequency
+with which the PeriodicTransmission state machine generates periodic!
+events. The timer is required on a per-Port basis. The Periodic
+Transmission timer is set to one second when it is started.
+
+10.7.5.10 periodic!
+
+This event indicates to the Applicant state machine that the timer
+used to stimulate periodic transmission has expired.
+
+10.7.5.23 periodictimer!
+
+For an instance of the PeriodicTransmission state machine, the
+periodictimer! event is deemed to have occurred when the periodictimer
+associated with that state machine expires.
+
+*/
+static void mrp_periodic_timer(unsigned long data)
+{
+	struct mrp_applicant *app = (struct mrp_applicant *)data;
+
+	spin_lock(&app->lock);
+	mrp_mad_event(app, MRP_EVENT_PERIODIC);
+	mrp_pdu_queue(app);
+	spin_unlock(&app->lock);
+
+	mrp_periodic_timer_arm(app);
+}
+
 static int mrp_pdu_parse_end_mark(struct sk_buff *skb, int *offset)
 {
 	__be16 endmark;
@@ -791,10 +909,13 @@ out:
 	return 0;
 }
 
+
 static int mrp_init_port(struct net_device *dev)
 {
 	struct mrp_port *port;
 
+	pr_debug("dev->name=%s\n", dev->name);
+
 	port = kzalloc(sizeof(*port), GFP_KERNEL);
 	if (!port)
 		return -ENOMEM;
@@ -807,6 +928,8 @@ static void mrp_release_port(struct net_device *dev)
 	struct mrp_port *port = rtnl_dereference(dev->mrp_port);
 	unsigned int i;
 
+	pr_debug("dev->name=%s\n", dev->name);
+
 	for (i = 0; i <= MRP_APPLICATION_MAX; i++) {
 		if (rtnl_dereference(port->applicants[i]))
 			return;
@@ -820,6 +943,8 @@ int mrp_init_applicant(struct net_device *dev, struct
mrp_application *appl)
 	struct mrp_applicant *app;
 	int err;
 
+	pr_debug("dev->name=%s\n", dev->name);
+
 	ASSERT_RTNL();
 
 	if (!rtnl_dereference(dev->mrp_port)) {
@@ -845,6 +970,8 @@ int mrp_init_applicant(struct net_device *dev, struct
mrp_application *appl)
 	rcu_assign_pointer(dev->mrp_port->applicants[appl->type], app);
 	setup_timer(&app->join_timer, mrp_join_timer, (unsigned long)app);
 	mrp_join_timer_arm(app);
+	setup_timer(&app->periodic_timer, mrp_periodic_timer, (unsigned long)app);
+	mrp_periodic_timer_arm(app);
 	return 0;
 
 err3:
@@ -862,6 +989,8 @@ void mrp_uninit_applicant(struct net_device *dev, struct
mrp_application *appl)
 	struct mrp_applicant *app = rtnl_dereference(
 		port->applicants[appl->type]);
 
+	pr_debug("dev->name=%s\n", dev->name);
+
 	ASSERT_RTNL();
 
 	RCU_INIT_POINTER(port->applicants[appl->type], NULL);
@@ -870,6 +999,7 @@ void mrp_uninit_applicant(struct net_device *dev, struct
mrp_application *appl)
 	 * all pending messages before the applicant is gone.
 	 */
 	del_timer_sync(&app->join_timer);
+	del_timer_sync(&app->periodic_timer);
 
 	spin_lock_bh(&app->lock);
 	mrp_mad_event(app, MRP_EVENT_TX);
@@ -897,3 +1027,4 @@ void mrp_unregister_application(struct mrp_application
*appl)
 	dev_remove_pack(&appl->pkttype);
 }
 EXPORT_SYMBOL_GPL(mrp_unregister_application);
+

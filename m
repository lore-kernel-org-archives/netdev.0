From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: 14 Feb 2004 08:56:21 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076766981.1059.16.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>
	 <20040211200549.736fa8b3.davem@redhat.com>
	 <1076561489.1032.65.camel@jzny.localdomain>
	 <1076561998.1035.72.camel@jzny.localdomain>
	 <1076562282.1033.76.camel@jzny.localdomain>
	 <20040211211536.23e97997.davem@redhat.com>
	 <1076563502.1031.85.camel@jzny.localdomain>
	 <1076564638.1033.91.camel@jzny.localdomain>
	 <20040211215142.7f817513.davem@redhat.com>
	 <1076566176.1033.94.camel@jzny.localdomain>
	 <20040211222259.776ad818.davem@redhat.com> <402D54D6.5070708@trash.net>
	 <20040213213606.5a13cc76.davem@redhat.com>
	 <1076762757.1060.4.camel@jzny.localdomain>
	 <1076763997.1059.13.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-q/iay1AfC+GTYLm2u913"
Cc: Patrick McHardy <kaber@trash.net>, qnex@atlantis.knm.org.pl,
        netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <1076763997.1059.13.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-q/iay1AfC+GTYLm2u913
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


And the closest to a sane patch in 30 secs that compiles is attached
to describe the idea.

cheers,
jamal

On Sat, 2004-02-14 at 08:06, jamal wrote:
> On second thought:
> Dawid noticed that SFQ and RED appear immune to this problem
> (i think any non classful qdisc would exhibit same behavior).
> Maybe we should allow for this behavior for consistency.
> The suggestion that Alexey made  of setting limit of 1 to default 
> child fifo when tx_queue_len is 0 is the better appraoch instead of
> touching these devices.
> 
> cheers,
> jamal
> 
> jamal wrote:
> > On Sat, 2004-02-14 at 00:36, David S. Miller wrote:
> > 
> > > However, I do agree with you, and we should not promote this kind of crap.
> > > I'm going to revert the changeset that set tx_queue_len to 1 in the tunnels.
> > 
> > I concur. But you gotta admit if that was a bug, it was the fastest
> > fixed bug of the week ;->
> > 
> > cheers,
> > jamal
> > 
> > 
> > 
> > 
> > 
> 
> 
> 

--=-q/iay1AfC+GTYLm2u913
Content-Disposition: attachment; filename=p2
Content-Type: text/plain; name=p2; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 261-mod/net/sched/sch_generic.c	2004/02/14 13:10:43	1.1
+++ 261-mod/net/sched/sch_generic.c	2004/02/14 13:42:18
@@ -448,22 +448,17 @@
 
 	if (dev->qdisc_sleeping == &noop_qdisc) {
 		struct Qdisc *qdisc;
-		if (dev->tx_queue_len) {
-			qdisc = qdisc_create_dflt(dev, &pfifo_fast_ops);
-			if (qdisc == NULL) {
-				printk(KERN_INFO "%s: activation failed\n", dev->name);
-				return;
-			}
-
-			write_lock(&qdisc_tree_lock);
-			qdisc->next = dev->qdisc_list;
-			dev->qdisc_list = qdisc;
-			write_unlock(&qdisc_tree_lock);
-
-		} else {
-			qdisc =  &noqueue_qdisc;
+		if (!dev->tx_queue_len) 
+			dev->tx_queue_len = 1;
+		qdisc = qdisc_create_dflt(dev, &pfifo_fast_ops);
+		if (qdisc == NULL) {
+			printk(KERN_INFO "%s: activation failed\n", dev->name);
+			return;
 		}
+
 		write_lock(&qdisc_tree_lock);
+		qdisc->next = dev->qdisc_list;
+		dev->qdisc_list = qdisc;
 		dev->qdisc_sleeping = qdisc;
 		write_unlock(&qdisc_tree_lock);
 	}
@@ -489,6 +484,8 @@
 	spin_unlock_bh(&dev->queue_lock);
 
 	dev_watchdog_down(dev);
+	if (dev->tx_queue_len == 1)
+		dev->tx_queue_len = 0;
 
 	while (test_bit(__LINK_STATE_SCHED, &dev->state))
 		yield();

--=-q/iay1AfC+GTYLm2u913--

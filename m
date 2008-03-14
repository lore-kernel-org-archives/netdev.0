From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Audit vs netlink interaction problem
Date: Fri, 14 Mar 2008 19:40:52 +0100
Message-ID: <20080314184052.GR20815@postel.suug.ch>
References: <47DAA660.90401@openvz.org> <20080314163929.GP20815@postel.suug.ch> <47DAB065.6060804@openvz.org> <20080314182927.GQ20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:54756 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751488AbYCNSkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2008 14:40:33 -0400
Content-Disposition: inline
In-Reply-To: <20080314182927.GQ20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Thomas Graf <tgraf@suug.ch> 2008-03-14 19:29
> * Pavel Emelyanov <xemul@openvz.org> 2008-03-14 20:05
> > Hmmm... I'm afraid, that this can break the audit filtering and signal
> > auditing. I haven't yet looked deep into it, but it compares the 
> > task->tgid with this audit_pid for different purposes. If audit_pid
> > changes this code will be broken.
> 
> OK, then both pids have to be stored. audit_pid remains as-is but is
> no longer used as destination netlink pid. A second pid is stored and
> updated whenever a netlink message is received from userspace.

The following patch represents what I mean. Untested!

Index: net-2.6.26/kernel/audit.c
===================================================================
--- net-2.6.26.orig/kernel/audit.c	2008-03-14 19:31:53.000000000 +0100
+++ net-2.6.26/kernel/audit.c	2008-03-14 19:38:35.000000000 +0100
@@ -82,6 +82,9 @@
  * contains the (non-zero) pid. */
 int		audit_pid;
 
+/* Actual netlink pid of the userspace process */
+static int	audit_nlk_pid;
+
 /* If audit_rate_limit is non-zero, limit the rate of sending audit records
  * to that number per second.  This prevents DoS attacks, but results in
  * audit records being dropped. */
@@ -347,12 +350,12 @@
 		skb = skb_dequeue(&audit_skb_queue);
 		wake_up(&audit_backlog_wait);
 		if (skb) {
-			if (audit_pid) {
-				int err = netlink_unicast(audit_sock, skb, audit_pid, 0);
+			if (audit_nlk_pid) {
+				int err = netlink_unicast(audit_sock, skb, audit_nlk_pid, 0);
 				if (err < 0) {
 					BUG_ON(err != -ECONNREFUSED); /* Shoudn't happen */
-					printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n", audit_pid);
-					audit_pid = 0;
+					printk(KERN_ERR "audit: *NO* daemon at audit_nlk_pid=%d\n", audit_nlk_pid);
+					audit_nlk_pid = 0;
 				}
 			} else {
 				if (printk_ratelimit())
@@ -623,6 +626,12 @@
 							sid, 1);
 
 			audit_pid = new_pid;
+
+			/*
+			 * Netlink pid is only updated here to avoid overwrites
+			 * from potential processes only querying the interface.
+			 */
+			audit_nlk_pid = NETLINK_CB(skb).pid;
 		}
 		if (status_get->mask & AUDIT_STATUS_RATE_LIMIT)
 			err = audit_set_rate_limit(status_get->rate_limit,
@@ -1350,7 +1359,7 @@
 	if (!audit_rate_check()) {
 		audit_log_lost("rate limit exceeded");
 	} else {
-		if (audit_pid) {
+		if (audit_nlk_pid) {
 			struct nlmsghdr *nlh = nlmsg_hdr(ab->skb);
 			nlh->nlmsg_len = ab->skb->len - NLMSG_SPACE(0);
 			skb_queue_tail(&audit_skb_queue, ab->skb);

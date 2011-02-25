From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH] sysctl: ipv6: use correct net in ipv6_sysctl_rtcache_flush
Date: Fri, 25 Feb 2011 07:48:03 +0200
Message-ID: <1298612883-18762-1-git-send-email-lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:52991 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431Ab1BYFsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 00:48:25 -0500
Received: by eyx24 with SMTP id 24so485397eyx.19
        for <netdev@vger.kernel.org>; Thu, 24 Feb 2011 21:48:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch issuing these commands:

  fd = open("/proc/sys/net/ipv6/route/flush")
  unshare(CLONE_NEWNET)
  write(fd, "stuff")

would flush the newly created net, not the original one.

The equivalent ipv4 code is correct (stores the net inside ->extra1).
---
 net/ipv6/route.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f786aed..522563e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2604,14 +2604,16 @@ static
 int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write,
 			      void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	struct net *net = current->nsproxy->net_ns;
-	int delay = net->ipv6.sysctl.flush_delay;
-	if (write) {
-		proc_dointvec(ctl, write, buffer, lenp, ppos);
-		fib6_run_gc(delay <= 0 ? ~0UL : (unsigned long)delay, net);
-		return 0;
-	} else
+	struct net *net;
+	int delay;
+	if (!write)
 		return -EINVAL;
+
+	net = (struct net *)ctl->extra1;
+	delay = net->ipv6.sysctl.flush_delay;
+	proc_dointvec(ctl, write, buffer, lenp, ppos);
+	fib6_run_gc(delay <= 0 ? ~0UL : (unsigned long)delay, net);
+	return 0;
 }
 
 ctl_table ipv6_route_table_template[] = {
@@ -2698,6 +2700,7 @@ struct ctl_table * __net_init ipv6_route_sysctl_init(struct net *net)
 
 	if (table) {
 		table[0].data = &net->ipv6.sysctl.flush_delay;
+		table[0].extra1 = net;
 		table[1].data = &net->ipv6.ip6_dst_ops.gc_thresh;
 		table[2].data = &net->ipv6.sysctl.ip6_rt_max_size;
 		table[3].data = &net->ipv6.sysctl.ip6_rt_gc_min_interval;
-- 
1.7.4.rc1.7.g2cf08.dirty


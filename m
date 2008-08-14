From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ipv4: Disable route secret interval on zero interval
Date: Thu, 14 Aug 2008 18:27:02 +1000
Message-ID: <20080814082702.GA32676@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53388 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752534AbYHNI1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 04:27:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

ipv4: Disable route secret interval on zero interval

Let me first state that disabling the route cache hash rebuild
should not be done without extensive analysis on the risk profile
and careful deliberation.

However, there are times when this can be done safely or for
testing.  For example, when you have mechanisms for ensuring
that offending parties do not exist in your network.

This patch lets the user disable the rebuild if the interval is
set to zero.  This also incidentally fixes a divide-by-zero error
with name-spaces.

In addition, this patch makes the effect of an interval change
immediate rather than it taking effect at the next rebuild as
is currently the case.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 16fc6f4..cca921e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2914,6 +2914,68 @@ static int ipv4_sysctl_rtcache_flush_strategy(ctl_table *table,
 	return 0;
 }
 
+static void rt_secret_reschedule(int old)
+{
+	struct net *net;
+	int new = ip_rt_secret_interval;
+	int diff = new - old;
+
+	if (!diff)
+		return;
+
+	rtnl_lock();
+	for_each_net(net) {
+		int deleted = del_timer_sync(&net->ipv4.rt_secret_timer);
+
+		if (!new)
+			continue;
+
+		if (deleted) {
+			long time = net->ipv4.rt_secret_timer.expires - jiffies;
+
+			if (time <= 0 || (time += diff) <= 0)
+				time = 0;
+
+			net->ipv4.rt_secret_timer.expires = time;
+		} else
+			net->ipv4.rt_secret_timer.expires = new;
+
+		net->ipv4.rt_secret_timer.expires += jiffies;
+		add_timer(&net->ipv4.rt_secret_timer);
+	}
+	rtnl_unlock();
+}
+
+static int ipv4_sysctl_rt_secret_interval(ctl_table *ctl, int write,
+					  struct file *filp,
+					  void __user *buffer, size_t *lenp,
+					  loff_t *ppos)
+{
+	int old = ip_rt_secret_interval;
+	int ret = proc_dointvec_jiffies(ctl, write, filp, buffer, lenp, ppos);
+
+	rt_secret_reschedule(old);
+
+	return ret;
+}
+
+static int ipv4_sysctl_rt_secret_interval_strategy(ctl_table *table,
+						   int __user *name,
+						   int nlen,
+						   void __user *oldval,
+						   size_t __user *oldlenp,
+						   void __user *newval,
+						   size_t newlen)
+{
+	int old = ip_rt_secret_interval;
+	int ret = sysctl_jiffies(table, name, nlen, oldval, oldlenp, newval,
+				 newlen);
+
+	rt_secret_reschedule(old);
+
+	return ret;
+}
+
 static ctl_table ipv4_route_table[] = {
 	{
 		.ctl_name	= NET_IPV4_ROUTE_GC_THRESH,
@@ -3048,8 +3110,8 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_secret_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies,
+		.proc_handler	= &ipv4_sysctl_rt_secret_interval,
+		.strategy	= &ipv4_sysctl_rt_secret_interval_strategy,
 	},
 	{ .ctl_name = 0 }
 };
@@ -3126,10 +3188,12 @@ static __net_init int rt_secret_timer_init(struct net *net)
 	net->ipv4.rt_secret_timer.data = (unsigned long)net;
 	init_timer_deferrable(&net->ipv4.rt_secret_timer);
 
-	net->ipv4.rt_secret_timer.expires =
-		jiffies + net_random() % ip_rt_secret_interval +
-		ip_rt_secret_interval;
-	add_timer(&net->ipv4.rt_secret_timer);
+	if (ip_rt_secret_interval) {
+		net->ipv4.rt_secret_timer.expires =
+			jiffies + net_random() % ip_rt_secret_interval +
+			ip_rt_secret_interval;
+		add_timer(&net->ipv4.rt_secret_timer);
+	}
 	return 0;
 }
 

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

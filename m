From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Mon, 29 Sep 2008 15:12:54 -0400
Message-ID: <20080929191254.GA20074@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, davem@davemloft.net, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37322 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbYI2TPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 15:15:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	We currently have the ability to disable our route cache secret interval
rebuild timer (by setting it to zero), but if we do that its possible for an
attacker (if they guess our route cache hash secret, to fill our system with
routes that all hash to the same bucket, destroying our performance.  This patch
provides a backstop for that issues.  In the event that our rebuild interval is
disabled (or very large), if any hash chain exceeds ip_rt_gc_elasticity, we do
an emergency hash rebuild.  During the hash rebuild we:
1) warn the user of the emergency
2) disable the rebuild timer
3) invalidate the route caches
4) re-enable the rebuild timer with its old value

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 route.c |   36 +++++++++++++++++++++++++++++++++++-
 1 file changed, 35 insertions(+), 1 deletion(-)


diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6ee5354..b95e02a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -145,7 +145,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 static int rt_garbage_collect(struct dst_ops *ops);
-
+static void rt_emergency_hash_rebuild(void);
 
 static struct dst_ops ipv4_dst_ops = {
 	.family =		AF_INET,
@@ -1056,6 +1056,15 @@ restart:
 			*candp = cand->u.dst.rt_next;
 			rt_free(cand);
 		}
+	} else if (chain_length > ip_rt_gc_elasticity) {
+		/*
+		 * We didn't find a route entry we could safely free,
+		 * yet our chain length is over our elasticity value.
+		 * Someone may have guessed our hash secret and is artifically
+		 * filling up our route cache.  Lets do an emergency rebuild
+		 * to be safe
+		 */
+		rt_emergency_hash_rebuild();
 	}
 
 	/* Try to bind route to arp only if it is output
@@ -2946,6 +2955,31 @@ static void rt_secret_reschedule(int old)
 	rtnl_unlock();
 }
 
+static void rt_secret_rebuild_oneshot(void) {
+	struct net *net;
+	int old_interval = ip_rt_secret_interval;
+
+	ip_rt_secret_interval = 0;
+
+	rt_secret_reschedule(old_interval);
+
+	for_each_net(net) 
+		rt_cache_invalidate(net);
+
+	ip_rt_secret_interval = old_interval;
+
+	rt_secret_reschedule(0);
+}
+
+static void rt_emergency_hash_rebuild(void) {
+	if (net_ratelimit()) {
+		printk(KERN_WARNING "Route hash chain too long!\n");
+		printk(KERN_WARNING "Adjust your secret_interval!\n");
+	}
+
+	rt_secret_rebuild_oneshot();
+}
+
 static int ipv4_sysctl_rt_secret_interval(ctl_table *ctl, int write,
 					  struct file *filp,
 					  void __user *buffer, size_t *lenp,
-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/

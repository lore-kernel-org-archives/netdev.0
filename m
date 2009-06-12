From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: use a deferred timer in rt_check_expire
Date: Fri, 12 Jun 2009 08:10:07 +0200
Message-ID: <4A31F13F.9080301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Tero.Kristo@nokia.com" <Tero.Kristo@nokia.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55690 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbZFLGKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 02:10:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the sake of power saver lovers, use a deferrable timer to fire rt_check_expire()

As some big routers cache equilibrium depends on garbage collection done in time,
we take into account elapsed time between two rt_check_expire() invocations 
to adjust the amount of slots we have to check.

Based on an initial idea and patch from Tero Kristo

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Tero Kristo <tero.kristo@nokia.com>
---
 net/ipv4/route.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a849bb1..cd76b3c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -131,8 +131,8 @@ static int ip_rt_min_advmss __read_mostly	= 256;
 static int ip_rt_secret_interval __read_mostly	= 10 * 60 * HZ;
 static int rt_chain_length_max __read_mostly	= 20;
 
-static void rt_worker_func(struct work_struct *work);
-static DECLARE_DELAYED_WORK(expires_work, rt_worker_func);
+static struct delayed_work expires_work;
+static unsigned long expires_ljiffies;
 
 /*
  *	Interface to generic destination cache.
@@ -787,9 +787,12 @@ static void rt_check_expire(void)
 	struct rtable *rth, *aux, **rthp;
 	unsigned long samples = 0;
 	unsigned long sum = 0, sum2 = 0;
+	unsigned long delta;
 	u64 mult;
 
-	mult = ((u64)ip_rt_gc_interval) << rt_hash_log;
+	delta = jiffies - expires_ljiffies;
+	expires_ljiffies = jiffies;
+	mult = ((u64)delta) << rt_hash_log;
 	if (ip_rt_gc_timeout > 1)
 		do_div(mult, ip_rt_gc_timeout);
 	goal = (unsigned int)mult;
@@ -3397,6 +3400,8 @@ int __init ip_rt_init(void)
 	/* All the timers, started at system startup tend
 	   to synchronize. Perturb it a bit.
 	 */
+	INIT_DELAYED_WORK_DEFERRABLE(&expires_work, rt_worker_func);
+	expires_ljiffies = jiffies;
 	schedule_delayed_work(&expires_work,
 		net_random() % ip_rt_gc_interval + ip_rt_gc_interval);
 

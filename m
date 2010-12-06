From: nhorman@tuxdriver.com
Subject: [PATCH] Convert netpoll blocking api in bonding driver to be a counter
Date: Mon,  6 Dec 2010 14:05:50 -0500
Message-ID: <1291662350-1656-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49025 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572Ab0LFTGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 14:06:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

A while back I made some changes to enable netpoll in the bonding driver.  Among
them was a per-cpu flag that indicated we were in a path that held locks which
could cause the netpoll path to block in during tx, and as such the tx path
should queue the frame for later use.  This appears to have given rise to a
regression.  If one of those paths on which we hold the per-cpu flag yields the
cpu, its possible for us to come back on a different cpu, leading to us clearing
a different flag than we set.  This results in odd netpoll drops, and BUG
backtraces appearing in the log, as we check to make sure that we only clear set
bits, and only set clear bits.  I had though briefly about changing the
offending paths so that they wouldn't sleep, but looking at my origional work
more closely, it doesn't appear that a per-cpu flag is warranted.  We alrady
gate the checking of this flag on IFF_IN_NETPOLL, so we don't hit this in the
normal tx case anyway.  And practically speaking, the normal use case for
netpoll is to only have one client anyway, so we're not going to erroneously
queue netpoll frames when its actually safe to do so.  As such, lets just
convert that per-cpu flag to an atomic counter.  It fixes the rescheduling bugs,
is equivalent from a performance perspective and actually eliminates some code
in the process.

Tested by the reporter and myself, successfully

Reported-by: Liang Zheng <lzheng@redhat.com>
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: David S. Miller <davem@davemloft.net>
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 drivers/net/bonding/bond_main.c |   17 +++++------------
 drivers/net/bonding/bonding.h   |   12 ++++--------
 2 files changed, 9 insertions(+), 20 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0273ad0..0bae9a5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -171,7 +171,7 @@ MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on link
 /*----------------------------- Global variables ----------------------------*/
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-cpumask_var_t netpoll_block_tx;
+atomic_t netpoll_block_tx = ATOMIC_INIT(0);
 #endif
 
 static const char * const version =
@@ -5293,13 +5293,6 @@ static int __init bonding_init(void)
 	if (res)
 		goto out;
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	if (!alloc_cpumask_var(&netpoll_block_tx, GFP_KERNEL)) {
-		res = -ENOMEM;
-		goto out;
-	}
-#endif
-
 	res = register_pernet_subsys(&bond_net_ops);
 	if (res)
 		goto out;
@@ -5328,9 +5321,6 @@ err:
 	rtnl_link_unregister(&bond_link_ops);
 err_link:
 	unregister_pernet_subsys(&bond_net_ops);
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	free_cpumask_var(netpoll_block_tx);
-#endif
 	goto out;
 
 }
@@ -5347,7 +5337,10 @@ static void __exit bonding_exit(void)
 	unregister_pernet_subsys(&bond_net_ops);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	free_cpumask_var(netpoll_block_tx);
+	/*
+	 * Make sure we don't have an imbalance on our netpoll blocking
+	 */
+	WARN_ON(atomic_read(&netpoll_block_tx));
 #endif
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ad3ae46..bd1a9ab 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -119,26 +119,22 @@
 
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-extern cpumask_var_t netpoll_block_tx;
+extern atomic_t netpoll_block_tx;
 
 static inline void block_netpoll_tx(void)
 {
-	preempt_disable();
-	BUG_ON(cpumask_test_and_set_cpu(smp_processor_id(),
-					netpoll_block_tx));
+	atomic_inc(&netpoll_block_tx);
 }
 
 static inline void unblock_netpoll_tx(void)
 {
-	BUG_ON(!cpumask_test_and_clear_cpu(smp_processor_id(),
-					   netpoll_block_tx));
-	preempt_enable();
+	atomic_dec(&netpoll_block_tx);
 }
 
 static inline int is_netpoll_tx_blocked(struct net_device *dev)
 {
 	if (unlikely(dev->priv_flags & IFF_IN_NETPOLL))
-		return cpumask_test_cpu(smp_processor_id(), netpoll_block_tx);
+		return atomic_read(&netpoll_block_tx);
 	return 0;
 }
 #else
-- 
1.7.2.3


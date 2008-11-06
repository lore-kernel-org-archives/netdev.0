From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/2] net: Guaranetee the proper ordering of the loopback device. v2
Date: Thu, 06 Nov 2008 07:36:00 -0800
Message-ID: <m1skq4zx26.fsf_-_@frodo.ebiederm.org>
References: <48ECA8D2.4090406@openvz.org>
	<m14p2l4v2l.fsf_-_@frodo.ebiederm.org>
	<m1y6zx3gcs.fsf_-_@frodo.ebiederm.org>
	<20081105.160047.174722021.davem@davemloft.net>
	<m14p2l0zyu.fsf@frodo.ebiederm.org>
	<m1y6zwzx4r.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlezcano@fr.ibm.com, containers@lists.osdl.org, den@openvz.org,
	xemul@openvz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:36631 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbYKFPpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 10:45:22 -0500
In-Reply-To: <m1y6zwzx4r.fsf_-_@frodo.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 06 Nov 2008 07:34:28 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I was recently hunting a bug that occurred in network namespace
cleanup.  In looking at the code it became apparrent that we have
and will continue to have cases where if we have anything going
on in a network namespace there will be assumptions that the
loopback device is present.   Things like sending igmp unsubscribe
messages when we bring down network devices invokes the routing
code which assumes that at least the loopback driver is present.

Therefore to avoid magic initcall ordering hackery that is hard
to follow and hard to get right insert a call to register the
loopback device directly from net_dev_init().    This guarantes
that the loopback device is the first device registered and
the last network device to go away.

But do it carefully so we register the loopback device after
we clear dev_boot_phase.

Signed-off-by: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>
---
 drivers/net/loopback.c    |   13 ++-----------
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   22 +++++++++++++++++-----
 3 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 3b43bfd..bcc9945 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -215,17 +215,8 @@ static __net_exit void loopback_net_exit(struct net *net)
 	unregister_netdev(dev);
 }
 
-static struct pernet_operations __net_initdata loopback_net_ops = {
+/* Registered in net/core/dev.c */
+struct pernet_operations __net_initdata loopback_net_ops = {
        .init = loopback_net_init,
        .exit = loopback_net_exit,
 };
-
-static int __init loopback_init(void)
-{
-	return register_pernet_device(&loopback_net_ops);
-}
-
-/* Loopback is special. It should be initialized before any other network
- * device and network subsystem.
- */
-fs_initcall(loopback_init);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 488c56e..c7004a5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1726,6 +1726,7 @@ static inline int skb_bond_should_drop(struct sk_buff *skb)
 	return 0;
 }
 
+extern struct pernet_operations __net_initdata loopback_net_ops;
 #endif /* __KERNEL__ */
 
 #endif	/* _LINUX_DEV_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index 3785c4b..cf54670 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4824,9 +4824,6 @@ static int __init net_dev_init(void)
 	if (register_pernet_subsys(&netdev_net_ops))
 		goto out;
 
-	if (register_pernet_device(&default_device_ops))
-		goto out;
-
 	/*
 	 *	Initialise the packet receive queues.
 	 */
@@ -4843,10 +4840,25 @@ static int __init net_dev_init(void)
 		queue->backlog.weight = weight_p;
 	}
 
-	netdev_dma_register();
-
 	dev_boot_phase = 0;
 
+	/* The loopback device is special if any other network devices
+	 * is present in a network namespace the loopback device must
+	 * be present. Since we now dynamically allocate and free the
+	 * loopback device ensure this invariant is maintained by
+	 * keeping the loopback device as the first device on the
+	 * list of network devices.  Ensuring the loopback devices
+	 * is the first device that appears and the last network device
+	 * that disappears.
+	 */
+	if (register_pernet_device(&loopback_net_ops))
+		goto out;
+
+	if (register_pernet_device(&default_device_ops))
+		goto out;
+
+	netdev_dma_register();
+
 	open_softirq(NET_TX_SOFTIRQ, net_tx_action);
 	open_softirq(NET_RX_SOFTIRQ, net_rx_action);
 
-- 
1.5.6.5


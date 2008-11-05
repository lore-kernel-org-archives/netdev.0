From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/3] net: Guaranetee the proper ordering of the loopback device.
Date: Wed, 05 Nov 2008 15:25:39 -0800
Message-ID: <m1y6zx3gcs.fsf_-_@frodo.ebiederm.org>
References: <m18wt6v7eb.fsf@frodo.ebiederm.org> <48EB36FC.4000008@fr.ibm.com>
	<48EB3F72.5090201@openvz.org> <m1d4ic4pbr.fsf@frodo.ebiederm.org>
	<48ECA8D2.4090406@openvz.org> <m14p2l4v2l.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	"Denis V. Lunev" <den@openvz.org>,
	Pavel Emelyanov <xemul@openvz.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36354 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbYKEXfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 18:35:09 -0500
In-Reply-To: <m14p2l4v2l.fsf_-_@frodo.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 05 Nov 2008 15:22:26 -0800")
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

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/loopback.c    |   13 ++-----------
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   12 ++++++++++++
 3 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 91d0858..c4516b5 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -204,17 +204,8 @@ static __net_exit void loopback_net_exit(struct net *net)
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
index f1b0dbe..12d7f44 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1766,6 +1766,7 @@ static inline int skb_bond_should_drop(struct sk_buff *skb)
 	return 0;
 }
 
+extern struct pernet_operations __net_initdata loopback_net_ops;
 #endif /* __KERNEL__ */
 
 #endif	/* _LINUX_DEV_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index 9475f3e..811507c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4904,6 +4904,18 @@ static int __init net_dev_init(void)
 	if (register_pernet_subsys(&netdev_net_ops))
 		goto out;
 
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
 	if (register_pernet_device(&default_device_ops))
 		goto out;
 
-- 
1.5.6.5


From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: add knob to send unsolicited ND on link-layer address change
Date: Wed, 7 Nov 2012 03:46:20 +0100
Message-ID: <20121107024620.GD26398@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38142 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611Ab2KGCqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 21:46:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces a new knob ndisc_notify. If enabled, the kernel
will transmit an unsolicited neighbour advertisement on link-layer address
change to update the neighbour tables of the corresponding hosts more quickly.

This is the equivalent to arp_notify in ipv4 world.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/ipv6.h      | 1 +
 include/uapi/linux/ipv6.h | 1 +
 net/ipv6/addrconf.c       | 9 +++++++++
 net/ipv6/ndisc.c          | 7 +++++++
 4 files changed, 18 insertions(+)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index bcba48a..5e11905 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -47,6 +47,7 @@ struct ipv6_devconf {
 	__s32		disable_ipv6;
 	__s32		accept_dad;
 	__s32		force_tllao;
+	__s32           ndisc_notify;
 	void		*sysctl;
 };
 
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index a6d7d1c..5a2991c 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -157,6 +157,7 @@ enum {
 	DEVCONF_DISABLE_IPV6,
 	DEVCONF_ACCEPT_DAD,
 	DEVCONF_FORCE_TLLAO,
+	DEVCONF_NDISC_NOTIFY,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0424e4e..e3df4fa 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3892,6 +3892,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_DISABLE_IPV6] = cnf->disable_ipv6;
 	array[DEVCONF_ACCEPT_DAD] = cnf->accept_dad;
 	array[DEVCONF_FORCE_TLLAO] = cnf->force_tllao;
+	array[DEVCONF_NDISC_NOTIFY] = cnf->ndisc_notify;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -4560,6 +4561,14 @@ static struct addrconf_sysctl_table
 			.proc_handler   = proc_dointvec
 		},
 		{
+			.procname       = "ndisc_notify",
+			.data           = &ipv6_devconf.ndisc_notify,
+			.maxlen         = sizeof(int),
+			.mode           = 0644,
+			.proc_handler   = proc_dointvec
+			
+		},
+		{
 			/* sentinel */
 		}
 	},
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index ff36194..66d5401 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1575,11 +1575,18 @@ static int ndisc_netdev_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = ptr;
 	struct net *net = dev_net(dev);
+	struct inet6_dev *idev;
 
 	switch (event) {
 	case NETDEV_CHANGEADDR:
 		neigh_changeaddr(&nd_tbl, dev);
 		fib6_run_gc(~0UL, net);
+		idev = in6_dev_get(dev);
+		if (!idev)
+			break;
+		if (idev->cnf.ndisc_notify)
+			ndisc_send_unsol_na(dev);
+		in6_dev_put(idev);
 		break;
 	case NETDEV_DOWN:
 		neigh_ifdown(&nd_tbl, dev);

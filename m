From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [net-next-2.6 PATCH 1/2] net ipv4: Decouple ipv4 interface parameters from binary sysctl numbers
Date: Sun, 14 Feb 2010 05:25:51 -0800
Message-ID: <m1fx54kkyo.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42143 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834Ab0BNNZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 08:25:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stop using the binary sysctl enumeartion in sysctl.h as an index into
a per interface array.  This leads to unnecessary binary sysctl number
allocation, and a fragility in data structure and implementation
because of unnecessary coupling.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/inetdevice.h |   42 ++++++++++++++++++++++++++++++++++++------
 include/linux/sysctl.h     |    4 ----
 net/ipv4/devinet.c         |   26 +++++++++++++-------------
 3 files changed, 49 insertions(+), 23 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index cf25780..2be1a1a 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -10,10 +10,40 @@
 #include <linux/timer.h>
 #include <linux/sysctl.h>
 
+enum
+{
+	IPV4_DEVCONF_FORWARDING=1,
+	IPV4_DEVCONF_MC_FORWARDING,
+	IPV4_DEVCONF_PROXY_ARP,
+	IPV4_DEVCONF_ACCEPT_REDIRECTS,
+	IPV4_DEVCONF_SECURE_REDIRECTS,
+	IPV4_DEVCONF_SEND_REDIRECTS,
+	IPV4_DEVCONF_SHARED_MEDIA,
+	IPV4_DEVCONF_RP_FILTER,
+	IPV4_DEVCONF_ACCEPT_SOURCE_ROUTE,
+	IPV4_DEVCONF_BOOTP_RELAY,
+	IPV4_DEVCONF_LOG_MARTIANS,
+	IPV4_DEVCONF_TAG,
+	IPV4_DEVCONF_ARPFILTER,
+	IPV4_DEVCONF_MEDIUM_ID,
+	IPV4_DEVCONF_NOXFRM,
+	IPV4_DEVCONF_NOPOLICY,
+	IPV4_DEVCONF_FORCE_IGMP_VERSION,
+	IPV4_DEVCONF_ARP_ANNOUNCE,
+	IPV4_DEVCONF_ARP_IGNORE,
+	IPV4_DEVCONF_PROMOTE_SECONDARIES,
+	IPV4_DEVCONF_ARP_ACCEPT,
+	IPV4_DEVCONF_ARP_NOTIFY,
+	IPV4_DEVCONF_ACCEPT_LOCAL,
+	IPV4_DEVCONF_SRC_VMARK,
+	IPV4_DEVCONF_PROXY_ARP_PVLAN,
+	__IPV4_DEVCONF_MAX
+};
+
 struct ipv4_devconf {
 	void	*sysctl;
-	int	data[__NET_IPV4_CONF_MAX - 1];
-	DECLARE_BITMAP(state, __NET_IPV4_CONF_MAX - 1);
+	int	data[__IPV4_DEVCONF_MAX - 1];
+	DECLARE_BITMAP(state, __IPV4_DEVCONF_MAX - 1);
 };
 
 struct in_device {
@@ -40,7 +70,7 @@ struct in_device {
 	struct rcu_head		rcu_head;
 };
 
-#define IPV4_DEVCONF(cnf, attr) ((cnf).data[NET_IPV4_CONF_ ## attr - 1])
+#define IPV4_DEVCONF(cnf, attr) ((cnf).data[IPV4_DEVCONF_ ## attr - 1])
 #define IPV4_DEVCONF_ALL(net, attr) \
 	IPV4_DEVCONF((*(net)->ipv4.devconf_all), attr)
 
@@ -60,13 +90,13 @@ static inline void ipv4_devconf_set(struct in_device *in_dev, int index,
 
 static inline void ipv4_devconf_setall(struct in_device *in_dev)
 {
-	bitmap_fill(in_dev->cnf.state, __NET_IPV4_CONF_MAX - 1);
+	bitmap_fill(in_dev->cnf.state, __IPV4_DEVCONF_MAX - 1);
 }
 
 #define IN_DEV_CONF_GET(in_dev, attr) \
-	ipv4_devconf_get((in_dev), NET_IPV4_CONF_ ## attr)
+	ipv4_devconf_get((in_dev), IPV4_DEVCONF_ ## attr)
 #define IN_DEV_CONF_SET(in_dev, attr, val) \
-	ipv4_devconf_set((in_dev), NET_IPV4_CONF_ ## attr, (val))
+	ipv4_devconf_set((in_dev), IPV4_DEVCONF_ ## attr, (val))
 
 #define IN_DEV_ANDCONF(in_dev, attr) \
 	(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), attr) && \
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 9f236cd..7c74e91 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -481,10 +481,6 @@ enum
 	NET_IPV4_CONF_PROMOTE_SECONDARIES=20,
 	NET_IPV4_CONF_ARP_ACCEPT=21,
 	NET_IPV4_CONF_ARP_NOTIFY=22,
-	NET_IPV4_CONF_ACCEPT_LOCAL=23,
-	NET_IPV4_CONF_SRC_VMARK=24,
-	NET_IPV4_CONF_PROXY_ARP_PVLAN=25,
-	__NET_IPV4_CONF_MAX
 };
 
 /* /proc/sys/net/ipv4/netfilter */
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cd71a39..b1eddee 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -64,20 +64,20 @@
 
 static struct ipv4_devconf ipv4_devconf = {
 	.data = {
-		[NET_IPV4_CONF_ACCEPT_REDIRECTS - 1] = 1,
-		[NET_IPV4_CONF_SEND_REDIRECTS - 1] = 1,
-		[NET_IPV4_CONF_SECURE_REDIRECTS - 1] = 1,
-		[NET_IPV4_CONF_SHARED_MEDIA - 1] = 1,
+		[IPV4_DEVCONF_ACCEPT_REDIRECTS - 1] = 1,
+		[IPV4_DEVCONF_SEND_REDIRECTS - 1] = 1,
+		[IPV4_DEVCONF_SECURE_REDIRECTS - 1] = 1,
+		[IPV4_DEVCONF_SHARED_MEDIA - 1] = 1,
 	},
 };
 
 static struct ipv4_devconf ipv4_devconf_dflt = {
 	.data = {
-		[NET_IPV4_CONF_ACCEPT_REDIRECTS - 1] = 1,
-		[NET_IPV4_CONF_SEND_REDIRECTS - 1] = 1,
-		[NET_IPV4_CONF_SECURE_REDIRECTS - 1] = 1,
-		[NET_IPV4_CONF_SHARED_MEDIA - 1] = 1,
-		[NET_IPV4_CONF_ACCEPT_SOURCE_ROUTE - 1] = 1,
+		[IPV4_DEVCONF_ACCEPT_REDIRECTS - 1] = 1,
+		[IPV4_DEVCONF_SEND_REDIRECTS - 1] = 1,
+		[IPV4_DEVCONF_SECURE_REDIRECTS - 1] = 1,
+		[IPV4_DEVCONF_SHARED_MEDIA - 1] = 1,
+		[IPV4_DEVCONF_ACCEPT_SOURCE_ROUTE - 1] = 1,
 	},
 };
 
@@ -1360,7 +1360,7 @@ int ipv4_doint_and_flush(ctl_table *ctl, int write,
 	{ \
 		.procname	= name, \
 		.data		= ipv4_devconf.data + \
-				  NET_IPV4_CONF_ ## attr - 1, \
+				  IPV4_DEVCONF_ ## attr - 1, \
 		.maxlen		= sizeof(int), \
 		.mode		= mval, \
 		.proc_handler	= proc, \
@@ -1381,7 +1381,7 @@ int ipv4_doint_and_flush(ctl_table *ctl, int write,
 
 static struct devinet_sysctl_table {
 	struct ctl_table_header *sysctl_header;
-	struct ctl_table devinet_vars[__NET_IPV4_CONF_MAX];
+	struct ctl_table devinet_vars[__IPV4_DEVCONF_MAX];
 	char *dev_name;
 } devinet_sysctl = {
 	.devinet_vars = {
@@ -1503,7 +1503,7 @@ static struct ctl_table ctl_forward_entry[] = {
 	{
 		.procname	= "ip_forward",
 		.data		= &ipv4_devconf.data[
-					NET_IPV4_CONF_FORWARDING - 1],
+					IPV4_DEVCONF_FORWARDING - 1],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= devinet_sysctl_forward,
@@ -1547,7 +1547,7 @@ static __net_init int devinet_init_net(struct net *net)
 		if (tbl == NULL)
 			goto err_alloc_ctl;
 
-		tbl[0].data = &all->data[NET_IPV4_CONF_FORWARDING - 1];
+		tbl[0].data = &all->data[IPV4_DEVCONF_FORWARDING - 1];
 		tbl[0].extra1 = all;
 		tbl[0].extra2 = net;
 #endif
-- 
1.6.5.2.143.g8cc62


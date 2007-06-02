From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/4] [IPV4]: Convert IPv4 devconf to an array
Date: Sat, 2 Jun 2007 20:02:52 +1000
Message-ID: <20070602100252.GB9247@gondor.apana.org.au>
References: <20070602100132.GA9129@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4462 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755031AbXFBKCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 06:02:55 -0400
Content-Disposition: inline
In-Reply-To: <20070602100132.GA9129@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV4]: Convert IPv4 devconf to an array

This patch converts the ipv4_devconf config members (everything except
sysctl) to an array.  This allows easier manipulation which will be
needed later on to provide better management of default config values.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/infiniband/hw/amso1100/c2.c b/drivers/infiniband/hw/amso1100/c2.c
--- a/drivers/infiniband/hw/amso1100/c2.c
+++ b/drivers/infiniband/hw/amso1100/c2.c
@@ -672,7 +672,7 @@ static int c2_up(struct net_device *netd
 	 * rdma interface.
 	 */
 	in_dev = in_dev_get(netdev);
-	in_dev->cnf.arp_ignore = 1;
+	IN_DEV_CONF_SET(in_dev, ARP_IGNORE, 1);
 	in_dev_put(in_dev);
 
 	return 0;
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -10,28 +10,8 @@
 
 struct ipv4_devconf
 {
-	int	accept_redirects;
-	int	send_redirects;
-	int	secure_redirects;
-	int	shared_media;
-	int	accept_source_route;
-	int	rp_filter;
-	int	proxy_arp;
-	int	bootp_relay;
-	int	log_martians;
-	int	forwarding;
-	int	mc_forwarding;
-	int	tag;
-	int     arp_filter;
-	int	arp_announce;
-	int	arp_ignore;
-	int	arp_accept;
-	int	medium_id;
-	int	no_xfrm;
-	int	no_policy;
-	int	force_igmp_version;
-	int	promote_secondaries;
 	void	*sysctl;
+	int	data[__NET_IPV4_CONF_MAX - 1];
 };
 
 extern struct ipv4_devconf ipv4_devconf;
@@ -60,30 +40,64 @@ struct in_device
 	struct rcu_head		rcu_head;
 };
 
-#define IN_DEV_FORWARD(in_dev)		((in_dev)->cnf.forwarding)
-#define IN_DEV_MFORWARD(in_dev)		(ipv4_devconf.mc_forwarding && (in_dev)->cnf.mc_forwarding)
-#define IN_DEV_RPFILTER(in_dev)		(ipv4_devconf.rp_filter && (in_dev)->cnf.rp_filter)
-#define IN_DEV_SOURCE_ROUTE(in_dev)	(ipv4_devconf.accept_source_route && (in_dev)->cnf.accept_source_route)
-#define IN_DEV_BOOTP_RELAY(in_dev)	(ipv4_devconf.bootp_relay && (in_dev)->cnf.bootp_relay)
-
-#define IN_DEV_LOG_MARTIANS(in_dev)	(ipv4_devconf.log_martians || (in_dev)->cnf.log_martians)
-#define IN_DEV_PROXY_ARP(in_dev)	(ipv4_devconf.proxy_arp || (in_dev)->cnf.proxy_arp)
-#define IN_DEV_SHARED_MEDIA(in_dev)	(ipv4_devconf.shared_media || (in_dev)->cnf.shared_media)
-#define IN_DEV_TX_REDIRECTS(in_dev)	(ipv4_devconf.send_redirects || (in_dev)->cnf.send_redirects)
-#define IN_DEV_SEC_REDIRECTS(in_dev)	(ipv4_devconf.secure_redirects || (in_dev)->cnf.secure_redirects)
-#define IN_DEV_IDTAG(in_dev)		((in_dev)->cnf.tag)
-#define IN_DEV_MEDIUM_ID(in_dev)	((in_dev)->cnf.medium_id)
-#define IN_DEV_PROMOTE_SECONDARIES(in_dev)	(ipv4_devconf.promote_secondaries || (in_dev)->cnf.promote_secondaries)
+#define IPV4_DEVCONF(cnf, attr) ((cnf).data[NET_IPV4_CONF_ ## attr - 1])
+#define IPV4_DEVCONF_ALL(attr) IPV4_DEVCONF(ipv4_devconf, attr)
+
+static inline int ipv4_devconf_get(struct in_device *in_dev, int index)
+{
+	index--;
+	return in_dev->cnf.data[index];
+}
+
+static inline void ipv4_devconf_set(struct in_device *in_dev, int index,
+				    int val)
+{
+	index--;
+	in_dev->cnf.data[index] = val;
+}
+
+#define IN_DEV_CONF_GET(in_dev, attr) \
+	ipv4_devconf_get((in_dev), NET_IPV4_CONF_ ## attr)
+#define IN_DEV_CONF_SET(in_dev, attr, val) \
+	ipv4_devconf_set((in_dev), NET_IPV4_CONF_ ## attr, (val))
+
+#define IN_DEV_ANDCONF(in_dev, attr) \
+	(IPV4_DEVCONF_ALL(attr) && IN_DEV_CONF_GET((in_dev), attr))
+#define IN_DEV_ORCONF(in_dev, attr) \
+	(IPV4_DEVCONF_ALL(attr) || IN_DEV_CONF_GET((in_dev), attr))
+#define IN_DEV_MAXCONF(in_dev, attr) \
+	(max(IPV4_DEVCONF_ALL(attr), IN_DEV_CONF_GET((in_dev), attr)))
+
+#define IN_DEV_FORWARD(in_dev)		IN_DEV_CONF_GET((in_dev), FORWARDING)
+#define IN_DEV_MFORWARD(in_dev)		(IPV4_DEVCONF_ALL(MC_FORWARDING) && \
+					 IPV4_DEVCONF((in_dev)->cnf, \
+						      MC_FORWARDING))
+#define IN_DEV_RPFILTER(in_dev)		IN_DEV_ANDCONF((in_dev), RP_FILTER)
+#define IN_DEV_SOURCE_ROUTE(in_dev)	IN_DEV_ANDCONF((in_dev), \
+						       ACCEPT_SOURCE_ROUTE)
+#define IN_DEV_BOOTP_RELAY(in_dev)	IN_DEV_ANDCONF((in_dev), BOOTP_RELAY)
+
+#define IN_DEV_LOG_MARTIANS(in_dev)	IN_DEV_ORCONF((in_dev), LOG_MARTIANS)
+#define IN_DEV_PROXY_ARP(in_dev)	IN_DEV_ORCONF((in_dev), PROXY_ARP)
+#define IN_DEV_SHARED_MEDIA(in_dev)	IN_DEV_ORCONF((in_dev), SHARED_MEDIA)
+#define IN_DEV_TX_REDIRECTS(in_dev)	IN_DEV_ORCONF((in_dev), SEND_REDIRECTS)
+#define IN_DEV_SEC_REDIRECTS(in_dev)	IN_DEV_ORCONF((in_dev), \
+						      SECURE_REDIRECTS)
+#define IN_DEV_IDTAG(in_dev)		IN_DEV_CONF_GET(in_dev, TAG)
+#define IN_DEV_MEDIUM_ID(in_dev)	IN_DEV_CONF_GET(in_dev, MEDIUM_ID)
+#define IN_DEV_PROMOTE_SECONDARIES(in_dev) \
+					IN_DEV_ORCONF((in_dev), \
+						      PROMOTE_SECONDARIES)
 
 #define IN_DEV_RX_REDIRECTS(in_dev) \
 	((IN_DEV_FORWARD(in_dev) && \
-	  (ipv4_devconf.accept_redirects && (in_dev)->cnf.accept_redirects)) \
+	  IN_DEV_ANDCONF((in_dev), ACCEPT_REDIRECTS)) \
 	 || (!IN_DEV_FORWARD(in_dev) && \
-	  (ipv4_devconf.accept_redirects || (in_dev)->cnf.accept_redirects)))
+	  IN_DEV_ORCONF((in_dev), ACCEPT_REDIRECTS)))
 
-#define IN_DEV_ARPFILTER(in_dev)	(ipv4_devconf.arp_filter || (in_dev)->cnf.arp_filter)
-#define IN_DEV_ARP_ANNOUNCE(in_dev)	(max(ipv4_devconf.arp_announce, (in_dev)->cnf.arp_announce))
-#define IN_DEV_ARP_IGNORE(in_dev)	(max(ipv4_devconf.arp_ignore, (in_dev)->cnf.arp_ignore))
+#define IN_DEV_ARPFILTER(in_dev)	IN_DEV_ORCONF((in_dev), ARPFILTER)
+#define IN_DEV_ARP_ANNOUNCE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_ANNOUNCE)
+#define IN_DEV_ARP_IGNORE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_IGNORE)
 
 struct in_ifaddr
 {
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -877,7 +877,7 @@ static int arp_process(struct sk_buff *s
 
 	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
 
-	if (ipv4_devconf.arp_accept) {
+	if (IPV4_DEVCONF_ALL(ARP_ACCEPT)) {
 		/* Unsolicited ARP is not accepted by default.
 		   It is possible, that this option should be enabled for some
 		   devices (strip is candidate)
@@ -987,11 +987,11 @@ static int arp_req_set(struct arpreq *r,
 			return 0;
 		}
 		if (dev == NULL) {
-			ipv4_devconf.proxy_arp = 1;
+			IPV4_DEVCONF_ALL(PROXY_ARP) = 1;
 			return 0;
 		}
 		if (__in_dev_get_rtnl(dev)) {
-			__in_dev_get_rtnl(dev)->cnf.proxy_arp = 1;
+			IN_DEV_CONF_SET(__in_dev_get_rtnl(dev), PROXY_ARP, 1);
 			return 0;
 		}
 		return -ENXIO;
@@ -1093,11 +1093,12 @@ static int arp_req_delete(struct arpreq 
 			return pneigh_delete(&arp_tbl, &ip, dev);
 		if (mask == 0) {
 			if (dev == NULL) {
-				ipv4_devconf.proxy_arp = 0;
+				IPV4_DEVCONF_ALL(PROXY_ARP) = 0;
 				return 0;
 			}
 			if (__in_dev_get_rtnl(dev)) {
-				__in_dev_get_rtnl(dev)->cnf.proxy_arp = 0;
+				IN_DEV_CONF_SET(__in_dev_get_rtnl(dev),
+						PROXY_ARP, 0);
 				return 0;
 			}
 			return -ENXIO;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -64,20 +64,26 @@
 #include <net/rtnetlink.h>
 
 struct ipv4_devconf ipv4_devconf = {
-	.accept_redirects = 1,
-	.send_redirects =  1,
-	.secure_redirects = 1,
-	.shared_media =	  1,
+	.data = {
+		[NET_IPV4_CONF_ACCEPT_REDIRECTS] = 1,
+		[NET_IPV4_CONF_SEND_REDIRECTS] = 1,
+		[NET_IPV4_CONF_SECURE_REDIRECTS] = 1,
+		[NET_IPV4_CONF_SHARED_MEDIA] = 1,
+	},
 };
 
 static struct ipv4_devconf ipv4_devconf_dflt = {
-	.accept_redirects =  1,
-	.send_redirects =    1,
-	.secure_redirects =  1,
-	.shared_media =	     1,
-	.accept_source_route = 1,
+	.data = {
+		[NET_IPV4_CONF_ACCEPT_REDIRECTS] = 1,
+		[NET_IPV4_CONF_SEND_REDIRECTS] = 1,
+		[NET_IPV4_CONF_SECURE_REDIRECTS] = 1,
+		[NET_IPV4_CONF_SHARED_MEDIA] = 1,
+		[NET_IPV4_CONF_ACCEPT_SOURCE_ROUTE] = 1,
+	},
 };
 
+#define IPV4_DEVCONF_DFLT(attr) IPV4_DEVCONF(ipv4_devconf_dflt, attr)
+
 static struct nla_policy ifa_ipv4_policy[IFA_MAX+1] __read_mostly = {
 	[IFA_LOCAL]     	= { .type = NLA_U32 },
 	[IFA_ADDRESS]   	= { .type = NLA_U32 },
@@ -1061,8 +1067,8 @@ static int inetdev_event(struct notifier
 				if (!in_dev)
 					panic("devinet: "
 					      "Failed to create loopback\n");
-				in_dev->cnf.no_xfrm = 1;
-				in_dev->cnf.no_policy = 1;
+				IN_DEV_CONF_SET(in_dev, NOXFRM, 1);
+				IN_DEV_CONF_SET(in_dev, NOPOLICY, 1);
 			}
 		}
 		goto out;
@@ -1241,10 +1247,10 @@ errout:
 void inet_forward_change(void)
 {
 	struct net_device *dev;
-	int on = ipv4_devconf.forwarding;
+	int on = IPV4_DEVCONF_ALL(FORWARDING);
 
-	ipv4_devconf.accept_redirects = !on;
-	ipv4_devconf_dflt.forwarding = on;
+	IPV4_DEVCONF_ALL(ACCEPT_REDIRECTS) = !on;
+	IPV4_DEVCONF_DFLT(FORWARDING) = on;
 
 	read_lock(&dev_base_lock);
 	for_each_netdev(dev) {
@@ -1252,7 +1258,7 @@ void inet_forward_change(void)
 		rcu_read_lock();
 		in_dev = __in_dev_get_rcu(dev);
 		if (in_dev)
-			in_dev->cnf.forwarding = on;
+			IN_DEV_CONF_SET(in_dev, FORWARDING, on);
 		rcu_read_unlock();
 	}
 	read_unlock(&dev_base_lock);
@@ -1269,9 +1275,9 @@ static int devinet_sysctl_forward(ctl_ta
 	int ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
 
 	if (write && *valp != val) {
-		if (valp == &ipv4_devconf.forwarding)
+		if (valp == &IPV4_DEVCONF_ALL(FORWARDING))
 			inet_forward_change();
-		else if (valp != &ipv4_devconf_dflt.forwarding)
+		else if (valp != &IPV4_DEVCONF_DFLT(FORWARDING))
 			rt_cache_flush(0);
 	}
 
@@ -1333,6 +1339,31 @@ int ipv4_doint_and_flush_strategy(ctl_ta
 }
 
 
+#define DEVINET_SYSCTL_ENTRY(attr, name, mval, proc, sysctl) \
+	{ \
+		.ctl_name	= NET_IPV4_CONF_ ## attr, \
+		.procname	= name, \
+		.data		= ipv4_devconf.data + \
+				  NET_IPV4_CONF_ ## attr - 1, \
+		.maxlen		= sizeof(int), \
+		.mode		= mval, \
+		.proc_handler	= proc, \
+		.strategy	= sysctl, \
+	}
+
+#define DEVINET_SYSCTL_RW_ENTRY(attr, name) \
+	DEVINET_SYSCTL_ENTRY(attr, name, 0644, &proc_dointvec, NULL)
+
+#define DEVINET_SYSCTL_RO_ENTRY(attr, name) \
+	DEVINET_SYSCTL_ENTRY(attr, name, 0444, &proc_dointvec, NULL)
+
+#define DEVINET_SYSCTL_COMPLEX_ENTRY(attr, name, proc, sysctl) \
+	DEVINET_SYSCTL_ENTRY(attr, name, 0644, proc, sysctl)
+
+#define DEVINET_SYSCTL_FLUSHING_ENTRY(attr, name) \
+	DEVINET_SYSCTL_COMPLEX_ENTRY(attr, name, ipv4_doint_and_flush, \
+				     ipv4_doint_and_flush_strategy)
+
 static struct devinet_sysctl_table {
 	struct ctl_table_header *sysctl_header;
 	ctl_table		devinet_vars[__NET_IPV4_CONF_MAX];
@@ -1342,178 +1373,33 @@ static struct devinet_sysctl_table {
 	ctl_table		devinet_root_dir[2];
 } devinet_sysctl = {
 	.devinet_vars = {
-		{
-			.ctl_name	= NET_IPV4_CONF_FORWARDING,
-			.procname	= "forwarding",
-			.data		= &ipv4_devconf.forwarding,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &devinet_sysctl_forward,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_MC_FORWARDING,
-			.procname	= "mc_forwarding",
-			.data		= &ipv4_devconf.mc_forwarding,
-			.maxlen		= sizeof(int),
-			.mode		= 0444,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_ACCEPT_REDIRECTS,
-			.procname	= "accept_redirects",
-			.data		= &ipv4_devconf.accept_redirects,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_SECURE_REDIRECTS,
-			.procname	= "secure_redirects",
-			.data		= &ipv4_devconf.secure_redirects,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_SHARED_MEDIA,
-			.procname	= "shared_media",
-			.data		= &ipv4_devconf.shared_media,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_RP_FILTER,
-			.procname	= "rp_filter",
-			.data		= &ipv4_devconf.rp_filter,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_SEND_REDIRECTS,
-			.procname	= "send_redirects",
-			.data		= &ipv4_devconf.send_redirects,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_ACCEPT_SOURCE_ROUTE,
-			.procname	= "accept_source_route",
-			.data		= &ipv4_devconf.accept_source_route,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_PROXY_ARP,
-			.procname	= "proxy_arp",
-			.data		= &ipv4_devconf.proxy_arp,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_MEDIUM_ID,
-			.procname	= "medium_id",
-			.data		= &ipv4_devconf.medium_id,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_BOOTP_RELAY,
-			.procname	= "bootp_relay",
-			.data		= &ipv4_devconf.bootp_relay,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_LOG_MARTIANS,
-			.procname	= "log_martians",
-			.data		= &ipv4_devconf.log_martians,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_TAG,
-			.procname	= "tag",
-			.data		= &ipv4_devconf.tag,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_ARPFILTER,
-			.procname	= "arp_filter",
-			.data		= &ipv4_devconf.arp_filter,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_ARP_ANNOUNCE,
-			.procname	= "arp_announce",
-			.data		= &ipv4_devconf.arp_announce,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_ARP_IGNORE,
-			.procname	= "arp_ignore",
-			.data		= &ipv4_devconf.arp_ignore,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_ARP_ACCEPT,
-			.procname	= "arp_accept",
-			.data		= &ipv4_devconf.arp_accept,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_NOXFRM,
-			.procname	= "disable_xfrm",
-			.data		= &ipv4_devconf.no_xfrm,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &ipv4_doint_and_flush,
-			.strategy	= &ipv4_doint_and_flush_strategy,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_NOPOLICY,
-			.procname	= "disable_policy",
-			.data		= &ipv4_devconf.no_policy,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &ipv4_doint_and_flush,
-			.strategy	= &ipv4_doint_and_flush_strategy,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_FORCE_IGMP_VERSION,
-			.procname	= "force_igmp_version",
-			.data		= &ipv4_devconf.force_igmp_version,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &ipv4_doint_and_flush,
-			.strategy	= &ipv4_doint_and_flush_strategy,
-		},
-		{
-			.ctl_name	= NET_IPV4_CONF_PROMOTE_SECONDARIES,
-			.procname	= "promote_secondaries",
-			.data		= &ipv4_devconf.promote_secondaries,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= &ipv4_doint_and_flush,
-			.strategy	= &ipv4_doint_and_flush_strategy,
-		},
+		DEVINET_SYSCTL_COMPLEX_ENTRY(FORWARDING, "forwarding",
+					     devinet_sysctl_forward, NULL),
+		DEVINET_SYSCTL_RO_ENTRY(MC_FORWARDING, "mc_forwarding"),
+
+		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_REDIRECTS, "accept_redirects"),
+		DEVINET_SYSCTL_RW_ENTRY(SECURE_REDIRECTS, "secure_redirects"),
+		DEVINET_SYSCTL_RW_ENTRY(SHARED_MEDIA, "shared_media"),
+		DEVINET_SYSCTL_RW_ENTRY(RP_FILTER, "rp_filter"),
+		DEVINET_SYSCTL_RW_ENTRY(SEND_REDIRECTS, "send_redirects"),
+		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_SOURCE_ROUTE,
+					"accept_source_route"),
+		DEVINET_SYSCTL_RW_ENTRY(PROXY_ARP, "proxy_arp"),
+		DEVINET_SYSCTL_RW_ENTRY(MEDIUM_ID, "medium_id"),
+		DEVINET_SYSCTL_RW_ENTRY(BOOTP_RELAY, "bootp_relay"),
+		DEVINET_SYSCTL_RW_ENTRY(LOG_MARTIANS, "log_martians"),
+		DEVINET_SYSCTL_RW_ENTRY(TAG, "tag"),
+		DEVINET_SYSCTL_RW_ENTRY(ARPFILTER, "arp_filter"),
+		DEVINET_SYSCTL_RW_ENTRY(ARP_ANNOUNCE, "arp_announce"),
+		DEVINET_SYSCTL_RW_ENTRY(ARP_IGNORE, "arp_ignore"),
+		DEVINET_SYSCTL_RW_ENTRY(ARP_ACCEPT, "arp_accept"),
+
+		DEVINET_SYSCTL_FLUSHING_ENTRY(NOXFRM, "disable_xfrm"),
+		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
+		DEVINET_SYSCTL_FLUSHING_ENTRY(FORCE_IGMP_VERSION,
+					      "force_igmp_version"),
+		DEVINET_SYSCTL_FLUSHING_ENTRY(PROMOTE_SECONDARIES,
+					      "promote_secondaries"),
 	},
 	.devinet_dev = {
 		{
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -128,14 +128,16 @@
  * contradict to specs provided this delay is small enough.
  */
 
-#define IGMP_V1_SEEN(in_dev) (ipv4_devconf.force_igmp_version == 1 || \
-		(in_dev)->cnf.force_igmp_version == 1 || \
-		((in_dev)->mr_v1_seen && \
-		time_before(jiffies, (in_dev)->mr_v1_seen)))
-#define IGMP_V2_SEEN(in_dev) (ipv4_devconf.force_igmp_version == 2 || \
-		(in_dev)->cnf.force_igmp_version == 2 || \
-		((in_dev)->mr_v2_seen && \
-		time_before(jiffies, (in_dev)->mr_v2_seen)))
+#define IGMP_V1_SEEN(in_dev) \
+	(IPV4_DEVCONF_ALL(FORCE_IGMP_VERSION) == 1 || \
+	 IN_DEV_CONF_GET((in_dev), FORCE_IGMP_VERSION) == 1 || \
+	 ((in_dev)->mr_v1_seen && \
+	  time_before(jiffies, (in_dev)->mr_v1_seen)))
+#define IGMP_V2_SEEN(in_dev) \
+	(IPV4_DEVCONF_ALL(FORCE_IGMP_VERSION) == 2 || \
+	 IN_DEV_CONF_GET((in_dev), FORCE_IGMP_VERSION) == 2 || \
+	 ((in_dev)->mr_v2_seen && \
+	  time_before(jiffies, (in_dev)->mr_v2_seen)))
 
 static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im);
 static void igmpv3_del_delrec(struct in_device *in_dev, __be32 multiaddr);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -154,7 +154,7 @@ struct net_device *ipmr_new_tunnel(struc
 			in_dev = __in_dev_get_rtnl(dev);
 			if (in_dev == NULL && (in_dev = inetdev_init(dev)) == NULL)
 				goto failure;
-			in_dev->cnf.rp_filter = 0;
+			IN_DEV_CONF_SET(in_dev, RP_FILTER, 0);
 
 			if (dev_open(dev))
 				goto failure;
@@ -221,7 +221,7 @@ static struct net_device *ipmr_reg_vif(v
 	if ((in_dev = inetdev_init(dev)) == NULL)
 		goto failure;
 
-	in_dev->cnf.rp_filter = 0;
+	IN_DEV_CONF_SET(in_dev, RP_FILTER, 0);
 
 	if (dev_open(dev))
 		goto failure;
@@ -281,7 +281,7 @@ static int vif_delete(int vifi)
 	dev_set_allmulti(dev, -1);
 
 	if ((in_dev = __in_dev_get_rtnl(dev)) != NULL) {
-		in_dev->cnf.mc_forwarding--;
+		IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)--;
 		ip_rt_multicast_event(in_dev);
 	}
 
@@ -426,7 +426,7 @@ static int vif_add(struct vifctl *vifc, 
 
 	if ((in_dev = __in_dev_get_rtnl(dev)) == NULL)
 		return -EADDRNOTAVAIL;
-	in_dev->cnf.mc_forwarding++;
+	IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)++;
 	dev_set_allmulti(dev, +1);
 	ip_rt_multicast_event(in_dev);
 
@@ -841,7 +841,7 @@ static void mrtsock_destruct(struct sock
 {
 	rtnl_lock();
 	if (sk == mroute_socket) {
-		ipv4_devconf.mc_forwarding--;
+		IPV4_DEVCONF_ALL(MC_FORWARDING)--;
 
 		write_lock_bh(&mrt_lock);
 		mroute_socket=NULL;
@@ -890,7 +890,7 @@ int ip_mroute_setsockopt(struct sock *sk
 			mroute_socket=sk;
 			write_unlock_bh(&mrt_lock);
 
-			ipv4_devconf.mc_forwarding++;
+			IPV4_DEVCONF_ALL(MC_FORWARDING)++;
 		}
 		rtnl_unlock();
 		return ret;
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -260,7 +260,7 @@ static int snmp_seq_show(struct seq_file
 		seq_printf(seq, " %s", snmp4_ipstats_list[i].name);
 
 	seq_printf(seq, "\nIp: %d %d",
-			ipv4_devconf.forwarding ? 1 : 2, sysctl_ip_default_ttl);
+		   IPV4_DEVCONF_ALL(FORWARDING) ? 1 : 2, sysctl_ip_default_ttl);
 
 	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1636,7 +1636,7 @@ static int ip_route_input_mc(struct sk_b
 
 	atomic_set(&rth->u.dst.__refcnt, 1);
 	rth->u.dst.flags= DST_HOST;
-	if (in_dev->cnf.no_policy)
+	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
 		rth->u.dst.flags |= DST_NOPOLICY;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
@@ -1778,9 +1778,9 @@ static inline int __mkroute_input(struct
 	if (res->fi->fib_nhs > 1)
 		rth->u.dst.flags |= DST_BALANCED;
 #endif
-	if (in_dev->cnf.no_policy)
+	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
 		rth->u.dst.flags |= DST_NOPOLICY;
-	if (out_dev->cnf.no_xfrm)
+	if (IN_DEV_CONF_GET(out_dev, NOXFRM))
 		rth->u.dst.flags |= DST_NOXFRM;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
@@ -2021,7 +2021,7 @@ local_input:
 
 	atomic_set(&rth->u.dst.__refcnt, 1);
 	rth->u.dst.flags= DST_HOST;
-	if (in_dev->cnf.no_policy)
+	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
 		rth->u.dst.flags |= DST_NOPOLICY;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
@@ -2218,9 +2218,9 @@ static inline int __mkroute_output(struc
 			rth->u.dst.flags |= DST_BALANCED;
 	}
 #endif
-	if (in_dev->cnf.no_xfrm)
+	if (IN_DEV_CONF_GET(in_dev, NOXFRM))
 		rth->u.dst.flags |= DST_NOXFRM;
-	if (in_dev->cnf.no_policy)
+	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
 		rth->u.dst.flags |= DST_NOPOLICY;
 
 	rth->fl.fl4_dst	= oldflp->fl4_dst;
@@ -2759,7 +2759,7 @@ static int rt_fill_info(struct sk_buff *
 		__be32 dst = rt->rt_dst;
 
 		if (MULTICAST(dst) && !LOCAL_MCAST(dst) &&
-		    ipv4_devconf.mc_forwarding) {
+		    IPV4_DEVCONF_ALL(MC_FORWARDING)) {
 			int err = ipmr_get_route(skb, r, nowait);
 			if (err <= 0) {
 				if (!nowait) {
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -37,12 +37,12 @@ static
 int ipv4_sysctl_forward(ctl_table *ctl, int write, struct file * filp,
 			void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	int val = ipv4_devconf.forwarding;
+	int val = IPV4_DEVCONF_ALL(FORWARDING);
 	int ret;
 
 	ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
 
-	if (write && ipv4_devconf.forwarding != val)
+	if (write && IPV4_DEVCONF_ALL(FORWARDING) != val)
 		inet_forward_change();
 
 	return ret;
@@ -222,7 +222,7 @@ ctl_table ipv4_table[] = {
 	{
 		.ctl_name	= NET_IPV4_FORWARD,
 		.procname	= "ip_forward",
-		.data		= &ipv4_devconf.forwarding,
+		.data		= &IPV4_DEVCONF_ALL(FORWARDING),
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &ipv4_sysctl_forward,

From: Julian Anastasov <ja@ssi.bg>
Subject: Restrict local IP announcements in ARP requests
Date: Sun, 8 Feb 2004 11:59:35 +0200 (EET)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.58.0402081149001.6268@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	I'm opening again the discussion about src IP selection
in ARP requests. We know that there are tools and framework for
ARP filtering and mangling. The question is whether we need a
simple interface flag to restrict the local src IP address for cases
where the target hosts require sender to be from same known logical
subnet due to [wrong] policy or topology reasons.

	I'm proposing simple flag that controls the src selection
in our ARP requests. I named it arp_announce - mode used to define
different restriction levels for announcing the local source address
from IP packets in ARP requests:

0 - the current behavior: use any local address if possible

	as it appears it is not the most safe mode in some cases

1 - restrict saddr to the target's subnet

	this behavior is useful in setups where the target hosts
	have [sometimes default] policy to drop incoming requests by
	checking the src IP. The result is that we can announce
	only addresses from same logical subnet as the target.

2 - always use the best source address for this target

	This is the most restrictive mode that expects answer
	from the target host. In this case we can announce only
	preferred/primary IP address. Useful for setups where we
	do not want to announce secondary IPs, for example, if
	they are shared from many hosts.

Draft version can be found here:

http://www.ssi.bg/~ja/#arp_announce

and it is also appended here. Comments?

Regards

--
Julian Anastasov <ja@ssi.bg>

diff -ur v2.6.2/linux/Documentation/networking/ip-sysctl.txt linux/Documentation/networking/ip-sysctl.txt
--- v2.6.2/linux/Documentation/networking/ip-sysctl.txt	2004-02-05 00:23:10.000000000 +0200
+++ linux/Documentation/networking/ip-sysctl.txt	2004-02-08 11:35:04.617310560 +0200
@@ -486,6 +486,21 @@
 	conf/{all,interface}/arp_filter is set to TRUE,
 	it will be disabled otherwise
 
+arp_announce - INTEGER
+	Define different restriction levels for announcing the local
+	source IP address from IP packets in ARP requests sent on
+	interface:
+	0 - (default) Use any local address, configured on any interface
+	1 - Try to avoid local addresses that are not in the target's
+	subnet for this interface
+	2 - Always use the best source address for this target
+
+	The max value from conf/{all,interface}/arp_announce is used.
+
+	Increasing the restriction level gives more chance for
+	receiving answer from the resolved target while decreasing
+	the level announces more valid sender's information.
+
 tag - INTEGER
 	Allows you to write a number, which can be used as required.
 	Default value is 0.
diff -ur v2.6.2/linux/include/linux/inetdevice.h linux/include/linux/inetdevice.h
--- v2.6.2/linux/include/linux/inetdevice.h	2003-08-23 19:42:33.000000000 +0300
+++ linux/include/linux/inetdevice.h	2004-02-07 17:57:38.000000000 +0200
@@ -18,6 +18,7 @@
 	int	mc_forwarding;
 	int	tag;
 	int     arp_filter;
+	int	arp_announce;
 	int	medium_id;
 	int	no_xfrm;
 	int	no_policy;
@@ -70,6 +71,7 @@
 	  (ipv4_devconf.accept_redirects || (in_dev)->cnf.accept_redirects)))
 
 #define IN_DEV_ARPFILTER(in_dev)	(ipv4_devconf.arp_filter || (in_dev)->cnf.arp_filter)
+#define IN_DEV_ARP_ANNOUNCE(in_dev)	(max(ipv4_devconf.arp_announce, (in_dev)->cnf.arp_announce))
 
 struct in_ifaddr
 {
diff -ur v2.6.2/linux/include/linux/sysctl.h linux/include/linux/sysctl.h
--- v2.6.2/linux/include/linux/sysctl.h	2004-02-05 00:23:17.000000000 +0200
+++ linux/include/linux/sysctl.h	2004-02-07 18:01:58.000000000 +0200
@@ -360,6 +360,7 @@
 	NET_IPV4_CONF_MEDIUM_ID=14,
 	NET_IPV4_CONF_NOXFRM=15,
 	NET_IPV4_CONF_NOPOLICY=16,
+	NET_IPV4_CONF_ARP_ANNOUNCE=17,
 };
 
 /* /proc/sys/net/ipv4/netfilter */
diff -ur v2.6.2/linux/net/ipv4/arp.c linux/net/ipv4/arp.c
--- v2.6.2/linux/net/ipv4/arp.c	2004-02-05 00:23:18.000000000 +0200
+++ linux/net/ipv4/arp.c	2004-02-08 11:37:24.551037400 +0200
@@ -321,15 +321,57 @@
 
 static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 {
-	u32 saddr;
+	u32 saddr = 0;
 	u8  *dst_ha = NULL;
 	struct net_device *dev = neigh->dev;
 	u32 target = *(u32*)neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
+	struct rtable *rt;
+	struct in_device *in_dev = in_dev_get(dev);
 
-	if (skb && inet_addr_type(skb->nh.iph->saddr) == RTN_LOCAL)
+	if (!in_dev)
+		return;
+
+	switch (IN_DEV_ARP_ANNOUNCE(in_dev)) {
+	default:
+	case 0:		/* By default announce any local IP */
+		if (skb && inet_addr_type(skb->nh.iph->saddr) == RTN_LOCAL)
+			saddr = skb->nh.iph->saddr;
+		break;
+	case 1:		/* Restrict announcements of saddr in same subnet */
+		if (!skb || !(rt = (struct rtable *) skb->dst) || rt->fl.iif)
+			break;
 		saddr = skb->nh.iph->saddr;
-	else
+		/* rt_src is always a local address */
+		if (saddr == rt->rt_src || inet_addr_type(saddr) == RTN_LOCAL) {
+			/* saddr should be known to target */
+			if (inet_addr_onlink(in_dev, target, saddr))
+				break;
+		}
+		saddr = 0;
+		break;
+	case 2:		/* Avoid secondary IPs, get a primary/preferred one */
+#if 0
+		{
+			struct flowi fl = {
+				.nl_u = { .ip4_u = { .daddr = target } },
+				.oif = dev->ifindex };
+
+			in_dev_put(in_dev);
+			in_dev = NULL;
+			if (ip_route_output_key(&rt, &fl) < 0)
+				return;
+			saddr = rt->rt_src;
+			ip_rt_put(rt);
+		}
+#endif
+
+		break;
+	}
+
+	if (in_dev)
+		in_dev_put(in_dev);
+	if (!saddr)
 		saddr = inet_select_addr(dev, target, RT_SCOPE_LINK);
 
 	if ((probes -= neigh->parms->ucast_probes) < 0) {
diff -ur v2.6.2/linux/net/ipv4/devinet.c linux/net/ipv4/devinet.c
--- v2.6.2/linux/net/ipv4/devinet.c	2004-02-05 00:23:18.000000000 +0200
+++ linux/net/ipv4/devinet.c	2004-02-07 18:03:04.000000000 +0200
@@ -1132,7 +1132,7 @@
 
 static struct devinet_sysctl_table {
 	struct ctl_table_header *sysctl_header;
-	ctl_table		devinet_vars[17];
+	ctl_table		devinet_vars[18];
 	ctl_table		devinet_dev[2];
 	ctl_table		devinet_conf_dir[2];
 	ctl_table		devinet_proto_dir[2];
@@ -1252,6 +1252,14 @@
 			.proc_handler	= &proc_dointvec,
 		},
 		{
+			.ctl_name	= NET_IPV4_CONF_ARP_ANNOUNCE,
+			.procname	= "arp_announce",
+			.data		= &ipv4_devconf.arp_announce,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= &proc_dointvec,
+		},
+		{
 			.ctl_name	= NET_IPV4_CONF_NOXFRM,
 			.procname	= "disable_xfrm",
 			.data		= &ipv4_devconf.no_xfrm,

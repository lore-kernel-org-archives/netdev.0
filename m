From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Restrict local IP announcements in ARP requests
Date: Sun, 15 Feb 2004 12:04:59 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402151153450.1129@u.domain.uli>
References: <Pine.LNX.4.58.0402081149001.6268@u.domain.uli>
 <20040209140853.69ab8bea.davem@redhat.com> <Pine.LNX.4.58.0402100049470.1251@u.domain.uli>
 <20040209151053.1f63937a.davem@redhat.com> <Pine.LNX.4.58.0402100154010.1251@u.domain.uli>
 <20040211202251.7b05102c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040211202251.7b05102c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 11 Feb 2004, David S. Miller wrote:

> The hidden patch does a hundred different things, that's what makes
> it so undigestable. :)
>
> Let us assume your arp_announce patch is applied.  Given that, plus the
> things you've mentioned, only a tiny piece of functionality is
> really needed from that hidden patch.
>
> Why don't you extract out just the needed part, and toss together
> an email with that patch explaining that specific behavior change?

	Appended is a patch for rich set of modes to ignore ARP
requests (yes Dave, I got your flag name :)). It is on top of the
arp_announce change. I hope, the main useful needs are represented,
all other modes belong to user space tools.

	As for the IPVS like setups they have two choices to use
arp_ignore combined with arp_announce:

- to define virtual IPs on different interface and to use
arp_ignore=1/2 and arp_announce=2

- or to use scope host IP addresses and to use arp_ignore=3 and
arp_announce=2. Such addresses can be used as preferred source
addresses in routes to talk with any remote host and at the same
time we achieve per IP filtering. By this way applications that
are not aware they are load balanced can use hidden addresses on
ARP devices if they need these addresses there.

	As for the performance, modes 1, 2 and 3 are slow, they
lookup for local IP addresses on one (mode 1 and 2) or all
interfaces (mode 3).

	The same patch is also here:

http://www.ssi.bg/~ja/tmp/arp_ignore-2.6.2-arp-1.diff

Regards

--
Julian Anastasov <ja@ssi.bg>

diff -ur v2.6.2-bk/linux/Documentation/networking/ip-sysctl.txt linux/Documentation/networking/ip-sysctl.txt
--- v2.6.2-bk/linux/Documentation/networking/ip-sysctl.txt	2004-02-14 14:12:55.000000000 +0200
+++ linux/Documentation/networking/ip-sysctl.txt	2004-02-14 23:06:40.000000000 +0200
@@ -530,6 +530,24 @@
 	receiving answer from the resolved target while decreasing
 	the level announces more valid sender's information.
 
+arp_ignore - INTEGER
+	Define different modes for sending replies in response to
+	received ARP requests that resolve local target IP addresses:
+	0 - (default): reply for any local target IP address, configured
+	on any interface
+	1 - reply only if the target IP address is local address
+	configured on the incoming interface
+	2 - reply only if the target IP address is local address
+	configured on the incoming interface and both with the
+	sender's IP address are part from same subnet on this interface
+	3 - do not reply for local addresses configured with scope host,
+	only resolutions for global and link addresses are replied
+	4-7 - reserved
+	8 - do not reply for all local addresses
+
+	The max value from conf/{all,interface}/arp_ignore is used
+	when ARP request is received on the {interface}
+
 tag - INTEGER
 	Allows you to write a number, which can be used as required.
 	Default value is 0.
diff -ur v2.6.2-bk/linux/include/linux/inetdevice.h linux/include/linux/inetdevice.h
--- v2.6.2-bk/linux/include/linux/inetdevice.h	2004-02-14 14:12:55.000000000 +0200
+++ linux/include/linux/inetdevice.h	2004-02-14 23:38:56.000000000 +0200
@@ -19,6 +19,7 @@
 	int	tag;
 	int     arp_filter;
 	int	arp_announce;
+	int	arp_ignore;
 	int	medium_id;
 	int	no_xfrm;
 	int	no_policy;
@@ -73,6 +74,7 @@
 
 #define IN_DEV_ARPFILTER(in_dev)	(ipv4_devconf.arp_filter || (in_dev)->cnf.arp_filter)
 #define IN_DEV_ARP_ANNOUNCE(in_dev)	(max(ipv4_devconf.arp_announce, (in_dev)->cnf.arp_announce))
+#define IN_DEV_ARP_IGNORE(in_dev)	(max(ipv4_devconf.arp_ignore, (in_dev)->cnf.arp_ignore))
 
 struct in_ifaddr
 {
@@ -99,6 +101,7 @@
 extern struct in_device *inetdev_init(struct net_device *dev);
 extern struct in_device	*inetdev_by_index(int);
 extern u32		inet_select_addr(const struct net_device *dev, u32 dst, int scope);
+extern u32		inet_confirm_addr(const struct net_device *dev, u32 dst, u32 local, int scope);
 extern struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, u32 prefix, u32 mask);
 extern void		inet_forward_change(void);
 
diff -ur v2.6.2-bk/linux/include/linux/sysctl.h linux/include/linux/sysctl.h
--- v2.6.2-bk/linux/include/linux/sysctl.h	2004-02-14 14:12:55.000000000 +0200
+++ linux/include/linux/sysctl.h	2004-02-14 23:40:12.000000000 +0200
@@ -363,6 +363,7 @@
 	NET_IPV4_CONF_NOPOLICY=16,
 	NET_IPV4_CONF_FORCE_IGMP_VERSION=17,
 	NET_IPV4_CONF_ARP_ANNOUNCE=18,
+	NET_IPV4_CONF_ARP_IGNORE=19,
 };
 
 /* /proc/sys/net/ipv4/netfilter */
diff -ur v2.6.2-bk/linux/net/ipv4/arp.c linux/net/ipv4/arp.c
--- v2.6.2-bk/linux/net/ipv4/arp.c	2004-02-14 14:12:55.000000000 +0200
+++ linux/net/ipv4/arp.c	2004-02-15 01:19:37.000000000 +0200
@@ -379,6 +379,42 @@
 		read_unlock_bh(&neigh->lock);
 }
 
+static int arp_ignore(struct in_device *in_dev, struct net_device *dev,
+		      u32 sip, u32 tip)
+{
+	int scope;
+
+	switch (IN_DEV_ARP_IGNORE(in_dev)) {
+	case 0:	/* Reply, the tip is already validated */
+		return 0;
+	case 1:	/* Reply only if tip is configured on the incoming interface */
+		sip = 0;
+		scope = RT_SCOPE_HOST;
+		break;
+	case 2:	/*
+		 * Reply only if tip is configured on the incoming interface
+		 * and is in same subnet as sip
+		 */
+		scope = RT_SCOPE_HOST;
+		break;
+	case 3:	/* Do not reply for scope host addresses */
+		sip = 0;
+		scope = RT_SCOPE_LINK;
+		dev = NULL;
+		break;
+	case 4:	/* Reserved */
+	case 5:
+	case 6:
+	case 7:
+		return 0;
+	case 8:	/* Do not reply */
+		return 1;
+	default:
+		return 0;
+	}
+	return !inet_confirm_addr(dev, sip, tip, scope);
+}
+
 static int arp_filter(__u32 sip, __u32 tip, struct net_device *dev)
 {
 	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = sip,
@@ -789,7 +825,8 @@
 	/* Special case: IPv4 duplicate address detection packet (RFC2131) */
 	if (sip == 0) {
 		if (arp->ar_op == htons(ARPOP_REQUEST) &&
-		    inet_addr_type(tip) == RTN_LOCAL)
+		    inet_addr_type(tip) == RTN_LOCAL &&
+		    !arp_ignore(in_dev,dev,sip,tip))
 			arp_send(ARPOP_REPLY,ETH_P_ARP,tip,dev,tip,sha,dev->dev_addr,dev->dev_addr);
 		goto out;
 	}
@@ -804,7 +841,10 @@
 			n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
 			if (n) {
 				int dont_send = 0;
-				if (IN_DEV_ARPFILTER(in_dev))
+
+				if (!dont_send)
+					dont_send |= arp_ignore(in_dev,dev,sip,tip);
+				if (!dont_send && IN_DEV_ARPFILTER(in_dev))
 					dont_send |= arp_filter(sip,tip,dev); 
 				if (!dont_send)
 					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
diff -ur v2.6.2-bk/linux/net/ipv4/devinet.c linux/net/ipv4/devinet.c
--- v2.6.2-bk/linux/net/ipv4/devinet.c	2004-02-14 14:12:55.000000000 +0200
+++ linux/net/ipv4/devinet.c	2004-02-15 11:46:20.380681736 +0200
@@ -809,6 +809,84 @@
 	goto out;
 }
 
+static u32 confirm_addr_indev(struct in_device *in_dev, u32 dst,
+			      u32 local, int scope)
+{
+	int same = 0;
+	u32 addr = 0;
+
+	for_ifa(in_dev) {
+		if (!addr &&
+		    (local == ifa->ifa_local || !local) &&
+		    ifa->ifa_scope <= scope) {
+			addr = ifa->ifa_local;
+			if (same)
+				break;
+		}
+		if (!same) {
+			same = (!local || inet_ifa_match(local, ifa)) &&
+				(!dst || inet_ifa_match(dst, ifa));
+			if (same && addr) {
+				if (local || !dst)
+					break;
+				/* Is the selected addr into dst subnet? */
+				if (inet_ifa_match(addr, ifa))
+					break;
+				/* No, then can we use new local src? */
+				if (ifa->ifa_scope <= scope) {
+					addr = ifa->ifa_local;
+					break;
+				}
+				/* search for large dst subnet for addr */
+				same = 0;
+			}
+		}
+	} endfor_ifa(in_dev);
+
+	return same? addr : 0;
+}
+
+/*
+ * Confirm that local IP address exists using wildcards:
+ * - dev: only on this interface, 0=any interface
+ * - dst: only in the same subnet as dst, 0=any dst
+ * - local: address, 0=autoselect the local address
+ * - scope: maximum allowed scope value for the local address
+ */
+u32 inet_confirm_addr(const struct net_device *dev, u32 dst, u32 local, int scope)
+{
+	u32 addr = 0;
+	struct in_device *in_dev;
+
+	if (dev) {
+		read_lock(&inetdev_lock);
+		if ((in_dev = __in_dev_get(dev))) {
+			read_lock(&in_dev->lock);
+			addr = confirm_addr_indev(in_dev, dst, local, scope);
+			read_unlock(&in_dev->lock);
+		}
+		read_unlock(&inetdev_lock);
+
+		return addr;
+	}
+
+	read_lock(&dev_base_lock);
+	read_lock(&inetdev_lock);
+	for (dev = dev_base; dev; dev = dev->next) {
+		if ((in_dev = __in_dev_get(dev))) {
+			read_lock(&in_dev->lock);
+			addr = confirm_addr_indev(in_dev, dst, local, scope);
+			read_unlock(&in_dev->lock);
+			if (addr)
+				break;
+		}
+	}
+	read_unlock(&inetdev_lock);
+	read_unlock(&dev_base_lock);
+
+	return addr;
+}
+
 /*
  *	Device notifier
  */
@@ -1132,7 +1210,7 @@
 
 static struct devinet_sysctl_table {
 	struct ctl_table_header *sysctl_header;
-	ctl_table		devinet_vars[19];
+	ctl_table		devinet_vars[20];
 	ctl_table		devinet_dev[2];
 	ctl_table		devinet_conf_dir[2];
 	ctl_table		devinet_proto_dir[2];
@@ -1260,6 +1338,14 @@
 			.proc_handler	= &proc_dointvec,
 		},
 		{
+			.ctl_name	= NET_IPV4_CONF_ARP_IGNORE,
+			.procname	= "arp_ignore",
+			.data		= &ipv4_devconf.arp_ignore,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= &proc_dointvec,
+		},
+		{
 			.ctl_name	= NET_IPV4_CONF_NOXFRM,
 			.procname	= "disable_xfrm",
 			.data		= &ipv4_devconf.no_xfrm,

From: Anton Blanchard <anton@samba.org>
Subject: send to self patch
Date: Fri, 29 Aug 2003 03:48:59 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030828174859.GG12541@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

Here in the lab we often want to send TCP/IP data out over looped back
networks. We do have tools to send and receive raw packets but sometimes
thats not enough.

eg When running netperf, you dont always need two machines. If you are
just trying to stress a box (eg to find a bug like the NAPI one we hit a
week or two ago) then running loopback is fine.

We also have exercisers that run over TCP/IP and checksum sent data vs
received data.

I stumbled upon a patch by Julian Anastasov, and have found it works well.
Is there any chance of getting this (or something like it) into 2.6?

http://www.ssi.bg/~ja/#loop

Anton

diff -ur v2.5.73/linux/Documentation/filesystems/proc.txt linux/Documentation/filesystems/proc.txt
--- v2.5.73/linux/Documentation/filesystems/proc.txt	Sun Jun 15 10:23:55 2003
+++ linux/Documentation/filesystems/proc.txt	Tue Jul  1 23:29:02 2003
@@ -1502,6 +1502,15 @@
 
 Log packets with source addresses with no known route to kernel log.
 
+loop 
+----
+
+By default (loop=0) the traffic between local IP addresses
+is routed via interface "lo". Setting this flag for two
+interfaces allows traffic between their IP addresses to
+be looped externally. This is useful for setups where the
+interfaces are attached to same broadcast medium.
+
 mc_forwarding
 -------------
 
diff -ur v2.5.73/linux/Documentation/networking/ip-sysctl.txt linux/Documentation/networking/ip-sysctl.txt
--- v2.5.73/linux/Documentation/networking/ip-sysctl.txt	Sun Jun 15 10:23:56 2003
+++ linux/Documentation/networking/ip-sysctl.txt	Tue Jul  1 23:27:02 2003
@@ -390,6 +390,13 @@
 forwarding - BOOLEAN
 	Enable IP forwarding on this interface.
 
+loop - BOOLEAN
+	By default (loop=0) the traffic between local IP addresses
+	is routed via interface "lo". Setting this flag for two
+	interfaces allows traffic between their IP addresses to
+	be looped externally. This is useful for setups where the
+	interfaces are attached to same broadcast medium.
+
 mc_forwarding - BOOLEAN
 	Do multicast routing. The kernel needs to be compiled with CONFIG_MROUTE
 	and a multicast routing daemon is required.
diff -ur v2.5.73/linux/include/linux/inetdevice.h linux/include/linux/inetdevice.h
--- v2.5.73/linux/include/linux/inetdevice.h	Sun Apr 20 11:02:16 2003
+++ linux/include/linux/inetdevice.h	Mon Jun 30 23:46:20 2003
@@ -21,6 +21,7 @@
 	int	medium_id;
 	int	no_xfrm;
 	int	no_policy;
+	int	loop;
 	void	*sysctl;
 };
 
@@ -70,6 +71,7 @@
 	  (ipv4_devconf.accept_redirects || (in_dev)->cnf.accept_redirects)))
 
 #define IN_DEV_ARPFILTER(in_dev)	(ipv4_devconf.arp_filter || (in_dev)->cnf.arp_filter)
+#define IN_DEV_LOOP(in_dev)		((in_dev)->cnf.loop)
 
 struct in_ifaddr
 {
diff -ur v2.5.73/linux/include/linux/sysctl.h linux/include/linux/sysctl.h
--- v2.5.73/linux/include/linux/sysctl.h	Sun Jun 15 10:25:03 2003
+++ linux/include/linux/sysctl.h	Mon Jun 30 23:47:14 2003
@@ -359,6 +359,7 @@
 	NET_IPV4_CONF_MEDIUM_ID=14,
 	NET_IPV4_CONF_NOXFRM=15,
 	NET_IPV4_CONF_NOPOLICY=16,
+	NET_IPV4_CONF_LOOP=17,
 };
 
 /* /proc/sys/net/ipv6 */
diff -ur v2.5.73/linux/net/ipv4/devinet.c linux/net/ipv4/devinet.c
--- v2.5.73/linux/net/ipv4/devinet.c	Sun Jun 15 10:25:07 2003
+++ linux/net/ipv4/devinet.c	Mon Jun 30 23:49:26 2003
@@ -1122,7 +1122,7 @@
 
 static struct devinet_sysctl_table {
 	struct ctl_table_header *sysctl_header;
-	ctl_table		devinet_vars[17];
+	ctl_table		devinet_vars[18];
 	ctl_table		devinet_dev[2];
 	ctl_table		devinet_conf_dir[2];
 	ctl_table		devinet_proto_dir[2];
@@ -1258,6 +1258,14 @@
 			.mode		= 0644,
 			.proc_handler	= &ipv4_doint_and_flush,
 			.strategy	= &ipv4_doint_and_flush_strategy,
+		},
+		{
+			.ctl_name	= NET_IPV4_CONF_LOOP,
+			.procname	= "loop",
+			.data		= &ipv4_devconf.loop,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= &proc_dointvec,
 		},
 	},
 	.devinet_dev = {
diff -ur v2.5.73/linux/net/ipv4/fib_frontend.c linux/net/ipv4/fib_frontend.c
--- v2.5.73/linux/net/ipv4/fib_frontend.c	Wed May 28 00:02:50 2003
+++ linux/net/ipv4/fib_frontend.c	Mon Jun 30 23:52:38 2003
@@ -167,15 +167,16 @@
 					.tos = tos } },
 			    .iif = oif };
 	struct fib_result res;
-	int no_addr, rpf;
+	int no_addr, rpf, loop;
 	int ret;
 
-	no_addr = rpf = 0;
+	no_addr = rpf = loop = 0;
 	read_lock(&inetdev_lock);
 	in_dev = __in_dev_get(dev);
 	if (in_dev) {
 		no_addr = in_dev->ifa_list == NULL;
 		rpf = IN_DEV_RPFILTER(in_dev);
+		loop = IN_DEV_LOOP(in_dev);
 	}
 	read_unlock(&inetdev_lock);
 
@@ -184,6 +185,11 @@
 
 	if (fib_lookup(&fl, &res))
 		goto last_resort;
+	if (loop && res.type == RTN_LOCAL) {
+		*spec_dst = FIB_RES_PREFSRC(res);
+		fib_res_put(&res);
+		return 0;
+	}
 	if (res.type != RTN_UNICAST)
 		goto e_inval_res;
 	*spec_dst = FIB_RES_PREFSRC(res);
diff -ur v2.5.73/linux/net/ipv4/route.c linux/net/ipv4/route.c
--- v2.5.73/linux/net/ipv4/route.c	Tue Jun 17 21:39:39 2003
+++ linux/net/ipv4/route.c	Tue Jul  1 00:29:05 2003
@@ -1967,6 +1967,11 @@
 			dev_put(dev_out);
 			goto out;	/* Wrong error code */
 		}
+		err = -ENETDOWN;
+		if (!(dev_out->flags&IFF_UP)) {
+			dev_put(dev_out);
+			goto out;
+		}
 
 		if (LOCAL_MCAST(oldflp->fl4_dst) || oldflp->fl4_dst == 0xFFFFFFFF) {
 			if (!fl.fl4_src)
@@ -2036,10 +2041,41 @@
 		goto e_inval;
 
 	if (res.type == RTN_LOCAL) {
-		if (!fl.fl4_src)
-			fl.fl4_src = fl.fl4_dst;
+		struct in_device *in_dev;
+		u32 src;
+
 		if (dev_out)
 			dev_put(dev_out);
+		dev_out = FIB_RES_DEV(res);
+		in_dev = in_dev_get(dev_out);
+		src = fl.fl4_src? : FIB_RES_PREFSRC(res);
+		if (in_dev && IN_DEV_LOOP(in_dev) && src) {
+			struct net_device *dev_src;
+
+			in_dev_put(in_dev);
+			in_dev = NULL;
+			dev_src = ip_dev_find(src);
+			if (dev_src && dev_src != dev_out &&
+			    (in_dev = in_dev_get(dev_src)) &&
+			    IN_DEV_LOOP(in_dev)) {
+				in_dev_put(in_dev);
+				dev_out = dev_src;
+				fl.fl4_src = src;
+				fl.oif = dev_out->ifindex;
+				res.type = RTN_UNICAST;
+				if (res.fi) {
+					fib_info_put(res.fi);
+					res.fi = NULL;
+				}
+				goto make_route;
+			}
+			if (dev_src)
+				dev_put(dev_src);
+		}
+		if (in_dev)
+			in_dev_put(in_dev);
+		if (!fl.fl4_src)
+			fl.fl4_src = fl.fl4_dst;
 		dev_out = &loopback_dev;
 		dev_hold(dev_out);
 		fl.oif = dev_out->ifindex;

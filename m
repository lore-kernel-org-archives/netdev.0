From: Ben Greear <greearb@candelatech.com>
Subject: RFC:  Support send-to-self over external interfaces (and veths).
Date: Fri, 08 Jun 2007 17:00:01 -0700
Message-ID: <4669ED81.8060800@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080603010100070704090802"
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:50997 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937265AbXFIAAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 20:00:07 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id l59002Tb008569
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 17:00:04 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080603010100070704090802
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This should also be useful with the pending 'veth' driver, as it
emulates two ethernet ports connected with a cross-over cable.

To make this work, you have to enable the sysctl (look Dave,
no IOCTLS, there might be hope for me yet!! :)), and in your
application you will need to use SO_BINDTODEVICE (and probably bind to
the local IP as well).  Some applications such as traceroute already
support this binding..others such as ping do not.

You most likely will also have to set up routing tables using
source IPs as a rule to direct these connections to a particular
routing table.

Comments welcome.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------080603010100070704090802
Content-Type: text/x-patch;
 name="sts.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sts.patch"

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index c0f7aec..88f78b6 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -31,6 +31,7 @@ struct ipv4_devconf
 	int	no_policy;
 	int	force_igmp_version;
 	int	promote_secondaries;
+	int	accept_sts;
 	void	*sysctl;
 };
 
@@ -84,6 +85,7 @@ struct in_device
 #define IN_DEV_ARPFILTER(in_dev)	(ipv4_devconf.arp_filter || (in_dev)->cnf.arp_filter)
 #define IN_DEV_ARP_ANNOUNCE(in_dev)	(max(ipv4_devconf.arp_announce, (in_dev)->cnf.arp_announce))
 #define IN_DEV_ARP_IGNORE(in_dev)	(max(ipv4_devconf.arp_ignore, (in_dev)->cnf.arp_ignore))
+#define IN_DEV_ACCEPT_STS(in_dev)      (max(ipv4_devconf.accept_sts, (in_dev)->cnf.accept_sts))
 
 struct in_ifaddr
 {
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 47f1c53..6c00bf4 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -496,6 +496,7 @@ enum
 	NET_IPV4_CONF_ARP_IGNORE=19,
 	NET_IPV4_CONF_PROMOTE_SECONDARIES=20,
 	NET_IPV4_CONF_ARP_ACCEPT=21,
+	NET_IPV4_CONF_ACCEPT_STS=22,
 	__NET_IPV4_CONF_MAX
 };
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7110779..9866f1b 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -419,6 +419,26 @@ static int arp_ignore(struct in_device *in_dev, struct net_device *dev,
 	return !inet_confirm_addr(dev, sip, tip, scope);
 }
 
+static int is_ip_on_dev(struct net_device* dev, __u32 ip) {
+      int rv = 0;
+      struct in_device* in_dev = in_dev_get(dev);
+      if (in_dev) {
+              struct in_ifaddr *ifa;
+
+              rcu_read_lock();
+              for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
+                      if (ifa->ifa_address == ip) {
+                              /* match */
+                              rv = 1;
+                              break;
+                      }
+              }
+              rcu_read_unlock();
+              in_dev_put(in_dev);
+      }
+      return rv;
+}
+
 static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
 {
 	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = sip,
@@ -430,8 +450,38 @@ static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
 	if (ip_route_output_key(&rt, &fl) < 0)
 		return 1;
 	if (rt->u.dst.dev != dev) {
-		NET_INC_STATS_BH(LINUX_MIB_ARPFILTER);
-		flag = 1;
+		struct in_device *in_dev = in_dev_get(dev);
+		if (in_dev && IN_DEV_ACCEPT_STS(in_dev) &&
+		    (rt->u.dst.dev == &loopback_dev))  {
+			/* Accept these IFF target-ip == dev's IP */
+			/* TODO:  Need to force the ARP response back out the interface
+			 * instead of letting it route locally.
+			 */
+			
+			if (is_ip_on_dev(dev, tip)) {
+				/* OK, we'll let this special case slide, so that we can
+				 * arp from one local interface to another.  This seems
+				 * to work, but could use some review. --Ben
+				 */
+				/*printk("arp_filter, sip: %x tip: %x  dev: %s, STS override (ip on dev)\n",
+                                  sip, tip, dev->name);*/
+			}
+			else {
+				/*printk("arp_filter, sip: %x tip: %x  dev: %s, IP is NOT on dev\n",
+                                  sip, tip, dev->name);*/
+				NET_INC_STATS_BH(LINUX_MIB_ARPFILTER);
+				flag = 1;
+			}
+		}
+		else {
+			/*printk("arp_filter, not lpbk  sip: %x tip: %x  dev: %s  flgs: %hx  dst.dev: %p  lbk: %p\n",
+			  sip, tip, dev->name, dev->priv_flags, rt->u.dst.dev, &loopback_dev);*/
+			NET_INC_STATS_BH(LINUX_MIB_ARPFILTER);
+			flag = 1;
+		}
+		if (in_dev) {
+			in_dev_put(in_dev);
+		}
 	}
 	ip_rt_put(rt);
 	return flag;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 7f95e6e..33ac2ed 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1513,6 +1513,15 @@ static struct devinet_sysctl_table {
 			.proc_handler	= &ipv4_doint_and_flush,
 			.strategy	= &ipv4_doint_and_flush_strategy,
 		},
+		{
+			.ctl_name       = NET_IPV4_CONF_ACCEPT_STS,
+			.procname       = "accept_sts",
+			.data           = &ipv4_devconf.accept_sts,
+			.maxlen         = sizeof(int),
+			.mode           = 0644,
+			.proc_handler   = &proc_dointvec,
+		},
+
 	},
 	.devinet_dev = {
 		{
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 837f295..9b57bf5 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -206,8 +206,16 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 
 	if (fib_lookup(&fl, &res))
 		goto last_resort;
-	if (res.type != RTN_UNICAST)
-		goto e_inval_res;
+	if (res.type != RTN_UNICAST) {
+		if ((res.type == RTN_LOCAL) &&
+		    (IN_DEV_ACCEPT_STS(in_dev))) {
+			/* All is OK */
+		}
+		else {
+			goto e_inval_res;
+		}
+	}
+
 	*spec_dst = FIB_RES_PREFSRC(res);
 	fib_combine_itag(itag, &res);
 #ifdef CONFIG_IP_ROUTE_MULTIPATH

--------------080603010100070704090802--

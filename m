From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH] net: don't allow CAP_NET_ADMIN to load non-netdev kernel
 modules
Date: Tue, 1 Mar 2011 22:48:45 +0300
Message-ID: <20110301194845.GA3533@albatros>
References: <201102272122.52643.arnd@arndb.de>
 <4D6B6AE7.2050202@msgid.tls.msk.ru>
 <20110228095133.GA4351@albatros>
 <20110228.112349.104067277.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mjt@tls.msk.ru, arnd@arndb.de, mirqus@gmail.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com,
	akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110228.112349.104067277.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since a8f80e8ff94ecba629542d9b4b5f5a8ee3eb565c any process with
CAP_NET_ADMIN may load any module from /lib/modules/.  This doesn't mean
that CAP_NET_ADMIN is a superset of CAP_SYS_MODULE as modules are
limited to /lib/modules/**.  However, CAP_NET_ADMIN capability shouldn't
allow anybody load any module not related to networking.

This patch restricts an ability of autoloading modules to netdev modules
with explicit aliases.  This fixes CVE-2011-1019.

Arnd Bergmann suggested to leave untouched the old pre-v2.6.32 behavior
of loading netdev modules by name (without any prefix) for processes
with CAP_SYS_MODULE to maintain the compatibility with network scripts
that use autoloading netdev modules by aliases like "eth0", "wlan0".

Currently there are only three users of the feature in the upstream
kernel: ipip, ip_gre and sit.

    root@albatros:~# capsh --drop=$(seq -s, 0 11),$(seq -s, 13 34) -- 
    root@albatros:~# grep Cap /proc/$$/status
    CapInh:	0000000000000000
    CapPrm:	fffffff800001000
    CapEff:	fffffff800001000
    CapBnd:	fffffff800001000
    root@albatros:~# modprobe xfs
    FATAL: Error inserting xfs
    (/lib/modules/2.6.38-rc6-00001-g2bf4ca3/kernel/fs/xfs/xfs.ko): Operation not permitted
    root@albatros:~# lsmod | grep xfs
    root@albatros:~# ifconfig xfs
    xfs: error fetching interface information: Device not found
    root@albatros:~# lsmod | grep xfs
    root@albatros:~# lsmod | grep sit
    root@albatros:~# ifconfig sit
    sit: error fetching interface information: Device not found
    root@albatros:~# lsmod | grep sit
    root@albatros:~# ifconfig sit0
    sit0      Link encap:IPv6-in-IPv4  
    	      NOARP  MTU:1480  Metric:1

    root@albatros:~# lsmod | grep sit
    sit                    10457  0 
    tunnel4                 2957  1 sit

For CAP_SYS_MODULE module loading is still relaxed:

    root@albatros:~# grep Cap /proc/$$/status
    CapInh:	0000000000000000
    CapPrm:	ffffffffffffffff
    CapEff:	ffffffffffffffff
    CapBnd:	ffffffffffffffff
    root@albatros:~# ifconfig xfs
    xfs: error fetching interface information: Device not found
    root@albatros:~# lsmod | grep xfs
    xfs                   745319  0 

Reference: https://lkml.org/lkml/2011/2/24/203 

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |   12 ++++++++++--
 net/ipv4/ip_gre.c         |    2 +-
 net/ipv4/ipip.c           |    2 +-
 net/ipv6/sit.c            |    2 +-
 5 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d971346..71caf7a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2392,6 +2392,9 @@ extern int netdev_notice(const struct net_device *dev, const char *format, ...)
 extern int netdev_info(const struct net_device *dev, const char *format, ...)
 	__attribute__ ((format (printf, 2, 3)));
 
+#define MODULE_ALIAS_NETDEV(device) \
+	MODULE_ALIAS("netdev-" device)
+
 #if defined(DEBUG)
 #define netdev_dbg(__dev, format, args...)			\
 	netdev_printk(KERN_DEBUG, __dev, format, ##args)
diff --git a/net/core/dev.c b/net/core/dev.c
index 8ae6631..fc6f037 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1119,8 +1119,16 @@ void dev_load(struct net *net, const char *name)
 	dev = dev_get_by_name_rcu(net, name);
 	rcu_read_unlock();
 
-	if (!dev && capable(CAP_NET_ADMIN))
-		request_module("%s", name);
+	if (!dev) {
+		if (capable(CAP_NET_ADMIN))
+			request_module("netdev-%s", name);
+		if (capable(CAP_SYS_MODULE)) {
+			if (!request_module("%s", name))
+				WARN_ONCE(1, "Loading kernel module for a "
+"network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias "
+"netdev-%s instead\n", name);
+		}
+	}
 }
 EXPORT_SYMBOL(dev_load);
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6613edf..d1d0e2c 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1765,4 +1765,4 @@ module_exit(ipgre_fini);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_RTNL_LINK("gre");
 MODULE_ALIAS_RTNL_LINK("gretap");
-MODULE_ALIAS("gre0");
+MODULE_ALIAS_NETDEV("gre0");
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 988f52f..a5f58e7 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -913,4 +913,4 @@ static void __exit ipip_fini(void)
 module_init(ipip_init);
 module_exit(ipip_fini);
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("tunl0");
+MODULE_ALIAS_NETDEV("tunl0");
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 8ce38f1..d2c16e1 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1290,4 +1290,4 @@ static int __init sit_init(void)
 module_init(sit_init);
 module_exit(sit_cleanup);
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("sit0");
+MODULE_ALIAS_NETDEV("sit0");
-- 
1.7.0.4

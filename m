From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH] don't allow CAP_NET_ADMIN to load non-netdev kernel modules
Date: Fri, 25 Feb 2011 18:14:14 +0300
Message-ID: <20110225151414.GA5211@albatros>
References: <20110224151238.GA16916@albatros>
 <1298565265.2613.16.camel@bwh-desktop>
 <20110225123023.GA8776@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Changli Gao <xiaosuo@gmail.com>, Jesse Gross <jesse@nicira.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110225123023.GA8776@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since a8f80e8ff94ecba629542d9b4b5f5a8ee3eb565c any process with
CAP_NET_ADMIN may load any module from /lib/modules/.  This doesn't mean
that CAP_NET_ADMIN is a superset of CAP_SYS_MODULE as modules are limited
to /lib/modules/**.  However, CAP_NET_ADMIN capability shouldn't allow
anybody load any module not related to networking.

This patch restricts an ability of autoloading modules to netdev modules
with explicit aliases.  Currently there are only three users of the
feature: ipip, ip_gre and sit.

Before the patch:

    root@albatros:~# grep Cap /proc/$$/status
    CapInh: 0000000000000000
    CapPrm: fffffffc00001000
    CapEff: fffffffc00001000
    CapBnd: fffffffc00001000
    root@albatros:~# lsmod | grep xfs
    root@albatros:~# ifconfig xfs
    xfs: error fetching interface information: Device not found
    root@albatros:~# lsmod | grep xfs
    xfs                   767011  0
    exportfs                4226  2 xfs,nfsd

After:

    root@albatros:~# grep Cap /proc/$$/status
    CapInh: 0000000000000000
    CapPrm: ffffffffffffffff
    CapEff: ffffffffffffffff
    CapBnd: ffffffffffffffff
    root@albatros:~# lsmod | grep scsi_wait_scan
    root@albatros:~# ifconfig scsi_wait_scan
    scsi_wait_scan: error fetching interface information: Device not found
    root@albatros:~# lsmod | grep scsi_wait_scan
    root@albatros:~# modprobe scsi_wait_scan
    root@albatros:~# lsmod | grep scsi_wait_scan
    scsi_wait_scan           829  0

Reference: http://www.openwall.com/lists/oss-security/2011/02/24/17

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |    2 +-
 net/ipv4/ip_gre.c         |    2 +-
 net/ipv4/ipip.c           |    2 +-
 net/ipv6/sit.c            |    2 +-
 5 files changed, 7 insertions(+), 4 deletions(-)

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
index 8ae6631..79b33d9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1120,7 +1120,7 @@ void dev_load(struct net *net, const char *name)
 	rcu_read_unlock();
 
 	if (!dev && capable(CAP_NET_ADMIN))
-		request_module("%s", name);
+		request_module("netdev-%s", name);
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

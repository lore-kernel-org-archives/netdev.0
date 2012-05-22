From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH] net: Surpress kmemleak messages on sysctl paths
Date: Mon, 21 May 2012 20:43:12 -0400
Message-ID: <1337647392.13348.14.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	ebiederm@xmission.com, tixxdz@opendz.org
To: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The network code allocates ctl_table_headers that are used for the life
of the kernel. These headers are registered and never unregistered. The
head pointer is allocated and not referenced, as it never needs to be
unregistered, and the kmemleak detector triggers these as false
positives:

unreferenced object 0xffff88007843fec0 (size 128):
  comm "swapper/0", pid 1, jiffies 4294669964 (age 12611.525s)
  hex dump (first 32 bytes):
    00 bb 59 82 ff ff ff ff 00 00 00 00 01 00 00 00  ..Y.............
    01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff8146b590>] kmemleak_alloc+0x73/0x98
    [<ffffffff8110a935>] kmemleak_alloc_recursive.constprop.42+0x16/0x18
    [<ffffffff8110b852>] __kmalloc+0x107/0x153
    [<ffffffff8116fa72>] kzalloc.constprop.8+0xe/0x10
    [<ffffffff8116fe2e>] __register_sysctl_table+0x46/0x39c
    [<ffffffff811703a7>] __register_sysctl_paths+0xbf/0x160
    [<ffffffff81170463>] register_sysctl_paths+0x1b/0x1d
    [<ffffffff81b1c769>] sysctl_core_init+0x17/0x38
    [<ffffffff81000229>] do_one_initcall+0x7f/0x13a
    [<ffffffff81ae5d00>] kernel_init+0x148/0x1cc
    [<ffffffff81493174>] kernel_thread_helper+0x4/0x10
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff8800784330c0 (size 128):
  comm "swapper/0", pid 1, jiffies 4294669968 (age 12611.521s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff8146b590>] kmemleak_alloc+0x73/0x98
    [<ffffffff8110a935>] kmemleak_alloc_recursive.constprop.42+0x16/0x18
    [<ffffffff8110b852>] __kmalloc+0x107/0x153
    [<ffffffff8116fa72>] kzalloc.constprop.8+0xe/0x10
    [<ffffffff811703c9>] __register_sysctl_paths+0xe1/0x160
    [<ffffffff81170463>] register_sysctl_paths+0x1b/0x1d
    [<ffffffff81b1d897>] ip_static_sysctl_init+0x17/0x19
    [<ffffffff81b1e1f4>] inet_init+0x9e/0x29c
    [<ffffffff81000229>] do_one_initcall+0x7f/0x13a
    [<ffffffff81ae5d00>] kernel_init+0x148/0x1cc
    [<ffffffff81493174>] kernel_thread_helper+0x4/0x10
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff88007843fdc0 (size 128):
  comm "swapper/0", pid 1, jiffies 4294669969 (age 12611.520s)
  hex dump (first 32 bytes):
    d0 d8 59 82 ff ff ff ff 00 00 00 00 01 00 00 00  ..Y.............
    01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff8146b590>] kmemleak_alloc+0x73/0x98
    [<ffffffff8110a935>] kmemleak_alloc_recursive.constprop.42+0x16/0x18
    [<ffffffff8110b852>] __kmalloc+0x107/0x153
    [<ffffffff8116fa72>] kzalloc.constprop.8+0xe/0x10
    [<ffffffff8116fe2e>] __register_sysctl_table+0x46/0x39c
    [<ffffffff8117024a>] register_leaf_sysctl_tables+0xc6/0x147
    [<ffffffff8117029f>] register_leaf_sysctl_tables+0x11b/0x147
    [<ffffffff811703f4>] __register_sysctl_paths+0x10c/0x160
    [<ffffffff81170463>] register_sysctl_paths+0x1b/0x1d
    [<ffffffff81b1d897>] ip_static_sysctl_init+0x17/0x19
    [<ffffffff81b1e1f4>] inet_init+0x9e/0x29c
    [<ffffffff81000229>] do_one_initcall+0x7f/0x13a
    [<ffffffff81ae5d00>] kernel_init+0x148/0x1cc
    [<ffffffff81493174>] kernel_thread_helper+0x4/0x10
    [<ffffffffffffffff>] 0xffffffffffffffff


Tell kmemleak to not consider these allocations as leaks.

Signed-off-by: Steven Rostedt <rostedt@goodmis.org>

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 0c28508..0bc5e0d 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -11,6 +11,7 @@
 #include <linux/socket.h>
 #include <linux/netdevice.h>
 #include <linux/ratelimit.h>
+#include <linux/kmemleak.h>
 #include <linux/vmalloc.h>
 #include <linux/init.h>
 #include <linux/slab.h>
@@ -255,9 +256,12 @@ static __net_initdata struct pernet_operations sysctl_core_ops = {
 static __init int sysctl_core_init(void)
 {
 	static struct ctl_table empty[1];
+	struct ctl_table_header *hdr;
 
-	register_sysctl_paths(net_core_path, empty);
-	register_net_sysctl_rotable(net_core_path, net_core_table);
+	hdr = register_sysctl_paths(net_core_path, empty);
+	kmemleak_not_leak(hdr);
+	hdr = register_net_sysctl_rotable(net_core_path, net_core_table);
+	kmemleak_not_leak(hdr);
 	return register_pernet_subsys(&sysctl_core_ops);
 }
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 167ea10..35aeaa7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -87,6 +87,7 @@
 #include <linux/pkt_sched.h>
 #include <linux/mroute.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/kmemleak.h>
 #include <linux/random.h>
 #include <linux/jhash.h>
 #include <linux/rcupdate.h>
@@ -3505,6 +3506,9 @@ int __init ip_rt_init(void)
  */
 void __init ip_static_sysctl_init(void)
 {
-	register_sysctl_paths(ipv4_path, ipv4_skeleton);
+	struct ctl_table_header *hdr;
+
+	hdr = register_sysctl_paths(ipv4_path, ipv4_skeleton);
+	kmemleak_not_leak(hdr);
 }
 #endif

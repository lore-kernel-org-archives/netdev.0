From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 7/6] net/sysfs: Fix the bitrot in network device kobject namespace support
Date: Sun, 16 May 2010 21:59:45 -0700
Message-ID: <m1y6fj3yym.fsf_-_@fess.ebiederm.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	<1273019809-16472-2-git-send-email-ebiederm@xmission.com>
	<20100505151746.GA15654@us.ibm.com> <m14oim2kcm.fsf@fess.ebiederm.org>
	<20100505220150.GA11595@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100505220150.GA11595@us.ibm.com> (Serge E. Hallyn's message of "Wed\, 5 May 2010 17\:01\:50 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I had a couple of stupid bugs in:
netns: Teach network device kobjects which namespace they are in.

- I duplicated the Kconfig for the NET_NS
- The build was broken when sysfs was not compiled in

The sysfs breakage is because after I moved the operations
for the sysfs to the kobject layer, to make things cleaner
I forgot to move the ifdefs.  Opps.

I'm not quite certain how I got introduced a second NET_NS Kconfig,
but it was probably a 3 way merge somewhere along the way that
did not notice that the NET_NS Kconfig option had mvoed and thout
that was a bug.  It probably slipped in because it used to be the
sysfs patches were the first patches in my network namespace patches.
Some things just don't go like you would expect.

Neither of these bugs actually affect anything in the common case
but they should be fixed.

Thanks to Serge for noticing they were present.

Reported-by: Serge E. Hallyn <serue@us.ibm.com>
Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 net/Kconfig          |    8 --------
 net/core/net-sysfs.c |    8 +++-----
 2 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index 265e33b..041c35e 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -45,14 +45,6 @@ config COMPAT_NETLINK_MESSAGES
 
 menu "Networking options"
 
-config NET_NS
-	bool "Network namespace support"
-	default n
-	depends on EXPERIMENTAL && NAMESPACES
-	help
-	  Allow user space to create what appear to be multiple instances
-	  of the network stack.
-
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 0727c57..c4c5157 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -467,6 +467,7 @@ static struct attribute_group wireless_group = {
 	.attrs = wireless_attrs,
 };
 #endif
+#endif /* CONFIG_SYSFS */
 
 static const void *net_current_ns(void)
 {
@@ -495,11 +496,10 @@ static void net_kobj_ns_exit(struct net *net)
 	kobj_ns_exit(KOBJ_NS_TYPE_NET, net);
 }
 
-static struct pernet_operations sysfs_net_ops = {
+static struct pernet_operations kobj_net_ops = {
 	.exit = net_kobj_ns_exit,
 };
 
-#endif /* CONFIG_SYSFS */
 
 #ifdef CONFIG_HOTPLUG
 static int netdev_uevent(struct device *d, struct kobj_uevent_env *env)
@@ -616,8 +616,6 @@ EXPORT_SYMBOL(netdev_class_remove_file);
 int netdev_kobject_init(void)
 {
 	kobj_ns_type_register(&net_ns_type_operations);
-#ifdef CONFIG_SYSFS
-	register_pernet_subsys(&sysfs_net_ops);
-#endif
+	register_pernet_subsys(&kobj_net_ops);
 	return class_register(&net_class);
 }
-- 
1.6.6.1

From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [NETNS] Oops in register_pernet_operations() with CONFIG_NET_NS=n
Date: Fri, 26 Oct 2007 13:41:55 +0200
Message-ID: <4721D283.4050909@bull.net>
References: <m1y7dr5esy.fsf@ebiederm.dsl.xmission.com>	<4720C9B9.80706@gmail.com>	<m1bqan5cuk.fsf@ebiederm.dsl.xmission.com> <20071026.043155.75000997.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070309020409080301040500"
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, dlunev@gmail.com,
	containers@lists.osdl.org, clg@fr.ibm.com, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:54158 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbXJZLmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 07:42:39 -0400
In-Reply-To: <20071026.043155.75000997.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070309020409080301040500
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1

David Miller wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Thu, 25 Oct 2007 11:21:55 -0600
> 
>>> By the way, I think that we can in the case of undefined CONFIG_NET_NS
>>> reduce register to calling ->init method and unregister to calling
>>> ->exit method.
>>>
>>> This is a correct thing at least for now and will be welcomed by the all
>>> embedded/etc people.
>> I'm not fundamentally opposed.  Earlier versions of my patchset
>> did that and more.   However I think the pain is greater then the
>> gain right now.  Especially since this concept seem to require
>> having quality inspected into it.
> 
> I think the correct thing to do for now is to simply remove these
> __net_* markers and their definitions.  There are so many tricky cases
> that it is easier to just get rid of them.
> 
> Could someone send me a patch which does that?

The attached patch revert Pavel's orginal patch from 2.6.23-mm1. 
It should work fine with net-2.6 too.

Benjamin

-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

   http://www.bull.com

--------------070309020409080301040500
Content-Transfer-Encoding: 7bit
Content-Type: text/x-patch;
 name="NETNS-REVERT-Move-some-code-into-__init-section-when-CONFIG_NET_NS-is-not-set.patch"
Content-Disposition: inline;
 filename*0="NETNS-REVERT-Move-some-code-into-__init-section-when-CONFIG_";
 filename*1="NET_NS-is-not-set.patch"

This patch reverts the patch sent by Pavel Emilyanov
that introduced __net_init/__net_exit/__net_initdata defines
to save some memory when CONFIG_NET_NS=n.

http://www.spinics.net/lists/netdev/msg43310.html

When CONFIG_NET_NS=n, this later patch causes an oops when a 
netns-aware module is loaded after boot. When initialized the 
module tries to register its pernet operations and add them in 
the pernet_list. Unfortunately this list is corrupted as its 
first entries have been freed at the end of the boot sequence.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 drivers/net/loopback.c      |    6 +++---
 fs/proc/proc_net.c          |    8 ++++----
 include/linux/init.h        |    1 -
 include/net/net_namespace.h |    9 ---------
 net/core/dev.c              |   16 ++++++++--------
 net/core/dev_mcast.c        |    6 +++---
 net/netlink/af_netlink.c    |    6 +++---
 scripts/mod/modpost.c       |    1 -
 8 files changed, 21 insertions(+), 32 deletions(-)

Index: linux-2.6.23-mm1-lxc1/drivers/net/loopback.c
===================================================================
--- linux-2.6.23-mm1-lxc1.orig/drivers/net/loopback.c
+++ linux-2.6.23-mm1-lxc1/drivers/net/loopback.c
@@ -250,7 +250,7 @@ static void loopback_setup(struct net_de
 }
 
 /* Setup and register the loopback device. */
-static __net_init int loopback_net_init(struct net *net)
+static int loopback_net_init(struct net *net)
 {
 	struct net_device *dev;
 	int err;
@@ -278,14 +278,14 @@ out_free_netdev:
 	goto out;
 }
 
-static __net_exit void loopback_net_exit(struct net *net)
+static void loopback_net_exit(struct net *net)
 {
 	struct net_device *dev = net->loopback_dev;
 
 	unregister_netdev(dev);
 }
 
-static struct pernet_operations __net_initdata loopback_net_ops = {
+static struct pernet_operations loopback_net_ops = {
        .init = loopback_net_init,
        .exit = loopback_net_exit,
 };
Index: linux-2.6.23-mm1-lxc1/fs/proc/proc_net.c
===================================================================
--- linux-2.6.23-mm1-lxc1.orig/fs/proc/proc_net.c
+++ linux-2.6.23-mm1-lxc1/fs/proc/proc_net.c
@@ -140,7 +140,7 @@ static struct inode_operations proc_net_
 	.setattr	= proc_net_setattr,
 };
 
-static __net_init int proc_net_ns_init(struct net *net)
+static int proc_net_ns_init(struct net *net)
 {
 	struct proc_dir_entry *root, *netd, *net_statd;
 	int err;
@@ -178,19 +178,19 @@ free_root:
 	goto out;
 }
 
-static __net_exit void proc_net_ns_exit(struct net *net)
+static void proc_net_ns_exit(struct net *net)
 {
 	remove_proc_entry("stat", net->proc_net);
 	remove_proc_entry("net", net->proc_net_root);
 	kfree(net->proc_net_root);
 }
 
-struct pernet_operations __net_initdata proc_net_ns_ops = {
+struct pernet_operations proc_net_ns_ops = {
 	.init = proc_net_ns_init,
 	.exit = proc_net_ns_exit,
 };
 
-int __init proc_net_init(void)
+int proc_net_init(void)
 {
 	proc_net_shadow = proc_mkdir("net", NULL);
 	proc_net_shadow->proc_iops = &proc_net_dir_inode_operations;
Index: linux-2.6.23-mm1-lxc1/include/linux/init.h
===================================================================
--- linux-2.6.23-mm1-lxc1.orig/include/linux/init.h
+++ linux-2.6.23-mm1-lxc1/include/linux/init.h
@@ -57,7 +57,6 @@
  * The markers follow same syntax rules as __init / __initdata. */
 #define __init_refok     noinline __attribute__ ((__section__ (".text.init.refok")))
 #define __initdata_refok          __attribute__ ((__section__ (".data.init.refok")))
-#define __exit_refok     noinline __attribute__ ((__section__ (".exit.text.refok")))
 
 #ifdef MODULE
 #define __exit		__attribute__ ((__section__(".exit.text"))) __cold
Index: linux-2.6.23-mm1-lxc1/include/net/net_namespace.h
===================================================================
--- linux-2.6.23-mm1-lxc1.orig/include/net/net_namespace.h
+++ linux-2.6.23-mm1-lxc1/include/net/net_namespace.h
@@ -99,15 +99,6 @@ static inline void release_net(struct ne
 #define for_each_net(VAR)				\
 	list_for_each_entry(VAR, &net_namespace_list, list)
 
-#ifdef CONFIG_NET_NS
-#define __net_init
-#define __net_exit
-#define __net_initdata
-#else
-#define __net_init	__init
-#define __net_exit	__exit_refok
-#define __net_initdata	__initdata
-#endif
 
 struct pernet_operations {
 	struct list_head list;
Index: linux-2.6.23-mm1-lxc1/net/core/dev.c
===================================================================
--- linux-2.6.23-mm1-lxc1.orig/net/core/dev.c
+++ linux-2.6.23-mm1-lxc1/net/core/dev.c
@@ -2615,7 +2615,7 @@ static const struct file_operations ptyp
 };
 
 
-static int __net_init dev_proc_net_init(struct net *net)
+static int dev_proc_net_init(struct net *net)
 {
 	int rc = -ENOMEM;
 
@@ -2640,7 +2640,7 @@ out_dev:
 	goto out;
 }
 
-static void __net_exit dev_proc_net_exit(struct net *net)
+static void dev_proc_net_exit(struct net *net)
 {
 	wext_proc_exit(net);
 
@@ -2649,7 +2649,7 @@ static void __net_exit dev_proc_net_exit
 	proc_net_remove(net, "dev");
 }
 
-static struct pernet_operations __net_initdata dev_proc_ops = {
+static struct pernet_operations dev_proc_ops = {
 	.init = dev_proc_net_init,
 	.exit = dev_proc_net_exit,
 };
@@ -4280,7 +4280,7 @@ static struct hlist_head *netdev_create_
 }
 
 /* Initialize per network namespace state */
-static int __net_init netdev_init(struct net *net)
+static int netdev_init(struct net *net)
 {
 	INIT_LIST_HEAD(&net->dev_base_head);
 	rwlock_init(&dev_base_lock);
@@ -4301,18 +4301,18 @@ err_name:
 	return -ENOMEM;
 }
 
-static void __net_exit netdev_exit(struct net *net)
+static void netdev_exit(struct net *net)
 {
 	kfree(net->dev_name_head);
 	kfree(net->dev_index_head);
 }
 
-static struct pernet_operations __net_initdata netdev_net_ops = {
+static struct pernet_operations netdev_net_ops = {
 	.init = netdev_init,
 	.exit = netdev_exit,
 };
 
-static void __net_exit default_device_exit(struct net *net)
+static void default_device_exit(struct net *net)
 {
 	struct net_device *dev, *next;
 	/*
@@ -4338,7 +4338,7 @@ static void __net_exit default_device_ex
 	rtnl_unlock();
 }
 
-static struct pernet_operations __net_initdata default_device_ops = {
+static struct pernet_operations default_device_ops = {
 	.exit = default_device_exit,
 };
 
Index: linux-2.6.23-mm1-lxc1/net/core/dev_mcast.c
===================================================================
--- linux-2.6.23-mm1-lxc1.orig/net/core/dev_mcast.c
+++ linux-2.6.23-mm1-lxc1/net/core/dev_mcast.c
@@ -273,19 +273,19 @@ static const struct file_operations dev_
 
 #endif
 
-static int __net_init dev_mc_net_init(struct net *net)
+static int dev_mc_net_init(struct net *net)
 {
 	if (!proc_net_fops_create(net, "dev_mcast", 0, &dev_mc_seq_fops))
 		return -ENOMEM;
 	return 0;
 }
 
-static void __net_exit dev_mc_net_exit(struct net *net)
+static void dev_mc_net_exit(struct net *net)
 {
 	proc_net_remove(net, "dev_mcast");
 }
 
-static struct pernet_operations __net_initdata dev_mc_net_ops = {
+static struct pernet_operations dev_mc_net_ops = {
 	.init = dev_mc_net_init,
 	.exit = dev_mc_net_exit,
 };
Index: linux-2.6.23-mm1-lxc1/net/netlink/af_netlink.c
===================================================================
--- linux-2.6.23-mm1-lxc1.orig/net/netlink/af_netlink.c
+++ linux-2.6.23-mm1-lxc1/net/netlink/af_netlink.c
@@ -1915,7 +1915,7 @@ static struct net_proto_family netlink_f
 	.owner	= THIS_MODULE,	/* for consistency 8) */
 };
 
-static int __net_init netlink_net_init(struct net *net)
+static int netlink_net_init(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
 	if (!proc_net_fops_create(net, "netlink", 0, &netlink_seq_fops))
@@ -1924,14 +1924,14 @@ static int __net_init netlink_net_init(s
 	return 0;
 }
 
-static void __net_exit netlink_net_exit(struct net *net)
+static void netlink_net_exit(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
 	proc_net_remove(net, "netlink");
 #endif
 }
 
-static struct pernet_operations __net_initdata netlink_net_ops = {
+static struct pernet_operations netlink_net_ops = {
 	.init = netlink_net_init,
 	.exit = netlink_net_exit,
 };
Index: linux-2.6.23-mm1-lxc1/scripts/mod/modpost.c
===================================================================
--- linux-2.6.23-mm1-lxc1.orig/scripts/mod/modpost.c
+++ linux-2.6.23-mm1-lxc1/scripts/mod/modpost.c
@@ -715,7 +715,6 @@ static int secref_whitelist(const char *
 
 	/* Check for pattern 0 */
 	if ((strncmp(fromsec, ".text.init.refok", strlen(".text.init.refok")) == 0) ||
-	    (strncmp(fromsec, ".exit.text.refok", strlen(".exit.text.refok")) == 0) ||
 	    (strncmp(fromsec, ".data.init.refok", strlen(".data.init.refok")) == 0))
 		return 1;
 

--------------070309020409080301040500--

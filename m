From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net: Marking struct pernet_operations __net_initdata was inappropriate
Date: Fri, 26 Oct 2007 17:45:33 -0600
Message-ID: <m1hckdwici.fsf_-_@ebiederm.dsl.xmission.com>
References: <m1bqan5cuk.fsf@ebiederm.dsl.xmission.com>
	<20071026.043155.75000997.davem@davemloft.net>
	<4721D283.4050909@bull.net>
	<20071026.045503.62376243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benjamin.thery@bull.net, ebiederm@xmission.com,
	netdev@vger.kernel.org, dlunev@gmail.com,
	containers@lists.osdl.org, clg@fr.ibm.com, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:42924 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753662AbXJZXqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 19:46:35 -0400
In-Reply-To: <20071026.045503.62376243.davem@davemloft.net> (David Miller's
	message of "Fri, 26 Oct 2007 04:55:03 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It is not safe to to place struct pernet_operations in a special section.
We need struct pernet_operations to last until we call unregister_pernet_subsys.
Which doesn't happen until module unload.

So marking struct pernet_operations is a disaster for modules in two ways.
- We discard it before we call the exit method it points to.
- Because I keep struct pernet_operations on a linked list discarding
  it for compiled in code removes elements in the middle of a linked
  list and does horrible things for linked insert.

So this looks safe assuming __exit_refok is not discarded
for modules.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/loopback.c      |    2 +-
 fs/proc/proc_net.c          |    2 +-
 include/net/net_namespace.h |    2 --
 net/core/dev.c              |    6 +++---
 net/core/dev_mcast.c        |    2 +-
 net/netlink/af_netlink.c    |    2 +-
 6 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 662b8d1..45f30a2 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -284,7 +284,7 @@ static __net_exit void loopback_net_exit(struct net *net)
 	unregister_netdev(dev);
 }
 
-static struct pernet_operations __net_initdata loopback_net_ops = {
+static struct pernet_operations loopback_net_ops = {
        .init = loopback_net_init,
        .exit = loopback_net_exit,
 };
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 4edaad0..749def0 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -185,7 +185,7 @@ static __net_exit void proc_net_ns_exit(struct net *net)
 	kfree(net->proc_net_root);
 }
 
-static struct pernet_operations __net_initdata proc_net_ns_ops = {
+static struct pernet_operations proc_net_ns_ops = {
 	.init = proc_net_ns_init,
 	.exit = proc_net_ns_exit,
 };
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 93aa87d..5279466 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -102,11 +102,9 @@ static inline void release_net(struct net *net)
 #ifdef CONFIG_NET_NS
 #define __net_init
 #define __net_exit
-#define __net_initdata
 #else
 #define __net_init	__init
 #define __net_exit	__exit_refok
-#define __net_initdata	__initdata
 #endif
 
 struct pernet_operations {
diff --git a/net/core/dev.c b/net/core/dev.c
index ddfef3b..853c8b5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2668,7 +2668,7 @@ static void __net_exit dev_proc_net_exit(struct net *net)
 	proc_net_remove(net, "dev");
 }
 
-static struct pernet_operations __net_initdata dev_proc_ops = {
+static struct pernet_operations dev_proc_ops = {
 	.init = dev_proc_net_init,
 	.exit = dev_proc_net_exit,
 };
@@ -4328,7 +4328,7 @@ static void __net_exit netdev_exit(struct net *net)
 	kfree(net->dev_index_head);
 }
 
-static struct pernet_operations __net_initdata netdev_net_ops = {
+static struct pernet_operations  netdev_net_ops = {
 	.init = netdev_init,
 	.exit = netdev_exit,
 };
@@ -4359,7 +4359,7 @@ static void __net_exit default_device_exit(struct net *net)
 	rtnl_unlock();
 }
 
-static struct pernet_operations __net_initdata default_device_ops = {
+static struct pernet_operations  default_device_ops = {
 	.exit = default_device_exit,
 };
 
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 15241cf..ae35405 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -285,7 +285,7 @@ static void __net_exit dev_mc_net_exit(struct net *net)
 	proc_net_remove(net, "dev_mcast");
 }
 
-static struct pernet_operations __net_initdata dev_mc_net_ops = {
+static struct pernet_operations dev_mc_net_ops = {
 	.init = dev_mc_net_init,
 	.exit = dev_mc_net_exit,
 };
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 3252729..4f994c0 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1888,7 +1888,7 @@ static void __net_exit netlink_net_exit(struct net *net)
 #endif
 }
 
-static struct pernet_operations __net_initdata netlink_net_ops = {
+static struct pernet_operations netlink_net_ops = {
 	.init = netlink_net_init,
 	.exit = netlink_net_exit,
 };
-- 
1.5.3.rc6.17.g1911


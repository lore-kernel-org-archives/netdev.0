From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] bonding: move IPv6 support into a separate kernel module
Date: Fri, 20 Feb 2009 19:31:29 -0500
Message-ID: <499F4B61.3050508@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrey Borzenkov <arvidjaar@mail.ru>,
	Vladislav Yasevich <vladislav.yasevich@hp.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Theodore Tso <tytso@mit.edu>, Valdis.Kletnieks@vt.edu,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bonding-devel@lists.sourceforge.net,
	=?ISO-8859-1?Q?=22J=2EA=2E_Magall?= =?ISO-8859-1?Q?=F3n=22?=
	<jamagallon@ono.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:12241 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317AbZBUAbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 19:31:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Possible fix for bonding IPv6 regression reported by Andrey Borzenkov,
tried to keep all Cc's]

This patch moves the IPv6 bonding code into a separate kernel module
called bonding_ipv6 if either bonding or IPv6 are built as modules.
If both are built into the kernel then this is as well.  Bonding_ipv6.ko
registers an "send_unsol_na" function pointer for the unsolicited
advertisement function to be called on a failover - the default action
is to do nothing.  The notifier callbacks are now registered in this
module and not in the base bonding module.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---
  Documentation/networking/bonding.txt |    3 ++
  drivers/net/bonding/Makefile         |    5 ++-
  drivers/net/bonding/bond_ipv6.c      |   13 +++++++-
  drivers/net/bonding/bond_main.c      |   52
++++++++++++++++++++++++++++++---
  drivers/net/bonding/bonding.h        |    9 +++--
  5 files changed, 69 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/bonding.txt
b/Documentation/networking/bonding.txt
index 5ede747..c8b1c1f 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -603,6 +603,9 @@ num_unsol_na
  	affects only the active-backup mode.  This option was added for
  	bonding version 3.4.0.

+	In order to get this functionality, you will need to load the
+	Bonding IPv6 module with 'modprobe bonding_ipv6'.
+
  primary

  	A string (eth0, eth2, etc) specifying which slave is the
diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index 6f9c6fa..d4f6338 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -6,6 +6,7 @@ obj-$(CONFIG_BONDING) += bonding.o

  bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o

-ipv6-$(subst m,y,$(CONFIG_IPV6)) += bond_ipv6.o
-bonding-objs += $(ipv6-y)
+# build bonding_ipv6 as module whenever either IPv6 or Bonding is a module
+obj-$(subst y,$(CONFIG_BONDING),$(CONFIG_IPV6)) += bonding_ipv6.o
+bonding_ipv6-y := bond_ipv6.o

diff --git a/drivers/net/bonding/bond_ipv6.c
b/drivers/net/bonding/bond_ipv6.c
index 0d73bf5..2f10514 100644
--- a/drivers/net/bonding/bond_ipv6.c
+++ b/drivers/net/bonding/bond_ipv6.c
@@ -20,6 +20,9 @@
   *
   */

+#include <linux/module.h>
+#include <linux/init.h>
+
  #include <linux/types.h>
  #include <linux/if_vlan.h>
  #include <net/ipv6.h>
@@ -204,13 +207,19 @@ static struct notifier_block
bond_inet6addr_notifier = {
  	.notifier_call = bond_inet6addr_event,
  };

-void bond_register_ipv6_notifier(void)
+static int __init bonding_ipv6_init(void)
  {
+	bond_register_ipv6_na(bond_send_unsolicited_na);
  	register_inet6addr_notifier(&bond_inet6addr_notifier);
+	return 0;
  }

-void bond_unregister_ipv6_notifier(void)
+static void __exit bonding_ipv6_exit(void)
  {
  	unregister_inet6addr_notifier(&bond_inet6addr_notifier);
+	bond_unregister_ipv6_na();
  }

+module_init(bonding_ipv6_init)
+module_exit(bonding_ipv6_exit)
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/bonding/bond_main.c
b/drivers/net/bonding/bond_main.c
index 2c96b93..ff61add 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -149,6 +149,12 @@ static const char * const version =
  	DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n";

  LIST_HEAD(bond_dev_list);
+EXPORT_SYMBOL(bond_dev_list);
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static DEFINE_SPINLOCK(bond_v6_na_lock);
+#endif
+static void (*bond_send_unsol_na)(struct bonding *bond);

  #ifdef CONFIG_PROC_FS
  static struct proc_dir_entry *bond_proc_dir = NULL;
@@ -1201,6 +1207,8 @@ void bond_change_active_slave(struct bonding
*bond, struct slave *new_active)
  		}

  		if (new_active) {
+			void (*send_unsol_na)(struct bonding *bond);
+
  			bond_set_slave_active_flags(new_active);

  			if (bond->params.fail_over_mac)
@@ -1211,7 +1219,11 @@ void bond_change_active_slave(struct bonding
*bond, struct slave *new_active)
  			bond_send_gratuitous_arp(bond);

  			bond->send_unsol_na = bond->params.num_unsol_na;
-			bond_send_unsolicited_na(bond);
+			rcu_read_lock();
+			send_unsol_na = rcu_dereference(bond_send_unsol_na);
+			if (send_unsol_na)
+				send_unsol_na(bond);
+			rcu_read_unlock();

  			write_unlock_bh(&bond->curr_slave_lock);
  			read_unlock(&bond->lock);
@@ -2464,8 +2476,14 @@ void bond_mii_monitor(struct work_struct *work)
  	}

  	if (bond->send_unsol_na) {
+		void (*send_unsol_na)(struct bonding *bond);
+
  		read_lock(&bond->curr_slave_lock);
-		bond_send_unsolicited_na(bond);
+		rcu_read_lock();
+		send_unsol_na = rcu_dereference(bond_send_unsol_na);
+		if (send_unsol_na)
+			send_unsol_na(bond);
+		rcu_read_unlock();
  		read_unlock(&bond->curr_slave_lock);
  	}

@@ -3165,8 +3183,14 @@ void bond_activebackup_arp_mon(struct work_struct
*work)
  	}

  	if (bond->send_unsol_na) {
+		void (*send_unsol_na)(struct bonding *bond);
+
  		read_lock(&bond->curr_slave_lock);
-		bond_send_unsolicited_na(bond);
+		rcu_read_lock();
+		send_unsol_na = rcu_dereference(bond_send_unsol_na);
+		if (send_unsol_na)
+			send_unsol_na(bond);
+		rcu_read_unlock();
  		read_unlock(&bond->curr_slave_lock);
  	}

@@ -5203,6 +5227,26 @@ out_rtnl:
  	return res;
  }

+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+void bond_register_ipv6_na(void (*send_unsol_na) (struct bonding *bond))
+{
+	spin_lock_bh(&bond_v6_na_lock);
+	rcu_assign_pointer(bond_send_unsol_na, send_unsol_na);
+	spin_unlock_bh(&bond_v6_na_lock);
+	synchronize_rcu();
+}
+EXPORT_SYMBOL_GPL(bond_register_ipv6_na);
+
+void bond_unregister_ipv6_na(void)
+{
+	spin_lock_bh(&bond_v6_na_lock);
+	rcu_assign_pointer(bond_send_unsol_na, NULL);
+	spin_unlock_bh(&bond_v6_na_lock);
+	synchronize_rcu();
+}
+EXPORT_SYMBOL(bond_unregister_ipv6_na);
+#endif
+
  static int __init bonding_init(void)
  {
  	int i;
@@ -5234,7 +5278,6 @@ static int __init bonding_init(void)

  	register_netdevice_notifier(&bond_netdev_notifier);
  	register_inetaddr_notifier(&bond_inetaddr_notifier);
-	bond_register_ipv6_notifier();

  	goto out;
  err:
@@ -5257,7 +5300,6 @@ static void __exit bonding_exit(void)
  {
  	unregister_netdevice_notifier(&bond_netdev_notifier);
  	unregister_inetaddr_notifier(&bond_inetaddr_notifier);
-	bond_unregister_ipv6_notifier();

  	bond_destroy_sysfs();

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ca849d2..9e5e092 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -23,15 +23,13 @@
  #include "bond_3ad.h"
  #include "bond_alb.h"

-#define DRV_VERSION	"3.5.0"
-#define DRV_RELDATE	"November 4, 2008"
+#define DRV_VERSION	"3.6.0"
+#define DRV_RELDATE	"February 20, 2009"
  #define DRV_NAME	"bonding"
  #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"

  #define BOND_MAX_ARP_TARGETS	16

-extern struct list_head bond_dev_list;
-
  #define IS_UP(dev)					   \
  	      ((((dev)->flags & IFF_UP) == IFF_UP)	&& \
  	       netif_running(dev)			&& \
@@ -360,6 +358,9 @@ extern struct rw_semaphore bonding_rwsem;
  void bond_send_unsolicited_na(struct bonding *bond);
  void bond_register_ipv6_notifier(void);
  void bond_unregister_ipv6_notifier(void);
+
+void bond_register_ipv6_na(void (*send_unsol_na) (struct bonding *bond));
+void bond_unregister_ipv6_na(void);
  #else
  static inline void bond_send_unsolicited_na(struct bonding *bond)
  {
-- 
1.5.4.3




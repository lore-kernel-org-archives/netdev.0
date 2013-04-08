From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH 2/2] bonding: fix bonding_masters race condition in bond
 unloading
Date: Mon, 8 Apr 2013 10:30:44 +0200
Message-ID: <20130408083044.GA1757@redhat.com>
References: <1365245678-4455-1-git-send-email-nikolay@redhat.com>
 <1365245678-4455-2-git-send-email-nikolay@redhat.com>
 <20130406135020.GA18246@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13289 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934056Ab3DHIbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 04:31:12 -0400
Content-Disposition: inline
In-Reply-To: <20130406135020.GA18246@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 06, 2013 at 03:50:20PM +0200, Veaceslav Falico wrote:
>On Sat, Apr 06, 2013 at 12:54:38PM +0200, Nikolay Aleksandrov wrote:
>>While the bonding module is unloading, it is considered that after
>>rtnl_link_unregister all bond devices are destroyed but since no
>>synchronization mechanism exists, a new bond device can be created
>>via bonding_masters before unregister_pernet_subsys which would
>>lead to multiple problems (e.g. NULL pointer dereference, wrong RIP,
>>list corruption).
>>
>>This patch fixes the issue by removing any bond devices left in the
>>netns after bonding_masters is removed from sysfs.
>>
>>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>>---
>>drivers/net/bonding/bond_main.c | 9 +++++++++
>>1 file changed, 9 insertions(+)
>>
>
>I'm still thinking that's it's not the best way of fixing it
>(remove_devices(); remove_sysfs(); remove_devices()) - but given that I
>can't come up with anything better and my first fix didn't actually work -
>I'm ok with your patch.


I think I've found a proper way to do it. Even with your approach we still
might end up in some kind of race condition with procfs (check
bond_net_exit() -> proc removal, it's made without rtnl_lock()). So the
best way would be to lock both functions (__rtnl_link_unregister() and
unregister_pernet_subsys()) with rtnl_lock(). It wasn't possible because of
a possible race with sysfs (we start removing the bonding, lock rtnl(),
someone accesses sysfs(), and our sysfs removal code blocks because of this
access - deadlock).

However, if we use the rtnl_trylock() mechanism, we will be able to let
sysfs go and finish the removal.

What do you think about this approach? A quick-n-dirty patch is below, I'm
running rmmod/insmod for an hour already and it seems to work, however
there still might be bugs, and the patch definitely needs some
cleaning/comments.

 From 3a7858ec5d8ef3261dd52fcd35048cb737aec780 Mon Sep 17 00:00:00 2001
From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon, 8 Apr 2013 10:29:46 +0200
Subject: [PATCH] bonding: properly protect bonding_exit()

We might race with sysfs/procfs on exit, so protect them with rtnl_lock.
Also, convert all sysfs code to rtnl_trylock()/restart_syscall(), so that
we don't end up in deadlock.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
  drivers/net/bonding/bond_main.c  |   13 ++++++-------
  drivers/net/bonding/bond_sysfs.c |   11 ++++++++---
  2 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2aac890..6671f89 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4797,22 +4797,17 @@ static struct rtnl_link_ops bond_link_ops __read_mostly = {
  
  /* Create a new bond based on the specified name and bonding parameters.
   * If name is NULL, obtain a suitable "bond%d" name for us.
- * Caller must NOT hold rtnl_lock; we need to release it here before we
- * set up our sysfs entries.
   */
  int bond_create(struct net *net, const char *name)
  {
  	struct net_device *bond_dev;
  	int res;
  
-	rtnl_lock();
-
  	bond_dev = alloc_netdev_mq(sizeof(struct bonding),
  				   name ? name : "bond%d",
  				   bond_setup, tx_queues);
  	if (!bond_dev) {
  		pr_err("%s: eek! can't alloc netdev!\n", name);
-		rtnl_unlock();
  		return -ENOMEM;
  	}
  
@@ -4823,9 +4818,9 @@ int bond_create(struct net *net, const char *name)
  
  	netif_carrier_off(bond_dev);
  
-	rtnl_unlock();
  	if (res < 0)
  		bond_destructor(bond_dev);
+
  	return res;
  }
  
@@ -4879,7 +4874,9 @@ static int __init bonding_init(void)
  	bond_create_debugfs();
  
  	for (i = 0; i < max_bonds; i++) {
+		rtnl_lock();
  		res = bond_create(&init_net, NULL);
+		rtnl_unlock();
  		if (res)
  			goto err;
  	}
@@ -4901,8 +4898,10 @@ static void __exit bonding_exit(void)
  
  	bond_destroy_debugfs();
  
+	rtnl_lock();
+	__rtnl_link_unregister(&bond_link_ops);
  	unregister_pernet_subsys(&bond_net_ops);
-	rtnl_link_unregister(&bond_link_ops);
+	rtnl_unlock();
  
  #ifdef CONFIG_NET_POLL_CONTROLLER
  	/*
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ea7a388..cd1d60f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -59,7 +59,8 @@ static ssize_t bonding_show_bonds(struct class *cls,
  	int res = 0;
  	struct bonding *bond;
  
-	rtnl_lock();
+	if (!rtnl_trylock())
+		return restart_syscall();
  
  	list_for_each_entry(bond, &bn->dev_list, bond_list) {
  		if (res > (PAGE_SIZE - IFNAMSIZ)) {
@@ -107,6 +108,9 @@ static ssize_t bonding_store_bonds(struct class *cls,
  	char *ifname;
  	int rv, res = count;
  
+	if (!rtnl_trylock())
+		return restart_syscall();
+
  	sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
  	ifname = command + 1;
  	if ((strlen(command) <= 1) ||
@@ -126,7 +130,6 @@ static ssize_t bonding_store_bonds(struct class *cls,
  	} else if (command[0] == '-') {
  		struct net_device *bond_dev;
  
-		rtnl_lock();
  		bond_dev = bond_get_by_name(bn, ifname);
  		if (bond_dev) {
  			pr_info("%s is being deleted...\n", ifname);
@@ -135,10 +138,11 @@ static ssize_t bonding_store_bonds(struct class *cls,
  			pr_err("unable to delete non-existent %s\n", ifname);
  			res = -ENODEV;
  		}
-		rtnl_unlock();
  	} else
  		goto err_no_cmd;
  
+	rtnl_unlock();
+
  	/* Always return either count or an error.  If you return 0, you'll
  	 * get called forever, which is bad.
  	 */
@@ -146,6 +150,7 @@ static ssize_t bonding_store_bonds(struct class *cls,
  
  err_no_cmd:
  	pr_err("no command found in bonding_masters. Use +ifname or -ifname.\n");
+	rtnl_unlock();
  	return -EPERM;
  }
  
-- 
1.7.1

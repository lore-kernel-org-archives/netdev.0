From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/6] Bonding simplifications and netns support
Date: Fri, 30 Oct 2009 17:10:53 -0700
Message-ID: <32609.1256947853@death.nxdomain.ibm.com>
References: <m1tyxhwxah.fsf@fess.ebiederm.org> <20091030.124153.00934819.davem@davemloft.net> <21200.1256937150@death.nxdomain.ibm.com> <m1639wo5gb.fsf@fess.ebiederm.org>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:36378 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933116AbZJaAK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2009 20:10:57 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9V03Rtc030727
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 20:03:27 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9V0B1i9106006
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 20:11:01 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9V0B13x025933
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 20:11:01 -0400
In-reply-to: <m1639wo5gb.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:

>Jay Vosburgh <fubar@us.ibm.com> writes:
>
>> David Miller <davem@davemloft.net> wrote:
>>
>>>From: ebiederm@xmission.com (Eric W. Biederman)
>>>Date: Thu, 29 Oct 2009 17:16:54 -0700
>>>
>>>> I recently had it pointed out to me that the bonding driver does not
>>>> work in a network namespace.  So I have simplified the bonding driver
>>>> a bit, added support for ip link add and ip link del, and finally made
>>>> the bonding driver work in multiple network namespaces.
>>>> 
>>>> The most note worthy change in the patchset is the addition of support
>>>> in the networking core for registering a sysfs group for a device.
>>>> 
>>>> Using this in the bonding driver simplifies the code and removes a
>>>> userspace race between actions triggered by the netlink event and the
>>>> bonding sysfs attributes appearing.
>>>
>>>I've tossed patches 1-7 into net-next-2.6, thanks Eric.
>>
>> 	I put patches 1-7 on a recent net-next-2.6, and from a simple
>> "insmod bonding.ko; rmmod bonding" I'm seeing the following:
>>
>> ------------[ cut here ]------------
>> WARNING: at fs/proc/generic.c:847 remove_proc_entry+0x1a8/0x1c7()
>> Hardware name: IBM eserver xSeries 220 -[8645]-
>> remove_proc_entry: removing non-empty directory 'net/bonding', leaking at least 
>> 'bond0'
>> Modules linked in: bonding(-) ipv6 microcode loop ppdev sworks_agp parport_pc tg
>> 3 e100 agpgart parport mii libphy e1000 edd pata_serverworks [last unloaded: spe
>> edstep_lib]
>> Pid: 6216, comm: rmmod Not tainted 2.6.32-rc3-devel #19
>> Call Trace:
>>  [<c012ec9d>] warn_slowpath_common+0x60/0x90
>>  [<c012ed01>] warn_slowpath_fmt+0x24/0x27
>>  [<c01e3e55>] remove_proc_entry+0x1a8/0x1c7
>>  [<e0906435>] ? bond_net_exit+0x0/0xa3 [bonding]
>>  [<e09064c3>] bond_net_exit+0x8e/0xa3 [bonding]
>>  [<c02e6ee8>] unregister_pernet_gen_subsys+0x23/0x3d
>>  [<e0910baa>] bonding_exit+0x3a/0x66 [bonding]
>>  [<c015ccf3>] sys_delete_module+0x191/0x1f1
>>  [<c0147a30>] ? up_read+0x16/0x2a
>>  [<c0102a18>] ? restore_all_notrace+0x0/0x18
>>  [<c0353357>] ? do_page_fault+0x0/0x393
>>  [<c0102904>] sysenter_do_call+0x12/0x32
>> ---[ end trace 8f3eaeee682a572c ]---
>>
>> 	Any thoughts?  I have not as yet investigated further.
>
>Weird.
>
>We have already run:
>rtnl_link_unregister. 
>  rtnl_kill_links
>    dellink(bond0)
>      unregister_netdevice(bond0)
>          bond_uninit
>             bond_remove_proc_entry
>
>
>So the proc entry should no longer be there.  I'm a little nervous about
>the new unregister_netdevice_many but I don't see any obvious problems with
>that code.
>
>Were there by any chance any earlier errors that could have prevented the uninit?
>You weren't inserting multiple copies of the bonding driver?

	No, to both questions.  Also, if I back out the 7 bonding
patches, the same insmod / rmmod does not panic.  

	I just set it up and did it again.  Fresh boot of the system
(which doesn't load bonding); "insmod drivers/net/bonding/bonding.ko;
rmmod bonding" and blammo.

	A little bisect action reveals that the problem first appears
after applying the fifth patch (below).  Does a basic insmod / rmmod
cycle work ok for you?  I'm specifying no options to bonding.

	-J

Subject: [PATCH 5/6] bond: Implement a basic set of rtnl link ops
[...]
This implements a basic set of rtnl link ops and takes advantage of
the fact that rtnl_link_unregister kills all of the surviving
devices to all us to kill bond_free_all.  A module alias
is added so ip link add can pull in the bonding module.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/bonding/bond_main.c |   55 +++++++++++++++++++++-----------------
 1 files changed, 30 insertions(+), 25 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7a37ecf..6da2a82 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4612,22 +4612,6 @@ static void bond_uninit(struct net_device *bond_dev)
 	netif_addr_unlock_bh(bond_dev);
 }

-/* Unregister and free all bond devices.
- * Caller must hold rtnl_lock.
- */
-static void bond_free_all(void)
-{
-	struct bonding *bond, *nxt;
-
-	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
-		struct net_device *bond_dev = bond->dev;
-
-		unregister_netdevice(bond_dev);
-	}
-
-	bond_destroy_proc_dir();
-}
-
 /*------------------------- Module initialization ---------------------------*/

 /*
@@ -5065,6 +5049,23 @@ static int bond_init(struct net_device *bond_dev)
 	return 0;
 }

+static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+			return -EINVAL;
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+			return -EADDRNOTAVAIL;
+	}
+	return 0;
+}
+
+static struct rtnl_link_ops bond_link_ops __read_mostly = {
+	.kind		= "bond",
+	.setup		= bond_setup,
+	.validate	= bond_validate,
+};
+
 /* Create a new bond based on the specified name and bonding parameters.
  * If name is NULL, obtain a suitable "bond%d" name for us.
  * Caller must NOT hold rtnl_lock; we need to release it here before we
@@ -5086,6 +5087,8 @@ int bond_create(const char *name)
 		goto out;
 	}

+	bond_dev->rtnl_link_ops = &bond_link_ops;
+
 	if (!name) {
 		res = dev_alloc_name(bond_dev, "bond%d");
 		if (res < 0)
@@ -5115,6 +5118,10 @@ static int __init bonding_init(void)

 	bond_create_proc_dir();

+	res = rtnl_link_register(&bond_link_ops);
+	if (res)
+		goto err;
+
 	for (i = 0; i < max_bonds; i++) {
 		res = bond_create(NULL);
 		if (res)
@@ -5128,14 +5135,12 @@ static int __init bonding_init(void)
 	register_netdevice_notifier(&bond_netdev_notifier);
 	register_inetaddr_notifier(&bond_inetaddr_notifier);
 	bond_register_ipv6_notifier();
-
-	goto out;
-err:
-	rtnl_lock();
-	bond_free_all();
-	rtnl_unlock();
 out:
 	return res;
+err:
+	rtnl_link_unregister(&bond_link_ops);
+	bond_destroy_proc_dir();
+	goto out;

 }

@@ -5147,9 +5152,8 @@ static void __exit bonding_exit(void)

 	bond_destroy_sysfs();

-	rtnl_lock();
-	bond_free_all();
-	rtnl_unlock();
+	rtnl_link_unregister(&bond_link_ops);
+	bond_destroy_proc_dir();
 }

 module_init(bonding_init);
@@ -5158,3 +5162,4 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 MODULE_DESCRIPTION(DRV_DESCRIPTION ", v" DRV_VERSION);
 MODULE_AUTHOR("Thomas Davis, tadavis@lbl.gov and many others");
+MODULE_ALIAS_RTNL_LINK("bond");
-- 
1.6.3.1.54.g99dd.dirty


---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

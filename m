From: Cong Wang <amwang@redhat.com>
Subject: [Patch V3] bonding: fix potential deadlock in bond_uninit()
Date: Thu, 01 Apr 2010 15:30:52 +0800
Message-ID: <4BB44BAC.2070304@redhat.com>
References: <20100401061014.4815.7341.sendpatchset@localhost.localdomain> <m1r5mzsnuh.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030500060907050404040208"
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65004 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753847Ab0DAH1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 03:27:19 -0400
In-Reply-To: <m1r5mzsnuh.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030500060907050404040208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Eric W. Biederman wrote:
> Amerigo Wang <amwang@redhat.com> writes:
> 
>> bond_uninit() is invoked with rtnl_lock held, when it does destroy_workqueue()
>> which will potentially flush all works in this workqueue, if we hold rtnl_lock
>> again in the work function, it will deadlock.
>>
>> So move destroy_workqueue() to destructor where rtnl_lock is not held any more,
>> suggested by Eric.
> 
> The error handling on creating a bond device needs to be updated as well.
> 

Done.


--------------030500060907050404040208
Content-Type: text/x-patch;
 name="drivers-net-bonding-bond_main_c-fix-destroy_workqueue-deadlock.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="drivers-net-bonding-bond_main_c-fix-destroy_workqueue-deadlo";
 filename*1="ck.diff"

V3: fix error handling path of bond_create()

bond_uninit() is invoked with rtnl_lock held, when it does destroy_workqueue()
which will potentially flush all works in this workqueue, if we hold rtnl_lock
again in the work function, it will deadlock.

So move destroy_workqueue() to destructor where rtnl_lock is not held any more,
suggested by Eric.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Jiri Pirko <jpirko@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>

---

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5b92fbf..61f8c63 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4450,6 +4450,14 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
 };
 
+static void bond_destructor(struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	if (bond->wq)
+		destroy_workqueue(bond->wq);
+	free_netdev(bond_dev);
+}
+
 static void bond_setup(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -4470,7 +4478,7 @@ static void bond_setup(struct net_device *bond_dev)
 	bond_dev->ethtool_ops = &bond_ethtool_ops;
 	bond_set_mode_ops(bond, bond->params.mode);
 
-	bond_dev->destructor = free_netdev;
+	bond_dev->destructor = bond_destructor;
 
 	/* Initialize the device options */
 	bond_dev->tx_queue_len = 0;
@@ -4542,9 +4550,6 @@ static void bond_uninit(struct net_device *bond_dev)
 
 	bond_remove_proc_entry(bond);
 
-	if (bond->wq)
-		destroy_workqueue(bond->wq);
-
 	netif_addr_lock_bh(bond_dev);
 	bond_mc_list_destroy(bond);
 	netif_addr_unlock_bh(bond_dev);
@@ -4956,8 +4961,8 @@ int bond_create(struct net *net, const char *name)
 				bond_setup);
 	if (!bond_dev) {
 		pr_err("%s: eek! can't alloc netdev!\n", name);
-		res = -ENOMEM;
-		goto out;
+		rtnl_unlock();
+		return -ENOMEM;
 	}
 
 	dev_net_set(bond_dev, net);
@@ -4966,19 +4971,16 @@ int bond_create(struct net *net, const char *name)
 	if (!name) {
 		res = dev_alloc_name(bond_dev, "bond%d");
 		if (res < 0)
-			goto out_netdev;
+			goto out;
 	}
 
 	res = register_netdevice(bond_dev);
-	if (res < 0)
-		goto out_netdev;
 
 out:
 	rtnl_unlock();
+	if (res < 0)
+		bond_destructor(bond_dev);
 	return res;
-out_netdev:
-	free_netdev(bond_dev);
-	goto out;
 }
 
 static int __net_init bond_net_init(struct net *net)

--------------030500060907050404040208--

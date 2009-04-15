From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic" trying to ifenslave a second interface to my bond
Date: Tue, 14 Apr 2009 18:12:47 -0700
Message-ID: <11276.1239757967@death.nxdomain.ibm.com>
References: <1239657348.8944.529.camel@psmith-ubeta.netezza.com>
Cc: netdev@vger.kernel.org
To: paul@mad-scientist.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:55000 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424AbZDOBMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 21:12:42 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3F1BDEv020605
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 19:11:13 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3F1Cffx192144
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 19:12:41 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3F1Ce1i028387
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 19:12:40 -0600
In-reply-to: <1239657348.8944.529.camel@psmith-ubeta.netezza.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Smith <paul@mad-scientist.net> wrote:
[...]
>As soon as I try to ifenslave the second interface, Badness Ensues:
>
>        # ifenslave bond0 eth0
>        ------------[ cut here ]------------
>        WARNING: at linux/kernel/sched.c:4303 local_bh_enable_ip+0x2c/0xc0()
>        Modules linked in: rng_core dock scsi_mod libata ata_piix zlib_inflate bnx2 ipmi_msghandler ipmi_si ipmi_devintf bonding
>        Pid: 1552, comm: ifenslave Not tainted 2.6.27.18-WR3.0bg_small #1
>        
>        Call Trace:
>         [<ffffffff8023be34>] warn_on_slowpath+0x64/0xb0
>         [<ffffffff8028654a>] get_page_from_freelist+0x30a/0x640
>         [<ffffffff8041497a>] __dev_get_by_name+0x9a/0xc0
>         [<ffffffff80419a66>] dev_ethtool+0xd46/0x11c0
>         [<ffffffff8027fc7a>] find_get_page+0x9a/0xe0
>         [<ffffffff802800c3>] find_lock_page+0x23/0x80
>         [<ffffffff8024233c>] local_bh_enable_ip+0x2c/0xc0
>         [<ffffffffa00ad780>] bond_alb_set_mac_address+0x2a0/0x2f0 [bonding]
[...]

	I think I know what's going on.  I believe this patch will
resolve things, but I won't be able to test it until tomorrow.  If you
want to test this, great; if you want to wait, that's fine too.

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 8dc6fbb..b22467a 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1708,10 +1708,8 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
  * Called with RTNL
  */
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
-	__releases(&bond->curr_slave_lock)
-	__releases(&bond->lock)
 	__acquires(&bond->lock)
-	__acquires(&bond->curr_slave_lock)
+	__releases(&bond->lock)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct sockaddr *sa = addr;
@@ -1747,9 +1745,6 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 		}
 	}
 
-	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
-
 	if (swap_slave) {
 		alb_swap_mac_addr(bond, swap_slave, bond->curr_active_slave);
 		alb_fasten_mac_swap(bond, swap_slave, bond->curr_active_slave);
@@ -1757,16 +1752,17 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 		alb_set_slave_mac_addr(bond->curr_active_slave, bond_dev->dev_addr,
 				       bond->alb_info.rlb_enabled);
 
-		alb_send_learning_packets(bond->curr_active_slave, bond_dev->dev_addr);
+		read_lock(&bond->lock);
+		alb_send_learning_packets(bond->curr_active_slave,
+					  bond_dev->dev_addr);
 		if (bond->alb_info.rlb_enabled) {
 			/* inform clients mac address has changed */
-			rlb_req_update_slave_clients(bond, bond->curr_active_slave);
+			rlb_req_update_slave_clients(bond,
+						     bond->curr_active_slave);
 		}
+		read_unlock(&bond->lock);
 	}
 
-	read_lock(&bond->lock);
-	write_lock_bh(&bond->curr_slave_lock);
-
 	return 0;
 }
 



	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

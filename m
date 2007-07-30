From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [ofa-general] Re: [PATCH V3 7/7] net/bonding: Delay sending of
	gratuitous ARP to avoid failure
Date: Mon, 30 Jul 2007 13:29:44 -0700
Message-ID: <19319.1185827384@death>
References: <46ADDB89.5030601@voltaire.com> <46ADDFE6.9000609@voltaire.com>
Cc: netdev@vger.kernel.org, rdreier@cisco.com, davem@davemloft.net,
	general@lists.openfabrics.org
To: Moni Shoua <monis@voltaire.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-reply-to: <46ADDFE6.9000609@voltaire.com> 
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


Moni Shoua <monis@voltaire.com> wrote:

>Delay sending a gratuitous_arp when LINK_STATE_LINKWATCH_PENDING bit
>in dev->state field is on. This improves the chances for the arp packet to
>be transmitted.

	Under what circumstances were you seeing problems that delaying
the gratuitous ARP until linkwatch is done improves things?  Is this
really an IB thing, or did you experience problems here over regular
ethernet?

>Signed-off-by: Moni Shoua <monis@voltaire.com>
>---
> drivers/net/bonding/bond_main.c |   25 +++++++++++++++++++++----
> drivers/net/bonding/bonding.h   |    1 +
> 2 files changed, 22 insertions(+), 4 deletions(-)
>
>Index: net-2.6/drivers/net/bonding/bond_main.c
>===================================================================
>--- net-2.6.orig/drivers/net/bonding/bond_main.c	2007-07-25 15:33:25.000000000 +0300
>+++ net-2.6/drivers/net/bonding/bond_main.c	2007-07-26 18:42:59.296296622 +0300
>@@ -1134,8 +1134,13 @@ void bond_change_active_slave(struct bon
> 		if (new_active && !bond->do_set_mac_addr)
> 			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
> 				new_active->dev->addr_len);
>-
>-		bond_send_gratuitous_arp(bond);
>+		if (bond->curr_active_slave &&
>+			test_bit(__LINK_STATE_LINKWATCH_PENDING, &bond->curr_active_slave->dev->state)){
>+			dprintk("delaying gratuitous arp on %s\n",bond->curr_active_slave->dev->name);
>+			bond->send_grat_arp=1;
>+		}else{
>+			bond_send_gratuitous_arp(bond);
>+		}

	Style issues throughout the patch series: many lines are too
long, many things are all smashed together, e.g., "}else{" instead of
"} else {", "send_grat_arp=1" instead of "send_grat_arp = 1", and so on.

> 	}
> }
>
>@@ -2120,6 +2125,15 @@ void bond_mii_monitor(struct net_device 
> 	 * program could monitor the link itself if needed.
> 	 */
>
>+	if (bond->send_grat_arp) {
>+		if (bond->curr_active_slave && test_bit(__LINK_STATE_LINKWATCH_PENDING, &bond->curr_active_slave->dev->state))
>+			dprintk("Needs to send gratuitous arp but not yet\n",__FUNCTION__);
>+		else {
>+			dprintk("sending delayed gratuitous arp on ond->curr_active_slave->dev->name\n");
>+			bond_send_gratuitous_arp(bond);
>+			bond->send_grat_arp=0;
>+		}
>+	}


> 	read_lock(&bond->curr_slave_lock);
> 	oldcurrent = bond->curr_active_slave;
> 	read_unlock(&bond->curr_slave_lock);
>@@ -2513,6 +2527,7 @@ static void bond_send_gratuitous_arp(str
> 	struct slave *slave = bond->curr_active_slave;
> 	struct vlan_entry *vlan;
> 	struct net_device *vlan_dev;
>+	int i;
>
> 	dprintk("bond_send_grat_arp: bond %s slave %s\n", bond->dev->name,
> 				slave ? slave->dev->name : "NULL");
>@@ -2520,8 +2535,9 @@ static void bond_send_gratuitous_arp(str
> 		return;
>
> 	if (bond->master_ip) {
>-		bond_arp_send(slave->dev, ARPOP_REPLY, bond->master_ip,
>-				  bond->master_ip, 0);
>+		for (i=0;i<3;i++)
>+			bond_arp_send(slave->dev, ARPOP_REPLY, bond->master_ip,
>+					  bond->master_ip, 0);
> 	}

	If you delay the grat ARP until linkwatch is done, why is it
also necessary to shotgun several ARPs instead of one?  Why are the ARPs
sent for VLANs not also shotgunned in a similar fashion?

	If shotgunning like this really is useful, would it not make
more sense to space them out a bit, e.g., over successive monitor
passes?

> 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
>@@ -4331,6 +4347,7 @@ static int bond_init(struct net_device *
> 	bond->current_arp_slave = NULL;
> 	bond->primary_slave = NULL;
> 	bond->dev = bond_dev;
>+	bond->send_grat_arp=0;
> 	INIT_LIST_HEAD(&bond->vlan_list);
>
> 	/* Initialize the device entry points */
>Index: net-2.6/drivers/net/bonding/bonding.h
>===================================================================
>--- net-2.6.orig/drivers/net/bonding/bonding.h	2007-07-25 15:20:10.000000000 +0300
>+++ net-2.6/drivers/net/bonding/bonding.h	2007-07-26 18:42:43.652087660 +0300
>@@ -203,6 +203,7 @@ struct bonding {
> 	struct   vlan_group *vlgrp;
> 	struct   packet_type arp_mon_pt;
> 	s8       do_set_mac_addr;
>+	int	 send_grat_arp;

	This need not be a full int, and (this applies to
do_set_mac_addr, also) could probably be squeezed into gaps already
existing within the struct bonding somewhere.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

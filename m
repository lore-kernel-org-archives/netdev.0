From: Moni Shoua <monis@voltaire.com>
Subject: [ofa-general] PATCH V6 7/9] net/bonding: Delay sending of gratuitous
 ARP to avoid failure
Date: Mon, 24 Sep 2007 17:46:12 +0200
Message-ID: <46F7DBC4.2090307@voltaire.com>
References: <46F7D770.4090500@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, OpenFabrics General <general@lists.openfabrics.org>
To: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46F7D770.4090500@voltaire.com>
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

Delay sending a gratuitous_arp when LINK_STATE_LINKWATCH_PENDING bit
in dev->state field is on. This improves the chances for the arp packet to
be transmitted.

Signed-off-by: Moni Shoua <monis at voltaire.com>
---
 drivers/net/bonding/bond_main.c |   24 +++++++++++++++++++++---
 drivers/net/bonding/bonding.h   |    1 +
 2 files changed, 22 insertions(+), 3 deletions(-)

Index: net-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.orig/drivers/net/bonding/bond_main.c	2007-08-15 10:56:33.000000000 +0300
+++ net-2.6/drivers/net/bonding/bond_main.c	2007-08-15 11:04:37.221123652 +0300
@@ -1102,8 +1102,14 @@ void bond_change_active_slave(struct bon
 		if (new_active && !bond->do_set_mac_addr)
 			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
 				new_active->dev->addr_len);
-
-		bond_send_gratuitous_arp(bond);
+		if (bond->curr_active_slave &&
+			test_bit(__LINK_STATE_LINKWATCH_PENDING,
+					&bond->curr_active_slave->dev->state)) {
+			dprintk("delaying gratuitous arp on %s\n",
+				bond->curr_active_slave->dev->name);
+			bond->send_grat_arp = 1;
+		} else
+			bond_send_gratuitous_arp(bond);
 	}
 }
 
@@ -2083,6 +2089,17 @@ void bond_mii_monitor(struct net_device 
 	 * program could monitor the link itself if needed.
 	 */
 
+	if (bond->send_grat_arp) {
+		if (bond->curr_active_slave && test_bit(__LINK_STATE_LINKWATCH_PENDING,
+				&bond->curr_active_slave->dev->state))
+			dprintk("Needs to send gratuitous arp but not yet\n");
+		else {
+			dprintk("sending delayed gratuitous arp on on %s\n",
+				bond->curr_active_slave->dev->name);
+			bond_send_gratuitous_arp(bond);
+			bond->send_grat_arp = 0;
+		}
+	}
 	read_lock(&bond->curr_slave_lock);
 	oldcurrent = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
@@ -2484,7 +2501,7 @@ static void bond_send_gratuitous_arp(str
 
 	if (bond->master_ip) {
 		bond_arp_send(slave->dev, ARPOP_REPLY, bond->master_ip,
-				  bond->master_ip, 0);
+				bond->master_ip, 0);
 	}
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
@@ -4293,6 +4310,7 @@ static int bond_init(struct net_device *
 	bond->current_arp_slave = NULL;
 	bond->primary_slave = NULL;
 	bond->dev = bond_dev;
+	bond->send_grat_arp = 0;
 	INIT_LIST_HEAD(&bond->vlan_list);
 
 	/* Initialize the device entry points */
Index: net-2.6/drivers/net/bonding/bonding.h
===================================================================
--- net-2.6.orig/drivers/net/bonding/bonding.h	2007-08-15 10:56:33.000000000 +0300
+++ net-2.6/drivers/net/bonding/bonding.h	2007-08-15 11:05:41.516451497 +0300
@@ -187,6 +187,7 @@ struct bonding {
 	struct   timer_list arp_timer;
 	s8       kill_timers;
 	s8       do_set_mac_addr;
+	s8	 send_grat_arp;
 	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
 	struct   proc_dir_entry *proc_entry;

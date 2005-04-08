From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.12-rc2 7/17] bonding: per bond my_ip
Date: Fri, 8 Apr 2005 16:54:51 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504081651450.10355@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch makes "my_ip" a per bond variable instead of a global

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>


diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bonding.h linux-2.6.12-rc2/drivers/net/bonding/bonding.h
--- linux-2.6.12-rc2clean/drivers/net/bonding/bonding.h	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bonding.h	2005-04-07 14:05:31.000000000 -0700
@@ -208,6 +208,7 @@
  	struct   bond_params params;
  	struct   list_head vlan_list;
  	struct   vlan_group *vlgrp;
+	u32 	 my_ip;
  };

  /**
diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c linux-2.6.12-rc2/drivers/net/bonding/bond_main.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bond_main.c	2005-04-07 14:35:41.000000000 -0700
@@ -575,7 +575,6 @@

  static u32 arp_target[BOND_MAX_ARP_TARGETS] = { 0, } ;
  static int arp_ip_count	= 0;
-static u32 my_ip	= 0;
  static int bond_mode	= BOND_MODE_ROUNDROBIN;
  static int lacp_fast	= 0;
  static int app_abi_ver	= 0;
@@ -2698,7 +2698,7 @@

  	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && targets[i]; i++) {
  		arp_send(ARPOP_REQUEST, ETH_P_ARP, targets[i], slave->dev,
-			 my_ip, NULL, slave->dev->dev_addr,
+			 bond->my_ip, NULL, slave->dev->dev_addr,
  			 NULL);
  	}
  }
@@ -2778,7 +2777,7 @@
  			 */
  			if (((jiffies - slave->dev->trans_start) >= (2*delta_in_ticks)) ||
  			    (((jiffies - slave->dev->last_rx) >= (2*delta_in_ticks)) &&
-			     my_ip)) {
+			     bond->my_ip)) {

  				slave->link  = BOND_LINK_DOWN;
  				slave->state = BOND_STATE_BACKUP;
@@ -2917,7 +2916,7 @@
  			if ((slave != bond->curr_active_slave) &&
  			    (!bond->current_arp_slave) &&
  			    (((jiffies - slave->dev->last_rx) >= 3*delta_in_ticks) &&
-			     my_ip)) {
+			     bond->my_ip)) {
  				/* a backup slave has gone down; three times
  				 * the delta allows the current slave to be
  				 * taken out before the backup slave.
@@ -2964,7 +2963,7 @@
  		 */
  		if ((((jiffies - slave->dev->trans_start) >= (2*delta_in_ticks)) ||
  		     (((jiffies - slave->dev->last_rx) >= (2*delta_in_ticks)) &&
-		      my_ip)) &&
+		      bond->my_ip)) &&
  		    ((jiffies - slave->jiffies) >= 2*delta_in_ticks)) {

  			slave->link  = BOND_LINK_DOWN;
@@ -3016,7 +3015,7 @@
  		/* the current slave must tx an arp to ensure backup slaves
  		 * rx traffic
  		 */
-		if (slave && my_ip) {
+		if (slave && bond->my_ip) {
  			bond_arp_send_all(bond, slave);
  		}
  	}
@@ -4059,13 +4058,13 @@

  	/* if we are sending arp packets, try to at least
  	   identify our own ip address */
-	if (bond->params.arp_interval && !my_ip &&
+	if (bond->params.arp_interval && !bond->my_ip &&
  		(skb->protocol == __constant_htons(ETH_P_ARP))) {
  		char *the_ip = (char *)skb->data +
  				sizeof(struct ethhdr) +
  				sizeof(struct arphdr) +
  				ETH_ALEN;
-		memcpy(&my_ip, the_ip, 4);
+		memcpy(&bond->my_ip, the_ip, 4);
  	}

  	read_lock(&bond->lock);

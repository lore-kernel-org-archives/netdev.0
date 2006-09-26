From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: [RFC][PATCH 1/3] enable bonding to enslave non ARPHRD_ETHER netdevices
Date: Tue, 26 Sep 2006 13:17:01 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0609261316420.24189@zuben>
References: <Pine.LNX.4.64.0609261309540.24189@zuben>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:61245 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP
	id S1751089AbWIZKRC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 06:17:02 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0609261309540.24189@zuben>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>

Index: net-2.6.19/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.19.orig/drivers/net/bonding/bond_main.c	2006-09-20 14:40:13.000000000 +0300
+++ net-2.6.19/drivers/net/bonding/bond_main.c	2006-09-25 11:43:52.000000000 +0300
@@ -1013,6 +1013,23 @@ static struct slave *bond_find_best_slav
 	return bestslave;
 }

+void bond_setup_by_slave(struct bonding *bond, struct slave *new_active)
+{
+	bond->dev->hard_header	        = new_active->dev->hard_header;
+	bond->dev->rebuild_header       = new_active->dev->rebuild_header;
+	bond->dev->hard_header_cache	= new_active->dev->hard_header_cache;
+	bond->dev->header_cache_update  = new_active->dev->header_cache_update;
+	bond->dev->hard_header_parse	= new_active->dev->hard_header_parse;
+
+	bond->dev->type		    = new_active->dev->type;
+	bond->dev->hard_header_len  = new_active->dev->hard_header_len;
+	bond->dev->mtu		    = new_active->dev->mtu;
+	bond->dev->addr_len	    = new_active->dev->addr_len;
+
+	memcpy(bond->dev->broadcast, new_active->dev->broadcast,
+		new_active->dev->addr_len);
+}
+
 /**
  * change_active_interface - change the active slave into the specified one
  * @bond: our bonding struct
@@ -1091,6 +1108,14 @@ void bond_change_active_slave(struct bon
 		if (new_active) {
 			bond_set_slave_active_flags(new_active);
 		}
+
+		/* bonding netdevices are created with ether_setup, so when the
+		 * slave type is not ARPHRD_ETHER there is a need to override
+		 * some of the type dependent attributes/functions
+		 */
+		if (new_active && new_active->dev->type != ARPHRD_ETHER)
+			bond_setup_by_slave(bond, new_active);
+
 		bond_send_gratuitous_arp(bond);
 	}
 }


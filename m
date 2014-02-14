From: Jiri Bohac <jiri@boha.cz>
Subject: [PATCH] bonding: 802.3ad: make aggregator_identifier bond-private
Date: Fri, 14 Feb 2014 18:13:50 +0100
Message-ID: <20140214171350.GC11688@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60960 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbaBNRNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 12:13:53 -0500
Received: by mail-we0-f174.google.com with SMTP id w61so3222019wes.5
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 09:13:52 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

aggregator_identifier is used to assign unique aggregator identifiers
to aggregators of a bond during device enslaving.

aggregator_identifier is currently a global variable that is zeroed in
bond_3ad_initialize().

This sequence will lead to duplicate aggregator identifiers for eth1 and eth3:

create bond0
change bond0 mode to 802.3ad
enslave eth0 to bond0 		//eth0 gets agg id 1
enslave eth1 to bond0 		//eth1 gets agg id 2
create bond1
change bond1 mode to 802.3ad
enslave eth2 to bond1		//aggregator_identifier is reset to 0
				//eth2 gets agg id 1
enslave eth3 to bond0 		//eth3 gets agg id 2

Fix this by making aggregator_identifier private to the bond.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>
---
 drivers/net/bonding/bond_3ad.c | 6 ++----
 drivers/net/bonding/bond_3ad.h | 1 +
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 4ced594..dcf2ee8 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1806,8 +1806,6 @@ void bond_3ad_initiate_agg_selection(struct bonding *bond, int timeout)
 	BOND_AD_INFO(bond).agg_select_timer = timeout;
 }
 
-static u16 aggregator_identifier;
-
 /**
  * bond_3ad_initialize - initialize a bond's 802.3ad parameters and structures
  * @bond: bonding struct to work on
@@ -1821,7 +1819,7 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution)
 	if (MAC_ADDRESS_COMPARE(&(BOND_AD_INFO(bond).system.sys_mac_addr),
 				bond->dev->dev_addr)) {
 
-		aggregator_identifier = 0;
+		BOND_AD_INFO(bond).aggregator_identifier = 0;
 
 		BOND_AD_INFO(bond).system.sys_priority = 0xFFFF;
 		BOND_AD_INFO(bond).system.sys_mac_addr = *((struct mac_addr *)bond->dev->dev_addr);
@@ -1892,7 +1890,7 @@ int bond_3ad_bind_slave(struct slave *slave)
 		ad_initialize_agg(aggregator);
 
 		aggregator->aggregator_mac_address = *((struct mac_addr *)bond->dev->dev_addr);
-		aggregator->aggregator_identifier = (++aggregator_identifier);
+		aggregator->aggregator_identifier = ++BOND_AD_INFO(bond).aggregator_identifier;
 		aggregator->slave = slave;
 		aggregator->is_active = 0;
 		aggregator->num_of_ports = 0;
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 5d91ad0..1f081c8 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -253,6 +253,7 @@ struct ad_system {
 struct ad_bond_info {
 	struct ad_system system;	    /* 802.3ad system structure */
 	u32 agg_select_timer;	    // Timer to select aggregator after all adapter's hand shakes
+	u16 aggregator_identifier;
 };
 
 struct ad_slave_info {

-- 
Jiri Bohac
e-mail/jabber: jiri@boha.cz

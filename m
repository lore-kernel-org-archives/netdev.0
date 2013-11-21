From: rama nichanamatlu <rama.nichanamatlu@oracle.com>
Subject: [PATCH] bonding: If IP route look-up to send an ARP fails, mark in
 bonding structure as no ARP sent.
Date: Wed, 20 Nov 2013 17:36:18 -0800
Message-ID: <528D6392.30101@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050903070101020809090303"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40949 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab3KUBgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 20:36:22 -0500
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id rAL1aKJc020025
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 01:36:21 GMT
Received: from aserz7021.oracle.com (aserz7021.oracle.com [141.146.126.230])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id rAL1aKtZ007167
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 01:36:20 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by aserz7021.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id rAL1aKqD029945
	for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 01:36:20 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050903070101020809090303
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

During the creation of VLAN's atop bonding the underlying interfaces are
made part of VLAN's, and at the same bonding driver gets aware that
VLAN's exists above it and hence would consult IP routing for every ARP
to  be sent to determine the route which tells bonding driver the
correct VLAN tag to attach to the outgoing ARP packet. But, during the
VLAN creation when vlan driver puts the underlying interface into
default vlan and then actual vlan, in-between this if bonding driver
consults the IP for a route, IP fails to provide a correct route and
upon which bonding driver drops the ARP packet. ARP monitor when it
comes around next time, sees no ARP response and fails-over to the next
available slave. Consulting for a IP route, ip_route_output(),happens in
bond_arp_send_all().

To prevent this false fail-over, when bonding driver fails to send an
ARP out it marks in its private structure, bonding{},  not to expect an
ARP response, when ARP monitor comes around next time ARP sending will
be tried again.

Extensively tested in a VM environment; sr-iov intf->bonding intf->vlan
intf. All virtual interfaces created at boot time.

Orabug: 17172660
Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Signed-off-by: Rama Nichanamatlu <rama.nichanamatlu@oracle.com>
---
 drivers/net/bonding/bond_main.c | 13 ++++++++-----
 drivers/net/bonding/bonding.h   |  1 +
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c
b/drivers/net/bonding/bond_main.c
index dde6b4a..d475161 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2661,7 +2661,7 @@ static int bond_has_this_ip(struct bonding *bond,
__be32 ip)
  * switches in VLAN mode (especially if ports are configured as
  * "native" to a VLAN) might not pass non-tagged frames.
  */
-static void bond_arp_send(struct net_device *slave_dev, int arp_op,
__be32 dest_ip, __be32 src_ip, unsigned short vlan_id)
+static void bond_arp_send(struct bonding *bond, struct net_device
*slave_dev, int arp_op, __be32 dest_ip, __be32 src_ip, unsigned short
vlan_id)
 {
 	struct sk_buff *skb;
 @@ -2683,6 +2683,7 @@ static void bond_arp_send(struct net_device
*slave_dev, int arp_op, __be32 dest_
 		}
 	}
 	arp_xmit(skb);
+	bond->arp_sent=true;
 }
  @@ -2700,7 +2701,7 @@ static void bond_arp_send_all(struct bonding
*bond, struct slave *slave)
 		pr_debug("basa: target %x\n", targets[i]);
 		if (!bond->vlgrp) {
 			pr_debug("basa: empty vlan: arp_send\n");
-			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
+			bond_arp_send(bond, slave->dev, ARPOP_REQUEST, targets[i],
 				      bond->master_ip, 0);
 			continue;
 		}
@@ -2726,7 +2727,7 @@ static void bond_arp_send_all(struct bonding
*bond, struct slave *slave)
 		if (rt->dst.dev == bond->dev) {
 			ip_rt_put(rt);
 			pr_debug("basa: rtdev == bond->dev: arp_send\n");
-			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
+			bond_arp_send(bond, slave->dev, ARPOP_REQUEST, targets[i],
 				      bond->master_ip, 0);
 			continue;
 		}
@@ -2744,7 +2745,7 @@ static void bond_arp_send_all(struct bonding
*bond, struct slave *slave)
  		if (vlan_id) {
 			ip_rt_put(rt);
-			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
+			bond_arp_send(bond, slave->dev, ARPOP_REQUEST, targets[i],
 				      vlan->vlan_ip, vlan_id);
 			continue;
 		}
@@ -3206,7 +3207,7 @@ void bond_activebackup_arp_mon(struct work_struct
*work)
  	should_notify_peers = bond_should_notify_peers(bond);
 -	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
+	if (bond->arp_sent && bond_ab_arp_inspect(bond, delta_in_ticks)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
 		read_lock(&bond->lock);
@@ -3218,6 +3219,7 @@ void bond_activebackup_arp_mon(struct work_struct
*work)
 		read_lock(&bond->lock);
 	}
 +	bond->arp_sent=false;
 	bond_ab_arp_probe(bond);
  re_arm:
@@ -4425,6 +4427,7 @@ static void bond_setup(struct net_device *bond_dev)
  	bond_dev->hw_features &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_NO_CSUM);
 	bond_dev->features |= bond_dev->hw_features;
+	bond->arp_sent=false;
 }
  static void bond_work_cancel_all(struct bonding *bond)
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index e9a3c56..3878bbd 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -253,6 +253,7 @@ struct bonding {
 	/* debugging suport via debugfs */
 	struct	 dentry *debug_dir;
 #endif /* CONFIG_DEBUG_FS */
+        bool arp_sent;
 };
  #define bond_slave_get_rcu(dev) \
-- 
1.8.2.1


--------------050903070101020809090303
Content-Type: text/plain; charset=windows-1252;
 name="Attached Message Part"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="Attached Message Part"


--------------050903070101020809090303--

From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH REPOST 1/10] bonding: Allow bonding to enslave a 10 Gig adapter
Date: Fri, 22 Sep 2006 21:52:15 -0700
Message-ID: <200609230452.k8N4qFZt027590@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:61151 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750960AbWIWEwT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 00:52:19 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8N4qJtG003949
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:52:19 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8N4qIct241492
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 22:52:18 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8N4qIKE009641
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 22:52:18 -0600
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Allow channel bonding to enslave a 10 Gig adapter without errors.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>

diff -urpN -X linux-2.6.18-rc4-clean/Documentation/dontdiff linux-2.6.18-rc4-clean/drivers/net/bonding/bond_3ad.c linux-2.6.18-rc4/drivers/net/bonding/bond_3ad.c
--- linux-2.6.18-rc4-clean/drivers/net/bonding/bond_3ad.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.18-rc4/drivers/net/bonding/bond_3ad.c	2006-08-30 11:31:45.000000000 -0700
@@ -85,6 +85,7 @@
 #define     AD_LINK_SPEED_BITMASK_10MBPS      0x2
 #define     AD_LINK_SPEED_BITMASK_100MBPS     0x4
 #define     AD_LINK_SPEED_BITMASK_1000MBPS    0x8
+#define     AD_LINK_SPEED_BITMASK_10000MBPS   0x10
 //endalloun
 
 // compare MAC addresses
@@ -330,7 +331,8 @@ static inline void __release_rx_machine_
  *     0,
  *     %AD_LINK_SPEED_BITMASK_10MBPS,
  *     %AD_LINK_SPEED_BITMASK_100MBPS,
- *     %AD_LINK_SPEED_BITMASK_1000MBPS
+ *     %AD_LINK_SPEED_BITMASK_1000MBPS,
+ *     %AD_LINK_SPEED_BITMASK_10000MBPS
  */
 static u16 __get_link_speed(struct port *port)
 {
@@ -357,6 +359,10 @@ static u16 __get_link_speed(struct port
 			speed = AD_LINK_SPEED_BITMASK_1000MBPS;
 			break;
 
+		case SPEED_10000:
+			speed = AD_LINK_SPEED_BITMASK_10000MBPS;
+			break;
+
 		default:
 			speed = 0; // unknown speed value from ethtool. shouldn't happen
 			break;
@@ -775,6 +781,9 @@ static u32 __get_agg_bandwidth(struct ag
 		case AD_LINK_SPEED_BITMASK_1000MBPS:
 			bandwidth = aggregator->num_of_ports * 1000;
 			break;
+		case AD_LINK_SPEED_BITMASK_10000MBPS:
+			bandwidth = aggregator->num_of_ports * 10000;
+			break;
 		default:
 			bandwidth=0; // to silent the compilor ....
 		}
diff -urpN -X linux-2.6.18-rc4-clean/Documentation/dontdiff linux-2.6.18-rc4-clean/drivers/net/bonding/bond_main.c linux-2.6.18-rc4/drivers/net/bonding/bond_main.c
--- linux-2.6.18-rc4-clean/drivers/net/bonding/bond_main.c	2006-08-21 13:28:43.000000000 -0700
+++ linux-2.6.18-rc4/drivers/net/bonding/bond_main.c	2006-08-30 10:49:37.000000000 -0700
@@ -638,6 +638,7 @@ verify:
 	case SPEED_10:
 	case SPEED_100:
 	case SPEED_1000:
+	case SPEED_10000:
 		break;
 	default:
 		return -1;

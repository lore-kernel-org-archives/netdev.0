From: sfeldma@gmail.com
Subject: [PATCH net-next 13/18] switchdev: remove unused NETIF_F_HW_SWITCH_OFFLOAD
Date: Mon, 30 Mar 2015 01:40:31 -0700
Message-ID: <1427704836-8776-14-git-send-email-sfeldma@gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35200 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392AbbC3Ij7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 04:39:59 -0400
Received: by patj18 with SMTP id j18so4805008pat.2
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 01:39:58 -0700 (PDT)
In-Reply-To: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Flag is no longer needed so remove it.  Using the attr get/set recurse algo
obsoletes the flag.  Setting the flag on bond/team interface, even when the
consitient member ports didn't have flag set was confusing.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/bonding/bond_main.c      |    5 +----
 drivers/net/ethernet/rocker/rocker.c |    3 +--
 drivers/net/team/team.c              |    2 +-
 include/linux/netdev_features.h      |    5 +----
 net/core/ethtool.c                   |    1 -
 5 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9d823b6..f6f4c9c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1013,10 +1013,7 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 	netdev_features_t mask;
 	struct slave *slave;
 
-	/* If any slave has the offload feature flag set,
-	 * set the offload flag on the bond.
-	 */
-	mask = features | NETIF_F_HW_SWITCH_OFFLOAD;
+	mask = features;
 
 	features &= ~NETIF_F_ONE_FOR_ALL;
 	features |= NETIF_F_ALL_FOR_ALL;
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 475ce93..9510525 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4617,8 +4617,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_carrier_init(rocker_port);
 
 	dev->features |= NETIF_F_NETNS_LOCAL |
-			 NETIF_F_HW_VLAN_CTAG_FILTER |
-			 NETIF_F_HW_SWITCH_OFFLOAD;
+			 NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	err = register_netdev(dev);
 	if (err) {
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 101b341..fecc6fe 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1924,7 +1924,7 @@ static netdev_features_t team_fix_features(struct net_device *dev,
 	struct team *team = netdev_priv(dev);
 	netdev_features_t mask;
 
-	mask = features | NETIF_F_HW_SWITCH_OFFLOAD;
+	mask = features;
 	features &= ~NETIF_F_ONE_FOR_ALL;
 	features |= NETIF_F_ALL_FOR_ALL;
 
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 7d59dc6..9672781 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -66,7 +66,6 @@ enum {
 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
 	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
-	NETIF_F_HW_SWITCH_OFFLOAD_BIT,  /* HW switch offload */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -125,7 +124,6 @@ enum {
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
-#define NETIF_F_HW_SWITCH_OFFLOAD	__NETIF_F(HW_SWITCH_OFFLOAD)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
@@ -161,8 +159,7 @@ enum {
  */
 #define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST | \
 				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
-				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED | \
-				 NETIF_F_HW_SWITCH_OFFLOAD)
+				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED)
 
 /*
  * If one device doesn't support one of these features, then disable it
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1d00b89..eb0c3ac 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -98,7 +98,6 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_RXALL_BIT] =            "rx-all",
 	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
 	[NETIF_F_BUSY_POLL_BIT] =        "busy-poll",
-	[NETIF_F_HW_SWITCH_OFFLOAD_BIT] = "hw-switch-offload",
 };
 
 static const char
-- 
1.7.10.4

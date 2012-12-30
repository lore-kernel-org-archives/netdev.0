From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/15] nes: remove usage of dev->master
Date: Sun, 30 Dec 2012 12:58:19 +0100
Message-ID: <1356868702-8144-13-git-send-email-jiri@resnulli.us>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com,
	shemminger@vyatta.com, fbl@redhat.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ebiederm@xmission.com, joe@perches.com, amwang@redhat.com,
	nhorman@tuxdriver.com, john.r.fastabend@intel.com,
	pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:40345 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558Ab2L3MAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 07:00:54 -0500
Received: by mail-ea0-f170.google.com with SMTP id d11so4762065eaa.1
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 04:00:53 -0800 (PST)
In-Reply-To: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/infiniband/hw/nes/nes.c    | 8 +++++---
 drivers/infiniband/hw/nes/nes_cm.c | 2 +-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes.c b/drivers/infiniband/hw/nes/nes.c
index 748db2d..d129c36 100644
--- a/drivers/infiniband/hw/nes/nes.c
+++ b/drivers/infiniband/hw/nes/nes.c
@@ -135,6 +135,7 @@ static int nes_inetaddr_event(struct notifier_block *notifier,
 	struct net_device *event_netdev = ifa->ifa_dev->dev;
 	struct nes_device *nesdev;
 	struct net_device *netdev;
+	struct net_device *upper_dev;
 	struct nes_vnic *nesvnic;
 	unsigned int is_bonded;
 
@@ -145,8 +146,9 @@ static int nes_inetaddr_event(struct notifier_block *notifier,
 				nesdev, nesdev->netdev[0]->name);
 		netdev = nesdev->netdev[0];
 		nesvnic = netdev_priv(netdev);
+		upper_dev = netdev_master_upper_dev_get(netdev);
 		is_bonded = netif_is_bond_slave(netdev) &&
-			    (netdev->master == event_netdev);
+			    (upper_dev == event_netdev);
 		if ((netdev == event_netdev) || is_bonded) {
 			if (nesvnic->rdma_enabled == 0) {
 				nes_debug(NES_DBG_NETDEV, "Returning without processing event for %s since"
@@ -179,9 +181,9 @@ static int nes_inetaddr_event(struct notifier_block *notifier,
 					/* fall through */
 				case NETDEV_CHANGEADDR:
 					/* Add the address to the IP table */
-					if (netdev->master)
+					if (upper_dev)
 						nesvnic->local_ipaddr =
-							((struct in_device *)netdev->master->ip_ptr)->ifa_list->ifa_address;
+							((struct in_device *)upper_dev->ip_ptr)->ifa_list->ifa_address;
 					else
 						nesvnic->local_ipaddr = ifa->ifa_address;
 
diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index 22ea67e..ca6fbae 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -1340,7 +1340,7 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 	}
 
 	if (netif_is_bond_slave(nesvnic->netdev))
-		netdev = nesvnic->netdev->master;
+		netdev = netdev_unique_upper_dev_get(nesvnic->netdev);
 	else
 		netdev = nesvnic->netdev;
 
-- 
1.8.0

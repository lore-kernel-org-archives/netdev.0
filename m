From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/16] nes: remove usage of dev->master
Date: Mon, 13 Aug 2012 17:27:11 +0200
Message-ID: <1344871635-1052-13-git-send-email-jiri@resnulli.us>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, faisal.latif@intel.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net, divy@chelsio.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, kaber@trash.net, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, linux390@de.ibm.com,
	shemminger@vyatta.com, bhutchings@solarflare.com,
	therbert@google.com, xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org,
	fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/infiniband/hw/nes/nes.c    |    8 +++++---
 drivers/infiniband/hw/nes/nes_cm.c |    2 +-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes.c b/drivers/infiniband/hw/nes/nes.c
index 7140199..e58e9af 100644
--- a/drivers/infiniband/hw/nes/nes.c
+++ b/drivers/infiniband/hw/nes/nes.c
@@ -140,6 +140,7 @@ static int nes_inetaddr_event(struct notifier_block *notifier,
 	struct net_device *event_netdev = ifa->ifa_dev->dev;
 	struct nes_device *nesdev;
 	struct net_device *netdev;
+	struct net_device *upper_dev;
 	struct nes_vnic *nesvnic;
 	unsigned int is_bonded;
 
@@ -150,8 +151,9 @@ static int nes_inetaddr_event(struct notifier_block *notifier,
 				nesdev, nesdev->netdev[0]->name);
 		netdev = nesdev->netdev[0];
 		nesvnic = netdev_priv(netdev);
+		upper_dev = netdev_unique_upper_dev_get(netdev);
 		is_bonded = netif_is_bond_slave(netdev) &&
-			    (netdev->master == event_netdev);
+			    (upper_dev == event_netdev);
 		if ((netdev == event_netdev) || is_bonded) {
 			if (nesvnic->rdma_enabled == 0) {
 				nes_debug(NES_DBG_NETDEV, "Returning without processing event for %s since"
@@ -184,9 +186,9 @@ static int nes_inetaddr_event(struct notifier_block *notifier,
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
index 020e95c..15e6340 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -1352,7 +1352,7 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 	}
 
 	if (netif_is_bond_slave(nesvnic->netdev))
-		netdev = nesvnic->netdev->master;
+		netdev = netdev_unique_upper_dev_get(nesvnic->netdev);
 	else
 		netdev = nesvnic->netdev;
 
-- 
1.7.10.4

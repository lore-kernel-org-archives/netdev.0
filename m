From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 07/17] benet: Replace ndo_add/del_vxlan_port
 with ndo_add/del_udp_enc_port
Date: Wed, 15 Jun 2016 15:08:00 -0700
Message-ID: <20160615220800.15575.38275.stgit@localhost.localdomain>
References: <20160615220449.15575.17031.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, eugenia@mellanox.com,
	jbenc@redhat.com, alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com,
	davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34460 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640AbcFOWIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 18:08:02 -0400
Received: by mail-pf0-f178.google.com with SMTP id 62so12748785pfd.1
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 15:08:02 -0700 (PDT)
In-Reply-To: <20160615220449.15575.17031.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the network device operations for adding or removing a
VXLAN port with operations that are more generically defined to be used for
any UDP offload port but provide a type.  As such by just adding a line to
verify that the offload type if VXLAN we can maintain the same
functionality.

I have also gone though and removed the BE2NET_VXLAN config option since it
no longer relies on the VXLAN code anyway.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/emulex/benet/Kconfig   |    8 -------
 drivers/net/ethernet/emulex/benet/be_main.c |   32 +++++++++++++--------------
 2 files changed, 15 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/Kconfig b/drivers/net/ethernet/emulex/benet/Kconfig
index 7108563260ae..b4853ec9de8d 100644
--- a/drivers/net/ethernet/emulex/benet/Kconfig
+++ b/drivers/net/ethernet/emulex/benet/Kconfig
@@ -13,11 +13,3 @@ config BE2NET_HWMON
 	---help---
 	  Say Y here if you want to expose thermal sensor data on
 	  be2net network adapter.
-
-config BE2NET_VXLAN
-        bool "VXLAN offload support on be2net driver"
-        default y
-        depends on BE2NET && VXLAN && !(BE2NET=y && VXLAN=m)
-        ---help---
-	  Say Y here if you want to enable VXLAN offload support on
-	  be2net driver.
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2451a47e88ab..3d947897bb6a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3625,10 +3625,8 @@ static int be_open(struct net_device *netdev)
 		be_link_status_update(adapter, link_status);
 
 	netif_tx_start_all_queues(netdev);
-#ifdef CONFIG_BE2NET_VXLAN
 	if (skyhawk_chip(adapter))
-		vxlan_get_rx_port(netdev);
-#endif
+		udp_tunnel_get_rx_info(netdev);
 
 	return 0;
 err:
@@ -3755,7 +3753,6 @@ static void be_cancel_err_detection(struct be_adapter *adapter)
 	}
 }
 
-#ifdef CONFIG_BE2NET_VXLAN
 static void be_disable_vxlan_offloads(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -3774,7 +3771,6 @@ static void be_disable_vxlan_offloads(struct be_adapter *adapter)
 	netdev->hw_features &= ~(NETIF_F_GSO_UDP_TUNNEL);
 	netdev->features &= ~(NETIF_F_GSO_UDP_TUNNEL);
 }
-#endif
 
 static void be_calculate_vf_res(struct be_adapter *adapter, u16 num_vfs,
 				struct be_resources *vft_res)
@@ -3875,9 +3871,7 @@ static int be_clear(struct be_adapter *adapter)
 					&vft_res);
 	}
 
-#ifdef CONFIG_BE2NET_VXLAN
 	be_disable_vxlan_offloads(adapter);
-#endif
 	kfree(adapter->pmac_id);
 	adapter->pmac_id = NULL;
 
@@ -4705,7 +4699,6 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				       0, 0, nlflags, filter_mask, NULL);
 }
 
-#ifdef CONFIG_BE2NET_VXLAN
 /* VxLAN offload Notes:
  *
  * The stack defines tunnel offload flags (hw_enc_features) for IP and doesn't
@@ -4720,13 +4713,17 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
  * adds more than one port, disable offloads and don't re-enable them again
  * until after all the tunnels are removed.
  */
-static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
-			      __be16 port)
+static void be_add_vxlan_port(struct net_device *netdev,
+			      struct udp_tunnel_info *ti)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct device *dev = &adapter->pdev->dev;
+	__be16 port = ti->port;
 	int status;
 
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
 	if (lancer_chip(adapter) || BEx_chip(adapter) || be_is_mc(adapter))
 		return;
 
@@ -4774,10 +4771,14 @@ err:
 	be_disable_vxlan_offloads(adapter);
 }
 
-static void be_del_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
-			      __be16 port)
+static void be_del_vxlan_port(struct net_device *netdev,
+			      struct udp_tunnel_info *ti)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	__be16 port = ti->port;
+
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
 
 	if (lancer_chip(adapter) || BEx_chip(adapter) || be_is_mc(adapter))
 		return;
@@ -4839,7 +4840,6 @@ static netdev_features_t be_features_check(struct sk_buff *skb,
 
 	return features;
 }
-#endif
 
 static int be_get_phys_port_id(struct net_device *dev,
 			       struct netdev_phys_item_id *ppid)
@@ -4887,11 +4887,9 @@ static const struct net_device_ops be_netdev_ops = {
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll		= be_busy_poll,
 #endif
-#ifdef CONFIG_BE2NET_VXLAN
-	.ndo_add_vxlan_port	= be_add_vxlan_port,
-	.ndo_del_vxlan_port	= be_del_vxlan_port,
+	.ndo_udp_tunnel_add	= be_add_vxlan_port,
+	.ndo_udp_tunnel_del	= be_del_vxlan_port,
 	.ndo_features_check	= be_features_check,
-#endif
 	.ndo_get_phys_port_id   = be_get_phys_port_id,
 };
 

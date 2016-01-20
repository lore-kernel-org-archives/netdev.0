From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: i40e: avoid unused function warnings
Date: Wed, 20 Jan 2016 11:42:26 +0100
Message-ID: <2806620.EpZqDlZTO3@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The addition of the geneve tunnel offload code left a couple
of functions unconditionally defined but empty whenever CONFIG_VXLAN
and CONFIG_GENEVE are disabled. gcc warns about this:

i40e_main.c:7049:13: warning: 'i40e_sync_udp_filters_subtask' defined but not used [-Wunused-function]
i40e_main.c:8516:13: warning: 'i40e_add_vxlan_port' defined but not used [-Wunused-function]
i40e_main.c:8561:13: warning: 'i40e_del_vxlan_port' defined but not used [-Wunused-function]
i40e_main.c:8596:13: warning: 'i40e_add_geneve_port' defined but not used [-Wunused-function]
i40e_main.c:8643:13: warning: 'i40e_del_geneve_port' defined but not used [-Wunused-function]

This moves the #ifdef statements to the outside of the affected
functions, which avoids the warnings.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 6a899024058d ("i40e: geneve tunnel offload support")
---
This is a harmless regression against v4.4, found on ARM randconfig builds

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index bb4612c159fd..49ab0426b773 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7056,7 +7056,6 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
  **/
 static void i40e_sync_udp_filters_subtask(struct i40e_pf *pf)
 {
-#if IS_ENABLED(CONFIG_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
 	struct i40e_hw *hw = &pf->hw;
 	i40e_status ret;
 	__be16 port;
@@ -7090,7 +7089,6 @@ static void i40e_sync_udp_filters_subtask(struct i40e_pf *pf)
 			}
 		}
 	}
-#endif
 }
 
 /**
@@ -7117,9 +7115,8 @@ static void i40e_service_task(struct work_struct *work)
 	i40e_watchdog_subtask(pf);
 	i40e_fdir_reinit_subtask(pf);
 	i40e_sync_filters_subtask(pf);
-#if IS_ENABLED(CONFIG_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
-	i40e_sync_udp_filters_subtask(pf);
-#endif
+	if (IS_ENABLED(CONFIG_VXLAN) || IS_ENABLED(CONFIG_GENEVE))
+		i40e_sync_udp_filters_subtask(pf);
 	i40e_clean_adminq_subtask(pf);
 
 	i40e_service_event_complete(pf);
@@ -8515,6 +8512,7 @@ static u8 i40e_get_udp_port_idx(struct i40e_pf *pf, __be16 port)
 }
 
 #endif
+#if IS_ENABLED(CONFIG_VXLAN)
 /**
  * i40e_add_vxlan_port - Get notifications about VXLAN ports that come up
  * @netdev: This physical port's netdev
@@ -8524,7 +8522,6 @@ static u8 i40e_get_udp_port_idx(struct i40e_pf *pf, __be16 port)
 static void i40e_add_vxlan_port(struct net_device *netdev,
 				sa_family_t sa_family, __be16 port)
 {
-#if IS_ENABLED(CONFIG_VXLAN)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8557,7 +8554,6 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 	pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_VXLAN;
 	pf->pending_udp_bitmap |= BIT_ULL(next_idx);
 	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
-#endif
 }
 
 /**
@@ -8569,7 +8565,6 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 static void i40e_del_vxlan_port(struct net_device *netdev,
 				sa_family_t sa_family, __be16 port)
 {
-#if IS_ENABLED(CONFIG_VXLAN)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8592,9 +8587,10 @@ static void i40e_del_vxlan_port(struct net_device *netdev,
 		netdev_warn(netdev, "vxlan port %d was not found, not deleting\n",
 			    ntohs(port));
 	}
-#endif
 }
+#endif
 
+#if IS_ENABLED(CONFIG_GENEVE)
 /**
  * i40e_add_geneve_port - Get notifications about GENEVE ports that come up
  * @netdev: This physical port's netdev
@@ -8604,7 +8600,6 @@ static void i40e_del_vxlan_port(struct net_device *netdev,
 static void i40e_add_geneve_port(struct net_device *netdev,
 				 sa_family_t sa_family, __be16 port)
 {
-#if IS_ENABLED(CONFIG_GENEVE)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8639,7 +8634,6 @@ static void i40e_add_geneve_port(struct net_device *netdev,
 	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
 
 	dev_info(&pf->pdev->dev, "adding geneve port %d\n", ntohs(port));
-#endif
 }
 
 /**
@@ -8651,7 +8645,6 @@ static void i40e_add_geneve_port(struct net_device *netdev,
 static void i40e_del_geneve_port(struct net_device *netdev,
 				 sa_family_t sa_family, __be16 port)
 {
-#if IS_ENABLED(CONFIG_GENEVE)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8677,8 +8670,8 @@ static void i40e_del_geneve_port(struct net_device *netdev,
 		netdev_warn(netdev, "geneve port %d was not found, not deleting\n",
 			    ntohs(port));
 	}
-#endif
 }
+#endif
 
 static int i40e_get_phys_port_id(struct net_device *netdev,
 				 struct netdev_phys_item_id *ppid)

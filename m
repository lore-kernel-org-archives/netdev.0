From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40evf: Fix link state event handling
Date: Tue, 20 Sep 2016 20:43:48 -0700
Message-ID: <1474429432-102772-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:33017 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754852AbcIUDn6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 23:43:58 -0400
In-Reply-To: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

Currently disabling the link state from PF via
	ip link set enp5s0f0 vf 0 state disable
doesn't disable the CARRIER on the VF.

This patch updates the carrier and starts/stops the tx queues based on the
link state notification from PF.

  PF: enp5s0f0, VF: enp5s2
  #modprobe i40e
  #echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
  #ip link set enp5s2 up
  #ip -d link show enp5s2
  175: enp5s2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
      link/ether ea:4d:60:bc:6f:85 brd ff:ff:ff:ff:ff:ff promiscuity 0 addrgenmode eui64
  #ip link set enp5s0f0 vf 0 state disable
  #ip -d link show enp5s0f0
  171: enp5s0f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
      link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff promiscuity 0 addrgenmode eui64 numtxqueues 72 numrxqueues 72 portid 6805ca2e7268
      vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state disable, trust off
      vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off
  #ip -d link show enp5s2
  175: enp5s2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DEFAULT group default qlen 1000
       link/ether ea:4d:60:bc:6f:85 brd ff:ff:ff:ff:ff:ff promiscuity 0 addrgenmode eui64 numtxqueues 16 numrxqueues 16

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c     |  4 ++++
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 10 +++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index f751f7b..e0a8cd8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1037,6 +1037,7 @@ void i40evf_down(struct i40evf_adapter *adapter)
 
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
+	adapter->link_up = false;
 	i40evf_napi_disable_all(adapter);
 	i40evf_irq_disable(adapter);
 
@@ -1731,6 +1732,7 @@ static void i40evf_reset_task(struct work_struct *work)
 			set_bit(__I40E_DOWN, &adapter->vsi.state);
 			netif_carrier_off(netdev);
 			netif_tx_disable(netdev);
+			adapter->link_up = false;
 			i40evf_napi_disable_all(adapter);
 			i40evf_irq_disable(adapter);
 			i40evf_free_traffic_irqs(adapter);
@@ -1769,6 +1771,7 @@ continue_reset:
 	if (netif_running(adapter->netdev)) {
 		netif_carrier_off(netdev);
 		netif_tx_stop_all_queues(netdev);
+		adapter->link_up = false;
 		i40evf_napi_disable_all(adapter);
 	}
 	i40evf_irq_disable(adapter);
@@ -2457,6 +2460,7 @@ static void i40evf_init_task(struct work_struct *work)
 		goto err_sw_init;
 
 	netif_carrier_off(netdev);
+	adapter->link_up = false;
 
 	if (!adapter->netdev_registered) {
 		err = register_netdev(netdev);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index cc6cb30..ddf478d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -898,8 +898,14 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 			    vpe->event_data.link_event.link_status) {
 				adapter->link_up =
 					vpe->event_data.link_event.link_status;
+				if (adapter->link_up) {
+					netif_tx_start_all_queues(netdev);
+					netif_carrier_on(netdev);
+				} else {
+					netif_tx_stop_all_queues(netdev);
+					netif_carrier_off(netdev);
+				}
 				i40evf_print_link_message(adapter);
-				netif_tx_stop_all_queues(netdev);
 			}
 			break;
 		case I40E_VIRTCHNL_EVENT_RESET_IMPENDING:
@@ -974,8 +980,6 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 	case I40E_VIRTCHNL_OP_ENABLE_QUEUES:
 		/* enable transmits */
 		i40evf_irq_enable(adapter, true);
-		netif_tx_start_all_queues(adapter->netdev);
-		netif_carrier_on(adapter->netdev);
 		break;
 	case I40E_VIRTCHNL_OP_DISABLE_QUEUES:
 		i40evf_free_all_tx_resources(adapter);
-- 
2.7.4

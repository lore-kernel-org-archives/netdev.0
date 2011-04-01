From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 5/9 net-next-2.6] qlcnic: Changes to VLAN code
Date: Thu, 31 Mar 2011 21:37:34 -0700
Message-ID: <alpine.OSX.2.00.1103312136390.47460@n5102mn2hhgf91.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1outboundpool.messaging.microsoft.com ([216.32.181.181]:15380
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750747Ab1DAEic convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2011 00:38:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Incorporated changes to comply with reworked VLAN infrastructure in kernel

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    4 ++-
 drivers/net/qlcnic/qlcnic_init.c |   15 ++++++-------
 drivers/net/qlcnic/qlcnic_main.c |   42 ++++++++++++++++++++++---------------
 3 files changed, 35 insertions(+), 26 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index a5b28d1..be9c329 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -29,6 +29,8 @@

 #include <linux/io.h>
 #include <asm/byteorder.h>
+#include <linux/bitops.h>
+#include <linux/if_vlan.h>

 #include "qlcnic_hdr.h"

@@ -982,8 +984,8 @@ struct qlcnic_adapter {
        u8 mac_addr[ETH_ALEN];

        u64 dev_rst_time;
+       unsigned long vlans[BITS_TO_LONGS(VLAN_N_VID)];

-       struct vlan_group *vlgrp;
        struct qlcnic_npar_info *npars;
        struct qlcnic_eswitch *eswitch;
        struct qlcnic_nic_template *nic_ops;
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 476ea14..74ec96d 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1467,10 +1467,10 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter,

        skb->protocol = eth_type_trans(skb, netdev);

-       if ((vid != 0xffff) && adapter->vlgrp)
-               vlan_gro_receive(&sds_ring->napi, adapter->vlgrp, vid, skb);
-       else
-               napi_gro_receive(&sds_ring->napi, skb);
+       if (vid != 0xffff)
+               __vlan_hwaccel_put_tag(skb, vid);
+
+       napi_gro_receive(&sds_ring->napi, skb);

        adapter->stats.rx_pkts++;
        adapter->stats.rxbytes += length;
@@ -1552,10 +1552,9 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,

        length = skb->len;

-       if ((vid != 0xffff) && adapter->vlgrp)
-               vlan_hwaccel_receive_skb(skb, adapter->vlgrp, vid);
-       else
-               netif_receive_skb(skb);
+       if (vid != 0xffff)
+               __vlan_hwaccel_put_tag(skb, vid);
+       netif_receive_skb(skb);

        adapter->stats.lro_pkts++;
        adapter->stats.lrobytes += length;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 3b740f5..b75aef0 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -13,7 +13,6 @@

 #include <linux/swab.h>
 #include <linux/dma-mapping.h>
-#include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <linux/ipv6.h>
 #include <linux/inetdevice.h>
@@ -98,6 +97,9 @@ static int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
 static int qlcnicvf_start_firmware(struct qlcnic_adapter *);
 static void qlcnic_set_netdev_features(struct qlcnic_adapter *,
                                struct qlcnic_esw_func_cfg *);
+static void qlcnic_vlan_rx_add(struct net_device *, u16);
+static void qlcnic_vlan_rx_del(struct net_device *, u16);
+
 /*  PCI Device ID Table  */
 #define ENTRY(device) \
        {PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, (device)), \
@@ -317,13 +319,6 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
        return 0;
 }

-static void qlcnic_vlan_rx_register(struct net_device *netdev,
-               struct vlan_group *grp)
-{
-       struct qlcnic_adapter *adapter = netdev_priv(netdev);
-       adapter->vlgrp = grp;
-}
-
 static const struct net_device_ops qlcnic_netdev_ops = {
        .ndo_open          = qlcnic_open,
        .ndo_stop          = qlcnic_close,
@@ -334,7 +329,8 @@ static const struct net_device_ops qlcnic_netdev_ops = {
        .ndo_set_mac_address    = qlcnic_set_mac,
        .ndo_change_mtu    = qlcnic_change_mtu,
        .ndo_tx_timeout    = qlcnic_tx_timeout,
-       .ndo_vlan_rx_register = qlcnic_vlan_rx_register,
+       .ndo_vlan_rx_add_vid    = qlcnic_vlan_rx_add,
+       .ndo_vlan_rx_kill_vid   = qlcnic_vlan_rx_del,
 #ifdef CONFIG_NET_POLL_CONTROLLER
        .ndo_poll_controller = qlcnic_poll_controller,
 #endif
@@ -710,6 +706,22 @@ qlcnic_set_vlan_config(struct qlcnic_adapter *adapter,
 }

 static void
+qlcnic_vlan_rx_add(struct net_device *netdev, u16 vid)
+{
+       struct qlcnic_adapter *adapter = netdev_priv(netdev);
+       set_bit(vid, adapter->vlans);
+}
+
+static void
+qlcnic_vlan_rx_del(struct net_device *netdev, u16 vid)
+{
+       struct qlcnic_adapter *adapter = netdev_priv(netdev);
+
+       qlcnic_restore_indev_addr(netdev, NETDEV_DOWN);
+       clear_bit(vid, adapter->vlans);
+}
+
+static void
 qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
                struct qlcnic_esw_func_cfg *esw_cfg)
 {
@@ -755,7 +767,7 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
        features = (NETIF_F_SG | NETIF_F_IP_CSUM |
                        NETIF_F_IPV6_CSUM | NETIF_F_GRO);
        vlan_features = (NETIF_F_SG | NETIF_F_IP_CSUM |
-                       NETIF_F_IPV6_CSUM);
+                       NETIF_F_IPV6_CSUM | NETIF_F_HW_VLAN_FILTER);

        if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
                features |= (NETIF_F_TSO | NETIF_F_TSO6);
@@ -1448,7 +1460,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
        netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
                NETIF_F_IPV6_CSUM | NETIF_F_GRO | NETIF_F_HW_VLAN_RX);
        netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
-               NETIF_F_IPV6_CSUM);
+               NETIF_F_IPV6_CSUM | NETIF_F_HW_VLAN_FILTER);

        if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
                netdev->features |= (NETIF_F_TSO | NETIF_F_TSO6);
@@ -4068,14 +4080,10 @@ qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)

        qlcnic_config_indev_addr(adapter, netdev, event);

-       if (!adapter->vlgrp)
-               return;
-
-       for (vid = 0; vid < VLAN_N_VID; vid++) {
-               dev = vlan_group_get_device(adapter->vlgrp, vid);
+       for_each_set_bit(vid, adapter->vlans, VLAN_N_VID) {
+               dev = vlan_find_dev(netdev, vid);
                if (!dev)
                        continue;
-
                qlcnic_config_indev_addr(adapter, dev, event);
        }
 }
--
1.7.4.1


This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.


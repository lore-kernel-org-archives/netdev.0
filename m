From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 1/2] enic: Add ndo_set_vf_mac support for enic
	dynamic devices
Date: Wed, 08 Dec 2010 15:53:58 -0800
Message-ID: <20101208235357.24874.10299.stgit@savbu-pc100.cisco.com>
References: <20101208235340.24874.50597.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:56518 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754366Ab0LHXx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 18:53:58 -0500
In-Reply-To: <20101208235340.24874.50597.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch implements the ndo_set_vf_mac netdev operation for enic
dynamic devices. It treats the mac address set by IFLA_VF_MAC as a
special case to use it in the port profile provisioning data.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/enic/enic.h      |    3 ++-
 drivers/net/enic/enic_main.c |   20 ++++++++++++++++++++
 2 files changed, 22 insertions(+), 1 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 8f374c1..bd473a9 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.4.1.8"
+#define DRV_VERSION		"1.4.1.9"
 #define DRV_COPYRIGHT		"Copyright 2008-2010 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
@@ -61,6 +61,7 @@ struct enic_port_profile {
 	char name[PORT_PROFILE_MAX];
 	u8 instance_uuid[PORT_UUID_MAX];
 	u8 host_uuid[PORT_UUID_MAX];
+	u8 vf_mac[ETH_ALEN];
 };
 
 /* Per-instance private data structure */
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 1931f15..ddeffb5 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1231,6 +1231,23 @@ static int enic_dev_init_done(struct enic *enic, int *done, int *error)
 	return err;
 }
 
+static int enic_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
+{
+	struct enic *enic = netdev_priv(netdev);
+
+	if (vf != PORT_SELF_VF)
+		return -EOPNOTSUPP;
+
+	/* Ignore the vf argument for now. We can assume the request
+	 * is coming on a vf.
+	 */
+	if (is_valid_ether_addr(mac)) {
+		memcpy(enic->pp.vf_mac, mac, ETH_ALEN);
+		return 0;
+	} else
+		return -EINVAL;
+}
+
 static int enic_set_port_profile(struct enic *enic, u8 *mac)
 {
 	struct vic_provinfo *vp;
@@ -2411,6 +2428,9 @@ static const struct net_device_ops enic_netdev_dynamic_ops = {
 	.ndo_tx_timeout		= enic_tx_timeout,
 	.ndo_set_vf_port	= enic_set_vf_port,
 	.ndo_get_vf_port	= enic_get_vf_port,
+#ifdef IFLA_VF_MAX
+	.ndo_set_vf_mac		= enic_set_vf_mac,
+#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= enic_poll_controller,
 #endif


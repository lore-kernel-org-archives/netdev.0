From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next] 8021q: validate SAN MAC address
Date: Fri, 9 Nov 2012 14:54:04 -0800
Message-ID: <1352501644-8444-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3393 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755968Ab2KIWjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2012 17:39:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some bnx2x multi-function devices are configured for FCoE only in
a PCI function and only has a SAN MAC address.  The current code
will fail ->ndo_validate_addr() when a VLAN device is brought up
over such a device.

Check the real device's dev_addrs[] for a valid SAN MAC address
when validating the MAC address if the regular MAC address is not
valid.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 net/8021q/vlan_dev.c |   25 ++++++++++++++++++++++++-
 1 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 6da96d4..9ef2d2e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -346,6 +346,29 @@ static int vlan_dev_stop(struct net_device *dev)
 	return 0;
 }
 
+static int vlan_dev_validate_addr(struct net_device *dev)
+{
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
+
+		if (real_dev) {
+			struct netdev_hw_addr *ha;
+
+			rcu_read_lock();
+			for_each_dev_addr(real_dev, ha) {
+				if ((ha->type == NETDEV_HW_ADDR_T_SAN) &&
+				    (is_valid_ether_addr(ha->addr))) {
+					rcu_read_unlock();
+					return 0;
+				}
+			}
+			rcu_read_unlock();
+		}
+		return -EADDRNOTAVAIL;
+	}
+	return 0;
+}
+
 static int vlan_dev_set_mac_address(struct net_device *dev, void *p)
 {
 	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
@@ -734,7 +757,7 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_open		= vlan_dev_open,
 	.ndo_stop		= vlan_dev_stop,
 	.ndo_start_xmit =  vlan_dev_hard_start_xmit,
-	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_validate_addr	= vlan_dev_validate_addr,
 	.ndo_set_mac_address	= vlan_dev_set_mac_address,
 	.ndo_set_rx_mode	= vlan_dev_set_rx_mode,
 	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
-- 
1.7.1

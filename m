From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] forcedeth: fix vlans
Date: Tue, 26 Jul 2011 18:41:50 +0200
Message-ID: <1311698510-2599-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, johnstul@us.ibm.com, w41ter@gmail.com,
	mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33574 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753574Ab1GZQ4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2011 12:56:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some reason, when rxaccel is disabled, NV_RX3_VLAN_TAG_PRESENT is
still set and some pseudorandom vids appear. So check for
NETIF_F_HW_VLAN_RX as well. Also set correctly hw_features and set vlan
mode on probe.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/forcedeth.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index e64cd9c..256a272 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2764,7 +2764,8 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 			prefetch(skb->data);
 
 			vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
-			if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
+			if (dev->features & NETIF_F_HW_VLAN_RX &&
+			    vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
 				u16 vid = vlanflags & NV_RX3_VLAN_TAG_MASK;
 
 				__vlan_hwaccel_put_tag(skb, vid);
@@ -5337,7 +5338,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	np->vlanctl_bits = 0;
 	if (id->driver_data & DEV_HAS_VLAN) {
 		np->vlanctl_bits = NVREG_VLANCONTROL_ENABLE;
-		dev->features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX;
+		dev->hw_features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX;
+		dev->features |= dev->hw_features;
 	}
 
 	np->pause_flags = NV_PAUSEFRAME_RX_CAPABLE | NV_PAUSEFRAME_RX_REQ | NV_PAUSEFRAME_AUTONEG;
@@ -5607,6 +5609,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		goto out_error;
 	}
 
+	nv_vlan_mode(dev, dev->features);
+
 	netif_carrier_off(dev);
 
 	dev_info(&pci_dev->dev, "ifname %s, PHY OUI 0x%x @ %d, addr %pM\n",
-- 
1.7.6


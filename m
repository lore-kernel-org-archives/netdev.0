From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 V2] forcedeth: fix vlans
Date: Tue, 26 Jul 2011 22:19:28 +0200
Message-ID: <20110726201927.GD2475@minipsycho>
References: <1311698510-2599-1-git-send-email-jpirko@redhat.com>
 <CAHXqBF+Yr8Bw0LZHPpPuFY9iDyxxCCKw7S7FZkuGseiCK-es3g@mail.gmail.com>
 <CAEP_g=9xVomtnViW=rWYmXqGO_45=N8YhWMHsObBXnWAf9Gh5A@mail.gmail.com>
 <CAHXqBF+qjCzfQmDLdKvanpBuQo1X-zFAr_26SCwVuwbSVwpyPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org,
	davem@davemloft.net, johnstul@us.ibm.com, w41ter@gmail.com
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42139 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753287Ab1GZUTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2011 16:19:33 -0400
Content-Disposition: inline
In-Reply-To: <CAHXqBF+qjCzfQmDLdKvanpBuQo1X-zFAr_26SCwVuwbSVwpyPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some reason, when rxaccel is disabled, NV_RX3_VLAN_TAG_PRESENT is
still set and some pseudorandom vids appear. So check for
NETIF_F_HW_VLAN_RX as well. Also set correctly hw_features and set vlan
mode on probe.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/forcedeth.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index e64cd9c..e55df30 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2764,7 +2764,14 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 			prefetch(skb->data);
 
 			vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
-			if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
+
+			/*
+			 * There's need to check for NETIF_F_HW_VLAN_RX here.
+			 * Even if vlan rx accel is disabled,
+			 * NV_RX3_VLAN_TAG_PRESENT is pseudo randomly set.
+			 */
+			if (dev->features & NETIF_F_HW_VLAN_RX &&
+			    vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
 				u16 vid = vlanflags & NV_RX3_VLAN_TAG_MASK;
 
 				__vlan_hwaccel_put_tag(skb, vid);
@@ -5331,15 +5338,16 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		np->txrxctl_bits |= NVREG_TXRXCTL_RXCHECK;
 		dev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_RXCSUM;
-		dev->features |= dev->hw_features;
 	}
 
 	np->vlanctl_bits = 0;
 	if (id->driver_data & DEV_HAS_VLAN) {
 		np->vlanctl_bits = NVREG_VLANCONTROL_ENABLE;
-		dev->features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX;
+		dev->hw_features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX;
 	}
 
+	dev->features |= dev->hw_features;
+
 	np->pause_flags = NV_PAUSEFRAME_RX_CAPABLE | NV_PAUSEFRAME_RX_REQ | NV_PAUSEFRAME_AUTONEG;
 	if ((id->driver_data & DEV_HAS_PAUSEFRAME_TX_V1) ||
 	    (id->driver_data & DEV_HAS_PAUSEFRAME_TX_V2) ||
@@ -5607,6 +5615,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		goto out_error;
 	}
 
+	nv_vlan_mode(dev, dev->features);
+
 	netif_carrier_off(dev);
 
 	dev_info(&pci_dev->dev, "ifname %s, PHY OUI 0x%x @ %d, addr %pM\n",
-- 
1.7.6


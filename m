From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/06]: VLAN TCI truncation fixes
Date: Mon, 07 Jul 2008 04:11:21 +0200
Message-ID: <48717B49.1060804@trash.net>
References: <48714BA3.3080102@trash.net> <4871769E.2020305@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050204030404030505020705"
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	john.ronciak@intel.com, ionut@cs.columbia.edu,
	baum@tehutinetworks.net, andy@greyhouse.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45808 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbYGGCR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 22:17:27 -0400
In-Reply-To: <4871769E.2020305@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050204030404030505020705
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Garzik wrote:
> Patrick McHardy wrote:
>>      e1000: don't truncate VLAN TCI with VLAN stripping
>>      e1000e: don't truncate VLAN TCI with VLAN stripping
>>      igb: don't truncate VLAN TCI with VLAN stripping
>>      ixgb: don't truncate VLAN TCI with VLAN stripping
>>      starfire: don't truncate VLAN TCI with VLAN stripping
>>      tehuti: don't truncate VLAN TCI with VLAN stripping
>
> Acked-by: Jeff Garzik <jgarzik@redhat.com>
Thanks.
>
> Though I would suggest combining all these patches into a single 
> patch, since they constitute a single logical change, and each change 
> is self-contained and small.

Attached is a combined patch with these 6 patches.

--------------050204030404030505020705
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit c9825e6591be8de5f93e43f115c08ed0ab80685e
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jul 7 04:12:12 2008 +0200

    netdrv: don't truncate VLAN TCI with VLAN stripping
    
    The vlan_hwaccel_{rx,receive_skb} functions expect the full TCI field
    for priority mappings, don't truncate the upper 4 bits.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 311ca26..7aa458f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4277,8 +4277,7 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		if (unlikely(adapter->vlgrp &&
 			    (status & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-						 le16_to_cpu(rx_desc->special) &
-						 E1000_RXD_SPC_VLAN_MASK);
+						 le16_to_cpu(rx_desc->special));
 		} else {
 			netif_receive_skb(skb);
 		}
@@ -4286,8 +4285,7 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		if (unlikely(adapter->vlgrp &&
 			    (status & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
-					le16_to_cpu(rx_desc->special) &
-					E1000_RXD_SPC_VLAN_MASK);
+					le16_to_cpu(rx_desc->special));
 		} else {
 			netif_rx(skb);
 		}
@@ -4464,16 +4462,14 @@ copydone:
 #ifdef CONFIG_E1000_NAPI
 		if (unlikely(adapter->vlgrp && (staterr & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->wb.middle.vlan) &
-				E1000_RXD_SPC_VLAN_MASK);
+				le16_to_cpu(rx_desc->wb.middle.vlan));
 		} else {
 			netif_receive_skb(skb);
 		}
 #else /* CONFIG_E1000_NAPI */
 		if (unlikely(adapter->vlgrp && (staterr & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->wb.middle.vlan) &
-				E1000_RXD_SPC_VLAN_MASK);
+				le16_to_cpu(rx_desc->wb.middle.vlan));
 		} else {
 			netif_rx(skb);
 		}
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index acdd616..80592bd 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -98,8 +98,7 @@ static void e1000_receive_skb(struct e1000_adapter *adapter,
 
 	if (adapter->vlgrp && (status & E1000_RXD_STAT_VP))
 		vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-					 le16_to_cpu(vlan) &
-					 E1000_RXD_SPC_VLAN_MASK);
+					 le16_to_cpu(vlan));
 	else
 		netif_receive_skb(skb);
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 7bc6fae..afd4ce3 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3391,8 +3391,7 @@ static void igb_receive_skb(struct igb_adapter *adapter, u8 status, __le16 vlan,
 {
 	if (adapter->vlgrp && (status & E1000_RXD_STAT_VP))
 		vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-					 le16_to_cpu(vlan) &
-					 E1000_RXD_SPC_VLAN_MASK);
+					 le16_to_cpu(vlan));
 	else
 		netif_receive_skb(skb);
 }
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index cb8dadd..41f3adf 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -2045,16 +2045,14 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 #ifdef CONFIG_IXGB_NAPI
 		if(adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->special) &
-					IXGB_RX_DESC_SPECIAL_VLAN_MASK);
+				le16_to_cpu(rx_desc->special));
 		} else {
 			netif_receive_skb(skb);
 		}
 #else /* CONFIG_IXGB_NAPI */
 		if(adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->special) &
-					IXGB_RX_DESC_SPECIAL_VLAN_MASK);
+				le16_to_cpu(rx_desc->special));
 		} else {
 			netif_rx(skb);
 		}
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 7b7b171..2038f38 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1510,7 +1510,7 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 			if (debug > 4)
 				printk(KERN_DEBUG "  netdev_rx() vlanid = %d\n", le16_to_cpu(desc->vlanid));
 			/* vlan_netdev_receive_skb() expects a packet with the VLAN tag stripped out */
-			vlan_netdev_receive_skb(skb, np->vlgrp, le16_to_cpu(desc->vlanid) & VLAN_VID_MASK);
+			vlan_netdev_receive_skb(skb, np->vlgrp, le16_to_cpu(desc->vlanid));
 		} else
 #endif /* VLAN_SUPPORT */
 			netdev_receive_skb(skb);
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 432e837..91f9054 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1165,7 +1165,7 @@ NETIF_RX_MUX(struct bdx_priv *priv, u32 rxd_val1, u16 rxd_vlan,
 					  GET_RXD_VLAN_ID(rxd_vlan))->name);
 		/* NAPI variant of receive functions */
 		vlan_hwaccel_receive_skb(skb, priv->vlgrp,
-					 GET_RXD_VLAN_ID(rxd_vlan));
+					 GET_RXD_VLAN_TCI(rxd_vlan));
 	} else {
 		netif_receive_skb(skb);
 	}
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index efd170f..c66dfc9 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -309,6 +309,7 @@ struct rxf_desc {
 #define GET_RXD_PKT_ID(x)		GET_BITS_SHIFT((x), 3, 28)
 #define GET_RXD_VTAG(x)			GET_BITS_SHIFT((x), 1, 31)
 #define GET_RXD_VLAN_ID(x)		GET_BITS_SHIFT((x), 12, 0)
+#define GET_RXD_VLAN_TCI(x)		GET_BITS_SHIFT((x), 16, 0)
 #define GET_RXD_CFI(x)			GET_BITS_SHIFT((x), 1, 12)
 #define GET_RXD_PRIO(x)			GET_BITS_SHIFT((x), 3, 13)
 

--------------050204030404030505020705--

From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: [PATCH net-next 2/5] tg3: Add unicast filtering support.
Date: Fri, 3 Jan 2014 10:09:12 -0800
Message-ID: <1388772555-916-3-git-send-email-nsujir@broadcom.com>
References: <1388772555-916-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:56397 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbaACSJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 13:09:28 -0500
In-Reply-To: <1388772555-916-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

Up to 3 additional unicast addresses can be added to the perfect match
filter table.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 80d55bf..c3b12de 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -37,6 +37,7 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/brcmphy.h>
+#include <linux/if.h>
 #include <linux/if_vlan.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
@@ -208,6 +209,9 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define TG3_RAW_IP_ALIGN 2
 
+#define TG3_MAX_UCAST_ADDR(tp) (tg3_flag((tp), ENABLE_ASF) ? 2 : 3)
+#define TG3_UCAST_ADDR_IDX(tp) (tg3_flag((tp), ENABLE_ASF) ? 2 : 1)
+
 #define TG3_FW_UPDATE_TIMEOUT_SEC	5
 #define TG3_FW_UPDATE_FREQ_SEC		(TG3_FW_UPDATE_TIMEOUT_SEC / 2)
 
@@ -9198,6 +9202,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 static void tg3_get_nstats(struct tg3 *, struct rtnl_link_stats64 *);
 static void tg3_get_estats(struct tg3 *, struct tg3_ethtool_stats *);
+static void __tg3_set_rx_mode(struct net_device *);
 
 /* tp->lock is held. */
 static int tg3_halt(struct tg3 *tp, int kind, bool silent)
@@ -9258,6 +9263,7 @@ static int tg3_set_mac_addr(struct net_device *dev, void *p)
 	}
 	spin_lock_bh(&tp->lock);
 	__tg3_set_mac_addr(tp, skip_mac_1);
+	__tg3_set_rx_mode(dev);
 	spin_unlock_bh(&tp->lock);
 
 	return err;
@@ -9646,6 +9652,20 @@ static void __tg3_set_rx_mode(struct net_device *dev)
 		tw32(MAC_HASH_REG_3, mc_filter[3]);
 	}
 
+	if (netdev_uc_count(dev) > TG3_MAX_UCAST_ADDR(tp)) {
+		rx_mode |= RX_MODE_PROMISC;
+	} else if (!(dev->flags & IFF_PROMISC)) {
+		/* Add all entries into to the mac addr filter list */
+		int i = 0;
+		struct netdev_hw_addr *ha;
+
+		netdev_for_each_uc_addr(ha, dev) {
+			__tg3_set_one_mac_addr(tp, ha->addr,
+					       i + TG3_UCAST_ADDR_IDX(tp));
+			i++;
+		}
+	}
+
 	if (rx_mode != tp->rx_mode) {
 		tp->rx_mode = rx_mode;
 		tw32_f(MAC_RX_MODE, rx_mode);
@@ -17620,6 +17640,7 @@ static int tg3_init_one(struct pci_dev *pdev,
 		features |= NETIF_F_LOOPBACK;
 
 	dev->hw_features |= features;
+	dev->priv_flags |= IFF_UNICAST_FLT;
 
 	if (tg3_chip_rev_id(tp) == CHIPREV_ID_5705_A1 &&
 	    !tg3_flag(tp, TSO_CAPABLE) &&
-- 
1.8.1.4

From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH RFC v2 net-next 5/8] net: qualcomm: move MTU handling to qca_common
Date: Mon, 26 Sep 2016 13:08:03 +0200
Message-ID: <1474888086-514-6-git-send-email-stefan.wahren@i2se.com>
References: <1474888086-514-1-git-send-email-stefan.wahren@i2se.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474888086-514-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MTU of the QCA7000 is independent from it's host interface (UART,SPI).
So move the change_mtu function to qca_common.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_common.c | 11 +++++++++++
 drivers/net/ethernet/qualcomm/qca_common.h |  3 +++
 drivers/net/ethernet/qualcomm/qca_spi.c    | 13 +------------
 3 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_common.c b/drivers/net/ethernet/qualcomm/qca_common.c
index 26453a9..9020c57 100644
--- a/drivers/net/ethernet/qualcomm/qca_common.c
+++ b/drivers/net/ethernet/qualcomm/qca_common.c
@@ -154,3 +154,14 @@ qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_by
 
 	return ret;
 }
+
+int
+qcacmn_netdev_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if ((new_mtu < QCAFRM_ETHMINMTU) || (new_mtu > QCAFRM_ETHMAXMTU))
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/qualcomm/qca_common.h b/drivers/net/ethernet/qualcomm/qca_common.h
index 8c9b713..0fafaaf 100644
--- a/drivers/net/ethernet/qualcomm/qca_common.h
+++ b/drivers/net/ethernet/qualcomm/qca_common.h
@@ -26,6 +26,7 @@
 
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
+#include <linux/netdevice.h>
 #include <linux/types.h>
 
 /* Frame is currently being received */
@@ -131,4 +132,6 @@ static inline void qcafrm_fsm_init(struct qcafrm_handle *handle)
 
 s32 qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_byte);
 
+int qcacmn_netdev_change_mtu(struct net_device *dev, int new_mtu);
+
 #endif /* _QCA_COMMON_H */
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 551591d..e0a5020 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -804,24 +804,13 @@ qcaspi_netdev_uninit(struct net_device *dev)
 		dev_kfree_skb(qca->rx_skb);
 }
 
-static int
-qcaspi_netdev_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < QCAFRM_ETHMINMTU) || (new_mtu > QCAFRM_ETHMAXMTU))
-		return -EINVAL;
-
-	dev->mtu = new_mtu;
-
-	return 0;
-}
-
 static const struct net_device_ops qcaspi_netdev_ops = {
 	.ndo_init = qcaspi_netdev_init,
 	.ndo_uninit = qcaspi_netdev_uninit,
 	.ndo_open = qcaspi_netdev_open,
 	.ndo_stop = qcaspi_netdev_close,
 	.ndo_start_xmit = qcaspi_netdev_xmit,
-	.ndo_change_mtu = qcaspi_netdev_change_mtu,
+	.ndo_change_mtu = qcacmn_netdev_change_mtu,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_tx_timeout = qcaspi_netdev_tx_timeout,
 	.ndo_validate_addr = eth_validate_addr,
-- 
2.1.4

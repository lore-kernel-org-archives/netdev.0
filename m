From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v8 net-next 17/17] net: qualcomm: add QCA7000 UART driver
Date: Mon, 29 May 2017 13:57:25 +0200
Message-ID: <1496059045-13572-18-git-send-email-stefan.wahren@i2se.com>
References: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the Ethernet over UART driver for the
Qualcomm QCA7000 HomePlug GreenPHY.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/qualcomm/Kconfig         |  16 +
 drivers/net/ethernet/qualcomm/Makefile        |   2 +
 drivers/net/ethernet/qualcomm/qca_7k_common.h |   6 +
 drivers/net/ethernet/qualcomm/qca_uart.c      | 423 ++++++++++++++++++++++++++
 4 files changed, 447 insertions(+)
 create mode 100644 drivers/net/ethernet/qualcomm/qca_uart.c

diff --git a/drivers/net/ethernet/qualcomm/Kconfig b/drivers/net/ethernet/qualcomm/Kconfig
index b4c369d..877675a 100644
--- a/drivers/net/ethernet/qualcomm/Kconfig
+++ b/drivers/net/ethernet/qualcomm/Kconfig
@@ -30,6 +30,22 @@ config QCA7000_SPI
 	  To compile this driver as a module, choose M here. The module
 	  will be called qcaspi.
 
+config QCA7000_UART
+	tristate "Qualcomm Atheros QCA7000 UART support"
+	select QCA7000
+	depends on SERIAL_DEV_BUS && OF
+	---help---
+	  This UART protocol driver supports the Qualcomm Atheros QCA7000.
+
+	  Currently the driver assumes these device UART settings:
+	    Data bits: 8
+	    Parity: None
+	    Stop bits: 1
+	    Flow control: None
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called qcauart.
+
 config QCOM_EMAC
 	tristate "Qualcomm Technologies, Inc. EMAC Gigabit Ethernet support"
 	depends on HAS_DMA && HAS_IOMEM
diff --git a/drivers/net/ethernet/qualcomm/Makefile b/drivers/net/ethernet/qualcomm/Makefile
index 65556ca..92fa7c4 100644
--- a/drivers/net/ethernet/qualcomm/Makefile
+++ b/drivers/net/ethernet/qualcomm/Makefile
@@ -5,5 +5,7 @@
 obj-$(CONFIG_QCA7000) += qca_7k_common.o
 obj-$(CONFIG_QCA7000_SPI) += qcaspi.o
 qcaspi-objs := qca_7k.o qca_debug.o qca_spi.o
+obj-$(CONFIG_QCA7000_UART) += qcauart.o
+qcauart-objs := qca_uart.o
 
 obj-y += emac/
diff --git a/drivers/net/ethernet/qualcomm/qca_7k_common.h b/drivers/net/ethernet/qualcomm/qca_7k_common.h
index 07bdd6c..928554f 100644
--- a/drivers/net/ethernet/qualcomm/qca_7k_common.h
+++ b/drivers/net/ethernet/qualcomm/qca_7k_common.h
@@ -122,6 +122,12 @@ static inline void qcafrm_fsm_init_spi(struct qcafrm_handle *handle)
 	handle->state = handle->init;
 }
 
+static inline void qcafrm_fsm_init_uart(struct qcafrm_handle *handle)
+{
+	handle->init = QCAFRM_WAIT_AA1;
+	handle->state = handle->init;
+}
+
 /*   Gather received bytes and try to extract a full Ethernet frame
  *   by following a simple state machine.
  *
diff --git a/drivers/net/ethernet/qualcomm/qca_uart.c b/drivers/net/ethernet/qualcomm/qca_uart.c
new file mode 100644
index 0000000..db6068c
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/qca_uart.c
@@ -0,0 +1,423 @@
+/*
+ *   Copyright (c) 2011, 2012, Qualcomm Atheros Communications Inc.
+ *   Copyright (c) 2017, I2SE GmbH
+ *
+ *   Permission to use, copy, modify, and/or distribute this software
+ *   for any purpose with or without fee is hereby granted, provided
+ *   that the above copyright notice and this permission notice appear
+ *   in all copies.
+ *
+ *   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
+ *   WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
+ *   WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
+ *   THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
+ *   CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
+ *   LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
+ *   NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
+ *   CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+/*   This module implements the Qualcomm Atheros UART protocol for
+ *   kernel-based UART device; it is essentially an Ethernet-to-UART
+ *   serial converter;
+ */
+
+#include <linux/device.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/of_net.h>
+#include <linux/sched.h>
+#include <linux/serdev.h>
+#include <linux/skbuff.h>
+#include <linux/types.h>
+
+#include "qca_7k_common.h"
+
+#define QCAUART_DRV_VERSION "0.1.0"
+#define QCAUART_DRV_NAME "qcauart"
+#define QCAUART_TX_TIMEOUT (1 * HZ)
+
+struct qcauart {
+	struct net_device *net_dev;
+	spinlock_t lock;			/* transmit lock */
+	struct work_struct tx_work;		/* Flushes transmit buffer   */
+
+	struct serdev_device *serdev;
+	struct qcafrm_handle frm_handle;
+	struct sk_buff *rx_skb;
+
+	unsigned char *tx_head;			/* pointer to next XMIT byte */
+	int tx_left;				/* bytes left in XMIT queue  */
+	unsigned char *tx_buffer;
+};
+
+static int
+qca_tty_receive(struct serdev_device *serdev, const unsigned char *data,
+		size_t count)
+{
+	struct qcauart *qca = serdev_device_get_drvdata(serdev);
+	struct net_device *netdev = qca->net_dev;
+	struct net_device_stats *n_stats = &netdev->stats;
+	size_t i;
+
+	if (!qca->rx_skb) {
+		qca->rx_skb = netdev_alloc_skb_ip_align(netdev,
+							netdev->mtu +
+							VLAN_ETH_HLEN);
+		if (!qca->rx_skb) {
+			n_stats->rx_errors++;
+			n_stats->rx_dropped++;
+			return 0;
+		}
+	}
+
+	for (i = 0; i < count; i++) {
+		s32 retcode;
+
+		retcode = qcafrm_fsm_decode(&qca->frm_handle,
+					    qca->rx_skb->data,
+					    skb_tailroom(qca->rx_skb),
+					    data[i]);
+
+		switch (retcode) {
+		case QCAFRM_GATHER:
+		case QCAFRM_NOHEAD:
+			break;
+		case QCAFRM_NOTAIL:
+			netdev_dbg(netdev, "recv: no RX tail\n");
+			n_stats->rx_errors++;
+			n_stats->rx_dropped++;
+			break;
+		case QCAFRM_INVLEN:
+			netdev_dbg(netdev, "recv: invalid RX length\n");
+			n_stats->rx_errors++;
+			n_stats->rx_dropped++;
+			break;
+		default:
+			n_stats->rx_packets++;
+			n_stats->rx_bytes += retcode;
+			skb_put(qca->rx_skb, retcode);
+			qca->rx_skb->protocol = eth_type_trans(
+						qca->rx_skb, qca->rx_skb->dev);
+			qca->rx_skb->ip_summed = CHECKSUM_UNNECESSARY;
+			netif_rx_ni(qca->rx_skb);
+			qca->rx_skb = netdev_alloc_skb_ip_align(netdev,
+								netdev->mtu +
+								VLAN_ETH_HLEN);
+			if (!qca->rx_skb) {
+				netdev_dbg(netdev, "recv: out of RX resources\n");
+				n_stats->rx_errors++;
+				return i;
+			}
+		}
+	}
+
+	return i;
+}
+
+/* Write out any remaining transmit buffer. Scheduled when tty is writable */
+static void qcauart_transmit(struct work_struct *work)
+{
+	struct qcauart *qca = container_of(work, struct qcauart, tx_work);
+	struct net_device_stats *n_stats = &qca->net_dev->stats;
+	int written;
+
+	spin_lock_bh(&qca->lock);
+
+	/* First make sure we're connected. */
+	if (!netif_running(qca->net_dev)) {
+		spin_unlock_bh(&qca->lock);
+		return;
+	}
+
+	if (qca->tx_left <= 0)  {
+		/* Now serial buffer is almost free & we can start
+		 * transmission of another packet
+		 */
+		n_stats->tx_packets++;
+		spin_unlock_bh(&qca->lock);
+		netif_wake_queue(qca->net_dev);
+		return;
+	}
+
+	written = serdev_device_write_buf(qca->serdev, qca->tx_head,
+					  qca->tx_left);
+	if (written > 0) {
+		qca->tx_left -= written;
+		qca->tx_head += written;
+	}
+	spin_unlock_bh(&qca->lock);
+}
+
+/* Called by the driver when there's room for more data.
+ * Schedule the transmit.
+ */
+static void qca_tty_wakeup(struct serdev_device *serdev)
+{
+	struct qcauart *qca = serdev_device_get_drvdata(serdev);
+
+	schedule_work(&qca->tx_work);
+}
+
+static struct serdev_device_ops qca_serdev_ops = {
+	.receive_buf = qca_tty_receive,
+	.write_wakeup = qca_tty_wakeup,
+};
+
+static int qcauart_netdev_open(struct net_device *dev)
+{
+	struct qcauart *qca = netdev_priv(dev);
+
+	netif_start_queue(qca->net_dev);
+
+	return 0;
+}
+
+static int qcauart_netdev_close(struct net_device *dev)
+{
+	struct qcauart *qca = netdev_priv(dev);
+
+	netif_stop_queue(dev);
+	flush_work(&qca->tx_work);
+
+	spin_lock_bh(&qca->lock);
+	qca->tx_left = 0;
+	spin_unlock_bh(&qca->lock);
+
+	return 0;
+}
+
+static netdev_tx_t
+qcauart_netdev_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_device_stats *n_stats = &dev->stats;
+	struct qcauart *qca = netdev_priv(dev);
+	u8 pad_len = 0;
+	int written;
+	u8 *pos;
+
+	spin_lock(&qca->lock);
+
+	WARN_ON(qca->tx_left);
+
+	if (!netif_running(dev))  {
+		spin_unlock(&qca->lock);
+		netdev_warn(qca->net_dev, "xmit: iface is down\n");
+		goto out;
+	}
+
+	pos = qca->tx_buffer;
+
+	if (skb->len < QCAFRM_MIN_LEN)
+		pad_len = QCAFRM_MIN_LEN - skb->len;
+
+	pos += qcafrm_create_header(pos, skb->len + pad_len);
+
+	memcpy(pos, skb->data, skb->len);
+	pos += skb->len;
+
+	if (pad_len) {
+		memset(pos, 0, pad_len);
+		pos += pad_len;
+	}
+
+	pos += qcafrm_create_footer(pos);
+
+	netif_stop_queue(qca->net_dev);
+
+	written = serdev_device_write_buf(qca->serdev, qca->tx_buffer,
+					  pos - qca->tx_buffer);
+	if (written > 0) {
+		qca->tx_left = (pos - qca->tx_buffer) - written;
+		qca->tx_head = qca->tx_buffer + written;
+		n_stats->tx_bytes += written;
+	}
+	spin_unlock(&qca->lock);
+
+	netif_trans_update(dev);
+out:
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
+}
+
+static void qcauart_netdev_tx_timeout(struct net_device *dev)
+{
+	struct qcauart *qca = netdev_priv(dev);
+
+	netdev_info(qca->net_dev, "Transmit timeout at %ld, latency %ld\n",
+		    jiffies, dev_trans_start(dev));
+	dev->stats.tx_errors++;
+	dev->stats.tx_dropped++;
+}
+
+static int qcauart_netdev_init(struct net_device *dev)
+{
+	struct qcauart *qca = netdev_priv(dev);
+	size_t len;
+
+	/* Finish setting up the device info. */
+	dev->mtu = QCAFRM_MAX_MTU;
+	dev->type = ARPHRD_ETHER;
+
+	len = QCAFRM_HEADER_LEN + QCAFRM_MAX_LEN + QCAFRM_FOOTER_LEN;
+	qca->tx_buffer = devm_kmalloc(&qca->serdev->dev, len, GFP_KERNEL);
+	if (!qca->tx_buffer)
+		return -ENOMEM;
+
+	qca->rx_skb = netdev_alloc_skb_ip_align(qca->net_dev,
+						qca->net_dev->mtu +
+						VLAN_ETH_HLEN);
+	if (!qca->rx_skb)
+		return -ENOBUFS;
+
+	return 0;
+}
+
+static void qcauart_netdev_uninit(struct net_device *dev)
+{
+	struct qcauart *qca = netdev_priv(dev);
+
+	if (qca->rx_skb)
+		dev_kfree_skb(qca->rx_skb);
+}
+
+static const struct net_device_ops qcauart_netdev_ops = {
+	.ndo_init = qcauart_netdev_init,
+	.ndo_uninit = qcauart_netdev_uninit,
+	.ndo_open = qcauart_netdev_open,
+	.ndo_stop = qcauart_netdev_close,
+	.ndo_start_xmit = qcauart_netdev_xmit,
+	.ndo_set_mac_address = eth_mac_addr,
+	.ndo_tx_timeout = qcauart_netdev_tx_timeout,
+	.ndo_validate_addr = eth_validate_addr,
+};
+
+static void qcauart_netdev_setup(struct net_device *dev)
+{
+	dev->netdev_ops = &qcauart_netdev_ops;
+	dev->watchdog_timeo = QCAUART_TX_TIMEOUT;
+	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	dev->tx_queue_len = 100;
+
+	/* MTU range: 46 - 1500 */
+	dev->min_mtu = QCAFRM_MIN_MTU;
+	dev->max_mtu = QCAFRM_MAX_MTU;
+}
+
+static const struct of_device_id qca_uart_of_match[] = {
+	{
+	 .compatible = "qca,qca7000",
+	},
+	{}
+};
+MODULE_DEVICE_TABLE(of, qca_uart_of_match);
+
+static int qca_uart_probe(struct serdev_device *serdev)
+{
+	struct net_device *qcauart_dev = alloc_etherdev(sizeof(struct qcauart));
+	struct qcauart *qca;
+	const char *mac;
+	u32 speed = 115200;
+	int ret;
+
+	if (!qcauart_dev)
+		return -ENOMEM;
+
+	qcauart_netdev_setup(qcauart_dev);
+	SET_NETDEV_DEV(qcauart_dev, &serdev->dev);
+
+	qca = netdev_priv(qcauart_dev);
+	if (!qca) {
+		pr_err("qca_uart: Fail to retrieve private structure\n");
+		ret = -ENOMEM;
+		goto free;
+	}
+	qca->net_dev = qcauart_dev;
+	qca->serdev = serdev;
+	qcafrm_fsm_init_uart(&qca->frm_handle);
+
+	spin_lock_init(&qca->lock);
+	INIT_WORK(&qca->tx_work, qcauart_transmit);
+
+	of_property_read_u32(serdev->dev.of_node, "current-speed", &speed);
+
+	mac = of_get_mac_address(serdev->dev.of_node);
+
+	if (mac)
+		ether_addr_copy(qca->net_dev->dev_addr, mac);
+
+	if (!is_valid_ether_addr(qca->net_dev->dev_addr)) {
+		eth_hw_addr_random(qca->net_dev);
+		dev_info(&serdev->dev, "Using random MAC address: %pM\n",
+			 qca->net_dev->dev_addr);
+	}
+
+	netif_carrier_on(qca->net_dev);
+	serdev_device_set_drvdata(serdev, qca);
+	serdev_device_set_client_ops(serdev, &qca_serdev_ops);
+
+	ret = serdev_device_open(serdev);
+	if (ret) {
+		dev_err(&serdev->dev, "Unable to open device %s\n",
+			qcauart_dev->name);
+		goto free;
+	}
+
+	speed = serdev_device_set_baudrate(serdev, speed);
+	dev_info(&serdev->dev, "Using baudrate: %u\n", speed);
+
+	serdev_device_set_flow_control(serdev, false);
+
+	ret = register_netdev(qcauart_dev);
+	if (ret) {
+		dev_err(&serdev->dev, "Unable to register net device %s\n",
+			qcauart_dev->name);
+		serdev_device_close(serdev);
+		cancel_work_sync(&qca->tx_work);
+		goto free;
+	}
+
+	return 0;
+
+free:
+	free_netdev(qcauart_dev);
+	return ret;
+}
+
+static void qca_uart_remove(struct serdev_device *serdev)
+{
+	struct qcauart *qca = serdev_device_get_drvdata(serdev);
+
+	unregister_netdev(qca->net_dev);
+
+	/* Flush any pending characters in the driver. */
+	serdev_device_close(serdev);
+	cancel_work_sync(&qca->tx_work);
+
+	free_netdev(qca->net_dev);
+}
+
+static struct serdev_device_driver qca_uart_driver = {
+	.probe = qca_uart_probe,
+	.remove = qca_uart_remove,
+	.driver = {
+		.name = QCAUART_DRV_NAME,
+		.of_match_table = of_match_ptr(qca_uart_of_match),
+	},
+};
+
+module_serdev_device_driver(qca_uart_driver);
+
+MODULE_DESCRIPTION("Qualcomm Atheros QCA7000 UART Driver");
+MODULE_AUTHOR("Qualcomm Atheros Communications");
+MODULE_AUTHOR("Stefan Wahren <stefan.wahren@i2se.com>");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_VERSION(QCAUART_DRV_VERSION);
-- 
2.1.4

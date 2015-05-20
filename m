From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 6/7] fjes: Implement upper layer of network driver
 functionality
Date: Wed, 20 May 2015 08:22:34 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A5422D889@G01JPEXMBYT01>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "Hart, Darren" <darren.hart@intel.com>,
	"rkhan@redhat.com" <rkhan@redhat.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>
To: "platform-driver-x86@vger.kernel.org"
	<platform-driver-x86@vger.kernel.org>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
Content-Language: ja-JP
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes.h      |   47 ++
 drivers/platform/x86/fjes/fjes_hw.c   |  214 ++++++
 drivers/platform/x86/fjes/fjes_main.c | 1267 +++++++++++++++++++++++++++++++++
 drivers/platform/x86/fjes/fjes_regs.h |    1 -
 4 files changed, 1528 insertions(+), 1 deletion(-)

diff --git a/drivers/platform/x86/fjes/fjes.h b/drivers/platform/x86/fjes/fjes.h
index efe7cc4..c056fc4 100644
--- a/drivers/platform/x86/fjes/fjes.h
+++ b/drivers/platform/x86/fjes/fjes.h
@@ -24,11 +24,58 @@
 #define FJES_H_
 
 #include <linux/acpi.h>
+#include <linux/workqueue.h>
 
 #include "fjes_hw.h"
 
 #define FJES_ACPI_SYMBOL	"Extended Socket"
 
+
+#define FJES_MAX_QUEUES		1
+#define FJES_TX_RETRY_INTERVAL	(20 * HZ)
+#define FJES_TX_RETRY_TIMEOUT	(100)
+#define FJES_TX_TX_STALL_TIMEOUT	(FJES_TX_RETRY_INTERVAL/2)
+#define FJES_OPEN_ZONE_UPDATE_WAIT	(300) /* msec */
+#define FJES_IRQ_WATCH_DELAY	(HZ)
+
+
+/* board specific private data structure */
+struct fjes_adapter {
+
+	struct net_device *netdev;
+	struct platform_device *plat_dev;
+
+	struct napi_struct napi;
+	struct rtnl_link_stats64 stats64;
+
+	unsigned int tx_retry_count;
+	unsigned long tx_start_jiffies;
+	unsigned long rx_last_jiffies;
+	bool unset_rx_last;
+
+
+	struct work_struct force_close_task;
+	bool force_reset;
+	bool open_guard;
+
+	bool irq_registered;
+
+	struct workqueue_struct *txrx_wq;
+	struct workqueue_struct *control_wq;
+
+	struct work_struct tx_stall_task;
+	struct work_struct raise_intr_rxdata_task;
+
+	struct work_struct unshare_watch_task;
+	unsigned long unshare_watch_bitmask;
+
+	struct delayed_work interrupt_watch_task;
+	bool interrupt_watch_enable;
+
+	struct fjes_hw hw;
+
+};
+
 extern char fjes_driver_name[];
 extern char fjes_driver_version[];
 extern u32 fjes_support_mtu[];
diff --git a/drivers/platform/x86/fjes/fjes_hw.c b/drivers/platform/x86/fjes/fjes_hw.c
index 4431aba..2beeb3a 100644
--- a/drivers/platform/x86/fjes/fjes_hw.c
+++ b/drivers/platform/x86/fjes/fjes_hw.c
@@ -22,6 +22,10 @@
 #include "fjes_hw.h"
 #include "fjes.h"
 
+static void fjes_hw_update_zone_task(struct work_struct *);
+static void fjes_hw_epstop_task(struct work_struct *);
+
+
 u32 fjes_hw_rd32(struct fjes_hw *hw, u32 reg)
 {
 	u8 *base = hw->base;
@@ -326,6 +330,9 @@ int fjes_hw_init(struct fjes_hw *hw)
 
 	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_ALL, true);
 
+	INIT_WORK(&hw->update_zone_task, fjes_hw_update_zone_task);
+	INIT_WORK(&hw->epstop_task, fjes_hw_epstop_task);
+
 	mutex_init(&hw->hw_info.lock);
 
 	hw->max_epid = fjes_hw_get_max_epid(hw);
@@ -942,3 +949,210 @@ int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *epbh,
 	return 0;
 }
 
+static void fjes_hw_update_zone_task(struct work_struct *work)
+{
+
+	struct fjes_hw *hw = container_of(work,
+			struct fjes_hw, update_zone_task);
+	struct fjes_adapter *adapter = (struct fjes_adapter *)hw->back;
+	struct net_device *netdev = adapter->netdev;
+	int ret;
+	int epidx;
+	enum ep_partner_status pstatus;
+	unsigned long share_bit = 0;
+	unsigned long unshare_bit = 0;
+	unsigned long irq_bit = 0;
+	bool update = false;
+	union fjes_device_command_res *res_buf =
+			hw->hw_info.res_buf;
+
+	mutex_lock(&hw->hw_info.lock);
+
+	ret = fjes_hw_request_info(hw);
+	switch (ret) {
+	case -ENOMSG:
+	case -EBUSY:
+	default:
+		if (!work_pending(&adapter->force_close_task)) {
+			adapter->force_reset = true;
+			schedule_work(&adapter->force_close_task);
+		}
+		break;
+
+	case 0:
+
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+			if (epidx != hw->my_epid) {
+
+				pstatus = fjes_hw_get_partner_ep_status(hw, epidx);
+				switch (pstatus) {
+				case EP_PARTNER_UNSHARE:
+				default:
+					if ((res_buf->info.info[epidx].zone !=
+						FJES_ZONING_ZONE_TYPE_NONE) &&
+					    (res_buf->info.info[epidx].es_status ==
+						FJES_ZONING_STATUS_ENABLE) &&
+					    (res_buf->info.info[epidx].zone ==
+						res_buf->info.info[hw->my_epid].zone))
+						set_bit(epidx, &share_bit);
+					else
+						set_bit(epidx, &unshare_bit);
+					break;
+
+				case EP_PARTNER_COMPLETE:
+				case EP_PARTNER_WAITING:
+					if ((res_buf->info.info[epidx].zone ==
+						FJES_ZONING_ZONE_TYPE_NONE) ||
+					    (res_buf->info.info[epidx].es_status !=
+						FJES_ZONING_STATUS_ENABLE) ||
+					    (res_buf->info.info[epidx].zone !=
+						res_buf->info.
+						  info[hw->my_epid].zone)) {
+
+						set_bit(epidx,
+						  &adapter->unshare_watch_bitmask);
+						set_bit(epidx,
+						  &hw->hw_info.buffer_unshare_reserve_bit);
+					}
+					break;
+
+				case EP_PARTNER_SHARED:
+					if ((res_buf->info.info[epidx].zone ==
+						FJES_ZONING_ZONE_TYPE_NONE) ||
+					    (res_buf->info.info[epidx].es_status !=
+						FJES_ZONING_STATUS_ENABLE) ||
+					    (res_buf->info.info[epidx].zone !=
+						res_buf->info.
+						  info[hw->my_epid].zone))
+
+						set_bit(epidx, &irq_bit);
+					break;
+				}
+
+			}
+
+			if (hw->ep_shm_info[epidx].zone !=
+						res_buf->info.info[epidx].zone)
+				update = true;
+			hw->ep_shm_info[epidx].es_status =
+				res_buf->info.info[epidx].es_status;
+			hw->ep_shm_info[epidx].zone =
+				res_buf->info.info[epidx].zone;
+
+		}
+		break;
+	}
+
+	mutex_unlock(&hw->hw_info.lock);
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+
+		if (epidx == hw->my_epid)
+			continue;
+
+		if (test_bit(epidx, &share_bit)) {
+
+			fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+				netdev->dev_addr, netdev->mtu);
+
+			mutex_lock(&hw->hw_info.lock);
+
+			ret = fjes_hw_register_buff_addr(hw, epidx,
+				&hw->ep_shm_info[epidx]);
+
+			switch (ret) {
+			case 0:
+				break;
+			case -ENOMSG:
+			case -EBUSY:
+			default:
+				if (!work_pending(&adapter->force_close_task)) {
+					adapter->force_reset = true;
+					schedule_work(
+					  &adapter->force_close_task);
+				}
+				break;
+			}
+
+			mutex_unlock(&hw->hw_info.lock);
+		}
+
+
+		if (test_bit(epidx, &unshare_bit)) {
+
+			mutex_lock(&hw->hw_info.lock);
+
+			ret = fjes_hw_unregister_buff_addr(hw, epidx);
+
+			switch (ret) {
+			case 0:
+				break;
+			case -ENOMSG:
+			case -EBUSY:
+			default:
+				if (!work_pending(&adapter->force_close_task)) {
+					adapter->force_reset = true;
+					schedule_work(
+					  &adapter->force_close_task);
+				}
+				break;
+			}
+
+			mutex_unlock(&hw->hw_info.lock);
+
+			if (ret == 0)
+				fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+					netdev->dev_addr, netdev->mtu);
+
+		}
+
+		if (test_bit(epidx, &irq_bit)) {
+			fjes_hw_raise_interrupt(hw, epidx,
+				REG_ICTL_MASK_TXRX_STOP_REQ);
+
+			set_bit(epidx, &hw->txrx_stop_req_bit);
+			hw->ep_shm_info[epidx].tx.
+				info->v1i.rx_status |=
+					FJES_RX_STOP_REQ_REQUEST;
+			set_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
+		}
+
+	}
+
+	if (irq_bit || adapter->unshare_watch_bitmask) {
+		if (!work_pending(&adapter->unshare_watch_task))
+			queue_work(adapter->control_wq,
+				&adapter->unshare_watch_task);
+	}
+}
+
+static void fjes_hw_epstop_task(struct work_struct *work)
+{
+	struct fjes_hw *hw = container_of(work,
+			struct fjes_hw, epstop_task);
+	struct fjes_adapter *adapter = (struct fjes_adapter *)hw->back;
+	int epid_bit;
+	unsigned long remain_bit;
+
+	while ((remain_bit = hw->epstop_req_bit)) {
+
+		for (epid_bit = 0; remain_bit; (remain_bit >>= 1),
+			(epid_bit++)) {
+
+			if (remain_bit & 1) {
+
+				hw->ep_shm_info[epid_bit].
+					tx.info->v1i.rx_status |=
+						FJES_RX_STOP_REQ_DONE;
+
+				clear_bit(epid_bit, &hw->epstop_req_bit);
+				set_bit(epid_bit,
+					&adapter->unshare_watch_bitmask);
+
+				if (!work_pending(&adapter->unshare_watch_task))
+					queue_work(adapter->control_wq,
+						&adapter->unshare_watch_task);
+			}
+		}
+	}
+}
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index 80aaf4d..0bf8efc 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -23,6 +23,8 @@
 #include <linux/types.h>
 #include <linux/nls.h>
 #include <linux/platform_device.h>
+#include <linux/netdevice.h>
+#include <linux/interrupt.h>
 
 #include "fjes.h"
 
@@ -43,6 +45,22 @@ MODULE_DESCRIPTION("FUJITSU Extended Socket Network Device Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+static int fjes_request_irq(struct fjes_adapter *);
+static void fjes_free_irq(struct fjes_adapter *);
+
+static int fjes_open(struct net_device *);
+static int fjes_close(struct net_device *);
+static int fjes_setup_resources(struct fjes_adapter *);
+static void fjes_free_resources(struct fjes_adapter *);
+static netdev_tx_t fjes_xmit_frame(struct sk_buff *,
+		struct net_device *);
+static void fjes_tx_retry(struct net_device *);
+static struct rtnl_link_stats64
+*fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
+static int fjes_change_mtu(struct net_device *, int);
+static int fjes_vlan_rx_add_vid(struct net_device *, __be16 proto, u16);
+static int fjes_vlan_rx_kill_vid(struct net_device *, __be16 proto, u16);
+static irqreturn_t fjes_intr(int, void*);
 
 static int fjes_acpi_add(struct acpi_device *);
 static int fjes_acpi_remove(struct acpi_device *);
@@ -51,6 +69,17 @@ static acpi_status fjes_get_acpi_resource(struct acpi_resource *, void*);
 static int fjes_probe(struct platform_device *);
 static int fjes_remove(struct platform_device *);
 
+static int fjes_sw_init(struct fjes_adapter *);
+static void fjes_force_close_task(struct work_struct *);
+static void fjes_tx_stall_task(struct work_struct *);
+static void fjes_raise_intr_rxdata_task(struct work_struct *);
+static void fjes_watch_unsahre_task(struct work_struct *);
+static void fjes_irq_watch_task(struct work_struct *);
+static void fjes_netdev_setup(struct net_device *);
+
+static void fjes_rx_irq(struct fjes_adapter *, int);
+static int fjes_poll(struct napi_struct *, int);
+
 
 static const struct acpi_device_id fjes_acpi_ids[] = {
 	{"PNP0C02", 0},
@@ -224,6 +253,831 @@ static acpi_status fjes_get_acpi_resource(struct acpi_resource *acpi_res,
 	return AE_OK;
 }
 
+static int fjes_request_irq(struct fjes_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	int result = -1;
+
+	adapter->interrupt_watch_enable = true;
+	if (!delayed_work_pending(&adapter->interrupt_watch_task)) {
+		queue_delayed_work(adapter->control_wq,
+				&adapter->interrupt_watch_task,
+				FJES_IRQ_WATCH_DELAY);
+	}
+
+	if (!adapter->irq_registered) {
+		result = request_irq(adapter->hw.hw_res.irq, fjes_intr,
+					IRQF_SHARED, netdev->name, adapter);
+		if (result)
+			adapter->irq_registered = false;
+		else
+			adapter->irq_registered = true;
+	}
+
+	return result;
+}
+
+
+static void fjes_free_irq(struct fjes_adapter *adapter)
+{
+	struct fjes_hw *hw = &adapter->hw;
+
+	adapter->interrupt_watch_enable = false;
+	cancel_delayed_work_sync(&adapter->interrupt_watch_task);
+
+	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_ALL, true);
+
+	if (adapter->irq_registered) {
+		free_irq(adapter->hw.hw_res.irq, adapter);
+		adapter->irq_registered = false;
+	}
+}
+
+
+
+static const struct net_device_ops fjes_netdev_ops = {
+	.ndo_open		= fjes_open,
+	.ndo_stop		= fjes_close,
+	.ndo_start_xmit		= fjes_xmit_frame,
+	.ndo_get_stats64	= fjes_get_stats64,
+	.ndo_change_mtu		= fjes_change_mtu,
+	.ndo_tx_timeout		= fjes_tx_retry,
+	.ndo_vlan_rx_add_vid	= fjes_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid = fjes_vlan_rx_kill_vid,
+};
+
+
+/*
+ *  fjes_open - Called when a network interface is made active
+ */
+static int fjes_open(struct net_device *netdev)
+{
+	int result;
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+
+	if (adapter->open_guard)
+		return -ENXIO;
+
+	result = fjes_setup_resources(adapter);
+	if (result)
+		goto err_setup_res;
+
+	hw->txrx_stop_req_bit = 0;
+	hw->epstop_req_bit = 0;
+
+	napi_enable(&adapter->napi);
+
+	fjes_hw_capture_interrupt_status(hw);
+
+	result = fjes_request_irq(adapter);
+	if (result)
+		goto err_req_irq;
+
+	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_ALL, false);
+
+	netif_tx_start_all_queues(netdev);
+	netif_carrier_on(netdev);
+
+	return 0;
+
+err_req_irq:
+	fjes_free_irq(adapter);
+	napi_disable(&adapter->napi);
+
+err_setup_res:
+	fjes_free_resources(adapter);
+	return result;
+
+}
+
+/*
+ *  fjes_close - Disables a network interface
+ */
+static int fjes_close(struct net_device *netdev)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+	int epidx;
+
+	netif_tx_stop_all_queues(netdev);
+	netif_carrier_off(netdev);
+
+	fjes_hw_raise_epstop(hw);
+
+	napi_disable(&adapter->napi);
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		adapter->hw.ep_shm_info[epidx].tx.info->v1i.rx_status &=
+			~FJES_RX_POLL_WORK;
+	}
+
+	fjes_free_irq(adapter);
+
+	cancel_work_sync(&adapter->tx_stall_task);
+	cancel_work_sync(&adapter->raise_intr_rxdata_task);
+	cancel_work_sync(&adapter->unshare_watch_task);
+	adapter->unshare_watch_bitmask = 0;
+
+	cancel_work_sync(&hw->update_zone_task);
+	cancel_work_sync(&hw->epstop_task);
+
+	fjes_hw_wait_epstop(hw);
+
+	fjes_free_resources(adapter);
+
+	return 0;
+}
+
+
+static int fjes_setup_resources(struct fjes_adapter *adapter)
+{
+	int epidx;
+	struct ep_share_mem_info *buf_pair;
+	int result;
+	struct fjes_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+
+
+	mutex_lock(&hw->hw_info.lock);
+	result = fjes_hw_request_info(hw);
+	switch (result) {
+	case 0:
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+			hw->ep_shm_info[epidx].es_status =
+			    hw->hw_info.res_buf->info.info[epidx].es_status;
+			hw->ep_shm_info[epidx].zone =
+			    hw->hw_info.res_buf->info.info[epidx].zone;
+		}
+		break;
+	default:
+	case -ENOMSG:
+	case -EBUSY:
+		adapter->force_reset = true;
+
+		mutex_unlock(&hw->hw_info.lock);
+		return result;
+	}
+	mutex_unlock(&hw->hw_info.lock);
+
+
+	for (epidx = 0; epidx < (hw->max_epid); epidx++) {
+		if ((epidx != hw->my_epid) &&
+			(hw->ep_shm_info[epidx].es_status ==
+				FJES_ZONING_STATUS_ENABLE)) {
+			fjes_hw_raise_interrupt(hw, epidx,
+					REG_ICTL_MASK_INFO_UPDATE);
+		}
+	}
+
+	msleep(FJES_OPEN_ZONE_UPDATE_WAIT * hw->max_epid);
+
+
+	for (epidx = 0; epidx < (hw->max_epid); epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		buf_pair = &(hw->ep_shm_info[epidx]);
+
+		fjes_hw_setup_epbuf(&(buf_pair->tx), netdev->dev_addr,
+				netdev->mtu);
+
+		if (fjes_hw_epid_is_same_zone(hw, epidx)) {
+			mutex_lock(&hw->hw_info.lock);
+			result = fjes_hw_register_buff_addr(hw, epidx,
+					buf_pair);
+			mutex_unlock(&hw->hw_info.lock);
+
+			switch (result) {
+			case 0:
+				break;
+			case -ENOMSG:
+			case -EBUSY:
+			default:
+				adapter->force_reset = true;
+				return result;
+			}
+		}
+	}
+
+	return 0;
+}
+
+static void fjes_free_resources(struct fjes_adapter *adapter)
+{
+	int epidx;
+	struct ep_share_mem_info *buf_pair;
+	int result;
+	struct fjes_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	struct fjes_device_command_param param;
+	bool reset_flag = false;
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		mutex_lock(&hw->hw_info.lock);
+		result = fjes_hw_unregister_buff_addr(hw, epidx);
+		mutex_unlock(&hw->hw_info.lock);
+
+		if (result)
+			reset_flag = true;
+
+		buf_pair = &hw->ep_shm_info[epidx];
+
+		fjes_hw_setup_epbuf(&buf_pair->tx, netdev->dev_addr,
+				netdev->mtu);
+
+		clear_bit(epidx, &hw->txrx_stop_req_bit);
+	}
+
+	if (reset_flag || adapter->force_reset) {
+
+		result = fjes_hw_reset(hw);
+
+		adapter->force_reset = false;
+
+		if (result)
+			adapter->open_guard = true;
+
+		hw->hw_info.buffer_share_bit = 0;
+
+		memset((void *)&param, 0, sizeof(param));
+
+		param.req_len = hw->hw_info.req_buf_size;
+		param.req_start = __pa(hw->hw_info.req_buf);
+		param.res_len = hw->hw_info.res_buf_size;
+		param.res_start = __pa(hw->hw_info.res_buf);
+		param.share_start = __pa(hw->hw_info.share->ep_status);
+
+		fjes_hw_init_command_registers(hw, &param);
+	}
+
+
+}
+
+
+static int fjes_tx_send(struct fjes_adapter *adapter, int dest,
+				void *data, size_t len)
+{
+	int retval;
+
+	retval = fjes_hw_epbuf_tx_pkt_send(
+		&(adapter->hw.ep_shm_info[dest].tx), data, len);
+	if (retval)
+		return retval;
+
+	adapter->hw.ep_shm_info[dest].tx.info->v1i.tx_status =
+		FJES_TX_DELAY_SEND_PENDING;
+	if (!work_pending(&adapter->raise_intr_rxdata_task))
+		queue_work(adapter->txrx_wq, &adapter->raise_intr_rxdata_task);
+
+	retval = 0;
+	return retval;
+}
+
+static netdev_tx_t fjes_xmit_frame(struct sk_buff *skb,
+		struct net_device *netdev)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+	enum ep_partner_status pstatus;
+
+	int len;
+	char *data, shortpkt[VLAN_ETH_HLEN];
+
+	u16 queue_no = 0;
+	struct netdev_queue *cur_queue = netdev_get_tx_queue(netdev, queue_no);
+	netdev_tx_t ret = NETDEV_TX_OK;
+	struct ethhdr *eth;
+	int dest_epid;
+
+	int max_epid, my_epid;
+	u16 vlan_id = 0;
+	bool vlan = false;
+	bool is_multi = false;
+
+	eth = (struct ethhdr *)skb->data;
+	my_epid = hw->my_epid;
+
+	vlan = (vlan_get_tag(skb, &vlan_id) == 0) ? true : false;
+
+	data = skb->data;
+	len = skb->len;
+
+	if (is_multicast_ether_addr(eth->h_dest)) {
+		dest_epid = 0;
+		max_epid = hw->max_epid;
+		is_multi = true;
+	} else if (is_local_ether_addr(eth->h_dest)) {
+
+		dest_epid = eth->h_dest[ETH_ALEN - 1];
+		max_epid = dest_epid + 1;
+
+		if ((eth->h_dest[0] == 0x02) &&
+			(0x00 == (eth->h_dest[1] | eth->h_dest[2] |
+				eth->h_dest[3] | eth->h_dest[4])) &&
+			(dest_epid < hw->max_epid)) {
+			;
+		} else {
+
+			dest_epid = 0;
+			max_epid = 0;
+			ret = NETDEV_TX_OK;
+
+			adapter->stats64.tx_packets += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_packets += 1;
+			adapter->stats64.tx_bytes += len;
+			hw->ep_shm_info[my_epid].net_stats.tx_bytes += len;
+
+		}
+	} else {
+
+		dest_epid = 0;
+		max_epid = 0;
+		ret = NETDEV_TX_OK;
+
+		adapter->stats64.tx_packets += 1;
+		hw->ep_shm_info[my_epid].net_stats.tx_packets += 1;
+		adapter->stats64.tx_bytes += len;
+		hw->ep_shm_info[my_epid].net_stats.tx_bytes += len;
+
+	}
+
+	for (; dest_epid < max_epid; dest_epid++) {
+
+		if (my_epid == dest_epid)
+			continue;
+
+		pstatus = fjes_hw_get_partner_ep_status(hw, dest_epid);
+		if (pstatus != EP_PARTNER_SHARED)
+			ret = NETDEV_TX_OK;
+		else if (!fjes_hw_check_epbuf_version(
+				&(adapter->hw.ep_shm_info[dest_epid].rx), 0)) {
+
+			/* version is NOT 0 */
+			adapter->stats64.tx_carrier_errors += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_carrier_errors += 1;
+
+			ret = NETDEV_TX_OK;
+		} else if (!fjes_hw_check_mtu(
+				&(adapter->hw.ep_shm_info[dest_epid].rx),
+				netdev->mtu)) {
+
+			adapter->stats64.tx_dropped += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_dropped += 1;
+			adapter->stats64.tx_errors += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_errors += 1;
+
+			ret = NETDEV_TX_OK;
+
+		} else if ((vlan == true) &&
+			   !fjes_hw_check_vlan_id(
+				&(adapter->hw.ep_shm_info[dest_epid].rx),
+				vlan_id)) {
+
+			ret = NETDEV_TX_OK;
+
+		} else {
+
+			if (len < VLAN_ETH_HLEN) {
+				memset(shortpkt, 0, VLAN_ETH_HLEN);
+				memcpy(shortpkt, skb->data, skb->len);
+				len = VLAN_ETH_HLEN;
+				data = shortpkt;
+			}
+
+			if (adapter->tx_retry_count == 0) {
+				adapter->tx_start_jiffies = jiffies;
+				adapter->tx_retry_count = 1;
+			} else {
+				adapter->tx_retry_count++;
+			}
+
+			if (fjes_tx_send(adapter, dest_epid, data, len)) {
+
+				if (is_multi) {
+					ret = NETDEV_TX_OK;
+				} else if (
+					   ((long)jiffies -
+					    (long)adapter->tx_start_jiffies) >=
+					    FJES_TX_RETRY_TIMEOUT) {
+
+					adapter->stats64.tx_fifo_errors += 1;
+					hw->ep_shm_info[my_epid].net_stats.tx_fifo_errors += 1;
+					adapter->stats64.tx_errors += 1;
+					hw->ep_shm_info[my_epid].net_stats.tx_errors += 1;
+
+					ret = NETDEV_TX_OK;
+				} else {
+
+					netdev->trans_start = jiffies;
+					netif_tx_stop_queue(cur_queue);
+					if (!work_pending(&adapter->tx_stall_task))
+						queue_work(adapter->txrx_wq, &adapter->tx_stall_task);
+
+					ret = NETDEV_TX_BUSY;
+				}
+			} else {
+
+				if (!is_multi) {
+					adapter->stats64.tx_packets += 1;
+					hw->ep_shm_info[my_epid].net_stats.tx_packets += 1;
+					adapter->stats64.tx_bytes += len;
+					hw->ep_shm_info[my_epid].net_stats.tx_bytes += len;
+				}
+
+				adapter->tx_retry_count = 0;
+				ret = NETDEV_TX_OK;
+
+			}
+		}
+	}
+
+
+	if (ret == NETDEV_TX_OK) {
+		dev_kfree_skb(skb);
+		if (is_multi) {
+			adapter->stats64.tx_packets += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_packets += 1;
+			adapter->stats64.tx_bytes += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_bytes += len;
+		}
+	}
+
+	return ret;
+}
+
+static void fjes_tx_retry(struct net_device *netdev)
+{
+	struct netdev_queue *curQueue = netdev_get_tx_queue(netdev, 0);
+
+	netif_tx_wake_queue(curQueue);
+}
+
+
+
+static struct rtnl_link_stats64
+*fjes_get_stats64(struct net_device *netdev,
+		struct rtnl_link_stats64 *stats)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+
+	memcpy(stats, &adapter->stats64, sizeof(struct rtnl_link_stats64));
+
+	return stats;
+}
+
+
+static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	int idx;
+	bool running = netif_running(netdev);
+	int ret = 0;
+
+	for (idx = 0; fjes_support_mtu[idx] != 0; idx++) {
+		if (new_mtu <= fjes_support_mtu[idx]) {
+
+			new_mtu = fjes_support_mtu[idx];
+			if (new_mtu == netdev->mtu)
+				return 0;
+
+			if (running)
+				fjes_close(netdev);
+
+			netdev->mtu = new_mtu;
+
+			if (running)
+				ret = fjes_open(netdev);
+
+			return ret;
+		}
+	}
+
+	return -EINVAL;
+}
+
+
+static int fjes_vlan_rx_add_vid(struct net_device *netdev,
+		__be16 proto, u16 vid)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	bool ret = true;
+	int epid;
+
+	for (epid = 0; epid < adapter->hw.max_epid; epid++) {
+		if (epid == adapter->hw.my_epid)
+			continue;
+
+		if (!fjes_hw_check_vlan_id(
+			&(adapter->hw.ep_shm_info[epid].tx), vid))
+			ret = fjes_hw_set_vlan_id(
+				&(adapter->hw.ep_shm_info[epid].tx), vid);
+	}
+
+	return ret ? 0 : -ENOSPC;
+}
+
+static int fjes_vlan_rx_kill_vid(struct net_device *netdev,
+		__be16 proto, u16 vid)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	int epid;
+
+	for (epid = 0; epid < adapter->hw.max_epid; epid++) {
+		if (epid == adapter->hw.my_epid)
+			continue;
+
+		fjes_hw_del_vlan_id(&(adapter->hw.ep_shm_info[epid].tx), vid);
+	}
+
+	return 0;
+}
+
+static void fjes_txrx_stop_req_irq(struct fjes_adapter *adapter,
+		int src_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+	enum ep_partner_status status;
+
+	status = fjes_hw_get_partner_ep_status(hw, src_epid);
+	switch (status) {
+	case EP_PARTNER_UNSHARE:
+	default:
+		break;
+	case EP_PARTNER_COMPLETE:
+		break;
+	case EP_PARTNER_WAITING:
+		if (src_epid < hw->my_epid) {
+			hw->ep_shm_info[src_epid].tx.info->v1i.rx_status |=
+				FJES_RX_STOP_REQ_DONE;
+
+			clear_bit(src_epid, &hw->txrx_stop_req_bit);
+			set_bit(src_epid, &adapter->unshare_watch_bitmask);
+
+			if (!work_pending(&adapter->unshare_watch_task))
+				queue_work(adapter->control_wq,
+						&adapter->unshare_watch_task);
+		}
+		break;
+	case EP_PARTNER_SHARED:
+		if (hw->ep_shm_info[src_epid].rx.info->v1i.rx_status
+				& FJES_RX_STOP_REQ_REQUEST) {
+
+			set_bit(src_epid, &hw->epstop_req_bit);
+
+			if (!work_pending(&hw->epstop_task))
+				queue_work(adapter->control_wq, &hw->epstop_task);
+
+		}
+		break;
+	}
+}
+
+static void fjes_stop_req_irq(struct fjes_adapter *adapter,
+		int src_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+	enum ep_partner_status status;
+
+	set_bit(src_epid, &hw->hw_info.buffer_unshare_reserve_bit);
+
+	status = fjes_hw_get_partner_ep_status(hw, src_epid);
+	switch (status) {
+	case EP_PARTNER_WAITING:
+		hw->ep_shm_info[src_epid].tx.info->v1i.rx_status |=
+				FJES_RX_STOP_REQ_DONE;
+		clear_bit(src_epid, &hw->txrx_stop_req_bit);
+		/* fall through */
+	case EP_PARTNER_UNSHARE:
+	case EP_PARTNER_COMPLETE:
+	default:
+		set_bit(src_epid, &adapter->unshare_watch_bitmask);
+		if (!work_pending(&adapter->unshare_watch_task))
+			queue_work(adapter->control_wq,
+					&adapter->unshare_watch_task);
+
+		break;
+	case EP_PARTNER_SHARED:
+		set_bit(src_epid, &hw->epstop_req_bit);
+
+		if (!work_pending(&hw->epstop_task))
+			queue_work(adapter->control_wq, &hw->epstop_task);
+
+		break;
+	}
+
+}
+
+static void fjes_update_zone_irq(struct fjes_adapter *adapter,
+		int src_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+
+	if (!work_pending(&hw->update_zone_task))
+		queue_work(adapter->control_wq, &hw->update_zone_task);
+}
+
+static irqreturn_t fjes_intr(int irq, void *data)
+{
+	struct fjes_adapter *adapter = data;
+	struct fjes_hw *hw = &adapter->hw;
+	irqreturn_t ret;
+	u32 icr;
+
+	icr = fjes_hw_capture_interrupt_status(hw);
+
+	if (icr & REG_IS_MASK_IS_ASSERT) {
+
+		if (icr & REG_ICTL_MASK_RX_DATA)
+			fjes_rx_irq(adapter, icr & REG_IS_MASK_EPID);
+
+		if (icr & REG_ICTL_MASK_TXRX_STOP_REQ)
+			fjes_txrx_stop_req_irq(adapter, icr & REG_IS_MASK_EPID);
+
+		if (icr & REG_ICTL_MASK_TXRX_STOP_DONE)
+			fjes_hw_set_irqmask(hw,
+				REG_ICTL_MASK_TXRX_STOP_DONE, true);
+
+		if (icr & REG_ICTL_MASK_DEV_STOP_REQ)
+			fjes_stop_req_irq(adapter, icr & REG_IS_MASK_EPID);
+
+		if (icr & REG_ICTL_MASK_INFO_UPDATE)
+			fjes_update_zone_irq(adapter, icr & REG_IS_MASK_EPID);
+
+		ret = IRQ_HANDLED;
+	} else
+		ret = IRQ_NONE;
+
+	return ret;
+}
+
+static int fjes_rxframe_search_exist(struct fjes_adapter *adapter, int start_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+	int cur_epid;
+	int max_epid;
+	int i;
+	enum ep_partner_status pstatus;
+
+	max_epid = hw->max_epid;
+	start_epid = (start_epid + 1 + max_epid) % max_epid;
+
+	for (i = 0; i < max_epid; i++) {
+		cur_epid = (start_epid + i) % max_epid;
+		if (cur_epid == hw->my_epid)
+			continue;
+
+		pstatus = fjes_hw_get_partner_ep_status(hw, cur_epid);
+		if (pstatus == EP_PARTNER_SHARED) {
+
+			if (!fjes_hw_epbuf_rx_is_empty(&hw->ep_shm_info[cur_epid].rx))
+				return cur_epid;
+
+		}
+
+	}
+	return -1;
+}
+
+static void *fjes_rxframe_get(struct fjes_adapter *adapter, size_t *psize,
+		int *cur_epid)
+{
+	void *frameBuf;
+
+	*cur_epid = fjes_rxframe_search_exist(adapter, *cur_epid);
+	if (*cur_epid < 0)
+		return NULL;
+
+	frameBuf =
+	    fjes_hw_epbuf_rx_curpkt_get_addr(&
+					   (adapter->hw.
+					    ep_shm_info[*cur_epid].rx), psize);
+
+	return frameBuf;
+}
+
+static void fjes_rxframe_release(struct fjes_adapter *adapter,
+		int cur_epid)
+{
+	fjes_hw_epbuf_rx_curpkt_drop(&(adapter->hw.ep_shm_info[cur_epid].rx));
+}
+
+
+static void fjes_rx_irq(struct fjes_adapter *adapter, int src_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+
+	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_RX_DATA, true);
+
+	adapter->unset_rx_last = true;
+	napi_schedule(&adapter->napi);
+
+}
+
+static int fjes_poll(struct napi_struct *napi, int budget)
+{
+
+	struct fjes_adapter *adapter =
+			container_of(napi, struct fjes_adapter, napi);
+	struct fjes_hw *hw = &adapter->hw;
+	struct net_device *netdev = napi->dev;
+	int work_done = 0;
+	struct sk_buff *skb;
+	void *frameData;
+	size_t frameLen;
+	int cur_epid = 0;
+	int epidx = 0;
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		adapter->hw.ep_shm_info[epidx].tx.info->v1i.rx_status |=
+			FJES_RX_POLL_WORK;
+	}
+
+	while (work_done < budget) {
+
+		prefetch(&adapter->hw);
+		frameData = fjes_rxframe_get(adapter, &frameLen, &cur_epid);
+
+		if (frameData) {
+
+			skb = napi_alloc_skb(napi, frameLen);
+			if (!skb) {
+
+				adapter->stats64.rx_dropped += 1;
+				hw->ep_shm_info[cur_epid].net_stats.rx_dropped += 1;
+				adapter->stats64.rx_errors += 1;
+				hw->ep_shm_info[cur_epid].net_stats.rx_errors += 1;
+
+			} else {
+
+				memcpy(skb_put(skb, frameLen), frameData,
+					frameLen);
+				skb->protocol = eth_type_trans(skb, netdev);
+				skb->ip_summed = CHECKSUM_UNNECESSARY;	/* don't check it */
+
+				netif_receive_skb(skb);
+
+				work_done++;
+
+				adapter->stats64.rx_packets += 1;
+				hw->ep_shm_info[cur_epid].net_stats.rx_packets += 1;
+				adapter->stats64.rx_bytes += frameLen;
+				hw->ep_shm_info[cur_epid].net_stats.rx_bytes += frameLen;
+
+
+				if (is_multicast_ether_addr
+					(((struct ethhdr *)frameData)->h_dest)) {
+
+					adapter->stats64.multicast += 1;
+					hw->ep_shm_info[cur_epid].net_stats.multicast += 1;
+
+				}
+
+			}
+
+			fjes_rxframe_release(adapter, cur_epid);
+			adapter->unset_rx_last = true;
+		} else {
+			break;
+		}
+	}
+
+	if (work_done < budget) {
+
+		napi_complete(napi);
+
+		if (adapter->unset_rx_last) {
+			adapter->rx_last_jiffies = jiffies;
+			adapter->unset_rx_last = false;
+		}
+
+		if (((long)jiffies - (long)adapter->rx_last_jiffies) < 3)
+			napi_reschedule(napi);
+		else {
+
+			for (epidx = 0; epidx < hw->max_epid; epidx++) {
+				if (epidx == hw->my_epid)
+					continue;
+				adapter->hw.ep_shm_info[epidx].tx.info->v1i.rx_status &=
+						~FJES_RX_POLL_WORK;
+			}
+
+			fjes_hw_set_irqmask(hw, REG_ICTL_MASK_RX_DATA, false);
+		}
+	}
+
+	return work_done;
+}
+
+
 /*
  *  fjes_probe - Device Initialization Routine
  *
@@ -231,7 +1085,84 @@ static acpi_status fjes_get_acpi_resource(struct acpi_resource *acpi_res,
  */
 static int fjes_probe(struct platform_device *plat_dev)
 {
+	struct net_device *netdev;
+	struct fjes_adapter *adapter;
+	struct fjes_hw *hw;
+	struct resource *res;
+	int err;
+
+	err = -ENOMEM;
+	netdev = alloc_netdev_mq(sizeof(struct fjes_adapter), "es%d",
+			NET_NAME_UNKNOWN, fjes_netdev_setup, FJES_MAX_QUEUES);
+
+	if (!netdev)
+		goto err_alloc_netdev;
+
+	SET_NETDEV_DEV(netdev, &plat_dev->dev);
+
+	dev_set_drvdata(&plat_dev->dev, netdev);
+	adapter = netdev_priv(netdev);
+	adapter->netdev = netdev;
+	adapter->plat_dev = plat_dev;
+	hw = &adapter->hw;
+	hw->back = adapter;
+
+
+	/* setup the private structure */
+	err = fjes_sw_init(adapter);
+	if (err)
+		goto err_sw_init;
+
+
+	INIT_WORK(&adapter->force_close_task, fjes_force_close_task);
+	adapter->force_reset = false;
+	adapter->open_guard = false;
+
+	adapter->txrx_wq = create_workqueue(DRV_NAME"/txrx");
+	adapter->control_wq = create_workqueue(DRV_NAME"/control");
+
+	INIT_WORK(&adapter->tx_stall_task, fjes_tx_stall_task);
+	INIT_WORK(&adapter->raise_intr_rxdata_task,
+			fjes_raise_intr_rxdata_task);
+	INIT_WORK(&adapter->unshare_watch_task, fjes_watch_unsahre_task);
+	adapter->unshare_watch_bitmask = 0;
+
+	INIT_DELAYED_WORK(&adapter->interrupt_watch_task, fjes_irq_watch_task);
+	adapter->interrupt_watch_enable = false;
+
+
+	res = platform_get_resource(plat_dev, IORESOURCE_MEM, 0);
+	hw->hw_res.start = res->start;
+	hw->hw_res.size = res->end - res->start;
+	hw->hw_res.irq = platform_get_irq(plat_dev, 0);
+	err = fjes_hw_init(&adapter->hw);
+	if (err)
+		goto err_hw_init;
+
+	/* setup MAC address (02:00:00:00:00:[epid])*/
+	netdev->dev_addr[0] = 2;
+	netdev->dev_addr[1] = 0;
+	netdev->dev_addr[2] = 0;
+	netdev->dev_addr[3] = 0;
+	netdev->dev_addr[4] = 0;
+	netdev->dev_addr[5] = hw->my_epid; /* EPID */
+
+
+	err = register_netdev(netdev);
+	if (err)
+		goto err_register;
+
+	netif_carrier_off(netdev);
+
 	return 0;
+
+err_register:
+	fjes_hw_exit(&adapter->hw);
+err_hw_init:
+err_sw_init:
+	free_netdev(netdev);
+err_alloc_netdev:
+	return err;
 }
 
 /*
@@ -239,7 +1170,343 @@ static int fjes_probe(struct platform_device *plat_dev)
  */
 static int fjes_remove(struct platform_device *plat_dev)
 {
+	struct net_device *netdev = dev_get_drvdata(&plat_dev->dev);
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+
+	cancel_delayed_work_sync(&adapter->interrupt_watch_task);
+	cancel_work_sync(&adapter->unshare_watch_task);
+	cancel_work_sync(&adapter->raise_intr_rxdata_task);
+	cancel_work_sync(&adapter->tx_stall_task);
+	cancel_work_sync(&adapter->force_close_task);
+	if (adapter->control_wq)
+		destroy_workqueue(adapter->control_wq);
+	if (adapter->txrx_wq)
+		destroy_workqueue(adapter->txrx_wq);
+
+	unregister_netdev(netdev);
+
+	fjes_hw_exit(hw);
+	cancel_work_sync(&hw->update_zone_task);
+	cancel_work_sync(&hw->epstop_task);
+
+	netif_napi_del(&adapter->napi);
+
+	free_netdev(netdev);
+
+	return 0;
+}
+
+static int fjes_sw_init(struct fjes_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	netif_napi_add(netdev, &adapter->napi, fjes_poll, 64);
+
 	return 0;
 }
 
+/*
+ *  fjes_netdev_setup - netdevice initialization routine
+ */
+static void fjes_netdev_setup(struct net_device *netdev)
+{
+	ether_setup(netdev);
+
+	netdev->watchdog_timeo = FJES_TX_RETRY_INTERVAL;
+	netdev->netdev_ops = &fjes_netdev_ops;
+	netdev->mtu = fjes_support_mtu[0];
+	netdev->flags |= IFF_BROADCAST;
+	netdev->features |= NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_CTAG_FILTER;
+
+}
+
+static void fjes_force_close_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(work,
+			struct fjes_adapter, force_close_task);
+	struct net_device *netdev = adapter->netdev;
+
+	rtnl_lock();
+	dev_close(netdev);
+	rtnl_unlock();
+}
+
+static void fjes_tx_stall_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(work,
+			struct fjes_adapter, tx_stall_task);
+	struct fjes_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	enum ep_partner_status pstatus;
+	int epid;
+	int max_epid, my_epid;
+	union ep_buffer_info *info;
+	int all_queue_available;
+	int i;
+	int sendable;
+
+	if (((long)jiffies -
+		(long)(netdev->trans_start)) > FJES_TX_TX_STALL_TIMEOUT) {
+		netif_wake_queue(netdev);
+		return;
+	}
+
+	my_epid = hw->my_epid;
+	max_epid = hw->max_epid;
+
+	for (i = 0; i < 5; i++) {
+		all_queue_available = 1;
+
+		for (epid = 0; epid < max_epid; epid++) {
+
+			if (my_epid == epid)
+				continue;
+
+			pstatus = fjes_hw_get_partner_ep_status(hw, epid);
+			sendable = (pstatus == EP_PARTNER_SHARED);
+			if (!sendable)
+				continue;
+
+			info = adapter->hw.ep_shm_info[epid].tx.info;
+
+			if (EP_RING_FULL(info->v1i.head, info->v1i.tail,
+				info->v1i.count_max)) {
+				all_queue_available = 0;
+				break;
+			}
+		}
+
+		if (all_queue_available) {
+			netif_wake_queue(netdev);
+			return;
+		}
+	}
+
+	usleep_range(50, 100);
+
+	queue_work(adapter->txrx_wq, &adapter->tx_stall_task);
+}
+
+static void fjes_raise_intr_rxdata_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(work,
+			struct fjes_adapter, raise_intr_rxdata_task);
+	struct fjes_hw *hw = &adapter->hw;
+	int epid;
+	int max_epid, my_epid;
+	enum ep_partner_status pstatus;
+
+	my_epid = hw->my_epid;
+	max_epid = hw->max_epid;
+
+	for (epid = 0; epid < max_epid; epid++)
+		hw->ep_shm_info[epid].tx_status_work = 0;
+
+	for (epid = 0; epid < max_epid; epid++) {
+		if (epid == my_epid)
+			continue;
+
+		pstatus = fjes_hw_get_partner_ep_status(hw, epid);
+		if (pstatus == EP_PARTNER_SHARED) {
+
+			hw->ep_shm_info[epid].tx_status_work =
+				hw->ep_shm_info[epid].tx.info->v1i.tx_status;
+
+			if (hw->ep_shm_info[epid].tx_status_work ==
+				FJES_TX_DELAY_SEND_PENDING) {
+				hw->ep_shm_info[epid].tx.info->v1i.tx_status =
+					FJES_TX_DELAY_SEND_NONE;
+			}
+		}
+
+	}
+
+	for (epid = 0; epid < max_epid; epid++) {
+		if (epid == my_epid)
+			continue;
+
+		pstatus = fjes_hw_get_partner_ep_status(hw, epid);
+		if ((hw->ep_shm_info[epid].tx_status_work ==
+				FJES_TX_DELAY_SEND_PENDING) &&
+			(pstatus == EP_PARTNER_SHARED) &&
+			!(hw->ep_shm_info[epid].rx.info->v1i.rx_status)) {
+
+			fjes_hw_raise_interrupt(hw, epid, REG_ICTL_MASK_RX_DATA);
+
+		}
+
+	}
+
+	usleep_range(500, 1000);
+
+}
+
+static void fjes_watch_unsahre_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(work,
+			struct fjes_adapter, unshare_watch_task);
+	struct fjes_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	int epidx;
+	int max_epid, my_epid;
+	unsigned long unshare_watch_bitmask;
+	int wait_time = 0;
+	int is_shared;
+	int ret;
+
+	my_epid = hw->my_epid;
+	max_epid = hw->max_epid;
+
+	unshare_watch_bitmask = adapter->unshare_watch_bitmask;
+	adapter->unshare_watch_bitmask = 0;
+
+	while ((unshare_watch_bitmask || hw->txrx_stop_req_bit) &&
+			(wait_time < 3000)) {
+
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+
+			if (epidx == hw->my_epid)
+				continue;
+
+			if (test_bit(epidx, &hw->txrx_stop_req_bit)) {
+
+				is_shared = fjes_hw_epid_is_shared(hw->hw_info.share, epidx);
+				if (!is_shared ||
+					(is_shared &&
+					 (FJES_RX_STOP_REQ_DONE &
+					  hw->ep_shm_info[epidx].rx.info->v1i.rx_status))) {
+
+					mutex_lock(&hw->hw_info.lock);
+					ret = fjes_hw_unregister_buff_addr(hw, epidx);
+					switch (ret) {
+					case 0:
+						break;
+					case -ENOMSG:
+					case -EBUSY:
+					default:
+
+						if (!work_pending(&adapter->force_close_task)) {
+							adapter->force_reset = true;
+							schedule_work(&adapter->force_close_task);
+						}
+						break;
+					}
+					mutex_unlock(&hw->hw_info.lock);
+
+					fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+						netdev->dev_addr, netdev->mtu);
+
+					clear_bit(epidx, &hw->txrx_stop_req_bit);
+					clear_bit(epidx, &unshare_watch_bitmask);
+					clear_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
+
+				}
+			}
+
+			is_shared = fjes_hw_epid_is_shared(hw->hw_info.share, epidx);
+			if (!is_shared && test_bit(epidx, &unshare_watch_bitmask)) {
+
+				if (test_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit)) {
+
+					mutex_lock(&hw->hw_info.lock);
+					ret = fjes_hw_unregister_buff_addr(hw, epidx);
+					switch (ret) {
+					case 0:
+						break;
+					case -ENOMSG:
+					case -EBUSY:
+					default:
+
+						if (!work_pending(&adapter->force_close_task)) {
+							adapter->force_reset = true;
+							schedule_work(&adapter->force_close_task);
+						}
+						break;
+					}
+					mutex_unlock(&hw->hw_info.lock);
+
+					fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+						netdev->dev_addr, netdev->mtu);
+
+					clear_bit(epidx, &hw->txrx_stop_req_bit);
+					clear_bit(epidx, &unshare_watch_bitmask);
+					clear_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
+
+				}
+			}
+
+		}
+		msleep(100);
+		wait_time += 100;
+	}
+
+	if (hw->hw_info.buffer_unshare_reserve_bit) {
+
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+
+			if (epidx == hw->my_epid)
+				continue;
+
+			if (test_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit)) {
+
+				mutex_lock(&hw->hw_info.lock);
+
+				ret = fjes_hw_unregister_buff_addr(hw, epidx);
+				switch (ret) {
+				case 0:
+					break;
+				case -ENOMSG:
+				case -EBUSY:
+				default:
+
+					if (!work_pending(&adapter->force_close_task)) {
+						adapter->force_reset = true;
+						schedule_work(&adapter->force_close_task);
+					}
+					break;
+				}
+				mutex_unlock(&hw->hw_info.lock);
+
+				fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+					netdev->dev_addr, netdev->mtu);
+
+				clear_bit(epidx, &hw->txrx_stop_req_bit);
+				clear_bit(epidx, &unshare_watch_bitmask);
+				clear_bit(epidx,
+				  &hw->hw_info.buffer_unshare_reserve_bit);
+			}
+
+			if (test_bit(epidx, &unshare_watch_bitmask)) {
+				hw->ep_shm_info[epidx].tx.info->v1i.rx_status &=
+						~FJES_RX_STOP_REQ_DONE;
+			}
+		}
+
+	}
+
+}
+
+static void fjes_irq_watch_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(to_delayed_work(work),
+			struct fjes_adapter, interrupt_watch_task);
+
+	local_irq_disable();
+	fjes_intr(adapter->hw.hw_res.irq, adapter);
+	local_irq_enable();
+
+	if (fjes_rxframe_search_exist(adapter, 0) >= 0)
+		napi_schedule(&adapter->napi);
+
+
+	if (adapter->interrupt_watch_enable) {
+		if (!delayed_work_pending(&adapter->interrupt_watch_task))
+			queue_delayed_work(adapter->control_wq,
+					&adapter->interrupt_watch_task,
+					FJES_IRQ_WATCH_DELAY);
+	}
+
+}
+
 
diff --git a/drivers/platform/x86/fjes/fjes_regs.h b/drivers/platform/x86/fjes/fjes_regs.h
index 490737b..dbccf71 100644
--- a/drivers/platform/x86/fjes/fjes_regs.h
+++ b/drivers/platform/x86/fjes/fjes_regs.h
@@ -147,5 +147,4 @@ do { \
 
 #define rd32(reg) (fjes_hw_rd32(hw, reg))
 
-
 #endif /* FJES_REGS_H_ */
-- 
1.8.3.1

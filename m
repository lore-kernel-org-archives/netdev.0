From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v3 07/22] fjes: net_device_ops.ndo_open and .ndo_stop
Date: Fri, 21 Aug 2015 17:29:23 +0900
Message-ID: <1440145778-15941-7-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440145680-15851-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds net_device_ops.ndo_open and .ndo_stop
callback. These function is called when network device
activation and deactivation.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes.h      |   1 +
 drivers/net/fjes/fjes_hw.c   | 145 +++++++++++++++++++++++++
 drivers/net/fjes/fjes_hw.h   |  30 ++++++
 drivers/net/fjes/fjes_main.c | 246 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_regs.h |  17 +++
 5 files changed, 439 insertions(+)

diff --git a/drivers/net/fjes/fjes.h b/drivers/net/fjes/fjes.h
index 54bc189..f182ed3 100644
--- a/drivers/net/fjes/fjes.h
+++ b/drivers/net/fjes/fjes.h
@@ -29,6 +29,7 @@
 #define FJES_ACPI_SYMBOL	"Extended Socket"
 #define FJES_MAX_QUEUES		1
 #define FJES_TX_RETRY_INTERVAL	(20 * HZ)
+#define FJES_OPEN_ZONE_UPDATE_WAIT	(300) /* msec */
 
 /* board specific private data structure */
 struct fjes_adapter {
diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index 1e807df..1935f48 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -638,6 +638,25 @@ int fjes_hw_unregister_buff_addr(struct fjes_hw *hw, int dest_epid)
 	return result;
 }
 
+int fjes_hw_raise_interrupt(struct fjes_hw *hw, int dest_epid,
+			    enum REG_ICTL_MASK  mask)
+{
+	u32 ig = mask | dest_epid;
+
+	wr32(XSCT_IG, cpu_to_le32(ig));
+
+	return 0;
+}
+
+u32 fjes_hw_capture_interrupt_status(struct fjes_hw *hw)
+{
+	u32 cur_is;
+
+	cur_is = rd32(XSCT_IS);
+
+	return cur_is;
+}
+
 void fjes_hw_set_irqmask(struct fjes_hw *hw,
 			 enum REG_ICTL_MASK intr_mask, bool mask)
 {
@@ -646,3 +665,129 @@ void fjes_hw_set_irqmask(struct fjes_hw *hw,
 	else
 		wr32(XSCT_IMC, intr_mask);
 }
+
+bool fjes_hw_epid_is_same_zone(struct fjes_hw *hw, int epid)
+{
+	if (epid >= hw->max_epid)
+		return false;
+
+	if ((hw->ep_shm_info[epid].es_status !=
+			FJES_ZONING_STATUS_ENABLE) ||
+		(hw->ep_shm_info[hw->my_epid].zone ==
+			FJES_ZONING_ZONE_TYPE_NONE))
+		return false;
+	else
+		return (hw->ep_shm_info[epid].zone ==
+				hw->ep_shm_info[hw->my_epid].zone);
+}
+
+int fjes_hw_epid_is_shared(struct fjes_device_shared_info *share,
+			   int dest_epid)
+{
+	int value = false;
+
+	if (dest_epid < share->epnum)
+		value = share->ep_status[dest_epid];
+
+	return value;
+}
+
+static bool fjes_hw_epid_is_stop_requested(struct fjes_hw *hw, int src_epid)
+{
+	return test_bit(src_epid, &hw->txrx_stop_req_bit);
+}
+
+static bool fjes_hw_epid_is_stop_process_done(struct fjes_hw *hw, int src_epid)
+{
+	return (hw->ep_shm_info[src_epid].tx.info->v1i.rx_status &
+			FJES_RX_STOP_REQ_DONE);
+}
+
+enum ep_partner_status
+fjes_hw_get_partner_ep_status(struct fjes_hw *hw, int epid)
+{
+	enum ep_partner_status status;
+
+	if (fjes_hw_epid_is_shared(hw->hw_info.share, epid)) {
+		if (fjes_hw_epid_is_stop_requested(hw, epid)) {
+			status = EP_PARTNER_WAITING;
+		} else {
+			if (fjes_hw_epid_is_stop_process_done(hw, epid))
+				status = EP_PARTNER_COMPLETE;
+			else
+				status = EP_PARTNER_SHARED;
+		}
+	} else {
+		status = EP_PARTNER_UNSHARE;
+	}
+
+	return status;
+}
+
+void fjes_hw_raise_epstop(struct fjes_hw *hw)
+{
+	enum ep_partner_status status;
+	int epidx;
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		status = fjes_hw_get_partner_ep_status(hw, epidx);
+		switch (status) {
+		case EP_PARTNER_SHARED:
+			fjes_hw_raise_interrupt(hw, epidx,
+						REG_ICTL_MASK_TXRX_STOP_REQ);
+			break;
+		default:
+			break;
+		}
+
+		set_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
+		set_bit(epidx, &hw->txrx_stop_req_bit);
+
+		hw->ep_shm_info[epidx].tx.info->v1i.rx_status |=
+				FJES_RX_STOP_REQ_REQUEST;
+	}
+}
+
+int fjes_hw_wait_epstop(struct fjes_hw *hw)
+{
+	enum ep_partner_status status;
+	union ep_buffer_info *info;
+	int wait_time = 0;
+	int epidx;
+
+	while (hw->hw_info.buffer_unshare_reserve_bit &&
+	       (wait_time < FJES_COMMAND_EPSTOP_WAIT_TIMEOUT * 1000)) {
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+			if (epidx == hw->my_epid)
+				continue;
+			status = fjes_hw_epid_is_shared(hw->hw_info.share,
+							epidx);
+			info = hw->ep_shm_info[epidx].rx.info;
+			if ((!status ||
+			     (info->v1i.rx_status &
+			      FJES_RX_STOP_REQ_DONE)) &&
+			    test_bit(epidx,
+				     &hw->hw_info.buffer_unshare_reserve_bit)) {
+				clear_bit(epidx,
+					  &hw->hw_info.buffer_unshare_reserve_bit);
+			}
+		}
+
+		msleep(100);
+		wait_time += 100;
+	}
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+		if (test_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit))
+			clear_bit(epidx,
+				  &hw->hw_info.buffer_unshare_reserve_bit);
+	}
+
+	return (wait_time < FJES_COMMAND_EPSTOP_WAIT_TIMEOUT * 1000)
+			? 0 : -EBUSY;
+}
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index 2e750e9..9b8df55 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -36,6 +36,7 @@ struct fjes_hw;
 #define FJES_DEVICE_RESET_TIMEOUT  ((17 + 1) * 3) /* sec */
 #define FJES_COMMAND_REQ_TIMEOUT  (5 + 1) /* sec */
 #define FJES_COMMAND_REQ_BUFF_TIMEOUT	(8 * 3) /* sec */
+#define FJES_COMMAND_EPSTOP_WAIT_TIMEOUT	(1) /* sec */
 
 #define FJES_CMD_REQ_ERR_INFO_PARAM  (0x0001)
 #define FJES_CMD_REQ_ERR_INFO_STATUS (0x0002)
@@ -43,6 +44,17 @@ struct fjes_hw;
 #define FJES_CMD_REQ_RES_CODE_NORMAL (0)
 #define FJES_CMD_REQ_RES_CODE_BUSY   (1)
 
+#define FJES_ZONING_STATUS_DISABLE	(0x00)
+#define FJES_ZONING_STATUS_ENABLE	(0x01)
+#define FJES_ZONING_STATUS_INVALID	(0xFF)
+
+#define FJES_ZONING_ZONE_TYPE_NONE (0xFF)
+
+#define FJES_RX_STOP_REQ_NONE		(0x0)
+#define FJES_RX_STOP_REQ_DONE		(0x1)
+#define FJES_RX_STOP_REQ_REQUEST	(0x2)
+#define FJES_RX_POLL_WORK		(0x4)
+
 #define EP_BUFFER_SIZE \
 	(((sizeof(union ep_buffer_info) + (128 * (64 * 1024))) \
 		/ EP_BUFFER_INFO_SIZE) * EP_BUFFER_INFO_SIZE)
@@ -77,6 +89,15 @@ struct esmem_frame {
 	u8 frame_data[];
 };
 
+/* EP partner status */
+enum ep_partner_status {
+	EP_PARTNER_UNSHARE,
+	EP_PARTNER_SHARED,
+	EP_PARTNER_WAITING,
+	EP_PARTNER_COMPLETE,
+	EP_PARTNER_STATUS_MAX,
+};
+
 /* shared status region */
 struct fjes_device_shared_info {
 	int epnum;
@@ -278,6 +299,15 @@ int fjes_hw_unregister_buff_addr(struct fjes_hw *, int);
 void fjes_hw_init_command_registers(struct fjes_hw *,
 				    struct fjes_device_command_param *);
 void fjes_hw_setup_epbuf(struct epbuf_handler *, u8 *, u32);
+int fjes_hw_raise_interrupt(struct fjes_hw *, int, enum REG_ICTL_MASK);
 void fjes_hw_set_irqmask(struct fjes_hw *, enum REG_ICTL_MASK, bool);
+u32 fjes_hw_capture_interrupt_status(struct fjes_hw *);
+void fjes_hw_raise_epstop(struct fjes_hw *);
+int fjes_hw_wait_epstop(struct fjes_hw *);
+enum ep_partner_status
+	fjes_hw_get_partner_ep_status(struct fjes_hw *, int);
+
+bool fjes_hw_epid_is_same_zone(struct fjes_hw *, int);
+int fjes_hw_epid_is_shared(struct fjes_device_shared_info *, int);
 
 #endif /* FJES_HW_H_ */
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 45a8b9c..bd50cbd 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -24,6 +24,7 @@
 #include <linux/nls.h>
 #include <linux/platform_device.h>
 #include <linux/netdevice.h>
+#include <linux/interrupt.h>
 
 #include "fjes.h"
 
@@ -43,6 +44,15 @@ MODULE_DESCRIPTION("FUJITSU Extended Socket Network Device Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+static int fjes_request_irq(struct fjes_adapter *);
+static void fjes_free_irq(struct fjes_adapter *);
+
+static int fjes_open(struct net_device *);
+static int fjes_close(struct net_device *);
+static int fjes_setup_resources(struct fjes_adapter *);
+static void fjes_free_resources(struct fjes_adapter *);
+static irqreturn_t fjes_intr(int, void*);
+
 static int fjes_acpi_add(struct acpi_device *);
 static int fjes_acpi_remove(struct acpi_device *);
 static acpi_status fjes_get_acpi_resource(struct acpi_resource *, void*);
@@ -170,9 +180,245 @@ fjes_get_acpi_resource(struct acpi_resource *acpi_res, void *data)
 	return AE_OK;
 }
 
+static int fjes_request_irq(struct fjes_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	int result = -1;
+
+	if (!adapter->irq_registered) {
+		result = request_irq(adapter->hw.hw_res.irq, fjes_intr,
+				     IRQF_SHARED, netdev->name, adapter);
+		if (result)
+			adapter->irq_registered = false;
+		else
+			adapter->irq_registered = true;
+	}
+
+	return result;
+}
+
+static void fjes_free_irq(struct fjes_adapter *adapter)
+{
+	struct fjes_hw *hw = &adapter->hw;
+
+	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_ALL, true);
+
+	if (adapter->irq_registered) {
+		free_irq(adapter->hw.hw_res.irq, adapter);
+		adapter->irq_registered = false;
+	}
+}
+
 static const struct net_device_ops fjes_netdev_ops = {
+	.ndo_open		= fjes_open,
+	.ndo_stop		= fjes_close,
 };
 
+/* fjes_open - Called when a network interface is made active */
+static int fjes_open(struct net_device *netdev)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+	int result;
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
+
+err_setup_res:
+	fjes_free_resources(adapter);
+	return result;
+}
+
+/* fjes_close - Disables a network interface */
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
+	fjes_hw_wait_epstop(hw);
+
+	fjes_free_resources(adapter);
+
+	return 0;
+}
+
+static int fjes_setup_resources(struct fjes_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct ep_share_mem_info *buf_pair;
+	struct fjes_hw *hw = &adapter->hw;
+	int result;
+	int epidx;
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
+	for (epidx = 0; epidx < (hw->max_epid); epidx++) {
+		if ((epidx != hw->my_epid) &&
+		    (hw->ep_shm_info[epidx].es_status ==
+		     FJES_ZONING_STATUS_ENABLE)) {
+			fjes_hw_raise_interrupt(hw, epidx,
+						REG_ICTL_MASK_INFO_UPDATE);
+		}
+	}
+
+	msleep(FJES_OPEN_ZONE_UPDATE_WAIT * hw->max_epid);
+
+	for (epidx = 0; epidx < (hw->max_epid); epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		buf_pair = &hw->ep_shm_info[epidx];
+
+		fjes_hw_setup_epbuf(&buf_pair->tx, netdev->dev_addr,
+				    netdev->mtu);
+
+		if (fjes_hw_epid_is_same_zone(hw, epidx)) {
+			mutex_lock(&hw->hw_info.lock);
+			result =
+			fjes_hw_register_buff_addr(hw, epidx, buf_pair);
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
+	struct net_device *netdev = adapter->netdev;
+	struct fjes_device_command_param param;
+	struct ep_share_mem_info *buf_pair;
+	struct fjes_hw *hw = &adapter->hw;
+	bool reset_flag = false;
+	int result;
+	int epidx;
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
+		fjes_hw_setup_epbuf(&buf_pair->tx,
+				    netdev->dev_addr, netdev->mtu);
+
+		clear_bit(epidx, &hw->txrx_stop_req_bit);
+	}
+
+	if (reset_flag || adapter->force_reset) {
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
+	if (icr & REG_IS_MASK_IS_ASSERT)
+		ret = IRQ_HANDLED;
+	else
+		ret = IRQ_NONE;
+
+	return ret;
+}
+
 /* fjes_probe - Device Initialization Routine */
 static int fjes_probe(struct platform_device *plat_dev)
 {
diff --git a/drivers/net/fjes/fjes_regs.h b/drivers/net/fjes/fjes_regs.h
index cc975a0..029c924 100644
--- a/drivers/net/fjes/fjes_regs.h
+++ b/drivers/net/fjes/fjes_regs.h
@@ -49,8 +49,11 @@
 #define XSCT_RESPBAH        0x004C  /* Response Buffer Address High */
 
 /* Interrupt Control registers */
+#define XSCT_IS             0x0080  /* Interrupt status */
 #define XSCT_IMS            0x0084  /* Interrupt mask set */
 #define XSCT_IMC            0x0088  /* Interrupt mask clear */
+#define XSCT_IG             0x008C  /* Interrupt generator */
+#define XSCT_ICTL           0x0090  /* Interrupt control */
 
 /* register structure */
 /* Information registers */
@@ -101,6 +104,15 @@ union REG_CS {
 	__le32 reg;
 };
 
+/* Interrupt Control registers */
+union REG_ICTL {
+	struct {
+		__le32 automak:1;
+		__le32 rsv0:31;
+	} bits;
+	__le32 reg;
+};
+
 enum REG_ICTL_MASK {
 	REG_ICTL_MASK_INFO_UPDATE     = 1 << 20,
 	REG_ICTL_MASK_DEV_STOP_REQ    = 1 << 19,
@@ -110,6 +122,11 @@ enum REG_ICTL_MASK {
 	REG_ICTL_MASK_ALL             = GENMASK(20, 16),
 };
 
+enum REG_IS_MASK {
+	REG_IS_MASK_IS_ASSERT	= 1 << 31,
+	REG_IS_MASK_EPID	= GENMASK(15, 0),
+};
+
 struct fjes_hw;
 
 u32 fjes_hw_rd32(struct fjes_hw *hw, u32 reg);
-- 
1.8.3.1

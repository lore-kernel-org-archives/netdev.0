From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 1/7] liquidio CN23XX: VF offload features
Date: Tue, 6 Dec 2016 13:06:01 -0800
Message-ID: <1481058367-3937-2-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1481058367-3937-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0053.outbound.protection.outlook.com ([104.47.34.53]:61952
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751995AbcLFVWX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 16:22:23 -0500
In-Reply-To: <1481058367-3937-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VF link initialization and offload features.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 562 +++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_device.c   |   3 +
 2 files changed, 565 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index e6321f3..81a578f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -22,7 +22,9 @@
 #include "octeon_iq.h"
 #include "response_manager.h"
 #include "octeon_device.h"
+#include "octeon_nic.h"
 #include "octeon_main.h"
+#include "octeon_network.h"
 #include "cn23xx_vf_device.h"
 
 MODULE_AUTHOR("Cavium Networks, <support@cavium.com>");
@@ -30,6 +32,33 @@
 MODULE_LICENSE("GPL");
 MODULE_VERSION(LIQUIDIO_VERSION);
 
+static int debug = -1;
+module_param(debug, int, 0644);
+MODULE_PARM_DESC(debug, "NETIF_MSG debug bits");
+
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
+
+#define   LIO_IFSTATE_REGISTERED           0x02
+#define   LIO_IFSTATE_RUNNING              0x04
+
+struct liquidio_if_cfg_context {
+	int octeon_id;
+
+	wait_queue_head_t wc;
+
+	int cond;
+};
+
+struct liquidio_if_cfg_resp {
+	u64 rh;
+	struct liquidio_if_cfg_info cfg_info;
+	u64 status;
+};
+
+#define OCTNIC_GSO_MAX_HEADER_SIZE 128
+#define OCTNIC_GSO_MAX_SIZE \
+		(CN23XX_DEFAULT_INPUT_JABBER - OCTNIC_GSO_MAX_HEADER_SIZE)
+
 struct octeon_device_priv {
 	/* Tasklet structures for this device. */
 	struct tasklet_struct droq_tasklet;
@@ -40,6 +69,7 @@ struct octeon_device_priv {
 liquidio_vf_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void liquidio_vf_remove(struct pci_dev *pdev);
 static int octeon_device_init(struct octeon_device *oct);
+static int liquidio_stop(struct net_device *netdev);
 
 static int lio_wait_for_oq_pkts(struct octeon_device *oct)
 {
@@ -113,6 +143,26 @@ static int wait_for_pending_requests(struct octeon_device *oct)
 	.remove		= liquidio_vf_remove,
 };
 
+/**
+ * \brief set interface state
+ * @param lio per-network private data
+ * @param state_flag flag state to set
+ */
+static inline void ifstate_set(struct lio *lio, int state_flag)
+{
+	atomic_set(&lio->ifstate, (atomic_read(&lio->ifstate) | state_flag));
+}
+
+/**
+ * \brief clear interface state
+ * @param lio per-network private data
+ * @param state_flag flag state to clear
+ */
+static inline void ifstate_reset(struct lio *lio, int state_flag)
+{
+	atomic_set(&lio->ifstate, (atomic_read(&lio->ifstate) & ~(state_flag)));
+}
+
 static
 int liquidio_schedule_msix_droq_pkt_handler(struct octeon_droq *droq, u64 ret)
 {
@@ -316,6 +366,7 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 		/* No more instructions will be forwarded. */
 		atomic_set(&oct->status, OCT_DEV_IN_RESET);
 
+		oct->app_mode = CVM_DRV_INVALID_APP;
 		dev_dbg(&oct->pci_dev->dev, "Device state is now %s\n",
 			lio_get_state_string(&oct->status));
 
@@ -420,6 +471,63 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 }
 
 /**
+ * \brief Destroy NIC device interface
+ * @param oct octeon device
+ * @param ifidx which interface to destroy
+ *
+ * Cleanup associated with each interface for an Octeon device  when NIC
+ * module is being unloaded or if initialization fails during load.
+ */
+static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
+{
+	struct net_device *netdev = oct->props[ifidx].netdev;
+	struct lio *lio;
+
+	if (!netdev) {
+		dev_err(&oct->pci_dev->dev, "%s No netdevice ptr for index %d\n",
+			__func__, ifidx);
+		return;
+	}
+
+	lio = GET_LIO(netdev);
+
+	dev_dbg(&oct->pci_dev->dev, "NIC device cleanup\n");
+
+	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING)
+		liquidio_stop(netdev);
+
+	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED)
+		unregister_netdev(netdev);
+
+	free_netdev(netdev);
+
+	oct->props[ifidx].gmxport = -1;
+
+	oct->props[ifidx].netdev = NULL;
+}
+
+/**
+ * \brief Stop complete NIC functionality
+ * @param oct octeon device
+ */
+static int liquidio_stop_nic_module(struct octeon_device *oct)
+{
+	int i;
+
+	dev_dbg(&oct->pci_dev->dev, "Stopping network interfaces\n");
+	if (!oct->ifcount) {
+		dev_err(&oct->pci_dev->dev, "Init for Octeon was not completed\n");
+		return 1;
+	}
+
+	for (i = 0; i < oct->ifcount; i++)
+		liquidio_destroy_nic_device(oct, i);
+
+	dev_dbg(&oct->pci_dev->dev, "Network interfaces stopped\n");
+	return 0;
+}
+
+/**
  * \brief Cleans up resources at unload time
  * @param pdev PCI device structure
  */
@@ -429,6 +537,9 @@ static void liquidio_vf_remove(struct pci_dev *pdev)
 
 	dev_dbg(&oct_dev->pci_dev->dev, "Stopping device\n");
 
+	if (oct_dev->app_mode == CVM_DRV_NIC_APP)
+		liquidio_stop_nic_module(oct_dev);
+
 	/* Reset the octeon device and cleanup all memory allocated for
 	 * the octeon device by driver.
 	 */
@@ -472,6 +583,452 @@ static int octeon_pci_os_setup(struct octeon_device *oct)
 }
 
 /**
+ * \brief Callback for getting interface configuration
+ * @param status status of request
+ * @param buf pointer to resp structure
+ */
+static void if_cfg_callback(struct octeon_device *oct,
+			    u32 status __attribute__((unused)), void *buf)
+{
+	struct octeon_soft_command *sc = (struct octeon_soft_command *)buf;
+	struct liquidio_if_cfg_context *ctx;
+	struct liquidio_if_cfg_resp *resp;
+
+	resp = (struct liquidio_if_cfg_resp *)sc->virtrptr;
+	ctx = (struct liquidio_if_cfg_context *)sc->ctxptr;
+
+	oct = lio_get_device(ctx->octeon_id);
+	if (resp->status)
+		dev_err(&oct->pci_dev->dev, "nic if cfg instruction failed. Status: %llx\n",
+			CVM_CAST64(resp->status));
+	WRITE_ONCE(ctx->cond, 1);
+
+	snprintf(oct->fw_info.liquidio_firmware_version, 32, "%s",
+		 resp->cfg_info.liquidio_firmware_version);
+
+	/* This barrier is required to be sure that the response has been
+	 * written fully before waking up the handler
+	 */
+	wmb();
+
+	wake_up_interruptible(&ctx->wc);
+}
+
+/**
+ * \brief Select queue based on hash
+ * @param dev Net device
+ * @param skb sk_buff structure
+ * @returns selected queue number
+ */
+static u16 select_q(struct net_device *dev, struct sk_buff *skb,
+		    void *accel_priv __attribute__((unused)),
+		    select_queue_fallback_t fallback __attribute__((unused)))
+{
+	struct lio *lio;
+	u32 qindex;
+
+	lio = GET_LIO(dev);
+
+	qindex = skb_tx_hash(dev, skb);
+
+	return (u16)(qindex % (lio->linfo.num_txpciq));
+}
+
+/**
+ * \brief Net device stop for LiquidIO
+ * @param netdev network device
+ */
+static int liquidio_stop(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	netif_info(lio, ifdown, lio->netdev, "Stopping interface!\n");
+	/* Inform that netif carrier is down */
+	lio->intf_open = 0;
+	lio->linfo.link.s.link_up = 0;
+
+	netif_carrier_off(netdev);
+	lio->link_changes++;
+
+	ifstate_reset(lio, LIO_IFSTATE_RUNNING);
+
+	dev_info(&oct->pci_dev->dev, "%s interface is stopped\n", netdev->name);
+
+	return 0;
+}
+
+/** Sending command to enable/disable RX checksum offload
+ * @param netdev                pointer to network device
+ * @param command               OCTNET_CMD_TNL_RX_CSUM_CTL
+ * @param rx_cmd_bit            OCTNET_CMD_RXCSUM_ENABLE/
+ *                              OCTNET_CMD_RXCSUM_DISABLE
+ * @returns                     SUCCESS or FAILURE
+ */
+static int liquidio_set_rxcsum_command(struct net_device *netdev, int command,
+				       u8 rx_cmd)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	int ret = 0;
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = command;
+	nctrl.ncmd.s.param1 = rx_cmd;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "DEVFLAGS RXCSUM change failed in core (ret:0x%x)\n",
+			ret);
+	}
+	return ret;
+}
+
+/** \brief Net device fix features
+ * @param netdev  pointer to network device
+ * @param request features requested
+ * @returns updated features list
+ */
+static netdev_features_t liquidio_fix_features(struct net_device *netdev,
+					       netdev_features_t request)
+{
+	struct lio *lio = netdev_priv(netdev);
+
+	if ((request & NETIF_F_RXCSUM) &&
+	    !(lio->dev_capability & NETIF_F_RXCSUM))
+		request &= ~NETIF_F_RXCSUM;
+
+	if ((request & NETIF_F_HW_CSUM) &&
+	    !(lio->dev_capability & NETIF_F_HW_CSUM))
+		request &= ~NETIF_F_HW_CSUM;
+
+	if ((request & NETIF_F_TSO) && !(lio->dev_capability & NETIF_F_TSO))
+		request &= ~NETIF_F_TSO;
+
+	if ((request & NETIF_F_TSO6) && !(lio->dev_capability & NETIF_F_TSO6))
+		request &= ~NETIF_F_TSO6;
+
+	if ((request & NETIF_F_LRO) && !(lio->dev_capability & NETIF_F_LRO))
+		request &= ~NETIF_F_LRO;
+
+	/* Disable LRO if RXCSUM is off */
+	if (!(request & NETIF_F_RXCSUM) && (netdev->features & NETIF_F_LRO) &&
+	    (lio->dev_capability & NETIF_F_LRO))
+		request &= ~NETIF_F_LRO;
+
+	return request;
+}
+
+/** \brief Net device set features
+ * @param netdev  pointer to network device
+ * @param features features to enable/disable
+ */
+static int liquidio_set_features(struct net_device *netdev,
+				 netdev_features_t features)
+{
+	struct lio *lio = netdev_priv(netdev);
+
+	if (!((netdev->features ^ features) & NETIF_F_LRO))
+		return 0;
+
+	if ((features & NETIF_F_LRO) && (lio->dev_capability & NETIF_F_LRO))
+		liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
+				     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
+	else if (!(features & NETIF_F_LRO) &&
+		 (lio->dev_capability & NETIF_F_LRO))
+		liquidio_set_feature(netdev, OCTNET_CMD_LRO_DISABLE,
+				     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
+	if (!(netdev->features & NETIF_F_RXCSUM) &&
+	    (lio->enc_dev_capability & NETIF_F_RXCSUM) &&
+	    (features & NETIF_F_RXCSUM))
+		liquidio_set_rxcsum_command(netdev, OCTNET_CMD_TNL_RX_CSUM_CTL,
+					    OCTNET_CMD_RXCSUM_ENABLE);
+	else if ((netdev->features & NETIF_F_RXCSUM) &&
+		 (lio->enc_dev_capability & NETIF_F_RXCSUM) &&
+		 !(features & NETIF_F_RXCSUM))
+		liquidio_set_rxcsum_command(netdev, OCTNET_CMD_TNL_RX_CSUM_CTL,
+					    OCTNET_CMD_RXCSUM_DISABLE);
+
+	return 0;
+}
+
+static const struct net_device_ops lionetdevops = {
+	.ndo_fix_features	= liquidio_fix_features,
+	.ndo_set_features	= liquidio_set_features,
+	.ndo_select_queue	= select_q,
+};
+
+/**
+ * \brief Setup network interfaces
+ * @param octeon_dev  octeon device
+ *
+ * Called during init time for each device. It assumes the NIC
+ * is already up and running.  The link information for each
+ * interface is passed in link_info.
+ */
+static int setup_nic_devices(struct octeon_device *octeon_dev)
+{
+	int retval, num_iqueues, num_oqueues;
+	struct liquidio_if_cfg_context *ctx;
+	u32 resp_size, ctx_size, data_size;
+	struct liquidio_if_cfg_resp *resp;
+	struct octeon_soft_command *sc;
+	union oct_nic_if_cfg if_cfg;
+	struct octdev_props *props;
+	struct net_device *netdev;
+	struct lio_version *vdata;
+	struct lio *lio = NULL;
+	u8 mac[ETH_ALEN], i, j;
+	u32 ifidx_or_pfnum;
+
+	ifidx_or_pfnum = octeon_dev->pf_num;
+
+	for (i = 0; i < octeon_dev->ifcount; i++) {
+		resp_size = sizeof(struct liquidio_if_cfg_resp);
+		ctx_size = sizeof(struct liquidio_if_cfg_context);
+		data_size = sizeof(struct lio_version);
+		sc = (struct octeon_soft_command *)
+			octeon_alloc_soft_command(octeon_dev, data_size,
+						  resp_size, ctx_size);
+		resp = (struct liquidio_if_cfg_resp *)sc->virtrptr;
+		ctx  = (struct liquidio_if_cfg_context *)sc->ctxptr;
+		vdata = (struct lio_version *)sc->virtdptr;
+
+		*((u64 *)vdata) = 0;
+		vdata->major = cpu_to_be16(LIQUIDIO_BASE_MAJOR_VERSION);
+		vdata->minor = cpu_to_be16(LIQUIDIO_BASE_MINOR_VERSION);
+		vdata->micro = cpu_to_be16(LIQUIDIO_BASE_MICRO_VERSION);
+
+		WRITE_ONCE(ctx->cond, 0);
+		ctx->octeon_id = lio_get_device_id(octeon_dev);
+		init_waitqueue_head(&ctx->wc);
+
+		if_cfg.u64 = 0;
+
+		if_cfg.s.num_iqueues = octeon_dev->sriov_info.rings_per_vf;
+		if_cfg.s.num_oqueues = octeon_dev->sriov_info.rings_per_vf;
+		if_cfg.s.base_queue = 0;
+
+		sc->iq_no = 0;
+
+		octeon_prepare_soft_command(octeon_dev, sc, OPCODE_NIC,
+					    OPCODE_NIC_IF_CFG, 0, if_cfg.u64,
+					    0);
+
+		sc->callback = if_cfg_callback;
+		sc->callback_arg = sc;
+		sc->wait_time = 5000;
+
+		retval = octeon_send_soft_command(octeon_dev, sc);
+		if (retval == IQ_SEND_FAILED) {
+			dev_err(&octeon_dev->pci_dev->dev,
+				"iq/oq config failed status: %x\n", retval);
+			/* Soft instr is freed by driver in case of failure. */
+			goto setup_nic_dev_fail;
+		}
+
+		/* Sleep on a wait queue till the cond flag indicates that the
+		 * response arrived or timed-out.
+		 */
+		if (sleep_cond(&ctx->wc, &ctx->cond) == -EINTR) {
+			dev_err(&octeon_dev->pci_dev->dev, "Wait interrupted\n");
+			goto setup_nic_wait_intr;
+		}
+
+		retval = resp->status;
+		if (retval) {
+			dev_err(&octeon_dev->pci_dev->dev, "iq/oq config failed\n");
+			goto setup_nic_dev_fail;
+		}
+
+		octeon_swap_8B_data((u64 *)(&resp->cfg_info),
+				    (sizeof(struct liquidio_if_cfg_info)) >> 3);
+
+		num_iqueues = hweight64(resp->cfg_info.iqmask);
+		num_oqueues = hweight64(resp->cfg_info.oqmask);
+
+		if (!(num_iqueues) || !(num_oqueues)) {
+			dev_err(&octeon_dev->pci_dev->dev,
+				"Got bad iqueues (%016llx) or oqueues (%016llx) from firmware.\n",
+				resp->cfg_info.iqmask, resp->cfg_info.oqmask);
+			goto setup_nic_dev_fail;
+		}
+		dev_dbg(&octeon_dev->pci_dev->dev,
+			"interface %d, iqmask %016llx, oqmask %016llx, numiqueues %d, numoqueues %d\n",
+			i, resp->cfg_info.iqmask, resp->cfg_info.oqmask,
+			num_iqueues, num_oqueues);
+
+		netdev = alloc_etherdev_mq(LIO_SIZE, num_iqueues);
+
+		if (!netdev) {
+			dev_err(&octeon_dev->pci_dev->dev, "Device allocation failed\n");
+			goto setup_nic_dev_fail;
+		}
+
+		SET_NETDEV_DEV(netdev, &octeon_dev->pci_dev->dev);
+
+		/* Associate the routines that will handle different
+		 * netdev tasks.
+		 */
+		netdev->netdev_ops = &lionetdevops;
+
+		lio = GET_LIO(netdev);
+
+		memset(lio, 0, sizeof(struct lio));
+
+		lio->ifidx = ifidx_or_pfnum;
+
+		props = &octeon_dev->props[i];
+		props->gmxport = resp->cfg_info.linfo.gmxport;
+		props->netdev = netdev;
+
+		lio->linfo.num_rxpciq = num_oqueues;
+		lio->linfo.num_txpciq = num_iqueues;
+
+		for (j = 0; j < num_oqueues; j++) {
+			lio->linfo.rxpciq[j].u64 =
+			    resp->cfg_info.linfo.rxpciq[j].u64;
+		}
+		for (j = 0; j < num_iqueues; j++) {
+			lio->linfo.txpciq[j].u64 =
+			    resp->cfg_info.linfo.txpciq[j].u64;
+		}
+
+		lio->linfo.hw_addr = resp->cfg_info.linfo.hw_addr;
+		lio->linfo.gmxport = resp->cfg_info.linfo.gmxport;
+		lio->linfo.link.u64 = resp->cfg_info.linfo.link.u64;
+		lio->linfo.macaddr_is_admin_asgnd =
+			resp->cfg_info.linfo.macaddr_is_admin_asgnd;
+
+		lio->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
+
+		lio->dev_capability = NETIF_F_HIGHDMA
+				      | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
+				      | NETIF_F_SG | NETIF_F_RXCSUM
+				      | NETIF_F_TSO | NETIF_F_TSO6
+				      | NETIF_F_GRO
+				      | NETIF_F_LRO;
+		netif_set_gso_max_size(netdev, OCTNIC_GSO_MAX_SIZE);
+
+		netdev->features = (lio->dev_capability & ~NETIF_F_LRO);
+
+		netdev->hw_features = lio->dev_capability;
+
+		/* Point to the  properties for octeon device to which this
+		 * interface belongs.
+		 */
+		lio->oct_dev = octeon_dev;
+		lio->octprops = props;
+		lio->netdev = netdev;
+
+		dev_dbg(&octeon_dev->pci_dev->dev,
+			"if%d gmx: %d hw_addr: 0x%llx\n", i,
+			lio->linfo.gmxport, CVM_CAST64(lio->linfo.hw_addr));
+
+		/* 64-bit swap required on LE machines */
+		octeon_swap_8B_data(&lio->linfo.hw_addr, 1);
+		for (j = 0; j < ETH_ALEN; j++)
+			mac[j] = *((u8 *)(((u8 *)&lio->linfo.hw_addr) + 2 + j));
+
+		/* Copy MAC Address to OS network device structure */
+		ether_addr_copy(netdev->dev_addr, mac);
+
+		if (netdev->features & NETIF_F_LRO)
+			liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
+					     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
+
+		if ((debug != -1) && (debug & NETIF_MSG_HW))
+			liquidio_set_feature(netdev, OCTNET_CMD_VERBOSE_ENABLE,
+					     0);
+
+		/* Register the network device with the OS */
+		if (register_netdev(netdev)) {
+			dev_err(&octeon_dev->pci_dev->dev, "Device registration failed\n");
+			goto setup_nic_dev_fail;
+		}
+
+		dev_dbg(&octeon_dev->pci_dev->dev,
+			"Setup NIC ifidx:%d mac:%02x%02x%02x%02x%02x%02x\n",
+			i, mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
+		netif_carrier_off(netdev);
+		lio->link_changes++;
+
+		ifstate_set(lio, LIO_IFSTATE_REGISTERED);
+
+		/* Sending command to firmware to enable Rx checksum offload
+		 * by default at the time of setup of Liquidio driver for
+		 * this device
+		 */
+		liquidio_set_rxcsum_command(netdev, OCTNET_CMD_TNL_RX_CSUM_CTL,
+					    OCTNET_CMD_RXCSUM_ENABLE);
+		liquidio_set_feature(netdev, OCTNET_CMD_TNL_TX_CSUM_CTL,
+				     OCTNET_CMD_TXCSUM_ENABLE);
+
+		dev_dbg(&octeon_dev->pci_dev->dev,
+			"NIC ifidx:%d Setup successful\n", i);
+
+		octeon_free_soft_command(octeon_dev, sc);
+	}
+
+	return 0;
+
+setup_nic_dev_fail:
+
+	octeon_free_soft_command(octeon_dev, sc);
+
+setup_nic_wait_intr:
+
+	while (i--) {
+		dev_err(&octeon_dev->pci_dev->dev,
+			"NIC ifidx:%d Setup failed\n", i);
+		liquidio_destroy_nic_device(octeon_dev, i);
+	}
+	return -ENODEV;
+}
+
+/**
+ * \brief initialize the NIC
+ * @param oct octeon device
+ *
+ * This initialization routine is called once the Octeon device application is
+ * up and running
+ */
+static int liquidio_init_nic_module(struct octeon_device *oct)
+{
+	int num_nic_ports = 1;
+	int i, retval = 0;
+
+	dev_dbg(&oct->pci_dev->dev, "Initializing network interfaces\n");
+
+	/* only default iq and oq were initialized
+	 * initialize the rest as well run port_config command for each port
+	 */
+	oct->ifcount = num_nic_ports;
+	memset(oct->props, 0,
+	       sizeof(struct octdev_props) * num_nic_ports);
+
+	for (i = 0; i < MAX_OCTEON_LINKS; i++)
+		oct->props[i].gmxport = -1;
+
+	retval = setup_nic_devices(oct);
+	if (retval) {
+		dev_err(&oct->pci_dev->dev, "Setup NIC devices failed\n");
+		goto octnet_init_failure;
+	}
+
+octnet_init_failure:
+
+	oct->ifcount = 0;
+
+	return retval;
+}
+
+/**
  * \brief Device initialization for each Octeon device that is probed
  * @param octeon_dev  octeon device
  */
@@ -498,6 +1055,8 @@ static int octeon_device_init(struct octeon_device *oct)
 
 	atomic_set(&oct->status, OCT_DEV_PCI_MAP_DONE);
 
+	oct->app_mode = CVM_DRV_NIC_APP;
+
 	/* Initialize the dispatch mechanism used to push packets arriving on
 	 * Octeon Output queues.
 	 */
@@ -594,6 +1153,9 @@ static int octeon_device_init(struct octeon_device *oct)
 
 	atomic_set(&oct->status, OCT_DEV_RUNNING);
 
+	if (liquidio_init_nic_module(oct))
+		return 1;
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 6d54032..583818e 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -1221,6 +1221,9 @@ struct octeon_config *octeon_get_conf(struct octeon_device *oct)
 	} else if (OCTEON_CN23XX_PF(oct)) {
 		default_oct_conf = (struct octeon_config *)
 			(CHIP_CONF(oct, cn23xx_pf));
+	} else if (OCTEON_CN23XX_VF(oct)) {
+		default_oct_conf = (struct octeon_config *)
+			(CHIP_CONF(oct, cn23xx_vf));
 	}
 	return default_oct_conf;
 }
-- 
1.8.3.1

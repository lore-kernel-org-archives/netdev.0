From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 02/12] netxen: enable ip addr hashing
Date: Sun, 26 Jul 2009 23:07:37 -0700
Message-ID: <1248674867-18821-3-git-send-email-dhananjay@netxen.com>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@netxen.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33559 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750908AbZG0GHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 02:07:47 -0400
In-Reply-To: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NX3031 hardware requires local IP addresses for packet
accumulation (LRO). IP address hashing is required to
distinguish a local TCP flow from others (forwarded or
guest).

This patch adds listener for IP and netdev events and
configures IP address in the firmware.

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    5 ++
 drivers/net/netxen/netxen_nic_hw.c   |   24 +++++++
 drivers/net/netxen/netxen_nic_init.c |   52 +++++++-------
 drivers/net/netxen/netxen_nic_main.c |  126 ++++++++++++++++++++++++++++++++++
 4 files changed, 182 insertions(+), 25 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index f86e050..6b9e759 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -380,6 +380,7 @@ struct rcv_desc {
 };
 
 /* opcode field in status_desc */
+#define NETXEN_NIC_SYN_OFFLOAD  0x03
 #define NETXEN_NIC_RXPKT_DESC  0x04
 #define NETXEN_OLD_RXPKT_DESC  0x3f
 #define NETXEN_NIC_RESPONSE_DESC 0x05
@@ -1078,6 +1079,9 @@ typedef struct {
 
 #define NX_MAC_EVENT		0x1
 
+#define NX_IP_UP		2
+#define NX_IP_DOWN		3
+
 /*
  * Driver --> Firmware
  */
@@ -1443,6 +1447,7 @@ void netxen_p3_free_mac_list(struct netxen_adapter *adapter);
 int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32);
 int netxen_config_intr_coalesce(struct netxen_adapter *adapter);
 int netxen_config_rss(struct netxen_adapter *adapter, int enable);
+int netxen_config_ipaddr(struct netxen_adapter *adapter, u32 ip, int cmd);
 int netxen_linkevent_request(struct netxen_adapter *adapter, int enable);
 void netxen_advert_link_change(struct netxen_adapter *adapter, int linkup);
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 3c614c3..088611b 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -706,6 +706,30 @@ int netxen_config_rss(struct netxen_adapter *adapter, int enable)
 	return rv;
 }
 
+int netxen_config_ipaddr(struct netxen_adapter *adapter, u32 ip, int cmd)
+{
+	nx_nic_req_t req;
+	u64 word;
+	int rv;
+
+	memset(&req, 0, sizeof(nx_nic_req_t));
+	req.qhdr = cpu_to_le64(NX_HOST_REQUEST << 23);
+
+	word = NX_NIC_H2C_OPCODE_CONFIG_IPADDR | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
+	req.words[0] = cpu_to_le64(cmd);
+	req.words[1] = cpu_to_le64(ip);
+
+	rv = netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0) {
+		printk(KERN_ERR "%s: could not notify %s IP 0x%x reuqest\n",
+				adapter->netdev->name,
+				(cmd == NX_IP_UP) ? "Add" : "Remove", ip);
+	}
+	return rv;
+}
+
 int netxen_linkevent_request(struct netxen_adapter *adapter, int enable)
 {
 	nx_nic_req_t req;
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 847f78b..5d7a2c4 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -880,22 +880,10 @@ netxen_validate_firmware(struct netxen_adapter *adapter, const char *fwname)
 	return 0;
 }
 
-void netxen_request_firmware(struct netxen_adapter *adapter)
+static int
+netxen_p3_has_mn(struct netxen_adapter *adapter)
 {
 	u32 capability, flashed_ver;
-	u8 fw_type;
-	struct pci_dev *pdev = adapter->pdev;
-	int rc = 0;
-
-	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
-		fw_type = NX_P2_MN_ROMIMAGE;
-		goto request_fw;
-	} else {
-		fw_type = NX_P3_CT_ROMIMAGE;
-		goto request_fw;
-	}
-
-request_mn:
 	capability = 0;
 
 	netxen_rom_fast_read(adapter,
@@ -903,23 +891,35 @@ request_mn:
 	flashed_ver = NETXEN_DECODE_VERSION(flashed_ver);
 
 	if (flashed_ver >= NETXEN_VERSION_CODE(4, 0, 220)) {
+
 		capability = NXRD32(adapter, NX_PEG_TUNE_CAPABILITY);
-		if (capability & NX_PEG_TUNE_MN_PRESENT) {
-			fw_type = NX_P3_MN_ROMIMAGE;
-			goto request_fw;
-		}
+		if (capability & NX_PEG_TUNE_MN_PRESENT)
+			return 1;
+	}
+	return 0;
+}
+
+void netxen_request_firmware(struct netxen_adapter *adapter)
+{
+	u8 fw_type;
+	struct pci_dev *pdev = adapter->pdev;
+	int rc = 0;
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+		fw_type = NX_P2_MN_ROMIMAGE;
+		goto request_fw;
 	}
 
-	fw_type = NX_FLASH_ROMIMAGE;
-	adapter->fw = NULL;
-	goto done;
+	fw_type = netxen_p3_has_mn(adapter) ?
+		NX_P3_MN_ROMIMAGE : NX_P3_CT_ROMIMAGE;
 
 request_fw:
 	rc = request_firmware(&adapter->fw, fw_name[fw_type], &pdev->dev);
 	if (rc != 0) {
-		if (fw_type == NX_P3_CT_ROMIMAGE) {
+		if (fw_type == NX_P3_MN_ROMIMAGE) {
 			msleep(1);
-			goto request_mn;
+			fw_type = NX_P3_CT_ROMIMAGE;
+			goto request_fw;
 		}
 
 		fw_type = NX_FLASH_ROMIMAGE;
@@ -931,9 +931,10 @@ request_fw:
 	if (rc != 0) {
 		release_firmware(adapter->fw);
 
-		if (fw_type == NX_P3_CT_ROMIMAGE) {
+		if (fw_type == NX_P3_MN_ROMIMAGE) {
 			msleep(1);
-			goto request_mn;
+			fw_type = NX_P3_CT_ROMIMAGE;
+			goto request_fw;
 		}
 
 		fw_type = NX_FLASH_ROMIMAGE;
@@ -1292,6 +1293,7 @@ netxen_process_rcv_ring(struct nx_host_sds_ring *sds_ring, int max)
 		switch (opcode) {
 		case NETXEN_NIC_RXPKT_DESC:
 		case NETXEN_OLD_RXPKT_DESC:
+		case NETXEN_NIC_SYN_OFFLOAD:
 			break;
 		case NETXEN_NIC_RESPONSE_DESC:
 			netxen_handle_fw_message(desc_cnt, consumer, sds_ring);
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 4c7e4c2..b368326 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -39,6 +39,7 @@
 #include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <linux/ipv6.h>
+#include <linux/inetdevice.h>
 
 MODULE_DESCRIPTION("NetXen Multi port (1/10) Gigabit Network Driver");
 MODULE_LICENSE("GPL");
@@ -1780,6 +1781,125 @@ static void netxen_nic_poll_controller(struct net_device *netdev)
 }
 #endif
 
+#define is_netxen_netdev(dev) (dev->netdev_ops == &netxen_netdev_ops)
+
+static int
+netxen_destip_supported(struct netxen_adapter *adapter)
+{
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		return 0;
+
+	if (adapter->ahw.cut_through)
+		return 0;
+
+	return 1;
+}
+
+static int netxen_netdev_event(struct notifier_block *this,
+				 unsigned long event, void *ptr)
+{
+	struct netxen_adapter *adapter;
+	struct net_device *dev = (struct net_device *)ptr;
+	struct in_device *indev;
+
+recheck:
+	if (dev == NULL)
+		goto done;
+
+	if (dev->priv_flags & IFF_802_1Q_VLAN) {
+		dev = vlan_dev_real_dev(dev);
+		goto recheck;
+	}
+
+	if (!is_netxen_netdev(dev))
+		goto done;
+
+	adapter = netdev_priv(dev);
+
+	if (!adapter || !netxen_destip_supported(adapter))
+		goto done;
+
+	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+		goto done;
+
+	indev = in_dev_get(dev);
+	if (!indev)
+		goto done;
+
+	for_ifa(indev) {
+		switch (event) {
+		case NETDEV_UP:
+			netxen_config_ipaddr(adapter,
+					ifa->ifa_address, NX_IP_UP);
+			break;
+		case NETDEV_DOWN:
+			netxen_config_ipaddr(adapter,
+					ifa->ifa_address, NX_IP_DOWN);
+			break;
+		default:
+			break;
+		}
+	} endfor_ifa(indev);
+
+	in_dev_put(indev);
+done:
+	return NOTIFY_DONE;
+}
+
+static int
+netxen_inetaddr_event(struct notifier_block *this,
+		unsigned long event, void *ptr)
+{
+	struct netxen_adapter *adapter;
+	struct net_device *dev;
+
+	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
+
+	dev = ifa->ifa_dev ? ifa->ifa_dev->dev : NULL;
+
+recheck:
+	if (dev == NULL || !netif_running(dev))
+		goto done;
+
+	if (dev->priv_flags & IFF_802_1Q_VLAN) {
+		dev = vlan_dev_real_dev(dev);
+		goto recheck;
+	}
+
+	if (!is_netxen_netdev(dev))
+		goto done;
+
+	adapter = netdev_priv(dev);
+
+	if (!adapter || !netxen_destip_supported(adapter))
+		goto done;
+
+	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+		goto done;
+
+	switch (event) {
+	case NETDEV_UP:
+		netxen_config_ipaddr(adapter, ifa->ifa_address, NX_IP_UP);
+		break;
+	case NETDEV_DOWN:
+		netxen_config_ipaddr(adapter, ifa->ifa_address, NX_IP_DOWN);
+		break;
+	default:
+		break;
+	}
+
+done:
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block	netxen_netdev_cb = {
+	.notifier_call = netxen_netdev_event,
+};
+
+static struct notifier_block netxen_inetaddr_cb = {
+	.notifier_call = netxen_inetaddr_event,
+};
+
 static struct pci_driver netxen_driver = {
 	.name = netxen_nic_driver_name,
 	.id_table = netxen_pci_tbl,
@@ -1800,6 +1920,9 @@ static int __init netxen_init_module(void)
 	if ((netxen_workq = create_singlethread_workqueue("netxen")) == NULL)
 		return -ENOMEM;
 
+	register_netdevice_notifier(&netxen_netdev_cb);
+	register_inetaddr_notifier(&netxen_inetaddr_cb);
+
 	return pci_register_driver(&netxen_driver);
 }
 
@@ -1808,6 +1931,9 @@ module_init(netxen_init_module);
 static void __exit netxen_exit_module(void)
 {
 	pci_unregister_driver(&netxen_driver);
+
+	unregister_inetaddr_notifier(&netxen_inetaddr_cb);
+	unregister_netdevice_notifier(&netxen_netdev_cb);
 	destroy_workqueue(netxen_workq);
 }
 
-- 
1.6.0.2


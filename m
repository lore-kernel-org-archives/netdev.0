From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next] Fix Cavium Liquidio build related errors and warnings
Date: Fri, 12 Jun 2015 18:11:50 -0700
Message-ID: <1434157910-5324-1-git-send-email-rvatsavayi@caviumnetworks.com>
References: <201506111433.eR8aCZeq%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0092.outbound.protection.outlook.com ([207.46.100.92]:23247
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755072AbbFMBQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jun 2015 21:16:12 -0400
In-Reply-To: <201506111433.eR8aCZeq%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fixed following sparse warnings:
    lio_main.c:213:6: warning: symbol 'octeon_droq_bh' was not
    declared. Should it be static?
    lio_main.c:233:5: warning: symbol 'lio_wait_for_oq_pkts' was
    not declared. Should it be static?
    lio_main.c:3083:5: warning: symbol 'lio_nic_info' was not
    declared. Should it be static?
    lio_main.c:2618:16: warning: cast from restricted __be16
    octeon_device.c:466:6: warning: symbol 'oct_set_config_info'
    was not declared. Should it be static?
    octeon_device.c:573:25: warning: cast to restricted __be32
    octeon_device.c:582:29: warning: cast to restricted __be32
    octeon_device.c:584:39: warning: cast to restricted __be32
    octeon_device.c:594:13: warning: cast to restricted __be32
    octeon_device.c:596:25: warning: cast to restricted __be32
    octeon_device.c:613:25: warning: cast to restricted __be32
    octeon_device.c:614:29: warning: cast to restricted __be64
    octeon_device.c:615:29: warning: cast to restricted __be32
    octeon_device.c:619:37: warning: cast to restricted __be32
    octeon_device.c:623:33: warning: cast to restricted __be32
    cn66xx_device.c:540:6: warning: symbol
    'lio_cn6xxx_get_pcie_qlmport' was not declared. Should it be s
    octeon_mem_ops.c:181:16: warning: cast to restricted __be64
    octeon_mem_ops.c:190:16: warning: cast to restricted __be32
    octeon_mem_ops.c:196:17: warning: incorrect type in initializer
2) Fix build errors corresponding to vmalloc on linux-next 4.1.
3) Liquidio now supports 64 bit only, modified Kconfig accordingly.
4) Fix some code alignment issues based on kernel build warnings.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/Kconfig                    |  1 +
 drivers/net/ethernet/cavium/liquidio/cn66xx_device.c   |  2 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c        |  9 +++++----
 drivers/net/ethernet/cavium/liquidio/liquidio_image.h  | 14 +++++++-------
 drivers/net/ethernet/cavium/liquidio/octeon_device.c   |  8 +++++---
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c     |  1 +
 drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c  |  6 +++---
 drivers/net/ethernet/cavium/liquidio/request_manager.c |  4 +++-
 8 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index c7d8674..5e7a0e2 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -43,6 +43,7 @@ config	THUNDER_NIC_BGX
 
 config LIQUIDIO
 	tristate "Cavium LiquidIO support"
+	depends on 64BIT
 	select PTP_1588_CLOCK
 	select FW_LOADER
 	select LIBCRC32
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index d23f494..8ad7425 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -537,7 +537,7 @@ void lio_cn6xxx_disable_interrupt(void *chip)
 	mmiowb();
 }
 
-void lio_cn6xxx_get_pcie_qlmport(struct octeon_device *oct)
+static void lio_cn6xxx_get_pcie_qlmport(struct octeon_device *oct)
 {
 	/* CN63xx Pass2 and newer parts implements the SLI_MAC_NUMBER register
 	 * to determine the PCIE port #
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index c75f517..0660dee 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -26,6 +26,7 @@
 #include <linux/pci.h>
 #include <linux/pci_ids.h>
 #include <linux/ip.h>
+#include <net/ip.h>
 #include <linux/ipv6.h>
 #include <linux/net_tstamp.h>
 #include <linux/if_vlan.h>
@@ -210,7 +211,7 @@ static int liquidio_probe(struct pci_dev *pdev,
 static struct handshake handshake[MAX_OCTEON_DEVICES];
 static struct completion first_stage;
 
-void octeon_droq_bh(unsigned long pdev)
+static void octeon_droq_bh(unsigned long pdev)
 {
 	int q_no;
 	int reschedule = 0;
@@ -230,7 +231,7 @@ void octeon_droq_bh(unsigned long pdev)
 		tasklet_schedule(&oct_priv->droq_tasklet);
 }
 
-int lio_wait_for_oq_pkts(struct octeon_device *oct)
+static int lio_wait_for_oq_pkts(struct octeon_device *oct)
 {
 	struct octeon_device_priv *oct_priv =
 		(struct octeon_device_priv *)oct->priv;
@@ -2615,7 +2616,7 @@ static inline int is_ip_fragmented(struct sk_buff *skb)
 	 * with more to follow; the current offset could be 0 ).
 	 * -  ths offset field is non-zero.
 	 */
-	return htons(ip_hdr(skb)->frag_off) & 0x3fff;
+	return (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) ? 1 : 0;
 }
 
 static inline int is_ipv6(struct sk_buff *skb)
@@ -3080,7 +3081,7 @@ static int __init liquidio_init(void)
 	return 0;
 }
 
-int lio_nic_info(struct octeon_recv_info *recv_info, void *buf)
+static int lio_nic_info(struct octeon_recv_info *recv_info, void *buf)
 {
 	struct octeon_device *oct = (struct octeon_device *)buf;
 	struct octeon_recv_pkt *recv_pkt = recv_info->recv_pkt;
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_image.h b/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
index 13c680b..93819bd 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
@@ -35,9 +35,9 @@
 #define LIO_MAX_IMAGES 16
 #define LIO_NIC_MAGIC 0x434E4943     /* "CNIC" */
 struct octeon_firmware_desc {
-	u64 addr;
-	u32 len;
-	u32 crc32;         /* crc32 of image */
+	__be64 addr;
+	__be32 len;
+	__be32 crc32;         /* crc32 of image */
 };
 
 /* Following the header is a list of 64-bit aligned binary images,
@@ -45,13 +45,13 @@ struct octeon_firmware_desc {
  * Numeric fields are in network byte order.
  */
 struct octeon_firmware_file_header {
-	u32 magic;
+	__be32 magic;
 	char version[LIO_MAX_FIRMWARE_VERSION_LEN];
 	char bootcmd[LIO_MAX_BOOTCMD_LEN];
-	u32 num_images;
+	__be32 num_images;
 	struct octeon_firmware_desc desc[LIO_MAX_IMAGES];
-	u32 pad;
-	u32 crc32;         /* header checksum */
+	__be32 pad;
+	__be32 crc32;         /* header checksum */
 };
 
 #endif /* _LIQUIDIO_IMAGE_H_ */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 2ca9165..0d3106b 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -27,6 +27,7 @@
 #include <linux/crc32.h>
 #include <linux/kthread.h>
 #include <linux/netdevice.h>
+#include <linux/vmalloc.h>
 #include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
@@ -463,7 +464,7 @@ static u32 octeon_device_count;
 
 static struct octeon_core_setup core_setup[MAX_OCTEON_DEVICES];
 
-void oct_set_config_info(int oct_id, int conf_type)
+static void oct_set_config_info(int oct_id, int conf_type)
 {
 	if (conf_type < 0 || conf_type > (NUM_OCTEON_CONFS - 1))
 		conf_type = OCTEON_CONFIG_TYPE_DEFAULT;
@@ -570,7 +571,7 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 
 	h = (struct octeon_firmware_file_header *)data;
 
-	if (h->magic != be32_to_cpu(LIO_NIC_MAGIC)) {
+	if (be32_to_cpu(h->magic) != LIO_NIC_MAGIC) {
 		dev_err(&oct->pci_dev->dev, "Unrecognized firmware file.\n");
 		return -EINVAL;
 	}
@@ -1108,11 +1109,12 @@ int octeon_core_drv_init(struct octeon_recv_info *recv_info, void *buf)
 		(u32)recv_pkt->rh.r_core_drv_init.app_mode),
 		sizeof(app_name) - 1);
 	oct->app_mode = (u32)recv_pkt->rh.r_core_drv_init.app_mode;
-	if (recv_pkt->rh.r_core_drv_init.app_mode == CVM_DRV_NIC_APP)
+	if (recv_pkt->rh.r_core_drv_init.app_mode == CVM_DRV_NIC_APP) {
 		oct->fw_info.max_nic_ports =
 			(u32)recv_pkt->rh.r_core_drv_init.max_nic_ports;
 		oct->fw_info.num_gmx_ports =
 			(u32)recv_pkt->rh.r_core_drv_init.num_gmx_ports;
+	}
 
 	if (oct->fw_info.max_nic_ports < num_nic_ports) {
 		dev_err(&oct->pci_dev->dev,
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 60a186f..94b502a 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -25,6 +25,7 @@
 #include <linux/pci.h>
 #include <linux/kthread.h>
 #include <linux/netdevice.h>
+#include <linux/vmalloc.h>
 #include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
index 9c0fd61..5aecef8 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
@@ -174,7 +174,7 @@ octeon_pci_write_core_mem(struct octeon_device *oct,
 
 u64 octeon_read_device_mem64(struct octeon_device *oct, u64 coreaddr)
 {
-	u64 ret;
+	__be64 ret;
 
 	__octeon_pci_rw_core_mem(oct, coreaddr, (u8 *)&ret, 8, 1);
 
@@ -183,7 +183,7 @@ u64 octeon_read_device_mem64(struct octeon_device *oct, u64 coreaddr)
 
 u32 octeon_read_device_mem32(struct octeon_device *oct, u64 coreaddr)
 {
-	u32 ret;
+	__be32 ret;
 
 	__octeon_pci_rw_core_mem(oct, coreaddr, (u8 *)&ret, 4, 1);
 
@@ -193,7 +193,7 @@ u32 octeon_read_device_mem32(struct octeon_device *oct, u64 coreaddr)
 void octeon_write_device_mem32(struct octeon_device *oct, u64 coreaddr,
 			       u32 val)
 {
-	u32 t = cpu_to_be32(val);
+	__be32 t = cpu_to_be32(val);
 
 	__octeon_pci_rw_core_mem(oct, coreaddr, (u8 *)&t, 4, 0);
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index adb4284..356796b 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -26,6 +26,7 @@
 #include <linux/pci.h>
 #include <linux/kthread.h>
 #include <linux/netdevice.h>
+#include <linux/vmalloc.h>
 #include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
@@ -453,9 +454,10 @@ update_iq_indices(struct octeon_device *oct, struct octeon_instr_queue *iq)
 	if (iq->flush_index != iq->octeon_read_index)
 		inst_processed = lio_process_iq_request_list(oct, iq);
 
-	if (inst_processed)
+	if (inst_processed) {
 		atomic_sub(inst_processed, &iq->instr_pending);
 		iq->stats.instr_processed += inst_processed;
+	}
 }
 
 static void
-- 
1.8.4.2

From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 1/2] liquidio: Add support to pass meta information
 to firmware
Date: Mon, 17 Jul 2017 12:51:55 -0700
Message-ID: <20170717195155.GA1211@felix-thinkpad.cavium.com>
References: <20170717195046.GA1191@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0066.outbound.protection.outlook.com ([104.47.42.66]:59967
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751316AbdGQTtn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 15:49:43 -0400
Content-Disposition: inline
In-Reply-To: <20170717195046.GA1191@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: VSR Burru <veerasenareddy.burru@cavium.com>

The LiquidIO adapter has processor cores that can run Linux. This patch
adds the support for passing meta information to LiquidIO linux cores.

Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
Signed-off-by: Srinivasa Jampala <Srinivasa.Jampala@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 11 ++++++++-
 .../net/ethernet/cavium/liquidio/liquidio_common.h | 17 +++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_console.c  | 28 ++++++++++++++++++----
 3 files changed, 51 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 51583ae..1508b18 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3949,6 +3949,8 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 	u32 resp_size, ctx_size, data_size;
 	u32 ifidx_or_pfnum;
 	struct lio_version *vdata;
+	union oct_nic_vf_info vf_info;
+
 
 	/* This is to handle link status changes */
 	octeon_register_dispatch_fn(octeon_dev, OPCODE_NIC,
@@ -4017,9 +4019,16 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		sc->iq_no = 0;
 
+		/* Populate VF info for firmware */
+		vf_info.info = 0;
+
+		vf_info.s.bus_num = octeon_dev->pci_dev->bus->number;
+		vf_info.s.dev_fn = octeon_dev->pci_dev->devfn;
+		vf_info.s.max_vfs = octeon_dev->sriov_info.max_vfs;
+
 		octeon_prepare_soft_command(octeon_dev, sc, OPCODE_NIC,
 					    OPCODE_NIC_IF_CFG, 0,
-					    if_cfg.u64, 0);
+					    if_cfg.u64, vf_info.info);
 
 		sc->callback = if_cfg_callback;
 		sc->callback_arg = sc;
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 231dd7f..fc59eda 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -894,4 +894,21 @@ union oct_nic_if_cfg {
 	} s;
 };
 
+union oct_nic_vf_info {
+	u64 info;
+	struct {
+#ifdef __BIG_ENDIAN_BITFIELD
+		u64 max_vfs:32;
+		u64 bus_num:8;
+		u64 dev_fn:8;
+		u64 reserved:16;
+#else
+		u64 reserved:16;
+		u64 dev_fn:8;
+		u64 bus_num:8;
+		u64 max_vfs:32;
+#endif
+	} s;
+};
+
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index e08f760..a6b9551 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -724,15 +724,19 @@ static int octeon_console_read(struct octeon_device *oct, u32 console_num,
 }
 
 #define FBUF_SIZE	(4 * 1024 * 1024)
+#define MAX_DATE_SIZE    30
 
 int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 			     size_t size)
 {
-	int ret = 0;
+	struct octeon_firmware_file_header *h;
+	char date[MAX_DATE_SIZE];
+	struct timeval time;
 	u32 crc32_result;
+	struct tm tm_val;
 	u64 load_addr;
 	u32 image_len;
-	struct octeon_firmware_file_header *h;
+	int ret = 0;
 	u32 i, rem;
 
 	if (size < sizeof(struct octeon_firmware_file_header)) {
@@ -814,8 +818,24 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 	dev_info(&oct->pci_dev->dev, "Writing boot command: %s\n",
 		 h->bootcmd);
 
-	/* Invoke the bootcmd */
+	/*Get time of the day*/
+	do_gettimeofday(&time);
+	time_to_tm(time.tv_sec, (-sys_tz.tz_minuteswest) * 60,  &tm_val);
+	ret = snprintf(date, MAX_DATE_SIZE,
+		       " date=%04ld.%02d.%02d-%02d:%02d:%02d",
+		       tm_val.tm_year + 1900, tm_val.tm_mon + 1, tm_val.tm_mday,
+		       tm_val.tm_hour, tm_val.tm_min, tm_val.tm_sec);
+	if ((sizeof(h->bootcmd) - strnlen(h->bootcmd, sizeof(h->bootcmd))) <
+		ret) {
+		dev_err(&oct->pci_dev->dev, "Boot command buffer too small\n");
+		return -EINVAL;
+	}
+	strncat(h->bootcmd, date,
+		sizeof(h->bootcmd) - strnlen(h->bootcmd, sizeof(h->bootcmd)));
+
 	ret = octeon_console_send_cmd(oct, h->bootcmd, 50);
+	if (ret)
+		dev_info(&oct->pci_dev->dev, "Boot command send failed\n");
 
-	return 0;
+	return ret;
 }
-- 
2.9.0

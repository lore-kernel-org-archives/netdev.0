From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH V2 net-next] liquidio: pass date and time info to NIC firmware
Date: Wed, 18 Oct 2017 10:24:45 -0700
Message-ID: <20171018172445.GA14012@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0041.outbound.protection.outlook.com ([104.47.41.41]:13216
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751717AbdJRRYu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 13:24:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>

Pass date and time information to NIC firmware at the time of loading
firmware and periodically update the host time to NIC firmware.
This is to make NIC firmware use the same time reference as Host,
so that it is easy to correlate logs from firmware and host for
debugging.

Signed-off-by: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
Patch Change Log:
  V1 -> V2:
    Follow reviewer's suggestion of periodically updating firmware with
    date and time info.

 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 126 +++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/liquidio_common.h |   8 ++
 .../net/ethernet/cavium/liquidio/octeon_console.c  |  28 ++++-
 .../net/ethernet/cavium/liquidio/octeon_network.h  |   3 +
 4 files changed, 162 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 963803b..8ab5ed5 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -83,6 +83,11 @@ static int octeon_console_debug_enabled(u32 console)
 
 /* runtime link query interval */
 #define LIQUIDIO_LINK_QUERY_INTERVAL_MS         1000
+/* update localtime to octeon firmware every 60 seconds.
+ * make firmware to use same time reference, so that it will be easy to
+ * correlate firmware logged events/errors with host events, for debugging.
+ */
+#define LIO_SYNC_OCTEON_TIME_INTERVAL_MS 60000
 
 struct liquidio_if_cfg_context {
 	int octeon_id;
@@ -901,6 +906,121 @@ static inline void update_link_status(struct net_device *netdev,
 	}
 }
 
+/**
+ * lio_sync_octeon_time_cb - callback that is invoked when soft command
+ * sent by lio_sync_octeon_time() has completed successfully or failed
+ *
+ * @oct - octeon device structure
+ * @status - indicates success or failure
+ * @buf - pointer to the command that was sent to firmware
+ **/
+static void lio_sync_octeon_time_cb(struct octeon_device *oct,
+				    u32 status, void *buf)
+{
+	struct octeon_soft_command *sc = (struct octeon_soft_command *)buf;
+
+	if (status)
+		dev_err(&oct->pci_dev->dev,
+			"Failed to sync time to octeon; error=%d\n", status);
+
+	octeon_free_soft_command(oct, sc);
+}
+
+/**
+ * lio_sync_octeon_time - send latest localtime to octeon firmware so that
+ * firmware will correct it's time, in case there is a time skew
+ *
+ * @work: work scheduled to send time update to octeon firmware
+ **/
+static void lio_sync_octeon_time(struct work_struct *work)
+{
+	struct cavium_wk *wk = (struct cavium_wk *)work;
+	struct lio *lio = (struct lio *)wk->ctxptr;
+	struct octeon_device *oct = lio->oct_dev;
+	struct octeon_soft_command *sc;
+	struct timespec64 ts;
+	struct lio_time *lt;
+	int ret;
+
+	sc = octeon_alloc_soft_command(oct, sizeof(struct lio_time), 0, 0);
+	if (!sc) {
+		dev_err(&oct->pci_dev->dev,
+			"Failed to sync time to octeon: soft command allocation failed\n");
+		return;
+	}
+
+	lt = (struct lio_time *)sc->virtdptr;
+
+	/* Get time of the day */
+	getnstimeofday64(&ts);
+	lt->sec = ts.tv_sec;
+	lt->nsec = ts.tv_nsec;
+	octeon_swap_8B_data((u64 *)lt, (sizeof(struct lio_time)) / 8);
+
+	sc->iq_no = lio->linfo.txpciq[0].s.q_no;
+	octeon_prepare_soft_command(oct, sc, OPCODE_NIC,
+				    OPCODE_NIC_SYNC_OCTEON_TIME, 0, 0, 0);
+
+	sc->callback = lio_sync_octeon_time_cb;
+	sc->callback_arg = sc;
+	sc->wait_time = 1000;
+
+	ret = octeon_send_soft_command(oct, sc);
+	if (ret == IQ_SEND_FAILED) {
+		dev_err(&oct->pci_dev->dev,
+			"Failed to sync time to octeon: failed to send soft command\n");
+		octeon_free_soft_command(oct, sc);
+	}
+
+	queue_delayed_work(lio->sync_octeon_time_wq.wq,
+			   &lio->sync_octeon_time_wq.wk.work,
+			   msecs_to_jiffies(LIO_SYNC_OCTEON_TIME_INTERVAL_MS));
+}
+
+/**
+ * setup_sync_octeon_time_wq - Sets up the work to periodically update
+ * local time to octeon firmware
+ *
+ * @netdev - network device which should send time update to firmware
+ **/
+static inline int setup_sync_octeon_time_wq(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	lio->sync_octeon_time_wq.wq =
+		alloc_workqueue("update-octeon-time", WQ_MEM_RECLAIM, 0);
+	if (!lio->sync_octeon_time_wq.wq) {
+		dev_err(&oct->pci_dev->dev, "Unable to create wq to update octeon time\n");
+		return -1;
+	}
+	INIT_DELAYED_WORK(&lio->sync_octeon_time_wq.wk.work,
+			  lio_sync_octeon_time);
+	lio->sync_octeon_time_wq.wk.ctxptr = lio;
+	queue_delayed_work(lio->sync_octeon_time_wq.wq,
+			   &lio->sync_octeon_time_wq.wk.work,
+			   msecs_to_jiffies(LIO_SYNC_OCTEON_TIME_INTERVAL_MS));
+
+	return 0;
+}
+
+/**
+ * cleanup_sync_octeon_time_wq - stop scheduling and destroy the work created
+ * to periodically update local time to octeon firmware
+ *
+ * @netdev - network device which should send time update to firmware
+ **/
+static inline void cleanup_sync_octeon_time_wq(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct cavium_wq *time_wq = &lio->sync_octeon_time_wq;
+
+	if (time_wq->wq) {
+		cancel_delayed_work_sync(&time_wq->wk.work);
+		destroy_workqueue(time_wq->wq);
+	}
+}
+
 static struct octeon_device *get_other_octeon_device(struct octeon_device *oct)
 {
 	struct octeon_device *other_oct;
@@ -1455,6 +1575,7 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED)
 		unregister_netdev(netdev);
 
+	cleanup_sync_octeon_time_wq(netdev);
 	cleanup_link_status_change_wq(netdev);
 
 	cleanup_rx_oom_poll_fn(netdev);
@@ -3611,6 +3732,11 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		if (setup_link_status_change_wq(netdev))
 			goto setup_nic_dev_fail;
 
+		if ((octeon_dev->fw_info.app_cap_flags &
+		     LIQUIDIO_TIME_SYNC_CAP) &&
+		    setup_sync_octeon_time_wq(netdev))
+			goto setup_nic_dev_fail;
+
 		if (setup_rx_oom_poll_fn(netdev))
 			goto setup_nic_dev_fail;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 3788c8c..0f21d57 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -84,6 +84,7 @@ enum octeon_tag_type {
 #define OPCODE_NIC_IF_CFG              0x09
 #define OPCODE_NIC_VF_DRV_NOTICE       0x0A
 #define OPCODE_NIC_INTRMOD_PARAMS      0x0B
+#define OPCODE_NIC_SYNC_OCTEON_TIME    0x14
 #define VF_DRV_LOADED                  1
 #define VF_DRV_REMOVED                -1
 #define VF_DRV_MACADDR_CHANGED         2
@@ -108,6 +109,9 @@ enum octeon_tag_type {
 
 #define SCR2_BIT_FW_LOADED	    63
 
+/* App specific capabilities from firmware to pf driver */
+#define LIQUIDIO_TIME_SYNC_CAP 0x1
+
 static inline u32 incr_index(u32 index, u32 count, u32 max)
 {
 	if ((index + count) >= max)
@@ -901,4 +905,8 @@ union oct_nic_if_cfg {
 	} s;
 };
 
+struct lio_time {
+	s64 sec;   /* seconds */
+	s64 nsec;  /* nanoseconds */
+};
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index ec3dd69..eda799b 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -803,15 +803,19 @@ static int octeon_console_read(struct octeon_device *oct, u32 console_num,
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
@@ -890,11 +894,29 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 			load_addr += size;
 		}
 	}
+
+	/* Get time of the day */
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
 	dev_info(&oct->pci_dev->dev, "Writing boot command: %s\n",
 		 h->bootcmd);
 
 	/* Invoke the bootcmd */
 	ret = octeon_console_send_cmd(oct, h->bootcmd, 50);
+	if (ret)
+		dev_info(&oct->pci_dev->dev, "Boot command send failed\n");
 
-	return 0;
+	return ret;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 9e36319..433f361 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -136,6 +136,9 @@ struct lio {
 	/* work queue for  link status */
 	struct cavium_wq	link_status_wq;
 
+	/* work queue to regularly send local time to octeon firmware */
+	struct cavium_wq	sync_octeon_time_wq;
+
 	int netdev_uc_count;
 };
 

From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v3 03/22] fjes: Hardware cleanup routine
Date: Fri, 21 Aug 2015 17:29:19 +0900
Message-ID: <1440145778-15941-3-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440145680-15851-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds hardware cleanup routine to be
invoked at driver's .remove routine.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_hw.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_hw.h |  1 +
 2 files changed, 67 insertions(+)

diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index ae26638..757cece 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -56,6 +56,12 @@ static u8 *fjes_hw_iomap(struct fjes_hw *hw)
 	return base;
 }
 
+static void fjes_hw_iounmap(struct fjes_hw *hw)
+{
+	iounmap(hw->base);
+	release_mem_region(hw->hw_res.start, hw->hw_res.size);
+}
+
 int fjes_hw_reset(struct fjes_hw *hw)
 {
 	union REG_DCTL dctl;
@@ -109,6 +115,12 @@ static int fjes_hw_alloc_shared_status_region(struct fjes_hw *hw)
 	return 0;
 }
 
+static void fjes_hw_free_shared_status_region(struct fjes_hw *hw)
+{
+	kfree(hw->hw_info.share);
+	hw->hw_info.share = NULL;
+}
+
 static int fjes_hw_alloc_epbuf(struct epbuf_handler *epbh)
 {
 	void *mem;
@@ -126,6 +138,18 @@ static int fjes_hw_alloc_epbuf(struct epbuf_handler *epbh)
 	return 0;
 }
 
+static void fjes_hw_free_epbuf(struct epbuf_handler *epbh)
+{
+	if (epbh->buffer)
+		vfree(epbh->buffer);
+
+	epbh->buffer = NULL;
+	epbh->size = 0;
+
+	epbh->info = NULL;
+	epbh->ring = NULL;
+}
+
 void fjes_hw_setup_epbuf(struct epbuf_handler *epbh, u8 *mac_addr, u32 mtu)
 {
 	union ep_buffer_info *info = epbh->info;
@@ -258,6 +282,32 @@ static int fjes_hw_setup(struct fjes_hw *hw)
 	return 0;
 }
 
+static void fjes_hw_cleanup(struct fjes_hw *hw)
+{
+	int epidx;
+
+	if (!hw->ep_shm_info)
+		return;
+
+	fjes_hw_free_shared_status_region(hw);
+
+	kfree(hw->hw_info.req_buf);
+	hw->hw_info.req_buf = NULL;
+
+	kfree(hw->hw_info.res_buf);
+	hw->hw_info.res_buf = NULL;
+
+	for (epidx = 0; epidx < hw->max_epid ; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+		fjes_hw_free_epbuf(&hw->ep_shm_info[epidx].tx);
+		fjes_hw_free_epbuf(&hw->ep_shm_info[epidx].rx);
+	}
+
+	kfree(hw->ep_shm_info);
+	hw->ep_shm_info = NULL;
+}
+
 int fjes_hw_init(struct fjes_hw *hw)
 {
 	int ret;
@@ -285,6 +335,22 @@ int fjes_hw_init(struct fjes_hw *hw)
 	return ret;
 }
 
+void fjes_hw_exit(struct fjes_hw *hw)
+{
+	int ret;
+
+	if (hw->base) {
+		ret = fjes_hw_reset(hw);
+		if (ret)
+			pr_err("%s: reset error", __func__);
+
+		fjes_hw_iounmap(hw);
+		hw->base = NULL;
+	}
+
+	fjes_hw_cleanup(hw);
+}
+
 void fjes_hw_set_irqmask(struct fjes_hw *hw,
 			 enum REG_ICTL_MASK intr_mask, bool mask)
 {
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index 836ebe2..1b3e9ca 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -241,6 +241,7 @@ struct fjes_hw {
 };
 
 int fjes_hw_init(struct fjes_hw *);
+void fjes_hw_exit(struct fjes_hw *);
 int fjes_hw_reset(struct fjes_hw *);
 
 void fjes_hw_init_command_registers(struct fjes_hw *,
-- 
1.8.3.1


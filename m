From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 03/22] fjes: Hardware cleanup routine
Date: Thu, 18 Jun 2015 09:49:28 +0900
Message-ID: <1434588587-25655-3-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds hardware cleanup routine to be
invoked at driver's .remove routine.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes_hw.c | 66 +++++++++++++++++++++++++++++++++++++
 drivers/platform/x86/fjes/fjes_hw.h |  1 +
 2 files changed, 67 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes_hw.c b/drivers/platform/x86/fjes/fjes_hw.c
index 1731827..d1f090a 100644
--- a/drivers/platform/x86/fjes/fjes_hw.c
+++ b/drivers/platform/x86/fjes/fjes_hw.c
@@ -56,6 +56,11 @@ static u8 *fjes_hw_iomap(struct fjes_hw *hw)
 	return base;
 }
 
+static void fjes_hw_iounmap(struct fjes_hw *hw)
+{
+	iounmap(hw->base);
+	release_mem_region(hw->hw_res.start, hw->hw_res.size);
+}
 
 int fjes_hw_reset(struct fjes_hw *hw)
 {
@@ -113,6 +118,12 @@ static int fjes_hw_alloc_shared_status_region(struct fjes_hw *hw)
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
@@ -131,6 +142,18 @@ static int fjes_hw_alloc_epbuf(struct epbuf_handler *epbh)
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
 
@@ -267,6 +290,33 @@ static int fjes_hw_setup(struct fjes_hw *hw)
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
+
+}
+
 int fjes_hw_init(struct fjes_hw *hw)
 {
 	int ret;
@@ -294,6 +344,22 @@ int fjes_hw_init(struct fjes_hw *hw)
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
 void fjes_hw_set_irqmask(struct fjes_hw *hw, enum REG_ICTL_MASK intr_mask,
 		bool mask)
 {
diff --git a/drivers/platform/x86/fjes/fjes_hw.h b/drivers/platform/x86/fjes/fjes_hw.h
index 02f4ee9..0bb2d51 100644
--- a/drivers/platform/x86/fjes/fjes_hw.h
+++ b/drivers/platform/x86/fjes/fjes_hw.h
@@ -244,6 +244,7 @@ struct fjes_hw {
 
 
 int fjes_hw_init(struct fjes_hw *);
+void fjes_hw_exit(struct fjes_hw *);
 int fjes_hw_reset(struct fjes_hw *);
 
 void fjes_hw_init_command_registers(struct fjes_hw *,
-- 
1.8.3.1

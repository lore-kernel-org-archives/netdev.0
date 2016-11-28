From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 7/9] liquidio CN23XX: VF mailbox
Date: Mon, 28 Nov 2016 00:50:36 -0800
Message-ID: <1480323038-13702-8-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1480323038-13702-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-by2nam01on0085.outbound.protection.outlook.com ([104.47.34.85]:8992
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754536AbcK1IvT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 03:51:19 -0500
In-Reply-To: <1480323038-13702-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VF mailbox setup.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_vf_device.c    | 59 ++++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 10 ++++
 2 files changed, 69 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
index ad4e442..7dfec44 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
@@ -17,6 +17,7 @@
  ***********************************************************************/
 #include <linux/pci.h>
 #include <linux/netdevice.h>
+#include <linux/vmalloc.h>
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
@@ -24,6 +25,7 @@
 #include "octeon_device.h"
 #include "cn23xx_vf_device.h"
 #include "octeon_main.h"
+#include "octeon_mailbox.h"
 
 static int cn23xx_vf_reset_io_queues(struct octeon_device *oct, u32 num_queues)
 {
@@ -231,6 +233,61 @@ static void cn23xx_setup_vf_oq_regs(struct octeon_device *oct, u32 oq_no)
 	    (u8 *)oct->mmio[0].hw_addr + CN23XX_VF_SLI_OQ_PKTS_CREDIT(oq_no);
 }
 
+static void cn23xx_vf_mbox_thread(struct work_struct *work)
+{
+	struct cavium_wk *wk = (struct cavium_wk *)work;
+	struct octeon_mbox *mbox = (struct octeon_mbox *)wk->ctxptr;
+
+	octeon_mbox_process_message(mbox);
+}
+
+static int cn23xx_free_vf_mbox(struct octeon_device *oct)
+{
+	cancel_delayed_work_sync(&oct->mbox[0]->mbox_poll_wk.work);
+	vfree(oct->mbox[0]);
+	return 0;
+}
+
+static int cn23xx_setup_vf_mbox(struct octeon_device *oct)
+{
+	struct octeon_mbox *mbox = NULL;
+
+	mbox = vmalloc(sizeof(*mbox));
+	if (!mbox)
+		return 1;
+
+	memset(mbox, 0, sizeof(struct octeon_mbox));
+
+	spin_lock_init(&mbox->lock);
+
+	mbox->oct_dev = oct;
+
+	mbox->q_no = 0;
+
+	mbox->state = OCTEON_MBOX_STATE_IDLE;
+
+	/* VF mbox interrupt reg */
+	mbox->mbox_int_reg =
+	    (u8 *)oct->mmio[0].hw_addr + CN23XX_VF_SLI_PKT_MBOX_INT(0);
+	/* VF reads from SIG0 reg */
+	mbox->mbox_read_reg =
+	    (u8 *)oct->mmio[0].hw_addr + CN23XX_SLI_PKT_PF_VF_MBOX_SIG(0, 0);
+	/* VF writes into SIG1 reg */
+	mbox->mbox_write_reg =
+	    (u8 *)oct->mmio[0].hw_addr + CN23XX_SLI_PKT_PF_VF_MBOX_SIG(0, 1);
+
+	INIT_DELAYED_WORK(&mbox->mbox_poll_wk.work,
+			  cn23xx_vf_mbox_thread);
+
+	mbox->mbox_poll_wk.ctxptr = mbox;
+
+	oct->mbox[0] = mbox;
+
+	writeq(OCTEON_PFVFSIG, mbox->mbox_read_reg);
+
+	return 0;
+}
+
 static int cn23xx_enable_vf_io_queues(struct octeon_device *oct)
 {
 	u32 q_no;
@@ -338,6 +395,8 @@ int cn23xx_setup_octeon_vf_device(struct octeon_device *oct)
 
 	oct->fn_list.setup_iq_regs = cn23xx_setup_vf_iq_regs;
 	oct->fn_list.setup_oq_regs = cn23xx_setup_vf_oq_regs;
+	oct->fn_list.setup_mbox = cn23xx_setup_vf_mbox;
+	oct->fn_list.free_mbox = cn23xx_free_vf_mbox;
 	oct->fn_list.setup_device_regs = cn23xx_setup_vf_device_regs;
 
 	oct->fn_list.enable_io_queues = cn23xx_enable_vf_io_queues;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 162e47b..43a1e3f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -143,6 +143,10 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 	int i;
 
 	switch (atomic_read(&oct->status)) {
+	case OCT_DEV_MBOX_SETUP_DONE:
+		oct->fn_list.free_mbox(oct);
+
+		/* fallthrough */
 	case OCT_DEV_IN_RESET:
 	case OCT_DEV_DROQ_INIT_DONE:
 		mdelay(100);
@@ -316,6 +320,12 @@ static int octeon_device_init(struct octeon_device *oct)
 	}
 	atomic_set(&oct->status, OCT_DEV_DROQ_INIT_DONE);
 
+	if (oct->fn_list.setup_mbox(oct)) {
+		dev_err(&oct->pci_dev->dev, "Mailbox setup failed\n");
+		return 1;
+	}
+	atomic_set(&oct->status, OCT_DEV_MBOX_SETUP_DONE);
+
 	return 0;
 }
 
-- 
1.8.3.1

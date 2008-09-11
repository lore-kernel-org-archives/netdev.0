From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 6/8] [RFC] qlge: Add mgmt port xface file qlge_mpi.c
Date: Thu, 11 Sep 2008 12:06:18 -0700
Message-ID: <20080911190618.GA23939@susedev.qlogic.org>
References: <20080910205813.GA13266@susedev.qlogic.org> <12210803432864-git-send-email-ron.mercer@qlogic.com> <48C8D0C7.6060706@marian.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com
To: Franco Fichtner <franco@marian.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:28234 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbYIKTHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 15:07:13 -0400
Content-Disposition: inline
In-Reply-To: <48C8D0C7.6060706@marian.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2008 at 10:03:19AM +0200, Franco Fichtner wrote:
> Ron Mercer wrote:
> >Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> >---
> > drivers/net/qlge/qlge_mpi.c |  228 
> > +++++++++++++++++++++++++++++++++++++++++++
> > 1 files changed, 228 insertions(+), 0 deletions(-)
> > create mode 100644 drivers/net/qlge/qlge_mpi.c
> >
> >diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
> >new file mode 100644
> >index 0000000..f235fc5
> >--- /dev/null
> >+++ b/drivers/net/qlge/qlge_mpi.c
> >@@ -0,0 +1,228 @@
> >+#include "qlge.h"
> >+
> >+/*
> >+ * Returns zero on success.
> >+ */
> >+static int ql_wait_mbx_cmd_cmplt(struct ql_adapter *qdev)
> >+{
> >+	int count = 50;
> >+	u32 temp;
> >+
> >+	while (count) {
> >+		temp = ql_read32(qdev, STS);
> >+		if (temp & STS_PI)
> >+			return 0;
> >+		mdelay(5);
> 
> Do you really want to delay execution for 250ms in worst case (timeout)
> scenarios? A msleep() would be more graceful.
>

We do need to wait this long as the MPI firmware will be handling
mailbox commands for an FCOE function as well as this NIC function.
You're right about msleep() being a better choice and I will change it
for the next submission.

> >+		count--;
> >+	}
> >+	return -ETIMEDOUT;
> >+}
> >+
> >+static int ql_write_mbox_reg(struct ql_adapter *qdev, u32 reg, u32 data)
> >+{
> >+	int status = 0;
> >+	/* wait for reg to come ready */
> >+	status = ql_wait_addr_reg(qdev, PROC_ADDR, PROC_ADDR_RDY);
> >+	if (status)
> >+		goto exit;
> >+	/* write the data to the data reg */
> >+	ql_write32(qdev, PROC_DATA, data);
> >+	/* trigger the write */
> >+	ql_write32(qdev, PROC_ADDR, reg);
> >+	/* wait for reg to come ready */
> >+	status = ql_wait_addr_reg(qdev, PROC_ADDR, PROC_ADDR_RDY);
> >+	if (status)
> >+		goto exit;
> 
> These two lines above are redundant. You cold also avoid the goto with
> opening a new block after the first if. Or how about just...
> 

Right again.  I was waiting before and after the function.  You only
need to wait at one of them.  I will remove the trailing wait.

> static int ql_write_mbox_reg(struct ql_adapter *qdev, u32 reg, u32 data)
> {
> 	/* wait for reg to come ready */
> 	if (ql_wait_addr_reg(qdev_ PROC_ADDR, PROC_ADDR_RDY)) {
> 		/* write the data to the data reg */
> 		ql_write32(qdev, PROC_DATA, data);
> 		/* trigger the write */
> 		ql_write32(qdev, PROC_ADDR, reg);
> 	}
> 
> 	/* wait for reg to come ready */
> 	return ql_wait_addr_reg(qdev, PROC_ADDR, PROC_ADDR_RDY);
> }
> 
> ... omitting the need for the status variable altogether.

I'll still need status, but won't initialize it and will drop the
trailing wait.

> 
> >+exit:
> >+	return status;
> >+}
> >+
> >+static int ql_read_mbox_reg(struct ql_adapter *qdev, u32 reg, u32 *data)
> >+{
> >+	int status = 0;
> 
> Same here for the goto. And no need to initialize status with a constant
> which must be pulled from memory when there is no path using this
> default value anyway.

done...

> 
> >+	/* wait for reg to come ready */
> >+	status = ql_wait_addr_reg(qdev, PROC_ADDR, PROC_ADDR_RDY);
> >+	if (status)
> >+		goto exit;
> >+	/* set up for reg read */
> >+	ql_write32(qdev, PROC_ADDR, reg | PROC_ADDR_R);
> >+	/* wait for reg to come ready */
> >+	status = ql_wait_addr_reg(qdev, PROC_ADDR, PROC_ADDR_RDY);
> >+	if (status)
> >+		goto exit;
> >+	/* get the data */
> >+	*data = ql_read32(qdev, PROC_DATA);
> >+exit:
> >+	return status;
> >+}
> >+
> >+static int ql_exec_mb_cmd(struct ql_adapter *qdev, struct mbox_params 
> >*mbcp)
> >+{
> >+	int i, status;
> >+
> >+	/*
> >+	 * Make sure there's nothing pending.
> >+	 * This shouldn't happen.
> >+	 */
> >+	if (ql_read32(qdev, CSR) & CSR_HRI)
> >+		return -EBUSY;
> >+
> >+	status = ql_sem_spinlock(qdev, SEM_PROC_REG_MASK);
> >+	if (status)
> >+		return -EBUSY;
> >+	/*
> >+	 * Fill the outbound mailboxes.
> >+	 */
> >+	for (i = 0; i < mbcp->in_count; i++) {
> >+		status =
> >+		    ql_write_mbox_reg(qdev, qdev->mailbox_in + i,
> >+				      mbcp->mbox_in[i]);
> >+		if (status)
> >+			goto end;
> >+	}
> >+	/*
> >+	 * Wake up the MPI firmware.
> >+	 */
> >+	ql_write32(qdev, CSR, CSR_CMD_SET_H2R_INT);
> >+end:
> >+	ql_sem_unlock(qdev, SEM_PROC_REG_MASK);	/* does flush too */
> >+	return status;
> >+}
> >+
> >+int ql_get_mb_sts(struct ql_adapter *qdev, struct mbox_params *mbcp)
> >+{
> >+	int i, status = 0;
> 
> Again, default value never used.

Done...

> 
> >+
> >+	status = ql_sem_spinlock(qdev, SEM_PROC_REG_MASK);
> >+	if (status)
> >+		return -EBUSY;
> >+	for (i = 0; i < mbcp->out_count; i++) {
> >+		status =
> >+		    ql_read_mbox_reg(qdev, qdev->mailbox_out + i,
> >+				     &mbcp->mbox_out[i]);
> >+		if (status) {
> >+			QPRINTK(qdev, DRV, ERR, "Failed mailbox read.\n");
> >+			break;
> >+		}
> >+	}
> >+	ql_sem_unlock(qdev, SEM_PROC_REG_MASK);	/* does flush too */
> >+	return status;
> >+}
> >+
> >+static void ql_link_up(struct ql_adapter *qdev)
> >+{
> >+	struct mbox_params mbc;
> >+	struct mbox_params *mbcp = &mbc;
> >+	mbcp->out_count = 2;
> >+
> >+	if (ql_get_mb_sts(qdev, mbcp))
> >+		goto exit;
> >+
> >+	qdev->link_status = mbcp->mbox_out[1];
> >+	QPRINTK(qdev, DRV, ERR, "Link Up.\n");
> >+	QPRINTK(qdev, DRV, ERR, "Link Status = 0x%.08x.\n", 
> >mbcp->mbox_out[1]);
> >+	if (!netif_carrier_ok(qdev->ndev)) {
> >+		QPRINTK(qdev, LINK, INFO, "Link is Up.\n");
> >+		netif_carrier_on(qdev->ndev);
> >+		netif_wake_queue(qdev->ndev);
> >+	}
> >+exit:
> >+	/* Clear the MPI firmware status. */
> >+	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
> >+}
> >+
> >+static void ql_link_down(struct ql_adapter *qdev)
> >+{
> >+	struct mbox_params mbc;
> >+	struct mbox_params *mbcp = &mbc;
> >+	mbcp->out_count = 3;
> >+
> >+	if (ql_get_mb_sts(qdev, mbcp)) {
> >+		QPRINTK(qdev, DRV, ERR, "Firmware did not initialize!\n");
> >+		goto exit;
> >+	}
> >+
> >+	if (netif_carrier_ok(qdev->ndev)) {
> >+		QPRINTK(qdev, LINK, INFO, "Link is Down.\n");
> >+		netif_carrier_off(qdev->ndev);
> >+		netif_stop_queue(qdev->ndev);
> >+	}
> >+	QPRINTK(qdev, DRV, ERR, "Link Down.\n");
> >+	QPRINTK(qdev, DRV, ERR, "Link Status = 0x%.08x.\n", 
> >mbcp->mbox_out[1]);
> >+exit:
> >+	/* Clear the MPI firmware status. */
> >+	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
> >+}
> >+
> >+static void ql_init_fw_done(struct ql_adapter *qdev)
> >+{
> >+	struct mbox_params mbc;
> >+	struct mbox_params *mbcp = &mbc;
> >+	mbcp->out_count = 2;
> >+
> >+	if (ql_get_mb_sts(qdev, mbcp)) {
> >+		QPRINTK(qdev, DRV, ERR, "Firmware did not initialize!\n");
> >+		goto exit;
> >+	}
> >+	QPRINTK(qdev, DRV, ERR, "Firmware initialized!\n");
> >+	QPRINTK(qdev, DRV, ERR, "Firmware status = 0x%.08x.\n",
> >+		mbcp->mbox_out[0]);
> >+	QPRINTK(qdev, DRV, ERR, "Firmware Revision  = 0x%.08x.\n",
> >+		mbcp->mbox_out[1]);
> >+exit:
> >+	/* Clear the MPI firmware status. */
> >+	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
> >+}
> >+
> >+void ql_mpi_work(struct work_struct *work)
> >+{
> >+	struct ql_adapter *qdev =
> >+	    container_of(work, struct ql_adapter, mpi_work.work);
> >+	struct mbox_params mbc;
> >+	struct mbox_params *mbcp = &mbc;
> >+	mbcp->out_count = 1;
> >+
> >+	while (ql_read32(qdev, STS) & STS_PI) {
> >+		if (ql_get_mb_sts(qdev, mbcp)) {
> >+			QPRINTK(qdev, DRV, ERR,
> >+				"Could not read MPI, resetting ASIC!\n");
> >+			ql_queue_asic_error(qdev);
> >+		}
> >+
> >+		switch (mbcp->mbox_out[0]) {
> >+		case AEN_LINK_UP:
> >+			ql_link_up(qdev);
> >+			break;
> >+		case AEN_LINK_DOWN:
> >+			ql_link_down(qdev);
> >+			break;
> >+		case AEN_FW_INIT_DONE:
> >+#ifdef PALLADIUM
> >+/* Palladium Workaround Start */
> >+		case 0:
> >+/* Palladium Workaround End */
> >+#endif
> >+			ql_init_fw_done(qdev);
> >+			break;
> >+		case AEN_FW_INIT_FAIL:
> >+			break;
> 
> No breaking here...

Thanks for bringing it to my attention.  I am in the process of cleaning this up.

> 
> >+		case AEN_SYS_ERR:
> >+			break;
> 
> ...and here necessary to make things more consistent with the lines
> below. (Having no default seems ok here.)
>

This wasn't done and kind of fell through the cracks.  It will be done
in the next submittal.

> >+		case MB_CMD_STS_GOOD:
> >+		case MB_CMD_STS_INTRMDT:
> >+		case MB_CMD_STS_ERR:
> >+		case AEN_IDC_CMPLT:
> >+		case AEN_IDC_REQ:
> >+			break;
> >+
> >+		}
> >+	}
> >+	ql_enable_completion_interrupt(qdev, 0);
> >+}
> >+
> >+void ql_mpi_reset_work(struct work_struct *work)
> >+{
> >+	struct ql_adapter *qdev =
> >+	    container_of(work, struct ql_adapter, mpi_reset_work.work);
> >+	printk(KERN_ERR "%s: Enter, qdev = %p..\n", __func__, qdev);
> >+}
> 
> Another inconsistency: you're not using QPRINTK() like before. Is this
> intended?

Not intended.  I'll fix it.


Thanks for your help.
-Ron



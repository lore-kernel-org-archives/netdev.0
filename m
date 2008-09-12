From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 5/8] [RFC] qlge: Add main source module qlge_main.c
Date: Thu, 11 Sep 2008 17:58:37 -0700
Message-ID: <20080912005837.GB23939@susedev.qlogic.org>
References: <20080910205813.GA13266@susedev.qlogic.org> <12210803433594-git-send-email-ron.mercer@qlogic.com> <48C8D937.5020708@marian.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com
To: Franco Fichtner <franco@marian.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:28608 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbYILA70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 20:59:26 -0400
Content-Disposition: inline
In-Reply-To: <48C8D937.5020708@marian.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2008 at 10:39:19AM +0200, Franco Fichtner wrote:

Hello Franco,
Thanks very much for your comments/suggestions.
Regarding ql_wait_idx_reg() and ql_wait_addr_reg() they provide waiting
while gaining access for read/writes to/from a secondary set of
registers.  To my understanding, you can't sleep while holding a
spinlock.  I tried this before and saw massive warnings.  I have
"Spinlock debugging: sleep-inside-spinlock checking" turned on in my
kernel and perhaps that's why I saw them.
At that point I changed from msleep to mdelay.
After reviewing your comments I've reduced and standardized the mdelay
wait to 5ms with a count of 50.
These secondary registers are
accessed only during open(), reset(), and a few
netdev-API like set_multi and add_vlan_vid.

> Ron Mercer wrote:
> 
> [snipped some code]
> 
> >+static int ql_wait_port_init_cmplt(struct ql_adapter *qdev)
> >+{
> >+	int count = 100;
> >+	u32 temp;
> >+
> >+	while (count) {
> >+		temp = ql_read32(qdev, STS);
> >+		if (temp & qdev->port_init)
> >+			return 0;
> >+		mdelay(5);
> 
> Wrost case: delaying for 500ms... msleep() here please.

Again, to my understanding, sleeping while holding a lock is
problematic.  I have changed this wait to 5ms * 50.

> 
> >+		QPRINTK(qdev, LINK, INFO, "Wait for MAC Port to 
> >Initialize.\n");
> 
> I don't know what QPRINTK does, but it gets executed 100 times. That
> can't possibly be intended?

Not intended.  It's gone.  Thanks.

> 
> >+		count--;
> >+	}
> >+	return -ETIMEDOUT;
> >+}
> >+
> >+/* The CFG register is used to download TX and RX control blocks
> >+ * to the chip. This function waits for an operation to complete.
> >+ */
> >+static int ql_wait_cfg(struct ql_adapter *qdev, u32 bit)
> >+{
> >+	int count = MSLEEP_COUNT;
> >+	u32 temp;
> >+
> >+	while (count) {
> >+		temp = ql_read32(qdev, CFG);
> >+		if (!(temp & bit))
> >+			return 0;
> >+		if (temp & CFG_LE)
> >+			return -EIO;
> >+		spin_unlock(&qdev->hw_lock);
> >+		msleep(MSLEEP_DELAY);
> >+		spin_lock(&qdev->hw_lock);
> 
> If this is why mdelay() is used in the other places... keeping the locks
> shouldn't hurt when changing them to msleep()? I don't see how a
> possible deadlock could occur in the mdelay() scenarios. And besides, 
> you seem to operate your spinlocks on a higher level than e.g. this
> function? Wouldn't that render multi-cpu usage pratically useless?

I've gotten rid of the unlock/lock and used mdelay() for 5ms * 50 as
above.  This is used to download a control block to the chip and then
wait for it to initialize internal data structures.  Only used during
open() and ethtool->set_coalesce() (if the device is up).

> 
> >+		count--;
> >+	}
> >+	return -ETIMEDOUT;
> >+}
> >+
> >+/* Used to issue init control blocks to hw. Maps control block,
> >+ * sets address, triggers download, waits for completion.
> >+ */
> >+int ql_write_cfg(struct ql_adapter *qdev, void *ptr, int size, u32 bit,
> >+		 u16 q_id)
> >+{
> >+	u64 map;
> >+	int status = 0;
> >+	int direction;
> >+	u32 mask;
> >+	u32 value;
> >+
> >+	direction =
> >+	    (bit & (CFG_LRQ | CFG_LR | CFG_LCQ)) ? PCI_DMA_TODEVICE :
> >+	    PCI_DMA_FROMDEVICE;
> >+
> >+	map = pci_map_single(qdev->pdev, ptr, size, direction);
> >+	if (pci_dma_mapping_error(map)) {
> >+		QPRINTK(qdev, IFUP, ERR, "Couldn't map DMA area.\n");
> >+		return -ENOMEM;
> >+	}
> >+
> >+	status = ql_wait_cfg(qdev, bit);
> >+	if (status) {
> >+		QPRINTK(qdev, IFUP, ERR,
> >+			"Timed out waiting for CFG to come ready.\n");
> >+		goto exit;
> >+	}
> >+
> >+	status = ql_sem_spinlock(qdev, SEM_ICB_MASK);
> >+	if (status)
> >+		goto exit;
> >+	ql_write32(qdev, ICB_L, (u32) map);
> >+	ql_write32(qdev, ICB_H, (u32) (map >> 32));
> >+	ql_sem_unlock(qdev, SEM_ICB_MASK);	/* does flush too */
> >+
> >+	mask = CFG_Q_MASK | (bit << 16);
> >+	value = bit | (q_id << CFG_Q_SHIFT);
> >+	ql_write32(qdev, CFG, (mask | value));
> >+
> >+	/*
> >+	 * Wait for the bit to clear after signaling hw.
> >+	 */
> >+	status = ql_wait_cfg(qdev, bit);
> >+exit:
> >+	pci_unmap_single(qdev->pdev, map, size, direction);
> >+	return status;
> >+}
> >+
> >+/* This chip has several addr/data register pairs that are used
> >+ * to index into another set of registers.  This function waits
> >+ * for a specified register set to be ready for access.
> >+ * Examples would be setting up the CAM with MAC addresses, setting
> >+ * up the frame routing table.
> >+ */
> >+static int ql_wait_idx_reg(struct ql_adapter *qdev, u32 reg, u32 flag)
> >+{
> >+	int count = 200;
> >+	u32 temp;
> >+
> >+	while (count) {
> >+		temp = ql_read32(qdev, reg);
> >+		if (temp & flag)
> >+			return 0;
> >+		mdelay(5);
> 
> Delaying for a 1000ms worst case.

See comments at top.

> 
> >+		count--;
> >+	}
> >+	return -ETIMEDOUT;
> >+}
> 
> [snipped more code]
> 
> >+static int ql_port_initialize(struct ql_adapter *qdev)
> >+{
> >+	int status = 0;
> >+	u32 data;
> >+
> >+	if (ql_sem_trylock(qdev, qdev->xg_sem_mask)) {
> >+		/* Another function has the semaphore, so
> >+		 * wait for the port init bit to come ready.
> >+		 */
> >+		QPRINTK(qdev, LINK, INFO,
> >+			"Another function has the semaphore, so wait for the 
> >port init bit to come ready.\n");
> >+		status = ql_wait_port_init_cmplt(qdev);
> >+		if (status) {
> >+			QPRINTK(qdev, LINK, CRIT,
> >+				"Port initialize timed out.\n");
> >+		}
> >+		return status;
> >+	}
> >+
> >+	QPRINTK(qdev, LINK, INFO, "Got xgmac semaphore!.\n");
> >+	/* Set the core reset. */
> >+	status = ql_read_xgmac_reg(qdev, GLOBAL_CFG, &data);
> >+	if (status)
> >+		goto end;
> >+	data |= GLOBAL_CFG_RESET;
> >+	status = ql_write_xgmac_reg(qdev, GLOBAL_CFG, data);
> >+	if (status)
> >+		goto end;
> >+
> >+	mdelay(100);
> 
> Again.

This shouldn't be there because it's followed by a wait before another
write.  It's gone now.

> 
> >+
> >+	/* Clear the core reset and turn on jumbo for receiver. */
> >+	data &= ~GLOBAL_CFG_RESET;	/* Clear core reset. */
> >+	data |= GLOBAL_CFG_JUMBO;	/* Turn on jumbo. */
> >+	data |= GLOBAL_CFG_TX_STAT_EN;
> >+	data |= GLOBAL_CFG_RX_STAT_EN;
> >+	status = ql_write_xgmac_reg(qdev, GLOBAL_CFG, data);
> >+	if (status)
> >+		goto end;
> >+
> >+	/* Enable transmitter, and clear it's reset. */
> >+	status = ql_read_xgmac_reg(qdev, TX_CFG, &data);
> >+	if (status)
> >+		goto end;
> >+	data &= ~TX_CFG_RESET;	/* Clear the TX MAC reset. */
> >+	data |= TX_CFG_EN;	/* Enable the transmitter. */
> >+	status = ql_write_xgmac_reg(qdev, TX_CFG, data);
> >+	if (status)
> >+		goto end;
> >+
> >+	/* Enable receiver and clear it's reset. */
> >+	status = ql_read_xgmac_reg(qdev, RX_CFG, &data);
> >+	if (status)
> >+		goto end;
> >+	data &= ~RX_CFG_RESET;	/* Clear the RX MAC reset. */
> >+	data |= RX_CFG_EN;	/* Enable the receiver. */
> >+	status = ql_write_xgmac_reg(qdev, RX_CFG, data);
> >+	if (status)
> >+		goto end;
> >+
> >+	/* Turn on jumbo. */
> >+	status =
> >+	    ql_write_xgmac_reg(qdev, MAC_TX_PARAMS, MAC_TX_PARAMS_JUMBO | 
> >(0x2580 << 16));
> >+	if (status)
> >+		goto end;
> >+	status =
> >+	    ql_write_xgmac_reg(qdev, MAC_RX_PARAMS, 0x2580);
> >+	if (status)
> >+		goto end;
> >+
> >+	/* Signal to the world that the port is enabled.        */
> >+	ql_write32(qdev, STS, ((qdev->port_init << 16) | qdev->port_init));
> >+end:
> >+	ql_sem_unlock(qdev, qdev->xg_sem_mask);
> >+	return status;
> >+}
> >+
> >+/* Get the next large buffer. */
> >+struct bq_desc *ql_get_curr_lbuf(struct rx_ring *rx_ring)
> >+{
> >+	struct bq_desc *lbq_desc = &rx_ring->lbq[rx_ring->lbq_curr_idx];
> >+	rx_ring->lbq_curr_idx++;
> >+	if (rx_ring->lbq_curr_idx == rx_ring->lbq_len)
> >+		rx_ring->lbq_curr_idx = 0;
> >+	rx_ring->lbq_free_cnt++;
> >+	return lbq_desc;
> >+}
> 
> [ remaining code snipped, a bit too much for today ]
> 
> 
> Franco

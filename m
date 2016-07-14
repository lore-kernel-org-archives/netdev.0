From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Subject: RE: [PATCH v3 5/8] thunderbolt: Communication with the ICM
 (firmware)
Date: Thu, 14 Jul 2016 18:34:59 +0000
Message-ID: <E607265CB020454880711A6F96C05A03893CD910@hasmsx107.ger.corp.intel.com>
References: <1468495702-7467-1-git-send-email-amir.jer.levy@intel.com>
 <1468495702-7467-6-git-send-email-amir.jer.levy@intel.com>
 <5B8DA87D05A7694D9FA63FD143655C1B54294E4A@hasmsx108.ger.corp.intel.com>
 <9B0331B6EBBD0E4684FBFAEDA55776F92CD7D05F@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	thunderbolt-linux <thunderbolt-linux@intel.com>,
	"Westerberg, Mika" <mika.westerberg@intel.com>
To: "Rosen, Rami" <rami.rosen@intel.com>,
	"Winkler, Tomas" <tomas.winkler@intel.com>,
	"andreas.noever@gmail.com" <andreas.noever@gmail.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"bhelgaas@google.com" <bhelgaas@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F92CD7D05F@HASMSX110.ger.corp.intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 14 2016, 06:08 PM, Rosen, Rami wrote:
> Hi Amir,

Hi Rami,

> Here are my 2 cents:
> 
> This method always returns true, should be void (unless you will change
> PDF_ERROR_NOTIFICATION  or other pdf values to return false), and
> likewise its invocation should not check return value.
> 

This patch is the communication with the FW.
The network functionality is added in the next patches in the series 
and with it, more messages from FW.
Indeed this function always returns true in this patch, 
but while writing it, I predicted that the network functionality will 
use the send_event flag differently.
You can see the documentation of send_event - currently unused in this patch.
I don't see any harm that in this patch, this function will always return true,
while applying the rest of the series will change it.

> > +static bool nhi_msg_from_icm_analysis(struct tbt_nhi_ctxt *nhi_ctxt,
> > +					enum pdf_value pdf,
> > +					const u8 *msg, u32 msg_len)
> > +{
> > +	/*
> > +	 * preparation for messages that won't be sent,
> > +	 * currently unused in this patch.
> > +	 */
> > +	bool send_event = true;
> > +
> > +	switch (pdf) {
> > +	case PDF_ERROR_NOTIFICATION:
> > +		dev_err(&nhi_ctxt->pdev->dev,
> > +			"controller id %#x PDF_ERROR_NOTIFICATION %hhu
> > msg len %u\n",
> > +			nhi_ctxt->id, msg[11], msg_len);
> > +		/* fallthrough */
> > +	case PDF_WRITE_CONFIGURATION_REGISTERS:
> > +		/* fallthrough */
> > +	case PDF_READ_CONFIGURATION_REGISTERS:
> > +		if (nhi_ctxt->wait_for_icm_resp) {
> > +			nhi_ctxt->wait_for_icm_resp = false;
> > +			up(&nhi_ctxt->send_sem);
> > +		}
> > +		break;
> > +
> > +	case PDF_FW_TO_SW_RESPONSE:
> > +		if (nhi_ctxt->wait_for_icm_resp) {
> > +			nhi_ctxt->wait_for_icm_resp = false;
> > +			up(&nhi_ctxt->send_sem);
> > +		}
> > +		break;
> > +
> > +	default:
> > +		dev_warn(&nhi_ctxt->pdev->dev,
> > +			 "controller id %#x pdf %u isn't handled/expected\n",
> > +			 nhi_ctxt->id, pdf);
> > +		break;
> > +	}
> > +
> > +	return send_event;
> > +}
> > +
> 
> This methods always returns 0, should be void.
> 

The prototype of suspend is return int:
http://lxr.free-electrons.com/source/include/linux/pm.h#L295

> > +static int nhi_suspend(struct device *dev) __releases(&nhi_ctxt-
> > >send_sem)
> > +{
> > +	struct tbt_nhi_ctxt *nhi_ctxt = pci_get_drvdata(to_pci_dev(dev));
> > +	void __iomem *rx_reg, *tx_reg;
> > +	u32 rx_reg_val, tx_reg_val;
> > +
> > +	/* must be after negotiation_events, since messages might be sent
> > */
> > +	nhi_ctxt->d0_exit = true;
> > +
> > +	rx_reg = nhi_ctxt->iobase + REG_RX_OPTIONS_BASE +
> > +		 (TBT_ICM_RING_NUM * REG_OPTS_STEP);
> > +	rx_reg_val = ioread32(rx_reg) & ~REG_OPTS_E2E_EN;
> > +	tx_reg = nhi_ctxt->iobase + REG_TX_OPTIONS_BASE +
> > +		 (TBT_ICM_RING_NUM * REG_OPTS_STEP);
> > +	tx_reg_val = ioread32(tx_reg) & ~REG_OPTS_E2E_EN;
> > +	/* disable RX flow control  */
> > +	iowrite32(rx_reg_val, rx_reg);
> > +	/* disable TX flow control  */
> > +	iowrite32(tx_reg_val, tx_reg);
> > +	/* disable RX ring  */
> > +	iowrite32(rx_reg_val & ~REG_OPTS_VALID, rx_reg);
> > +
> > +	mutex_lock(&nhi_ctxt->d0_exit_mailbox_mutex);
> > +	mutex_lock(&nhi_ctxt->d0_exit_send_mutex);
> > +
> > +	cancel_work_sync(&nhi_ctxt->icm_msgs_work);
> > +
> > +	if (nhi_ctxt->wait_for_icm_resp) {
> > +		nhi_ctxt->wait_for_icm_resp = false;
> > +		nhi_ctxt->ignore_icm_resp = false;
> > +		/*
> > +		 * if there is response, it is lost, so unlock the send
> > +		 * for the next resume.
> > +		 */
> > +		up(&nhi_ctxt->send_sem);
> > +	}
> > +
> > +	mutex_unlock(&nhi_ctxt->d0_exit_send_mutex);
> > +	mutex_unlock(&nhi_ctxt->d0_exit_mailbox_mutex);
> > +
> > +	/* wait for all TX to finish  */
> > +	usleep_range(5 * USEC_PER_MSEC, 7 * USEC_PER_MSEC);
> > +
> > +	/* disable all interrupts */
> > +	iowrite32(0, nhi_ctxt->iobase + REG_RING_INTERRUPT_BASE);
> > +	/* disable TX ring  */
> > +	iowrite32(tx_reg_val & ~REG_OPTS_VALID, tx_reg);
> > +
> > +	return 0;
> > +}
> > +
> 
> This methods also always returns 0, should be void.
> 

The prototype of resume is return int:
http://lxr.free-electrons.com/source/include/linux/pm.h#L295

> > +static int nhi_resume(struct device *dev) __acquires(&nhi_ctxt-
> > >send_sem)
> > +{
> > +	dma_addr_t phys;
> > +	struct tbt_nhi_ctxt *nhi_ctxt = pci_get_drvdata(to_pci_dev(dev));
> > +	struct tbt_buf_desc *desc;
> > +	void __iomem *iobase = nhi_ctxt->iobase;
> > +	void __iomem *reg;
> > +	int i;
> > +
> > +	if (nhi_ctxt->msix_entries) {
> > +		iowrite32(ioread32(iobase + REG_DMA_MISC) |
> > +
> > 	REG_DMA_MISC_INT_AUTO_CLEAR,
> > +			  iobase + REG_DMA_MISC);
> > +		/*
> > +		 * Vector #0, which is TX complete to ICM,
> > +		 * isn't been used currently.
> > +		 */
> > +		nhi_set_int_vec(nhi_ctxt, 0, 1);
> > +
> > +		for (i = 2; i < nhi_ctxt->num_vectors; i++)
> > +			nhi_set_int_vec(nhi_ctxt, nhi_ctxt->num_paths -
> > (i/2),
> > +					i);
> > +	}
> > +
> > +	/* configure TX descriptors */
> > +	for (i = 0, phys = nhi_ctxt->icm_ring_shared_mem_dma_addr;
> > +	     i < TBT_ICM_RING_NUM_TX_BUFS;
> > +	     i++, phys += TBT_ICM_RING_MAX_FRAME_SIZE) {
> > +		desc = &nhi_ctxt->icm_ring_shared_mem->tx_buf_desc[i];
> > +		desc->phys = cpu_to_le64(phys);
> > +		desc->attributes = cpu_to_le32(DESC_ATTR_REQ_STS);
> > +	}
> > +	/* configure RX descriptors */
> > +	for (i = 0;
> > +	     i < TBT_ICM_RING_NUM_RX_BUFS;
> > +	     i++, phys += TBT_ICM_RING_MAX_FRAME_SIZE) {
> > +		desc = &nhi_ctxt->icm_ring_shared_mem->rx_buf_desc[i];
> > +		desc->phys = cpu_to_le64(phys);
> > +		desc->attributes = cpu_to_le32(DESC_ATTR_REQ_STS |
> > +					       DESC_ATTR_INT_EN);
> > +	}
> > +
> > +	/* configure throttling rate for interrupts */
> > +	for (i = 0, reg = iobase + REG_INT_THROTTLING_RATE;
> > +	     i < NUM_INT_VECTORS;
> > +	     i++, reg += REG_INT_THROTTLING_RATE_STEP) {
> > +		iowrite32(USEC_TO_256_NSECS(128), reg);
> > +	}
> > +
> > +	/* configure TX for ICM ring */
> > +	reg = iobase + REG_TX_RING_BASE + (TBT_ICM_RING_NUM *
> > REG_RING_STEP);
> > +	phys = nhi_ctxt->icm_ring_shared_mem_dma_addr +
> > +		offsetof(struct tbt_icm_ring_shared_memory, tx_buf_desc);
> > +	iowrite32(lower_32_bits(phys), reg + REG_RING_PHYS_LO_OFFSET);
> > +	iowrite32(upper_32_bits(phys), reg + REG_RING_PHYS_HI_OFFSET);
> > +	iowrite32((TBT_ICM_RING_NUM_TX_BUFS <<
> > REG_RING_SIZE_SHIFT) &
> > +			REG_RING_SIZE_MASK,
> > +		  reg + REG_RING_SIZE_OFFSET);
> > +
> > +	reg = iobase + REG_TX_OPTIONS_BASE +
> > (TBT_ICM_RING_NUM*REG_OPTS_STEP);
> > +	iowrite32(REG_OPTS_RAW | REG_OPTS_VALID, reg);
> > +
> > +	/* configure RX for ICM ring */
> > +	reg = iobase + REG_RX_RING_BASE + (TBT_ICM_RING_NUM *
> > REG_RING_STEP);
> > +	phys = nhi_ctxt->icm_ring_shared_mem_dma_addr +
> > +		offsetof(struct tbt_icm_ring_shared_memory, rx_buf_desc);
> > +	iowrite32(lower_32_bits(phys), reg + REG_RING_PHYS_LO_OFFSET);
> > +	iowrite32(upper_32_bits(phys), reg + REG_RING_PHYS_HI_OFFSET);
> > +	iowrite32(((TBT_ICM_RING_NUM_RX_BUFS <<
> > REG_RING_SIZE_SHIFT) &
> > +			REG_RING_SIZE_MASK) |
> > +		  ((TBT_ICM_RING_MAX_FRAME_SIZE <<
> > REG_RING_BUF_SIZE_SHIFT) &
> > +			REG_RING_BUF_SIZE_MASK),
> > +		  reg + REG_RING_SIZE_OFFSET);
> > +	iowrite32(((TBT_ICM_RING_NUM_RX_BUFS - 1) <<
> > REG_RING_CONS_SHIFT) &
> > +			REG_RING_CONS_MASK,
> > +		  reg + REG_RING_CONS_PROD_OFFSET);
> > +
> > +	reg = iobase + REG_RX_OPTIONS_BASE +
> > (TBT_ICM_RING_NUM*REG_OPTS_STEP);
> > +	iowrite32(REG_OPTS_RAW | REG_OPTS_VALID, reg);
> > +
> > +	/* enable RX interrupt */
> > +	RING_INT_ENABLE_RX(iobase, TBT_ICM_RING_NUM, nhi_ctxt-
> > >num_paths);
> > +
> > +	if (likely((atomic_read(&subscribers) > 0) &&
> > +		   nhi_nvm_authenticated(nhi_ctxt))) {
> > +		down(&nhi_ctxt->send_sem);
> > +		nhi_ctxt->d0_exit = false;
> > +		mutex_lock(&nhi_ctxt->d0_exit_send_mutex);
> > +		/*
> > +		 * interrupts are enabled here before send due to
> > +		 * implicit barrier in mutex
> > +		 */
> > +		nhi_send_driver_ready_command(nhi_ctxt);
> > +		mutex_unlock(&nhi_ctxt->d0_exit_send_mutex);
> > +	} else {
> > +		nhi_ctxt->d0_exit = false;
> > +	}
> > +
> > +	return 0;
> > +}
> 
> 
> Regards,
> Rami Rosen
> Intel Corporation

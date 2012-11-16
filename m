From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v5 1/2] PCI-Express Non-Transparent Bridge Support
Date: Thu, 15 Nov 2012 16:29:04 -0800
Message-ID: <20121116002904.GA20876@kroah.com>
References: <1352160669-4330-1-git-send-email-jon.mason@intel.com>
 <1352160669-4330-2-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1352160669-4330-2-git-send-email-jon.mason@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 05, 2012 at 05:11:08PM -0700, Jon Mason wrote:
> --- /dev/null
> +++ b/drivers/ntb/ntb_hw.h
> @@ -0,0 +1,195 @@
> +/*
> + * This file is provided under a dual BSD/GPLv2 license.  When using or
> + *   redistributing this file, you may do so under either license.
> + *
> + *   GPL LICENSE SUMMARY
> + *
> + *   Copyright(c) 2012 Intel Corporation. All rights reserved.
> + *
> + *   This program is free software; you can redistribute it and/or modify
> + *   it under the terms of version 2 of the GNU General Public License as
> + *   published by the Free Software Foundation.
> + *
> + *   BSD LICENSE
> + *
> + *   Copyright(c) 2012 Intel Corporation. All rights reserved.
> + *
> + *   Redistribution and use in source and binary forms, with or without
> + *   modification, are permitted provided that the following conditions
> + *   are met:
> + *
> + *     * Redistributions of source code must retain the above copyright
> + *       notice, this list of conditions and the following disclaimer.
> + *     * Redistributions in binary form must reproduce the above copy
> + *       notice, this list of conditions and the following disclaimer in
> + *       the documentation and/or other materials provided with the
> + *       distribution.
> + *     * Neither the name of Intel Corporation nor the names of its
> + *       contributors may be used to endorse or promote products derived
> + *       from this software without specific prior written permission.
> + *
> + *   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
> + *   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
> + *   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
> + *   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
> + *   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
> + *   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
> + *   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
> + *   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
> + *   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> + *   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
> + *   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + *
> + * Intel PCIe NTB Linux driver
> + *
> + * Contact Information:
> + * Jon Mason <jon.mason@intel.com>
> + */
> +
> +#define PCI_DEVICE_ID_INTEL_NTB_B2B_JSF		0x3725
> +#define PCI_DEVICE_ID_INTEL_NTB_CLASSIC_JSF	0x3726
> +#define PCI_DEVICE_ID_INTEL_NTB_RP_JSF		0x3727
> +#define PCI_DEVICE_ID_INTEL_NTB_RP_SNB		0x3C08
> +#define PCI_DEVICE_ID_INTEL_NTB_B2B_SNB		0x3C0D
> +#define PCI_DEVICE_ID_INTEL_NTB_CLASSIC_SNB	0x3C0E
> +#define PCI_DEVICE_ID_INTEL_NTB_2ND_SNB		0x3C0F
> +#define PCI_DEVICE_ID_INTEL_NTB_B2B_BWD		0x0C4E
> +
> +#define msix_table_size(control)	((control & PCI_MSIX_FLAGS_QSIZE)+1)
> +
> +#define NTB_BAR_MMIO		0
> +#define NTB_BAR_23		2
> +#define NTB_BAR_45		4
> +#define NTB_BAR_MASK		((1 << NTB_BAR_MMIO) | (1 << NTB_BAR_23) |\
> +				 (1 << NTB_BAR_45))
> +
> +#define NTB_LINK_DOWN		0
> +#define NTB_LINK_UP		1
> +
> +#define NTB_HB_TIMEOUT		msecs_to_jiffies(1000)
> +
> +#define NTB_NUM_MW		2
> +
> +enum ntb_hw_event {
> +	NTB_EVENT_SW_EVENT0 = 0,
> +	NTB_EVENT_SW_EVENT1,
> +	NTB_EVENT_SW_EVENT2,
> +	NTB_EVENT_HW_ERROR,
> +	NTB_EVENT_HW_LINK_UP,
> +	NTB_EVENT_HW_LINK_DOWN,
> +};
> +
> +struct ntb_mw {
> +	dma_addr_t phys_addr;
> +	void __iomem *vbase;
> +	resource_size_t bar_sz;
> +};
> +
> +struct ntb_db_cb {
> +	void (*callback) (void *data, int db_num);
> +	unsigned int db_num;
> +	void *data;
> +	struct ntb_device *ndev;
> +};
> +
> +struct ntb_device {
> +	struct pci_dev *pdev;
> +	struct msix_entry *msix_entries;
> +	void __iomem *reg_base;
> +	struct ntb_mw mw[NTB_NUM_MW];
> +	struct {
> +		unsigned int max_spads;
> +		unsigned int max_db_bits;
> +		unsigned int msix_cnt;
> +	} limits;
> +	struct {
> +		void __iomem *pdb;
> +		void __iomem *pdb_mask;
> +		void __iomem *sdb;
> +		void __iomem *sbar2_xlat;
> +		void __iomem *sbar4_xlat;
> +		void __iomem *spad_write;
> +		void __iomem *spad_read;
> +		void __iomem *lnk_cntl;
> +		void __iomem *lnk_stat;
> +		void __iomem *spci_cmd;
> +	} reg_ofs;
> +	void *ntb_transport;

Use the real type here please.  No void *.

> +	void (*event_cb)(void *handle, enum ntb_hw_event event);
> +
> +	struct ntb_db_cb *db_cb;
> +	unsigned char hw_type;
> +	unsigned char conn_type;
> +	unsigned char dev_type;
> +	unsigned char num_msix;
> +	unsigned char bits_per_vector;
> +	unsigned char max_cbs;
> +	unsigned char link_status;
> +	struct delayed_work hb_timer;
> +	unsigned long last_ts;
> +};

Shouldn't this have a 'struct device' embedded it in somewhere?


> +/**
> + * ntb_hw_link_status() - return the hardware link status
> + * @ndev: pointer to ntb_device instance
> + *
> + * Returns true if the hardware is connected to the remote system
> + *
> + * RETURNS: true or false based on the hardware link state
> + */
> +static inline bool ntb_hw_link_status(struct ntb_device *ndev)
> +{
> +	return ndev->link_status == NTB_LINK_UP;
> +}
> +
> +/**
> + * ntb_query_pdev() - return the pci_dev pointer
> + * @ndev: pointer to ntb_device instance
> + *
> + * Given the ntb pointer return the pci_dev pointerfor the NTB hardware device
> + *
> + * RETURNS: a pointer to the ntb pci_dev
> + */
> +static inline struct pci_dev *ntb_query_pdev(struct ntb_device *ndev)
> +{
> +	return ndev->pdev;
> +}
> +
> +/**
> + * ntb_query_max_cbs() - return the maximum number of callback tuples
> + * @ndev: pointer to ntb_device instance
> + *
> + * The number of callbacks can vary depending on the platform and MSI-X/MSI
> + * enablement
> + *
> + * RETURNS: the maximum number of callback tuples (3, 15, or 33)
> + */
> +static inline unsigned int ntb_query_max_cbs(struct ntb_device *ndev)
> +{
> +	return ndev->max_cbs;
> +}

It is shorter, and simpler, to just write the '->variable' version out
for this, than to make the function call here.  Why are these needed?
Especially when I see the driver code not using them.  Please remove.

> +static void ntb_client_release(struct device *dev)
> +{
> +}

Ah, how sweet.  Now, according to the in-kernel documentation, I get to
publicly mock you for trying to be smarter than the kernel.  Nice try.

Think back to when you wrote this function.  Did you really think it was
the correct thing to do?  If not, why did you do this?



Sorry, no.

> +struct bus_type ntb_bus_type = {
> +	.name = "ntb_bus",
> +	.match = ntb_match_bus,
> +	.probe = ntb_client_probe,
> +	.remove = ntb_client_remove,
> +};
> +
> +static atomic_t ntb_bus_use = ATOMIC_INIT(0);
> +
> +static int __devinit ntb_bus_init(void)
> +{
> +	int rc;
> +
> +	if (atomic_inc_return(&ntb_bus_use) == 1) {

That's the wierdest way of using an atomic variable I have ever seen.
How could this ever be anything but 0?  If you need a lock, use a lock.

> +static int __devinit ntb_dev_init(struct ntb_transport *nt)
> +{
> +	struct device *dev = &nt->netdev;

Ah, there's the struct device.  Don't call it a 'netdev', that's just
really really confusing to anyone who has looked at a network driver.
As this isn't a netdev, it's a 'device'.

> +	int rc;
> +
> +	rc = ntb_bus_init();
> +	if (rc)
> +		goto err;
> +
> +	/* setup and register client devices */
> +	dev_set_name(dev, "ntb_netdev");

All devices get the same name?  That's a recipe for confusion.

> +static void ntb_transport_setup_qp_mw(struct ntb_transport *nt,
> +				      unsigned int qp_num)
> +{
> +	struct ntb_transport_qp *qp = &nt->qps[qp_num];
> +	u8 mw_num = QP_TO_MW(qp_num);
> +	unsigned int size, num_qps_mw;
> +
> +	WARN_ON(nt->mw[mw_num].virt_addr == 0);
> +
> +	if (nt->max_qps % NTB_NUM_MW && !mw_num)
> +		num_qps_mw = nt->max_qps / NTB_NUM_MW +
> +			     (nt->max_qps % NTB_NUM_MW - mw_num);
> +	else
> +		num_qps_mw = nt->max_qps / NTB_NUM_MW;
> +
> +	size = nt->mw[mw_num].size / num_qps_mw;
> +	pr_debug("orig size = %d, num qps = %d, size = %d\n",
> +		 (int) nt->mw[mw_num].size, nt->max_qps, size);
> +
> +	qp->rx_buff_begin = nt->mw[mw_num].virt_addr +
> +			    (qp_num / NTB_NUM_MW * size);
> +	qp->rx_buff_end = qp->rx_buff_begin + size;
> +	pr_info("QP %d - RX Buff start %p end %p\n", qp->qp_num,
> +		qp->rx_buff_begin, qp->rx_buff_end);
> +	qp->rx_offset = qp->rx_buff_begin;
> +
> +	qp->tx_mw_begin = ntb_get_mw_vbase(nt->ndev, mw_num) +
> +			  (qp_num / NTB_NUM_MW * size);
> +	qp->tx_mw_end = qp->tx_mw_begin + size;
> +	pr_info("QP %d - TX MW start %p end %p\n", qp->qp_num, qp->tx_mw_begin,
> +		qp->tx_mw_end);

That's some debugging information spamming the kernel log, please
remove.

Also, you have a 'struct device', so use dev_dbg() and friends, not pr_*
calls.  This should be fixed in lots of places here.

thanks,

greg k-h

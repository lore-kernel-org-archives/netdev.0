From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: RE: [PATCH 6/14] nes: hardware init
Date: Wed, 8 Aug 2007 09:33:33 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC07443E4D@venom2>
References: <200708080105.l7815pC3004792@neteffect.com> <46B92342.9090802@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <rdreier@cisco.com>, <ewg@lists.openfabrics.org>,
	<netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.neteffect.com ([204.57.75.68]:21966 "EHLO
	mail2.neteffect.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935645AbXHHOtu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 10:49:50 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46B92342.9090802@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Thanks for the input.  I'll take your suggestions into account for the
patch v2 posting.

Glenn.

-----Original Message-----
From: Jeff Garzik [mailto:jeff@garzik.org] 
Sent: Tuesday, August 07, 2007 8:58 PM
To: Glenn Grundstrom
Cc: rdreier@cisco.com; ewg@lists.openfabrics.org; netdev@vger.kernel.org
Subject: Re: [PATCH 6/14] nes: hardware init

ggrundstrom@neteffect.com wrote:
> +struct nes_adapter *nes_init_adapter(struct nes_device *nesdev, u8
hw_rev) {
> +	struct nes_adapter *nesadapter = NULL;
> +	unsigned long num_pds;
> +	u32 u32temp;
> +	u32 port_count;
> +	u16 max_rq_wrs;
> +	u16 max_sq_wrs;
> +	u32 max_mr;
> +	u32 max_256pbl;
> +	u32 max_4kpbl;
> +	u32 max_qp;
> +	u32 max_irrq;
> +	u32 max_cq;
> +	u32 hte_index_mask;
> +	u32 adapter_size;
> +	u32 arp_table_size;
> +	u8  OneG_Mode;
> +
> +	/* search the list of existing adapters */
> +	list_for_each_entry(nesadapter, &nes_adapter_list, list) {
> +		dprintk("Searching Adapter list for PCI devfn = 0x%X,"
> +				" adapter PCI slot/bus = %u/%u, pci
devices PCI slot/bus = %u/%u, .\n",
> +				nesdev->pcidev->devfn,
> +				PCI_SLOT(nesadapter->devfn),
> +				nesadapter->bus_number,
> +				PCI_SLOT(nesdev->pcidev->devfn),
> +				nesdev->pcidev->bus->number );
> +		if ((PCI_SLOT(nesadapter->devfn) ==
PCI_SLOT(nesdev->pcidev->devfn)) &&
> +			(nesadapter->bus_number ==
nesdev->pcidev->bus->number)) {
> +			nesadapter->ref_count++;
> +			return(nesadapter);

you don't need any of this PCI bus scanning at all.  Please convert to
normal PCI usage



> +	/* no adapter found */
> +	num_pds = pci_resource_len(nesdev->pcidev, BAR_1) / 4096;

see, this is why the BAR_1 define should go away -- it's actually define

to the value '2'


> +	if (hw_rev != NE020_REV) {
> +		dprintk("%s: NE020 driver detected unknown hardware
revision 0x%x\n",
> +				__FUNCTION__, hw_rev);
> +		return(NULL);
> +	}

move this test to the top of the function


> +	dprintk("%s:%u Determine Soft Reset, QP_control=0x%x, CPU0=0x%x,
CPU1=0x%x, CPU2=0x%x\n",
> +			__FUNCTION__, __LINE__,
> +			nes_read_indexed(nesdev, NES_IDX_QP_CONTROL +
PCI_FUNC(nesdev->pcidev->devfn) * 8),
> +			nes_read_indexed(nesdev,
NES_IDX_INT_CPU_STATUS),
> +			nes_read_indexed(nesdev, 0x00A4),
> +			nes_read_indexed(nesdev, 0x00A8));
> +
> +		dprintk("%s: Reset and init NE020\n", __FUNCTION__);
> +		if ((port_count = nes_reset_adapter_ne020(nesdev,
&OneG_Mode)) == 0) {
> +			return(NULL);
> +		}
> +		if (nes_init_serdes(nesdev, port_count)) {
> +			return(NULL);
> +		}

kill braces


> +		nes_init_csr_ne020(nesdev, hw_rev, port_count);
> +
> +	/* Setup and enable the periodic timer */
> +	nesdev->et_rx_coalesce_usecs_irq = interrupt_mod_interval;
> +	if (nesdev->et_rx_coalesce_usecs_irq) {
> +		nes_write32(nesdev->regs+NES_PERIODIC_CONTROL,
0x80000000 |
> +				((u32)(nesdev->et_rx_coalesce_usecs_irq
* 8)));
> +	} else {
> +		nes_write32(nesdev->regs+NES_PERIODIC_CONTROL,
0x00000000);
> +	}
> +
> +	max_qp = nes_read_indexed(nesdev, NES_IDX_QP_CTX_SIZE);
> +	dprintk("%s: QP_CTX_SIZE=%u\n", __FUNCTION__, max_qp);
> +
> +	u32temp = nes_read_indexed(nesdev,
NES_IDX_QUAD_HASH_TABLE_SIZE);
> +	if (max_qp > ((u32)1 << (u32temp & 0x001f))) {
> +		dprintk("Reducing Max QPs to %u due to hash table size =
0x%08X\n",
> +				max_qp, u32temp);
> +		max_qp = (u32)1 << (u32temp & 0x001f);
> +	}
> +
> +	hte_index_mask = ((u32)1 << ((u32temp & 0x001f)+1))-1;
> +	dprintk("Max QP = %u, hte_index_mask = 0x%08X.\n", max_qp,
hte_index_mask);
> +
> +	u32temp = nes_read_indexed(nesdev, NES_IDX_IRRQ_COUNT);
> +
> +	max_irrq = 1 << (u32temp & 0x001f);
> +
> +	if (max_qp > max_irrq) {
> +		max_qp = max_irrq;
> +		dprintk("Reducing Max QPs to %u due to Available
Q1s.\n", max_qp);
> +	}
> +
> +	/* there should be no reason to allocate more pds than qps */
> +	if (num_pds > max_qp)
> +		num_pds = max_qp;
> +
> +	u32temp = nes_read_indexed(nesdev, NES_IDX_MRT_SIZE);
> +	max_mr = (u32)8192 << (u32temp & 0x7);
> +
> +	u32temp = nes_read_indexed(nesdev, NES_IDX_PBL_REGION_SIZE);
> +	max_256pbl = (u32)1 << (u32temp & 0x0000001f);
> +	max_4kpbl = (u32)1 << ((u32temp >> 16) & 0x0000001f);
> +	max_cq = nes_read_indexed(nesdev, NES_IDX_CQ_CTX_SIZE);
> +
> +	u32temp = nes_read_indexed(nesdev, NES_IDX_ARP_CACHE_SIZE);
> +	arp_table_size = 1 << u32temp;
> +
> +	adapter_size = (sizeof(struct nes_adapter) +
> +			(sizeof(unsigned long)-1)) & (~(sizeof(unsigned
long)-1));
> +	adapter_size += sizeof(unsigned long) * BITS_TO_LONGS(max_qp);
> +	adapter_size += sizeof(unsigned long) * BITS_TO_LONGS(max_mr);
> +	adapter_size += sizeof(unsigned long) * BITS_TO_LONGS(max_cq);
> +	adapter_size += sizeof(unsigned long) * BITS_TO_LONGS(num_pds);
> +	adapter_size += sizeof(unsigned long) *
BITS_TO_LONGS(arp_table_size);
> +	adapter_size += sizeof(struct nes_qp **) * max_qp;
> +
> +	/* allocate a new adapter struct */
> +	nesadapter = kmalloc(adapter_size, GFP_KERNEL);
> +	if (nesadapter == NULL) {
> +		return(NULL);
> +	}
> +	memset(nesadapter, 0, adapter_size);

kzalloc


> +	dprintk("Allocating new nesadapter @ %p, size = %u (actual size
= %u).\n",
> +			nesadapter, (u32)sizeof(struct nes_adapter),
adapter_size);
> +
> +	/* populate the new nesadapter */
> +	nesadapter->devfn = nesdev->pcidev->devfn;
> +	nesadapter->bus_number = nesdev->pcidev->bus->number;

wrong wrong wrong.  Use pci_dev pointer for comparison.  Store that, not

bus number and devfn.


> +	nesadapter->ref_count = 1;
> +	nesadapter->timer_int_req = 0xffff0000;
> +	nesadapter->OneG_Mode = OneG_Mode;
> +
> +	/* nesadapter->tick_delta = clk_divisor; */
> +	nesadapter->hw_rev = hw_rev;
> +	nesadapter->port_count = port_count;
> +
> +	nesadapter->max_qp = max_qp;
> +	nesadapter->hte_index_mask = hte_index_mask;
> +	nesadapter->max_irrq = max_irrq;
> +	nesadapter->max_mr = max_mr;
> +	nesadapter->max_256pbl = max_256pbl - 1;
> +	nesadapter->max_4kpbl = max_4kpbl - 1;
> +	nesadapter->max_cq = max_cq;
> +	nesadapter->free_256pbl = max_256pbl - 1;
> +	nesadapter->free_4kpbl = max_4kpbl - 1;
> +	nesadapter->max_pd = num_pds;
> +	nesadapter->arp_table_size = arp_table_size;
> +	nesadapter->base_pd = 1;
> +
> +	nesadapter->device_cap_flags =
> +			IB_DEVICE_ZERO_STAG | IB_DEVICE_SEND_W_INV |
IB_DEVICE_MEM_WINDOW;
> +
> +	nesadapter->allocated_qps = (unsigned long *)&(((unsigned char
*)nesadapter)
> +			[(sizeof(struct nes_adapter)+(sizeof(unsigned
long)-1))&(~(sizeof(unsigned long)-1))]);
> +	nesadapter->allocated_cqs =
&nesadapter->allocated_qps[BITS_TO_LONGS(max_qp)];
> +	nesadapter->allocated_mrs =
&nesadapter->allocated_cqs[BITS_TO_LONGS(max_cq)];
> +	nesadapter->allocated_pds =
&nesadapter->allocated_mrs[BITS_TO_LONGS(max_mr)];
> +	nesadapter->allocated_arps =
&nesadapter->allocated_pds[BITS_TO_LONGS(num_pds)];
> +	nesadapter->qp_table = (struct nes_qp
**)(&nesadapter->allocated_arps[BITS_TO_LONGS(arp_table_size)]);
> +
> +
> +	/* mark the usual suspect QPs and CQs as in use */
> +	for (u32temp = 0; u32temp < NES_FIRST_QPN; u32temp++) {
> +		set_bit(u32temp, nesadapter->allocated_qps);
> +		set_bit(u32temp, nesadapter->allocated_cqs);
> +	}
> +
> +	u32temp = nes_read_indexed(nesdev, NES_IDX_QP_MAX_CFG_SIZES);
> +
> +	max_rq_wrs = ((u32temp >> 8) & 3);
> +	switch (max_rq_wrs) {
> +		case 0:
> +			max_rq_wrs = 4;
> +			break;
> +		case 1:
> +			max_rq_wrs = 16;
> +			break;
> +		case 2:
> +			max_rq_wrs = 32;
> +			break;
> +		case 3:
> +			max_rq_wrs = 512;
> +			break;
> +	}
> +
> +	max_sq_wrs = (u32temp & 3);
> +	switch (max_sq_wrs) {
> +		case 0:
> +			max_sq_wrs = 4;
> +			break;
> +		case 1:
> +			max_sq_wrs = 16;
> +			break;
> +		case 2:
> +			max_sq_wrs = 32;
> +			break;
> +		case 3:
> +			max_sq_wrs = 512;
> +			break;
> +	}
> +	nesadapter->max_qp_wr = min(max_rq_wrs, max_sq_wrs);
> +	dprintk("Max wqes = %u.\n", nesadapter->max_qp_wr);
> +
> +	nesadapter->max_irrq_wr = (u32temp >> 16) & 3;
> +	dprintk("%s: Max IRRQ wqes = %u.\n", __FUNCTION__,
nesadapter->max_irrq_wr);
> +
> +
> +	nesadapter->max_sge = 4;
> +	nesadapter->max_cqe = 32767;
> +
> +	if (nes_read_eeprom_values(nesdev, nesadapter)) {
> +		printk(KERN_ERR PFX "Unable to read EEPROM data.\n");
> +		kfree(nesadapter);
> +		return(NULL);
> +	}
> +
> +	u32temp = nes_read_indexed(nesdev, NES_IDX_TCP_TIMER_CONFIG);
> +	nes_write_indexed(nesdev, NES_IDX_TCP_TIMER_CONFIG,
> +			(u32temp & 0xff000000) |
(nesadapter->tcp_timer_core_clk_divisor & 0x00ffffff));
> +	dprintk("%s: TCP Timer Config0=%08x\n", __FUNCTION__,
> +			nes_read_indexed(nesdev,
NES_IDX_TCP_TIMER_CONFIG));
> +
> +	/* setup port configuration */
> +	if (nesadapter->port_count == 1) {
> +		u32temp = 0x00000000;
> +		if (nes_drv_opt & NES_DRV_OPT_DUAL_LOGICAL_PORT) {
> +			nes_write_indexed(nesdev, NES_IDX_TX_POOL_SIZE,
0x00000002);
> +		} else {
> +			nes_write_indexed(nesdev, NES_IDX_TX_POOL_SIZE,
0x00000003);
> +		}
> +	} else {
> +		if (nesadapter->port_count == 2) {
> +			u32temp = 0x00000044;
> +		} else {
> +			u32temp = 0x000000e4;
> +		}
> +		nes_write_indexed(nesdev, NES_IDX_TX_POOL_SIZE,
0x00000003);
> +	}
> +
> +	nes_write_indexed(nesdev, NES_IDX_NIC_LOGPORT_TO_PHYPORT,
u32temp);
> +	dprintk("%s: Probe time, LOG2PHY=%u\n", __FUNCTION__,
> +			nes_read_indexed(nesdev,
NES_IDX_NIC_LOGPORT_TO_PHYPORT));
> +
> +	spin_lock_init(&nesadapter->resource_lock);
> +	spin_lock_init(&nesadapter->phy_lock);
> +
> +	init_timer(&nesadapter->mh_timer);
> +	nesadapter->mh_timer.function = nes_mh_fix;
> +	nesadapter->mh_timer.expires = jiffies + (HZ/5);  /* 1 second */
> +	nesadapter->mh_timer.data = (unsigned long)nesdev;
> +	add_timer(&nesadapter->mh_timer);
> +
> +	INIT_LIST_HEAD(&nesadapter->nesvnic_list[0]);
> +	INIT_LIST_HEAD(&nesadapter->nesvnic_list[1]);
> +	INIT_LIST_HEAD(&nesadapter->nesvnic_list[2]);
> +	INIT_LIST_HEAD(&nesadapter->nesvnic_list[3]);
> +
> +	list_add_tail(&nesadapter->list, &nes_adapter_list);
> +
> +	return(nesadapter);
> +}
> +
> +
> +/**
> + * nes_reset_adapter_ne020
> + */
> +unsigned int nes_reset_adapter_ne020(struct nes_device *nesdev, u8
*OneG_Mode)
> +{
> +	u32 port_count;
> +	u32 u32temp;
> +	u32 i;
> +
> +	u32temp = nes_read32(nesdev->regs+NES_SOFTWARE_RESET);
> +	port_count = ((u32temp & 0x00000300) >> 8) + 1;
> +	/* TODO: assuming that both SERDES are set the same for now */
> +	*OneG_Mode = (u32temp & 0x00003c00) ? 0 : 1;
> +	dprintk("%s: Initial Software Reset = 0x%08X, port_count=%u\n",
__FUNCTION__, u32temp, port_count);
> +	if (*OneG_Mode) {
> +		dprintk("%s: Running in 1G mode.\n", __FUNCTION__);
> +	}
> +	u32temp &= 0xff00ffc0;
> +	switch (port_count) {
> +		case 1:
> +			u32temp |= 0x00ee0000;
> +			break;
> +		case 2:
> +			u32temp |= 0x00cc0000;
> +			break;
> +		case 4:
> +			u32temp |= 0x00000000;
> +			break;
> +		default:
> +			return (0);
> +			break;
> +	}
> +
> +	/* check and do full reset if needed */
> +	if (nes_read_indexed(nesdev,
NES_IDX_QP_CONTROL+(PCI_FUNC(nesdev->pcidev->devfn)*8))) {
> +		dprintk("Issuing Full Soft reset = 0x%08X\n", u32temp |
0xd);
> +		nes_write32(nesdev->regs+NES_SOFTWARE_RESET, u32temp |
0xd);
> +
> +		i = 0;
> +		while (((nes_read32(nesdev->regs+NES_SOFTWARE_RESET) &
0x00000040) == 0) && i++ < 10000) {
> +			mdelay(1);
> +		}
> +		if (i >= 10000) {
> +			dprintk("Did not see full soft reset done.\n");
> +			return (0);
> +		}
> +	}
> +
> +	/* port reset */
> +	switch (port_count) {
> +		case 1:
> +			u32temp |= 0x00ee0010;
> +			break;
> +		case 2:
> +			u32temp |= 0x00cc0030;
> +			break;
> +		case 4:
> +			u32temp |= 0x00000030;
> +			break;
> +	}
> +
> +	dprintk("Issuing Port Soft reset = 0x%08X\n", u32temp | 0xd);
> +	nes_write32(nesdev->regs+NES_SOFTWARE_RESET, u32temp | 0xd);
> +
> +	i = 0;
> +	while (((nes_read32(nesdev->regs+NES_SOFTWARE_RESET) &
0x00000040) == 0) && i++ < 10000) {
> +		mdelay(1);
> +	}
> +	if (i >= 10000) {
> +		dprintk("Did not see port soft reset done.\n");
> +		return (0);
> +	}
> +
> +	/* serdes 0 */
> +	i = 0;
> +	while (((u32temp = (nes_read_indexed(nesdev,
NES_IDX_ETH_SERDES_COMMON_STATUS0)
> +			& 0x0000000f)) != 0x0000000f) && i++ < 5000) {
> +		mdelay(1);

all these delays should be msleep()


> +	if (i >= 5000) {
> +		dprintk("Serdes 0 not ready, status=%x\n", u32temp);
> +		return (0);
> +	}
> +
> +	/* serdes 1 */
> +	if (port_count > 1) {
> +		i = 0;
> +		while (((u32temp = (nes_read_indexed(nesdev,
NES_IDX_ETH_SERDES_COMMON_STATUS1)
> +				& 0x0000000f)) != 0x0000000f) && i++ <
5000) {
> +			mdelay(1);
> +		}
> +		if (i >= 5000) {
> +			dprintk("Serdes 1 not ready, status=%x\n",
u32temp);
> +			return (0);
> +		}
> +	}
> +
> +	i = 0;
> +	while ((nes_read_indexed(nesdev, NES_IDX_INT_CPU_STATUS) !=
0x80) && i++ < 10000) {
> +		mdelay(1);
> +	}
> +	dprintk("%s:%u CPU_STATUS loops=%u\n", __FUNCTION__, __LINE__,
i);
> +	if (i >= 10000) {
> +		printk(KERN_ERR PFX "Internal CPU not ready, status =
%02X\n",
> +				nes_read_indexed(nesdev,
NES_IDX_INT_CPU_STATUS));
> +		return (0);
> +	}
> +
> +	return (port_count);
> +}
> +
> +
> +/**
> + * nes_init_serdes
> + */
> +int nes_init_serdes(struct nes_device *nesdev, u8 port_count)
> +{
> +	int i;
> +	u32 u32temp;
> +
> +	/* init serdes 0 */
> +	nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_COMMON_CONTROL0,
0x00000008);
> +	i = 0;
> +	while (((u32temp = (nes_read_indexed(nesdev,
NES_IDX_ETH_SERDES_COMMON_STATUS0)
> +			& 0x0000000f)) != 0x0000000f) && i++ < 5000) {
> +		mdelay(1);
> +	}
> +	if (i >= 5000) {
> +		dprintk("Init: serdes 0 not ready, status=%x\n",
u32temp);
> +		return (1);
> +	}
> +	nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_TX_EMP0,
0x000bdef7);
> +	nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_TX_DRIVE0,
0x9ce73000);
> +	nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_RX_MODE0,
0x0ff00000);
> +	nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_RX_SIGDET0,
0x00000000);
> +	nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_BYPASS0,
0x00000000);
> +	nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_LOOPBACK_CONTROL0,
0x00000000);
> +	nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_RX_EQ_CONTROL0,
0xf0002222);
> +	nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_CDR_CONTROL0,
0x000000ff);
> +
> +	if (port_count > 1) {
> +		/* init serdes 1 */
> +		nes_write_indexed(nesdev,
NES_IDX_ETH_SERDES_COMMON_CONTROL1, 0x00000048);
> +		i = 0;
> +		while (((u32temp = (nes_read_indexed(nesdev,
NES_IDX_ETH_SERDES_COMMON_STATUS1) & 0x0000000f)) != 0x0000000f) &&
> +			   (i++ < 5000)) {
> +			mdelay(1);
> +		}
> +		if (i >= 5000) {
> +			printk("%s: Init: serdes 1 not ready,
status=%x\n", __FUNCTION__, u32temp);
> +			/* return 1; */
> +		}
> +		nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_TX_EMP1,
0x000bdef7);
> +		nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_TX_DRIVE1,
0x9ce73000);
> +		nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_RX_MODE1,
0x0ff00000);
> +		nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_RX_SIGDET1,
0x00000000);
> +		nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_BYPASS1,
0x00000000);
> +		nes_write_indexed(nesdev,
NES_IDX_ETH_SERDES_LOOPBACK_CONTROL1, 0x00000000);
> +		nes_write_indexed(nesdev,
NES_IDX_ETH_SERDES_RX_EQ_CONTROL1, 0xf0002222);
> +		nes_write_indexed(nesdev,
NES_IDX_ETH_SERDES_CDR_CONTROL1, 0x000000ff);
> +	}
> +	return (0);
> +}
> +
> +
> +/**
> + * nes_init_csr_ne020
> + * Initialize registers for ne020 hardware
> + */
> +void nes_init_csr_ne020(struct nes_device *nesdev, u8 hw_rev, u8
port_count)
> +{
> +
> +	nes_write_indexed(nesdev, 0x000001E4, 0x00000007);	
> +	/* nes_write_indexed(nesdev, 0x000001E8, 0x000208C4); */	
> +	nes_write_indexed(nesdev, 0x000001E8, 0x00020844);	
> +	nes_write_indexed(nesdev, 0x000001D8, 0x00048002);	
> +	/* nes_write_indexed(nesdev, 0x000001D8, 0x0004B002); */  
> +	nes_write_indexed(nesdev, 0x000001FC, 0x00050005);	
> +	nes_write_indexed(nesdev, 0x00000600, 0x55555555);	
> +	nes_write_indexed(nesdev, 0x00000604, 0x55555555);	
> +
> +	/* TODO: move these MAC register settings to NIC bringup */
> +	nes_write_indexed(nesdev, 0x00002000, 0x00000001);	
> +	nes_write_indexed(nesdev, 0x00002004, 0x00000001);	
> +	nes_write_indexed(nesdev, 0x00002008, 0x0000FFFF);	
> +	nes_write_indexed(nesdev, 0x0000200C, 0x00000001);	
> +	nes_write_indexed(nesdev, 0x00002010, 0x000003c1);	
> +	nes_write_indexed(nesdev, 0x0000201C, 0x75345678);	
> +	if (port_count > 1) {
> +		nes_write_indexed(nesdev, 0x00002200, 0x00000001);	
> +		nes_write_indexed(nesdev, 0x00002204, 0x00000001);	
> +		nes_write_indexed(nesdev, 0x00002208, 0x0000FFFF);	
> +		nes_write_indexed(nesdev, 0x0000220C, 0x00000001);	
> +		nes_write_indexed(nesdev, 0x00002210, 0x000003c1);	
> +		nes_write_indexed(nesdev, 0x0000221C, 0x75345678);	
> +	}
> +	if (port_count > 2) {
> +		nes_write_indexed(nesdev, 0x00002400, 0x00000001);	
> +		nes_write_indexed(nesdev, 0x00002404, 0x00000001);	
> +		nes_write_indexed(nesdev, 0x00002408, 0x0000FFFF);	
> +		nes_write_indexed(nesdev, 0x0000240C, 0x00000001);	
> +		nes_write_indexed(nesdev, 0x00002410, 0x000003c1);	
> +		nes_write_indexed(nesdev, 0x0000241C, 0x75345678);	
> +
> +		nes_write_indexed(nesdev, 0x00002600, 0x00000001);	
> +		nes_write_indexed(nesdev, 0x00002604, 0x00000001);	
> +		nes_write_indexed(nesdev, 0x00002608, 0x0000FFFF);	
> +		nes_write_indexed(nesdev, 0x0000260C, 0x00000001);	
> +		nes_write_indexed(nesdev, 0x00002610, 0x000003c1);	
> +		nes_write_indexed(nesdev, 0x0000261C, 0x75345678);	
> +	}
> +
> +	nes_write_indexed(nesdev, 0x00005000, 0x00018000);	
> +	/* nes_write_indexed(nesdev, 0x00005000, 0x00010000); */  
> +	nes_write_indexed(nesdev, 0x00005004, 0x00020001);	
> +	nes_write_indexed(nesdev, 0x00005008, 0x1F1F1F1F);	
> +	nes_write_indexed(nesdev, 0x00005010, 0x1F1F1F1F);	
> +	nes_write_indexed(nesdev, 0x00005018, 0x1F1F1F1F);	
> +	nes_write_indexed(nesdev, 0x00005020, 0x1F1F1F1F);	
> +	nes_write_indexed(nesdev, 0x00006090, 0xFFFFFFFF);	
> +
> +	/* TODO: move this to code, get from EEPROM */
> +	nes_write_indexed(nesdev, 0x00000900, 0x20000001);	
> +	nes_write_indexed(nesdev, 0x000060C0, 0x0000028e);	
> +	nes_write_indexed(nesdev, 0x000060C8, 0x00000020);	
> +
> +	nes_write_indexed(nesdev, 0x000001EC, 0x5b2625a0);	
> +	/* nes_write_indexed(nesdev, 0x000001EC, 0x5f2625a0); */  
> +	
> +}
> +
> +
> +/**
> + * nes_destroy_adapter - destroy the adapter structure
> + */
> +void nes_destroy_adapter(struct nes_adapter *nesadapter)
> +{
> +	struct nes_adapter *tmp_adapter;
> +
> +	list_for_each_entry(tmp_adapter, &nes_adapter_list, list) {
> +		dprintk("%s: Nes Adapter list entry = 0x%p.\n",
__FUNCTION__, tmp_adapter);
> +	}
> +
> +	nesadapter->ref_count--;
> +	if (!nesadapter->ref_count) {
> +			del_timer(&nesadapter->mh_timer);
> +
> +		dprintk("nes_destroy_adapter: Deleting adapter from
adapter list.\n");
> +		list_del(&nesadapter->list);
> +		dprintk("nes_destroy_adapter: Freeing adapter
structure.\n");
> +		kfree(nesadapter);
> +	}
> +	dprintk("%s: Done.\n", __FUNCTION__);
> +}
> +
> +
> +/**
> + * nes_init_cqp
> + */
> +int nes_init_cqp(struct nes_device *nesdev)
> +{
> +	struct nes_adapter *nesadapter = nesdev->nesadapter;
> +	struct nes_hw_cqp_qp_context *cqp_qp_context;
> +	struct nes_hw_cqp_wqe *cqp_wqe;
> +	struct nes_hw_ceq *ceq;
> +	struct nes_hw_ceq *nic_ceq;
> +	struct nes_hw_aeq *aeq;
> +	void *vmem;
> +	dma_addr_t pmem;
> +	u32 count=0;
> +	u32 cqp_head;
> +	u64 u64temp;
> +	u32 u32temp;
> +
> +#define NES_NIC_CEQ_SIZE 8
> +/* NICs will be on a separate CQ */
> +#define NES_CCEQ_SIZE ((nesadapter->max_cq / nesadapter->port_count)
- 32)
> +
> +	/* allocate CQP memory */
> +	/* Need to add max_cq to the aeq size once cq overflow checking
is added back */
> +	/* SQ is 512 byte aligned, others are 256 byte aligned */
> +	nesdev->cqp_mem_size = 512 +
> +			(sizeof(struct nes_hw_cqp_wqe) *
NES_CQP_SQ_SIZE) +
> +			(sizeof(struct nes_hw_cqe) * NES_CCQ_SIZE) +
> +			max(((u32)sizeof(struct nes_hw_ceqe) *
NES_CCEQ_SIZE), (u32)256) +
> +			max(((u32)sizeof(struct nes_hw_ceqe) *
NES_NIC_CEQ_SIZE), (u32)256) +
> +			(sizeof(struct nes_hw_aeqe) *
nesadapter->max_qp) +
> +			sizeof(struct nes_hw_cqp_qp_context);
> +
> +	nesdev->cqp_vbase = pci_alloc_consistent(nesdev->pcidev,
nesdev->cqp_mem_size,
> +			&nesdev->cqp_pbase);
> +	if (!nesdev->cqp_vbase) {
> +		dprintk(KERN_ERR PFX "Unable to allocate memory for host
descriptor rings\n");
> +		return(-ENOMEM);
> +	}
> +	memset(nesdev->cqp_vbase, 0, nesdev->cqp_mem_size);
> +
> +	/* Allocate a twice the number of CQP requests as the SQ size */
> +	nesdev->nes_cqp_requests = kmalloc(sizeof(struct
nes_cqp_request) *
> +			2 * NES_CQP_SQ_SIZE, GFP_KERNEL);

kzalloc


> +	if (NULL == nesdev->nes_cqp_requests) {

kernel standard:  variable comes first, then comparison constant

or just 'if (!foo)'


> +		dprintk(KERN_ERR PFX "Unable to allocate memory CQP
request entries.\n");
> +		pci_free_consistent(nesdev->pcidev,
nesdev->cqp_mem_size, nesdev->cqp.sq_vbase,
> +				nesdev->cqp.sq_pbase);
> +		return(-ENOMEM);
> +	}
> +	memset(nesdev->nes_cqp_requests, 0, sizeof(struct
nes_cqp_request) *
> +			2 * NES_CQP_SQ_SIZE);
> +	dprintk("Allocated CQP structures at %p (phys = %016lX), size =
%u.\n",
> +			nesdev->cqp_vbase, (unsigned
long)nesdev->cqp_pbase, nesdev->cqp_mem_size);
> +
> +	spin_lock_init(&nesdev->cqp.lock);
> +	init_waitqueue_head(&nesdev->cqp.waitq);
> +
> +	/* Setup Various Structures */
> +	vmem = (void *)(((unsigned long long)nesdev->cqp_vbase + (512 -
1)) &
> +			~(unsigned long long)(512 - 1));
> +	pmem = (dma_addr_t)(((unsigned long long)nesdev->cqp_pbase +
(512 - 1)) &
> +			~(unsigned long long)(512 - 1));
> +
> +	nesdev->cqp.sq_vbase = vmem;
> +	nesdev->cqp.sq_pbase = pmem;
> +	nesdev->cqp.sq_size = NES_CQP_SQ_SIZE;
> +	nesdev->cqp.sq_head = 0;
> +	nesdev->cqp.sq_tail = 0;
> +	nesdev->cqp.qp_id = PCI_FUNC(nesdev->pcidev->devfn);

kill


> +	dprintk("CQP at %p (phys = %016lX).\n",
> +			nesdev->cqp.sq_vbase,	(unsigned
long)nesdev->cqp.sq_pbase);
> +
> +	vmem += (sizeof(struct nes_hw_cqp_wqe) * nesdev->cqp.sq_size);
> +	pmem += (sizeof(struct nes_hw_cqp_wqe) * nesdev->cqp.sq_size);
> +
> +	nesdev->ccq.cq_vbase = vmem;
> +	nesdev->ccq.cq_pbase = pmem;
> +	nesdev->ccq.cq_size = NES_CCQ_SIZE;
> +	nesdev->ccq.cq_head = 0;
> +	nesdev->ccq.ce_handler = nes_cqp_ce_handler;
> +	nesdev->ccq.cq_number = PCI_FUNC(nesdev->pcidev->devfn);

kill


> +	dprintk("CCQ at %p (phys = %016lX).\n",
> +			nesdev->ccq.cq_vbase, (unsigned
long)nesdev->ccq.cq_pbase);
> +
> +	vmem += (sizeof(struct nes_hw_cqe) * nesdev->ccq.cq_size);
> +	pmem += (sizeof(struct nes_hw_cqe) * nesdev->ccq.cq_size);
> +
> +	nesdev->ceq_index = PCI_FUNC(nesdev->pcidev->devfn);
> +	ceq = &nesadapter->ceq[nesdev->ceq_index];
> +	ceq->ceq_vbase = vmem;
> +	ceq->ceq_pbase = pmem;
> +	ceq->ceq_size = NES_CCEQ_SIZE;
> +	ceq->ceq_head = 0;
> +	dprintk("CEQ at %p (phys = %016lX).\n",
> +			ceq->ceq_vbase, (unsigned long)ceq->ceq_pbase);
> +
> +	vmem += max(((u32)sizeof(struct nes_hw_ceqe) * ceq->ceq_size),
(u32)256);
> +	pmem += max(((u32)sizeof(struct nes_hw_ceqe) * ceq->ceq_size),
(u32)256);
> +
> +	nesdev->nic_ceq_index = PCI_FUNC(nesdev->pcidev->devfn) + 8;
> +	nic_ceq = &nesadapter->ceq[nesdev->nic_ceq_index];
> +	nic_ceq->ceq_vbase = vmem;
> +	nic_ceq->ceq_pbase = pmem;
> +	nic_ceq->ceq_size = NES_NIC_CEQ_SIZE;
> +	nic_ceq->ceq_head = 0;
> +	dprintk("NIC CEQ at %p (phys = %016lX).\n",
> +			nic_ceq->ceq_vbase, (unsigned
long)nic_ceq->ceq_pbase);
> +
> +	vmem += max(((u32)sizeof(struct nes_hw_ceqe) *
nic_ceq->ceq_size), (u32)256);
> +	pmem += max(((u32)sizeof(struct nes_hw_ceqe) *
nic_ceq->ceq_size), (u32)256);
> +
> +	aeq = &nesadapter->aeq[PCI_FUNC(nesdev->pcidev->devfn)];
> +	aeq->aeq_vbase = vmem;
> +	aeq->aeq_pbase = pmem;
> +	aeq->aeq_size = nesadapter->max_qp;
> +	aeq->aeq_head = 0;
> +	dprintk("AEQ  at %p (phys = %016lX).\n",
> +			aeq->aeq_vbase, (unsigned long)aeq->aeq_pbase);
> +
> +	/* Setup QP Context */
> +	vmem += (sizeof(struct nes_hw_aeqe) * aeq->aeq_size);
> +	pmem += (sizeof(struct nes_hw_aeqe) * aeq->aeq_size);
> +
> +	cqp_qp_context = vmem;
> +	cqp_qp_context->context_words[0] =
(PCI_FUNC(nesdev->pcidev->devfn) << 12) + (2 << 10);
> +	cqp_qp_context->context_words[1] = 0;
> +	cqp_qp_context->context_words[2] = (u32)nesdev->cqp.sq_pbase;
> +	cqp_qp_context->context_words[3] = ((u64)nesdev->cqp.sq_pbase)
>> 32;
> +
> +	dprintk("Address of CQP Context = %p.\n", cqp_qp_context);
> +	for (count=0;count<4 ; count++) {
> +		dprintk("CQP Context, Line %u = %08X.\n",
> +				count,
cqp_qp_context->context_words[count]);
> +	}
> +
> +	/* Write the address to Create CQP */
> +	if ((sizeof(dma_addr_t) > 4)) {
> +		nes_write_indexed(nesdev,
> +				NES_IDX_CREATE_CQP_HIGH +
(PCI_FUNC(nesdev->pcidev->devfn) * 8),
> +				((u64)pmem) >> 32);
> +	} else {
> +		nes_write_indexed(nesdev,
> +				NES_IDX_CREATE_CQP_HIGH +
(PCI_FUNC(nesdev->pcidev->devfn) * 8), 0);
> +	}
> +	nes_write_indexed(nesdev,
> +			NES_IDX_CREATE_CQP_LOW +
(PCI_FUNC(nesdev->pcidev->devfn) * 8),
> +			(u32)pmem);
> +
> +	dprintk("Address of CQP SQ = %p.\n", nesdev->cqp.sq_vbase);
> +
> +	INIT_LIST_HEAD(&nesdev->cqp_avail_reqs);
> +	INIT_LIST_HEAD(&nesdev->cqp_pending_reqs);
> +
> +	for (count=0; count<2*NES_CQP_SQ_SIZE; count++) {
> +
init_waitqueue_head(&nesdev->nes_cqp_requests[count].waitq);
> +		list_add_tail(&nesdev->nes_cqp_requests[count].list,
&nesdev->cqp_avail_reqs);
> +		/* dprintk("Adding cqp request %p to the available list
\n",
> +				&nesdev->nes_cqp_requests[count]); */
> +	}
> +
> +	/* Write Create CCQ WQE */
> +	cqp_head = nesdev->cqp.sq_head++;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_CREATE_CQ | NES_CQP_CQ_CEQ_VALID |
> +			NES_CQP_CQ_CHK_OVERFLOW |
((u32)nesdev->ccq.cq_size << 16));
> +	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
cpu_to_le32(nesdev->ccq.cq_number |
> +			((u32)nesdev->ceq_index<<16));
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
> +	*((struct nes_hw_cqp
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) = &nesdev->cqp;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = 0;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = 0;
> +	u64temp = (u64)nesdev->ccq.cq_pbase;
> +	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_PBL_LOW_IDX] =
cpu_to_le32((u32)u64temp);
> +	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_PBL_HIGH_IDX] =
cpu_to_le32((u32)(u64temp >> 32));
> +	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_HIGH_IDX] = 0;
> +	/* TODO: the following 2 lines likely have endian issues */
> +	*((struct nes_hw_cq
**)&cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX]) =
&nesdev->ccq;
> +	*((u64 *)&cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX])
>>= 1;
> +	dprintk("%s: CQ%u context = 0x%08X:0x%08X.\n", __FUNCTION__,
nesdev->ccq.cq_number,
> +
cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_HIGH_IDX],
> +
cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX]);
> +
> +	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_DOORBELL_INDEX_HIGH_IDX] = 0;
> +
> +	/* Write Create CEQ WQE */
> +	cqp_head = nesdev->cqp.sq_head++;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_CREATE_CEQ +
> +			((u32)nesdev->ceq_index << 8));
> +	cqp_wqe->wqe_words[NES_CQP_CEQ_WQE_ELEMENT_COUNT_IDX] =
cpu_to_le32(ceq->ceq_size);
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
> +	*((struct nes_hw_cqp
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) = &nesdev->cqp;
> +	*((struct nes_cqp_request
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX]) = NULL;
> +	u64temp = (u64)ceq->ceq_pbase;
> +	cqp_wqe->wqe_words[NES_CQP_CEQ_WQE_PBL_LOW_IDX] =
cpu_to_le32((u32)u64temp);
> +	cqp_wqe->wqe_words[NES_CQP_CEQ_WQE_PBL_HIGH_IDX] =
cpu_to_le32((u32)(u64temp >> 32));
> +
> +	/* Write Create AEQ WQE */
> +	cqp_head = nesdev->cqp.sq_head++;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_CREATE_AEQ +
> +			((u32)PCI_FUNC(nesdev->pcidev->devfn) << 8));
> +	cqp_wqe->wqe_words[NES_CQP_AEQ_WQE_ELEMENT_COUNT_IDX] =
cpu_to_le32(aeq->aeq_size);
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
> +	*((struct nes_hw_cqp
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) = &nesdev->cqp;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = 0;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = 0;
> +	u64temp = (u64)aeq->aeq_pbase;
> +	cqp_wqe->wqe_words[NES_CQP_AEQ_WQE_PBL_LOW_IDX] =
cpu_to_le32((u32)u64temp);
> +	cqp_wqe->wqe_words[NES_CQP_AEQ_WQE_PBL_HIGH_IDX] =
cpu_to_le32((u32)(u64temp >> 32));
> +
> +	/* Write Create CEQ WQE */
> +	cqp_head = nesdev->cqp.sq_head++;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_CREATE_CEQ +
> +			((u32)nesdev->nic_ceq_index << 8));
> +	cqp_wqe->wqe_words[NES_CQP_CEQ_WQE_ELEMENT_COUNT_IDX] =
cpu_to_le32(nic_ceq->ceq_size);
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
> +	*((struct nes_hw_cqp
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) = &nesdev->cqp;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = 0;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = 0;
> +	u64temp = (u64)nic_ceq->ceq_pbase;
> +	cqp_wqe->wqe_words[NES_CQP_CEQ_WQE_PBL_LOW_IDX] =
cpu_to_le32((u32)u64temp);
> +	cqp_wqe->wqe_words[NES_CQP_CEQ_WQE_PBL_HIGH_IDX] =
cpu_to_le32((u32)(u64temp >> 32));

remove all these pointless u32 casts


> +	/* Poll until CCQP done */
> +	count = 0;
> +	do {
> +		if (count++ > 1000) {
> +			printk(KERN_ERR PFX "Error creating CQP\n");
> +			pci_free_consistent(nesdev->pcidev,
nesdev->cqp_mem_size,
> +					nesdev->cqp_vbase,
nesdev->cqp_pbase);

consolidate duplicated error handling code


> +			return(-1);
> +		}
> +		udelay(10);
> +	} while (!(nes_read_indexed(nesdev,
> +			NES_IDX_QP_CONTROL +
(PCI_FUNC(nesdev->pcidev->devfn) * 8)) & (1 << 8)));
> +
> +	dprintk("CQP Status = 0x%08X\n", nes_read_indexed(nesdev,
> +
NES_IDX_QP_CONTROL+(PCI_FUNC(nesdev->pcidev->devfn)*8)));
> +
> +	u32temp = 0x04800000;
> +	nes_write32(nesdev->regs+NES_WQE_ALLOC, u32temp |
nesdev->cqp.qp_id);
> +
> +	/* wait for the CCQ, CEQ, and AEQ to get created */
> +	count = 0;
> +	do {
> +		if (count++ > 1000) {
> +			printk(KERN_ERR PFX "Error creating CCQ, CEQ,
and AEQ\n");
> +			pci_free_consistent(nesdev->pcidev,
nesdev->cqp_mem_size,
> +					nesdev->cqp_vbase,
nesdev->cqp_pbase);
> +			return(-1);
> +		}
> +		udelay(10);
> +	} while (((nes_read_indexed(nesdev,
> +			NES_IDX_QP_CONTROL +
(PCI_FUNC(nesdev->pcidev->devfn)*8)) & (15<<8)) != (15<<8)));
> +
> +	/* dump the QP status value */
> +	dprintk("QP Status = 0x%08X\n", nes_read_indexed(nesdev,
> +
NES_IDX_QP_CONTROL+(PCI_FUNC(nesdev->pcidev->devfn)*8)));
> +
> +	nesdev->cqp.sq_tail++;
> +
> +	return (0);
> +}
> +
> +
> +/**
> + * nes_destroy_cqp
> + */
> +int nes_destroy_cqp(struct nes_device *nesdev)
> +{
> +	struct nes_hw_cqp_wqe *cqp_wqe;
> +	u32 count=0;
> +	u32 cqp_head;
> +	unsigned long flags;
> +
> +	dprintk("Waiting for CQP work to complete.\n");
> +	do {
> +		if (count++ > 1000)	break;
> +		udelay(10);
> +	} while (!(nesdev->cqp.sq_head == nesdev->cqp.sq_tail));
> +
> +	/* Reset CCQ */
> +	nes_write32(nesdev->regs+NES_CQE_ALLOC, NES_CQE_ALLOC_RESET |
> +			nesdev->ccq.cq_number);
> +
> +	/* Disable device interrupts */
> +	nes_write32(nesdev->regs+NES_INT_MASK, 0x7fffffff);
> +	/* Destroy the AEQ */
> +	spin_lock_irqsave(&nesdev->cqp.lock, flags);
> +	cqp_head = nesdev->cqp.sq_head++;
> +	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_DESTROY_AEQ |
> +			((u32)PCI_FUNC(nesdev->pcidev->devfn)<<8));
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
> +	/* Destroy the NIC CEQ */
> +	cqp_head = nesdev->cqp.sq_head++;
> +	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_DESTROY_CEQ |
> +			((u32)nesdev->nic_ceq_index<<8));
> +	/* Destroy the CEQ */
> +	cqp_head = nesdev->cqp.sq_head++;
> +	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_DESTROY_CEQ |
> +			(nesdev->ceq_index<<8));
> +	/* Destroy the CCQ */
> +	cqp_head = nesdev->cqp.sq_head++;
> +	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_DESTROY_CQ);
> +	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] = cpu_to_le32(
nesdev->ccq.cq_number ||
> +			((u32)nesdev->ceq_index<<16));
> +	/* Destroy CQP */
> +	cqp_head = nesdev->cqp.sq_head++;
> +	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_DESTROY_QP |
> +			NES_CQP_QP_TYPE_CQP);
> +	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
cpu_to_le32(nesdev->cqp.qp_id);
> +
> +	barrier();

insufficient


> +	/* Ring doorbell (4 WQEs) */
> +	nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x05800000 |
nesdev->cqp.qp_id);
> +
> +	/* Wait for the destroy to complete */
> +	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +
> +	/* wait for the CCQ, CEQ, and AEQ to get destroyed */
> +	count = 0;
> +	do {
> +		if (count++ > 1000) {
> +			printk(KERN_ERR PFX "Function%d: Error
destroying CCQ, CEQ, and AEQ\n",
> +
PCI_FUNC(nesdev->pcidev->devfn));
> +			break;
> +		}
> +		udelay(10);
> +	} while (((nes_read_indexed(nesdev,
> +			NES_IDX_QP_CONTROL +
(PCI_FUNC(nesdev->pcidev->devfn)*8)) & (15<<8)) != 0));
> +
> +	/* dump the QP status value */
> +	dprintk("Function%d: QP Status = 0x%08X\n",
> +			PCI_FUNC(nesdev->pcidev->devfn),
> +			nes_read_indexed(nesdev,
> +
NES_IDX_QP_CONTROL+(PCI_FUNC(nesdev->pcidev->devfn)*8)));
> +
> +	kfree(nesdev->nes_cqp_requests);
> +
> +	/* Free the control structures */
> +	pci_free_consistent(nesdev->pcidev, nesdev->cqp_mem_size,
nesdev->cqp.sq_vbase,
> +			nesdev->cqp.sq_pbase);
> +
> +	return (0);
> +}
> +
> +
> +/**
> + * nes_init_phy
> + */
> +int nes_init_phy(struct nes_device *nesdev)
> +{
> +	struct nes_adapter *nesadapter = nesdev->nesadapter;
> +	u32 counter = 0;
> +	u32 mac_index = nesdev->mac_index;
> +	u16 phy_data;
> +
> +	if (nesadapter->OneG_Mode) {
> +		dprintk("1G PHY, mac_index = %d.\n", mac_index);
> +		nes_read_1G_phy_reg(nesdev, 1,
nesadapter->phy_index[mac_index], &phy_data);
> +		dprintk("Phy data from register 1 phy address %u =
0x%X.\n",
> +				nesadapter->phy_index[mac_index],
phy_data);
> +
> +		nes_write_1G_phy_reg(nesdev, 23,
nesadapter->phy_index[mac_index],  0xb000);
> +
> +		/* Reset the PHY */
> +		nes_write_1G_phy_reg(nesdev, 0,
nesadapter->phy_index[mac_index], 0x8000);
> +		udelay(100);
> +		counter = 0;
> +		do {
> +			nes_read_1G_phy_reg(nesdev, 0,
nesadapter->phy_index[mac_index], &phy_data);
> +			dprintk("Phy data from register 0 = 0x%X.\n",
phy_data);
> +			if (counter++ > 100) break;
> +		} while (phy_data & 0x8000);
> +
> +		/* Setting no phy loopback */
> +		phy_data &= 0xbfff;
> +		phy_data |= 0x1140;
> +		nes_write_1G_phy_reg(nesdev, 0,
nesadapter->phy_index[mac_index],  phy_data);
> +		nes_read_1G_phy_reg(nesdev, 0,
nesadapter->phy_index[mac_index], &phy_data);
> +		dprintk("Phy data from register 0 = 0x%X.\n", phy_data);
> +
> +		nes_read_1G_phy_reg(nesdev, 0x17,
nesadapter->phy_index[mac_index], &phy_data);
> +		dprintk("Phy data from register 0x17 = 0x%X.\n",
phy_data);
> +
> +		nes_read_1G_phy_reg(nesdev, 0x1e,
nesadapter->phy_index[mac_index], &phy_data);
> +		dprintk("Phy data from register 0x1e = 0x%X.\n",
phy_data);
> +
> +		/* Setting the interrupt mask */
> +		nes_read_1G_phy_reg(nesdev, 0x19,
nesadapter->phy_index[mac_index], &phy_data);
> +		dprintk("Phy data from register 0x19 = 0x%X.\n",
phy_data);
> +		nes_write_1G_phy_reg(nesdev, 0x19,
nesadapter->phy_index[mac_index], 0xffee);
> +
> +		nes_read_1G_phy_reg(nesdev, 0x19,
nesadapter->phy_index[mac_index], &phy_data);
> +		dprintk("Phy data from register 0x19 = 0x%X.\n",
phy_data);
> +
> +		/* turning on flow control */
> +		nes_read_1G_phy_reg(nesdev, 4,
nesadapter->phy_index[mac_index], &phy_data);
> +		dprintk("Phy data from register 0x4 = 0x%X.\n",
phy_data);
> +		nes_write_1G_phy_reg(nesdev, 4,
nesadapter->phy_index[mac_index],
> +				(phy_data & ~(0x03E0)) | 0xc00);
> +		/* nes_write_1G_phy_reg(nesdev, 4,
nesadapter->phy_index[mac_index],
> +				phy_data | 0xc00); */
> +		nes_read_1G_phy_reg(nesdev, 4,
nesadapter->phy_index[mac_index], &phy_data);
> +		dprintk("Phy data from register 0x4 = 0x%X.\n",
phy_data);
> +
> +		nes_read_1G_phy_reg(nesdev, 9,
nesadapter->phy_index[mac_index], &phy_data);
> +		dprintk("Phy data from register 0x9 = 0x%X.\n",
phy_data);
> +		/* Clear Half duplex */
> +		nes_write_1G_phy_reg(nesdev, 9,
nesadapter->phy_index[mac_index],
> +				phy_data & ~(0x0100));
> +		nes_read_1G_phy_reg(nesdev, 9,
nesadapter->phy_index[mac_index], &phy_data);
> +		dprintk("Phy data from register 0x9 = 0x%X.\n",
phy_data);
> +
> +		nes_read_1G_phy_reg(nesdev, 0,
nesadapter->phy_index[mac_index], &phy_data);
> +		nes_write_1G_phy_reg(nesdev, 0,
nesadapter->phy_index[mac_index], phy_data | 0x0300);

move all code down one indentation level.  adjust test at top of 
function to return accordingly, or use a goto

I stopped reviewing here.  please do all style changes, so we can review

this driver in depth.


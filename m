From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Tue, 07 Aug 2007 21:13:30 -0400
Message-ID: <46B918BA.2020400@garzik.org>
References: <200708080045.l780jE9E004667@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: ggrundstrom@neteffect.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48676 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933795AbXHHBNg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 21:13:36 -0400
In-Reply-To: <200708080045.l780jE9E004667@neteffect.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ggrundstrom@neteffect.com wrote:
> +#ifndef PCI_VENDOR_ID_NETEFFECT	/* not in pci.ids yet */
> +#define PCI_VENDOR_ID_NETEFFECT 0x1678

this should be part of your patch


> +#define PCI_DEVICE_ID_NETEFFECT_NE020 0x0100

no need for a #define at all, just use the hex number if the ONLY place 
its used is in the pci_device_id table.

Doing so avoids patch hell that is pci_ids.h, avoids adding a constant 
for a single-use hex number that's arbitrary anyway


> +#define BAR_0                	0
> +#define BAR_1                	2

delete


> +#define RX_BUF_SIZE         	(1536 + 8)

this number was blindly copied from another driver, right?


> +#ifdef NES_DEBUG
> +#define assert(expr)												\
> +if(!(expr)) {														\
> +	printk(KERN_ERR PFX "Assertion failed! %s, %s, %s, line %d\n",	\
> +		   #expr, __FILE__, __FUNCTION__, __LINE__);				\
> +}
> +#ifndef dprintk
> +#define dprintk(fmt, args...) do { printk(KERN_ERR PFX fmt, ##args); } while (0)
> +#endif

look around, we already have debug macros.  you're probably copying from 
an older net driver that doesn't yet use the new stuff


> +#define NES_EVENT_TIMEOUT	1200000
> +/* #define NES_EVENT_TIMEOUT	1200 */
> +#else
> +#define assert(expr)          do {} while (0)
> +#define dprintk(fmt, args...) do {} while (0)
> +
> +#define NES_EVENT_TIMEOUT	100000
> +#endif
> +
> +#include "nes_hw.h"
> +#include "nes_verbs.h"
> +#include "nes_context.h"
> +#include "nes_user.h"
> +#include "nes_cm.h"
> +
> +
> +extern unsigned int nes_drv_opt;
> +extern unsigned int nes_debug_level;
> +
> +extern struct list_head nes_adapter_list;
> +extern struct list_head nes_dev_list;
> +
> +extern int max_mtu;
> +#define max_frame_len (max_mtu+ETH_HLEN)
> +extern int interrupt_mod_interval;
> +
> +struct nes_device {
> +	struct nes_adapter *nesadapter;
> +	void __iomem *regs;
> +	void __iomem *index_reg;
> +	struct pci_dev *pcidev;
> +	struct net_device *netdev[NES_NIC_MAX_NICS];

this is questionable.  why do you need multiple netdevs?  multiple 
ports?  ok.  multiple queues?  not ok.  see recent netdev discussions.


> +	u64 link_status_interrupts;
> +	struct tasklet_struct dpc_tasklet;
> +	spinlock_t indexed_regs_lock;
> +	unsigned long doorbell_start;
> +	unsigned long csr_start;
> +	unsigned long mac_tx_errors;
> +	unsigned long mac_pause_frames_sent;
> +	unsigned long mac_pause_frames_received;
> +	unsigned long mac_rx_errors;
> +	unsigned long mac_rx_crc_errors;
> +	unsigned long mac_rx_symbol_err_frames;
> +	unsigned long mac_rx_jabber_frames;
> +	unsigned long mac_rx_oversized_frames;
> +	unsigned long mac_rx_short_frames;
> +	unsigned int mac_index;
> +	unsigned int nes_stack_start;
> +
> +	/* Control Structures */
> +	void *cqp_vbase;
> +	dma_addr_t cqp_pbase;
> +	u32 cqp_mem_size;
> +	u8 ceq_index;
> +	u8 nic_ceq_index;
> +	struct nes_hw_cqp cqp;
> +	struct nes_hw_cq ccq;
> +	struct list_head cqp_avail_reqs;
> +	struct list_head cqp_pending_reqs;
> +	struct nes_cqp_request *nes_cqp_requests;
> +
> +	u32 int_req;
> +	u32 int_stat;
> +	u32 timer_int_req;
> +	u32 timer_only_int_count;
> +	u32 intf_int_req;
> +	u32 et_rx_coalesce_usecs_irq;
> +	struct list_head list;
> +
> +	u16 base_doorbell_index;
> +	u8 msi_enabled;
> +	u8 netdev_count;
> +	u8 napi_isr_ran;
> +	u8 disable_rx_flow_control;
> +	u8 disable_tx_flow_control;

#1: please consider using tabs to separate type and name, which makes 
the struct definition far easier to read.

See drivers/net/tg3.h for an example

#2: consider putting all RX-related items together, and all TX-related 
items together.  this makes cacheline sharing more likely.


> +/* Linux kernel version interface changes */
> +#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,18))
> +static inline unsigned short nes_skb_lso_size(const struct sk_buff *skb)
> +{
> +	return(skb_shinfo(skb)->tso_size);
> +}
> +#define nes_skb_linearize(_skb, _type)  skb_linearize(_skb, _type)
> +#define NES_INIT_WORK(_work, _func, _data)  INIT_WORK(_work, _func)
> +#else
> +static inline unsigned short nes_skb_lso_size(const struct sk_buff *skb)
> +{
> +	return(skb_shinfo(skb)->gso_size);
> +}
> +#define nes_skb_linearize(_skb, _type)  skb_linearize(_skb)
> +#define NES_INIT_WORK(_work, _func, _data)  INIT_WORK(_work, _func)
> +#endif

delete all old-kernel compat code.  not appropriate for upstream submission



> +static inline u32 nes_read32(const void __iomem * addr)
> +{
> +	return(le32_to_cpu(readl(addr)));
> +}
> +
> +static inline u16 nes_read16(const void __iomem * addr)
> +{
> +	return(le16_to_cpu(readw(addr)));
> +}
> +
> +static inline u8 nes_read8(const void __iomem * addr)
> +{
> +	return(readb(addr));
> +}

#1:  delete these completely useless wrappers

#2:  these wrappers are WRONG anyway.  You don't need endian conversion 
macros.


> +/* Write to memory-mapped device */
> +static inline void nes_write_indexed(struct nes_device *nesdev, u32 reg_index, u32 val)
> +{
> +	unsigned long flags;
> +	void __iomem * addr = nesdev->index_reg;
> +
> +	spin_lock_irqsave(&nesdev->indexed_regs_lock, flags);
> +
> +	/* dprintk("Writing %08X, to indexed offset %08X using address %p and %p.\n",
> +			val, reg_index, addr, addr+4); */
> +	writel(cpu_to_le32(reg_index), addr);
> +	writel(cpu_to_le32(val),(u8 *)addr + 4);

wrong -- endian conversion macros not needed with writel()



> +	spin_unlock_irqrestore(&nesdev->indexed_regs_lock, flags);
> +}
> +
> +static inline void nes_write32(void __iomem * addr, u32 val)
> +{
> +	/* dprintk("Writing %08X, to address %p.\n", val, addr); */
> +	writel(cpu_to_le32(val), addr);
> +}
> +
> +static inline void nes_write16(void __iomem * addr, u16 val)
> +{
> +	writew(cpu_to_le16(val), addr);
> +}
> +
> +static inline void nes_write8(void __iomem * addr, u8 val)
> +{
> +	writeb(val, addr);
> +}

#1: delete wrappers

#2: the wrappers are buggy anyway


> +static inline struct nes_vnic *to_nesvnic(struct ib_device *ibdev) {
> +	return (container_of(ibdev, struct nes_ib_device, ibdev)->nesvnic);
> +}
> +
> +static inline struct nes_pd *to_nespd(struct ib_pd *ibpd) {
> +	return (container_of(ibpd, struct nes_pd, ibpd));
> +}
> +
> +static inline struct nes_ucontext *to_nesucontext(struct ib_ucontext *ibucontext) {
> +	return (container_of(ibucontext, struct nes_ucontext, ibucontext));
> +}
> +
> +static inline struct nes_mr *to_nesmr(struct ib_mr *ibmr) {
> +	return (container_of(ibmr, struct nes_mr, ibmr));
> +}
> +
> +static inline struct nes_mr *to_nesmw(struct ib_mw *ibmw) {
> +	return (container_of(ibmw, struct nes_mr, ibmw));
> +}
> +
> +static inline struct nes_mr *to_nesfmr(struct ib_fmr *ibfmr) {
> +	return (container_of(ibfmr, struct nes_mr, ibfmr));
> +}
> +
> +static inline struct nes_cq *to_nescq(struct ib_cq *ibcq) {
> +	return (container_of(ibcq, struct nes_cq, ibcq));
> +}
> +
> +static inline struct nes_qp *to_nesqp(struct ib_qp *ibqp) {
> +	return (container_of(ibqp, struct nes_qp, ibqp));
> +}

all functions have their starting brace in column 1, not at EOL


> +/* Utils */
> +#define CRC32C_POLY     0x1EDC6F41

use libcrc32c rather than reinventing the wheel


> +static inline struct nes_cqp_request
> +		*nes_get_cqp_request(struct nes_device *nesdev, int holding_lock)
> +{
> +	unsigned long flags;
> +	struct nes_cqp_request *cqp_request = NULL;
> +
> +	if (!holding_lock) {
> +		spin_lock_irqsave(&nesdev->cqp.lock, flags);
> +	}
> +	if (!list_empty(&nesdev->cqp_avail_reqs)) {
> +		cqp_request = list_entry(nesdev->cqp_avail_reqs.next,
> +				struct nes_cqp_request, list);
> +		list_del_init(&cqp_request->list);
> +	}
> +	if (!holding_lock) {
> +		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +	}
> +
> +	if (cqp_request) {
> +		cqp_request->waiting = 0;
> +		cqp_request->request_done = 0;
> +		init_waitqueue_head(&cqp_request->waitq);
> +		/* dprintk("%s: Got cqp request %p from the available list \n",
> +				__FUNCTION__, cqp_request); */
> +	} else
> +		dprintk("%s: CQP request queue is empty.\n", __FUNCTION__);
> +
> +	return (cqp_request);
> +}

see below comment about conditional locking


> +static inline void nes_post_cqp_request(struct nes_device *nesdev,
> +		struct nes_cqp_request *cqp_request, int holding_lock, int ring_doorbell)
> +{
> +	/* caller must be holding CQP lock */
> +	struct nes_hw_cqp_wqe *cqp_wqe;
> +	unsigned long flags;
> +	u32 cqp_head;
> +
> +	if (!holding_lock) {
> +		spin_lock_irqsave(&nesdev->cqp.lock, flags);
> +	}
> +
> +	if (((((nesdev->cqp.sq_tail+(nesdev->cqp.sq_size*2))-nesdev->cqp.sq_head) &
> +			(nesdev->cqp.sq_size - 1)) != 1)
> +			&& (list_empty(&nesdev->cqp_pending_reqs))) {
> +		cqp_head = nesdev->cqp.sq_head++;
> +		nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +		cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +		memcpy(cqp_wqe, &cqp_request->cqp_wqe, sizeof(*cqp_wqe));
> +		barrier();
> +		*((struct nes_cqp_request **)&cqp_wqe->wqe_words
> +				[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX]) = cqp_request;
> +		dprintk("%s: CQP request (opcode 0x%02X), line 1 = 0x%08X put on CQPs SQ,"
> +				" request = %p, cqp_head = %u, cqp_tail = %u, cqp_size = %u,"
> +				" waiting = %d, refcount = %d.\n",
> +				__FUNCTION__, cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX]&0x3f,
> +				cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX], cqp_request,
> +				nesdev->cqp.sq_head, nesdev->cqp.sq_tail, nesdev->cqp.sq_size,
> +				cqp_request->waiting, atomic_read(&cqp_request->refcount));
> +	} else {
> +		dprintk("%s: CQP request %p (opcode 0x%02X), line 1 = 0x%08X"
> +				" put on the pending queue.\n",
> +				__FUNCTION__, cqp_request,
> +				cqp_request->cqp_wqe.wqe_words[NES_CQP_WQE_OPCODE_IDX]&0x3f,
> +				cqp_request->cqp_wqe.wqe_words[NES_CQP_WQE_ID_IDX]);
> +		list_add_tail(&cqp_request->list, &nesdev->cqp_pending_reqs);
> +	}
> +
> +	if (ring_doorbell) {
> +		barrier();
> +		/* Ring doorbell (1 WQEs) */
> +		nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x01800000 | nesdev->cqp.qp_id);
> +	}
> +
> +	if (!holding_lock) {
> +		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +	}
> +
> +	return;
> +}

#1: these two are way too big to inline

#2: conditional locking has proven to be fragile.  don't do it.  create 
a wrapper function that acquires/releases the lock, and an inner 
function that does the real work.


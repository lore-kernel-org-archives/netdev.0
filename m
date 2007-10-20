From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [ofa-general] Re: [PATCH 2/14 v2] nes: device structures and defines
Date: Fri, 19 Oct 2007 22:00:15 -0700
Message-ID: <20071019220015.3faa9bbb@freepuppy.rosehill>
References: <200710192004.l9JK48dm021704@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, ewg@lists.openfabrics.org,
	general@lists.openfabrics.org
To: ggrundstrom@neteffect.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <200710192004.l9JK48dm021704@neteffect.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Oct 2007 15:04:08 -0500
ggrundstrom@neteffect.com wrote:

> Main include file for device structures and defines.
> 
> Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>

You are starting off on the wrong foot.

> +#ifdef CONFIG_INFINIBAND_NES_DEBUG
> +#define assert(expr)												\
> +if(!(expr)) {														\
> +	printk(KERN_ERR PFX "Assertion failed! %s, %s, %s, line %d\n",	\
> +		   #expr, __FILE__, __FUNCTION__, __LINE__);				\
> +}

Use BUG_ON

> +#define nes_debug(level, fmt, args...) \
> +	if (level & nes_debug_level) \
> +		printk(KERN_ERR PFX "%s[%u]: " fmt, __FUNCTION__, __LINE__, ##args)
> +
> +#ifndef dprintk
> +#define dprintk(fmt, args...) do { printk(KERN_ERR PFX fmt, ##args); } while (0)
> +#endif

pr_debug or dev_dgg()

> +#define NES_EVENT_TIMEOUT	1200000
> +/* #define NES_EVENT_TIMEOUT	1200 */
> +#else
> +#define assert(expr)          do {} while (0)
> +#define nes_debug(level, fmt, args...)
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
> +extern int max_mtu;
> +extern int nics_per_function;
> +#define max_frame_len (max_mtu+ETH_HLEN)
> +extern int interrupt_mod_interval;
> +extern int nes_if_count;
> +extern int mpa_version;
> +extern int disable_mpa_crc;
> +extern unsigned int send_first;
> +extern unsigned int nes_drv_opt;
> +extern unsigned int nes_debug_level;

Lots of GLOBAL symbols that should be local to the driver.
Also you want to be able to set them per board, not for the whol driver.

> +
> +static inline int nes_skb_is_gso(const struct sk_buff *skb)
> +{
> +	return skb_shinfo(skb)->gso_size;
> +}
> +
> +#define nes_skb_linearize(_skb)  skb_linearize(_skb)
> +

Why the silly wrappers?


> +/* Read from memory-mapped device */
> +static inline u32 nes_read_indexed(struct nes_device *nesdev, u32 reg_index)
> +{
> +	unsigned long flags;
> +	void __iomem *addr = nesdev->index_reg;
> +	u32 value;
> +
> +	spin_lock_irqsave(&nesdev->indexed_regs_lock, flags);
> +
> +	writel(reg_index, addr);
> +	value = readl((void __iomem *)addr + 4);
> +
> +	spin_unlock_irqrestore(&nesdev->indexed_regs_lock, flags);
> +	return value;
> +}

Bad feeling, I smell bad locking coming.

> +static inline u32 nes_read32(const void __iomem* addr)
> +{
> +	return readl(addr);
> +}
> +
> +static inline u16 nes_read16(const void __iomem* addr)
> +{
> +	return readw(addr);
> +}
> +
> +static inline u8 nes_read8(const void __iomem* addr)
> +{
> +	return readb(addr);
> +}

More silly wrappers.

> +/* Write to memory-mapped device */
> +static inline void nes_write_indexed(struct nes_device *nesdev, u32 reg_index, u32 val)
> +{
> +	unsigned long flags;
> +	void __iomem *addr = nesdev->index_reg;
> +
> +	spin_lock_irqsave(&nesdev->indexed_regs_lock, flags);
> +
> +	writel(reg_index, addr);
> +	writel(val, (void __iomem *)addr + 4);
> +
> +	spin_unlock_irqrestore(&nesdev->indexed_regs_lock, flags);
> +}


> +static inline void nes_write32(void __iomem *addr, u32 val)
> +{
> +	writel(val, addr);
> +}
> +
> +static inline void nes_write16(void __iomem *addr, u16 val)
> +{
> +	writew(val, addr);
> +}
> +
> +static inline void nes_write8(void __iomem *addr, u8 val)
> +{
> +	writeb(val, addr);
> +}
> +
> +
> +
> +static inline int nes_alloc_resource(struct nes_adapter *nesadapter,
> +		unsigned long *resource_array, u32 max_resources,
> +		u32 *req_resource_num, u32 *next)
> +{
> +	unsigned long flags;
> +	u32 resource_num;
> +
> +	spin_lock_irqsave(&nesadapter->resource_lock, flags);
> +
> +	resource_num = find_next_zero_bit(resource_array, max_resources, *next);
> +	if (resource_num >= max_resources) {
> +		resource_num = find_first_zero_bit(resource_array, max_resources);
> +		if (resource_num >= max_resources) {
> +			printk(KERN_ERR PFX "%s: No available resourcess.\n", __FUNCTION__);
> +			spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
> +			return -EMFILE;
> +		}
> +	}
> +	nes_debug(NES_DBG_HW, "find_next_zero_bit returned = %u (max = %u).\n",
> +			resource_num, max_resources);
> +	set_bit(resource_num, resource_array);
> +	*next = resource_num+1;
> +	if (*next == max_resources) {
> +		*next = 0;
> +	}
> +	spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
> +	*req_resource_num = resource_num;
> +
> +	return 0;
> +}

Big fat initialization routine that shouldn't be as device inline.

> +static inline int nes_is_resource_allocated(struct nes_adapter *nesadapter,
> +		unsigned long *resource_array, u32 resource_num)
> +{
> +	unsigned long flags;
> +	int bit_is_set;
> +
> +	spin_lock_irqsave(&nesadapter->resource_lock, flags);
> +
> +	bit_is_set = test_bit(resource_num, resource_array);
> +	nes_debug(NES_DBG_HW, "resource_num %u is%s allocated.\n",
> +			resource_num, (bit_is_set ? "": " not"));
> +	spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
> +
> +	return bit_is_set;
> +}

What resource, how about a comment?

> +static inline void nes_free_resource(struct nes_adapter *nesadapter,
> +		unsigned long *resource_array, u32 resource_num)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&nesadapter->resource_lock, flags);
> +	clear_bit(resource_num, resource_array);
> +	spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
> +}
> +
> +static inline struct nes_vnic *to_nesvnic(struct ib_device *ibdev) {
> +	return(container_of(ibdev, struct nes_ib_device, ibdev)->nesvnic);
        return container_of(ibdev, struct nes_ib_device, ibdev)->nesvnic;


> +static inline struct nes_pd *to_nespd(struct ib_pd *ibpd) {
> +	return(container_of(ibpd, struct nes_pd, ibpd));
> +}
> +
> +static inline struct nes_ucontext *to_nesucontext(struct ib_ucontext *ibucontext) {
> +	return(container_of(ibucontext, struct nes_ucontext, ibucontext));
> +}
> +
> +static inline struct nes_mr *to_nesmr(struct ib_mr *ibmr) {
> +	return(container_of(ibmr, struct nes_mr, ibmr));
> +}
> +
> +static inline struct nes_mr *to_nesmr_from_ibfmr(struct ib_fmr *ibfmr) {
> +	return(container_of(ibfmr, struct nes_mr, ibfmr));
> +}
> +
> +static inline struct nes_mr *to_nesmw(struct ib_mw *ibmw) {
> +	return(container_of(ibmw, struct nes_mr, ibmw));
> +}
> +
> +static inline struct nes_fmr *to_nesfmr(struct nes_mr *nesmr) {
> +	return(container_of(nesmr, struct nes_fmr, nesmr));
> +}
> +
> +static inline struct nes_cq *to_nescq(struct ib_cq *ibcq) {
> +	return(container_of(ibcq, struct nes_cq, ibcq));
> +}
> +
> +static inline struct nes_qp *to_nesqp(struct ib_qp *ibqp) {
> +	return(container_of(ibqp, struct nes_qp, ibqp));
> +}
> +
> +
> +#define NES_CQP_REQUEST_NOT_HOLDING_LOCK 0
> +#define NES_CQP_REQUEST_HOLDING_LOCK 1
> +#define NES_CQP_REQUEST_NO_DOORBELL_RING 0
> +#define NES_CQP_REQUEST_RING_DOORBELL 1
> +
> +static inline struct nes_cqp_request
> +		*nes_get_cqp_request(struct nes_device *nesdev, int holding_lock) {

Any code like that has conditional locking is indication of poor design.
It also makes static analysis tools harder.

> +	unsigned long flags;
> +	struct nes_cqp_request *cqp_request = NULL;
> +
> +	if (!holding_lock) {
> +		spin_lock_irqsave(&nesdev->cqp.lock, flags);
> +	}
> +	if (!list_empty(&nesdev->cqp_avail_reqs)) {
> +		cqp_request = list_entry(nesdev->cqp_avail_reqs.next,
> +				struct nes_cqp_request, list);
> +		atomic_inc(&cqp_reqs_allocated);
> +		list_del_init(&cqp_request->list);
> +	} else if (!holding_lock) {
> +		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +		cqp_request = kzalloc(sizeof(struct nes_cqp_request),
> +							  GFP_KERNEL);
> +		if (cqp_request) {
> +			cqp_request->dynamic = 1;
> +			INIT_LIST_HEAD(&cqp_request->list);
> +			atomic_inc(&cqp_reqs_dynallocated);
> +		}
> +		spin_lock_irqsave(&nesdev->cqp.lock, flags);
> +	}
> +	if (!holding_lock) {
> +		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +	}
> +
> +	if (cqp_request) {
> +		init_waitqueue_head(&cqp_request->waitq);
> +		cqp_request->waiting = 0;
> +		cqp_request->request_done = 0;
> +		init_waitqueue_head(&cqp_request->waitq);
> +		nes_debug(NES_DBG_CQP, "Got cqp request %p from the available list \n",
> +				cqp_request);
> +	} else
> +		printk(KERN_ERR PFX "%s: Could not allocated a CQP request.\n",
> +			   __FUNCTION__);
> +
> +	return cqp_request;
> +}
> +
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
> +		cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = cpu_to_le32((u32)((u64)(cqp_request)));
> +		cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = cpu_to_le32((u32)(((u64)(cqp_request))>>32));
> +		nes_debug(NES_DBG_CQP, "CQP request (opcode 0x%02X), line 1 = 0x%08X put on CQPs SQ,"
> +				" request = %p, cqp_head = %u, cqp_tail = %u, cqp_size = %u,"
> +				" waiting = %d, refcount = %d.\n",
> +				le32_to_cpu(cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX])&0x3f,
> +				le32_to_cpu(cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX]), cqp_request,
> +				nesdev->cqp.sq_head, nesdev->cqp.sq_tail, nesdev->cqp.sq_size,
> +				cqp_request->waiting, atomic_read(&cqp_request->refcount));
> +		barrier();
> +		if (ring_doorbell) {
> +			/* Ring doorbell (1 WQEs) */
> +			nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x01800000 | nesdev->cqp.qp_id);
> +		}
> +
> +		barrier();
> +	} else {
> +		atomic_inc(&cqp_reqs_queued);
> +		nes_debug(NES_DBG_CQP, "CQP request %p (opcode 0x%02X), line 1 = 0x%08X"
> +				" put on the pending queue.\n",
> +				cqp_request,
> +				cqp_request->cqp_wqe.wqe_words[NES_CQP_WQE_OPCODE_IDX]&0x3f,
> +				cqp_request->cqp_wqe.wqe_words[NES_CQP_WQE_ID_IDX]);
> +		list_add_tail(&cqp_request->list, &nesdev->cqp_pending_reqs);
> +	}
> +
> +	if (!holding_lock) {
> +		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +	}
> +
> +	return;
> +}
> +

You really think that you need to have a function this big inline in the header file.

> +
> +/* Utils */
> +#define CRC32C_POLY     0x1EDC6F41

Linux has a perfectly good crc32 library routine, use it!


-- 
Stephen Hemminger <shemminger@linux-foundation.org>

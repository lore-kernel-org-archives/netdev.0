From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [PATCH 5/8] csiostor: Chelsio FCoE offload driver submission
 (sources part 5).
Date: Fri, 24 Aug 2012 23:10:36 +0530
Message-ID: <5037BC94.1050201@chelsio.com>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com>  <1345760873-12101-6-git-send-email-naresh@chelsio.com> <1345751301.10190.75.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1345751301.10190.75.camel@haakon2.linux-iscsi.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/24/2012 1:18 AM, Nicholas A. Bellinger wrote:
> On Fri, 2012-08-24 at 03:57 +0530, Naresh Kumar Inna wrote:
>> This patch contains code to implement the interrupt handling and the fast
>> path I/O functionality. The interrupt handling includes allocation of
>> MSIX vectors, registering and implemeting the interrupt service routines.
>> The fast path I/O functionality includes posting the I/O request to firmware
>> via Work Requests, tracking/completing them, and handling task management
>> requests. SCSI midlayer host template implementation is also covered by
>> this patch.
>>
>> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
>> ---
> 
> Hi Naresh,
> 
> My review comments are inline below..

Hi Nicholas,

Thanks for taking the time to review the driver. Please find my replies
inline.

Regards,
Naresh.

> 
>>  drivers/scsi/csiostor/csio_isr.c  |  631 ++++++++++
>>  drivers/scsi/csiostor/csio_scsi.c | 2498 +++++++++++++++++++++++++++++++++++++
>>  2 files changed, 3129 insertions(+), 0 deletions(-)
>>  create mode 100644 drivers/scsi/csiostor/csio_isr.c
>>  create mode 100644 drivers/scsi/csiostor/csio_scsi.c
>>
>> diff --git a/drivers/scsi/csiostor/csio_isr.c b/drivers/scsi/csiostor/csio_isr.c
>> new file mode 100644
>> index 0000000..96633e9
>> --- /dev/null
>> +++ b/drivers/scsi/csiostor/csio_isr.c
> 
> <SNIP>
> 
>> +#define csio_extra_msix_desc(_desc, _len, _str, _arg1, _arg2, _arg3)	\
>> +do {									\
>> +	memset((_desc), 0, (_len) + 1);					\
>> +	snprintf((_desc), (_len), (_str), (_arg1), (_arg2), (_arg3));	\
>> +} while (0)
>> +
> 
> This type of macro usage is not necessary for just two users below.
> Please inline code like this.
> 

OK, I will get rid of this macro.

>> +static void
>> +csio_add_msix_desc(struct csio_hw *hw)
>> +{
>> +	int i;
>> +	struct csio_msix_entries *entryp = &hw->msix_entries[0];
>> +	int k = CSIO_EXTRA_VECS;
>> +	int len = sizeof(entryp->desc) - 1;
>> +	int cnt = hw->num_sqsets + k;
>> +
>> +	/* Non-data vector */
>> +	csio_extra_msix_desc(entryp->desc, len, "csio-%02x:%02x:%x-nondata",
>> +			     CSIO_PCI_BUS(hw), CSIO_PCI_DEV(hw),
>> +			     CSIO_PCI_FUNC(hw));
>> +	entryp++;
>> +	csio_extra_msix_desc(entryp->desc, len, "csio-%02x:%02x:%x-fwevt",
>> +			     CSIO_PCI_BUS(hw), CSIO_PCI_DEV(hw),
>> +			     CSIO_PCI_FUNC(hw));
>> +	entryp++;
>> +
>> +	/* Name SCSI vecs */
>> +	for (i = k; i < cnt; i++, entryp++) {
>> +		memset(entryp->desc, 0, len + 1);
>> +		snprintf(entryp->desc, len, "csio-%02x:%02x:%x-scsi%d",
>> +			 CSIO_PCI_BUS(hw), CSIO_PCI_DEV(hw),
>> +			 CSIO_PCI_FUNC(hw), i - CSIO_EXTRA_VECS);
>> +	}
>> +}
>> +
> 
> 
>> diff --git a/drivers/scsi/csiostor/csio_scsi.c b/drivers/scsi/csiostor/csio_scsi.c
>> new file mode 100644
>> index 0000000..0f87b00
>> --- /dev/null
>> +++ b/drivers/scsi/csiostor/csio_scsi.c
> 
>> +
>> +/*
>> + * csio_scsi_match_io - Match an ioreq with the given SCSI level data.
>> + * @ioreq: The I/O request
>> + * @sld: Level information
>> + *
>> + * Should be called with lock held.
>> + *
>> + */
>> +static bool
>> +csio_scsi_match_io(struct csio_ioreq *ioreq, struct csio_scsi_level_data *sld)
>> +{
>> +	struct scsi_cmnd *scmnd = csio_scsi_cmnd(ioreq);
>> +
>> +	switch (sld->level) {
>> +	case CSIO_LEV_LUN:
>> +		if (scmnd == NULL)
>> +			return CSIO_FALSE;
>> +
>> +		return ((ioreq->lnode == sld->lnode) &&
>> +			(ioreq->rnode == sld->rnode) &&
>> +			((uint64_t)scmnd->device->lun == sld->oslun));
>> +
>> +	case CSIO_LEV_RNODE:
>> +		return ((ioreq->lnode == sld->lnode) &&
>> +				(ioreq->rnode == sld->rnode));
>> +	case CSIO_LEV_LNODE:
>> +		return (ioreq->lnode == sld->lnode);
>> +	case CSIO_LEV_ALL:
>> +		return CSIO_TRUE;
>> +	default:
>> +		return CSIO_FALSE;
>> +	}
>> +}
>> +
> 
> Why can't CSIO_[TRUE,FALSE] just use normal Boolean defines..?
> 

Is there a TRUE/FALSE define in a standard header file? I see a lot of
kernel code defining their own TRUE/FALSE.

>> +/*
>> + * csio_scsi_fcp_cmnd - Frame the SCSI FCP command paylod.
>> + * @req: IO req structure.
>> + * @addr: DMA location to place the payload.
>> + *
>> + * This routine is shared between FCP_WRITE, FCP_READ and FCP_CMD requests.
>> + */
>> +static inline void
>> +csio_scsi_fcp_cmnd(struct csio_ioreq *req, void *addr)
>> +{
>> +	struct csio_fcp_cmnd *fcp_cmnd = (struct csio_fcp_cmnd *)addr;
>> +	struct scsi_cmnd *scmnd = csio_scsi_cmnd(req);
>> +
>> +	/* Check for Task Management */
>> +	if (likely(scmnd->SCp.Message == 0)) {
>> +		int_to_scsilun(scmnd->device->lun,
>> +				(struct scsi_lun *)fcp_cmnd->lun);
>> +		fcp_cmnd->tm_flags = 0;
>> +		fcp_cmnd->cmdref = 0;
>> +		fcp_cmnd->pri_ta = 0;
>> +
>> +		memcpy(fcp_cmnd->cdb, scmnd->cmnd, 16);
>> +		csio_scsi_tag(scmnd, &fcp_cmnd->pri_ta,
>> +			      FCP_PTA_HEADQ, FCP_PTA_ORDERED, FCP_PTA_SIMPLE);
>> +		fcp_cmnd->dl = cpu_to_be32(scsi_bufflen(scmnd));
>> +
>> +		if (req->nsge)
>> +			if (req->datadir == CSIO_IOREQF_DMA_WRITE)
> 
> The same goes for CSIO_IOREQF_DMA_*...
> 
> Why can't this just be DMA_* defs from include/linux/dma-direction.h..?

OK, I will get rid of them and use the standard defines.

> 
>> +				fcp_cmnd->flags = FCP_CFL_WRDATA;
>> +			else
>> +				fcp_cmnd->flags = FCP_CFL_RDDATA;
>> +		else
>> +			fcp_cmnd->flags = 0;
>> +	} else {
>> +		memset(fcp_cmnd, 0, sizeof(*fcp_cmnd));
>> +		int_to_scsilun(scmnd->device->lun,
>> +				(struct scsi_lun *)fcp_cmnd->lun);
>> +		fcp_cmnd->tm_flags = (uint8_t)scmnd->SCp.Message;
>> +	}
>> +}
>> +
> 
> 
> 
>> +
>> +#define CSIO_SCSI_CMD_WR_SZ(_imm)					\
>> +	(sizeof(struct fw_scsi_cmd_wr) +		/* WR size */	\
>> +	 ALIGN((_imm), 16))				/* Immed data */
>> +
>> +#define CSIO_SCSI_CMD_WR_SZ_16(_imm)					\
>> +			(ALIGN(CSIO_SCSI_CMD_WR_SZ((_imm)), 16))
>> +
>> +/*
>> + * csio_scsi_cmd - Create a SCSI CMD WR.
>> + * @req: IO req structure.
>> + *
>> + * Gets a WR slot in the ingress queue and initializes it with SCSI CMD WR.
>> + *
>> + */
>> +static inline void
>> +csio_scsi_cmd(struct csio_ioreq *req)
>> +{
>> +	struct csio_wr_pair wrp;
>> +	struct csio_hw *hw = req->lnode->hwp;
>> +	struct csio_scsim *scsim = csio_hw_to_scsim(hw);
>> +	uint32_t size = CSIO_SCSI_CMD_WR_SZ_16(scsim->proto_cmd_len);
>> +
>> +	req->drv_status = csio_wr_get(hw, req->eq_idx, size, &wrp);
>> +	if (unlikely(req->drv_status != CSIO_SUCCESS))
>> +		return;
>> +
>> +	if (wrp.size1 >= size) {
>> +		/* Initialize WR in one shot */
>> +		csio_scsi_init_cmd_wr(req, wrp.addr1, size);
>> +	} else {
>> +		uint8_t tmpwr[512];
> 
> Mmmm, putting this large of a buffer on the local stack is probably not
> a good idea.
> 
> This should become an allocation..  If it's a hot path then you'll
> probably want to set this up before-hand.
> 

The else switch above is entered only when we near the end of the DMA
ring. This is not a frequent occurrence. If it is a strict no-no to have
so many on-stack bytes, I have to think of a way re-work it to use
pre-allocated memory. Please let me know.

>> +		/*
>> +		 * Make a temporary copy of the WR and write back
>> +		 * the copy into the WR pair.
>> +		 */
>> +		csio_scsi_init_cmd_wr(req, (void *)tmpwr, size);
>> +		memcpy(wrp.addr1, tmpwr, wrp.size1);
>> +		memcpy(wrp.addr2, tmpwr + wrp.size1, size - wrp.size1);
>> +	}
>> +}
>> +
>> +/*
>> + * The following is fast path code. Therefore it is inlined with multi-line
>> + * macros using name substitution, thus avoiding if-else switches for
>> + * operation (read/write), as well as serving the purpose of code re-use.
>> + */
>> +/*
>> + * csio_scsi_init_ulptx_dsgl - Fill in a ULP_TX_SC_DSGL
>> + * @hw: HW module
>> + * @req: IO request
>> + * @sgl: ULP TX SGL pointer.
>> + *
>> + */
>> +#define csio_scsi_init_ultptx_dsgl(hw, req, sgl)			       \
>> +do {									       \
>> +	struct ulptx_sge_pair *_sge_pair = NULL;			       \
>> +	struct scatterlist *_sgel;					       \
>> +	uint32_t _i = 0;						       \
>> +	uint32_t _xfer_len;						       \
>> +	struct list_head *_tmp;						       \
>> +	struct csio_dma_buf *_dma_buf;					       \
>> +	struct scsi_cmnd *scmnd = csio_scsi_cmnd((req));		       \
>> +									       \
>> +	(sgl)->cmd_nsge = htonl(ULPTX_CMD(ULP_TX_SC_DSGL) | ULPTX_MORE |       \
>> +				     ULPTX_NSGE((req)->nsge));		       \
>> +	/* Now add the data SGLs */					       \
>> +	if (likely(!(req)->dcopy)) {				               \
>> +		scsi_for_each_sg(scmnd, _sgel, (req)->nsge, _i) {	       \
>> +			if (_i == 0) {					       \
>> +				(sgl)->addr0 = cpu_to_be64(	               \
>> +						sg_dma_address(_sgel));	       \
>> +				(sgl)->len0 = cpu_to_be32(		       \
>> +						sg_dma_len(_sgel));	       \
>> +				_sge_pair =				       \
>> +					(struct ulptx_sge_pair *)((sgl) + 1);  \
>> +				continue;				       \
>> +			}						       \
>> +			if ((_i - 1) & 0x1) {				       \
>> +				_sge_pair->addr[1] = cpu_to_be64(	       \
>> +						sg_dma_address(_sgel));	       \
>> +				_sge_pair->len[1] = cpu_to_be32(	       \
>> +						sg_dma_len(_sgel));	       \
>> +				_sge_pair++;				       \
>> +			} else	{					       \
>> +				_sge_pair->addr[0] = cpu_to_be64(	       \
>> +						sg_dma_address(_sgel));	       \
>> +				_sge_pair->len[0] = cpu_to_be32(	       \
>> +						sg_dma_len(_sgel));	       \
>> +			}						       \
>> +		}							       \
>> +	} else {							       \
>> +		/* Program sg elements with driver's DDP buffer */	       \
>> +		_xfer_len = scsi_bufflen(scmnd);			       \
>> +		list_for_each(_tmp, &(req)->gen_list) {		       \
>> +			_dma_buf = (struct csio_dma_buf *)_tmp;		       \
>> +			if (_i == 0) {					       \
>> +				(sgl)->addr0 = cpu_to_be64(_dma_buf->paddr);   \
>> +				(sgl)->len0 = cpu_to_be32(		       \
>> +					min(_xfer_len, _dma_buf->len));        \
>> +				_sge_pair =				       \
>> +					(struct ulptx_sge_pair *)((sgl) + 1);  \
>> +			}						       \
>> +			else if ((_i - 1) & 0x1) {			       \
>> +				_sge_pair->addr[1] = cpu_to_be64(	       \
>> +							_dma_buf->paddr);      \
>> +				_sge_pair->len[1] = cpu_to_be32(	       \
>> +					min(_xfer_len, _dma_buf->len));        \
>> +				_sge_pair++;				       \
>> +			} else	{					       \
>> +				_sge_pair->addr[0] = cpu_to_be64(	       \
>> +							_dma_buf->paddr);      \
>> +				_sge_pair->len[0] = cpu_to_be32(	       \
>> +					min(_xfer_len, _dma_buf->len));        \
>> +			}						       \
>> +			_xfer_len -= min(_xfer_len, _dma_buf->len);            \
>> +			_i++;						       \
>> +		}							       \
>> +	}								       \
>> +} while (0)
>> +
> 
> I don't see any reason why this can't just be a static function..?  Why
> is the macro usage necessary here..?

OK, I will make this static-inline.

> 
>> +/*
>> + * csio_scsi_init_data_wr - Initialize the READ/WRITE SCSI WR.
>> + * @req: IO req structure.
>> + * @oper: read/write
>> + * @wrp: DMA location to place the payload.
>> + * @size: Size of WR (including FW WR + immed data + rsp SG entry + data SGL
>> + * @wrop:  _READ_/_WRITE_
>> + *
>> + * Wrapper for populating fw_scsi_read_wr/fw_scsi_write_wr.
>> + */
>> +#define csio_scsi_init_data_wr(req, oper, wrp, size, wrop)		       \
>> +do {									       \
>> +	struct csio_hw *_hw = (req)->lnode->hwp;			       \
>> +	struct csio_rnode *_rn = (req)->rnode;				       \
>> +	struct fw_scsi_##oper##_wr *__wr = (struct fw_scsi_##oper##_wr *)(wrp);\
>> +	struct ulptx_sgl *_sgl;						       \
>> +	struct csio_dma_buf *_dma_buf;					       \
>> +	uint8_t _imm = csio_hw_to_scsim(_hw)->proto_cmd_len;		       \
>> +	struct scsi_cmnd *scmnd = csio_scsi_cmnd((req));		       \
>> +									       \
>> +	__wr->op_immdlen = cpu_to_be32(FW_WR_OP(FW_SCSI##wrop##WR) |           \
>> +					   FW_SCSI##wrop##WR_IMMDLEN(_imm));   \
>> +	__wr->flowid_len16 = cpu_to_be32(FW_WR_FLOWID(_rn->flowid) |           \
>> +					     FW_WR_LEN16(		       \
>> +						CSIO_ROUNDUP((size), 16)));    \
>> +	__wr->cookie = (uintptr_t) (req);				       \
>> +	__wr->iqid = (uint16_t)cpu_to_be16(csio_q_physiqid(_hw,	               \
>> +							       (req)->iq_idx));\
>> +	__wr->tmo_val = (uint8_t)((req)->tmo);				       \
>> +	__wr->use_xfer_cnt = 1;						       \
>> +	__wr->xfer_cnt = cpu_to_be32(scsi_bufflen(scmnd));		       \
>> +	__wr->ini_xfer_cnt = cpu_to_be32(scsi_bufflen(scmnd));		       \
>> +	/* Get RSP DMA buffer */					       \
>> +	_dma_buf = &(req)->dma_buf;					       \
>> +									       \
>> +	/* Prepare RSP SGL */						       \
>> +	__wr->rsp_dmalen = cpu_to_be32(_dma_buf->len);		               \
>> +	__wr->rsp_dmaaddr = cpu_to_be64(_dma_buf->paddr);		       \
>> +									       \
>> +	__wr->r4 = 0;							       \
>> +									       \
>> +	__wr->u.fcoe.ctl_pri = 0;					       \
>> +	__wr->u.fcoe.cp_en_class = 0;					       \
>> +	__wr->u.fcoe.r3_lo[0] = 0;					       \
>> +	__wr->u.fcoe.r3_lo[1] = 0;					       \
>> +	csio_scsi_fcp_cmnd((req), (void *)((uintptr_t)(wrp) +		       \
>> +				   sizeof(struct fw_scsi_##oper##_wr)));       \
>> +									       \
>> +	/* Move WR pointer past command and immediate data */		       \
>> +	_sgl = (struct ulptx_sgl *) ((uintptr_t)(wrp) +			       \
>> +			      sizeof(struct fw_scsi_##oper##_wr) +	       \
>> +			      ALIGN(_imm, 16));			               \
>> +									       \
>> +	/* Fill in the DSGL */						       \
>> +	csio_scsi_init_ultptx_dsgl(_hw, (req), _sgl);			       \
>> +									       \
>> +} while (0)
>> +
> 
> This one has four uses of CPP keys.  Just turn those into macros, and
> leave the rest of the code in a static function.
> 

So what you are suggesting is to have all the lines of the macro
csio_scsi_init_data_wr() added into a static function, but for the ones
with the 4 keys. csio_scsi_init_data_wr() will then invoke this new
function. Is that correct?

>> +/* Calculate WR size needed for fw_scsi_read_wr/fw_scsi_write_wr */
>> +#define csio_scsi_data_wrsz(req, oper, sz, imm)				       \
>> +do {									       \
>> +	(sz) = sizeof(struct fw_scsi_##oper##_wr) +	/* WR size */          \
>> +	       ALIGN((imm), 16) +			/* Immed data */       \
>> +	       sizeof(struct ulptx_sgl);		/* ulptx_sgl */	       \
>> +									       \
>> +	if (unlikely((req)->nsge > 1))				               \
>> +		(sz) += (sizeof(struct ulptx_sge_pair) *		       \
>> +				(ALIGN(((req)->nsge - 1), 2) / 2));            \
>> +							/* Data SGE */	       \
>> +} while (0)
>> +
>> +/*
>> + * csio_scsi_data - Create a SCSI WRITE/READ WR.
>> + * @req: IO req structure.
>> + * @oper: read/write
>> + * @wrop:  _READ_/_WRITE_ (string subsitutions to use with the FW bit field
>> + *         macros).
>> + *
>> + * Gets a WR slot in the ingress queue and initializes it with
>> + * SCSI CMD READ/WRITE WR.
>> + *
>> + */
>> +#define csio_scsi_data(req, oper, wrop)					       \
>> +do {									       \
>> +	struct csio_wr_pair _wrp;					       \
>> +	uint32_t _size;							       \
>> +	struct csio_hw *_hw = (req)->lnode->hwp;			       \
>> +	struct csio_scsim *_scsim = csio_hw_to_scsim(_hw);		       \
>> +									       \
>> +	csio_scsi_data_wrsz((req), oper, _size, _scsim->proto_cmd_len);	       \
>> +	_size = ALIGN(_size, 16);					       \
>> +									       \
>> +	(req)->drv_status = csio_wr_get(_hw, (req)->eq_idx, _size, &_wrp);     \
>> +	if (likely((req)->drv_status == CSIO_SUCCESS)) {		       \
>> +		if (likely(_wrp.size1 >= _size)) {			       \
>> +			/* Initialize WR in one shot */			       \
>> +			csio_scsi_init_data_wr((req), oper, _wrp.addr1,        \
>> +						    _size, wrop);	       \
>> +		} else {						       \
>> +			uint8_t tmpwr[512];				       \
>> +			/*						       \
>> +			 * Make a temporary copy of the WR and write back      \
>> +			 * the copy into the WR pair.			       \
>> +			 */						       \
>> +			csio_scsi_init_data_wr((req), oper, (void *)tmpwr,     \
>> +						    _size, wrop);	       \
>> +			memcpy(_wrp.addr1, tmpwr, _wrp.size1);	               \
>> +			memcpy(_wrp.addr2, tmpwr + _wrp.size1,	               \
>> +				    _size - _wrp.size1);		       \
>> +		}							       \
>> +	}								       \
>> +} while (0)
>> +
> 
> Ditto on this one, along with the tmpwr[512] stack usage..
> 
>> +static inline void
>> +csio_scsi_abrt_cls(struct csio_ioreq *req, bool abort)
>> +{
>> +	struct csio_wr_pair wrp;
>> +	struct csio_hw *hw = req->lnode->hwp;
>> +	uint32_t size = ALIGN(sizeof(struct fw_scsi_abrt_cls_wr), 16);
>> +
>> +	req->drv_status = csio_wr_get(hw, req->eq_idx, size, &wrp);
>> +	if (req->drv_status != CSIO_SUCCESS)
>> +		return;
>> +
>> +	if (wrp.size1 >= size) {
>> +		/* Initialize WR in one shot */
>> +		csio_scsi_init_abrt_cls_wr(req, wrp.addr1, size, abort);
>> +	} else {
>> +		uint8_t tmpwr[512];
> 
> Ditto here on local scope stack usage..
> 
>> +		/*
>> +		 * Make a temporary copy of the WR and write back
>> +		 * the copy into the WR pair.
>> +		 */
>> +		csio_scsi_init_abrt_cls_wr(req, (void *)tmpwr, size, abort);
>> +		memcpy(wrp.addr1, tmpwr, wrp.size1);
>> +		memcpy(wrp.addr2, tmpwr + wrp.size1, size - wrp.size1);
>> +	}
>> +}
>> +
>> +/*****************************************************************************/
>> +/* START: SCSI SM                                                            */
>> +/*****************************************************************************/
>> +static void
>> +csio_scsis_uninit(struct csio_ioreq *req, enum csio_scsi_ev evt)
>> +{
>> +	struct csio_hw *hw = req->lnode->hwp;
>> +	struct csio_scsim *scsim = csio_hw_to_scsim(hw);
>> +
>> +	switch (evt) {
>> +
>> +	case CSIO_SCSIE_START_IO:
> 
> Extra space between start of first switch case

OK, I will remove it. Is there any tool that catches such deviations?
checkpath.pl didnt report it.

> 
>> +
>> +		/* There is data */
> 
> Point-less comment

I will remove it.

> 
>> +		if (req->nsge) {
>> +			if (req->datadir == CSIO_IOREQF_DMA_WRITE) {
>> +				req->dcopy = 0;
>> +				csio_scsi_data(req, write, _WRITE_);
>> +			} else
>> +				csio_setup_ddp(scsim, req);
>> +		} else {
>> +			csio_scsi_cmd(req);
>> +		}
>> +
>> +		if (likely(req->drv_status == CSIO_SUCCESS)) {
>> +			/* change state and enqueue on active_q */
>> +			csio_set_state(&req->sm, csio_scsis_io_active);
>> +			list_add_tail(&req->sm.sm_list, &scsim->active_q);
>> +			csio_wr_issue(hw, req->eq_idx, CSIO_FALSE);
>> +			csio_inc_stats(scsim, n_active);
>> +
>> +			return;
>> +		}
>> +		break;
>> +
>> +	case CSIO_SCSIE_START_TM:
>> +		csio_scsi_cmd(req);
>> +		if (req->drv_status == CSIO_SUCCESS) {
>> +			/*
>> +			 * NOTE: We collect the affected I/Os prior to issuing
>> +			 * LUN reset, and not after it. This is to prevent
>> +			 * aborting I/Os that get issued after the LUN reset,
>> +			 * but prior to LUN reset completion (in the event that
>> +			 * the host stack has not blocked I/Os to a LUN that is
>> +			 * being reset.
>> +			 */
>> +			csio_set_state(&req->sm, csio_scsis_tm_active);
>> +			list_add_tail(&req->sm.sm_list, &scsim->active_q);
>> +			csio_wr_issue(hw, req->eq_idx, CSIO_FALSE);
>> +			csio_inc_stats(scsim, n_tm_active);
>> +		}
>> +		return;
>> +
>> +	case CSIO_SCSIE_ABORT:
>> +	case CSIO_SCSIE_CLOSE:
>> +		/*
>> +		 * NOTE:
>> +		 * We could get here due to  :
>> +		 * - a window in the cleanup path of the SCSI module
>> +		 *   (csio_scsi_abort_io()). Please see NOTE in this function.
>> +		 * - a window in the time we tried to issue an abort/close
>> +		 *   of a request to FW, and the FW completed the request
>> +		 *   itself.
>> +		 *   Print a message for now, and return INVAL either way.
>> +		 */
>> +		req->drv_status = CSIO_INVAL;
>> +		csio_warn(hw, "Trying to abort/close completed IO:%p!\n", req);
>> +		break;
>> +
>> +	default:
>> +		csio_dbg(hw, "Unhandled event:%d sent to req:%p\n", evt, req);
>> +		CSIO_DB_ASSERT(0);
>> +	}
>> +}
>> +
>> +static void
>> +csio_scsis_io_active(struct csio_ioreq *req, enum csio_scsi_ev evt)
>> +{
>> +	struct csio_hw *hw = req->lnode->hwp;
>> +	struct csio_scsim *scm = csio_hw_to_scsim(hw);
>> +	struct csio_rnode *rn;
>> +
>> +	switch (evt) {
>> +
>> +	case CSIO_SCSIE_COMPLETED:
> 
> Ditto
> 
>> +		csio_dec_stats(scm, n_active);
>> +		list_del_init(&req->sm.sm_list);
>> +		csio_set_state(&req->sm, csio_scsis_uninit);
>> +		/*
>> +		 * In MSIX mode, with multiple queues, the SCSI compeltions
>> +		 * could reach us sooner than the FW events sent to indicate
>> +		 * I-T nexus loss (link down, remote device logo etc). We
>> +		 * dont want to be returning such I/Os to the upper layer
>> +		 * immediately, since we wouldnt have reported the I-T nexus
>> +		 * loss itself. This forces us to serialize such completions
>> +		 * with the reporting of the I-T nexus loss. Therefore, we
>> +		 * internally queue up such up such completions in the rnode.
>> +		 * The reporting of I-T nexus loss to the upper layer is then
>> +		 * followed by the returning of I/Os in this internal queue.
>> +		 * Having another state alongwith another queue helps us take
>> +		 * actions for events such as ABORT received while we are
>> +		 * in this rnode queue.
>> +		 */
>> +		if (unlikely(req->wr_status != FW_SUCCESS)) {
>> +			rn = req->rnode;
>> +			/*
>> +			 * FW says remote device is lost, but rnode
>> +			 * doesnt reflect it.
>> +			 */
>> +			if (csio_scsi_itnexus_loss_error(req->wr_status) &&
>> +						csio_is_rnode_ready(rn)) {
>> +				csio_set_state(&req->sm,
>> +						csio_scsis_shost_cmpl_await);
>> +				list_add_tail(&req->sm.sm_list,
>> +					      &rn->host_cmpl_q);
>> +			}
>> +		}
>> +
>> +		break;
>> +
>> +	case CSIO_SCSIE_ABORT:
>> +		csio_scsi_abrt_cls(req, SCSI_ABORT);
>> +		if (req->drv_status == CSIO_SUCCESS) {
>> +			csio_wr_issue(hw, req->eq_idx, CSIO_FALSE);
>> +			csio_set_state(&req->sm, csio_scsis_aborting);
>> +		}
>> +		break;
>> +
>> +	case CSIO_SCSIE_CLOSE:
>> +		csio_scsi_abrt_cls(req, SCSI_CLOSE);
>> +		if (req->drv_status == CSIO_SUCCESS) {
>> +			csio_wr_issue(hw, req->eq_idx, CSIO_FALSE);
>> +			csio_set_state(&req->sm, csio_scsis_closing);
>> +		}
>> +		break;
>> +
>> +	case CSIO_SCSIE_DRVCLEANUP:
>> +		req->wr_status = FW_HOSTERROR;
>> +		csio_dec_stats(scm, n_active);
>> +		csio_set_state(&req->sm, csio_scsis_uninit);
>> +		break;
>> +
>> +	default:
>> +		csio_dbg(hw, "Unhandled event:%d sent to req:%p\n", evt, req);
>> +		CSIO_DB_ASSERT(0);
>> +	}
>> +}
>> +
>> +static void
>> +csio_scsis_tm_active(struct csio_ioreq *req, enum csio_scsi_ev evt)
>> +{
>> +	struct csio_hw *hw = req->lnode->hwp;
>> +	struct csio_scsim *scm = csio_hw_to_scsim(hw);
>> +
>> +	switch (evt) {
>> +
>> +	case CSIO_SCSIE_COMPLETED:
> 
> Ditto
> 
>> +		csio_dec_stats(scm, n_tm_active);
>> +		list_del_init(&req->sm.sm_list);
>> +		csio_set_state(&req->sm, csio_scsis_uninit);
>> +
>> +		break;
>> +
>> +	case CSIO_SCSIE_ABORT:
>> +		csio_scsi_abrt_cls(req, SCSI_ABORT);
>> +		if (req->drv_status == CSIO_SUCCESS) {
>> +			csio_wr_issue(hw, req->eq_idx, CSIO_FALSE);
>> +			csio_set_state(&req->sm, csio_scsis_aborting);
>> +		}
>> +		break;
>> +
>> +
>> +	case CSIO_SCSIE_CLOSE:
>> +		csio_scsi_abrt_cls(req, SCSI_CLOSE);
>> +		if (req->drv_status == CSIO_SUCCESS) {
>> +			csio_wr_issue(hw, req->eq_idx, CSIO_FALSE);
>> +			csio_set_state(&req->sm, csio_scsis_closing);
>> +		}
>> +		break;
>> +
>> +	case CSIO_SCSIE_DRVCLEANUP:
>> +		req->wr_status = FW_HOSTERROR;
>> +		csio_dec_stats(scm, n_tm_active);
>> +		csio_set_state(&req->sm, csio_scsis_uninit);
>> +		break;
>> +
>> +	default:
>> +		csio_dbg(hw, "Unhandled event:%d sent to req:%p\n", evt, req);
>> +		CSIO_DB_ASSERT(0);
>> +	}
>> +}
>> +
>> +static void
>> +csio_scsis_aborting(struct csio_ioreq *req, enum csio_scsi_ev evt)
>> +{
>> +	struct csio_hw *hw = req->lnode->hwp;
>> +	struct csio_scsim *scm = csio_hw_to_scsim(hw);
>> +
>> +	switch (evt) {
>> +
>> +	case CSIO_SCSIE_COMPLETED:
> 
> Ditto
> 
>> +		csio_dbg(hw,
>> +			 "ioreq %p recvd cmpltd (wr_status:%d) "
>> +			 "in aborting st\n", req, req->wr_status);
>> +		/*
>> +		 * Use CSIO_CANCELLED to explicitly tell the ABORTED event that
>> +		 * the original I/O was returned to driver by FW.
>> +		 * We dont really care if the I/O was returned with success by
>> +		 * FW (because the ABORT and completion of the I/O crossed each
>> +		 * other), or any other return value. Once we are in aborting
>> +		 * state, the success or failure of the I/O is unimportant to
>> +		 * us.
>> +		 */
>> +		req->drv_status = CSIO_CANCELLED;
>> +		break;
>> +
>> +	case CSIO_SCSIE_ABORT:
>> +		csio_inc_stats(scm, n_abrt_dups);
>> +		break;
>> +
>> +	case CSIO_SCSIE_ABORTED:
>> +
>> +		csio_dbg(hw, "abort of %p return status:0x%x drv_status:%x\n",
>> +			 req, req->wr_status, req->drv_status);
>> +		/*
>> +		 * Check if original I/O WR completed before the Abort
>> +		 * completion.
>> +		 */
>> +		if (req->drv_status != CSIO_CANCELLED) {
>> +			csio_fatal(hw,
>> +				   "Abort completed before original I/O,"
>> +				   " req:%p\n", req);
>> +			CSIO_DB_ASSERT(0);
>> +		}
>> +
>> +		/*
>> +		 * There are the following possible scenarios:
>> +		 * 1. The abort completed successfully, FW returned FW_SUCCESS.
>> +		 * 2. The completion of an I/O and the receipt of
>> +		 *    abort for that I/O by the FW crossed each other.
>> +		 *    The FW returned FW_EINVAL. The original I/O would have
>> +		 *    returned with FW_SUCCESS or any other SCSI error.
>> +		 * 3. The FW couldnt sent the abort out on the wire, as there
>> +		 *    was an I-T nexus loss (link down, remote device logged
>> +		 *    out etc). FW sent back an appropriate IT nexus loss status
>> +		 *    for the abort.
>> +		 * 4. FW sent an abort, but abort timed out (remote device
>> +		 *    didnt respond). FW replied back with
>> +		 *    FW_SCSI_ABORT_TIMEDOUT.
>> +		 * 5. FW couldnt genuinely abort the request for some reason,
>> +		 *    and sent us an error.
>> +		 *
>> +		 * The first 3 scenarios are treated as  succesful abort
>> +		 * operations by the host, while the last 2 are failed attempts
>> +		 * to abort. Manipulate the return value of the request
>> +		 * appropriately, so that host can convey these results
>> +		 * back to the upper layer.
>> +		 */
>> +		if ((req->wr_status == FW_SUCCESS) ||
>> +		    (req->wr_status == FW_EINVAL) ||
>> +		     csio_scsi_itnexus_loss_error(req->wr_status))
>> +			req->wr_status = FW_SCSI_ABORT_REQUESTED;
>> +
>> +		csio_dec_stats(scm, n_active);
>> +		list_del_init(&req->sm.sm_list);
>> +		csio_set_state(&req->sm, csio_scsis_uninit);
>> +		break;
>> +
>> +	case CSIO_SCSIE_DRVCLEANUP:
>> +		req->wr_status = FW_HOSTERROR;
>> +		csio_dec_stats(scm, n_active);
>> +		csio_set_state(&req->sm, csio_scsis_uninit);
>> +		break;
>> +
>> +	case CSIO_SCSIE_CLOSE:
>> +		/*
>> +		 * We can receive this event from the module
>> +		 * cleanup paths, if the FW forgot to reply to the ABORT WR
>> +		 * and left this ioreq in this state. For now, just ignore
>> +		 * the event. The CLOSE event is sent to this state, as
>> +		 * the LINK may have already gone down.
>> +		 */
>> +		break;
>> +
>> +	default:
>> +		csio_dbg(hw, "Unhandled event:%d sent to req:%p\n", evt, req);
>> +		CSIO_DB_ASSERT(0);
>> +	}
>> +}
>> +
>> +static void
>> +csio_scsis_closing(struct csio_ioreq *req, enum csio_scsi_ev evt)
>> +{
>> +	struct csio_hw *hw = req->lnode->hwp;
>> +	struct csio_scsim *scm = csio_hw_to_scsim(hw);
>> +
>> +	switch (evt) {
>> +
>> +	case CSIO_SCSIE_COMPLETED:
> 
> Ditto
> 
>> +		csio_dbg(hw,
>> +			 "ioreq %p recvd cmpltd (wr_status:%d) "
>> +			 "in closing st\n", req, req->wr_status);
>> +		/*
>> +		 * Use CSIO_CANCELLED to explicitly tell the CLOSED event that
>> +		 * the original I/O was returned to driver by FW.
>> +		 * We dont really care if the I/O was returned with success by
>> +		 * FW (because the CLOSE and completion of the I/O crossed each
>> +		 * other), or any other return value. Once we are in aborting
>> +		 * state, the success or failure of the I/O is unimportant to
>> +		 * us.
>> +		 */
>> +		req->drv_status = CSIO_CANCELLED;
>> +		break;
>> +
>> +	case CSIO_SCSIE_CLOSED:
>> +		/*
>> +		 * Check if original I/O WR completed before the Close
>> +		 * completion.
>> +		 */
>> +		if (req->drv_status != CSIO_CANCELLED) {
>> +			csio_fatal(hw,
>> +				   "Close completed before original I/O,"
>> +				   " req:%p\n", req);
>> +			CSIO_DB_ASSERT(0);
>> +		}
>> +
>> +		/*
>> +		 * Either close succeeded, or we issued close to FW at the
>> +		 * same time FW compelted it to us. Either way, the I/O
>> +		 * is closed.
>> +		 */
>> +		CSIO_DB_ASSERT((req->wr_status == FW_SUCCESS) ||
>> +					(req->wr_status == FW_EINVAL));
>> +		req->wr_status = FW_SCSI_CLOSE_REQUESTED;
>> +
>> +		csio_dec_stats(scm, n_active);
>> +		list_del_init(&req->sm.sm_list);
>> +		csio_set_state(&req->sm, csio_scsis_uninit);
>> +		break;
>> +
>> +	case CSIO_SCSIE_CLOSE:
>> +		break;
>> +
>> +	case CSIO_SCSIE_DRVCLEANUP:
>> +		req->wr_status = FW_HOSTERROR;
>> +		csio_dec_stats(scm, n_active);
>> +		csio_set_state(&req->sm, csio_scsis_uninit);
>> +		break;
>> +
>> +	default:
>> +		csio_dbg(hw, "Unhandled event:%d sent to req:%p\n", evt, req);
>> +		CSIO_DB_ASSERT(0);
>> +	}
>> +}
>> +
>> +static void
>> +csio_scsis_shost_cmpl_await(struct csio_ioreq *req, enum csio_scsi_ev evt)
>> +{
>> +	switch (evt) {
>> +	case CSIO_SCSIE_ABORT:
>> +	case CSIO_SCSIE_CLOSE:
>> +		/*
>> +		 * Just succeed the abort request, and hope that
>> +		 * the remote device unregister path will cleanup
>> +		 * this I/O to the upper layer within a sane
>> +		 * amount of time.
>> +		 */
>> +		/*
>> +		 * A close can come in during a LINK DOWN. The FW would have
>> +		 * returned us the I/O back, but not the remote device lost
>> +		 * FW event. In this interval, if the I/O times out at the upper
>> +		 * layer, a close can come in. Take the same action as abort:
>> +		 * return success, and hope that the remote device unregister
>> +		 * path will cleanup this I/O. If the FW still doesnt send
>> +		 * the msg, the close times out, and the upper layer resorts
>> +		 * to the next level of error recovery.
>> +		 */
>> +		req->drv_status = CSIO_SUCCESS;
>> +		break;
>> +	case CSIO_SCSIE_DRVCLEANUP:
>> +		csio_set_state(&req->sm, csio_scsis_uninit);
>> +		break;
>> +	default:
>> +		csio_dbg(req->lnode->hwp, "Unhandled event:%d sent to req:%p\n",
>> +			 evt, req);
>> +		CSIO_DB_ASSERT(0);
>> +	}
>> +}
>> +
> 
> 
>> +
>> +/**
>> + * csio_queuecommand_lck - Entry point to kickstart an I/O request.
>> + * @cmnd:	The I/O request from ML.
>> + * @done:	The ML callback routine.
>> + *
>> + * This routine does the following:
>> + *	- Checks for HW and Rnode module readiness.
>> + *	- Gets a free ioreq structure (which is already initialized
>> + *	  to uninit during its allocation).
>> + *	- Maps SG elements.
>> + *	- Initializes ioreq members.
>> + *	- Kicks off the SCSI state machine for this IO.
>> + *	- Returns busy status on error.
>> + */
>> +static int
>> +csio_queuecommand_lck(struct scsi_cmnd *cmnd, void (*done)(struct scsi_cmnd *))
>> +{
>> +	struct csio_lnode *ln = shost_priv(cmnd->device->host);
>> +	struct csio_hw *hw = csio_lnode_to_hw(ln);
>> +	struct csio_scsim *scsim = csio_hw_to_scsim(hw);
>> +	struct csio_rnode *rn = (struct csio_rnode *)(cmnd->device->hostdata);
>> +	struct csio_ioreq *ioreq = NULL;
>> +	unsigned long flags;
>> +	int nsge = 0;
>> +	int rv = SCSI_MLQUEUE_HOST_BUSY, nr;
>> +	csio_retval_t retval;
>> +	int cpu;
>> +	struct csio_scsi_qset *sqset;
>> +	struct fc_rport *rport = starget_to_rport(scsi_target(cmnd->device));
>> +
>> +	if (!blk_rq_cpu_valid(cmnd->request))
>> +		cpu = smp_processor_id();
>> +	else
>> +		cpu = cmnd->request->cpu;
>> +
>> +	sqset = &hw->sqset[ln->portid][cpu];
>> +
>> +	nr = fc_remote_port_chkready(rport);
>> +	if (nr) {
>> +		cmnd->result = nr;
>> +		csio_inc_stats(scsim, n_rn_nr_error);
>> +		goto err_done;
>> +	}
>> +
>> +	if (unlikely(!csio_is_hw_ready(hw))) {
>> +		cmnd->result = (DID_REQUEUE << 16);
>> +		csio_inc_stats(scsim, n_hw_nr_error);
>> +		goto err_done;
>> +	}
>> +
>> +	/* Get req->nsge, if there are SG elements to be mapped  */
>> +	nsge = scsi_dma_map(cmnd);
>> +	if (unlikely(nsge < 0)) {
>> +		csio_inc_stats(scsim, n_dmamap_error);
>> +		goto err;
>> +	}
>> +
>> +	/* Do we support so many mappings? */
>> +	if (unlikely(nsge > scsim->max_sge)) {
>> +		csio_warn(hw,
>> +			  "More SGEs than can be supported."
>> +			  " SGEs: %d, Max SGEs: %d\n", nsge, scsim->max_sge);
>> +		csio_inc_stats(scsim, n_unsupp_sge_error);
>> +		goto err_dma_unmap;
>> +	}
>> +
>> +	/* Get a free ioreq structure - SM is already set to uninit */
>> +	ioreq = csio_get_scsi_ioreq_lock(hw, scsim);
>> +	if (!ioreq) {
>> +		csio_err(hw, "Out of I/O request elements. Active #:%d\n",
>> +			 scsim->stats.n_active);
>> +		csio_inc_stats(scsim, n_no_req_error);
>> +		goto err_dma_unmap;
>> +	}
>> +
>> +	ioreq->nsge		= nsge;
>> +	ioreq->lnode		= ln;
>> +	ioreq->rnode		= rn;
>> +	ioreq->iq_idx		= sqset->iq_idx;
>> +	ioreq->eq_idx		= sqset->eq_idx;
>> +	ioreq->wr_status	= 0;
>> +	ioreq->drv_status	= CSIO_SUCCESS;
>> +	csio_scsi_cmnd(ioreq)	= (void *)cmnd;
>> +	ioreq->tmo		= 0;
>> +
>> +	switch (cmnd->sc_data_direction) {
>> +	case DMA_BIDIRECTIONAL:
>> +		ioreq->datadir = CSIO_IOREQF_DMA_BIDI;
>> +		csio_inc_stats(ln, n_control_requests);
>> +		break;
>> +	case DMA_TO_DEVICE:
>> +		ioreq->datadir = CSIO_IOREQF_DMA_WRITE;
>> +		csio_inc_stats(ln, n_output_requests);
>> +		ln->stats.n_output_bytes += scsi_bufflen(cmnd);
>> +		break;
>> +	case DMA_FROM_DEVICE:
>> +		ioreq->datadir = CSIO_IOREQF_DMA_READ;
>> +		csio_inc_stats(ln, n_input_requests);
>> +		ln->stats.n_input_bytes += scsi_bufflen(cmnd);
>> +		break;
>> +	case DMA_NONE:
>> +		ioreq->datadir = CSIO_IOREQF_DMA_NONE;
>> +		csio_inc_stats(ln, n_control_requests);
>> +		break;
>> +	default:
>> +		CSIO_DB_ASSERT(0);
>> +		break;
>> +	}
>> +
>> +	/* Set cbfn */
>> +	ioreq->io_cbfn = csio_scsi_cbfn;
>> +
>> +	/* Needed during abort */
>> +	cmnd->host_scribble = (unsigned char *)ioreq;
>> +	cmnd->scsi_done = done;
>> +	cmnd->SCp.Message = 0;
>> +
>> +	/* Kick off SCSI IO SM on the ioreq */
>> +	spin_lock_irqsave(&hw->lock, flags);
>> +	retval = csio_scsi_start_io(ioreq);
>> +	spin_unlock_irqrestore(&hw->lock, flags);
>> +
>> +	if (retval != CSIO_SUCCESS) {
>> +		csio_err(hw, "ioreq: %p couldnt be started, status:%d\n",
>> +			 ioreq, retval);
>> +		csio_inc_stats(scsim, n_busy_error);
>> +		goto err_put_req;
>> +	}
>> +
>> +	return 0;
>> +
>> +err_put_req:
>> +	csio_put_scsi_ioreq_lock(hw, scsim, ioreq);
>> +err_dma_unmap:
>> +	if (nsge > 0)
>> +		scsi_dma_unmap(cmnd);
>> +err:
>> +	return rv;
>> +
>> +err_done:
>> +	done(cmnd);
>> +	return 0;
>> +}
>> +
>> +static DEF_SCSI_QCMD(csio_queuecommand);
>> +
> 
> This means that your running with the host_lock held..  I'm not sure if
> that is really what you want to do as it really end's up killing
> multi-lun small packet performance..
> 
> How about dropping DEF_SCSI_QCMD usage here, and figure out what
> actually needs to be protected by the SCSI host_lock within
> csio_queuecommand_lck()..?

It is on my TODO list for the next version of the driver, after the
initial submission. Per the current design, we shouldnt need the
host_lock to be held, but I would like to test this change thoroughly
before I submit it.

>> +static csio_retval_t
>> +csio_do_abrt_cls(struct csio_hw *hw, struct csio_ioreq *ioreq, bool abort)
>> +{
>> +	csio_retval_t rv;
>> +	int cpu = smp_processor_id();
>> +	struct csio_lnode *ln = ioreq->lnode;
>> +	struct csio_scsi_qset *sqset = &hw->sqset[ln->portid][cpu];
>> +
>> +	ioreq->tmo = CSIO_SCSI_ABRT_TMO_MS;
>> +	/*
>> +	 * Use current processor queue for posting the abort/close, but retain
>> +	 * the ingress queue ID of the original I/O being aborted/closed - we
>> +	 * need the abort/close completion to be received on the same queue
>> +	 * as the original I/O.
>> +	 */
>> +	ioreq->eq_idx = sqset->eq_idx;
>> +
>> +	if (abort == SCSI_ABORT)
>> +		rv = csio_scsi_abort(ioreq);
>> +	else /* close */
> 
> Point-less comment.

I will remove it.

> 
>> +		rv = csio_scsi_close(ioreq);
>> +
>> +	return rv;
>> +}
>> +
>> +static int
>> +csio_eh_abort_handler(struct scsi_cmnd *cmnd)
>> +{
>> +	struct csio_ioreq *ioreq;
>> +	struct csio_lnode *ln = shost_priv(cmnd->device->host);
>> +	struct csio_hw *hw = csio_lnode_to_hw(ln);
>> +	struct csio_scsim *scsim = csio_hw_to_scsim(hw);
>> +	int ready = 0, ret;
>> +	unsigned long tmo = 0;
>> +	csio_retval_t rv;
>> +	struct csio_rnode *rn = (struct csio_rnode *)(cmnd->device->hostdata);
>> +
>> +	ret = fc_block_scsi_eh(cmnd);
>> +	if (ret)
>> +		return ret;
>> +
>> +	ioreq = (struct csio_ioreq *)cmnd->host_scribble;
>> +	if (!ioreq)
>> +		return SUCCESS;
>> +
>> +	if (!rn)
>> +		return FAILED;
>> +
>> +	csio_dbg(hw,
>> +		 "Request to abort ioreq:%p cmd:%p cdb:%08llx"
>> +		 " ssni:0x%x lun:%d iq:0x%x\n",
>> +		ioreq, cmnd, *((uint64_t *)cmnd->cmnd), rn->flowid,
>> +		cmnd->device->lun, csio_q_physiqid(hw, ioreq->iq_idx));
>> +
>> +	if (((struct scsi_cmnd *)csio_scsi_cmnd(ioreq)) != cmnd) {
>> +		csio_inc_stats(scsim, n_abrt_race_comp);
>> +		return SUCCESS;
>> +	}
>> +
>> +	ready = csio_is_lnode_ready(ln);
>> +	tmo = CSIO_SCSI_ABRT_TMO_MS;
>> +
>> +	spin_lock_irq(&hw->lock);
>> +	rv = csio_do_abrt_cls(hw, ioreq, (ready ? SCSI_ABORT : SCSI_CLOSE));
>> +	spin_unlock_irq(&hw->lock);
>> +
>> +	if (rv != CSIO_SUCCESS) {
>> +		if (rv == CSIO_INVAL) {
>> +			/* Return success, if abort/close request issued on
>> +			 * already completed IO
>> +			 */
>> +			return SUCCESS;
>> +		}
>> +		if (ready)
>> +			csio_inc_stats(scsim, n_abrt_busy_error);
>> +		else
>> +			csio_inc_stats(scsim, n_cls_busy_error);
>> +
>> +		goto inval_scmnd;
>> +	}
>> +
>> +	/* Wait for completion */
>> +	init_completion(&ioreq->cmplobj);
>> +	wait_for_completion_timeout(&ioreq->cmplobj, msecs_to_jiffies(tmo));
>> +
>> +	/* FW didnt respond to abort within our timeout */
>> +	if (((struct scsi_cmnd *)csio_scsi_cmnd(ioreq)) == cmnd) {
>> +
>> +		csio_err(hw, "Abort timed out -- req: %p\n", ioreq);
>> +		csio_inc_stats(scsim, n_abrt_timedout);
>> +
>> +inval_scmnd:
>> +		if (ioreq->nsge > 0)
>> +			scsi_dma_unmap(cmnd);
>> +
>> +		spin_lock_irq(&hw->lock);
>> +		csio_scsi_cmnd(ioreq) = NULL;
>> +		spin_unlock_irq(&hw->lock);
>> +
>> +		cmnd->result = (DID_ERROR << 16);
>> +		cmnd->scsi_done(cmnd);
>> +
>> +		return FAILED;
>> +	}
>> +
>> +	/* FW successfully aborted the request */
>> +	if (host_byte(cmnd->result) == DID_REQUEUE) {
>> +		csio_info(hw,
>> +			"Aborted SCSI command to (%d:%d) serial#:0x%lx\n",
>> +			cmnd->device->id, cmnd->device->lun,
>> +			cmnd->serial_number);
>> +		return SUCCESS;
>> +	} else {
>> +		csio_info(hw,
>> +			"Failed to abort SCSI command, (%d:%d) serial#:0x%lx\n",
>> +			cmnd->device->id, cmnd->device->lun,
>> +			cmnd->serial_number);
>> +		return FAILED;
>> +	}
>> +}
>> +
> 
>> +struct scsi_host_template csio_fcoe_shost_template = {
>> +	.module			= THIS_MODULE,
>> +	.name			= CSIO_DRV_DESC,
>> +	.proc_name		= KBUILD_MODNAME,
>> +	.queuecommand		= csio_queuecommand,
>> +	.eh_abort_handler	= csio_eh_abort_handler,
>> +	.eh_device_reset_handler = csio_eh_lun_reset_handler,
>> +	.slave_alloc		= csio_slave_alloc,
>> +	.slave_configure	= csio_slave_configure,
>> +	.slave_destroy		= csio_slave_destroy,
>> +	.scan_finished		= csio_scan_finished,
>> +	.this_id		= -1,
>> +	.sg_tablesize		= CSIO_SCSI_MAX_SGE,
>> +	.cmd_per_lun		= CSIO_MAX_CMD_PER_LUN,
>> +	.use_clustering		= ENABLE_CLUSTERING,
>> +	.shost_attrs		= csio_fcoe_lport_attrs,
>> +	.max_sectors		= CSIO_MAX_SECTOR_SIZE,
>> +};
>> +
>> +struct scsi_host_template csio_fcoe_shost_vport_template = {
>> +	.module			= THIS_MODULE,
>> +	.name			= CSIO_DRV_DESC,
>> +	.proc_name		= KBUILD_MODNAME,
>> +	.queuecommand		= csio_queuecommand,
>> +	.eh_abort_handler	= csio_eh_abort_handler,
>> +	.eh_device_reset_handler = csio_eh_lun_reset_handler,
>> +	.slave_alloc		= csio_slave_alloc,
>> +	.slave_configure	= csio_slave_configure,
>> +	.slave_destroy		= csio_slave_destroy,
>> +	.scan_finished		= csio_scan_finished,
>> +	.this_id		= -1,
>> +	.sg_tablesize		= CSIO_SCSI_MAX_SGE,
>> +	.cmd_per_lun		= CSIO_MAX_CMD_PER_LUN,
>> +	.use_clustering		= ENABLE_CLUSTERING,
>> +	.shost_attrs		= csio_fcoe_vport_attrs,
>> +	.max_sectors		= CSIO_MAX_SECTOR_SIZE,
>> +};
>> +
>> +/*
>> + * csio_scsi_alloc_ddp_bufs - Allocate buffers for DDP of unaligned SGLs.
>> + * @scm: SCSI Module
>> + * @hw: HW device.
>> + * @buf_size: buffer size
>> + * @num_buf : Number of buffers.
>> + *
>> + * This routine allocates DMA buffers required for SCSI Data xfer, if
>> + * each SGL buffer for a SCSI Read request posted by SCSI midlayer are
>> + * not virtually contiguous.
>> + */
>> +static csio_retval_t
>> +csio_scsi_alloc_ddp_bufs(struct csio_scsim *scm, struct csio_hw *hw,
>> +			 int buf_size, int num_buf)
>> +{
>> +	int n = 0;
>> +	struct list_head *tmp;
>> +	struct csio_dma_buf *ddp_desc = NULL;
>> +	uint32_t unit_size = 0;
>> +
>> +	if (!num_buf)
>> +		return CSIO_SUCCESS;
> 
> Just return 0..?

Since there is a comment about driver-internal return values in your
review of patch 6, I would like to take up this discussion in that thread.


> 
>> +
>> +	if (!buf_size)
>> +		return CSIO_INVAL;
> 
> Just return -EINVAL..?
> 
>> +
>> +	INIT_LIST_HEAD(&scm->ddp_freelist);
>> +
>> +	/* Align buf size to page size */
>> +	buf_size = (buf_size + PAGE_SIZE - 1) & PAGE_MASK;
>> +	/* Initialize dma descriptors */
>> +	for (n = 0; n < num_buf; n++) {
>> +		/* Set unit size to request size */
>> +		unit_size = buf_size;
>> +		ddp_desc = kzalloc(sizeof(struct csio_dma_buf), GFP_KERNEL);
>> +		if (!ddp_desc) {
>> +			csio_err(hw,
>> +				 "Failed to allocate ddp descriptors,"
>> +				 " Num allocated = %d.\n",
>> +				 scm->stats.n_free_ddp);
>> +			goto no_mem;
>> +		}
>> +
>> +		/* Allocate Dma buffers for DDP */
>> +		ddp_desc->vaddr = pci_alloc_consistent(hw->pdev, unit_size,
>> +							&ddp_desc->paddr);
>> +		if (!ddp_desc->vaddr) {
>> +			csio_err(hw,
>> +				 "SCSI response DMA buffer (ddp) allocation"
>> +				 " failed!\n");
>> +			kfree(ddp_desc);
>> +			goto no_mem;
>> +		}
>> +
>> +		ddp_desc->len = unit_size;
>> +
>> +		/* Added it to scsi ddp freelist */
>> +		list_add_tail(&ddp_desc->list, &scm->ddp_freelist);
>> +		csio_inc_stats(scm, n_free_ddp);
>> +	}
>> +
>> +	return CSIO_SUCCESS;
> 
> Just return 0..?
> 
>> +no_mem:
>> +	/* release dma descs back to freelist and free dma memory */
>> +	list_for_each(tmp, &scm->ddp_freelist) {
>> +		ddp_desc = (struct csio_dma_buf *) tmp;
>> +		tmp = csio_list_prev(tmp);
>> +		pci_free_consistent(hw->pdev, ddp_desc->len, ddp_desc->vaddr,
>> +				    ddp_desc->paddr);
>> +		list_del_init(&ddp_desc->list);
>> +		kfree(ddp_desc);
>> +	}
>> +	scm->stats.n_free_ddp = 0;
>> +
>> +	return CSIO_NOMEM;
> 
> This should be just -ENOMEM..?
> 
>> +}
>> +
>> +/*
>> + * csio_scsi_free_ddp_bufs - free DDP buffers of unaligned SGLs.
>> + * @scm: SCSI Module
>> + * @hw: HW device.
>> + *
>> + * This routine frees ddp buffers.
>> + */
>> +static csio_retval_t
>> +csio_scsi_free_ddp_bufs(struct csio_scsim *scm, struct csio_hw *hw)
>> +{
>> +	struct list_head *tmp;
>> +	struct csio_dma_buf *ddp_desc;
>> +
>> +	/* release dma descs back to freelist and free dma memory */
>> +	list_for_each(tmp, &scm->ddp_freelist) {
>> +		ddp_desc = (struct csio_dma_buf *) tmp;
>> +		tmp = csio_list_prev(tmp);
>> +		pci_free_consistent(hw->pdev, ddp_desc->len, ddp_desc->vaddr,
>> +				    ddp_desc->paddr);
>> +		list_del_init(&ddp_desc->list);
>> +		kfree(ddp_desc);
>> +	}
>> +	scm->stats.n_free_ddp = 0;
>> +
>> +	return CSIO_NOMEM;
>> +}
> 
> Ditto..  Just -ENOMEM..?
> 
> 


From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [PATCH 5/8] csiostor: Chelsio FCoE offload driver submission
 (sources part 5).
Date: Sun, 26 Aug 2012 00:06:07 +0530
Message-ID: <50391B17.2040505@chelsio.com>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com>  <1345760873-12101-6-git-send-email-naresh@chelsio.com>  <1345751301.10190.75.camel@haakon2.linux-iscsi.org>  <5037BC94.1050201@chelsio.com> <1345841784.28432.44.camel@haakon2.linux-iscsi.org>
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
In-Reply-To: <1345841784.28432.44.camel@haakon2.linux-iscsi.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/25/2012 2:26 AM, Nicholas A. Bellinger wrote:
> On Fri, 2012-08-24 at 23:10 +0530, Naresh Kumar Inna wrote:
>> On 8/24/2012 1:18 AM, Nicholas A. Bellinger wrote:
>>> On Fri, 2012-08-24 at 03:57 +0530, Naresh Kumar Inna wrote:
>>>> This patch contains code to implement the interrupt handling and the fast
>>>> path I/O functionality. The interrupt handling includes allocation of
>>>> MSIX vectors, registering and implemeting the interrupt service routines.
>>>> The fast path I/O functionality includes posting the I/O request to firmware
>>>> via Work Requests, tracking/completing them, and handling task management
>>>> requests. SCSI midlayer host template implementation is also covered by
>>>> this patch.
>>>>
>>>> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
>>>> ---
>>>
>>> Hi Naresh,
>>>
>>> My review comments are inline below..
>>
>> Hi Nicholas,
>>
>> Thanks for taking the time to review the driver. Please find my replies
>> inline.
>>
>> Regards,
>> Naresh.
>>
>>>
>>>>  drivers/scsi/csiostor/csio_isr.c  |  631 ++++++++++
>>>>  drivers/scsi/csiostor/csio_scsi.c | 2498 +++++++++++++++++++++++++++++++++++++
>>>>  2 files changed, 3129 insertions(+), 0 deletions(-)
>>>>  create mode 100644 drivers/scsi/csiostor/csio_isr.c
>>>>  create mode 100644 drivers/scsi/csiostor/csio_scsi.c
>>>>
> 
> <SNIP>
> 
>>>
>>>> diff --git a/drivers/scsi/csiostor/csio_scsi.c b/drivers/scsi/csiostor/csio_scsi.c
>>>> new file mode 100644
>>>> index 0000000..0f87b00
>>>> --- /dev/null
>>>> +++ b/drivers/scsi/csiostor/csio_scsi.c
>>>> +
>>>> +#define CSIO_SCSI_CMD_WR_SZ(_imm)					\
>>>> +	(sizeof(struct fw_scsi_cmd_wr) +		/* WR size */	\
>>>> +	 ALIGN((_imm), 16))				/* Immed data */
>>>> +
>>>> +#define CSIO_SCSI_CMD_WR_SZ_16(_imm)					\
>>>> +			(ALIGN(CSIO_SCSI_CMD_WR_SZ((_imm)), 16))
>>>> +
>>>> +/*
>>>> + * csio_scsi_cmd - Create a SCSI CMD WR.
>>>> + * @req: IO req structure.
>>>> + *
>>>> + * Gets a WR slot in the ingress queue and initializes it with SCSI CMD WR.
>>>> + *
>>>> + */
>>>> +static inline void
>>>> +csio_scsi_cmd(struct csio_ioreq *req)
>>>> +{
>>>> +	struct csio_wr_pair wrp;
>>>> +	struct csio_hw *hw = req->lnode->hwp;
>>>> +	struct csio_scsim *scsim = csio_hw_to_scsim(hw);
>>>> +	uint32_t size = CSIO_SCSI_CMD_WR_SZ_16(scsim->proto_cmd_len);
>>>> +
>>>> +	req->drv_status = csio_wr_get(hw, req->eq_idx, size, &wrp);
>>>> +	if (unlikely(req->drv_status != CSIO_SUCCESS))
>>>> +		return;
>>>> +
>>>> +	if (wrp.size1 >= size) {
>>>> +		/* Initialize WR in one shot */
>>>> +		csio_scsi_init_cmd_wr(req, wrp.addr1, size);
>>>> +	} else {
>>>> +		uint8_t tmpwr[512];
>>>
>>> Mmmm, putting this large of a buffer on the local stack is probably not
>>> a good idea.
>>>
>>> This should become an allocation..  If it's a hot path then you'll
>>> probably want to set this up before-hand.
>>>
>>
>> The else switch above is entered only when we near the end of the DMA
>> ring. This is not a frequent occurrence. If it is a strict no-no to have
>> so many on-stack bytes, I have to think of a way re-work it to use
>> pre-allocated memory. Please let me know.
>>
> 
> Considering it's used a number of times, it would be better to just
> figure out a sensible manner to pre-allocate this, especially if it's
> only a single occurrence to an individual ring held under a lock. 
> 

I will see what I can do - I can probably add these bytes into every
queues metadata structure.

>>>> +		/*
>>>> +		 * Make a temporary copy of the WR and write back
>>>> +		 * the copy into the WR pair.
>>>> +		 */
>>>> +		csio_scsi_init_cmd_wr(req, (void *)tmpwr, size);
>>>> +		memcpy(wrp.addr1, tmpwr, wrp.size1);
>>>> +		memcpy(wrp.addr2, tmpwr + wrp.size1, size - wrp.size1);
>>>> +	}
>>>> +}
>>>> +
>>>> +/*
>>>> + * The following is fast path code. Therefore it is inlined with multi-line
>>>> + * macros using name substitution, thus avoiding if-else switches for
>>>> + * operation (read/write), as well as serving the purpose of code re-use.
>>>> + */
>>>> +/*
>>>> + * csio_scsi_init_ulptx_dsgl - Fill in a ULP_TX_SC_DSGL
>>>> + * @hw: HW module
>>>> + * @req: IO request
>>>> + * @sgl: ULP TX SGL pointer.
>>>> + *
>>>> + */
>>>> +#define csio_scsi_init_ultptx_dsgl(hw, req, sgl)			       \
>>>> +do {									       \
>>>> +	struct ulptx_sge_pair *_sge_pair = NULL;			       \
>>>> +	struct scatterlist *_sgel;					       \
>>>> +	uint32_t _i = 0;						       \
>>>> +	uint32_t _xfer_len;						       \
>>>> +	struct list_head *_tmp;						       \
>>>> +	struct csio_dma_buf *_dma_buf;					       \
>>>> +	struct scsi_cmnd *scmnd = csio_scsi_cmnd((req));		       \
>>>> +									       \
>>>> +	(sgl)->cmd_nsge = htonl(ULPTX_CMD(ULP_TX_SC_DSGL) | ULPTX_MORE |       \
>>>> +				     ULPTX_NSGE((req)->nsge));		       \
>>>> +	/* Now add the data SGLs */					       \
>>>> +	if (likely(!(req)->dcopy)) {				               \
>>>> +		scsi_for_each_sg(scmnd, _sgel, (req)->nsge, _i) {	       \
>>>> +			if (_i == 0) {					       \
>>>> +				(sgl)->addr0 = cpu_to_be64(	               \
>>>> +						sg_dma_address(_sgel));	       \
>>>> +				(sgl)->len0 = cpu_to_be32(		       \
>>>> +						sg_dma_len(_sgel));	       \
>>>> +				_sge_pair =				       \
>>>> +					(struct ulptx_sge_pair *)((sgl) + 1);  \
>>>> +				continue;				       \
>>>> +			}						       \
>>>> +			if ((_i - 1) & 0x1) {				       \
>>>> +				_sge_pair->addr[1] = cpu_to_be64(	       \
>>>> +						sg_dma_address(_sgel));	       \
>>>> +				_sge_pair->len[1] = cpu_to_be32(	       \
>>>> +						sg_dma_len(_sgel));	       \
>>>> +				_sge_pair++;				       \
>>>> +			} else	{					       \
>>>> +				_sge_pair->addr[0] = cpu_to_be64(	       \
>>>> +						sg_dma_address(_sgel));	       \
>>>> +				_sge_pair->len[0] = cpu_to_be32(	       \
>>>> +						sg_dma_len(_sgel));	       \
>>>> +			}						       \
>>>> +		}							       \
>>>> +	} else {							       \
>>>> +		/* Program sg elements with driver's DDP buffer */	       \
>>>> +		_xfer_len = scsi_bufflen(scmnd);			       \
>>>> +		list_for_each(_tmp, &(req)->gen_list) {		       \
>>>> +			_dma_buf = (struct csio_dma_buf *)_tmp;		       \
>>>> +			if (_i == 0) {					       \
>>>> +				(sgl)->addr0 = cpu_to_be64(_dma_buf->paddr);   \
>>>> +				(sgl)->len0 = cpu_to_be32(		       \
>>>> +					min(_xfer_len, _dma_buf->len));        \
>>>> +				_sge_pair =				       \
>>>> +					(struct ulptx_sge_pair *)((sgl) + 1);  \
>>>> +			}						       \
>>>> +			else if ((_i - 1) & 0x1) {			       \
>>>> +				_sge_pair->addr[1] = cpu_to_be64(	       \
>>>> +							_dma_buf->paddr);      \
>>>> +				_sge_pair->len[1] = cpu_to_be32(	       \
>>>> +					min(_xfer_len, _dma_buf->len));        \
>>>> +				_sge_pair++;				       \
>>>> +			} else	{					       \
>>>> +				_sge_pair->addr[0] = cpu_to_be64(	       \
>>>> +							_dma_buf->paddr);      \
>>>> +				_sge_pair->len[0] = cpu_to_be32(	       \
>>>> +					min(_xfer_len, _dma_buf->len));        \
>>>> +			}						       \
>>>> +			_xfer_len -= min(_xfer_len, _dma_buf->len);            \
>>>> +			_i++;						       \
>>>> +		}							       \
>>>> +	}								       \
>>>> +} while (0)
>>>> +
>>>
>>> I don't see any reason why this can't just be a static function..?  Why
>>> is the macro usage necessary here..?
>>
>> OK, I will make this static-inline.
>>
>>>
>>>> +/*
>>>> + * csio_scsi_init_data_wr - Initialize the READ/WRITE SCSI WR.
>>>> + * @req: IO req structure.
>>>> + * @oper: read/write
>>>> + * @wrp: DMA location to place the payload.
>>>> + * @size: Size of WR (including FW WR + immed data + rsp SG entry + data SGL
>>>> + * @wrop:  _READ_/_WRITE_
>>>> + *
>>>> + * Wrapper for populating fw_scsi_read_wr/fw_scsi_write_wr.
>>>> + */
>>>> +#define csio_scsi_init_data_wr(req, oper, wrp, size, wrop)		       \
>>>> +do {									       \
>>>> +	struct csio_hw *_hw = (req)->lnode->hwp;			       \
>>>> +	struct csio_rnode *_rn = (req)->rnode;				       \
>>>> +	struct fw_scsi_##oper##_wr *__wr = (struct fw_scsi_##oper##_wr *)(wrp);\
>>>> +	struct ulptx_sgl *_sgl;						       \
>>>> +	struct csio_dma_buf *_dma_buf;					       \
>>>> +	uint8_t _imm = csio_hw_to_scsim(_hw)->proto_cmd_len;		       \
>>>> +	struct scsi_cmnd *scmnd = csio_scsi_cmnd((req));		       \
>>>> +									       \
>>>> +	__wr->op_immdlen = cpu_to_be32(FW_WR_OP(FW_SCSI##wrop##WR) |           \
>>>> +					   FW_SCSI##wrop##WR_IMMDLEN(_imm));   \
>>>> +	__wr->flowid_len16 = cpu_to_be32(FW_WR_FLOWID(_rn->flowid) |           \
>>>> +					     FW_WR_LEN16(		       \
>>>> +						CSIO_ROUNDUP((size), 16)));    \
>>>> +	__wr->cookie = (uintptr_t) (req);				       \
>>>> +	__wr->iqid = (uint16_t)cpu_to_be16(csio_q_physiqid(_hw,	               \
>>>> +							       (req)->iq_idx));\
>>>> +	__wr->tmo_val = (uint8_t)((req)->tmo);				       \
>>>> +	__wr->use_xfer_cnt = 1;						       \
>>>> +	__wr->xfer_cnt = cpu_to_be32(scsi_bufflen(scmnd));		       \
>>>> +	__wr->ini_xfer_cnt = cpu_to_be32(scsi_bufflen(scmnd));		       \
>>>> +	/* Get RSP DMA buffer */					       \
>>>> +	_dma_buf = &(req)->dma_buf;					       \
>>>> +									       \
>>>> +	/* Prepare RSP SGL */						       \
>>>> +	__wr->rsp_dmalen = cpu_to_be32(_dma_buf->len);		               \
>>>> +	__wr->rsp_dmaaddr = cpu_to_be64(_dma_buf->paddr);		       \
>>>> +									       \
>>>> +	__wr->r4 = 0;							       \
>>>> +									       \
>>>> +	__wr->u.fcoe.ctl_pri = 0;					       \
>>>> +	__wr->u.fcoe.cp_en_class = 0;					       \
>>>> +	__wr->u.fcoe.r3_lo[0] = 0;					       \
>>>> +	__wr->u.fcoe.r3_lo[1] = 0;					       \
>>>> +	csio_scsi_fcp_cmnd((req), (void *)((uintptr_t)(wrp) +		       \
>>>> +				   sizeof(struct fw_scsi_##oper##_wr)));       \
>>>> +									       \
>>>> +	/* Move WR pointer past command and immediate data */		       \
>>>> +	_sgl = (struct ulptx_sgl *) ((uintptr_t)(wrp) +			       \
>>>> +			      sizeof(struct fw_scsi_##oper##_wr) +	       \
>>>> +			      ALIGN(_imm, 16));			               \
>>>> +									       \
>>>> +	/* Fill in the DSGL */						       \
>>>> +	csio_scsi_init_ultptx_dsgl(_hw, (req), _sgl);			       \
>>>> +									       \
>>>> +} while (0)
>>>> +
>>>
>>> This one has four uses of CPP keys.  Just turn those into macros, and
>>> leave the rest of the code in a static function.
>>>
>>
>> So what you are suggesting is to have all the lines of the macro
>> csio_scsi_init_data_wr() added into a static function, but for the ones
>> with the 4 keys. csio_scsi_init_data_wr() will then invoke this new
>> function. Is that correct?
>>
> 
> Not sure how the above should actually look without actually doing it,
> but IMHO the usage of macro just obfuscates what is going on..
> 
> If it's only used a few times, just inline the code into seperate static
> functions.  If it's used more than a few times, then use a single static
> funciton with macro accessors for the assignment of the various '__wr'
> structure members.
> 
> The larger problem with all of these macros is that you can't tell what
> is a macro and what is a function.
> 
> If you need to use a CPP macro, please make sure to capitalize the name
> of the macro in order to tell the difference between the two.
> 

OK, I will see what I can do to convert this macro into a function.

>>>> +/* Calculate WR size needed for fw_scsi_read_wr/fw_scsi_write_wr */
>>>> +#define csio_scsi_data_wrsz(req, oper, sz, imm)				       \
>>>> +do {									       \
>>>> +	(sz) = sizeof(struct fw_scsi_##oper##_wr) +	/* WR size */          \
>>>> +	       ALIGN((imm), 16) +			/* Immed data */       \
>>>> +	       sizeof(struct ulptx_sgl);		/* ulptx_sgl */	       \
>>>> +									       \
>>>> +	if (unlikely((req)->nsge > 1))				               \
>>>> +		(sz) += (sizeof(struct ulptx_sge_pair) *		       \
>>>> +				(ALIGN(((req)->nsge - 1), 2) / 2));            \
>>>> +							/* Data SGE */	       \
>>>> +} while (0)
>>>> +
>>>> +/*
>>>> + * csio_scsi_data - Create a SCSI WRITE/READ WR.
>>>> + * @req: IO req structure.
>>>> + * @oper: read/write
>>>> + * @wrop:  _READ_/_WRITE_ (string subsitutions to use with the FW bit field
>>>> + *         macros).
>>>> + *
>>>> + * Gets a WR slot in the ingress queue and initializes it with
>>>> + * SCSI CMD READ/WRITE WR.
>>>> + *
>>>> + */
>>>> +#define csio_scsi_data(req, oper, wrop)					       \
>>>> +do {									       \
>>>> +	struct csio_wr_pair _wrp;					       \
>>>> +	uint32_t _size;							       \
>>>> +	struct csio_hw *_hw = (req)->lnode->hwp;			       \
>>>> +	struct csio_scsim *_scsim = csio_hw_to_scsim(_hw);		       \
>>>> +									       \
>>>> +	csio_scsi_data_wrsz((req), oper, _size, _scsim->proto_cmd_len);	       \
>>>> +	_size = ALIGN(_size, 16);					       \
>>>> +									       \
>>>> +	(req)->drv_status = csio_wr_get(_hw, (req)->eq_idx, _size, &_wrp);     \
>>>> +	if (likely((req)->drv_status == CSIO_SUCCESS)) {		       \
>>>> +		if (likely(_wrp.size1 >= _size)) {			       \
>>>> +			/* Initialize WR in one shot */			       \
>>>> +			csio_scsi_init_data_wr((req), oper, _wrp.addr1,        \
>>>> +						    _size, wrop);	       \
>>>> +		} else {						       \
>>>> +			uint8_t tmpwr[512];				       \
>>>> +			/*						       \
>>>> +			 * Make a temporary copy of the WR and write back      \
>>>> +			 * the copy into the WR pair.			       \
>>>> +			 */						       \
>>>> +			csio_scsi_init_data_wr((req), oper, (void *)tmpwr,     \
>>>> +						    _size, wrop);	       \
>>>> +			memcpy(_wrp.addr1, tmpwr, _wrp.size1);	               \
>>>> +			memcpy(_wrp.addr2, tmpwr + _wrp.size1,	               \
>>>> +				    _size - _wrp.size1);		       \
>>>> +		}							       \
>>>> +	}								       \
>>>> +} while (0)
>>>> +
>>>
>>> Ditto on this one, along with the tmpwr[512] stack usage..
>>>
>>>> +static inline void
>>>> +csio_scsi_abrt_cls(struct csio_ioreq *req, bool abort)
>>>> +{
>>>> +	struct csio_wr_pair wrp;
>>>> +	struct csio_hw *hw = req->lnode->hwp;
>>>> +	uint32_t size = ALIGN(sizeof(struct fw_scsi_abrt_cls_wr), 16);
>>>> +
>>>> +	req->drv_status = csio_wr_get(hw, req->eq_idx, size, &wrp);
>>>> +	if (req->drv_status != CSIO_SUCCESS)
>>>> +		return;
>>>> +
>>>> +	if (wrp.size1 >= size) {
>>>> +		/* Initialize WR in one shot */
>>>> +		csio_scsi_init_abrt_cls_wr(req, wrp.addr1, size, abort);
>>>> +	} else {
>>>> +		uint8_t tmpwr[512];
>>>
>>> Ditto here on local scope stack usage..
>>>
>>>> +		/*
>>>> +		 * Make a temporary copy of the WR and write back
>>>> +		 * the copy into the WR pair.
>>>> +		 */
>>>> +		csio_scsi_init_abrt_cls_wr(req, (void *)tmpwr, size, abort);
>>>> +		memcpy(wrp.addr1, tmpwr, wrp.size1);
>>>> +		memcpy(wrp.addr2, tmpwr + wrp.size1, size - wrp.size1);
>>>> +	}
>>>> +}
>>>> +
>>>> +/*****************************************************************************/
>>>> +/* START: SCSI SM                                                            */
>>>> +/*****************************************************************************/
>>>> +static void
>>>> +csio_scsis_uninit(struct csio_ioreq *req, enum csio_scsi_ev evt)
>>>> +{
>>>> +	struct csio_hw *hw = req->lnode->hwp;
>>>> +	struct csio_scsim *scsim = csio_hw_to_scsim(hw);
>>>> +
>>>> +	switch (evt) {
>>>> +
>>>> +	case CSIO_SCSIE_START_IO:
>>>
>>> Extra space between start of first switch case
>>
>> OK, I will remove it. Is there any tool that catches such deviations?
>> checkpath.pl didnt report it.
>>
> 
> Sorry, can't help you there..  ;)
> 
>>>
>>>> +
>>>> +/**
>>>> + * csio_queuecommand_lck - Entry point to kickstart an I/O request.
>>>> + * @cmnd:	The I/O request from ML.
>>>> + * @done:	The ML callback routine.
>>>> + *
>>>> + * This routine does the following:
>>>> + *	- Checks for HW and Rnode module readiness.
>>>> + *	- Gets a free ioreq structure (which is already initialized
>>>> + *	  to uninit during its allocation).
>>>> + *	- Maps SG elements.
>>>> + *	- Initializes ioreq members.
>>>> + *	- Kicks off the SCSI state machine for this IO.
>>>> + *	- Returns busy status on error.
>>>> + */
>>>> +static int
>>>> +csio_queuecommand_lck(struct scsi_cmnd *cmnd, void (*done)(struct scsi_cmnd *))
>>>> +{
>>>> +	struct csio_lnode *ln = shost_priv(cmnd->device->host);
>>>> +	struct csio_hw *hw = csio_lnode_to_hw(ln);
>>>> +	struct csio_scsim *scsim = csio_hw_to_scsim(hw);
>>>> +	struct csio_rnode *rn = (struct csio_rnode *)(cmnd->device->hostdata);
>>>> +	struct csio_ioreq *ioreq = NULL;
>>>> +	unsigned long flags;
>>>> +	int nsge = 0;
>>>> +	int rv = SCSI_MLQUEUE_HOST_BUSY, nr;
>>>> +	csio_retval_t retval;
>>>> +	int cpu;
>>>> +	struct csio_scsi_qset *sqset;
>>>> +	struct fc_rport *rport = starget_to_rport(scsi_target(cmnd->device));
>>>> +
>>>> +	if (!blk_rq_cpu_valid(cmnd->request))
>>>> +		cpu = smp_processor_id();
>>>> +	else
>>>> +		cpu = cmnd->request->cpu;
>>>> +
>>>> +	sqset = &hw->sqset[ln->portid][cpu];
>>>> +
>>>> +	nr = fc_remote_port_chkready(rport);
>>>> +	if (nr) {
>>>> +		cmnd->result = nr;
>>>> +		csio_inc_stats(scsim, n_rn_nr_error);
>>>> +		goto err_done;
>>>> +	}
>>>> +
>>>> +	if (unlikely(!csio_is_hw_ready(hw))) {
>>>> +		cmnd->result = (DID_REQUEUE << 16);
>>>> +		csio_inc_stats(scsim, n_hw_nr_error);
>>>> +		goto err_done;
>>>> +	}
>>>> +
>>>> +	/* Get req->nsge, if there are SG elements to be mapped  */
>>>> +	nsge = scsi_dma_map(cmnd);
>>>> +	if (unlikely(nsge < 0)) {
>>>> +		csio_inc_stats(scsim, n_dmamap_error);
>>>> +		goto err;
>>>> +	}
>>>> +
>>>> +	/* Do we support so many mappings? */
>>>> +	if (unlikely(nsge > scsim->max_sge)) {
>>>> +		csio_warn(hw,
>>>> +			  "More SGEs than can be supported."
>>>> +			  " SGEs: %d, Max SGEs: %d\n", nsge, scsim->max_sge);
>>>> +		csio_inc_stats(scsim, n_unsupp_sge_error);
>>>> +		goto err_dma_unmap;
>>>> +	}
>>>> +
>>>> +	/* Get a free ioreq structure - SM is already set to uninit */
>>>> +	ioreq = csio_get_scsi_ioreq_lock(hw, scsim);
>>>> +	if (!ioreq) {
>>>> +		csio_err(hw, "Out of I/O request elements. Active #:%d\n",
>>>> +			 scsim->stats.n_active);
>>>> +		csio_inc_stats(scsim, n_no_req_error);
>>>> +		goto err_dma_unmap;
>>>> +	}
>>>> +
>>>> +	ioreq->nsge		= nsge;
>>>> +	ioreq->lnode		= ln;
>>>> +	ioreq->rnode		= rn;
>>>> +	ioreq->iq_idx		= sqset->iq_idx;
>>>> +	ioreq->eq_idx		= sqset->eq_idx;
>>>> +	ioreq->wr_status	= 0;
>>>> +	ioreq->drv_status	= CSIO_SUCCESS;
>>>> +	csio_scsi_cmnd(ioreq)	= (void *)cmnd;
>>>> +	ioreq->tmo		= 0;
>>>> +
>>>> +	switch (cmnd->sc_data_direction) {
>>>> +	case DMA_BIDIRECTIONAL:
>>>> +		ioreq->datadir = CSIO_IOREQF_DMA_BIDI;
>>>> +		csio_inc_stats(ln, n_control_requests);
>>>> +		break;
>>>> +	case DMA_TO_DEVICE:
>>>> +		ioreq->datadir = CSIO_IOREQF_DMA_WRITE;
>>>> +		csio_inc_stats(ln, n_output_requests);
>>>> +		ln->stats.n_output_bytes += scsi_bufflen(cmnd);
>>>> +		break;
>>>> +	case DMA_FROM_DEVICE:
>>>> +		ioreq->datadir = CSIO_IOREQF_DMA_READ;
>>>> +		csio_inc_stats(ln, n_input_requests);
>>>> +		ln->stats.n_input_bytes += scsi_bufflen(cmnd);
>>>> +		break;
>>>> +	case DMA_NONE:
>>>> +		ioreq->datadir = CSIO_IOREQF_DMA_NONE;
>>>> +		csio_inc_stats(ln, n_control_requests);
>>>> +		break;
>>>> +	default:
>>>> +		CSIO_DB_ASSERT(0);
>>>> +		break;
>>>> +	}
>>>> +
>>>> +	/* Set cbfn */
>>>> +	ioreq->io_cbfn = csio_scsi_cbfn;
>>>> +
>>>> +	/* Needed during abort */
>>>> +	cmnd->host_scribble = (unsigned char *)ioreq;
>>>> +	cmnd->scsi_done = done;
>>>> +	cmnd->SCp.Message = 0;
>>>> +
>>>> +	/* Kick off SCSI IO SM on the ioreq */
>>>> +	spin_lock_irqsave(&hw->lock, flags);
>>>> +	retval = csio_scsi_start_io(ioreq);
>>>> +	spin_unlock_irqrestore(&hw->lock, flags);
>>>> +
>>>> +	if (retval != CSIO_SUCCESS) {
>>>> +		csio_err(hw, "ioreq: %p couldnt be started, status:%d\n",
>>>> +			 ioreq, retval);
>>>> +		csio_inc_stats(scsim, n_busy_error);
>>>> +		goto err_put_req;
>>>> +	}
>>>> +
>>>> +	return 0;
>>>> +
>>>> +err_put_req:
>>>> +	csio_put_scsi_ioreq_lock(hw, scsim, ioreq);
>>>> +err_dma_unmap:
>>>> +	if (nsge > 0)
>>>> +		scsi_dma_unmap(cmnd);
>>>> +err:
>>>> +	return rv;
>>>> +
>>>> +err_done:
>>>> +	done(cmnd);
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +static DEF_SCSI_QCMD(csio_queuecommand);
>>>> +
>>>
>>> This means that your running with the host_lock held..  I'm not sure if
>>> that is really what you want to do as it really end's up killing
>>> multi-lun small packet performance..
>>>
>>> How about dropping DEF_SCSI_QCMD usage here, and figure out what
>>> actually needs to be protected by the SCSI host_lock within
>>> csio_queuecommand_lck()..?
>>
>> It is on my TODO list for the next version of the driver, after the
>> initial submission. Per the current design, we shouldnt need the
>> host_lock to be held, but I would like to test this change thoroughly
>> before I submit it.
>>
> 
> Sure, it's really quite easy to convert and these days the majority of
> high performance LLDs do run in host-lock-less mode.
> 
> IIRC the libfc based FCoE initiator driver is doing this too..
> 


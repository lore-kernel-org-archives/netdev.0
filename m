From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [PATCH 5/8] csiostor: Chelsio FCoE offload driver submission
 (sources part 5).
Date: Wed, 29 Aug 2012 13:17:10 +0530
Message-ID: <503DC8FE.4010503@chelsio.com>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com>  <1345760873-12101-6-git-send-email-naresh@chelsio.com>  <1345751301.10190.75.camel@haakon2.linux-iscsi.org>  <5037BC94.1050201@chelsio.com>  <1345841784.28432.44.camel@haakon2.linux-iscsi.org>  <50391B17.2040505@chelsio.com> <1345920205.28432.105.camel@haakon2.linux-iscsi.org>
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
In-Reply-To: <1345920205.28432.105.camel@haakon2.linux-iscsi.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/26/2012 12:13 AM, Nicholas A. Bellinger wrote:
> On Sun, 2012-08-26 at 00:06 +0530, Naresh Kumar Inna wrote:
>> On 8/25/2012 2:26 AM, Nicholas A. Bellinger wrote:
>>> On Fri, 2012-08-24 at 23:10 +0530, Naresh Kumar Inna wrote:
>>>> On 8/24/2012 1:18 AM, Nicholas A. Bellinger wrote:
>>>>> On Fri, 2012-08-24 at 03:57 +0530, Naresh Kumar Inna wrote:
>>>>>> This patch contains code to implement the interrupt handling and the fast
>>>>>> path I/O functionality. The interrupt handling includes allocation of
>>>>>> MSIX vectors, registering and implemeting the interrupt service routines.
>>>>>> The fast path I/O functionality includes posting the I/O request to firmware
>>>>>> via Work Requests, tracking/completing them, and handling task management
>>>>>> requests. SCSI midlayer host template implementation is also covered by
>>>>>> this patch.
>>>>>>
>>>>>> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
>>>>>> ---
>>>>>
>>>>> Hi Naresh,
>>>>>
>>>>> My review comments are inline below..
>>>>
>>>> Hi Nicholas,
>>>>
>>>> Thanks for taking the time to review the driver. Please find my replies
>>>> inline.
>>>>
>>>> Regards,
>>>> Naresh.
>>>>
>>>>>
>>>>>>  drivers/scsi/csiostor/csio_isr.c  |  631 ++++++++++
>>>>>>  drivers/scsi/csiostor/csio_scsi.c | 2498 +++++++++++++++++++++++++++++++++++++
>>>>>>  2 files changed, 3129 insertions(+), 0 deletions(-)
>>>>>>  create mode 100644 drivers/scsi/csiostor/csio_isr.c
>>>>>>  create mode 100644 drivers/scsi/csiostor/csio_scsi.c
>>>>>>
> 
> <SNIP>
> 
>>>>>
>>>>>> +/*
>>>>>> + * csio_scsi_init_data_wr - Initialize the READ/WRITE SCSI WR.
>>>>>> + * @req: IO req structure.
>>>>>> + * @oper: read/write
>>>>>> + * @wrp: DMA location to place the payload.
>>>>>> + * @size: Size of WR (including FW WR + immed data + rsp SG entry + data SGL
>>>>>> + * @wrop:  _READ_/_WRITE_
>>>>>> + *
>>>>>> + * Wrapper for populating fw_scsi_read_wr/fw_scsi_write_wr.
>>>>>> + */
>>>>>> +#define csio_scsi_init_data_wr(req, oper, wrp, size, wrop)		       \
>>>>>> +do {									       \
>>>>>> +	struct csio_hw *_hw = (req)->lnode->hwp;			       \
>>>>>> +	struct csio_rnode *_rn = (req)->rnode;				       \
>>>>>> +	struct fw_scsi_##oper##_wr *__wr = (struct fw_scsi_##oper##_wr *)(wrp);\
>>>>>> +	struct ulptx_sgl *_sgl;						       \
>>>>>> +	struct csio_dma_buf *_dma_buf;					       \
>>>>>> +	uint8_t _imm = csio_hw_to_scsim(_hw)->proto_cmd_len;		       \
>>>>>> +	struct scsi_cmnd *scmnd = csio_scsi_cmnd((req));		       \
>>>>>> +									       \
>>>>>> +	__wr->op_immdlen = cpu_to_be32(FW_WR_OP(FW_SCSI##wrop##WR) |           \
>>>>>> +					   FW_SCSI##wrop##WR_IMMDLEN(_imm));   \
>>>>>> +	__wr->flowid_len16 = cpu_to_be32(FW_WR_FLOWID(_rn->flowid) |           \
>>>>>> +					     FW_WR_LEN16(		       \
>>>>>> +						CSIO_ROUNDUP((size), 16)));    \
>>>>>> +	__wr->cookie = (uintptr_t) (req);				       \
>>>>>> +	__wr->iqid = (uint16_t)cpu_to_be16(csio_q_physiqid(_hw,	               \
>>>>>> +							       (req)->iq_idx));\
>>>>>> +	__wr->tmo_val = (uint8_t)((req)->tmo);				       \
>>>>>> +	__wr->use_xfer_cnt = 1;						       \
>>>>>> +	__wr->xfer_cnt = cpu_to_be32(scsi_bufflen(scmnd));		       \
>>>>>> +	__wr->ini_xfer_cnt = cpu_to_be32(scsi_bufflen(scmnd));		       \
>>>>>> +	/* Get RSP DMA buffer */					       \
>>>>>> +	_dma_buf = &(req)->dma_buf;					       \
>>>>>> +									       \
>>>>>> +	/* Prepare RSP SGL */						       \
>>>>>> +	__wr->rsp_dmalen = cpu_to_be32(_dma_buf->len);		               \
>>>>>> +	__wr->rsp_dmaaddr = cpu_to_be64(_dma_buf->paddr);		       \
>>>>>> +									       \
>>>>>> +	__wr->r4 = 0;							       \
>>>>>> +									       \
>>>>>> +	__wr->u.fcoe.ctl_pri = 0;					       \
>>>>>> +	__wr->u.fcoe.cp_en_class = 0;					       \
>>>>>> +	__wr->u.fcoe.r3_lo[0] = 0;					       \
>>>>>> +	__wr->u.fcoe.r3_lo[1] = 0;					       \
>>>>>> +	csio_scsi_fcp_cmnd((req), (void *)((uintptr_t)(wrp) +		       \
>>>>>> +				   sizeof(struct fw_scsi_##oper##_wr)));       \
>>>>>> +									       \
>>>>>> +	/* Move WR pointer past command and immediate data */		       \
>>>>>> +	_sgl = (struct ulptx_sgl *) ((uintptr_t)(wrp) +			       \
>>>>>> +			      sizeof(struct fw_scsi_##oper##_wr) +	       \
>>>>>> +			      ALIGN(_imm, 16));			               \
>>>>>> +									       \
>>>>>> +	/* Fill in the DSGL */						       \
>>>>>> +	csio_scsi_init_ultptx_dsgl(_hw, (req), _sgl);			       \
>>>>>> +									       \
>>>>>> +} while (0)
>>>>>> +
>>>>>
>>>>> This one has four uses of CPP keys.  Just turn those into macros, and
>>>>> leave the rest of the code in a static function.
>>>>>
>>>>
>>>> So what you are suggesting is to have all the lines of the macro
>>>> csio_scsi_init_data_wr() added into a static function, but for the ones
>>>> with the 4 keys. csio_scsi_init_data_wr() will then invoke this new
>>>> function. Is that correct?
>>>>
>>>
>>> Not sure how the above should actually look without actually doing it,
>>> but IMHO the usage of macro just obfuscates what is going on..
>>>
>>> If it's only used a few times, just inline the code into seperate static
>>> functions.  If it's used more than a few times, then use a single static
>>> funciton with macro accessors for the assignment of the various '__wr'
>>> structure members.
>>>
>>> The larger problem with all of these macros is that you can't tell what
>>> is a macro and what is a function.
>>>
>>> If you need to use a CPP macro, please make sure to capitalize the name
>>> of the macro in order to tell the difference between the two.
>>>
>>
>> OK, I will see what I can do to convert this macro into a function.
>>
> 
> Also please change all of the remaining macro names to be capitalized so
> someone reading the code knows the difference between function or macro.
> 

Hi Nicholas,

Did you get a chance to review the rest of the driver patches?

Thanks,
Naresh.

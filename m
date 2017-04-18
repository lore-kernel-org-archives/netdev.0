From: Logan Gunthorpe <logang@deltatee.com>
Subject: Re: [PATCH 16/22] xen-blkfront: Make use of the new sg_map helper
 function
Date: Tue, 18 Apr 2017 09:42:20 -0600
Message-ID: <7930aa93-6106-e12f-ba76-e2771d4ec2dc@deltatee.com>
References: <1492121135-4437-1-git-send-email-logang@deltatee.com>
 <1492121135-4437-17-git-send-email-logang@deltatee.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFD3CD7@AcuExch.aculab.com>
 <20170418142723.GA27133@char.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>,
 Steve Wise <swise@opengridcomputing.com>,
 "linux-nvme@lists.infradead.org" <linux-nvme@lists.infradead.org>,
 "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
 Sumit Semwal <sumit.semwal@linaro.org>,
 "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 "rds-devel@oss.oracle.com" <rds-devel@oss.oracle.com>,
 Sagi Grimberg <sagi@grimberg.me>,
 "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
 Matthew Wilcox <mawilcox@microsoft.com>,
 "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
 Christoph Hellwig <hch@lst.de>,
 "fcoe-devel@open-fcoe.org" <fcoe-devel@open-fcoe.org>,
 Ross Zwisler <ross.zwisler@linux.intel.com>,
 "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
 "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
 Ming Lin <ming.l@ssi.samsung.com>,
 "intel-gfx@list
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 David Laight <David.Laight@ACULAB.COM>, xen-devel@lists.xensource.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170418142723.GA27133@char.us.oracle.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



On 18/04/17 08:27 AM, Konrad Rzeszutek Wilk wrote:
> Interesting that you didn't CC any of the maintainers. Could you 
> do that in the future please?

Please read the cover letter. The distribution list for the patchset
would have been way too large to cc every maintainer (even as limited as
it was, I had mailing lists yelling at me). My plan was to get buy in
for the first patch, get it merged and resend the rest independently to
their respective maintainers. Of course, though, I'd be open to other
suggestions.

>>>
>>> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
>>> ---
>>>  drivers/block/xen-blkfront.c | 33 +++++++++++++++++++++++++++------
>>>  1 file changed, 27 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
>>> index 5067a0a..7dcf41d 100644
>>> --- a/drivers/block/xen-blkfront.c
>>> +++ b/drivers/block/xen-blkfront.c
>>> @@ -807,8 +807,19 @@ static int blkif_queue_rw_req(struct request *req, struct blkfront_ring_info *ri
>>>  		BUG_ON(sg->offset + sg->length > PAGE_SIZE);
>>>
>>>  		if (setup.need_copy) {
>>> -			setup.bvec_off = sg->offset;
>>> -			setup.bvec_data = kmap_atomic(sg_page(sg));
>>> +			setup.bvec_off = 0;
>>> +			setup.bvec_data = sg_map(sg, SG_KMAP_ATOMIC);
>>> +			if (IS_ERR(setup.bvec_data)) {
>>> +				/*
>>> +				 * This should really never happen unless
>>> +				 * the code is changed to use memory that is
>>> +				 * not mappable in the sg. Seeing there is a
>>> +				 * questionable error path out of here,
>>> +				 * we WARN.
>>> +				 */
>>> +				WARN(1, "Non-mappable memory used in sg!");
>>> +				return 1;
>>> +			}
>> ...
>>
>> Perhaps add a flag to mark failure as 'unexpected' and trace (and panic?)
>> inside sg_map().

Thanks, that's a good suggestion. I'll make the change for v2.

Logan

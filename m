From: Logan Gunthorpe <logang@deltatee.com>
Subject: Re: [PATCH 10/22] staging: unisys: visorbus: Make use of the new
 sg_map helper function
Date: Fri, 14 Apr 2017 10:12:30 -0600
Message-ID: <a182336f-ebda-66c6-3a2e-90f2d43582d7__1319.02628713778$1492186379$gmane$org@deltatee.com>
References: <1492121135-4437-1-git-send-email-logang@deltatee.com>
 <1492121135-4437-11-git-send-email-logang@deltatee.com>
 <CY4PR07MB317691139A5B2F902CDA9B0EF0050@CY4PR07MB3176.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise@opengridcomputing.com>,
        Stephen Bates <sbates@raithlin.com>
To: "Kershner, David A" <David.Kershner@unisys.com>,
        Christoph Hellwig <hch@lst.de>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Sagi Grimberg <sagi@grimberg.me>, Jens Axboe <axboe@kernel.dk>,
        Tejun Heo <tj@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Ross Zwisler <ross.zwisler@linux.intel.com>,
        Matthew Wilcox <mawilcox@microsoft.com>,
        Sumit Semwal <sumit.semwal@linaro.org>,
        Ming Lin <ming.l@ssi.samsung.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
        "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
        "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
        "linaro-mm-sig@lists.linaro.org" <linaro-mm-si
Return-path: <netdev-owner@vger.kernel.org>
Received: from ale.deltatee.com ([207.54.116.67]:41026 "EHLO ale.deltatee.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751687AbdDNQMt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Apr 2017 12:12:49 -0400
In-Reply-To: <CY4PR07MB317691139A5B2F902CDA9B0EF0050@CY4PR07MB3176.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Great, thanks!

Logan

On 14/04/17 10:07 AM, Kershner, David A wrote:
> Can you add Acked-by for this patch? 
> 
> Acked-by: David Kershner <david.kershner@unisys.com>
> 
> Tested on s-Par and no problems. 
> 
> Thanks,
> David Kershner
> 
>> ---
>>  drivers/staging/unisys/visorhba/visorhba_main.c | 12 +++++++-----
>>  1 file changed, 7 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/staging/unisys/visorhba/visorhba_main.c
>> b/drivers/staging/unisys/visorhba/visorhba_main.c
>> index 0ce92c8..2d8c8bc 100644
>> --- a/drivers/staging/unisys/visorhba/visorhba_main.c
>> +++ b/drivers/staging/unisys/visorhba/visorhba_main.c
>> @@ -842,7 +842,6 @@ do_scsi_nolinuxstat(struct uiscmdrsp *cmdrsp, struct
>> scsi_cmnd *scsicmd)
>>  	struct scatterlist *sg;
>>  	unsigned int i;
>>  	char *this_page;
>> -	char *this_page_orig;
>>  	int bufind = 0;
>>  	struct visordisk_info *vdisk;
>>  	struct visorhba_devdata *devdata;
>> @@ -869,11 +868,14 @@ do_scsi_nolinuxstat(struct uiscmdrsp *cmdrsp,
>> struct scsi_cmnd *scsicmd)
>>
>>  		sg = scsi_sglist(scsicmd);
>>  		for (i = 0; i < scsi_sg_count(scsicmd); i++) {
>> -			this_page_orig = kmap_atomic(sg_page(sg + i));
>> -			this_page = (void *)((unsigned long)this_page_orig |
>> -					     sg[i].offset);
>> +			this_page = sg_map(sg + i, SG_KMAP_ATOMIC);
>> +			if (IS_ERR(this_page)) {
>> +				scsicmd->result = DID_ERROR << 16;
>> +				return;
>> +			}
>> +
>>  			memcpy(this_page, buf + bufind, sg[i].length);
>> -			kunmap_atomic(this_page_orig);
>> +			sg_unmap(sg + i, this_page, SG_KMAP_ATOMIC);
>>  		}
>>  	} else {
>>  		devdata = (struct visorhba_devdata *)scsidev->host-
>>> hostdata;
>> --
>> 2.1.4
> 

From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: Re: [PATCH 01/22] scatterlist: Introduce sg_map helper functions
Date: Fri, 14 Apr 2017 10:35:18 +0200
Message-ID: <20170414083518.GA25471@lst.de>
References: <1492121135-4437-1-git-send-email-logang@deltatee.com> <1492121135-4437-2-git-send-email-logang@deltatee.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
	"Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Ross Zwisler <ross.zwisler-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Matthew Wilcox <mawilcox-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Sumit Semwal <sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Ming Lin <ming.l-Vzezgt5dB6uUEJcrhfAQsw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, linaro-mm-sig-cunTk1MwBs8s++Sfvej+rw@public.gmane.org,
	intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	megaraidlinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, sparmaintainer-GLv8BlqOqDDQT0dZR+AlfA@public.gmane.org,
	devel@drive
To: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Return-path: <open-iscsi+bncBDUNBGN3R4KRBR4TYLDQKGQEUPQMGEY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <1492121135-4437-2-git-send-email-logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
List-Post: <https://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/open-iscsi
List-Subscribe: <https://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/dma-buf/dma-buf.c b/drivers/dma-buf/dma-buf.c
> index 0007b79..b95934b 100644
> --- a/drivers/dma-buf/dma-buf.c
> +++ b/drivers/dma-buf/dma-buf.c
> @@ -37,6 +37,9 @@
>  
>  #include <uapi/linux/dma-buf.h>
>  
> +/* Prevent the highmem.h macro from aliasing ops->kunmap_atomic */
> +#undef kunmap_atomic
> +
>  static inline int is_dma_buf_file(struct file *);
>  
>  struct dma_buf_list {

I think the right fix here is to rename the operation to unmap_atomic
and send out a little patch for that ASAP.

> + *   Flags can be any of:
> + *	* SG_KMAP	 - Use kmap to create the mapping
> + *	* SG_KMAP_ATOMIC - Use kmap_atomic to map the page atommically.
> + *			   Thus, the rules of that function apply: the cpu
> + *			   may not sleep until it is unmaped.
> + *
> + *   Also, consider carefully whether this function is appropriate. It is
> + *   largely not recommended for new code and if the sgl came from another
> + *   subsystem and you don't know what kind of memory might be in the list
> + *   then you definitely should not call it. Non-mappable memory may be in
> + *   the sgl and thus this function may fail unexpectedly.
> + **/
> +static inline void *sg_map_offset(struct scatterlist *sg, size_t offset,
> +				   int flags)

I'd rather have separate functions for kmap vs kmap_atomic instead of
the flags parameter.  And while you're at it just always pass the 0
offset parameter instead of adding a wrapper..

Otherwise this looks good to me.

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at https://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.

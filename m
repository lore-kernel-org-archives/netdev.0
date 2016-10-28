From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 03/27] swiotlb: Add support for DMA_ATTR_SKIP_CPU_SYNC
Date: Fri, 28 Oct 2016 11:09:26 -0700
Message-ID: <CAKgT0UeG7HXCx7xpyFa5u5ytUEd4s3oor5AX-8b8UbDrqvOgUw@mail.gmail.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
 <20161025153703.4815.13673.stgit@ahduyck-blue-test.jf.intel.com> <20161028173430.GE5112@char.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>, David Miller <davem@davemloft.net>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161028173430.GE5112@char.us.oracle.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 28, 2016 at 10:34 AM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Tue, Oct 25, 2016 at 11:37:03AM -0400, Alexander Duyck wrote:
>> As a first step to making DMA_ATTR_SKIP_CPU_SYNC apply to architectures
>> beyond just ARM I need to make it so that the swiotlb will respect the
>> flag.  In order to do that I also need to update the swiotlb-xen since it
>> heavily makes use of the functionality.
>>
>> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
>
> I am pretty sure I acked it the RFC. Was there a particular
> reason (this is very different from the RFC?) you dropped my ACk?
>
> Thanks.

If I recall you had acked patch 1, but for 2 you had some review
comments on and suggested I change a few things.  What was patch 2 in
the RFC was split out into patches 2 and 3.  That is why I didn't
include an Ack from you for those patches.

Patch 2 is a fix for Xen to address the fact that you could return
either 0 or ~0.  It was part of patch 2 originally and I pulled it out
into a separate patch.

Patch 3 does most of what patch 2 in the RFC was doing before with
fixes to address the fact that I was moving some code to avoid going
over 80 characters.  I found a different way to fix that by just
updating attrs before using it instead of ORing in the value when
passing it as a parameter.

>> @@ -558,11 +560,12 @@ void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
>>                                                                start_dma_addr,
>>                                                                sg_phys(sg),
>>                                                                sg->length,
>> -                                                              dir);
>> +                                                              dir, attrs);
>>                       if (map == SWIOTLB_MAP_ERROR) {
>>                               dev_warn(hwdev, "swiotlb buffer is full\n");
>>                               /* Don't panic here, we expect map_sg users
>>                                  to do proper error handling. */
>> +                             attrs |= DMA_ATTR_SKIP_CPU_SYNC;
>>                               xen_swiotlb_unmap_sg_attrs(hwdev, sgl, i, dir,
>>                                                          attrs);
>>                               sg_dma_len(sgl) = 0;

The biggest difference from patch 2 in the RFC is right here.  This
code before was moving this off to the end of the function and adding
a label which I then jumped to.  I just ORed the
DMA_ATTR_SKIP_CPU_SYNC into attrs and skipped the problem entirely.
It should be harmless to do this way since attrs isn't used anywhere
else once we have had the error.

I hope that helps to clear it up.  So if you want I will add your
Acked-by for patches 2 and 3, but I just wanted to make sure this
worked with the changes you suggested.

Thanks.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

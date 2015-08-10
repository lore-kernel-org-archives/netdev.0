From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v3 18/20] net/xen-netback: Make it running on 64KB page
 granularity
Date: Mon, 10 Aug 2015 12:39:07 +0100
Message-ID: <20150810113907.GH8857@zion.uk.xensource.com>
References: <1438966019-19322-1-git-send-email-julien.grall@citrix.com>
 <1438966019-19322-19-git-send-email-julien.grall@citrix.com>
 <20150808145534.GB14214@zion.uk.xensource.com> <55C8759C.3010507@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55C8759C.3010507@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 10, 2015 at 10:57:48AM +0100, Julien Grall wrote:
[...]
> 
> >>+		info.page = page;
> >>+		gnttab_foreach_grant_in_range(page, offset, bytes,
> >>+					      xenvif_gop_frag_copy_grant,
> >>+					      &info);
> >
> >Looks like I need to at least wait until the API is settle before giving
> >my ack.
> >
> >>  		size -= bytes;
> >>+		offset = 0;
> >
> >This looks wrong. Should be offset += bytes.
> 
> With the new implementation of the loop, each iteration will be on a
> different page.
> So only the first page has an offset different than zero.
> 
> >
> >>
> >>-		/* Next frame */
> >>-		if (offset == PAGE_SIZE && size) {
> >>+		/* Next page */
> >>+		if (size) {
> >>  			BUG_ON(!PageCompound(page));
> >>  			page++;
> >>-			offset = 0;
> >
> >And this should not be deleted, I think.
> >
> >What is the reason for changing offset calculation? I think there is
> >still compound page when using 64K page.
> 
> The compound pages are still working ... gnttab_foreach_grant_in_range is
> called once per page. So the offset can be reset to 0 every time. No need to
> add code which would make the result less clear.
> 
> We only need to know if the size is not 0 to get the next page.
> 
> The patch may not be clear enough to see it's working so I've copied the
> result loop below:
> 
>         while (size > 0) {
>                 BUG_ON(offset >= PAGE_SIZE);
> 
>                 bytes = PAGE_SIZE - offset;
>                 if (bytes > size)
>                         bytes = size;
> 
>                 info.page = page;
>                 gnttab_foreach_grant_in_range(page, offset, bytes,
>                                              xenvif_gop_frag_copy_grant,
>                                               &info);
>                 size -= bytes;
>                 offset = 0;
> 
>                 /* Next page */
>                 if (size) {
>                         BUG_ON(!PageCompound(page));
>                         page++;
>                 }
>         }
> 

Right. That doesn't mean the original code was wrong or anything. But I
don't want to bikeshed about this.

Please add a comment saying that offset is always 0 starting from second
iteration because the gnttab_foreach_grant_in_range makes sure we handle
one page in one go.

Wei.


> Regards,
> 
> -- 
> Julien Grall

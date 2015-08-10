From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [PATCH v3 18/20] net/xen-netback: Make it running on 64KB page
 granularity
Date: Mon, 10 Aug 2015 13:00:40 +0100
Message-ID: <55C89268.2030102@citrix.com>
References: <1438966019-19322-1-git-send-email-julien.grall@citrix.com>
 <1438966019-19322-19-git-send-email-julien.grall@citrix.com>
 <20150808145534.GB14214@zion.uk.xensource.com> <55C8759C.3010507@citrix.com>
 <20150810113907.GH8857@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <stefano.stabellini@eu.citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:53923 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751553AbbHJMBj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 08:01:39 -0400
In-Reply-To: <20150810113907.GH8857@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/15 12:39, Wei Liu wrote:
> On Mon, Aug 10, 2015 at 10:57:48AM +0100, Julien Grall wrote:
>>         while (size > 0) {
>>                 BUG_ON(offset >= PAGE_SIZE);
>>
>>                 bytes = PAGE_SIZE - offset;
>>                 if (bytes > size)
>>                         bytes = size;
>>
>>                 info.page = page;
>>                 gnttab_foreach_grant_in_range(page, offset, bytes,
>>                                              xenvif_gop_frag_copy_grant,
>>                                               &info);
>>                 size -= bytes;
>>                 offset = 0;
>>
>>                 /* Next page */
>>                 if (size) {
>>                         BUG_ON(!PageCompound(page));
>>                         page++;
>>                 }
>>         }
>>
> 
> Right. That doesn't mean the original code was wrong or anything. But I
> don't want to bikeshed about this.

I never said the original code was wrong... The original code was
allowing the possibility to copy less data than the length contained in
page.

In the new version, it has been pushed with the callback
xenvif_gop_frag_copy_grant.

> Please add a comment saying that offset is always 0 starting from second
> iteration because the gnttab_foreach_grant_in_range makes sure we handle
> one page in one go.

I think this is superfluous. To be honest, the comment should have been
on the original version and not in the new one. The construction of the
loop was far from obvious that we copied less data.

In this new version, the reason is not because of
gnttab_foreach_grant_in_range is always a page but how the loop has been
constructed.

If you look how bytes has been defined, it will always contain

min(PAGE_SIZE - offset, size)

So for the first page, this will be PAGE_SIZE - offset. A the end of the
loop we reset the offset 0, indeed we copy all the data of the first
page. For the second page and onwards this will always be PAGE_SIZE
except for the last one where we took size.


Regards,

-- 
Julien Grall

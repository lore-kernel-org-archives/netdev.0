From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH 1/4] xen/netback: implements persistent
 grant with one page pool.
Date: Fri, 16 Nov 2012 09:32:43 +0000
Message-ID: <1353058363.3499.171.camel@zakaz.uk.xensource.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
	 <1352963066-570-1-git-send-email-annie.li@oracle.com>
	 <50A4BC7D.6060707@citrix.com> <50A5A9CF.8030008@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roger Pau Monne <roger.pau@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: ANNIE LI <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:12628 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109Ab2KPJcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 04:32:46 -0500
In-Reply-To: <50A5A9CF.8030008@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-16 at 02:49 +0000, ANNIE LI wrote:
> >
> > Take a look at the following functions from blkback; foreach_grant,
> > add_persistent_gnt and get_persistent_gnt. They are generic functions to
> > deal with persistent grants.
> 
> Ok, thanks.
> Or moving those functions into a separate common file?

Please put them somewhere common.

> > This is highly inefficient, one of the points of using gnttab_set_map_op
> > is that you can queue a bunch of grants, and then map them at the same
> > time using gnttab_map_refs, but here you are using it to map a single
> > grant at a time. You should instead see how much grants you need to map
> > to complete the request and map them all at the same time.
> 
> Yes, it is inefficient here. But this is limited by current netback
> implementation. Current netback is not per-VIF based(not like blkback
> does). After combining persistent grant and non persistent grant
> together, every vif request in the queue may/may not support persistent
> grant. I have to judge whether every vif in the queue supports
> persistent grant or not. If it support, memcpy is used, if not,
> grantcopy is used.

You could (and should) still batch all the grant copies into one
hypercall, e.g. walk the list either doing memcpy or queuing up copyops
as appropriate, then at the end if the queue is non-zero length issue
the hypercall.

I'd expect this lack of batching here and in the other case I just
spotted to have a detrimental affect on guests running with this patch
but not using persistent grants. Did you benchmark that case?

> After making netback per-VIF works, this issue can be fixed.

You've mentioned improvements which are conditional on this work a few
times I think, perhaps it makes sense to make that change first?

Ian.

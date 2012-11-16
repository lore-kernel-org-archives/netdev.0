From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 0/4] Implement persistent grant in xen-netfront/netback
Date: Fri, 16 Nov 2012 11:46:22 +0000
Message-ID: <1353066382.3499.227.camel@zakaz.uk.xensource.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
	 <1353059821.3499.190.camel@zakaz.uk.xensource.com>
	 <50A6255C.10108@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: ANNIE LI <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:28550 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab2KPLqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 06:46:25 -0500
In-Reply-To: <50A6255C.10108@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-16 at 11:37 +0000, ANNIE LI wrote:
> 
> On 2012-11-16 17:57, Ian Campbell wrote:
> > On Thu, 2012-11-15 at 07:03 +0000, Annie Li wrote:
> >> This patch implements persistent grants for xen-netfront/netback.
> > Hang on a sec. It has just occurred to me that netfront/netback in the
> > current mainline kernels don't currently use grant maps at all, they use
> > grant copy on both the tx and rx paths.
> 
> Ah, this patch is based on v3.4-rc3.

Nothing has changed in more recent kernels in this regard.

> >
> > The supposed benefit of persistent grants is to avoid the TLB shootdowns
> > on grant unmap, but in the current code there should be exactly zero of
> > those.
> 
> Is there any performance document about current grant copy code in 
> mainline kernel?

Not AFAIK.

> > If I understand correctly this patch goes from using grant copy
> > operations to persistently mapping frames and then using memcpy on those
> > buffers to copy in/out to local buffers. I'm finding it hard to think of
> > a reason why this should perform any better, do you have a theory which
> > explains it?
> 
> This patch is aiming to fix spin lock issue of grant operations, it 
> comes out to avoid possible grant operations(including grant map and copy).

Makes sense. This is the sort of thing which ought to feature
prominently in commit messages and/or introductory mails.

> > Do you know
> > that they both benefit from this change (rather than for example an
> > improvement in one direction masking a regression in the other).
> 
> On theory, this implementation avoid spinlock issue of grant operation, 
> so they should both benefit from it.

It seems like having netfront simply allocate itself a pool of grant
references which it reuses would give equivalent benefits whilst being a
smaller patch, with no protocol change and avoiding double copying. In
fact by avoiding the double copy I'd expect it to be even better.

> > Were
> > the numbers you previously posted in one particular direction or did you
> > measure both?
> 
> One particular direction, one runs as server, the other runs as client.

I think you need to measure both dom0->domU and domU->dom0 to get the
full picture since AIUI netperf sends the bulk data in only one
direction with just ACKs coming back the other way.

Ian.

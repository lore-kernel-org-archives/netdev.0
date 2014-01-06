From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: fix guest-receive-side
 array sizes
Date: Mon, 6 Jan 2014 13:04:39 +0000
Message-ID: <alpine.DEB.2.02.1401061303480.8667@kaball.uk.xensource.com>
References: <1387790838-8852-1-git-send-email-paul.durrant@citrix.com> <alpine.DEB.2.02.1401061257360.8667@kaball.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Paul Durrant <paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>, <davem@davemloft.net>
To: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37005 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754448AbaAFNFz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 08:05:55 -0500
In-Reply-To: <alpine.DEB.2.02.1401061257360.8667@kaball.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Jan 2014, Stefano Stabellini wrote:
> On Mon, 23 Dec 2013, Paul Durrant wrote:
> > The sizes chosen for the metadata and grant_copy_op arrays on the guest
> > receive size are wrong;
> > 
> > - The meta array is needlessly twice the ring size, when we only ever
> >   consume a single array element per RX ring slot
> > - The grant_copy_op array is way too small. It's sized based on a bogus
> >   assumption: that at most two copy ops will be used per ring slot. This
> >   may have been true at some point in the past but it's clear from looking
> >   at start_new_rx_buffer() that a new ring slot is only consumed if a frag
> >   would overflow the current slot (plus some other conditions) so the actual
> >   limit is MAX_SKB_FRAGS grant_copy_ops per ring slot.
> > 
> > This patch fixes those two sizing issues and, because grant_copy_ops grows
> > so much, it pulls it out into a separate chunk of vmalloc()ed memory.
> > 
> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> > Acked-by: Wei Liu <wei.liu2@citrix.com>
> > Cc: Ian Campbell <ian.campbell@citrix.com>
> > Cc: David Vrabel <david.vrabel@citrix.com>
> 
> Unfortunately this patch (now in 3.13-rc7) breaks the ARM build:
> 
>   CC      drivers/net/xen-netback/interface.o
> drivers/net/xen-netback/interface.c: In function 'xenvif_alloc':
> drivers/net/xen-netback/interface.c:311:2: error: implicit declaration of function 'vmalloc' [-Werror=implicit-function-declaration]
>   vif->grant_copy_op = vmalloc(sizeof(struct gnttab_copy) *
>   ^
> drivers/net/xen-netback/interface.c:311:21: warning: assignment makes pointer from integer without a cast [enabled by default]
>   vif->grant_copy_op = vmalloc(sizeof(struct gnttab_copy) *
>                      ^
> drivers/net/xen-netback/interface.c: In function 'xenvif_free':
> drivers/net/xen-netback/interface.c:499:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>   vfree(vif->grant_copy_op);
>   ^
> cc1: some warnings being treated as errors
> make[3]: *** [drivers/net/xen-netback/interface.o] Error 1
> make[2]: *** [drivers/net/xen-netback] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2
> 
> I suggest we fix it (probably by reverting it) ASAP otherwise we risk
> break the release.

Actually I realized that the issue has already been fixed, thanks!

http://marc.info/?l=linux-kernel&m=138897212904706&w=2

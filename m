From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH 1/4] xen/netback: implements persistent
 grant with one page pool.
Date: Fri, 16 Nov 2012 09:27:54 +0000
Message-ID: <1353058074.3499.166.camel@zakaz.uk.xensource.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
	 <1352963066-570-1-git-send-email-annie.li@oracle.com>
	 <1352970612.3499.43.camel@zakaz.uk.xensource.com>
	 <50A5A285.1030805@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: ANNIE LI <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:5400 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab2KPJ14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 04:27:56 -0500
In-Reply-To: <50A5A285.1030805@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-16 at 02:18 +0000, ANNIE LI wrote:
> In this patch,
> The maximum of memory overhead is about
> 
> (XEN_NETIF_TX_RING_SIZE+XEN_NETIF_RX_RING_SIZE)*PAGE_SIZE  (plus size of grant_ref_t and handle)
> which is about 512 PAGE_SIZE. Normally, without heavy network offload, this maximum can not be reached.
> 
> In next patch of splitting tx/rx pool, the maximum is about

"about" or just "is"?

>  (256+512)PAGE_SIZE.

IOW 3MB.

> >
> >> +
> >> +       return NULL;
> >> +}
> >> +
> >> @@ -1338,7 +1497,11 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
> >>                  gop->source.domid = vif->domid;
> >>                  gop->source.offset = txreq.offset;
> >>
> >> -               gop->dest.u.gmfn = virt_to_mfn(page_address(page));
> >> +               if (!vif->persistent_grant)
> >> +                       gop->dest.u.gmfn = virt_to_mfn(page_address(page));
> >> +               else
> >> +                       gop->dest.u.gmfn = (unsigned long)page_address(page);
> > page_address doesn't return any sort of frame number, does it? This is
> > rather confusing...
> 
> Yes. I only use dest.u.gmfn element to save the page_address here for 
> future memcpy, and it does not mean to use frame number actually. To 
> avoid confusion, here I can use
> 
> gop->dest.u.gmfn = virt_to_mfn(page_address(page));
> 
> and then call mfn_to_virt when doing memcpy.

It seems a bit odd to be using the gop structure in this way when you
aren't actually doing a grant op on it. 

While investigating I noticed:
+static int
+grant_memory_copy_op(unsigned int cmd, void *vuop, unsigned int count,
+                    struct xen_netbk *netbk, bool tx_pool)
...
+       struct gnttab_copy *uop = vuop;

Why void *vuop? Why not struct gnttab_copy * in the parameter?

I also noticed your new grant_memory_copy_op() seems to have unbatched
the grant ops in the non-persistent case, which is going to suck for
performance in non-persistent mode. You need to pull the conditional and
the HYPERVISOR_grant_table_op outside the loop and pass it full array
instead of doing them one at a time.

Ian

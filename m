From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: allow configuration of the size of page in
 __netdev_alloc_frag
Date: Wed, 24 Oct 2012 15:30:03 +0200
Message-ID: <1351085403.6537.102.camel@edumazet-glaptop>
References: <1351078936-14159-1-git-send-email-ian.campbell@citrix.com>
	 <1351081703.6537.99.camel@edumazet-glaptop>
	 <1351084618.18035.27.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63341 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756439Ab2JXNaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 09:30:09 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so250645bkc.19
        for <netdev@vger.kernel.org>; Wed, 24 Oct 2012 06:30:07 -0700 (PDT)
In-Reply-To: <1351084618.18035.27.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-24 at 14:16 +0100, Ian Campbell wrote:
> On Wed, 2012-10-24 at 13:28 +0100, Eric Dumazet wrote:
> > On Wed, 2012-10-24 at 12:42 +0100, Ian Campbell wrote:
> > > The commit 69b08f62e174 "net: use bigger pages in __netdev_alloc_frag"
> > > lead to 70%+ packet loss under Xen when transmitting from physical (as
> > > opposed to virtual) network devices.
> > > 
> > > This is because under Xen pages which are contiguous in the physical
> > > address space may not be contiguous in the DMA space, in fact it is
> > > very likely that they are not. I think there are other architectures
> > > where this is true, although perhaps non quite so aggressive as to
> > > have this property at a per-order-0-page granularity.
> > > 
> > > The real underlying bug here most likely lies in the swiotlb not
> > > correctly handling compound pages, and Konrad is investigating this.
> > > However even with the swiotlb issue fixed the current arrangement
> > > seems likely to result in a lot of bounce buffering which seems likely
> > > to more than offset any benefit from the use of larger pages.
> > > 
> > > Therefore make NETDEV_FRAG_PAGE_MAX_ORDER configurable at runtime and
> > > use this to request order-0 frags under Xen. Also expose this setting
> > > via sysctl.
> > > 
> > > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> > > Cc: Eric Dumazet <edumazet@google.com>
> > > Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > > Cc: netdev@vger.kernel.org
> > > Cc: xen-devel@lists.xen.org
> > > ---
> > 
> > I understand your concern, but this seems a quick/dirty hack at this
> > moment. After setting the sysctl to 0, some tasks may still have some
> > order-3 pages in their cache.
> 
> Right, the sysctl thing might be overkill, I just figured it was useful
> for debugging. When booting in a Xen VM the patch sets it to zero very
> early on, during setup_arch(), which is before any tasks even exist.
> 
> > Your driver must already cope with skb->head being split on several
> > pages.
> > 
> > So what fundamental difference exists with frags ?
> 
> The issue here is with drivers for physical network devices when running
> under Xen not with the Xen paravirtualised network drivers (AKA
> netback/netfront).
> 
> The problem is that pages which are contiguous in the physical address
> space may not be contiguous in the DMA address space. With order>0 pages
> this becomes a problem when you poke down the DMA address and length of
> a compound page into the hardware registers. The DMA address will be
> right for the head of the page but once the hardware steps off the end
> of that it'll get the wrong page.
> 
> I don't think this non-contiguousness between physical and DMA addresses
> is specific to Xen, although it is more frequent under Xen than any real
> hardware platform. (Xen has often been a good canary for these sorts of
> issues which turn out later on to impact other arches too.)
> 
> In theory this could be fixed in all the drivers for physical network
> devices, but that would be a lot of effort (and probably a fair bit of
> ugliness in the drivers) for a gain which was only relevant to Xen. 

I still have concerns about skb->head that you dint really answered.

Why skb->head can be on order-1 or order-2 pages and this is working ?

It seems to me its a driver issue, for example
drivers/net/xen-netfront.c has assumptions that can be easily fixed.

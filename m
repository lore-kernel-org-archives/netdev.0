From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH 03/13] xen-netback: implement TX persistent grants
Date: Tue, 2 Jun 2015 15:53:59 +0100
Message-ID: <20150602145359.GP19403@zion.uk.xensource.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-4-git-send-email-joao.martins@neclab.eu>
 <20150519152342.GB26335@zion.uk.xensource.com>
 <30CF0FF9-3B1D-48AF-AFB4-73E20C404357@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Joao Martins <Joao.Martins@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:25659 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758542AbbFBOyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 10:54:03 -0400
Content-Disposition: inline
In-Reply-To: <30CF0FF9-3B1D-48AF-AFB4-73E20C404357@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 22, 2015 at 10:24:39AM +0000, Joao Martins wrote:
> 
> On 19 May 2015, at 17:23, Wei Liu <wei.liu2@citrix.com> wrote:
> > On Tue, May 12, 2015 at 07:18:27PM +0200, Joao Martins wrote:
> >> Introduces persistent grants for TX path which follows similar code path
> >> as the grant mapping.
> >> 
> >> It starts by checking if there's a persistent grant available for header
> >> and frags grefs and if so setting it in tx_pgrants. If no persistent grant
> >> is found in the tree for the header it will resort to grant copy (but
> >> preparing the map ops and add them laster). For the frags it will use the
> >                                     ^
> >                                     later
> > 
> >> tree page pool, and in case of no pages it fallbacks to grant map/unmap
> >> using mmap_pages. When skb destructor callback gets called we release the
> >> slot and persistent grant within the callback to avoid waking up the
> >> dealloc thread. As long as there are no unmaps to done the dealloc thread
> >> will remain inactive.
> >> 
> > 
> > This scheme looks complicated. Can we just only use one
> > scheme at a time? What's the rationale for using this combined scheme?
> > Maybe you're thinking about using a max_grants < ring_size to save
> > memory?
> 
> Yes, my purpose was to allow a max_grants < ring_size to save amount of
> memory mapped. I did a bulk transfer test with iperf and the max amount of
> grants in tree was <160 TX gnts, without affecting the max performance;
> tough using pktgen fills the tree completely.
> The second reason is to handle the case for a (malicious?) frontend providing
> more grefs than the max allowed in which I would fallback to grant map/unmap.
> 

This is indeed a valid concern. The only method is to expires oldest
grant when that happens -- but this is just complexity in another place,
not really simplifying anything.

> > 
> > Only skim the patch. I will do detailed reviews after we're sure this is
> > the right way to go.
> > 
[...]
> > 
> > Under what circumstance can we retrieve a already in use persistent
> > grant? You seem to suggest this is a bug in RX case.
> 
> A guest could share try to share the same mapped page in multiple frags,
> in which case I fallback to map/unmap. I think this is a limitation in
> the way we manage the persistent gnts where we can only have a single
> reference of a persistent grant inflight.
> 

How much harder would it be to ref-count inflight grants? Would that
simplify or perplex things? I'm just asking, not suggesting you should
choose ref-counting over current scheme.

In principle I favour simple code path over optimisation for every
possible corner case.

Wei.

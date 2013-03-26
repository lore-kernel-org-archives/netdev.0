From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before
 copying
Date: Tue, 26 Mar 2013 09:16:10 +0000
Message-ID: <291EDFCB1E9E224A99088639C4762022013F7D8E0DC6@LONPMAILBOX01.citrite.net>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
	<1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
	<5150699C.6080209@citrix.com>
	<CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>
	<51507C9B.3080109@citrix.com>
	<CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com>
	<51509789.8090608@citrix.com> <20130325190911.GC7004@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <liuw@liuw.name>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:45190 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932225Ab3CZJQE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 05:16:04 -0400
In-Reply-To: <20130325190911.GC7004@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: xen-devel-bounces@lists.xen.org [mailto:xen-devel-
> bounces@lists.xen.org] On Behalf Of Wei Liu
> Sent: 25 March 2013 19:09
> To: David Vrabel
> Cc: Ian Campbell; konrad.wilk@oracle.com; netdev@vger.kernel.org; Wei
> Liu; xen-devel@lists.xen.org; annie.li@oracle.com
> Subject: Re: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before
> copying
> 
> On Mon, Mar 25, 2013 at 06:29:29PM +0000, David Vrabel wrote:
> > >>
> > >
> > > Are you suggesting move the default macro value to header file? It is
> > > just an estimation, I have no knowledge of the accurate maximum value,
> > > so I think make it part of the protocol a bad idea.
> >
> > How is the author of a new frontend supposed to know how many slots
> they
> > can use per packet if it is not precisely defined?
> >
> 
> A new frontend shuold use the scheme you mentioned below to get the
> maximum value. For old frontends that cannot be fixed, administrator can
> configure max_skb_slots to accommodate their need.
> 
> > > Do you have a handle on the maximum value?
> >
> > Backends should provide the value to the frontend via a xenstore key
> > (e.g., max-slots-per-frame).  This value should be at least 18 (the
> > historical value of MAX_SKB_FRAGS).
> >
> > The frontend may use up to this specified value or 17 if the
> > max-slots-per-frame key is missing.
> >
> > Supporting at least 18 in the backend is required for existing
> > frontends.  Limiting frontends to 17 allows them to work with all
> > backends (including recent Linux version that only supported 17).
> >
> > It's not clear why 19 or 20 were suggested as possible values.  I
> > checked back to 2.6.18 and MAX_SKB_FRAGS there is (65536/PAGE_SIZE +
> 2)
> 
> Because the check is >= MAX_SKB_FRAGS originally and James Harper told
> me that "Windows stops counting on 20".
> 

For the Citrix PV drivers I lifted the #define of MAX_SKB_FRAGS from the dom0 kernel (i.e. 18). If a packet coming from the stack has more than that number of fragments then it's copied and coalesced. The value advertised for TSO size is chosen such that a maximally sized TSO will always fit in 18 fragments after coalescing but (since this is Windows) the drivers don't trust the stack to stick to that limit and will drop a packet if it won't fit.

It seems reasonable that, since the backend is copying anyway, that it should handle any fragment list coming from the frontend that it can. This would allow the copy-and-coalesce code to be removed from the frontend (and the double-copy avoided). If there is a maximum backend packet size though then I think this needs to be advertised to the frontend. The backend should clearly bin packets coming from the frontend that exceed that limit but advertising that limit in xenstore allows the frontend to choose the right TSO maximum size to advertise to its stack, rather than having to make it based on some historical value that actually has little meaning (in the absence of grant mapping).

  Paul

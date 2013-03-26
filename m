From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before
 copying
Date: Tue, 26 Mar 2013 09:51:00 +0000
Message-ID: <20130326095100.GE7004@zion.uk.xensource.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
 <1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
 <5150699C.6080209@citrix.com>
 <CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>
 <51507C9B.3080109@citrix.com>
 <CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com>
 <51509789.8090608@citrix.com>
 <20130325190911.GC7004@zion.uk.xensource.com>
 <291EDFCB1E9E224A99088639C4762022013F7D8E0DC6@LONPMAILBOX01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <liuw@liuw.name>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:18472 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652Ab3CZJvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 05:51:02 -0400
Content-Disposition: inline
In-Reply-To: <291EDFCB1E9E224A99088639C4762022013F7D8E0DC6@LONPMAILBOX01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 26, 2013 at 09:16:10AM +0000, Paul Durrant wrote:
> > >
> > > It's not clear why 19 or 20 were suggested as possible values.  I
> > > checked back to 2.6.18 and MAX_SKB_FRAGS there is (65536/PAGE_SIZE
> > > +
> > 2)
> > 
> > Because the check is >= MAX_SKB_FRAGS originally and James Harper
> > told me that "Windows stops counting on 20".
> > 
> 
> For the Citrix PV drivers I lifted the #define of MAX_SKB_FRAGS from
> the dom0 kernel (i.e. 18). If a packet coming from the stack has more

That means Citrix PV drivers cannot run on a vanilla kernel backend
because upstream MAX_SKB_FRAGS now is 17. The scope of the patch is to
fix this sort of problems without touching frontend because it is
impossible for us to fix every frontend in the world.

> than that number of fragments then it's copied and coalesced. The
> value advertised for TSO size is chosen such that a maximally sized
> TSO will always fit in 18 fragments after coalescing but (since this
> is Windows) the drivers don't trust the stack to stick to that limit
> and will drop a packet if it won't fit.
> 
> It seems reasonable that, since the backend is copying anyway, that it
> should handle any fragment list coming from the frontend that it can.
> This would allow the copy-and-coalesce code to be removed from the
> frontend (and the double-copy avoided). If there is a maximum backend
> packet size though then I think this needs to be advertised to the
> frontend. The backend should clearly bin packets coming from the
> frontend that exceed that limit but advertising that limit in xenstore
> allows the frontend to choose the right TSO maximum size to advertise
> to its stack, rather than having to make it based on some historical
> value that actually has little meaning (in the absence of grant
> mapping).
> 

The historical is choosen based on the idea that it should cope with all
known frontend limits and leave a bit more space for frontends that
slightly cross the line. Advertising through Xenstore is the future plan
as it cannot be done without modifying frontend.


Wei.

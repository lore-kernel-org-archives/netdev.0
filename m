From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 05/10] net: move destructor_arg to the front of sk_buff.
Date: Wed, 11 Apr 2012 08:00:41 +0000
Message-ID: <1334131241.12209.199.camel@dagon.hellion.org.uk>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
	 <1334067984-7706-5-git-send-email-ian.campbell@citrix.com>
	 <4F847CF9.3090701@intel.com> <1334083265.5300.288.camel@edumazet-glaptop>
	 <4F8486E7.5050604@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:64378 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871Ab2DKIBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 04:01:00 -0400
In-Reply-To: <4F8486E7.5050604@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 20:15 +0100, Alexander Duyck wrote:
> On 04/10/2012 11:41 AM, Eric Dumazet wrote:
> > On Tue, 2012-04-10 at 11:33 -0700, Alexander Duyck wrote:
> >
> >> Have you checked this for 32 bit as well as 64?  Based on my math your
> >> next patch will still mess up the memset on 32 bit with the structure
> >> being split somewhere just in front of hwtstamps.
> >>
> >> Why not just take frags and move it to the start of the structure?  It
> >> is already an unknown value because it can be either 16 or 17 depending
> >> on the value of PAGE_SIZE, and since you are making changes to frags the
> >> changes wouldn't impact the alignment of the other values later on since
> >> you are aligning the end of the structure.  That way you would be
> >> guaranteed that all of the fields that will be memset would be in the
> >> last 64 bytes.
> >>
> > Now when a fragmented packet is copied in pskb_expand_head(), you access
> > two separate zones of memory to copy the shinfo. But its supposed to be
> > slow path.
> >
> > Problem with this is that the offsets of often used fields will be big
> > (instead of being < 127) and code will be bigger on x86.
> 
> Actually now that I think about it my concerns go much further than the
> memset.  I'm convinced that this is going to cause a pretty significant
> performance regression on multiple drivers, especially on non x86_64
> architecture.  What we have right now on most platforms is a
> skb_shared_info structure in which everything up to and including frag 0
> is all in one cache line.  This gives us pretty good performance for igb
> and ixgbe since that is our common case when jumbo frames are not
> enabled is to split the head and place the data in a page.

With all the changes in this series it is still possible to fit a
maximum standard MTU frame and the shinfo on the same 4K page while also
have the skb_shared_info up to and including frag [0] aligned to the
same 64 byte cache line. 

The only exception is destructor_arg on 64 bit which is on the preceding
cache line but that is not a field used in any hot path.

> However the change being recommend here only resolves the issue for one
> specific architecture, and that is what I don't agree with.  What we
> need is a solution that also works for 64K pages or 32 bit pointers and
> I am fairly certain this current solution does not.

I think it does work for 32 bit pointers. What issue to do you see with
64K pages?

Ian.

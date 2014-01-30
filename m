From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Thu, 30 Jan 2014 13:55:23 -0800
Message-ID: <20140130215523.GC14228@xanatos>
References: <20140130211816.GB3787@xanatos>
 <Pine.LNX.4.44L0.1401301630340.31548-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Mark Lord <mlord@pobox.com>, Freddy Xin <freddy@asix.com.tw>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52218 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752584AbaA3Vz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jan 2014 16:55:27 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.1401301630340.31548-100000@netrider.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 04:43:54PM -0500, Alan Stern wrote:
> On Thu, 30 Jan 2014, Sarah Sharp wrote:
> 
> > It should not matter what alignment or length of scatter-gather list the
> > upper layers pass the xHCI driver, it should just work.  I want to do
> > this fix right, by changing the fundamental way we queue TRBs to the
> > rings to fit the TD rules.  We should break each TD into fragment-sized
> > chunks, and add a link TRB in the middle of a segment where necessary.
> 
> That's a good plan.  However _some_ restriction will turn out to be
> necessary.
> 
> For example, what will you do if a driver submits an SG list containing
> 300 elements, each 3 bytes long?  That's too many to fit in a single
> ring segment, but it's smaller than a TD fragment -- it's even smaller
> than maxpacket -- so there's no place to split it.  (Not that I think
> drivers _will_ submit requests like this; this is just to demonstrate
> the point.)
> 
> It ought to be acceptable to require, for example, that an SG URB 
> contain no more than (say) 100 elements that are smaller than 512 
> bytes.

At that point, the xHCI driver or USB core should probably use a bounce
buffer.  It feels like we should attempt to push down scatter-gather
lists as far down in the stack as possible, so the upper layers don't
have to care what alignment, length, or random 64KB boundary splits we
need.

> ehci-hcd gets along okay with the restriction that each SG element 
> except the last has to be a multiple of the maxpacket size.  xhci-hcd 
> can relax this quite a lot, but not all the way.

What does the EHCI driver do when it receives a SG list from the USB
networking layer that violates this restriction?

Sarah Sharp

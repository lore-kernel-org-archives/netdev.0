From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Thu, 30 Jan 2014 16:43:54 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1401301630340.31548-100000@netrider.rowland.org>
References: <20140130211816.GB3787@xanatos>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Laight <David.Laight@ACULAB.COM>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Mark Lord <mlord@pobox.com>, Freddy Xin <freddy@asix.com.tw>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netrider.rowland.org ([192.131.102.5]:41839 "HELO
	netrider.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753401AbaA3Vn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 16:43:56 -0500
In-Reply-To: <20140130211816.GB3787@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Jan 2014, Sarah Sharp wrote:

> It should not matter what alignment or length of scatter-gather list the
> upper layers pass the xHCI driver, it should just work.  I want to do
> this fix right, by changing the fundamental way we queue TRBs to the
> rings to fit the TD rules.  We should break each TD into fragment-sized
> chunks, and add a link TRB in the middle of a segment where necessary.

That's a good plan.  However _some_ restriction will turn out to be
necessary.

For example, what will you do if a driver submits an SG list containing
300 elements, each 3 bytes long?  That's too many to fit in a single
ring segment, but it's smaller than a TD fragment -- it's even smaller
than maxpacket -- so there's no place to split it.  (Not that I think
drivers _will_ submit requests like this; this is just to demonstrate
the point.)

It ought to be acceptable to require, for example, that an SG URB 
contain no more than (say) 100 elements that are smaller than 512 
bytes.

ehci-hcd gets along okay with the restriction that each SG element 
except the last has to be a multiple of the maxpacket size.  xhci-hcd 
can relax this quite a lot, but not all the way.

Alan Stern

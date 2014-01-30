From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Thu, 30 Jan 2014 13:18:16 -0800
Message-ID: <20140130211816.GB3787@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Mark Lord <mlord@pobox.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61917 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751468AbaA3VSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jan 2014 16:18:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 05:35:08PM +0100, Peter Stuge wrote:
> David Laight wrote:
> > > Where's the 8k coming from?
> > 
> > My memory, I meant 16k :-(
> 
> No problem. But what about that alignment? It seems that userspace
> needs to start caring about alignment with xhci, right?

We need to step back and reassess the larger picture here, instead of
trying to fire-fight all the regressions caused by the link TRB commit
(35773dac5f86 "usb: xhci: Link TRB must not occur within a USB payload
burst").

We shouldn't need to make userspace start to worry about alignment at
all.  libusb worked in the past, before the link TRB fix went in.  We
*cannot* break userspace USB drivers.  The breakage needs to be fixed in
the USB core or the xHCI driver.

Commit 35773dac5f86 was meant to be a short-term bandaid fix, but it's
already caused at least four different regressions.  Some we've fixed,
some have proposed solutions that David has sent.

The storage layer is getting borked because it submits scatter-gather
lists longer than what will fit on a segment, and now libusb has the
same issue.  One xHCI host controller stopped responding to commands,
and reverting the bandaid fix helped.  The implications of this change
just keep coming in, and I'm not comfortable wall-papering over the
issues.

On the flip side, it seems that the only devices that have been helped
by the bandaid fix patch are USB ethernet devices using the ax88179_178a
driver.  (Mark Lord still needs to confirm which device he uses.)  I
have not seen any other reports that other USB ethernet chipsets were
broken in 3.12 by the USB networking layer adding scatter-gather
support.

It should not matter what alignment or length of scatter-gather list the
upper layers pass the xHCI driver, it should just work.  I want to do
this fix right, by changing the fundamental way we queue TRBs to the
rings to fit the TD rules.  We should break each TD into fragment-sized
chunks, and add a link TRB in the middle of a segment where necessary.

Let's do this fix the right way, instead of wall papering over the
issue.  Here's what we should do:

1. Disable scatter-gather for the ax88179_178a driver when it's under an
   xHCI host.

2. Revert the following commits:
   f2d9b991c549 xhci: Set scatter-gather limit to avoid failed block writes.
   d6c9ea9069af xhci: Avoid infinite loop when sg urb requires too many trbs
   35773dac5f86 usb: xhci: Link TRB must not occur within a USB payload burst

3. Dan and Mathias can work together to come up with an overall plan to
   change the xHCI driver architecture to be fully compliant with the TD
   fragment rules.  That can be done over the next few kernel releases.

The end result is that we don't destabilize storage or break userspace
USB drivers, we don't break people's xHCI host controllers,
the ax88179_178a USB ethernet devices still work under xHCI (a bit with
worse performance), and other USB ethernet devices still get the
performance improvement introduced in 3.12.

Sarah Sharp

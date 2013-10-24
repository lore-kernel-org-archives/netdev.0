From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: transmit lockup using smsc95xx ethernet on usb3
Date: Thu, 24 Oct 2013 16:05:28 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73AF@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B738B@saturn3.aculab.com> <20131017000758.GL7082@xanatos>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	"Xenia Ragiadakou" <burzalodowa@gmail.com>
To: "Sarah Sharp" <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59819 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753818Ab3JXPHZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 11:07:25 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14210-06 for <netdev@vger.kernel.org>;
 Thu, 24 Oct 2013 16:07:22 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20131017000758.GL7082@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Have you tried the latest stable kernel or the latest -rc kernel?

I've built a kernel based on Linus's tree from last Friday, 3.12-rc6 ish.
Commented out the trace for short reads - happens all the time.

I've not seen an error on a Bo yet, the failure rate is depressingly low.
I have had an error that started with an interrupt completion (I think
from the root), that leads to a full unplug-replug sequence that
overfilled the kernel message buffer (rebuilt with a much bigger buffer).

I've just got a error -71 from a Bi. This generates:
(There are actually two separated by a Bo completion and setup.

[175908.563068] xhci_hcd 0000:00:14.0: Transfer error on endpoint
[175908.563070] xhci_hcd 0000:00:14.0: Cleaning up stalled endpoint ring
[175908.563072] xhci_hcd 0000:00:14.0: Finding segment containing stopped TRB.
[175908.563074] xhci_hcd 0000:00:14.0: Finding endpoint context
[175908.563076] xhci_hcd 0000:00:14.0: Finding segment containing last TRB in TD.
[175908.563078] xhci_hcd 0000:00:14.0: Cycle state = 0x1
[175908.563081] xhci_hcd 0000:00:14.0: New dequeue segment = ffff8800d6a817e0 (virtual)
[175908.563089] xhci_hcd 0000:00:14.0: New dequeue pointer = 0x2137a4b90 (DMA)
[175908.563096] xhci_hcd 0000:00:14.0: Queueing new dequeue state
[175908.563104] xhci_hcd 0000:00:14.0: Set TR Deq Ptr cmd, new deq seg = ffff8800d6a817e0 (0x2137a4800 dma), new deq ptr = ffff8802137a4b90 (0x2137a4b90 dma), new cycle = 1
[175908.563110] xhci_hcd 0000:00:14.0: // Ding dong!
[175908.563119] xhci_hcd 0000:00:14.0: Giveback URB ffff8802114fd9c0, len = 0, expected = 18944, status = -71
[175908.563122] xhci_hcd 0000:00:14.0: Ignoring reset ep completion code of 1
[175908.563125] xhci_hcd 0000:00:14.0: Successful Set TR Deq Ptr cmd, deq = @2137a4b91

What is interesting is that the usbmon trace then shows only 2 Bi URB being used
(rather than 4). After 125ms (assuming the usbmon timestamps are us)
another 2 URB are added.
Since the URB are usually recycled (or at least freed and immediately realloced
so getting the same address) I wonder if this is a memory leak?
In any case waiting that long before adding the URB back doesn't seem right.

I don't think I've seen an error that only affected the Bi side before, so
don't know whether the recover behaviour has changed.

FWIW we have identified something 'sub-optimal' with the pcb layout that might
be responsible for noise on the USB data/clock source. However the xhci driver
should recover from such errors.
If the hw guys fix the pcb I'm going to need to keep a failing system!

	David

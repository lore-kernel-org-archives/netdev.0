From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Fri, 31 Jan 2014 10:14:46 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B5B78@AcuExch.aculab.com>
References: <20140130211816.GB3787@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	"Dan Williams" <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Mark Lord <mlord@pobox.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: 'Sarah Sharp' <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59289 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751006AbaAaKPS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 05:15:18 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09404-09 for <netdev@vger.kernel.org>;
 Fri, 31 Jan 2014 10:15:14 +0000 (GMT)
In-Reply-To: <20140130211816.GB3787@xanatos>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarah Sharp
> We need to step back and reassess the larger picture here, instead of
> trying to fire-fight all the regressions caused by the link TRB commit
> (35773dac5f86 "usb: xhci: Link TRB must not occur within a USB payload
> burst").

Some of the breakage seems to have been related to the PM and readq/writeq
changes.

The main problem with that patch is that it limited the number of
fragments.

> We shouldn't need to make userspace start to worry about alignment at
> all.  libusb worked in the past, before the link TRB fix went in.  We
> *cannot* break userspace USB drivers.  The breakage needs to be fixed in
> the USB core or the xHCI driver.

Userspace doesn't care since everything gets copied into aligned
kernel fragments - otherwise the other usb controllers wouldn't work.

> Commit 35773dac5f86 was meant to be a short-term bandaid fix, but it's
> already caused at least four different regressions.  Some we've fixed,
> some have proposed solutions that David has sent.
> 
> The storage layer is getting borked because it submits scatter-gather
> lists longer than what will fit on a segment, and now libusb has the
> same issue.  One xHCI host controller stopped responding to commands,
> and reverting the bandaid fix helped.  The implications of this change
> just keep coming in, and I'm not comfortable wall-papering over the
> issues.

The transfers from the storage layer are actually all 'suitably aligned'.
Fragments can cross 64k boundaries, but they all start on 4k boundaries.

> On the flip side, it seems that the only devices that have been helped
> by the bandaid fix patch are USB ethernet devices using the ax88179_178a
> driver.  (Mark Lord still needs to confirm which device he uses.)  I
> have not seen any other reports that other USB ethernet chipsets were
> broken in 3.12 by the USB networking layer adding scatter-gather
> support.

That is the only usbnet driver for which SG support is enabled.
I believe it was all enabled because the ax88179_178a is the only
one that can be expected to saturate Ge and supports TCP segmentation
offload (TSO) - where the buffer is almost always fragmented.
With TSO transmits are almost certainly single fragments.

> It should not matter what alignment or length of scatter-gather list the
> upper layers pass the xHCI driver, it should just work.  I want to do
> this fix right, by changing the fundamental way we queue TRBs to the
> rings to fit the TD rules.  We should break each TD into fragment-sized
> chunks, and add a link TRB in the middle of a segment where necessary.

There will always be some transfer requests that make this impossible
(without using a bounce buffer).
In practise nothing will send such bad transfers.
To avoid excessive work you need to be told whether the transfer is
aligned (everything from the block layer and libusb is) or misaligned
(potentially everything from usbnet).
The limits on the number length of SG list has to be different for the
two types of request.

> Let's do this fix the right way, instead of wall papering over the
> issue.  Here's what we should do:
> 
> 1. Disable scatter-gather for the ax88179_178a driver when it's under an
>    xHCI host.

That can be done by simple not setting the flag on the xhci driver.
However you also need to double check that this disables TSO.

> 2. Revert the following commits:
>    f2d9b991c549 xhci: Set scatter-gather limit to avoid failed block writes.
>    d6c9ea9069af xhci: Avoid infinite loop when sg urb requires too many trbs
>    35773dac5f86 usb: xhci: Link TRB must not occur within a USB payload burst
> 
> 3. Dan and Mathias can work together to come up with an overall plan to
>    change the xHCI driver architecture to be fully compliant with the TD
>    fragment rules.  That can be done over the next few kernel releases.

Don't forget that these rules can affect isoc transfers as well.
Even without SG, the buffer can cross a 64k boundary and thus
need splitting into separate TRB - which might need to be in
different ring segments.
Easily fixable by writing the LINK early (expect that the TRB writing
code looks for LINK TRBs).
 
> The end result is that we don't destabilize storage or break userspace
> USB drivers, we don't break people's xHCI host controllers,
> the ax88179_178a USB ethernet devices still work under xHCI (a bit with
> worse performance), and other USB ethernet devices still get the
> performance improvement introduced in 3.12.

From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC 1/1] usb: Tell xhci when usb data might be	misaligned
Date: Fri, 31 Jan 2014 13:52:40 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B5DC1@AcuExch.aculab.com>
References: <20140130211816.GB3787@xanatos>
 <063D6719AE5E284EB5DD2968C1650D6D0F6B5B78@AcuExch.aculab.com>
 <20140131132146.2833.qmail@stuge.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Sarah Sharp' <sarah.a.sharp@linux.intel.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Mark Lord <mlord@pobox.com>,
	"Alan Stern" <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: 'Peter Stuge' <peter@stuge.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35412 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751411AbaAaNxN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 08:53:13 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20511-10 for <netdev@vger.kernel.org>;
 Fri, 31 Jan 2014 13:53:09 +0000 (GMT)
In-Reply-To: <20140131132146.2833.qmail@stuge.se>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Stuge [mailto:peter@stuge.se]
> > Userspace doesn't care since everything gets copied into aligned
> > kernel fragments - otherwise the other usb controllers wouldn't work.
> 
> OK, but not so great if someone wants to squeeze the most performance
> possible out of USB also from userspace.
> 
> I'm going off on a tangent now but would it make sense to allow
> userspace to do alignment if it wants to, and have a way to tell
> the kernel when urb buffers are pre-aligned?

I can only see that mattering if either:
1) The userspace buffers are (say) 4n+1 aligned and the kernel
   decides to align the copy_from_user().
2) The code is doing buffer-loaning.

Personally I'm not at all sure how often buffer-loaning helps
(given the cost of the TLB shootdowns that it often implies).
I guess it might be ok if the memory doesn't have to be given
a KVA and the user program avoids any COW.
In any case and such code could be limited to page-aligned transfers.
And/or the user code would have to know at least some of the constraints.

The other usb controllers only support 'message' aligned transfers
(512 bytes for USB2). All the code I've found achieves this by using
page aligned (maybe 4k aligned) fragments. xhci trivially supports this
(it has since the 'ring expansion' code was added).

xhci can also easily support:
1) Arbitrary fragmentation for a limited number of fragments
   (by constraining the fragments to a single ring segment).
2) Arbitrary fragmentation provided all the fragments (except the
   last) exceed some minimal length (by splitting the current or
   previous fragment at the appropriate boundary).

The code for the second is probably worth adding just in case
a 4k fragment crosses a 64k boundary.

Since arbitrarily fragmented packets can't be sent to other controllers
it does seem sensible for the code generating the urb so say that
it is (or might be) fragmented like that.

	David

 

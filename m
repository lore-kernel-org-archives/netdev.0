From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: Active URB submitted twice in pegasus driver
Date: Tue, 26 Mar 2013 10:01:40 -0700
Message-ID: <20130326170140.GC10317@xanatos>
References: <20130325223834.GF6869@xanatos>
 <alpine.DEB.2.02.1303261655450.3724@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petko Manolov <petkan@users.sourceforge.net>,
	linux-usb@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49458 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752086Ab3CZRBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 13:01:41 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1303261655450.3724@fry.nucleusys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 26, 2013 at 05:22:07PM +0200, Petko Manolov wrote:
> On Mon, 25 Mar 2013, Sarah Sharp wrote:
> 
> >Hi Petko,
> >
> >I'm testing a USB to ethernet adapter with Greg's usb-linus branch (based
> >on 3.9-rc4).  I'm seeing an odd behavior, and I'm suspicious that a
> >second behavior found by Stephen Hemminger may also be related:
> >
> >http://marc.info/?l=linux-usb&m=136364625519235&w=2
> >
> >When I load the pegasus driver for this adapter (without an ethernet
> >cable hooked to it), and this is on a cold system boot or a complete
> >unloading and reloading of the usbcore, I get the following warning:
> 
> Unfortunately the machine i ran my tests on does not have xHCI nor i
> used Greg's tree.  I did not observe this warning on both 3.8.4 and
> Linus' 3.9-rc4.  It looks like to me that the issue is outside the
> driver code.

Or it could be a race condition that's only triggered by the xHCI driver
(or me having xHCI debugging turned on).  Control transfer completions
may be delayed when I have debug turned on.

> However, i am curious whether you experience the same problem with
> other (non-ADMtek based) usb-to-lan adapters which support
> xxx_set_multicast().

The only other USB to ethernet adapter I have is also an ADMteck device:

Bus 001 Device 008: ID 07a6:8513 ADMtek, Inc. AN8513 Ethernet

> These calls are asynchronous by nature and should also trigger this
> warning.  Please let me know if this is not the case so i start
> digging into pegasus.c.

What do you mean by an asynchronous call?  Do you mean that
xxx_set_multicast() could be called at any time?

After taking a brief glance at the pegasus code, pegasus_set_multicast
looks broken.  It sets the control URB status to zero and calls
ctrl_callback(), which does some stuff if the URB status is zero.  It
doesn't look like pegasus_set_multicast() is an URB callback function,
so why in the world is it touching a control URB that could possibly be
in flight else where?

It looks like the control URB is used to do things like get or set
registers, so what's stopping the upper layers from calling get
registers (which will submit the control URB and schedule a wait queue),
and then pegasus_set_multicast(), which will go overwrite the active URB
status?  USB device drivers should not be writing or reading fields in
a submitted URB until the completion handler's callback function is
called.

Sarah Sharp

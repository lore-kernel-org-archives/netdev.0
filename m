From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Fri, 31 Jan 2014 11:00:35 -0800
Message-ID: <20140131190035.GB18262@xanatos>
References: <20140130211816.GB3787@xanatos>
 <87iot1qgv6.fsf@nemi.mork.no>
 <20140130221511.GD14228@xanatos>
 <CACVXFVMVoMAH3DRiv-VYZL8VWq2Rw+fZwreVtUVm1M44HR+X8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	David Laight <David.Laight@aculab.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Mark Lord <mlord@pobox.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:9618 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932236AbaAaTAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jan 2014 14:00:38 -0500
Content-Disposition: inline
In-Reply-To: <CACVXFVMVoMAH3DRiv-VYZL8VWq2Rw+fZwreVtUVm1M44HR+X8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 31, 2014 at 08:17:58AM +0800, Ming Lei wrote:
> On Fri, Jan 31, 2014 at 6:15 AM, Sarah Sharp
> <sarah.a.sharp@linux.intel.com> wrote:
> > On Thu, Jan 30, 2014 at 10:50:21PM +0100, Bj=F8rn Mork wrote:
> >> FWIW, the plan looks fine to me.  Just adding a couple of hints to
> >> simplify the implementation.
> >>
> >> Sarah Sharp <sarah.a.sharp@linux.intel.com> writes:
> >>
> >> > Let's do this fix the right way, instead of wall papering over t=
he
> >> > issue.  Here's what we should do:
> >> >
> >> > 1. Disable scatter-gather for the ax88179_178a driver when it's =
under an
> >> >    xHCI host.
> >>
> >> No need to make this conditional.  SG is only enabled in the
> >> ax88179_178a driver if udev->bus->no_sg_constraint is true, so it
> >> applies only to xHCI hosts in the first place.
> >
> > Ah, so you're suggesting just reverting commit
> > 3804fad45411b48233b48003e33a78f290d227c8 "USBNET: ax88179_178a: ena=
ble
> > tso if usb host supports sg dma"?
>=20
> If I understand the problem correctly, the current issue is that xhci=
 driver
> doesn't support the arbitrary dma length not well, but per XHCI spec,=
 it
> should be supported, right?
>=20
> If the above is correct, reverting the commit isn't correct since the=
re isn't
> any issue about the commit, so I suggest to disable the flag in xhci
> for the buggy devices, and it may be enabled again if the problem is =
fixed.

Ok, I like that plan, since it means I don't have to touch any
networking code to fix this. :)

I believe that means we'll have to disable the flag for all 1.0 xHCI
hosts, since those are the ones that need TD fragments.

> >> > 2. Revert the following commits:
> >> >    f2d9b991c549 xhci: Set scatter-gather limit to avoid failed b=
lock writes.
> >> >    d6c9ea9069af xhci: Avoid infinite loop when sg urb requires t=
oo many trbs
> >> >    35773dac5f86 usb: xhci: Link TRB must not occur within a USB =
payload burst
> >> >
> >> > 3. Dan and Mathias can work together to come up with an overall =
plan to
> >> >    change the xHCI driver architecture to be fully compliant wit=
h the TD
> >> >    fragment rules.  That can be done over the next few kernel re=
leases.
> >> >
> >> > The end result is that we don't destabilize storage or break use=
rspace
> >> > USB drivers, we don't break people's xHCI host controllers,
> >> > the ax88179_178a USB ethernet devices still work under xHCI (a b=
it with
> >> > worse performance), and other USB ethernet devices still get the
> >> > performance improvement introduced in 3.12.
> >>
> >> No other usbnet drivers has enabled SG...  Which is why you have o=
nly
> >> seen this problem with the ax88179_178a devices.  So there is no
> >> performance improvement to keep.
>=20
> In my test environment, the patch does improve both throughput and
> cpu utilization, if you search the previous email for the patch, you =
can
> see the data.

Right, I did see the performance improvement note in that commit.  Do
you know if the ARM A15 dual core board was using a 0.96 xHCI host, or =
a
1.0 host?  You can find out by reloading the xHCI driver with dynamic
debugging turned on:

# sudo modprobe xhci_hcd dyndbg

and then look for lines like:

[25296.765767] xhci_hcd 0000:00:14.0: HCIVERSION: 0x100

Sarah Sharp

From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Thu, 06 Aug 2009 07:00:20 -0600
Message-ID: <4A7A9BA40200005A00051BAB@sinclair.provo.novell.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
 <20090806081955.GA9752@redhat.com>
 <4A7A8F7B0200005A00051B84@sinclair.provo.novell.com>
 <20090806122449.GC11038@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <alacrityvm-devel@lists.sourceforge.net>, <kvm@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755560AbZHFNAZ@vger.kernel.org>
In-Reply-To: <20090806122449.GC11038@redhat.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 8/6/2009 at  8:24 AM, in message <20090806122449.GC11038@redhat.com>,
"Michael S. Tsirkin" <mst@redhat.com> wrote: 
> On Thu, Aug 06, 2009 at 06:08:27AM -0600, Gregory Haskins wrote:
>> Hi Michael,
>> 
>> >>> On 8/6/2009 at  4:19 AM, in message <20090806081955.GA9752@redhat.com>,
>> "Michael S. Tsirkin" <mst@redhat.com> wrote: 
>> > On Mon, Aug 03, 2009 at 01:17:30PM -0400, Gregory Haskins wrote:
>> >> (Applies to v2.6.31-rc5, proposed for linux-next after review is complete)
>> > 
>> > These are guest drivers, right?
>> 
>> Yep.
>> 
>> > Merging the guest first means relying on
>> > kernel interface from an out of tree driver, which well might change
>> > before it goes in.
>> 
>> ABI compatibility is already addressed/handled, so even if that is true its 
> not a problem.
> 
> It is? With versioning? Presumably this:
> 
> +       params.devid   = vdev->id;
> +       params.version = version;
> +
> +       ret = vbus_pci_hypercall(VBUS_PCI_HC_DEVOPEN,
> +                                &params, sizeof(params));
> +       if (ret < 0)
> +               return ret;

This is part of it.  There are various ABI version components (which, by the way, are only expected to only allow change while the code is experimental/alpha).  The other component is capability functions (such as NEGCAP in the venet driver).

> 
> Even assuming host even knows how to decode this structure (e.g.  some
> other host module doesn't use VBUS_PCI_HC_DEVOPEN),

This argument demonstrates a fundamental lack of understanding on how AlacrityVM works.  Please study the code more closely and you will see that your concern is illogical.  If it's still not clear, let me know and I will walk it through for you.

> checks the version
> and denies older guests, this might help guest not to crash, but guest
> still won't work.

Thats ok.  As I said above, the version number is just there for gross ABI protection and generally will never be changed once a driver is "official" (if at all).  We use things like capability-bit negotiation to allow backwards compat.

For an example, see drivers/net/vbus-enet.c, line 703:

http://git.kernel.org/?p=linux/kernel/git/ghaskins/alacrityvm/linux-2.6.git;a=blob;f=drivers/net/vbus-enet.c;h=7220f43723adc5b0bece1bc37974fae1b034cd9e;hb=b3b2339efbd4e754b1c85f8bc8f85f21a1a1f509#l703

venet exposes a verb "NEGCAP" (negotiate capabilities), which is used to extend the ABI.  The version number you quote above (on the device open) is really just a check to make sure the NEGCAP ABI is compatible.  The rest of the abi is negotiated at runtime with capability feature bits.

FWIW; I decided to not built a per-device capability into the low-level vbus protocol (e.g. there is no VBUS_PCI_HC_NEGCAP) because I felt as though the individual devices could better express their own capability mechanism, rather than try to generalize it.  Therefore it is up to each device to define its own mechanism, presumably using a verb from its own private call() namespace (as venet has done).

> 
>> > Would it make more sense to start merging with the host side of the 
> project?
>> 
>> Not necessarily, no.  These are drivers for a "device", so its no
>> different than merging any other driver really.  This is especially
>> true since the hypervisor is also already published and freely
>> available today, so anyone can start using it.
> 
> The difference is clear to me: devices do not get to set kernel/userspace
> interfaces. This "device" depends on a specific interface between
> kernel and (guest) userspace.

This doesn't really parse for me, but I think the gist of it is based on an incorrect assumption.

Can you elaborate?

Kind Regards,
-Greg

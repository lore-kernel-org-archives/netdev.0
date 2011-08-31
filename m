From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH] virtio-net: Read MAC only after initializing MSI-X
Date: Wed, 31 Aug 2011 19:24:36 +0300
Message-ID: <1314807876.14150.13.camel@lappy>
References: <1313225461-24458-1-git-send-email-levinsasha928@gmail.com>
	 <20110819152335.GA19489@redhat.com> <87hb5a5m3x.fsf@rustcorp.com.au>
	 <20110822083613.GA18556@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110822083613.GA18556@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm wondering if we can switch to using a linked list 'capabilities'
structure similar to whats being done with PCI capabilities.

Here are the pros and the cons as I see them:

Pros:
 * Simpler code - currently before each access to the virtio config
space we have to check whether MSI-X is on and whether the device has
64bit features. This isn't necessarily slow, but it complicates the
code.

 * Future proof - code will be a mess once 5-6 features can change the
config space.

 * 'Concept reuse' - using same concepts in virtio-pci as the ones used
in PCI ('PCI Capabilities list') would make it easier to understand, and
would implement the same method to use optional features as in the layer
above.


Cons:
 * MSI-X is already moving the config space, we'll need to keep
supporting it for a while, but it would mean that it's the only thing we
need to keep backwards compatible.

 * 64bit features also move config space, but they're brand new in the
spec and aren't implemented in the kernel yet - I doubt anyone
implemented it anywhere else yet.

On Mon, 2011-08-22 at 11:36 +0300, Michael S. Tsirkin wrote:
> On Mon, Aug 22, 2011 at 09:54:50AM +0930, Rusty Russell wrote:
> > On Fri, 19 Aug 2011 18:23:35 +0300, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > > On Sat, Aug 13, 2011 at 11:51:01AM +0300, Sasha Levin wrote:
> > > > The MAC of a virtio-net device is located at the first field of the device
> > > > specific header. This header is located at offset 20 if the device doesn't
> > > > support MSI-X or offset 24 if it does.
> > > > 
> > > > Current code in virtnet_probe() used to probe the MAC before checking for
> > > > MSI-X, which means that the read was always made from offset 20 regardless
> > > > of whether MSI-X in enabled or not.
> > > > 
> > > > This patch moves the MAC probe to after the detection of whether MSI-X is
> > > > enabled. This way the MAC will be read from offset 24 if the device indeed
> > > > supports MSI-X.
> > > > 
> > > > Cc: Rusty Russell <rusty@rustcorp.com.au>
> > > > Cc: Michael S. Tsirkin <mst@redhat.com>
> > > > Cc: virtualization@lists.linux-foundation.org
> > > > Cc: netdev@vger.kernel.org
> > > > Cc: kvm@vger.kernel.org
> > > > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> > > 
> > > I am not sure I see a bug in virtio: the config pace layout simply
> > > changes as msix is enabled and disabled (and if you look at the latest
> > > draft, also on whether 64 bit features are enabled).
> > > It doesn't depend on msix capability being present in device.
> > > 
> > > The spec seems to be explicit enough:
> > > 	If MSI-X is enabled for the device, two additional fields immediately
> > > 	follow this header.
> > > 
> > > So I'm guessing the bug is in kvm tools which assume
> > > same layout for when msix is enabled and disabled.
> > > qemu-kvm seems to do the right thing so the device
> > > seems to get the correct mac.
> > 
> > So, the config space moves once MSI-X is enabled?  In which case, it
> > should say "ONCE MSI-X is enabled..."
> > 
> > Thanks,
> > Rusty.
> 
> Yes. Or maybe 'WHEN' - since if MSI-X is disabled again, it moves back.
> Let's update the spec to make it clearer?
> 

-- 

Sasha.

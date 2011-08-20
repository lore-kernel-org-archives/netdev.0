From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: Read MAC only after initializing MSI-X
Date: Sat, 20 Aug 2011 23:00:44 +0300
Message-ID: <20110820200043.GB5276@redhat.com>
References: <1313225461-24458-1-git-send-email-levinsasha928@gmail.com>
 <20110819152335.GA19489@redhat.com>
 <1313771587.12243.16.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1313771587.12243.16.camel@lappy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 19, 2011 at 07:33:07PM +0300, Sasha Levin wrote:
> On Fri, 2011-08-19 at 18:23 +0300, Michael S. Tsirkin wrote:
> > On Sat, Aug 13, 2011 at 11:51:01AM +0300, Sasha Levin wrote:
> > > The MAC of a virtio-net device is located at the first field of the device
> > > specific header. This header is located at offset 20 if the device doesn't
> > > support MSI-X or offset 24 if it does.
> > > 
> > > Current code in virtnet_probe() used to probe the MAC before checking for
> > > MSI-X, which means that the read was always made from offset 20 regardless
> > > of whether MSI-X in enabled or not.
> > > 
> > > This patch moves the MAC probe to after the detection of whether MSI-X is
> > > enabled. This way the MAC will be read from offset 24 if the device indeed
> > > supports MSI-X.
> > > 
> > > Cc: Rusty Russell <rusty@rustcorp.com.au>
> > > Cc: Michael S. Tsirkin <mst@redhat.com>
> > > Cc: virtualization@lists.linux-foundation.org
> > > Cc: netdev@vger.kernel.org
> > > Cc: kvm@vger.kernel.org
> > > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> > 
> > I am not sure I see a bug in virtio: the config pace layout simply
> > changes as msix is enabled and disabled (and if you look at the latest
> > draft, also on whether 64 bit features are enabled).
> > It doesn't depend on msix capability being present in device.
> > 
> > The spec seems to be explicit enough:
> > 	If MSI-X is enabled for the device, two additional fields immediately
> > 	follow this header.
> > 
> > So I'm guessing the bug is in kvm tools which assume
> > same layout for when msix is enabled and disabled.
> > qemu-kvm seems to do the right thing so the device
> > seems to get the correct mac.
> 
> We assumed that PCI config space has a static layout like most other
> devices. Having a behavior of "First bit 20 does something, but after
> enabling MSI-X it does something completely different" sounds strange.

The layout is always virtio header followed by device specific header.
We started with a small header so when more data was added, we could not
extend the header unconditionally.

We can't change that behaviour for MSI-X now, guests and
hosts rely on it.

>
> I'm wondering why offsets of the config structure change during run time
> and are not statically defined when the device is started.

That's because of backwards compatibility with old guests.
When we know the guest is new, we expose new layout,
but old guests must see old layout.

> It's not like VIRTIO_F_FEATURES_HI can be disabled after it was enabled,

Yes it can, e.g. at guest reset. Generally features can be tweaked
any way guest likes until status is set to OK.

> or MSI-X can be simply disabled during run time.

Not sure what you mean by 'run time'. Guest can reset
or disable the device, change any parameters,
then re-enable.

> Maybe this is better solved by copying the way it was done in PCI itself
> with capability linked list?
> 
> -- 
> 
> Sasha.

There are any number of ways to lay out the structure.  I went for what
seemed a simplest one.  For MSI-X the train has left the station.  We
can probably still tweak where the high 32 bit features
for 64 bit features are.  No idea if it's worth it.


-- 
MST

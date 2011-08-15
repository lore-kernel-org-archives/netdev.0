From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: Read MAC only after initializing MSI-X
Date: Mon, 15 Aug 2011 09:55:26 +0930
Message-ID: <87vctz7c7d.fsf@rustcorp.com.au>
References: <1313225461-24458-1-git-send-email-levinsasha928@gmail.com> <878vqw9007.fsf@rustcorp.com.au> <1313330252.2422.12.camel@sasha>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1313330252.2422.12.camel@sasha>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 14 Aug 2011 16:57:32 +0300, Sasha Levin <levinsasha928@gmail.com> wrote:
> On Sun, 2011-08-14 at 12:23 +0930, Rusty Russell wrote:
> > On Sat, 13 Aug 2011 11:51:01 +0300, Sasha Levin <levinsasha928@gmail.com> wrote:
> > > The MAC of a virtio-net device is located at the first field of the device
> > > specific header. This header is located at offset 20 if the device doesn't
> > > support MSI-X or offset 24 if it does.
> > 
> > Erk.  This means, in general, we have to do virtio_find_single_vq or
> > config->find_vqs before we examine any config options.
> > 
> > Look at virtio_blk, which has the same error.
> > 
> > Solutions in order of best to worst:
> > (1) Enable MSI-X before calling device probe.  This means reserving two
> >     vectors in virtio_pci_probe to ensure we *can* do this, I think.  Michael?
> 
> Do you mean reserving the vectors even before we probed the device for
> MSI-X support? Wouldn't we need 3 vectors then? (config, input, output).

We want three, but *need* two: see vp_find_vqs().  Also, the generic
code doesn't know how many virtqueues we have on the device.

> > (2) Ensure ordering of "find_vqs then access config space" statically.  This
> >     probably means handing the vqs array to virtio_config_val, so noone
> >     can call it before they have their virtqueues.
> 
> Just noticed that only virtio-blk uses virtio_config_val(), while the
> others are still doing 'if(virtio_has_feature()) vdev->config->get()',
> I'll send patches to fix that regardless of what we end up doing here.

Thanks.

> Did you want to pass the vq array to virtio_config_val() just to check
> that they were already found? 

Not if we fix is using method #1...

Thanks,
Rusty.

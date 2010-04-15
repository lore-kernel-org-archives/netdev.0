From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC][PATCH v3 1/3] A device for zero-copy based on KVM virtio-net.
Date: Thu, 15 Apr 2010 17:06:43 +0200
Message-ID: <201004151706.43582.arnd@arndb.de>
References: <1270805865-16901-1-git-send-email-xiaohui.xin@intel.com> <201004141655.21885.arnd@arndb.de> <97F6D3BD476C464182C1B7BABF0B0AF5C18969A5@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <97F6D3BD476C464182C1B7BABF0B0AF5C18969A5@shzsmsx502.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 15 April 2010, Xin, Xiaohui wrote:
> 
> >It seems that you are duplicating a lot of functionality that
> >is already in macvtap. I've asked about this before but then
> >didn't look at your newer versions. Can you explain the value
> >of introducing another interface to user land?
> 
> >I'm still planning to add zero-copy support to macvtap,
> >hopefully reusing parts of your code, but do you think there
> >is value in having both?
> 
> I have not looked into your macvtap code in detail before.
> Does the two interface exactly the same? We just want to create a simple
> way to do zero-copy. Now it can only support vhost, but in future
> we also want it to support directly read/write operations from user space too.

Right now, the features are mostly distinct. Macvtap first of all provides
a "tap" style interface for users, and can also be used by vhost-net.
It also provides a way to share a NIC among a number of guests by software,
though I indent to add support for VMDq and SR-IOV as well. Zero-copy
is also not yet done in macvtap but should be added.

mpassthru right now does not allow sharing a NIC between guests, and
does not have a tap interface for non-vhost operation, but does the
zero-copy that is missing in macvtap.

> Basically, compared to the interface, I'm more worried about the modification
> to net core we have made to implement zero-copy now. If this hardest part
> can be done, then any user space interface modifications or integrations are 
> more easily to be done after that.

I agree that the network stack modifications are the hard part for zero-copy,
and your work on that looks very promising and is complementary to what I've
done with macvtap. Your current user interface looks good for testing this out,
but I think we should not merge it (the interface) upstream if we can get the
same or better result by integrating your buffer management code into macvtap.

I can try to merge your code into macvtap myself if you agree, so you
can focus on getting the internals right.

> >Not sure what I'm missing, but who calls the vq->receiver? This seems
> >to be neither in the upstream version of vhost nor introduced by your
> >patch.
> 
> See Patch v3 2/3 I have sent out, it is called by handle_rx() in vhost.

Ok, I see. As a general rule, it's preferred to split a patch series
in a way that makes it possible to apply each patch separately and still
get a working kernel, ideally with more features than the version before
the patch. I believe you could get there by reordering your patches to
make the actual driver the last one in the series.

Not a big problem though, I was mostly looking in the wrong place.

> >> +		ifr.ifr_name[IFNAMSIZ-1] = '\0';
> >> +
> >> +		ret = -EBUSY;
> >> +
> >> +		if (ifr.ifr_flags & IFF_MPASSTHRU_EXCL)
> >> +			break;
> 
> >Your current use of the IFF_MPASSTHRU* flags does not seem to make
> >any sense whatsoever. You check that this flag is never set, but set
> >it later yourself and then ignore all flags.
> 
> Using that flag is tried to prevent if another one wants to bind the same device
> Again. But I will see if it really ignore all other flags.

The ifr variable is on the stack of the mp_chr_ioctl function, and you never
look at the value after setting it. In order to prevent multiple opens
of that device, you probably need to lock out any other users as well,
and make it a property of the underlying device. E.g. you also want to
prevent users on the host from setting an IP address on the NIC and
using it to send and receive data there.

	Arnd

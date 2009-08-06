From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Thu, 6 Aug 2009 17:40:04 +0200
Message-ID: <200908061740.04276.arnd@arndb.de>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <4A7AE150.7040009@redhat.com> <4A7AAB1A0200005A00051BED@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Avi Kivity" <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Gregory Haskins" <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756118AbZHFPkN@vger.kernel.org>
In-Reply-To: <4A7AAB1A0200005A00051BED@sinclair.provo.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 06 August 2009, Gregory Haskins wrote:
> We can exchange out the "virtio-pci" module like this:
> 
>   (guest-side)
> |--------------------------
> | virtio-net
> |--------------------------
> | virtio-ring
> |--------------------------
> | virtio-bus
> |--------------------------
> | virtio-vbus
> |--------------------------
> | vbus-proxy
> |--------------------------
> | vbus-connector
> |--------------------------
>                       |
>                    (vbus)
>                       |
> |--------------------------
> | kvm.ko
> |--------------------------
> | vbus-connector
> |--------------------------
> | vbus
> |--------------------------
> | virtio-net-tap (vbus model)
> |--------------------------
> | netif
> |--------------------------
>      (host-side)
> 
> 
> So virtio-net runs unmodified.  What is "competing" here is "virtio-pci" vs "virtio-vbus".
> Also, venet vs virtio-net are technically competing.  But to say "virtio vs vbus" is inaccurate, IMO.


I think what's confusing everyone is that you are competing on multiple
issues:

1. Implementation of bus probing: both vbus and virtio are backed by
PCI devices and can be backed by something else (e.g. virtio by lguest
or even by vbus).

2. Exchange of metadata: virtio uses a config space, vbus uses devcall
to do the same.

3. User data transport: virtio has virtqueues, vbus has shm/ioq.

I think these three are the main differences, and the venet vs. virtio-net
question comes down to which interface the drivers use for each aspect. Do
you agree with this interpretation?

Now to draw conclusions from each of these is of course highly subjective,
but this is how I view it:

1. The bus probing is roughly equivalent, they both work and the
virtio method seems to need a little less code but that could be fixed
by slimming down the vbus code as I mentioned in my comments on the
pci-to-vbus bridge code. However, I would much prefer not to have both
of them, and virtio came first.

2. the two methods (devcall/config space) are more or less equivalent
and you should be able to implement each one through the other one. The
virtio design was driven by making it look similar to PCI, the vbus
design was driven by making it easy to implement in a host kernel. I
don't care too much about these, as they can probably coexist without
causing any trouble. For a (hypothetical) vbus-in-virtio device,
a devcall can be a config-set/config-get pair, for a virtio-in-vbus,
you can do a config-get and a config-set devcall and be happy. Each
could be done in a trivial helper library.

3. The ioq method seems to be the real core of your work that makes
venet perform better than virtio-net with its virtqueues. I don't see
any reason to doubt that your claim is correct. My conclusion from
this would be to add support for ioq to virtio devices, alongside
virtqueues, but to leave out the extra bus_type and probing method.

	Arnd <><

From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Thu, 06 Aug 2009 10:29:08 -0600
Message-ID: <4A7ACC940200005A00051C43@sinclair.provo.novell.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
 <4A7AE150.7040009@redhat.com>
 <4A7AAB1A0200005A00051BED@sinclair.provo.novell.com>
 <200908061740.04276.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <alacrityvm-devel@lists.sourceforge.net>,
	"Avi Kivity" <avi@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, <kvm@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Arnd Bergmann" <arnd@arndb.de>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200908061740.04276.arnd@arndb.de>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 8/6/2009 at 11:40 AM, in message <200908061740.04276.arnd@arndb.de>, Arnd
Bergmann <arnd@arndb.de> wrote: 
> On Thursday 06 August 2009, Gregory Haskins wrote:
>> We can exchange out the "virtio-pci" module like this:
>> 
>>   (guest-side)
>> |--------------------------
>> | virtio-net
>> |--------------------------
>> | virtio-ring
>> |--------------------------
>> | virtio-bus
>> |--------------------------
>> | virtio-vbus
>> |--------------------------
>> | vbus-proxy
>> |--------------------------
>> | vbus-connector
>> |--------------------------
>>                       |
>>                    (vbus)
>>                       |
>> |--------------------------
>> | kvm.ko
>> |--------------------------
>> | vbus-connector
>> |--------------------------
>> | vbus
>> |--------------------------
>> | virtio-net-tap (vbus model)
>> |--------------------------
>> | netif
>> |--------------------------
>>      (host-side)
>> 
>> 
>> So virtio-net runs unmodified.  What is "competing" here is "virtio-pci" vs 
> "virtio-vbus".
>> Also, venet vs virtio-net are technically competing.  But to say "virtio vs 
> vbus" is inaccurate, IMO.
> 
> 
> I think what's confusing everyone is that you are competing on multiple
> issues:
> 
> 1. Implementation of bus probing: both vbus and virtio are backed by
> PCI devices and can be backed by something else (e.g. virtio by lguest
> or even by vbus).

More specifically, vbus-proxy and virtio-bus can be backed by modular adapters.

vbus-proxy can be backed by vbus-pcibridge (as it is in AlacrityVM).  It was backed by KVM-hypercalls in previous releases, but we have deprecated/dropped that connector.  Other types of connectors are possible...

virtio-bus can be backed by virtio-pci, virtio-lguest, virtio-s390, and virtio-vbus (which is backed by vbus-proxy, et. al.)

"vbus" itself is actually the host-side container technology which vbus-proxy connects to.  This is an important distinction.

> 
> 2. Exchange of metadata: virtio uses a config space, vbus uses devcall
> to do the same.

Sort of.  You can use devcall() to implement something like config-space (and in fact, we do use it like this for some operations).  But this can also be fast path (for when you need synchronous behavior).

This has various uses, such as when you need synchronous updates from non-preemptible guest code (cpupri, for instance, for -rt)

> 
> 3. User data transport: virtio has virtqueues, vbus has shm/ioq.

Not quite:  vbus has shm + shm-signal.  You can then overlay shared-memory protocols over that, such as virtqueues, ioq, or even non-ring constructs.

I also consider the synchronous call() method to be part of the transport (tho more for niche devices, like -rt)

> 
> I think these three are the main differences, and the venet vs. virtio-net
> question comes down to which interface the drivers use for each aspect. Do
> you agree with this interpretation?
> 
> Now to draw conclusions from each of these is of course highly subjective,
> but this is how I view it:
> 
> 1. The bus probing is roughly equivalent, they both work and the
> virtio method seems to need a little less code but that could be fixed
> by slimming down the vbus code as I mentioned in my comments on the
> pci-to-vbus bridge code. However, I would much prefer not to have both
> of them, and virtio came first.
> 
> 2. the two methods (devcall/config space) are more or less equivalent
> and you should be able to implement each one through the other one. The
> virtio design was driven by making it look similar to PCI, the vbus
> design was driven by making it easy to implement in a host kernel. I
> don't care too much about these, as they can probably coexist without
> causing any trouble. For a (hypothetical) vbus-in-virtio device,
> a devcall can be a config-set/config-get pair, for a virtio-in-vbus,
> you can do a config-get and a config-set devcall and be happy. Each
> could be done in a trivial helper library.

Yep, in fact I publish something close to what I think you are talking about back in April

http://lkml.org/lkml/2009/4/21/427

> 
> 3. The ioq method seems to be the real core of your work that makes
> venet perform better than virtio-net with its virtqueues. I don't see
> any reason to doubt that your claim is correct. My conclusion from
> this would be to add support for ioq to virtio devices, alongside
> virtqueues, but to leave out the extra bus_type and probing method.

While I appreciate the sentiment, I doubt that is actually whats helping here.

There are a variety of factors that I poured into venet/vbus that I think contribute to its superior performance.  However, the difference in the ring design I do not think is one if them.  In fact, in many ways I think Rusty's design might turn out to be faster if put side by side because he was much more careful with cacheline alignment than I was.  Also note that I was careful to not pick one ring vs the other ;)  They both should work.

IMO, we are only looking at the tip of the iceberg when looking at this purely as the difference between virtio-pci vs virtio-vbus, or venet vs virtio-net.

Really, the big thing I am working on here is the host side device-model.  The idea here was to design a bus model that was conducive to high performance, software to software IO that would work in a variety of environments (that may or may not have PCI).  KVM is one such environment, but I also have people looking at building other types of containers, and even physical systems (host+blade kind of setups).

The idea is that the "connector" is modular, and then something like virtio-net or venet "just work": in kvm, in the userspace container, on the blade system. 

It provides a management infrastructure that (hopefully) makes sense for these different types of containers, regardless of whether they have PCI, QEMU, etc (e.g. things that are inherent to KVM, but not others).

I hope this helps to clarify the project :)

Kind Regards,
-Greg

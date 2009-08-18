From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Mon, 17 Aug 2009 20:08:24 -0500
Message-ID: <4A89FF08.30509@codemonkey.ws>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Gregory Haskins <ghaskins@novell.com>,
	kvm@vger.kernel.org, Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758548AbZHRBI2@vger.kernel.org>
In-Reply-To: <4A8965E0.8050608@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
> Note: No one has ever proposed to change the virtio-ABI.

virtio-pci is part of the virtio ABI.  You are proposing changing that.

You cannot add new kernel modules to guests and expect them to remain 
supported.  So there is value in reusing existing ABIs

>> I think the reason vbus gets better performance for networking today is
>> that vbus' backends are in the kernel while virtio's backends are
>> currently in userspace.
>>     
>
> Well, with all due respect, you also said initially when I announced
> vbus that in-kernel doesn't matter, and tried to make virtio-net run as
> fast as venet from userspace ;)  Given that we never saw those userspace
> patches from you that in fact equaled my performance, I assume you were
> wrong about that statement.  Perhaps you were wrong about other things too?
>   

I'm wrong about a lot of things :-)  I haven't yet been convinced that 
I'm wrong here though.

One of the gray areas here is what constitutes an in-kernel backend.  
tun/tap is a sort of an in-kernel backend.  Userspace is still involved 
in all of the paths.  vhost seems to be an intermediate step between 
tun/tap and vbus.  The fast paths avoid userspace completely.  Many of 
the slow paths involve userspace still (like migration apparently).  
With vbus, userspace is avoided entirely.  In some ways, you could argue 
that slirp and vbus are opposite ends of the virtual I/O spectrum.

I believe strongly that we should avoid putting things in the kernel 
unless they absolutely have to be.  I'm definitely interested in playing 
with vhost to see if there are ways to put even less in the kernel.  In 
particular, I think it would be a big win to avoid knowledge of slots in 
the kernel by doing ring translation in userspace.  This implies a 
userspace transition in the fast path.  This may or may not be 
acceptable.  I think this is going to be a very interesting experiment 
and will ultimately determine whether my intuition about the cost of 
dropping to userspace is right or wrong.


> Conversely, I am not afraid of requiring a new driver to optimize the
> general PV interface.  In the long term, this will reduce the amount of
> reimplementing the same code over and over, reduce system overhead, and
> it adds new features not previously available (for instance, coalescing
> and prioritizing interrupts).
>   

I think you have a lot of ideas and I don't know that we've been able to 
really understand your vision.  Do you have any plans on writing a paper 
about vbus that goes into some of your thoughts in detail?

>> If that's the case, then I don't see any
>> reason to adopt vbus unless Greg things there are other compelling
>> features over virtio.
>>     
>
> Aside from the fact that this is another confusion of the vbus/virtio
> relationship...yes, of course there are compelling features (IMHO) or I
> wouldn't be expending effort ;)  They are at least compelling enough to
> put in AlacrityVM.

This whole AlactricyVM thing is really hitting this nail with a 
sledgehammer.  While the kernel needs to be very careful about what it 
pulls in, as long as you're willing to commit to ABI compatibility, we 
can pull code into QEMU to support vbus.  Then you can just offer vbus 
host and guest drivers instead of forking the kernel.

>   If upstream KVM doesn't want them, that's KVMs
> decision and I am fine with that.  Simply never apply my qemu patches to
> qemu-kvm.git, and KVM will be blissfully unaware if vbus is present.

As I mentioned before, if you submit patches to upstream QEMU, we'll 
apply them (after appropriate review).  As I said previously, we want to 
avoid user confusion as much as possible.  Maybe this means limiting it 
to -device or a separate machine type.  I'm not sure, but that's 
something we can discussion on qemu-devel.

>   I
> do hope that I can convince the KVM community otherwise, however. :)
>   

Regards,

Anthony Liguori

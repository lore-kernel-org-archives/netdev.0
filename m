From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 09:31:32 -0600
Message-ID: <4B30E654.40702@codemonkey.ws>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu>	<4B2F9582.5000002@gmail.com> <4B2F978D.7010602@redhat.com>	<4B2F9C85.7070202@gmail.com> <4B2FA42F.3070408@codemonkey.ws>	<4B2FA655.6030205@gmail.com> <4B2FAE7B.9030005@codemonkey.ws>	<4B2FB3F1.5080808@gmail.com> <4B300EF8.8010602@codemonkey.ws> <87637zdy9g.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <87637zdy9g.fsf@basil.nowhere.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/22/2009 05:49 AM, Andi Kleen wrote:
> Anthony Liguori<anthony@codemonkey.ws>  writes:
>    
>> On a modern Nehalem, I would be surprised if an MMIO exit handled in
>> the kernel was muck more than 2us.  The hardware is getting very, very
>> fast.  The trends here are very important to consider when we're
>> looking at architectures that we potentially are going to support for
>> a long time.
>>      
> When you talk about trends the trend for IO is also to get faster.
>
> An exit will be always more expensive than passing something from
> another CPU in shared memory. An exit is much more work,
> with lots of saved context and fundamentally synchronous,
> even with all the tricks hardware can do.  And then there's the
> in kernel handler too.
>    

Noone is advocating avoiding shared memory and doing more exits in the 
IO path :-)

Whether it's x2apic support or whether it's more sophisicated hardware 
apic virtualization support, the point remains that taking an exit due 
to EOI is likely to not be required in the near term future.

So far, the only actual technical advantage I've seen is that vbus 
avoids EOI exits.  My response is that I don't think that that's so 
important especially when you consider that it's going to not matter so 
much in the future and that Avi has some ideas about how to eliminate 
some of them even on older hardware.  I'm also suspicious that EOI exits 
alone would result in a huge performance differiental between the two 
architectures.

We think we understand why vbus does better than the current userspace 
virtio backend.  That's why we're building vhost-net.  It's not done 
yet, but our expectation is that it will do just as well if not better.

> Shared memory passing from another CPU is a much cheaper
> operation and more likely to scale with IO rate improvements.
>
> The basic problem in this discussion seems to be the usual
> disconnect between working code (I understand Gregory has working
> code that demonstrates the performance advances he's claiming)
> versus unwritten optimizations.
>    

vbus has one driver (networking) that supports one guest (very new Linux 
kernels).  It supports one hypervisor (KVM) on one architecture (x86).

On the other hand, virtio has six upstream drivers (console, network, 
block, rng, balloon, 9p) with at least as many in development.  It 
supports kernels going back to at least 2.6.18, almost all versions of 
Windows, and has experimental drivers for other OSes.  It supports KVM, 
lguest, VirtualBox, with support for additional hypervisors under 
development.  It supports at least five architectures (x86, ppc, s390, 
ia64, arm).

You are correct, vbus has better numbers than virtio today.  But so far, 
it's hardly an apples-to-apples comparison.  Our backend networking 
driver has been implemented entirely in userspace up until very 
recently.  There really isn't any good performance data comparing vbus 
to vhost-net largely because vhost-net is still under active development.

The most important point though, is that so far, I don't think Greg has 
been able to articulate _why_ vbus would perform better than vhost-net.

If that can be articulated in a way that we all agree vbus has a 
technical advantage over vhost-net, then I'm absolutely in agreement 
that it should be merged.

I think the comparison would be if someone submitted a second e1000 
driver that happened to do better on one netperf test than the current 
e1000 driver.

You can argue, hey, choice is good, let's let a user choose if they want 
to use the faster e1000 driver.  But surely, the best thing for a user 
is to figure out why the second e1000 driver is better on that one test, 
integrate that change into the current e1000 driver, or decided that the 
new e1000 driver is more superior in architecture and do the required 
work to make the new e1000 driver a full replacement for the old one.

Regards,

Anthony Liguori

> Unwritten code tends to always sound nicer, but it remains to be seen
> if it can deliver what it promises.
>
>  From a abstract stand point having efficient paravirtual IO interfaces
> seem attractive.
>
> I also personally don't see a big problem in having another set of
> virtual drivers -- Linux already has plenty (vmware, xen, virtio, power,
> s390-vm, ...) and it's not that they would be a particular maintenance
> burden impacting the kernel core.
>
> -Andi
>    


From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 16:37:04 +0300
Message-ID: <49D61100.5010202@redhat.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com> <49D4A4EB.8020105@redhat.com> <49D4AE0C.3000604@novell.com> <49D4B2C0.5060906@redhat.com> <49D4B594.6080703@novell.com> <49D4B8B4.4020003@redhat.com> <49D4BF70.1060301@novell.com> <49D4C191.2070502@redhat.com> <49D4CAA7.3020004@novell.com> <49D4CC61.6010105@redhat.com> <49D4CEB1.9020001@redhat.com> <49D4D075.9010702@codemonkey.ws> <49D4E33F.5000303@codemonkey.ws> <49D5FAFD.1010102@novell.com> <49D5FDF9.7090602@redhat.com> <49D6
 0B91.6010503@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D60B91.6010503@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
> Avi Kivity wrote:
>   
>> Gregory Haskins wrote:
>>     
>>> So again, I am proposing for consideration of accepting my work (either
>>> in its current form, or something we agree on after the normal review
>>> process) not only on the basis of the future development of the
>>> platform, but also to keep current components in their running to their
>>> full potential.  I will again point out that the code is almost
>>> completely off to the side, can be completely disabled with config
>>> options, and I will maintain it.  Therefore the only real impact is to
>>> people who care to even try it, and to me.
>>>   
>>>       
>> Your work is a whole stack.  Let's look at the constituents.
>>
>> - a new virtual bus for enumerating devices.
>>
>> Sorry, I still don't see the point.  It will just make writing drivers
>> more difficult.  The only advantage I've heard from you is that it
>> gets rid of the gunk.  Well, we still have to support the gunk for
>> non-pv devices so the gunk is basically free.  The clean version is
>> expensive since we need to port it to all guests and implement
>> exciting features like hotplug.
>>     
> My real objection to PCI is fast-path related.  I don't object, per se,
> to using PCI for discovery and hotplug.  If you use PCI just for these
> types of things, but then allow fastpath to use more hypercall oriented
> primitives, then I would agree with you.  We can leave PCI emulation in
> user-space, and we get it for free, and things are relatively tidy.
>   

PCI has very little to do with the fast path (nothing, if we use MSI).

> Its once you start requiring that we stay ABI compatible with something
> like the existing virtio-net in x86 KVM where I think it starts to get
> ugly when you try to move it into the kernel.  So that is what I had a
> real objection to.  I think as long as we are not talking about trying
> to make something like that work, its a much more viable prospect.
>   

I don't see why the fast path of virtio-net would be bad.  Can you 
elaborate?

Obviously all the pci glue stays in userspace.

> So what I propose is the following: 
>
> 1) The core vbus design stays the same (or close to it)
>   

Sorry, I still don't see what advantage this has over PCI, and how you 
deal with the disadvantages.

> 2) the vbus-proxy and kvm-guest patch go away
> 3) the kvm-host patch changes to work with coordination from the
> userspace-pci emulation for things like MSI routing
> 4) qemu will know to create some MSI shim 1:1 with whatever it
> instantiates on the bus (and can communicate changes
>   

Don't userstand.  What's this MSI shim?

> 5) any drivers that are written for these new PCI-IDs that might be
> present are allowed to use a hypercall ABI to talk after they have been
> probed for that ID (e.g. they are not limited to PIO or MMIO BAR type
> access methods).
>   

The way we'd to it with virtio is to add a feature bit that say "you can 
hypercall here instead of pio".  This way old drivers continue to work.

Note that nothing prevents us from trapping pio in the kernel (in fact, 
we do) and forwarding it to the device.  It shouldn't be any slower than 
hypercalls.

> Once I get here, I might have greater clarity to see how hard it would
> make to emulate fast path components as well.  It might be easier than I
> think.
>
> This is all off the cuff so it might need some fine tuning before its
> actually workable.
>
> Does that sound reasonable?
>   

The vbus part (I assume you mean device enumeration) worries me.  I 
don't think you've yet set down what its advantages are.  Being pure and 
clean doesn't count, unless you rip out PCI from all existing installed 
hardware and from Windows.

>> - finer-grained point-to-point communication abstractions
>>
>> Where virtio has ring+signalling together, you layer the two.  For
>> networking, it doesn't matter.  For other applications, it may be
>> helpful, perhaps you have something in mind.
>>     
>
> Yeah, actually.  Thanks for bringing that up.
>
> So the reason why signaling and the ring are distinct constructs in the
> design is to facilitate constructs other than rings.  For instance,
> there may be some models where having a flat shared page is better than
> a ring.  A ring will naturally preserve all values in flight, where as a
> flat shared page would not (last update is always current).  There are
> some algorithms where a previously posted value is obsoleted by an
> update, and therefore rings are inherently bad for this update model. 
> And as we know, there are plenty of algorithms where a ring works
> perfectly.  So I wanted that flexibility to be able to express both.
>   

I agree that there is significant potential here.

> One of the things I have in mind for the flat page model is that RT vcpu
> priority thing.  Another thing I am thinking of is coming up with a PV
> LAPIC type replacement (where we can avoid doing the EOI trap by having
> the PICs state shared).
>   

You keep falling into the paravirtualize the entire universe trap.  If 
you look deep down, you can see Jeremy struggling in there trying to 
bring dom0 support to Linux/Xen.

The lapic is a huge ball of gunk but ripping it out is a monumental job 
with no substantial benefits.  We can at much lower effort avoid the EOI 
trap by paravirtualizing that small bit of ugliness.  Sure the result 
isn't a pure and clean room implementation.  It's a band aid.  But I'll 
take a 50-line band aid over a 3000-line implementation split across 
guest and host, which only works with Linux.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.


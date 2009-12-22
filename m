From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Mon, 21 Dec 2009 18:12:40 -0600
Message-ID: <4B300EF8.8010602@codemonkey.ws>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <4B2F978D.7010602@redhat.com> <4B2F9C85.7070202@gmail.com> <4B2FA42F.3070408@codemonkey.ws> <4B2FA655.6030205@gmail.com> <4B2FAE7B.9030005@codemonkey.ws> <4B2FB3F1.5080808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4B2FB3F1.5080808@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/21/2009 11:44 AM, Gregory Haskins wrote:
> Well, surely something like SR-IOV is moving in that direction, no?
>    

Not really, but that's a different discussion.

>> But let's focus on concrete data.  For a given workload,
>> how many exits do you see due to EOI?
>>      
> Its of course highly workload dependent, and I've published these
> details in the past, I believe.  Off the top of my head, I recall that
> virtio-pci tends to throw about 65k exits per second, vs about 32k/s for
> venet on a 10GE box, but I don't recall what ratio of those exits are
> EOI.

Was this userspace virtio-pci or was this vhost-net?  If it was the 
former, then were you using MSI-X?  If you weren't, there would be an 
additional (rather heavy) exit per-interrupt to clear the ISR which 
would certainly account for a large portion of the additional exits.

>    To be perfectly honest, I don't care.  I do not discriminate
> against the exit type...I want to eliminate as many as possible,
> regardless of the type.  That's how you go fast and yet use less CPU.
>    

It's important to understand why one mechanism is better than another.   
All I'm looking for is a set of bullet points that say, vbus does this, 
vhost-net does that, therefore vbus is better.  We would then either 
say, oh, that's a good idea, let's change vhost-net to do that, or we 
would say, hrm, well, we can't change vhost-net to do that because of 
some fundamental flaw, let's drop it and adopt vbus.

It's really that simple :-)


>>   They should be relatively rare
>> because obtaining good receive batching is pretty easy.
>>      
> Batching is poor mans throughput (its easy when you dont care about
> latency), so we generally avoid as much as possible.
>    

Fair enough.

>> Considering
>> these are lightweight exits (on the order of 1-2us),
>>      
> APIC EOIs on x86 are MMIO based, so they are generally much heavier than
> that.  I measure at least 4-5us just for the MMIO exit on my Woodcrest,
> never mind executing the locking/apic-emulation code.
>    

You won't like to hear me say this, but Woodcrests are pretty old and 
clunky as far as VT goes :-)

On a modern Nehalem, I would be surprised if an MMIO exit handled in the 
kernel was muck more than 2us.  The hardware is getting very, very 
fast.  The trends here are very important to consider when we're looking 
at architectures that we potentially are going to support for a long time.

>> you need an awfully
>> large amount of interrupts before you get really significant performance
>> impact.  You would think NAPI would kick in at this point anyway.
>>
>>      
> Whether NAPI can kick in or not is workload dependent, and it also does
> not address coincident events.  But on that topic, you can think of
> AlacrityVM's interrupt controller as "NAPI for interrupts", because it
> operates on the same principle.  For what its worth, it also operates on
> a "NAPI for hypercalls" concept too.
>    

The concept of always batching hypercalls has certainly been explored 
within the context of Xen.  But then when you look at something like 
KVM's hypercall support, it turns out that with sufficient cleverness in 
the host, we don't even bother with the MMU hypercalls anymore.

Doing fancy things in the guest is difficult to support from a long term 
perspective.  It'll more or less never work for Windows and even the lag 
with Linux makes it difficult for users to see the benefit of these 
changes.  You get a lot more flexibility trying to solve things in the 
host even if it's convoluted (like TPR patching).

>> Do you have data demonstrating the advantage of EOI mitigation?
>>      
> I have non-scientifically gathered numbers in my notebook that put it on
> average of about 55%-60% reduction in EOIs for inbound netperf runs, for
> instance.  I don't have time to gather more in the near term, but its
> typically in that range for a chatty enough workload, and it goes up as
> you add devices.  I would certainly formally generate those numbers when
> I make another merge request in the future, but I don't have them now.
>    

I don't think it's possible to make progress with vbus without detailed 
performance data comparing both vbus and virtio (vhost-net).  On the 
virtio/vhost-net side, I think we'd be glad to help gather/analyze that 
data.  We have to understand why one's better than the other and then we 
have to evaluate whether we can bring those benefits into the later.  If 
we can't, we merge vbus.  If we can, we fix virtio.

Regards,

Anthony Liguori

> Kind Regards,
> -Greg
>
>    


From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH v2 00/19] virtual-bus
Date: Sat, 11 Apr 2009 19:45:50 +0300
Message-ID: <49E0C93E.5030205@redhat.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <49DE26EE.9030402@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49DE26EE.9030402@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
> Avi,
>
> Gregory Haskins wrote:
>   
>> Todo:
>> *) Develop some kind of hypercall registration mechanism for KVM so that
>>    we can use that as an integration point instead of directly hooking
>>    kvm hypercalls
>>   
>>     
>
> What would you like to see here?  I now remember why I removed the
> original patch I had for registration...it requires some kind of
> discovery mechanism on its own.  Note that this is hard, but I figured
> it would make the overall series simpler if I didn't go this route and
> instead just integrated with a statically allocated vector.  That being
> said, I have no problem adding this back in but figure we should discuss
> the approach so I don't go down a rat-hole ;)
>
>   


One idea is similar to signalfd() or eventfd().  Provide a kvm ioctl 
that takes a gsi and returns an fd.  Writes to the fd change the state 
of the line, possible triggering an interrupt.  Another ioctl takes a 
hypercall number or pio port as well as an existing fd.  Invocations of 
the hypercall or writes to the port write to the fd (using the same 
protocol as eventfd), so the other end can respond.

The nice thing is that this can be used by both kernel and userspace 
components, and for kernel components, hypercalls can be either buffered 
or unbuffered.

> So, one thing we could do is use a string-identifier to discover
> hypercall resources.  In this model, we would have one additional
> hypercall registered with kvm (in addition to the mmu-ops, etc) called
> KVM_HC_DYNHC or something like that.  The support for DYNHC could be
> indicated in the cpuid (much like I do with the RESET, DYNIRQ, and VBUS
> support today.   When hypercall provides register, the could provide a
> string such as "vbus", and they would be allocated a hypercall id. 
> Likewise, the HC_DYNHC interface would allow a guest to query the cpuid
> for the DYNHC feature, and then query the HC_DYNHC vector for a string
> to hc# translation.  If the provider is not present, we return -1 for
> the hc#, otherwise we return the one that was allocated.
>
> I know how you feel about string-ids in general, but I am not quite sure
> how to design this otherwise without it looking eerily similar to what I
> already have (which is registering a new HC vector in kvm_para.h)
>   

No need for a string ID.  Reserve a range of hypercall numbers for 
dynamic IDs.  Userspace allocates one and gives it to the device using 
its configuration space (as applies to whatever bus it is using).


-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

